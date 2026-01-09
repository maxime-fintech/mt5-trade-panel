#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\Edit.mqh>
#include <Controls\CheckBox.mqh>
#include <Controls\Panel.mqh>

#include "Panel_MT5_Controller.mqh"

#include "Panel_MT5_Types.mqh"

// Button state helpers for UI toggles.
struct SOrderButton
{
   CButton* button;
   bool     active;
};

struct STradeButton
{
   CButton* button;
   bool     active;
   color    active_color;
};

class CTradePanel : public CDialog
{
private:

   // Controller bridge for calculations and orders.
   CTradePanelController* m_controller;

   string m_last_clicked_object;
   CButton m_button_sell;
   CButton m_button_buy;
   CButton m_button_market;
   CButton m_button_limit;
   CButton m_button_stop;
   CButton m_button_trade;
   CLabel m_label_trade_line1;
   CLabel m_label_trade_line2;
   CButton m_button_be;
   CButton m_button_close_order;
   CLabel m_label_pnl;
   CLabel m_label_balance;
   CLabel m_label_symbol;
   CLabel m_label_risk_percent;
   CLabel m_label_risk_dollar;
   CLabel m_label_price;
   CLabel m_label_lot;
   CLabel m_label_stoploss;
   CLabel m_label_takeprofit;
   CLabel m_label_ticks;
   CLabel m_label_price_sl_tp;
   CLabel m_label_atr;
   CLabel m_label_synced;
   CLabel m_label_author;
   CCheckBox m_checkbox_sl;
   CCheckBox m_checkbox_tp;
   CPanel m_panel_divider1;
   CPanel m_panel_divider2;
   CEdit m_edit_risk_percent;
   CEdit m_edit_risk_dollar;
   CEdit m_edit_price;
   CEdit m_edit_lot;
   CEdit m_edit_sl_ticks;
   CEdit m_edit_tp_ticks;
   CEdit m_edit_sl_price;
   CEdit m_edit_tp_price;
   CEdit m_edit_sl_atr;
   CEdit m_edit_tp_atr;
   double m_risk_percent;
   double m_risk_dollar;
   double m_price;
   double m_lot;
   double m_sl_ticks;
   double m_tp_ticks;
   double m_sl_price;
   double m_tp_price;
   double m_sl_atr;
   double m_tp_atr;
   ENUM_TRADE_DIRECTION m_trade_direction;
   ENUM_TRADE_DIRECTION m_trade_direction_new;
   ENUM_PANEL_ORDER_TYPE m_order_type;
   ENUM_PANEL_ORDER_TYPE m_order_type_new;
   bool m_panel_locked;
   bool m_locked_sl_checked;
   bool m_locked_tp_checked;
   STradeButton ButtonTrade[2];
   SOrderButton ButtonOrder[3];

   double m_cached_atr;
   int m_cached_atr_day;
   string m_trade_button_names[2];
   ENUM_TRADE_DIRECTION m_trade_types[2];
   string m_order_button_names[3];
   ENUM_PANEL_ORDER_TYPE m_order_types[3];

   string m_line_price_name;
   string m_line_sl_name;
   string m_line_tp_name;

   bool m_need_restore_data;

   bool m_skip_data_init;

   struct SPanelData
   {
      double risk_percent;
      double risk_dollar;
      double price;
      double lot;
      double sl_ticks;
      double tp_ticks;
      double sl_price;
      double tp_price;
      double sl_atr;
      double tp_atr;
      ENUM_TRADE_DIRECTION trade_direction;
      ENUM_PANEL_ORDER_TYPE order_type;
      bool checkbox_sl_checked;
      bool checkbox_tp_checked;

      int panel_x1;
      int panel_y1;
      int panel_x2;
      int panel_y2;
   } m_saved_data;

   ENUM_TIMEFRAMES m_last_timeframe;

public:
#include "Panel_mt5_View_UI.mqh"
#include "Panel_mt5_View_Logic.mqh"
};
