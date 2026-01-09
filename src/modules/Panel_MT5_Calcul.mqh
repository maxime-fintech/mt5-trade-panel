// Math-only helpers for price/ATR/risk conversions.
#property copyright "MT5 Panel Calculations"
#property version   "1.00"
#property strict

class CTradePanelCalculations
{
public:

   CTradePanelCalculations(void) {}

   ~CTradePanelCalculations(void) {}

   static double GetCurrentPrice(string symbol, int direction)
   {

      if(direction == 0)
      {

         return SymbolInfoDouble(symbol, SYMBOL_BID);
      }
      else
      {

         return SymbolInfoDouble(symbol, SYMBOL_ASK);
      }
   }

   static double CalculateATR(string symbol, int period, ENUM_TIMEFRAMES timeframe)
   {

      int handle = iATR(symbol, timeframe, period);

      if(handle == INVALID_HANDLE)
         return 0.0;

      double atr[];
      ArraySetAsSeries(atr, true);

      // CopyBuffer requires an array, even for a single value.
      if(CopyBuffer(handle, 0, 0, 1, atr) <= 0)
      {

         IndicatorRelease(handle);
         return 0.0;
      }

      double result = atr[0];

      IndicatorRelease(handle);

      return result;
   }

   static int GetSymbolDigits(string symbol)
   {

      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      return digits;
   }

   static double GetSymbolPoint(string symbol)
   {

      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      return point;
   }

   static double GetContractSize(string symbol)
   {

      double contract_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      return contract_size;
   }

   static double GetTickValue(string symbol)
   {

      double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      return tick_value;
   }

   static double CalculateSLPriceFromATR(string symbol, double price, double sl_atr, double atr_value, int direction)
   {

      if(direction == 1)
      {
         return price - sl_atr * atr_value;
      }

      else
      {
         return price + sl_atr * atr_value;
      }
   }

   static double CalculateTPPriceFromATR(string symbol, double price, double tp_atr, double atr_value, int direction)
   {

      if(direction == 1)
      {
         return price + tp_atr * atr_value;
      }

      else
      {
         return price - tp_atr * atr_value;
      }
   }

   static double CalculateSLATRFromPrice(string symbol, double price, double sl_price, double atr_value, int direction)
   {

      if(atr_value == 0.0)
         return 0.0;

      if(direction == 1)
      {
         return (price - sl_price) / atr_value;
      }

      else
      {
         return (sl_price - price) / atr_value;
      }
   }

   static double CalculateTPATRFromPrice(string symbol, double price, double tp_price, double atr_value, int direction)
   {

      if(atr_value == 0.0)
         return 0.0;

      if(direction == 1)
      {
         return (tp_price - price) / atr_value;
      }

      else
      {
         return (price - tp_price) / atr_value;
      }
   }

   static double CalculateTicksFromPrices(string symbol, double price1, double price2)
   {

      double point = GetSymbolPoint(symbol);

      if(point == 0.0)
         return 0.0;

      double ticks = MathAbs(price1 - price2) / point;
      return ticks;
   }

   static double CalculateSLPriceFromTicks(string symbol, double price, double sl_ticks, int direction)
   {

      double point = GetSymbolPoint(symbol);

      if(direction == 1)
      {
         return price - sl_ticks * point;
      }

      else
      {
         return price + sl_ticks * point;
      }
   }

   static double CalculateTPPriceFromTicks(string symbol, double price, double tp_ticks, int direction)
   {

      double point = GetSymbolPoint(symbol);

      if(direction == 1)
      {
         return price + tp_ticks * point;
      }

      else
      {
         return price - tp_ticks * point;
      }
   }

   static double CalculateSLTicksFromPrice(string symbol, double price, double sl_price)
   {

      return CalculateTicksFromPrices(symbol, price, sl_price);
   }

   static double CalculateTPTicksFromPrice(string symbol, double price, double tp_price)
   {

      return CalculateTicksFromPrices(symbol, price, tp_price);
   }

   static double CalculateLotFromRisk(string symbol, double risk_dollar, double price, double sl_price)
   {

      double tick_value = GetTickValue(symbol);
      double point = GetSymbolPoint(symbol);

      double price_diff = MathAbs(price - sl_price);

      if(price_diff == 0.0)
         return 0.0;

      if(tick_value == 0.0)
         return 0.0;

      double lot = risk_dollar / (price_diff / point * tick_value);
      return lot;
   }

   static double CalculateRiskFromLot(string symbol, double lot, double price, double sl_price)
   {

      double tick_value = GetTickValue(symbol);
      double point = GetSymbolPoint(symbol);

      double price_diff = MathAbs(price - sl_price);

      double risk_dollar = lot * (price_diff / point * tick_value);
      return risk_dollar;
   }
};
