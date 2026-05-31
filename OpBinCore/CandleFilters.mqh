//+------------------------------------------------------------------+
//|                                            OpBinCore/CandleFilters.mqh |
//|           Regras parametrizaveis para validacao do candle        |
//+------------------------------------------------------------------+
#ifndef __OPBIN_CANDLE_FILTERS_MQH__
#define __OPBIN_CANDLE_FILTERS_MQH__

struct CandleFilterSettings
  {
   double min_body_points;
   double max_body_points;
   double min_range_points;
   double max_range_points;
   double min_upper_wick_points;
   double max_upper_wick_points;
   double min_lower_wick_points;
   double max_lower_wick_points;
   double min_body_pct_range;
   double max_body_pct_range;
   double min_upper_wick_pct_range;
   double max_upper_wick_pct_range;
   double min_lower_wick_pct_range;
   double max_lower_wick_pct_range;
   double doji_tolerance_percent;
  };

bool ValueInRange(const double value,const double min_value,const double max_value)
  {
   return(value >= min_value && value <= max_value);
  }

bool ValidateCandleFilterSettings(const CandleFilterSettings &settings)
  {
   if(settings.min_body_points > settings.max_body_points)
      return(false);
   if(settings.min_range_points > settings.max_range_points)
      return(false);
   if(settings.min_upper_wick_points > settings.max_upper_wick_points)
      return(false);
   if(settings.min_lower_wick_points > settings.max_lower_wick_points)
      return(false);
   if(settings.min_body_pct_range > settings.max_body_pct_range)
      return(false);
   if(settings.min_upper_wick_pct_range > settings.max_upper_wick_pct_range)
      return(false);
   if(settings.min_lower_wick_pct_range > settings.max_lower_wick_pct_range)
      return(false);
   if(settings.doji_tolerance_percent < 0.0 || settings.doji_tolerance_percent > 100.0)
      return(false);

   return(true);
  }

bool ValidateCandleFeatures(const CandleFeatures &features,const CandleFilterSettings &settings)
  {
   if(!ValidateCandleFilterSettings(settings))
      return(false);

   if(!ValueInRange(features.body_points,settings.min_body_points,settings.max_body_points))
      return(false);
   if(!ValueInRange(features.range_points,settings.min_range_points,settings.max_range_points))
      return(false);
   if(!ValueInRange(features.upper_wick_points,settings.min_upper_wick_points,settings.max_upper_wick_points))
      return(false);
   if(!ValueInRange(features.lower_wick_points,settings.min_lower_wick_points,settings.max_lower_wick_points))
      return(false);
   if(!ValueInRange(features.body_pct_range,settings.min_body_pct_range,settings.max_body_pct_range))
      return(false);
   if(!ValueInRange(features.upper_wick_pct_range,settings.min_upper_wick_pct_range,settings.max_upper_wick_pct_range))
      return(false);
   if(!ValueInRange(features.lower_wick_pct_range,settings.min_lower_wick_pct_range,settings.max_lower_wick_pct_range))
      return(false);

   return(true);
  }

#endif
