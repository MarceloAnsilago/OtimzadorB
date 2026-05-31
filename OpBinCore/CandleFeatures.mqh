//+------------------------------------------------------------------+
//|                                           OpBinCore/CandleFeatures.mqh |
//|      Extracao deterministica de features de candle fechado       |
//+------------------------------------------------------------------+
#ifndef __OPBIN_CANDLE_FEATURES_MQH__
#define __OPBIN_CANDLE_FEATURES_MQH__

struct CandleFeatures
  {
   double body_points;
   double range_points;
   double upper_wick_points;
   double lower_wick_points;
   double body_pct_range;
   double upper_wick_pct_range;
   double lower_wick_pct_range;
   bool   bullish;
   bool   bearish;
   bool   doji;
  };

void ResetCandleFeatures(CandleFeatures &features)
  {
   features.body_points            = 0.0;
   features.range_points           = 0.0;
   features.upper_wick_points      = 0.0;
   features.lower_wick_points      = 0.0;
   features.body_pct_range         = 0.0;
   features.upper_wick_pct_range   = 0.0;
   features.lower_wick_pct_range   = 0.0;
   features.bullish                = false;
   features.bearish                = false;
   features.doji                   = false;
  }

bool LoadClosedCandle(const int shift,MqlRates &bar)
  {
   if(shift < 1)
      return(false);

   MqlRates rates[];
   int copied = CopyRates(_Symbol,_Period,shift,1,rates);
   if(copied != 1)
      return(false);

   bar = rates[0];
   return(true);
  }

bool LoadHistoricalRates(const int candles_to_copy,MqlRates &rates[])
  {
   if(candles_to_copy <= 0)
      return(false);

   int copied = CopyRates(_Symbol,_Period,0,candles_to_copy,rates);
   if(copied <= 0)
      return(false);

   ArraySetAsSeries(rates,true);
   return(true);
  }

CandleFeatures ExtractCandleFeaturesFromRate(const MqlRates &bar,const double doji_tolerance_percent)
  {
   CandleFeatures features;
   ResetCandleFeatures(features);

   double point_value = (_Point > 0.0 ? _Point : 1.0);
   double body_price = MathAbs(bar.close - bar.open);
   double range_price = bar.high - bar.low;
   double upper_wick_price = bar.high - MathMax(bar.open,bar.close);
   double lower_wick_price = MathMin(bar.open,bar.close) - bar.low;

   if(upper_wick_price < 0.0)
      upper_wick_price = 0.0;
   if(lower_wick_price < 0.0)
      lower_wick_price = 0.0;
   if(range_price < 0.0)
      range_price = 0.0;

   features.body_points       = body_price / point_value;
   features.range_points      = range_price / point_value;
   features.upper_wick_points = upper_wick_price / point_value;
   features.lower_wick_points = lower_wick_price / point_value;

   if(range_price > 0.0)
     {
      features.body_pct_range       = (body_price * 100.0) / range_price;
      features.upper_wick_pct_range = (upper_wick_price * 100.0) / range_price;
      features.lower_wick_pct_range = (lower_wick_price * 100.0) / range_price;
     }

   bool is_bullish = (bar.close > bar.open);
   bool is_bearish = (bar.close < bar.open);
   bool is_doji = (features.range_points <= 0.0 || features.body_pct_range <= doji_tolerance_percent);

   features.doji    = is_doji;
   features.bullish = (!is_doji && is_bullish);
   features.bearish = (!is_doji && is_bearish);

   return(features);
  }

CandleFeatures ExtractCandleFeaturesFromSeries(const MqlRates &rates[],const int shift,const double doji_tolerance_percent)
  {
   CandleFeatures features;
   ResetCandleFeatures(features);

   if(shift < 0 || shift >= ArraySize(rates))
      return(features);

   return(ExtractCandleFeaturesFromRate(rates[shift],doji_tolerance_percent));
  }

#endif
