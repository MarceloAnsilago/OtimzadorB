//+------------------------------------------------------------------+
//|                                              OpBinCore/SignalEngine.mqh |
//|               Geracao deterministica de sinais de candle         |
//+------------------------------------------------------------------+
#ifndef __OPBIN_SIGNAL_ENGINE_MQH__
#define __OPBIN_SIGNAL_ENGINE_MQH__

enum ENUM_OPBIN_SIGNAL
  {
   SINAL_NENHUM = 0,
   SINAL_CALL   = 1,
   SINAL_PUT    = -1
  };

ENUM_OPBIN_SIGNAL EvaluateSignal(const CandleFeatures &features,const CandleFilterSettings &settings)
  {
   if(!ValidateCandleFeatures(features,settings))
      return(SINAL_NENHUM);

   if(features.doji)
      return(SINAL_NENHUM);

   if(features.bullish)
      return(SINAL_CALL);

   if(features.bearish)
      return(SINAL_PUT);

   return(SINAL_NENHUM);
  }

string SignalToString(const ENUM_OPBIN_SIGNAL signal)
  {
   switch(signal)
     {
      case SINAL_CALL:
         return("CALL");
      case SINAL_PUT:
         return("PUT");
     }

   return("NENHUM");
  }

string CandleDirectionToString(const CandleFeatures &features)
  {
   if(features.doji)
      return("DOJI");
   if(features.bullish)
      return("BULLISH");
   if(features.bearish)
      return("BEARISH");

   return("NEUTRO");
  }

#endif
