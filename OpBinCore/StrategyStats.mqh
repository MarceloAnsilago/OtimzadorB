//+------------------------------------------------------------------+
//|                                            OpBinCore/StrategyStats.mqh |
//|         Validacao historica e estatistica para binarias          |
//+------------------------------------------------------------------+
#ifndef __OPBIN_STRATEGY_STATS_MQH__
#define __OPBIN_STRATEGY_STATS_MQH__

enum ENUM_OPBIN_TRADE_RESULT
  {
   RESULTADO_LOSS      = 0,
   RESULTADO_WIN_G0    = 1,
   RESULTADO_WIN_G1    = 2,
   RESULTADO_WIN_G2    = 3,
   RESULTADO_NO_SIGNAL = 4
  };

struct StrategyResult
  {
   int    total_candles;
   int    total_signals;
   int    total_wins_g0;
   int    total_wins_g1;
   int    total_wins_g2;
   int    total_losses;
   double winrate_g0;
   double winrate_g1;
   double winrate_g2;
   double winrate_total;
   double score_final;
  };

void ResetStrategyResult(StrategyResult &result)
  {
   result.total_candles   = 0;
   result.total_signals   = 0;
   result.total_wins_g0   = 0;
   result.total_wins_g1   = 0;
   result.total_wins_g2   = 0;
   result.total_losses    = 0;
   result.winrate_g0      = 0.0;
   result.winrate_g1      = 0.0;
   result.winrate_g2      = 0.0;
   result.winrate_total   = 0.0;
   result.score_final     = 0.0;
  }

double CalculateWinrate(const int wins,const int total)
  {
   if(total <= 0)
      return(0.0);

   return((double)wins * 100.0 / (double)total);
  }

bool IsWinningBinaryCandle(const ENUM_OPBIN_SIGNAL signal,const MqlRates &bar)
  {
   if(signal == SINAL_CALL)
      return(bar.close > bar.open);

   if(signal == SINAL_PUT)
      return(bar.close < bar.open);

   return(false);
  }

ENUM_OPBIN_TRADE_RESULT CheckTradeResult(
   const ENUM_OPBIN_SIGNAL signal,
   const MqlRates &rates[],
   const int entry_shift,
   const int expiration_candles,
   const bool use_gale_1,
   const bool use_gale_2)
  {
   if(signal == SINAL_NENHUM)
      return(RESULTADO_NO_SIGNAL);

   if(expiration_candles <= 0)
      return(RESULTADO_LOSS);

   int g0_shift = entry_shift - expiration_candles;
   if(g0_shift < 0 || g0_shift >= ArraySize(rates))
      return(RESULTADO_LOSS);

   if(IsWinningBinaryCandle(signal,rates[g0_shift]))
      return(RESULTADO_WIN_G0);

   if(use_gale_1)
     {
      int g1_shift = g0_shift - expiration_candles;
      if(g1_shift >= 0 && g1_shift < ArraySize(rates) && IsWinningBinaryCandle(signal,rates[g1_shift]))
         return(RESULTADO_WIN_G1);
     }

   if(use_gale_2)
     {
      int g2_shift = g0_shift - (expiration_candles * 2);
      if(g2_shift >= 0 && g2_shift < ArraySize(rates) && IsWinningBinaryCandle(signal,rates[g2_shift]))
         return(RESULTADO_WIN_G2);
     }

   return(RESULTADO_LOSS);
  }

void AccumulateTradeResult(StrategyResult &result,const ENUM_OPBIN_TRADE_RESULT trade_result)
  {
   if(trade_result == RESULTADO_NO_SIGNAL)
      return;

   result.total_signals++;

   switch(trade_result)
     {
      case RESULTADO_WIN_G0:
         result.total_wins_g0++;
         break;
      case RESULTADO_WIN_G1:
         result.total_wins_g1++;
         break;
      case RESULTADO_WIN_G2:
         result.total_wins_g2++;
         break;
      default:
         result.total_losses++;
         break;
     }
  }

void FinalizeStrategyResult(StrategyResult &result)
  {
   int total_wins = result.total_wins_g0 + result.total_wins_g1 + result.total_wins_g2;
   result.winrate_g0    = CalculateWinrate(result.total_wins_g0,result.total_signals);
   result.winrate_g1    = CalculateWinrate(result.total_wins_g1,result.total_signals);
   result.winrate_g2    = CalculateWinrate(result.total_wins_g2,result.total_signals);
   result.winrate_total = CalculateWinrate(total_wins,result.total_signals);
   result.score_final   = result.winrate_total;
  }

string TradeResultToString(const ENUM_OPBIN_TRADE_RESULT trade_result)
  {
   switch(trade_result)
     {
      case RESULTADO_WIN_G0:
         return("WIN_G0");
      case RESULTADO_WIN_G1:
         return("WIN_G1");
      case RESULTADO_WIN_G2:
         return("WIN_G2");
      case RESULTADO_NO_SIGNAL:
         return("NO_SIGNAL");
     }

   return("LOSS");
  }

#endif
