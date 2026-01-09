virtual bool OnEvent(const int id,
                        const long &lparam,
                        const double &dparam,
                        const string &sparam)
   {
      if(m_panel_locked && IsCheckboxEvent(id, sparam))
         return HandleLockedCheckbox();

      if(id == (CHARTEVENT_CUSTOM + ON_CHANGE) && IsCheckboxEvent(id, sparam))
         return HandleCheckboxChange(sparam);

      if(id == CHARTEVENT_OBJECT_CLICK)
         return HandleObjectClick(id, lparam, dparam, sparam);

      if(id == CHARTEVENT_OBJECT_ENDEDIT)
         return HandleEndEdit(id, lparam, dparam, sparam);

      if(id == CHARTEVENT_CHART_CHANGE)
         return HandleChartChange(id, lparam, dparam, sparam);

      return CDialog::OnEvent(id, lparam, dparam, sparam);
   }

protected:
   bool IsCheckboxEvent(const int id, const string &name) const
   {
      if(id != CHARTEVENT_OBJECT_CLICK &&
         id != (CHARTEVENT_CUSTOM + ON_CHANGE))
         return false;

      return (StringFind(name, "TraderPanelCheckBoxSL") >= 0 ||
              StringFind(name, "TraderPanelCheckBoxTP") >= 0);
   }

   bool HandleLockedCheckbox(void)
   {
      m_checkbox_sl.Checked(m_locked_sl_checked);
      m_checkbox_tp.Checked(m_locked_tp_checked);
      return true;
   }

   bool HandleCheckboxChange(const string &name)
   {
      if(StringFind(name, "TraderPanelCheckBoxSL") >= 0)
      {
         OnClickCheckBoxSL();
         return true;
      }

      if(StringFind(name, "TraderPanelCheckBoxTP") >= 0)
      {
         OnClickCheckBoxTP();
         return true;
      }

      return true;
   }

   bool HandleObjectClick(const int id, const long &lparam, const double &dparam, const string &sparam)

   {
      m_last_clicked_object = sparam;

      if(m_panel_locked)
      {

         if(StringFind(m_last_clicked_object, "TraderPanelButtonCloseOrder") >= 0)
         {

         }
         else if(StringFind(m_last_clicked_object, "TraderPanelButtonBE") >= 0)
         {

            if(ObjectGetInteger(0, "TraderPanelButtonBE", OBJPROP_STATE) == 0)
            {

               return true;
            }

         }
         else
         {

            return true;
         }
      }

      for(int i = 0; i < 2; i++)
      {
         if(StringFind(m_last_clicked_object, m_trade_button_names[i]) >= 0)
         {
            if(m_panel_locked) return true;
            m_trade_direction_new = m_trade_types[i];
            OnClickTradeDirection();
            return true;
         }
      }

      for(int i = 0; i < 3; i++)
      {
         if(StringFind(m_last_clicked_object, m_order_button_names[i]) >= 0)
         {
            if(m_panel_locked) return true;
            m_order_type_new = m_order_types[i];
            OnClickButtonOrderType();
            return true;
         }
      }

      if(StringFind(m_last_clicked_object, "TraderPanelCheckBoxSL") >= 0)
      {
         if(m_panel_locked) return true;

         OnClickCheckBoxSL();
         return true;
      }

      if(StringFind(m_last_clicked_object, "TraderPanelCheckBoxTP") >= 0)
      {
         if(m_panel_locked) return true;

         OnClickCheckBoxTP();
         return true;
      }

      if(StringFind(m_last_clicked_object, "TraderPanelButtonTrade") >= 0)
      {
         if(m_panel_locked) return true;

         if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         {
            if(!CheckTradeButtonActive())
            {
               Print("Trade button inactive: conditions not met!");
               return true;
            }
         }

         if(m_controller != NULL)
            (*m_controller).OnTradeButtonClicked();
         else
            Print("Controller not set!");
         return true;
      }

      if(StringFind(m_last_clicked_object, "TraderPanelButtonBE") >= 0)
      {
         if(m_controller != NULL)
            (*m_controller).OnBEClicked();
         else
            Print("Controller not set!");
         return true;
      }

      if(StringFind(m_last_clicked_object, "TraderPanelButtonCloseOrder") >= 0)
      {
         if(m_controller != NULL)
            (*m_controller).OnCLOSEClicked();
         else
            Print("Controller not set!");
         return true;
      }

      if(StringFind(m_last_clicked_object, "TraderPanel") == 0 && StringFind(m_last_clicked_object, "Client") >= 0)
      {

         return true;
      }

      if(StringFind(m_last_clicked_object, "TraderPanel") == 0)
      {
         return true;
      }

      return CDialog::OnEvent(id, lparam, dparam, sparam);
   }

   bool HandleEndEdit(const int id, const long &lparam, const double &dparam, const string &sparam)
   {

      if(m_panel_locked)
         return true;

      if(StringFind(sparam, "TraderPanelEditRiskPercent") >= 0)
      {
         string value = m_edit_risk_percent.Text();
         m_risk_percent = StringToDouble(value);
         Print("Risk % changed: ", m_risk_percent);
         RecalculateOnRiskPercentChange();
         return true;
      }

      if(StringFind(sparam, "TraderPanelEditRiskDollar") >= 0)
      {
         string value = m_edit_risk_dollar.Text();
         m_risk_dollar = StringToDouble(value);
         Print("Risk $ changed: ", m_risk_dollar);
         RecalculateOnRiskDollarChange();
         return true;
      }

      if(StringFind(sparam, "TraderPanelEditPrice") >= 0)
      {
         string value = m_edit_price.Text();
         m_price = StringToDouble(value);
         Print("Price changed: ", m_price);
         RecalculateOnPriceChange();
         return true;
      }

      if(StringFind(sparam, "TraderPanelEditLot") >= 0)
      {
         string value = m_edit_lot.Text();
         m_lot = StringToDouble(value);
         Print("Lot changed: ", m_lot);
         RecalculateOnLotChange();
         return true;
      }

      if(StringFind(sparam, "TraderPanelEditSLTicks") >= 0)
      {
         string value = m_edit_sl_ticks.Text();
         m_sl_ticks = StringToDouble(value);
         Print("SL ticks changed: ", m_sl_ticks);
         RecalculateOnSLTicksChange();
         return true;
      }

      if(StringFind(sparam, "TraderPanelEditTPTicks") >= 0)
      {
         string value = m_edit_tp_ticks.Text();
         m_tp_ticks = StringToDouble(value);
         Print("TP ticks changed: ", m_tp_ticks);
         RecalculateOnTPTicksChange();
         return true;
      }

      if(StringFind(sparam, "TraderPanelEditSLPrice") >= 0)
      {
         string value = m_edit_sl_price.Text();
         m_sl_price = StringToDouble(value);
         Print("SL price changed: ", m_sl_price);
         RecalculateOnSLPriceChange();
         return true;
      }

      if(StringFind(sparam, "TraderPanelEditTPPrice") >= 0)
      {
         string value = m_edit_tp_price.Text();
         m_tp_price = StringToDouble(value);
         Print("TP price changed: ", m_tp_price);
         RecalculateOnTPPriceChange();
         return true;
      }

      if(StringFind(sparam, "TraderPanelEditSLATR") >= 0)
      {
         string value = m_edit_sl_atr.Text();
         m_sl_atr = StringToDouble(value);
         Print("SL ATR changed: ", m_sl_atr);
         RecalculateOnSLATRChange();
         return true;
      }

      if(StringFind(sparam, "TraderPanelEditTPATR") >= 0)
      {
         string value = m_edit_tp_atr.Text();
         m_tp_atr = StringToDouble(value);
         Print("TP ATR changed: ", m_tp_atr);
         RecalculateOnTPATRChange();
         return true;
      }

      return CDialog::OnEvent(id, lparam, dparam, sparam);
   }

   bool HandleChartChange(const int id, const long &lparam, const double &dparam, const string &sparam)
   {

      ENUM_TIMEFRAMES current_timeframe = (ENUM_TIMEFRAMES)Period();

      if(current_timeframe != m_last_timeframe)
      {

         RebuildUI();
         m_last_timeframe = current_timeframe;
      }

      bool result = CDialog::OnEvent(id, lparam, dparam, sparam);

      ChartRedraw(0);

      return result;
   }

public:

   void OnTickUpdate(void)
   {
      if(m_controller == NULL)
         return;

      string symbol = Symbol();

      if(m_order_type == PANEL_ORDER_TYPE_MARKET && !m_panel_locked)
      {

         double new_price = (m_controller != NULL) ? (*m_controller).GetCurrentPrice(symbol, (int)m_trade_direction) : 0.0;
         if(new_price != m_price)
         {
            m_price = new_price;

            int digits = (m_controller != NULL) ? (*m_controller).GetSymbolDigits(symbol) : 2;
            string price_text = DoubleToString(m_price, digits);
            m_edit_price.Text(price_text);

            RecalculateOnPriceChange();
         }
         else
         {

            UpdatePriceLine();
         }
      }

      else if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
      {

         bool is_button_active = CheckTradeButtonActive();

         UpdateTradeButton(is_button_active);
      }
      else
      {

         UpdateTradeButton(true);
      }
   }

   bool CheckTradeButtonActive(void)
   {
      if(m_controller == NULL)
         return true;

      string symbol = Symbol();
      double current_price_bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double current_price_ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

      if(m_order_type == PANEL_ORDER_TYPE_LIMIT)
      {
         if(m_trade_direction == TRADE_DIRECTION_BUY)
         {

            return (current_price_bid > m_price);
         }
         else
         {

            return (current_price_ask < m_price);
         }
      }

      else if(m_order_type == PANEL_ORDER_TYPE_STOP)
      {
         if(m_trade_direction == TRADE_DIRECTION_BUY)
         {

            return (current_price_bid < m_price);
         }
         else
         {

            return (current_price_ask > m_price);
         }
      }

      return true;
   }

   void UpdatePriceLine(void)
   {

      if(m_panel_locked)
         return;

      if(m_price <= 0.0)
      {

         ObjectDelete(0, m_line_price_name);
         ChartRedraw(0);
         return;
      }

      if(ObjectFind(0, m_line_price_name) < 0)
      {

         ObjectCreate(0, m_line_price_name, OBJ_HLINE, 0, 0, m_price);
      }
      else
      {

         ObjectSetDouble(0, m_line_price_name, OBJPROP_PRICE, m_price);
      }

      ObjectSetInteger(0, m_line_price_name, OBJPROP_COLOR, clrBlue);
      ObjectSetInteger(0, m_line_price_name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, m_line_price_name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_line_price_name, OBJPROP_BACK, true);
      ObjectSetInteger(0, m_line_price_name, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, m_line_price_name, OBJPROP_TEXT, "Price");

      ChartRedraw(0);
   }

   void UpdateSLLine(void)
   {

      if(m_panel_locked)
         return;

      if(!m_checkbox_sl.Checked() || m_sl_price <= 0.0)
      {

         ObjectDelete(0, m_line_sl_name);
         ChartRedraw(0);
         return;
      }

      if(ObjectFind(0, m_line_sl_name) < 0)
      {

         ObjectCreate(0, m_line_sl_name, OBJ_HLINE, 0, 0, m_sl_price);
      }
      else
      {

         ObjectSetDouble(0, m_line_sl_name, OBJPROP_PRICE, m_sl_price);
      }

      ObjectSetInteger(0, m_line_sl_name, OBJPROP_COLOR, clrRed);
      ObjectSetInteger(0, m_line_sl_name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, m_line_sl_name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_line_sl_name, OBJPROP_BACK, true);
      ObjectSetInteger(0, m_line_sl_name, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, m_line_sl_name, OBJPROP_TEXT, "Stoploss");

      ChartRedraw(0);
   }

   void UpdateTPLine(void)
   {

      if(m_panel_locked)
         return;

      if(!m_checkbox_tp.Checked() || m_tp_price <= 0.0)
      {

         ObjectDelete(0, m_line_tp_name);
         ChartRedraw(0);
         return;
      }

      if(ObjectFind(0, m_line_tp_name) < 0)
      {

         ObjectCreate(0, m_line_tp_name, OBJ_HLINE, 0, 0, m_tp_price);
      }
      else
      {

         ObjectSetDouble(0, m_line_tp_name, OBJPROP_PRICE, m_tp_price);
      }

      ObjectSetInteger(0, m_line_tp_name, OBJPROP_COLOR, clrGreen);
      ObjectSetInteger(0, m_line_tp_name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, m_line_tp_name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_line_tp_name, OBJPROP_BACK, true);
      ObjectSetInteger(0, m_line_tp_name, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, m_line_tp_name, OBJPROP_TEXT, "TakeProfit");

      ChartRedraw(0);
   }

   void DeleteLines(void)
   {
      ObjectDelete(0, m_line_price_name);
      ObjectDelete(0, m_line_sl_name);
      ObjectDelete(0, m_line_tp_name);
      ChartRedraw(0);
   }

   void SyncDataFromUI(void)
   {

      string value;

      value = m_edit_risk_percent.Text();
      if(value != "")
         m_risk_percent = StringToDouble(value);

      value = m_edit_risk_dollar.Text();
      if(value != "")
         m_risk_dollar = StringToDouble(value);

      value = m_edit_price.Text();
      if(value != "")
         m_price = StringToDouble(value);

      value = m_edit_lot.Text();
      if(value != "")
         m_lot = StringToDouble(value);

      value = m_edit_sl_ticks.Text();
      if(value != "")
         m_sl_ticks = StringToDouble(value);

      value = m_edit_tp_ticks.Text();
      if(value != "")
         m_tp_ticks = StringToDouble(value);

      value = m_edit_sl_price.Text();
      if(value != "")
         m_sl_price = StringToDouble(value);

      value = m_edit_tp_price.Text();
      if(value != "")
         m_tp_price = StringToDouble(value);

      value = m_edit_sl_atr.Text();
      if(value != "")
         m_sl_atr = StringToDouble(value);

      value = m_edit_tp_atr.Text();
      if(value != "")
         m_tp_atr = StringToDouble(value);
   }

   void SavePanelData(void)
   {

      SyncDataFromUI();

      m_saved_data.risk_percent = m_risk_percent;
      m_saved_data.risk_dollar = m_risk_dollar;
      m_saved_data.price = m_price;
      m_saved_data.lot = m_lot;
      m_saved_data.sl_ticks = m_sl_ticks;
      m_saved_data.tp_ticks = m_tp_ticks;
      m_saved_data.sl_price = m_sl_price;
      m_saved_data.tp_price = m_tp_price;
      m_saved_data.sl_atr = m_sl_atr;
      m_saved_data.tp_atr = m_tp_atr;
      m_saved_data.trade_direction = m_trade_direction;
      m_saved_data.order_type = m_order_type;
      m_saved_data.checkbox_sl_checked = m_checkbox_sl.Checked();
      m_saved_data.checkbox_tp_checked = m_checkbox_tp.Checked();

      m_saved_data.panel_x1 = Left();
      m_saved_data.panel_y1 = Top();
      m_saved_data.panel_x2 = Right();
      m_saved_data.panel_y2 = Bottom();
   }

   void RestorePanelData(void)
   {

      m_risk_percent = m_saved_data.risk_percent;
      m_risk_dollar = m_saved_data.risk_dollar;
      m_price = m_saved_data.price;
      m_lot = NormalizeLotValue(m_saved_data.lot);
      m_sl_ticks = m_saved_data.sl_ticks;
      m_tp_ticks = m_saved_data.tp_ticks;
      m_sl_price = m_saved_data.sl_price;
      m_tp_price = m_saved_data.tp_price;
      m_sl_atr = m_saved_data.sl_atr;
      m_tp_atr = m_saved_data.tp_atr;
      m_trade_direction = m_saved_data.trade_direction;
      m_trade_direction_new = m_saved_data.trade_direction;
      m_order_type = m_saved_data.order_type;
      m_order_type_new = m_saved_data.order_type;

      m_checkbox_sl.Checked(m_saved_data.checkbox_sl_checked);
      m_checkbox_tp.Checked(m_saved_data.checkbox_tp_checked);

      string symbol = Symbol();
      int digits = (m_controller != NULL) ? (*m_controller).GetSymbolDigits(symbol) : 2;
      string price_text = DoubleToString(m_price, digits);
      m_edit_price.Text(price_text);

      if(m_trade_button_names[0] == "")
      {
         m_trade_button_names[0] = "TraderPanelButtonSell";
         m_trade_button_names[1] = "TraderPanelButtonBuy";
         m_trade_types[0] = TRADE_DIRECTION_SELL;
         m_trade_types[1] = TRADE_DIRECTION_BUY;
      }
      if(ButtonTrade[0].button == NULL)
      {
         ButtonTrade[0].button = GetPointer(m_button_sell);
         ButtonTrade[0].active_color = clrRed;
         ButtonTrade[1].button = GetPointer(m_button_buy);
         ButtonTrade[1].active_color = clrTeal;
      }

      if(m_order_button_names[0] == "")
      {
         m_order_button_names[0] = "TraderPanelButtonMarket";
         m_order_button_names[1] = "TraderPanelButtonLimit";
         m_order_button_names[2] = "TraderPanelButtonStop";
         m_order_types[0] = PANEL_ORDER_TYPE_MARKET;
         m_order_types[1] = PANEL_ORDER_TYPE_LIMIT;
         m_order_types[2] = PANEL_ORDER_TYPE_STOP;
      }
      if(ButtonOrder[0].button == NULL)
      {
         ButtonOrder[0].button = GetPointer(m_button_market);
         ButtonOrder[1].button = GetPointer(m_button_limit);
         ButtonOrder[2].button = GetPointer(m_button_stop);
      }

      ButtonTrade[m_trade_direction].active = true;
      (*ButtonTrade[m_trade_direction].button).ColorBackground(ButtonTrade[m_trade_direction].active_color);
      (*ButtonTrade[m_trade_direction].button).Color(clrWhite);

      int inactive_direction = (m_trade_direction == TRADE_DIRECTION_BUY) ? TRADE_DIRECTION_SELL : TRADE_DIRECTION_BUY;
      ButtonTrade[inactive_direction].active = false;
      (*ButtonTrade[inactive_direction].button).ColorBackground(clrGray);
      (*ButtonTrade[inactive_direction].button).Color(clrDarkGray);

      for(int i = 0; i < 3; i++)
      {
         if(m_order_types[i] == m_order_type)
         {
            ButtonOrder[i].active = true;
            (*ButtonOrder[i].button).ColorBackground(clrGold);
            (*ButtonOrder[i].button).Color(clrBlack);
         }
         else
         {
            ButtonOrder[i].active = false;
            (*ButtonOrder[i].button).ColorBackground(clrGray);
            (*ButtonOrder[i].button).Color(clrDarkGray);
         }
      }

      UpdateRiskFields();
      UpdateLotField();
      UpdateSLFields();
      UpdateTPFields();

      OnClickCheckBoxSL();
      OnClickCheckBoxTP();

      UpdatePriceLine();

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void RebuildUI(void)
   {
      // Preserve state across timeframe changes.
      SavePanelData();

      DeleteLines();

      m_skip_data_init = true;

      Destroy();

      if(!CreatePanel())
      {
         Print("Panel rebuild failed!");
         m_skip_data_init = false;
         return;
      }

      ChartRedraw(0);
   }

   void SaveToGlobalVariables(void)
   {
      // Persist values per chart+symbol to survive reinitialization.
      SyncDataFromUI();

      long chart_id = ChartID();
      string symbol = Symbol();
      string prefix = "PanelMT5_" + IntegerToString(chart_id) + "_" + symbol + "_";

      GlobalVariableSet(prefix + "risk_percent", m_risk_percent);
      GlobalVariableSet(prefix + "risk_dollar", m_risk_dollar);
      GlobalVariableSet(prefix + "price", m_price);
      GlobalVariableSet(prefix + "lot", m_lot);
      GlobalVariableSet(prefix + "sl_ticks", m_sl_ticks);
      GlobalVariableSet(prefix + "tp_ticks", m_tp_ticks);
      GlobalVariableSet(prefix + "sl_price", m_sl_price);
      GlobalVariableSet(prefix + "tp_price", m_tp_price);
      GlobalVariableSet(prefix + "sl_atr", m_sl_atr);
      GlobalVariableSet(prefix + "tp_atr", m_tp_atr);
      GlobalVariableSet(prefix + "trade_direction", (double)m_trade_direction);
      GlobalVariableSet(prefix + "order_type", (double)m_order_type);
      GlobalVariableSet(prefix + "checkbox_sl_checked", m_checkbox_sl.Checked() ? 1.0 : 0.0);
      GlobalVariableSet(prefix + "checkbox_tp_checked", m_checkbox_tp.Checked() ? 1.0 : 0.0);

      GlobalVariableSet(prefix + "panel_x1", (double)Left());
      GlobalVariableSet(prefix + "panel_y1", (double)Top());
      GlobalVariableSet(prefix + "panel_x2", (double)Right());
      GlobalVariableSet(prefix + "panel_y2", (double)Bottom());

      GlobalVariableSet(prefix + "version", 1.0);
   }

   bool LoadFromGlobalVariables(void)
   {
      // Restore saved state for this chart+symbol.
      long chart_id = ChartID();
      string symbol = Symbol();
      string prefix = "PanelMT5_" + IntegerToString(chart_id) + "_" + symbol + "_";

      if(!GlobalVariableCheck(prefix + "version"))
         return false;

      m_risk_percent = GlobalVariableGet(prefix + "risk_percent");
      m_risk_dollar = GlobalVariableGet(prefix + "risk_dollar");
      m_price = GlobalVariableGet(prefix + "price");
      m_lot = GlobalVariableGet(prefix + "lot");
      m_sl_ticks = GlobalVariableGet(prefix + "sl_ticks");
      m_tp_ticks = GlobalVariableGet(prefix + "tp_ticks");
      m_sl_price = GlobalVariableGet(prefix + "sl_price");
      m_tp_price = GlobalVariableGet(prefix + "tp_price");
      m_sl_atr = GlobalVariableGet(prefix + "sl_atr");
      m_tp_atr = GlobalVariableGet(prefix + "tp_atr");
      m_trade_direction = (ENUM_TRADE_DIRECTION)(int)GlobalVariableGet(prefix + "trade_direction");
      m_trade_direction_new = m_trade_direction;
      m_order_type = (ENUM_PANEL_ORDER_TYPE)(int)GlobalVariableGet(prefix + "order_type");
      m_order_type_new = m_order_type;

      bool checkbox_sl_checked = (GlobalVariableGet(prefix + "checkbox_sl_checked") > 0.5);
      bool checkbox_tp_checked = (GlobalVariableGet(prefix + "checkbox_tp_checked") > 0.5);

      m_saved_data.risk_percent = m_risk_percent;
      m_saved_data.risk_dollar = m_risk_dollar;
      m_saved_data.price = m_price;
      m_saved_data.lot = m_lot;
      m_saved_data.sl_ticks = m_sl_ticks;
      m_saved_data.tp_ticks = m_tp_ticks;
      m_saved_data.sl_price = m_sl_price;
      m_saved_data.tp_price = m_tp_price;
      m_saved_data.sl_atr = m_sl_atr;
      m_saved_data.tp_atr = m_tp_atr;
      m_saved_data.trade_direction = m_trade_direction;
      m_saved_data.order_type = m_order_type;
      m_saved_data.checkbox_sl_checked = checkbox_sl_checked;
      m_saved_data.checkbox_tp_checked = checkbox_tp_checked;

      m_saved_data.panel_x1 = (int)GlobalVariableGet(prefix + "panel_x1");
      m_saved_data.panel_y1 = (int)GlobalVariableGet(prefix + "panel_y1");
      m_saved_data.panel_x2 = (int)GlobalVariableGet(prefix + "panel_x2");
      m_saved_data.panel_y2 = (int)GlobalVariableGet(prefix + "panel_y2");

      return true;
   }

   bool GetPanelData(string &symbol, ENUM_TRADE_DIRECTION &direction, ENUM_PANEL_ORDER_TYPE &order_type,
                     double &lot, double &price, double &sl_price, double &tp_price,
                     bool &sl_active, bool &tp_active)
   {

      SyncDataFromUI();

      symbol = Symbol();
      direction = m_trade_direction;
      order_type = m_order_type;
      lot = m_lot;
      price = m_price;
      sl_price = m_sl_price;
      tp_price = m_tp_price;
      sl_active = m_checkbox_sl.Checked();
      tp_active = m_checkbox_tp.Checked();

      return true;
   }

   void LockPanel(void)
   {
      // Disable edits while an order or position is active.
      m_panel_locked = true;
      m_locked_sl_checked = m_checkbox_sl.Checked();
      m_locked_tp_checked = m_checkbox_tp.Checked();

      m_edit_risk_percent.ReadOnly(true);
      m_edit_risk_dollar.ReadOnly(true);
      m_edit_price.ReadOnly(true);
      m_edit_lot.ReadOnly(true);
      m_edit_sl_ticks.ReadOnly(true);
      m_edit_tp_ticks.ReadOnly(true);
      m_edit_sl_price.ReadOnly(true);
      m_edit_tp_price.ReadOnly(true);
      m_edit_sl_atr.ReadOnly(true);
      m_edit_tp_atr.ReadOnly(true);

      ObjectSetInteger(0, "TraderPanelButtonSell", OBJPROP_STATE, false);
      ObjectSetInteger(0, "TraderPanelButtonBuy", OBJPROP_STATE, false);
      ObjectSetInteger(0, "TraderPanelButtonMarket", OBJPROP_STATE, false);
      ObjectSetInteger(0, "TraderPanelButtonLimit", OBJPROP_STATE, false);
      ObjectSetInteger(0, "TraderPanelButtonStop", OBJPROP_STATE, false);

      ObjectSetInteger(0, "TraderPanelButtonTrade", OBJPROP_STATE, false);

      ObjectSetInteger(0, "TraderPanelCheckBoxSL", OBJPROP_STATE, false);
      ObjectSetInteger(0, "TraderPanelCheckBoxTP", OBJPROP_STATE, false);
      UpdateEditColors();

   }

   void UnlockPanel(void)
   {
      m_panel_locked = false;
      m_locked_sl_checked = m_checkbox_sl.Checked();
      m_locked_tp_checked = m_checkbox_tp.Checked();

      m_edit_risk_percent.ReadOnly(false);
      m_edit_risk_dollar.ReadOnly(false);
      m_edit_price.ReadOnly(false);
      m_edit_lot.ReadOnly(false);

      ObjectSetInteger(0, "TraderPanelButtonSell", OBJPROP_STATE, true);
      ObjectSetInteger(0, "TraderPanelButtonBuy", OBJPROP_STATE, true);
      ObjectSetInteger(0, "TraderPanelButtonMarket", OBJPROP_STATE, true);
      ObjectSetInteger(0, "TraderPanelButtonLimit", OBJPROP_STATE, true);
      ObjectSetInteger(0, "TraderPanelButtonStop", OBJPROP_STATE, true);

      ObjectSetInteger(0, "TraderPanelButtonTrade", OBJPROP_STATE, true);

      ObjectSetInteger(0, "TraderPanelCheckBoxSL", OBJPROP_STATE, true);
      ObjectSetInteger(0, "TraderPanelCheckBoxTP", OBJPROP_STATE, true);

      OnClickCheckBoxSL();
      OnClickCheckBoxTP();

      UpdateBEButton(false);
      UpdateCLOSEButton(false);
      UpdateEditColors();

      if(m_order_type == PANEL_ORDER_TYPE_MARKET && m_controller != NULL)
      {
         string symbol = Symbol();

         double new_price = (*m_controller).GetCurrentPrice(symbol, (int)m_trade_direction);
         if(new_price > 0.0)
         {
            m_price = new_price;

            int digits = (*m_controller).GetSymbolDigits(symbol);
            string price_text = DoubleToString(m_price, digits);
            m_edit_price.Text(price_text);

            RecalculateOnPriceChange();
         }
      }
   }

   void UpdateBEButton(bool is_active)
   {
      if(is_active)
      {

         m_button_be.ColorBackground(clrGold);
         m_button_be.Color(clrBlack);
         ObjectSetInteger(0, "TraderPanelButtonBE", OBJPROP_STATE, true);
      }
      else
      {

         m_button_be.ColorBackground(clrGray);
         m_button_be.Color(clrDarkGray);
         ObjectSetInteger(0, "TraderPanelButtonBE", OBJPROP_STATE, false);
      }
   }

   void UpdateCLOSEButton(bool is_active)
   {
      if(is_active)
      {

         m_button_close_order.ColorBackground(clrGold);
         m_button_close_order.Color(clrBlack);
         ObjectSetInteger(0, "TraderPanelButtonCloseOrder", OBJPROP_STATE, true);
      }
      else
      {

         m_button_close_order.ColorBackground(clrGray);
         m_button_close_order.Color(clrDarkGray);
         ObjectSetInteger(0, "TraderPanelButtonCloseOrder", OBJPROP_STATE, false);
      }
   }

   void UpdatePnLLabel(string symbol, double pnl)
   {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      string balance_text;
      if(pnl == 0.0)
      {

         balance_text = "Balance: " + DoubleToString(balance, 2) + " | PnL: 0.00";
      }
      else
      {

         balance_text = "Balance: " + DoubleToString(balance, 2) + " | PnL: " + DoubleToString(pnl, 2);
      }

      m_label_balance.Text(balance_text);
   }

protected:

   void InitializeButtons(void)
   {

      m_trade_button_names[0] = "TraderPanelButtonSell";
      m_trade_button_names[1] = "TraderPanelButtonBuy";
      m_trade_types[0] = TRADE_DIRECTION_SELL;
      m_trade_types[1] = TRADE_DIRECTION_BUY;

      ButtonTrade[0].button = GetPointer(m_button_sell);
      ButtonTrade[0].active = true;
      ButtonTrade[0].active_color = clrRed;
      ButtonTrade[1].button = GetPointer(m_button_buy);
      ButtonTrade[1].active = false;
      ButtonTrade[1].active_color = clrTeal;

      m_trade_direction = TRADE_DIRECTION_SELL;
      (*ButtonTrade[0].button).ColorBackground(clrRed);
      (*ButtonTrade[0].button).Color(clrWhite);
      (*ButtonTrade[1].button).ColorBackground(clrGray);
      (*ButtonTrade[1].button).Color(clrDarkGray);

      m_order_button_names[0] = "TraderPanelButtonMarket";
      m_order_button_names[1] = "TraderPanelButtonLimit";
      m_order_button_names[2] = "TraderPanelButtonStop";
      m_order_types[0] = PANEL_ORDER_TYPE_MARKET;
      m_order_types[1] = PANEL_ORDER_TYPE_LIMIT;
      m_order_types[2] = PANEL_ORDER_TYPE_STOP;

      ButtonOrder[0].button = GetPointer(m_button_market);
      ButtonOrder[0].active = true;
      ButtonOrder[1].button = GetPointer(m_button_limit);
      ButtonOrder[1].active = false;
      ButtonOrder[2].button = GetPointer(m_button_stop);
      ButtonOrder[2].active = false;

      m_order_type = PANEL_ORDER_TYPE_MARKET;
      (*ButtonOrder[0].button).ColorBackground(clrGold);
      (*ButtonOrder[0].button).Color(clrBlack);
      (*ButtonOrder[1].button).ColorBackground(clrGray);
      (*ButtonOrder[1].button).Color(clrDarkGray);
      (*ButtonOrder[2].button).ColorBackground(clrGray);
      (*ButtonOrder[2].button).Color(clrDarkGray);
   }

   void OnClickTradeDirection(void)
   {

      if(m_trade_direction == m_trade_direction_new)
         return;

      ButtonTrade[m_trade_direction].active = false;

      (*ButtonTrade[m_trade_direction].button).ColorBackground(clrGray);
      (*ButtonTrade[m_trade_direction].button).Color(clrDarkGray);

      ButtonTrade[m_trade_direction_new].active = true;

      (*ButtonTrade[m_trade_direction_new].button).ColorBackground(ButtonTrade[m_trade_direction_new].active_color);
      (*ButtonTrade[m_trade_direction_new].button).Color(clrWhite);

      m_trade_direction = m_trade_direction_new;

      string symbol = Symbol();
      if(m_order_type == PANEL_ORDER_TYPE_MARKET)
      {

         m_price = (m_controller != NULL) ? (*m_controller).GetCurrentPrice(symbol, (int)m_trade_direction) : 0.0;
         int digits = (m_controller != NULL) ? (*m_controller).GetSymbolDigits(symbol) : 2;
         string price_text = DoubleToString(m_price, digits);
         m_edit_price.Text(price_text);

         UpdatePriceLine();
      }

      RecalculateOnTradeDirectionChange();

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void OnClickButtonOrderType(void)
   {

      if(m_order_type == m_order_type_new)
         return;

      ButtonOrder[m_order_type].active = false;

      (*ButtonOrder[m_order_type].button).ColorBackground(clrGray);
      (*ButtonOrder[m_order_type].button).Color(clrDarkGray);

      ButtonOrder[m_order_type_new].active = true;

      (*ButtonOrder[m_order_type_new].button).ColorBackground(clrGold);
      (*ButtonOrder[m_order_type_new].button).Color(clrBlack);

      m_order_type = m_order_type_new;

      if(m_order_type == PANEL_ORDER_TYPE_MARKET)
      {
         string symbol = Symbol();

         m_price = (m_controller != NULL) ? (*m_controller).GetCurrentPrice(symbol, (int)m_trade_direction) : 0.0;
         int digits = (m_controller != NULL) ? (*m_controller).GetSymbolDigits(symbol) : 2;
         string price_text = DoubleToString(m_price, digits);
         m_edit_price.Text(price_text);

         RecalculateOnPriceChange();
      }

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void OnClickCheckBoxSL(void)
   {
      bool is_checked = m_checkbox_sl.Checked();

      m_edit_sl_ticks.ReadOnly(!is_checked);
      m_edit_sl_price.ReadOnly(!is_checked);
      m_edit_sl_atr.ReadOnly(!is_checked);
      UpdateEditColors();

      UpdateSLLine();

      if(is_checked)
         Print("Stoploss enabled: fields active");
      else
         Print("Stoploss disabled: fields locked");
   }

   void OnClickCheckBoxTP(void)
   {
      bool is_checked = m_checkbox_tp.Checked();

      m_edit_tp_ticks.ReadOnly(!is_checked);
      m_edit_tp_price.ReadOnly(!is_checked);
      m_edit_tp_atr.ReadOnly(!is_checked);
      UpdateEditColors();

      UpdateTPLine();

      if(is_checked)
         Print("TakeProfit enabled: fields active");
      else
         Print("TakeProfit disabled: fields locked");
   }

protected:

   bool UpdateTradeButton(bool is_active = true)
   {

      string direction_text = "";
      color button_color = clrGray;

      if(m_trade_direction == TRADE_DIRECTION_SELL)
      {
         direction_text = "Sell";
         button_color = is_active ? clrRed : clrGray;
      }
      else if(m_trade_direction == TRADE_DIRECTION_BUY)
      {
         direction_text = "Buy";
         button_color = is_active ? clrTeal : clrGray;
      }

      string order_type_text = "";
      if(m_order_type == PANEL_ORDER_TYPE_MARKET)
         order_type_text = "Market";
      else if(m_order_type == PANEL_ORDER_TYPE_LIMIT)
         order_type_text = "Limit";
      else if(m_order_type == PANEL_ORDER_TYPE_STOP)
         order_type_text = "Stop";

      string symbol = Symbol();

      int digits = (m_controller != NULL) ? (*m_controller).GetSymbolDigits(symbol) : 2;

      int lot_digits = GetLotDigits();
      string line1_text = direction_text + " " + DoubleToString(m_lot, lot_digits) + " " + symbol;

      string line2_text = DoubleToString(m_price, digits) + " " + order_type_text;

      if(!m_button_trade.ColorBackground(button_color))
         return false;

      if(!is_active)
      {

         m_label_trade_line1.Color(clrDarkGray);
         m_label_trade_line2.Color(clrDarkGray);
      }
      else
      {
         m_label_trade_line1.Color(clrWhite);
         m_label_trade_line2.Color(clrWhite);
      }

      if(!m_label_trade_line1.Text(line1_text))
         return false;
      if(!m_label_trade_line2.Text(line2_text))
         return false;

      return true;
   }

   virtual void OnClickButtonClose(void)
   {

      if(StringFind(m_last_clicked_object, "TraderPanelButtonCloseOrder") >= 0)
      {

         return;
      }

      if(StringFind(m_last_clicked_object, "TraderPanel") == 0 && StringFind(m_last_clicked_object, "Close") >= 0)
      {
         Visible(false);
         ExpertRemove();
      }
   }

   double GetATR(void)
   {

      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      int current_day = dt.day;

      if(m_cached_atr_day != current_day || m_cached_atr == 0.0)
      {
         string symbol = Symbol();

         m_cached_atr = (m_controller != NULL) ? (*m_controller).CalculateATR(symbol, 14, PERIOD_D1) : 0.0;
         m_cached_atr_day = current_day;
      }

      return m_cached_atr;
   }

   void UpdateSLFields(void)
   {
      string symbol = Symbol();
      int digits = (m_controller != NULL) ? (*m_controller).GetSymbolDigits(symbol) : 2;

      string sl_price_text = DoubleToString(m_sl_price, digits);
      m_edit_sl_price.Text(sl_price_text);

      string sl_ticks_text = DoubleToString(m_sl_ticks, 0);
      m_edit_sl_ticks.Text(sl_ticks_text);

      string sl_atr_text = DoubleToString(m_sl_atr, 1);
      m_edit_sl_atr.Text(sl_atr_text);

      UpdateSLLine();
   }

   void UpdateTPFields(void)
   {
      string symbol = Symbol();
      int digits = (m_controller != NULL) ? (*m_controller).GetSymbolDigits(symbol) : 2;

      string tp_price_text = DoubleToString(m_tp_price, digits);
      m_edit_tp_price.Text(tp_price_text);

      string tp_ticks_text = DoubleToString(m_tp_ticks, 0);
      m_edit_tp_ticks.Text(tp_ticks_text);

      string tp_atr_text = DoubleToString(m_tp_atr, 1);
      m_edit_tp_atr.Text(tp_atr_text);

      UpdateTPLine();
   }

   void UpdateRiskFields(void)
   {

      string risk_percent_text = DoubleToString(m_risk_percent, 2);
      m_edit_risk_percent.Text(risk_percent_text);

      string risk_dollar_text = DoubleToString(m_risk_dollar, 2);
      m_edit_risk_dollar.Text(risk_dollar_text);
   }

   void UpdateEditColors(void)
   {
      bool sl_active = (!m_panel_locked && m_checkbox_sl.Checked());
      bool tp_active = (!m_panel_locked && m_checkbox_tp.Checked());
      bool base_active = !m_panel_locked;
      color active_color = clrBlack;
      color inactive_color = clrDarkGray;

      m_edit_risk_percent.Color(base_active ? active_color : inactive_color);
      m_edit_risk_dollar.Color(base_active ? active_color : inactive_color);
      m_edit_price.Color(base_active ? active_color : inactive_color);
      m_edit_lot.Color(base_active ? active_color : inactive_color);

      m_edit_sl_ticks.Color(sl_active ? active_color : inactive_color);
      m_edit_sl_price.Color(sl_active ? active_color : inactive_color);
      m_edit_sl_atr.Color(sl_active ? active_color : inactive_color);

      m_edit_tp_ticks.Color(tp_active ? active_color : inactive_color);
      m_edit_tp_price.Color(tp_active ? active_color : inactive_color);
      m_edit_tp_atr.Color(tp_active ? active_color : inactive_color);
   }

   int GetLotDigitsFromStep(double step) const
   {
      int digits = 0;
      double value = step;
      while(value < 1.0 && digits < 8)
      {
         value *= 10.0;
         digits++;
      }
      return digits;
   }

   int GetLotDigits(void) const
   {
      double step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
      if(step <= 0.0)
         step = 0.01;
      return GetLotDigitsFromStep(step);
   }

   double NormalizeLotValue(double lot) const
   {
      if(lot <= 0.0)
         return 0.0;

      string symbol = Symbol();
      double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

      if(step <= 0.0)
         step = 0.01;
      if(min_lot <= 0.0)
         min_lot = step;

      if(lot < min_lot)
         lot = min_lot;

      double steps = MathRound((lot - min_lot) / step);
      double normalized = min_lot + steps * step;

      if(max_lot > 0.0 && normalized > max_lot)
         normalized = max_lot;

      int digits = GetLotDigitsFromStep(step);
      return NormalizeDouble(normalized, digits);
   }

   void UpdateLotField(void)
   {

      int lot_digits = GetLotDigits();
      string lot_text = DoubleToString(m_lot, lot_digits);
      m_edit_lot.Text(lot_text);
   }

   void RecalculateOnPriceChange(void)
   {
      string symbol = Symbol();
      double atr = GetATR();

      if(m_sl_atr > 0.0)
      {
         if(m_controller != NULL)
         {
            m_sl_price = (*m_controller).CalculateSLPriceFromATR(symbol, m_price, m_sl_atr, atr, (int)m_trade_direction);
            m_sl_ticks = (*m_controller).CalculateSLTicksFromPrice(symbol, m_price, m_sl_price);
         }
         UpdateSLFields();
      }
      else if(m_sl_ticks > 0.0)
      {
         if(m_controller != NULL)
         {
            m_sl_price = (*m_controller).CalculateSLPriceFromTicks(symbol, m_price, m_sl_ticks, (int)m_trade_direction);
            if(atr > 0.0)
               m_sl_atr = (*m_controller).CalculateSLATRFromPrice(symbol, m_price, m_sl_price, atr, (int)m_trade_direction);
         }
         UpdateSLFields();
      }

      if(m_tp_atr > 0.0)
      {
         if(m_controller != NULL)
         {
            m_tp_price = (*m_controller).CalculateTPPriceFromATR(symbol, m_price, m_tp_atr, atr, (int)m_trade_direction);
            m_tp_ticks = (*m_controller).CalculateTPTicksFromPrice(symbol, m_price, m_tp_price);
         }
         UpdateTPFields();
      }
      else if(m_tp_ticks > 0.0)
      {
         if(m_controller != NULL)
         {
            m_tp_price = (*m_controller).CalculateTPPriceFromTicks(symbol, m_price, m_tp_ticks, (int)m_trade_direction);
            if(atr > 0.0)
               m_tp_atr = (*m_controller).CalculateTPATRFromPrice(symbol, m_price, m_tp_price, atr, (int)m_trade_direction);
         }
         UpdateTPFields();
      }

      if(m_risk_dollar > 0.0 && m_sl_price > 0.0)
      {
         m_lot = (m_controller != NULL) ? NormalizeLotValue((*m_controller).CalculateLotFromRisk(symbol, m_risk_dollar, m_price, m_sl_price)) : 0.0;
         UpdateLotField();
      }

      UpdatePriceLine();

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void RecalculateOnLotChange(void)
   {
      string symbol = Symbol();
      m_lot = NormalizeLotValue(m_lot);
      UpdateLotField();

      if(m_sl_price > 0.0)
      {
         m_risk_dollar = (m_controller != NULL) ? (*m_controller).CalculateRiskDollarFromLot(symbol, m_lot, m_price, m_sl_price) : 0.0;

         double balance = AccountInfoDouble(ACCOUNT_BALANCE);
         if(balance > 0.0)
         {
            m_risk_percent = (m_risk_dollar / balance) * 100.0;
            UpdateRiskFields();
         }
      }

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void RecalculateOnRiskPercentChange(void)
   {

      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_risk_dollar = m_risk_percent * balance / 100.0;
      UpdateRiskFields();

      string symbol = Symbol();
      if(m_sl_price > 0.0)
      {
         m_lot = (m_controller != NULL) ? NormalizeLotValue((*m_controller).CalculateLotFromRisk(symbol, m_risk_dollar, m_price, m_sl_price)) : 0.0;
         UpdateLotField();
      }

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void RecalculateOnRiskDollarChange(void)
   {

      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      if(balance > 0.0)
      {
         m_risk_percent = (m_risk_dollar / balance) * 100.0;
         UpdateRiskFields();
      }

      string symbol = Symbol();
      if(m_sl_price > 0.0)
      {
         m_lot = (m_controller != NULL) ? NormalizeLotValue((*m_controller).CalculateLotFromRisk(symbol, m_risk_dollar, m_price, m_sl_price)) : 0.0;
         UpdateLotField();
      }

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void RecalculateOnSLATRChange(void)
   {
      string symbol = Symbol();
      double atr = GetATR();

      m_sl_price = m_controller.CalculateSLPriceFromATR(symbol, m_price, m_sl_atr, atr, (int)m_trade_direction);

      m_sl_ticks = m_controller.CalculateSLTicksFromPrice(symbol, m_price, m_sl_price);

      UpdateSLFields();

      if(m_risk_dollar > 0.0)
      {
         m_lot = (m_controller != NULL) ? NormalizeLotValue((*m_controller).CalculateLotFromRisk(symbol, m_risk_dollar, m_price, m_sl_price)) : 0.0;
         UpdateLotField();
      }

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void RecalculateOnSLPriceChange(void)
   {
      string symbol = Symbol();
      double atr = GetATR();

      if(atr > 0.0)
      {
         m_sl_atr = (m_controller != NULL) ? (*m_controller).CalculateSLATRFromPrice(symbol, m_price, m_sl_price, atr, (int)m_trade_direction) : 0.0;
      }

      m_sl_ticks = m_controller.CalculateSLTicksFromPrice(symbol, m_price, m_sl_price);

      UpdateSLFields();

      if(m_risk_dollar > 0.0)
      {
         m_lot = (m_controller != NULL) ? NormalizeLotValue((*m_controller).CalculateLotFromRisk(symbol, m_risk_dollar, m_price, m_sl_price)) : 0.0;
         UpdateLotField();
      }

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void RecalculateOnSLTicksChange(void)
   {
      string symbol = Symbol();
      double atr = GetATR();

      m_sl_price = (m_controller != NULL) ? (*m_controller).CalculateSLPriceFromTicks(symbol, m_price, m_sl_ticks, (int)m_trade_direction) : 0.0;

      if(atr > 0.0)
      {
         m_sl_atr = (m_controller != NULL) ? (*m_controller).CalculateSLATRFromPrice(symbol, m_price, m_sl_price, atr, (int)m_trade_direction) : 0.0;
      }

      UpdateSLFields();

      if(m_risk_dollar > 0.0)
      {
         m_lot = (m_controller != NULL) ? NormalizeLotValue((*m_controller).CalculateLotFromRisk(symbol, m_risk_dollar, m_price, m_sl_price)) : 0.0;
         UpdateLotField();
      }

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void RecalculateOnTPATRChange(void)
   {
      string symbol = Symbol();
      double atr = GetATR();

      m_tp_price = m_controller.CalculateTPPriceFromATR(symbol, m_price, m_tp_atr, atr, (int)m_trade_direction);

      m_tp_ticks = m_controller.CalculateTPTicksFromPrice(symbol, m_price, m_tp_price);

      UpdateTPFields();

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void RecalculateOnTPPriceChange(void)
   {
      string symbol = Symbol();
      double atr = GetATR();

      if(atr > 0.0)
      {
         m_tp_atr = (m_controller != NULL) ? (*m_controller).CalculateTPATRFromPrice(symbol, m_price, m_tp_price, atr, (int)m_trade_direction) : 0.0;
      }

      m_tp_ticks = m_controller.CalculateTPTicksFromPrice(symbol, m_price, m_tp_price);

      UpdateTPFields();

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void RecalculateOnTPTicksChange(void)
   {
      string symbol = Symbol();
      double atr = GetATR();

      m_tp_price = (m_controller != NULL) ? (*m_controller).CalculateTPPriceFromTicks(symbol, m_price, m_tp_ticks, (int)m_trade_direction) : 0.0;

      if(atr > 0.0)
      {
         m_tp_atr = (m_controller != NULL) ? (*m_controller).CalculateTPATRFromPrice(symbol, m_price, m_tp_price, atr, (int)m_trade_direction) : 0.0;
      }

      UpdateTPFields();

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }

   void RecalculateOnTradeDirectionChange(void)
   {
      string symbol = Symbol();
      double atr = GetATR();

      if(m_sl_atr > 0.0)
      {
         if(m_controller != NULL)
         {
            m_sl_price = (*m_controller).CalculateSLPriceFromATR(symbol, m_price, m_sl_atr, atr, (int)m_trade_direction);
            m_sl_ticks = (*m_controller).CalculateSLTicksFromPrice(symbol, m_price, m_sl_price);
         }
         UpdateSLFields();
      }
      else if(m_sl_ticks > 0.0)
      {
         if(m_controller != NULL)
         {
            m_sl_price = (*m_controller).CalculateSLPriceFromTicks(symbol, m_price, m_sl_ticks, (int)m_trade_direction);
            if(atr > 0.0)
               m_sl_atr = (*m_controller).CalculateSLATRFromPrice(symbol, m_price, m_sl_price, atr, (int)m_trade_direction);
         }
         UpdateSLFields();
      }

      if(m_tp_atr > 0.0)
      {
         if(m_controller != NULL)
         {
            m_tp_price = (*m_controller).CalculateTPPriceFromATR(symbol, m_price, m_tp_atr, atr, (int)m_trade_direction);
            m_tp_ticks = (*m_controller).CalculateTPTicksFromPrice(symbol, m_price, m_tp_price);
         }
         UpdateTPFields();
      }
      else if(m_tp_ticks > 0.0)
      {
         if(m_controller != NULL)
         {
            m_tp_price = (*m_controller).CalculateTPPriceFromTicks(symbol, m_price, m_tp_ticks, (int)m_trade_direction);
            if(atr > 0.0)
               m_tp_atr = (*m_controller).CalculateTPATRFromPrice(symbol, m_price, m_tp_price, atr, (int)m_trade_direction);
         }
         UpdateTPFields();
      }

      bool is_active = true;
      if(m_order_type == PANEL_ORDER_TYPE_LIMIT || m_order_type == PANEL_ORDER_TYPE_STOP)
         is_active = CheckTradeButtonActive();
      UpdateTradeButton(is_active);
   }
