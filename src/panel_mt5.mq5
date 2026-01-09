// MT5 Trade Panel entry point.
#property copyright "MT5 Panel"
#property version   "1.00"
#property strict

#include "modules/Panel_MT5_Controller.mqh"
#include "modules/Panel_mt5_View.mqh"

CTradePanelController g_controller;

int OnInit()
{
   // Enable chart events used by the panel.
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);

   if(!g_controller.Initialize(GetPointer(g_controller)))
   {
      Print("Controller initialization failed!");
      return(INIT_FAILED);
   }

   ChartRedraw(0);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   CTradePanel* view = g_controller.GetView();
   if(view != NULL)
   {
      // Persist UI state between terminal sessions.
      (*view).SaveToGlobalVariables();
      Print("Panel data saved to Global Variables");
   }
}

void OnTick()
{
   g_controller.OnTick();
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   g_controller.OnChartEvent(id, lparam, dparam, sparam);
}
