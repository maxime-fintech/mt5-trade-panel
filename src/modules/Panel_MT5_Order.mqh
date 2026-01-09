#ifndef PANEL_MT5_ORDER_MQH
#define PANEL_MT5_ORDER_MQH

#include <Trade\Trade.mqh>
#include "Panel_MT5_Calcul.mqh"
#include "Panel_MT5_Types.mqh"

class CTradePanel;
class CTradePanelController;

class CTradePanelOrders
{
private:

   CTradePanel* m_view;
   CTradePanelController* m_controller;
   CTrade m_trade;

   // Tracks active order/position lifecycle for UI locking.
   ulong m_active_order_ticket;
   ulong m_active_position_ticket;
   bool m_order_placed;
   bool m_position_opened;

   string m_order_symbol;
   ENUM_TRADE_DIRECTION m_order_direction;
   ENUM_PANEL_ORDER_TYPE m_order_type;
   double m_order_lot;
   double m_order_price;
   double m_order_sl;
   double m_order_tp;

public:

   CTradePanelOrders(void)
   {
      m_view = NULL;
      m_controller = NULL;
      m_active_order_ticket = 0;
      m_active_position_ticket = 0;
      m_order_placed = false;
      m_position_opened = false;
      m_order_symbol = "";
      m_order_direction = TRADE_DIRECTION_SELL;
      m_order_type = PANEL_ORDER_TYPE_MARKET;
      m_order_lot = 0.0;
      m_order_price = 0.0;
      m_order_sl = 0.0;
      m_order_tp = 0.0;
   }

   ~CTradePanelOrders(void)
   {
   }

   void Initialize(CTradePanel* view, CTradePanelController* controller)
   {
      m_view = view;
      m_controller = controller;
   }

   bool OnTradeButtonClicked(void);

   bool OnBEClicked(void);

   bool OnCLOSEClicked(void);

   void OnTickUpdate(void);

   bool HasActiveOrderOrPosition(void);

   bool GetPanelData(string &symbol, ENUM_TRADE_DIRECTION &direction, ENUM_PANEL_ORDER_TYPE &order_type,
                     double &lot, double &price, double &sl_price, double &tp_price,
                     bool &sl_active, bool &tp_active);

private:

   bool OpenMarketOrder(string symbol, ENUM_TRADE_DIRECTION direction, double lot,
                        double sl_price, double tp_price, bool sl_active, bool tp_active);

   bool OpenLimitOrder(string symbol, ENUM_TRADE_DIRECTION direction, double lot, double price,
                       double sl_price, double tp_price, bool sl_active, bool tp_active);

   bool OpenStopOrder(string symbol, ENUM_TRADE_DIRECTION direction, double lot, double price,
                      double sl_price, double tp_price, bool sl_active, bool tp_active);

   bool CheckActiveOrder(void);

   bool CheckActivePosition(void);

   bool IsPositionInProfit(void);

   void LockPanel(void);

   void UnlockPanel(void);

   void UpdateButtonsState(void);

   bool ClosePosition(void);
};

bool CTradePanelOrders::OnTradeButtonClicked(void)
{
   if(m_view == NULL)
   {
      Print("Error: View not set!");
      return false;
   }

   // Reject when the panel is already busy with an order/position.
   if(HasActiveOrderOrPosition())
   {
      Print("An active order or position already exists!");
      return false;
   }

   string symbol;
   ENUM_TRADE_DIRECTION direction;
   ENUM_PANEL_ORDER_TYPE order_type;
   double lot, price, sl_price, tp_price;
   bool sl_active, tp_active;

   if(m_view == NULL)
   {
      Print("Error: View not initialized!");
      return false;
   }

   if(!(*m_view).GetPanelData(symbol, direction, order_type, lot, price, sl_price, tp_price, sl_active, tp_active))
   {
      Print("Failed to read panel data!");
      return false;
   }

   if(lot <= 0.0 || price <= 0.0)
   {
      Print("Invalid order data (lot=", lot, ", price=", price, ")");
      return false;
   }

   // Normalize prices to symbol digits before sending orders.
   double sl = 0.0, tp = 0.0;
   if(sl_active && sl_price > 0.0)
      sl = NormalizeDouble(sl_price, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
   if(tp_active && tp_price > 0.0)
      tp = NormalizeDouble(tp_price, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));

   bool result = false;
   if(order_type == PANEL_ORDER_TYPE_MARKET)
   {
      result = OpenMarketOrder(symbol, direction, lot, sl, tp, sl_active, tp_active);
   }
   else if(order_type == PANEL_ORDER_TYPE_LIMIT)
   {
      result = OpenLimitOrder(symbol, direction, lot, price, sl, tp, sl_active, tp_active);
   }
   else if(order_type == PANEL_ORDER_TYPE_STOP)
   {
      result = OpenStopOrder(symbol, direction, lot, price, sl, tp, sl_active, tp_active);
   }

   if(result)
   {

      m_order_symbol = symbol;
      m_order_direction = direction;
      m_order_type = order_type;
      m_order_lot = lot;
      m_order_price = price;
      m_order_sl = sl;
      m_order_tp = tp;
      m_order_placed = true;

      LockPanel();

      UpdateButtonsState();

      Print("Order placed successfully!");
   }
   else
   {
      Print("Order placement failed: ", m_trade.ResultRetcodeDescription());
   }

   return result;
}

bool CTradePanelOrders::OnBEClicked(void)
{

   if(!m_position_opened || m_active_position_ticket == 0)
   {
      Print("No open position for breakeven!");
      return false;
   }

   // Breakeven only makes sense for positive PnL.
   if(!IsPositionInProfit())
   {
      Print("Position not in profit; breakeven not allowed!");
      return false;
   }

   if(!PositionSelectByTicket(m_active_position_ticket))
   {
      Print("Failed to select position by ticket ", m_active_position_ticket);
      return false;
   }

   double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
   double current_sl = PositionGetDouble(POSITION_SL);
   double current_tp = PositionGetDouble(POSITION_TP);
   string symbol = PositionGetString(POSITION_SYMBOL);

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double be_price = NormalizeDouble(open_price, digits);

   if(MathAbs(current_sl - be_price) < SymbolInfoDouble(symbol, SYMBOL_POINT) * 0.5)
   {
      Print("Breakeven already set!");
      return true;
   }

   // Move SL to open price.
   if(m_trade.PositionModify(m_active_position_ticket, be_price, current_tp))
   {
      Print("Breakeven set to price ", be_price);
      return true;
   }
   else
   {
      Print("Breakeven setup failed: ", m_trade.ResultRetcodeDescription());
      return false;
   }
}

bool CTradePanelOrders::OnCLOSEClicked(void)
{
   bool result = false;

   if(m_order_placed && m_active_order_ticket > 0)
   {

      if(CheckActivePosition())
      {

         result = ClosePosition();
      }
      else
      {

         if(m_trade.OrderDelete(m_active_order_ticket))
         {
            Print("Order deleted successfully!");
            result = true;
         }
         else
         {
            Print("Order deletion failed: ", m_trade.ResultRetcodeDescription());
            return false;
         }
      }
   }

   else if(m_position_opened && m_active_position_ticket > 0)
   {
      result = ClosePosition();
   }
   else
   {
      Print("No active order or position to close!");
      return false;
   }

   if(result)
   {

      m_order_placed = false;
      m_position_opened = false;
      m_active_order_ticket = 0;
      m_active_position_ticket = 0;

      UnlockPanel();

      UpdateButtonsState();

      Print("Panel unlocked, ready for the next trade");
   }

   return result;
}

void CTradePanelOrders::OnTickUpdate(void)
{

   bool had_order = m_order_placed;
   bool had_position = m_position_opened;

   CheckActiveOrder();
   CheckActivePosition();

   if(had_order != m_order_placed || had_position != m_position_opened)
   {
      UpdateButtonsState();

      if(had_order && !m_order_placed && m_position_opened)
      {
         Print("Order triggered, position opened!");
      }

      if(had_position && !m_position_opened)
      {
         UnlockPanel();
         Print("Position closed, panel unlocked");
      }
   }

   if(m_position_opened)
   {
      bool in_profit = IsPositionInProfit();
      if(m_view != NULL)
      {
         (*m_view).UpdateBEButton(in_profit);

         if(PositionSelectByTicket(m_active_position_ticket))
         {
            string symbol = PositionGetString(POSITION_SYMBOL);
            double pnl = PositionGetDouble(POSITION_PROFIT);
            (*m_view).UpdatePnLLabel(symbol, pnl);
         }
      }
   }
   else
   {

      if(m_view != NULL)
      {
         string symbol = (m_order_symbol != "") ? m_order_symbol : Symbol();
         (*m_view).UpdatePnLLabel(symbol, 0.0);
      }
   }
}

bool CTradePanelOrders::HasActiveOrderOrPosition(void)
{
   return (m_order_placed || m_position_opened);
}

bool CTradePanelOrders::GetPanelData(string &symbol, ENUM_TRADE_DIRECTION &direction, ENUM_PANEL_ORDER_TYPE &order_type,
                                     double &lot, double &price, double &sl_price, double &tp_price,
                                     bool &sl_active, bool &tp_active)
{
   if(m_view == NULL)
      return false;

   return (*m_view).GetPanelData(symbol, direction, order_type, lot, price, sl_price, tp_price, sl_active, tp_active);
}

bool CTradePanelOrders::OpenMarketOrder(string symbol, ENUM_TRADE_DIRECTION direction, double lot,
                                        double sl_price, double tp_price, bool sl_active, bool tp_active)
{

   double price = 0.0;
   if(direction == TRADE_DIRECTION_BUY)
      price = SymbolInfoDouble(symbol, SYMBOL_ASK);
   else
      price = SymbolInfoDouble(symbol, SYMBOL_BID);

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   price = NormalizeDouble(price, digits);
   double sl = (sl_active && sl_price > 0.0) ? NormalizeDouble(sl_price, digits) : 0.0;
   double tp = (tp_active && tp_price > 0.0) ? NormalizeDouble(tp_price, digits) : 0.0;

   bool result = false;
   if(direction == TRADE_DIRECTION_BUY)
   {
      result = m_trade.Buy(lot, symbol, price, sl, tp, "Panel MT5 Market Buy");
   }
   else
   {
      result = m_trade.Sell(lot, symbol, price, sl, tp, "Panel MT5 Market Sell");
   }

   if(result)
   {

      m_active_position_ticket = m_trade.ResultOrder();
      m_position_opened = true;
      m_order_placed = false;
      Print("Market order filled, position opened. Ticket: ", m_active_position_ticket);
   }

   return result;
}

bool CTradePanelOrders::OpenLimitOrder(string symbol, ENUM_TRADE_DIRECTION direction, double lot, double price,
                                       double sl_price, double tp_price, bool sl_active, bool tp_active)
{

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double limit_price = NormalizeDouble(price, digits);
   double sl = (sl_active && sl_price > 0.0) ? NormalizeDouble(sl_price, digits) : 0.0;
   double tp = (tp_active && tp_price > 0.0) ? NormalizeDouble(tp_price, digits) : 0.0;

   bool result = false;
   if(direction == TRADE_DIRECTION_BUY)
   {
      result = m_trade.BuyLimit(lot, limit_price, symbol, sl, tp, ORDER_TIME_GTC, 0, "Panel MT5 Buy Limit");
   }
   else
   {
      result = m_trade.SellLimit(lot, limit_price, symbol, sl, tp, ORDER_TIME_GTC, 0, "Panel MT5 Sell Limit");
   }

   if(result)
   {
      m_active_order_ticket = m_trade.ResultOrder();
      m_order_placed = true;
      Print("Limit order placed. Ticket: ", m_active_order_ticket);
   }

   return result;
}

bool CTradePanelOrders::OpenStopOrder(string symbol, ENUM_TRADE_DIRECTION direction, double lot, double price,
                                      double sl_price, double tp_price, bool sl_active, bool tp_active)
{

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double stop_price = NormalizeDouble(price, digits);
   double sl = (sl_active && sl_price > 0.0) ? NormalizeDouble(sl_price, digits) : 0.0;
   double tp = (tp_active && tp_price > 0.0) ? NormalizeDouble(tp_price, digits) : 0.0;

   bool result = false;
   if(direction == TRADE_DIRECTION_BUY)
   {
      result = m_trade.BuyStop(lot, stop_price, symbol, sl, tp, ORDER_TIME_GTC, 0, "Panel MT5 Buy Stop");
   }
   else
   {
      result = m_trade.SellStop(lot, stop_price, symbol, sl, tp, ORDER_TIME_GTC, 0, "Panel MT5 Sell Stop");
   }

   if(result)
   {
      m_active_order_ticket = m_trade.ResultOrder();
      m_order_placed = true;
      Print("Stop order placed. Ticket: ", m_active_order_ticket);
   }

   return result;
}

bool CTradePanelOrders::CheckActiveOrder(void)
{
   if(m_active_order_ticket == 0)
   {

      string symbol = (m_order_symbol != "") ? m_order_symbol : Symbol();

      int total = OrdersTotal();
      for(int i = 0; i < total; i++)
      {
         ulong ticket = OrderGetTicket(i);
         if(ticket > 0)
         {
            if(OrderSelect(ticket))
            {
               if(OrderGetString(ORDER_SYMBOL) == symbol)
               {
                  long order_type = OrderGetInteger(ORDER_TYPE);

                  if(order_type == ORDER_TYPE_BUY_LIMIT || order_type == ORDER_TYPE_SELL_LIMIT ||
                     order_type == ORDER_TYPE_BUY_STOP || order_type == ORDER_TYPE_SELL_STOP)
                  {
                     long order_state = OrderGetInteger(ORDER_STATE);
                     if(order_state == ORDER_STATE_PLACED || order_state == ORDER_STATE_PARTIAL)
                     {
                        m_active_order_ticket = ticket;
                        m_order_placed = true;
                        return true;
                     }
                  }
               }
            }
         }
      }

      m_order_placed = false;
      return false;
   }

   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == m_active_order_ticket)
      {
         if(OrderSelect(ticket))
         {
            long order_state = OrderGetInteger(ORDER_STATE);
            if(order_state == ORDER_STATE_PLACED || order_state == ORDER_STATE_PARTIAL)
            {
               m_order_placed = true;
               return true;
            }
         }
         break;
      }
   }

   m_active_order_ticket = 0;
   m_order_placed = false;

   if(CheckActivePosition())
   {
      Print("Order triggered, position opened!");
   }

   return false;
}

bool CTradePanelOrders::CheckActivePosition(void)
{

   if(m_active_position_ticket > 0)
   {
      if(PositionSelectByTicket(m_active_position_ticket))
      {
         m_position_opened = true;
         return true;
      }
      else
      {

         m_active_position_ticket = 0;
         m_position_opened = false;
         return false;
      }
   }

   string symbol = (m_order_symbol != "") ? m_order_symbol : Symbol();
   if(PositionSelect(symbol))
   {
      ulong ticket = PositionGetInteger(POSITION_TICKET);
      if(ticket > 0)
      {
         m_active_position_ticket = ticket;
         m_position_opened = true;
         return true;
      }
   }

   m_position_opened = false;
   return false;
}

bool CTradePanelOrders::IsPositionInProfit(void)
{
   if(!m_position_opened || m_active_position_ticket == 0)
      return false;

   if(!PositionSelectByTicket(m_active_position_ticket))
      return false;

   double profit = PositionGetDouble(POSITION_PROFIT);
   return (profit > 0.0);
}

void CTradePanelOrders::LockPanel(void)
{
   if(m_view != NULL)
      (*m_view).LockPanel();
}

void CTradePanelOrders::UnlockPanel(void)
{
   if(m_view != NULL)
      (*m_view).UnlockPanel();
}

void CTradePanelOrders::UpdateButtonsState(void)
{
   if(m_view == NULL)
      return;

   bool has_active = HasActiveOrderOrPosition();
   (*m_view).UpdateCLOSEButton(has_active);

   if(m_position_opened)
   {
      bool in_profit = IsPositionInProfit();
      (*m_view).UpdateBEButton(in_profit);
   }
   else
   {

      (*m_view).UpdateBEButton(false);
   }
}

bool CTradePanelOrders::ClosePosition(void)
{
   if(m_active_position_ticket == 0)
   {

      string symbol = (m_order_symbol != "") ? m_order_symbol : Symbol();
      if(m_trade.PositionClose(symbol))
      {
         Print("Position closed successfully for symbol ", symbol);
         return true;
      }
      else
      {
         Print("Position close failed: ", m_trade.ResultRetcodeDescription());
         return false;
      }
   }

   if(m_trade.PositionClose(m_active_position_ticket))
   {
      Print("Position closed successfully. Ticket: ", m_active_position_ticket);
      return true;
   }
   else
   {
      Print("Position close failed: ", m_trade.ResultRetcodeDescription());
      return false;
   }
}

#endif
