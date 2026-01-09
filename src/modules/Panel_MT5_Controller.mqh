#ifndef PANEL_MT5_CONTROLLER_MQH
#define PANEL_MT5_CONTROLLER_MQH

class CTradePanel;

#include "Panel_MT5_Calcul.mqh"
#include "Panel_MT5_Order.mqh"

class CTradePanelController
{
private:
   CTradePanel* m_view;
   CTradePanelCalculations* m_calculations;
   CTradePanelOrders* m_orders;
   bool m_initialized;

public:
   // Coordinates View, calculations, and order execution.
   CTradePanelController(void)
   {
      m_view = NULL;
      m_calculations = NULL;
      m_orders = NULL;
      m_initialized = false;
   }

   ~CTradePanelController(void)
   {
      if(m_view != NULL)
      {
         delete m_view;
         m_view = NULL;
      }
      if(m_calculations != NULL)
      {
         delete m_calculations;
         m_calculations = NULL;
      }
      if(m_orders != NULL)
      {
         delete m_orders;
         m_orders = NULL;
      }
   }

   bool Initialize(CTradePanelController* controller_ptr);

   bool LoadDataBeforeCreate(void);

   void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

   void OnTick(void);

   double GetCurrentPrice(string symbol, int direction);

   int GetSymbolDigits(string symbol);

   double CalculateATR(string symbol, int period, ENUM_TIMEFRAMES timeframe);

   double CalculateLotFromRisk(string symbol, double risk_dollar, double price, double sl_price);

   double CalculateRiskDollarFromLot(string symbol, double lot, double price, double sl_price);

   double CalculateSLPriceFromATR(string symbol, double price, double sl_atr_multiplier, double atr_value, int direction);

   double CalculateTPPriceFromATR(string symbol, double price, double tp_atr_multiplier, double atr_value, int direction);

   double CalculateSLTicksFromPrice(string symbol, double price, double sl_price);

   double CalculateTPTicksFromPrice(string symbol, double price, double tp_price);

   double CalculateSLATRFromPrice(string symbol, double price, double sl_price, double atr_value, int direction);

   double CalculateTPATRFromPrice(string symbol, double price, double tp_price, double atr_value, int direction);

   double CalculateSLPriceFromTicks(string symbol, double price, double sl_ticks, int direction);

   double CalculateTPPriceFromTicks(string symbol, double price, double tp_ticks, int direction);

   void OnTradeButtonClicked(void);

   void OnBEClicked(void);

   void OnCLOSEClicked(void);

   void SetView(CTradePanel* view) { m_view = view; }

   CTradePanel* GetView(void) { return m_view; }
};

bool CTradePanelController::LoadDataBeforeCreate(void)
{
   if(m_view == NULL)
      return false;

   return (*m_view).LoadFromGlobalVariables();
}

bool CTradePanelController::Initialize(CTradePanelController* controller_ptr)
{
   // Create components in dependency order: calculations, orders, view.
   m_calculations = new CTradePanelCalculations();
   if(m_calculations == NULL)
   {
      Print("Failed to create calculations component!");
      return false;
   }

   m_orders = new CTradePanelOrders();
   if(m_orders == NULL)
   {
      Print("Failed to create orders component!");
      return false;
   }

   m_view = new CTradePanel();
   if(m_view == NULL)
   {
      Print("Failed to create view component!");
      return false;
   }

   SetView(m_view);

   if(controller_ptr != NULL)
      (*m_view).SetController(controller_ptr);
   else
   {
      Print("Error: controller_ptr is NULL!");
      return false;
   }

   (*m_orders).Initialize(m_view, controller_ptr);

   // Load persisted values before UI creation to avoid flicker.
   bool data_loaded = LoadDataBeforeCreate();
   if(data_loaded)
      Print("Panel data loaded from Global Variables before UI creation");
   else
      Print("Panel data not found, using defaults");

   if(!(*m_view).CreatePanel())
   {
      Print("Failed to create panel!");
      return false;
   }

   m_initialized = true;
   return true;
}

void CTradePanelController::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(!m_initialized || m_view == NULL)
      return;

   (*m_view).OnEvent(id, lparam, dparam, sparam);

   // Force redraw for hover states.
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      ChartRedraw(0);
   }
}

void CTradePanelController::OnTick(void)
{
   if(!m_initialized || m_view == NULL)
      return;

   if(m_orders != NULL)
      (*m_orders).OnTickUpdate();

   (*m_view).OnTickUpdate();
}

double CTradePanelController::GetCurrentPrice(string symbol, int direction)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::GetCurrentPrice(symbol, direction);
}

int CTradePanelController::GetSymbolDigits(string symbol)
{
   if(m_calculations == NULL)
      return 2;
   return CTradePanelCalculations::GetSymbolDigits(symbol);
}

double CTradePanelController::CalculateATR(string symbol, int period, ENUM_TIMEFRAMES timeframe)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::CalculateATR(symbol, period, timeframe);
}

double CTradePanelController::CalculateLotFromRisk(string symbol, double risk_dollar, double price, double sl_price)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::CalculateLotFromRisk(symbol, risk_dollar, price, sl_price);
}

double CTradePanelController::CalculateRiskDollarFromLot(string symbol, double lot, double price, double sl_price)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::CalculateRiskFromLot(symbol, lot, price, sl_price);
}

double CTradePanelController::CalculateSLPriceFromATR(string symbol, double price, double sl_atr_multiplier, double atr_value, int direction)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::CalculateSLPriceFromATR(symbol, price, sl_atr_multiplier, atr_value, direction);
}

double CTradePanelController::CalculateTPPriceFromATR(string symbol, double price, double tp_atr_multiplier, double atr_value, int direction)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::CalculateTPPriceFromATR(symbol, price, tp_atr_multiplier, atr_value, direction);
}

double CTradePanelController::CalculateSLTicksFromPrice(string symbol, double price, double sl_price)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::CalculateSLTicksFromPrice(symbol, price, sl_price);
}

double CTradePanelController::CalculateTPTicksFromPrice(string symbol, double price, double tp_price)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::CalculateTPTicksFromPrice(symbol, price, tp_price);
}

double CTradePanelController::CalculateSLATRFromPrice(string symbol, double price, double sl_price, double atr_value, int direction)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::CalculateSLATRFromPrice(symbol, price, sl_price, atr_value, direction);
}

double CTradePanelController::CalculateTPATRFromPrice(string symbol, double price, double tp_price, double atr_value, int direction)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::CalculateTPATRFromPrice(symbol, price, tp_price, atr_value, direction);
}

double CTradePanelController::CalculateSLPriceFromTicks(string symbol, double price, double sl_ticks, int direction)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::CalculateSLPriceFromTicks(symbol, price, sl_ticks, direction);
}

double CTradePanelController::CalculateTPPriceFromTicks(string symbol, double price, double tp_ticks, int direction)
{
   if(m_calculations == NULL)
      return 0.0;
   return CTradePanelCalculations::CalculateTPPriceFromTicks(symbol, price, tp_ticks, direction);
}

void CTradePanelController::OnTradeButtonClicked(void)
{
   if(m_orders != NULL)
   {
      if((*m_orders).OnTradeButtonClicked())
         Print("Order placed successfully via Orders module");
      else
         Print("Order placement failed");
   }
   else
   {
      Print("Error: Orders module not initialized!");
   }
}

void CTradePanelController::OnBEClicked(void)
{
   if(m_orders != NULL)
   {
      if((*m_orders).OnBEClicked())
         Print("Breakeven set successfully");
      else
         Print("Breakeven setup failed");
   }
   else
   {
      Print("Error: Orders module not initialized!");
   }
}

void CTradePanelController::OnCLOSEClicked(void)
{
   if(m_orders != NULL)
   {
      if((*m_orders).OnCLOSEClicked())
         Print("Order/position closed successfully");
      else
         Print("Order/position close failed");
   }
   else
   {
      Print("Error: Orders module not initialized!");
   }
}

#endif
