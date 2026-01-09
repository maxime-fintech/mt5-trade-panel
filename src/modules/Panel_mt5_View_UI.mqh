CTradePanel(void)
   {
      m_controller = NULL;

      m_line_price_name = "TraderPanel_Line_Price";
      m_line_sl_name = "TraderPanel_Line_SL";
      m_line_tp_name = "TraderPanel_Line_TP";

      m_need_restore_data = false;
      m_skip_data_init = false;
      m_panel_locked = false;
      m_locked_sl_checked = false;
      m_locked_tp_checked = false;

      m_last_timeframe = (ENUM_TIMEFRAMES)Period();
   }

   ~CTradePanel(void)
   {
      DeleteLines();
   }

   void SetController(CTradePanelController* controller)
   {
      m_controller = controller;
   }

bool CreatePanel()
{
      // Restore panel position if available; otherwise use defaults.
      int x1 = 15, y1 = 30, x2 = 275, y2 = 570; 
      if(m_saved_data.panel_x1 > 0 && m_saved_data.panel_y1 > 0 &&
         m_saved_data.panel_x2 > m_saved_data.panel_x1 &&
         m_saved_data.panel_y2 > m_saved_data.panel_y1)
      {

         x1 = m_saved_data.panel_x1;
         y1 = m_saved_data.panel_y1;
         x2 = m_saved_data.panel_x2;
         y2 = m_saved_data.panel_y2;
      }

      if(!Create(0, "TraderPanel", 0, x1, y1, x2, y2))
         return false;

      // Static header text for symbol and spread.
      Caption("Trade Panel");

      string symbol = _Symbol;
      long spread_points = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
      string symbol_text = symbol + " | Spread: " + IntegerToString(spread_points);

      if(!m_label_symbol.Create(0, "TraderPanelLabelSymbol", 0, 10, 5, 240, 25))
         return false;

      if(!m_label_symbol.Text(symbol_text))
         return false;

      if(!Add(m_label_symbol))
         return false;

      if(!m_button_sell.Create(0, "TraderPanelButtonSell", 0, 10, 30, 120, 60))
         return false;

      if(!m_button_sell.Text("Sell"))
         return false;

      if(!Add(m_button_sell))
         return false;

      if(!m_button_buy.Create(0, "TraderPanelButtonBuy", 0, 130, 30, 240, 60))
         return false;

      if(!m_button_buy.Text("Buy"))
         return false;

      if(!Add(m_button_buy))
         return false;

      if(!m_button_market.Create(0, "TraderPanelButtonMarket", 0, 10, 70, 80, 100))
         return false;
      if(!m_button_market.Text("Market"))
         return false;
      if(!Add(m_button_market))
         return false;

      if(!m_button_limit.Create(0, "TraderPanelButtonLimit", 0, 90, 70, 160, 100))
         return false;
      if(!m_button_limit.Text("Limit"))
         return false;
      if(!Add(m_button_limit))
         return false;

      if(!m_button_stop.Create(0, "TraderPanelButtonStop", 0, 170, 70, 240, 100))
         return false;
      if(!m_button_stop.Text("Stop"))
         return false;
      if(!Add(m_button_stop))
         return false;

      if(!m_label_price.Create(0, "TraderPanelLabelPrice", 0, 10, 110, 120, 130))
         return false;
      if(!m_label_price.Text("Price"))
         return false;
      if(!Add(m_label_price))
         return false;

      if(!m_edit_price.Create(0, "TraderPanelEditPrice", 0, 10, 130, 120, 150))
         return false;
      if(!m_edit_price.Text("0"))
         return false;
      if(!Add(m_edit_price))
         return false;

      if(!m_label_lot.Create(0, "TraderPanelLabelLot", 0, 130, 110, 240, 130))
         return false;
      if(!m_label_lot.Text("Lot"))
         return false;
      if(!Add(m_label_lot))
         return false;

      if(!m_edit_lot.Create(0, "TraderPanelEditLot", 0, 130, 130, 240, 150))
         return false;
      if(!m_edit_lot.Text("0"))
         return false;
      if(!Add(m_edit_lot))
         return false;

      if(!m_panel_divider1.Create(0, "TraderPanelDivider1", 0, 0, 156, 250, 159))
         return false;
      if(!m_panel_divider1.ColorBackground(clrLightGray))
         return false;
      if(!m_panel_divider1.ColorBorder(clrSilver))
         return false;
      if(!Add(m_panel_divider1))
         return false;

      if(!m_label_risk_percent.Create(0, "TraderPanelLabelRiskPercent", 0, 10, 162, 120, 182))
         return false;
      if(!m_label_risk_percent.Text("Risk, %"))
         return false;
      if(!Add(m_label_risk_percent))
         return false;

      if(!m_edit_risk_percent.Create(0, "TraderPanelEditRiskPercent", 0, 10, 182, 120, 202))
         return false;
      if(!m_edit_risk_percent.Text("0"))
         return false;
      if(!Add(m_edit_risk_percent))
         return false;

      if(!m_label_risk_dollar.Create(0, "TraderPanelLabelRiskDollar", 0, 130, 162, 240, 182))
         return false;
      if(!m_label_risk_dollar.Text("Risk, $"))
         return false;
      if(!Add(m_label_risk_dollar))
         return false;

      if(!m_edit_risk_dollar.Create(0, "TraderPanelEditRiskDollar", 0, 130, 182, 240, 202))
         return false;
      if(!m_edit_risk_dollar.Text("0"))
         return false;
      if(!Add(m_edit_risk_dollar))
         return false;

      if(!m_checkbox_sl.Create(0, "TraderPanelCheckBoxSL", 0, 10, 210, 30, 230))
         return false;
      if(!m_checkbox_sl.Checked(false))
         return false;
      if(!Add(m_checkbox_sl))
         return false;

      if(!m_label_stoploss.Create(0, "TraderPanelLabelStoploss", 0, 35, 210, 100, 230))
         return false;
      if(!m_label_stoploss.Text("Stoploss"))
         return false;
      if(!Add(m_label_stoploss))
         return false;

      if(!m_label_takeprofit.Create(0, "TraderPanelLabelTakeProfit", 0, 140, 210, 200, 230))
         return false;
      if(!m_label_takeprofit.Text("TakeProfit"))
         return false;
      if(!Add(m_label_takeprofit))
         return false;

      if(!m_checkbox_tp.Create(0, "TraderPanelCheckBoxTP", 0, 220, 210, 240, 230))
         return false;
      if(!m_checkbox_tp.Checked(false))
         return false;
      if(!Add(m_checkbox_tp))
         return false;

      if(!m_edit_sl_ticks.Create(0, "TraderPanelEditSLTicks", 0, 10, 240, 80, 260))
         return false;
      if(!m_edit_sl_ticks.Text("0"))
         return false;
      if(!Add(m_edit_sl_ticks))
         return false;

      if(!m_label_ticks.Create(0, "TraderPanelLabelTicks", 0, 105, 240, 130, 260))
         return false;
      if(!m_label_ticks.Text("Ticks"))
         return false;
      if(!Add(m_label_ticks))
         return false;

      if(!m_edit_tp_ticks.Create(0, "TraderPanelEditTPTicks", 0, 170, 240, 240, 260))
         return false;
      if(!m_edit_tp_ticks.Text("0"))
         return false;
      if(!Add(m_edit_tp_ticks))
         return false;

      if(!m_edit_sl_price.Create(0, "TraderPanelEditSLPrice", 0, 10, 270, 80, 290))
         return false;
      if(!m_edit_sl_price.Text("0"))
         return false;
      if(!Add(m_edit_sl_price))
         return false;

      if(!m_label_price_sl_tp.Create(0, "TraderPanelLabelPriceSLTP", 0, 105, 270, 130, 290))
         return false;
      if(!m_label_price_sl_tp.Text("Price"))
         return false;
      if(!Add(m_label_price_sl_tp))
         return false;

      if(!m_edit_tp_price.Create(0, "TraderPanelEditTPPrice", 0, 170, 270, 240, 290))
         return false;
      if(!m_edit_tp_price.Text("0"))
         return false;
      if(!Add(m_edit_tp_price))
         return false;

      if(!m_edit_sl_atr.Create(0, "TraderPanelEditSLATR", 0, 10, 300, 80, 320))
         return false;
      if(!m_edit_sl_atr.Text("0"))
         return false;
      if(!Add(m_edit_sl_atr))
         return false;

      if(!m_label_atr.Create(0, "TraderPanelLabelATR", 0, 95, 300, 130, 320))
         return false;
      if(!m_label_atr.Text("x ATR x"))
         return false;
      if(!Add(m_label_atr))
         return false;

      if(!m_edit_tp_atr.Create(0, "TraderPanelEditTPATR", 0, 170, 300, 240, 320))
         return false;
      if(!m_edit_tp_atr.Text("0"))
         return false;
      if(!Add(m_edit_tp_atr))
         return false;

      if(!m_label_synced.Create(0, "TraderPanelLabelSynced", 0, 120, 330, 240, 345))
         return false;
      if(!m_label_synced.Text("Edit any field — synced"))
         return false;
      if(!m_label_synced.Color(clrBlack))
         return false;
      if(!m_label_synced.ColorBackground(clrNONE))
         return false;

      ObjectSetInteger(0, "TraderPanelLabelSynced", OBJPROP_ANCHOR, ANCHOR_CENTER);

      ObjectSetInteger(0, "TraderPanelLabelSynced", OBJPROP_FONTSIZE, 8);
      if(!Add(m_label_synced))
         return false;

      if(!m_panel_divider2.Create(0, "TraderPanelDivider2", 0, 0, 345, 250, 348))
         return false;
      if(!m_panel_divider2.ColorBackground(clrLightGray))
         return false;
      if(!m_panel_divider2.ColorBorder(clrSilver))
         return false;
      if(!Add(m_panel_divider2))
         return false;

      if(!m_button_trade.Create(0, "TraderPanelButtonTrade", 0, 10, 355, 240, 415))
         return false;
      if(!m_button_trade.Text(""))
         return false;
      if(!Add(m_button_trade))
         return false;

      if(!m_label_trade_line1.Create(0, "TraderPanelLabelTradeLine1", 0, 125, 370, 240, 390))
         return false;
      if(!m_label_trade_line1.Color(clrWhite))
         return false;
      if(!m_label_trade_line1.ColorBackground(clrNONE))
         return false;

      ObjectSetInteger(0, "TraderPanelLabelTradeLine1", OBJPROP_ANCHOR, ANCHOR_CENTER);
      if(!Add(m_label_trade_line1))
         return false;

      if(!m_label_trade_line2.Create(0, "TraderPanelLabelTradeLine2", 0, 125, 395, 240, 415))
         return false;
      if(!m_label_trade_line2.Color(clrWhite))
         return false;
      if(!m_label_trade_line2.ColorBackground(clrNONE))
         return false;

      ObjectSetInteger(0, "TraderPanelLabelTradeLine2", OBJPROP_ANCHOR, ANCHOR_CENTER);
      if(!Add(m_label_trade_line2))
         return false;

      if(!m_button_be.Create(0, "TraderPanelButtonBE", 0, 10, 425, 120, 455))
         return false;
      if(!m_button_be.Text("BE"))
         return false;
      if(!m_button_be.ColorBackground(clrGray))
         return false;
      if(!m_button_be.Color(clrDarkGray))
         return false;

      ObjectSetInteger(0, "TraderPanelButtonBE", OBJPROP_STATE, false);
      if(!Add(m_button_be))
         return false;

      if(!m_button_close_order.Create(0, "TraderPanelButtonCloseOrder", 0, 130, 425, 240, 455))
         return false;
      if(!m_button_close_order.Text("CLOSE"))
         return false;
      if(!m_button_close_order.ColorBackground(clrGray))
         return false;
      if(!m_button_close_order.Color(clrDarkGray))
         return false;

      ObjectSetInteger(0, "TraderPanelButtonCloseOrder", OBJPROP_STATE, false);
      if(!Add(m_button_close_order))
         return false;

      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      string balance_text = "Balance: " + DoubleToString(balance, 2) + " | PnL: 0.00";

      if(!m_label_balance.Create(0, "TraderPanelLabelPnL", 0, 10, 470, 240, 485))
         return false;
      if(!m_label_balance.Text(balance_text))
         return false;
      if(!m_label_balance.Color(clrBlack))
         return false;
      if(!m_label_balance.ColorBackground(clrNONE))
         return false;

      ObjectSetInteger(0, "TraderPanelLabelPnL", OBJPROP_ANCHOR, ANCHOR_LEFT);
      if(!Add(m_label_balance))
         return false;

      if(!m_label_author.Create(0, "TraderPanelLabelAuthor", 0, 120, 495, 240, 505))
         return false;
      if(!m_label_author.Text("maxime-fintech (GitHub)"))
         return false;
      if(!m_label_author.Color(clrBlack))
         return false;
      if(!m_label_author.ColorBackground(clrNONE))
         return false;

      ObjectSetInteger(0, "TraderPanelLabelAuthor", OBJPROP_ANCHOR, ANCHOR_LEFT);

      ObjectSetInteger(0, "TraderPanelLabelAuthor", OBJPROP_FONTSIZE, 8);
      if(!Add(m_label_author))
         return false;

      InitializeButtons();

      if(!m_skip_data_init)
      {

         bool data_loaded = false;
         if(m_saved_data.risk_percent > 0.0 ||
            m_saved_data.price > 0.0 ||
            m_saved_data.lot > 0.0)
         {

            RestorePanelData();
            data_loaded = true;
         }

         if(!data_loaded)
         {

            m_risk_percent = 0.0;
            m_risk_dollar = 0.0;
            m_lot = 0.0;
            m_sl_ticks = 0.0;
            m_tp_ticks = 0.0;
            m_sl_price = 0.0;
            m_tp_price = 0.0;
            m_sl_atr = 0.0;
            m_tp_atr = 0.0;

            string symbol = Symbol();
            if(m_controller != NULL)
               m_price = (*m_controller).GetCurrentPrice(symbol, (int)m_trade_direction);
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
            string price_text = DoubleToString(m_price, digits);
            if(!m_edit_price.Text(price_text))
               return false;

            balance = AccountInfoDouble(ACCOUNT_BALANCE);
            m_risk_percent = 1.0;
            m_risk_dollar = m_risk_percent * balance / 100.0;
            m_lot = 0.1;

            m_cached_atr = 0.0;
            m_cached_atr_day = 0;
            double atr = GetATR();

            m_sl_atr = 0.1;
            if(m_controller != NULL)
            {
               m_sl_price = (*m_controller).CalculateSLPriceFromATR(symbol, m_price, m_sl_atr, atr, (int)m_trade_direction);
               m_sl_ticks = (*m_controller).CalculateSLTicksFromPrice(symbol, m_price, m_sl_price);

               m_tp_atr = 0.3;
               m_tp_price = (*m_controller).CalculateTPPriceFromATR(symbol, m_price, m_tp_atr, atr, (int)m_trade_direction);
               m_tp_ticks = (*m_controller).CalculateTPTicksFromPrice(symbol, m_price, m_tp_price);

            m_lot = NormalizeLotValue((*m_controller).CalculateLotFromRisk(symbol, m_risk_dollar, m_price, m_sl_price));
            }

            UpdateRiskFields();
            UpdateLotField();
            UpdateSLFields();
            UpdateTPFields();

            OnClickCheckBoxSL();
            OnClickCheckBoxTP();

            UpdatePriceLine();
         }
      }
      else
      {

         RestorePanelData();
         m_skip_data_init = false;
      }

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);

      return true;
   }
