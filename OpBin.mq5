//+------------------------------------------------------------------+
//|                                              OpBinMartingale.mq5 |
//|                     Base para Operações Binárias                 |
//+------------------------------------------------------------------+
#property strict

#include <Canvas\Canvas.mqh>

//+------------------------------------------------------------------+
//| ENUMS                                                            |
//+------------------------------------------------------------------+

enum ENUM_TIPO_APORTE
{
   APORTE_FIXO = 0,
   APORTE_PERCENTUAL = 1
};

enum ENUM_TIPO_MEDIDA
{
   MEDIDA_PONTOS = 0,
   MEDIDA_PERCENTUAL = 1
};

enum ENUM_MODO_ENTRADA
{
   MODO_DESATIVADO = -1,
   MODO_FILTRO = 0,
   MODO_ESTRATEGIA_1 = 1,
   MODO_CICLO_PRIMEIRO_CANDLE_DIA = 2,
   MODO_TESTE_TODO_CANDLE = 3
};

enum ENUM_DIRECAO_TESTE_TODO_CANDLE
{
   TESTE_CALL = 1,
   TESTE_PUT = -1,
   TESTE_ALTERNAR = 2
};

enum ENUM_CICLO_PRIMEIRA_ENTRADA
{
   SO_PRIMEIRA_ENTRADA = 0,
   EXTENDER_CICLOS = 1
};

enum ENUM_SIM_NAO
{
   NAO = 0,
   SIM = 1
};

enum ENUM_ENTRAR_MARTINGALE
{
   ENTRAR_MARTINGALE_NAO_USAR = 0,
   ENTRAR_MARTINGALE_PRIMEIRO = 1,
   ENTRAR_MARTINGALE_SEGUNDO = 2,
   ENTRAR_MARTINGALE_TERCEIRO = 3
};

enum ENUM_DIRECAO
{
   DIRECAO_ALTA = 1,
   DIRECAO_BAIXA = -1,
   DIRECAO_DOJI = 0
};

enum ENUM_RESULTADO
{
   RESULTADO_LOSS = 0,
   RESULTADO_WIN_G0,
   RESULTADO_WIN_G1,
   RESULTADO_WIN_G2,
   RESULTADO_WIN_G3
};

//+------------------------------------------------------------------+
//| INPUTS                                                           |
//+------------------------------------------------------------------+

//----------------------------------------------------
// OPERAÇÃO
//----------------------------------------------------
input group "Operação"

input ENUM_TIMEFRAMES  InpTimeframe       = PERIOD_M1;
input ENUM_MODO_ENTRADA InpEntrada1       = MODO_ESTRATEGIA_1;
input ENUM_MODO_ENTRADA InpEntrada2       = MODO_DESATIVADO;
input ENUM_MODO_ENTRADA InpEntrada3       = MODO_DESATIVADO;
input int              InpEntradaNCandles = 0;
input bool             InpSentidoDoCandleSinal = true;
input ENUM_DIRECAO_TESTE_TODO_CANDLE InpDirecaoTesteTodoCandle = TESTE_ALTERNAR;
input int              InpMaxMartingale   = 3;
input ENUM_ENTRAR_MARTINGALE InpEntrarNoMartingale = ENTRAR_MARTINGALE_NAO_USAR;

//----------------------------------------------------
// IDENTIFICAÇÃO
//----------------------------------------------------
input group "Identificação"

input long   InpMagicNumber      = 1001;
input string InpNomeEstrategia   = "OpBin";

//----------------------------------------------------
// APORTE
//----------------------------------------------------
input group "Aporte"

input double             InpCapitalInicial = 100.0;
input ENUM_TIPO_APORTE   InpTipoAporte     = APORTE_FIXO;
input double             InpValorAporte    = 2.0;
input double             InpPayout         = 80.0;

//----------------------------------------------------
// FILTRO
//----------------------------------------------------
input group "Filtro"

input ENUM_TIPO_MEDIDA InpTipoMedida = MEDIDA_PONTOS;
input bool InpUsarPavios = false;
input double InpMinCorpo = 0.10;
input double InpMaxCorpo = 100.0;
input double InpMinPavioSuperior = 0.0;
input double InpMaxPavioSuperior = 100.0;
input double InpMinPavioInferior = 0.0;
input double InpMaxPavioInferior = 100.0;
input bool InpAceitarDoji = false;

//----------------------------------------------------
// ESTRATÉGIA 1
//----------------------------------------------------
input group "Estrategia 1 - Retracao na Tendencia da Media Movel"

input int            InpMAPeriodo             = 20;
input ENUM_MA_METHOD InpMAMetodo              = MODE_EMA;
input int            InpInclinacaoMinimaPontos = 5;

//----------------------------------------------------
// ESTRATÉGIA 2
//----------------------------------------------------
input group "Estrategia 2 - Ciclo Primeiro Candle do Dia"

input ENUM_CICLO_PRIMEIRA_ENTRADA InpCicloPrimeiraEntrada = SO_PRIMEIRA_ENTRADA;
input ENUM_SIM_NAO InpMartingaleNoProximoCiclo = NAO;

//----------------------------------------------------
// EXPORTAÇÃO
//----------------------------------------------------
input group "Exportacao"

input bool InpExportarCurvasOtimizacao = true;

input group "Otimizacao"

input bool InpModoCurtoOtimizacao = true;
input int  InpMaxBarrasOtimizacao = 5000;

//----------------------------------------------------
// BRIDGE IQ OPTION
//----------------------------------------------------
input group "Bridge IQ Option"

input bool   InpBridgeAtivo                 = false;
input string InpBridgeRootFolder            = "OpBinBridge";
input string InpBridgeSignalsFolder         = "signals_in";
input string InpBridgeStatusFolder          = "status";
input int    InpBridgeExpirationMinutes     = 1;
input bool   InpBridgeExportarMesmoSemSinal = false;
input int    InpBridgeStatusIntervalSeconds = 2;

//+------------------------------------------------------------------+
//| ESTRUTURAS                                                       |
//+------------------------------------------------------------------+

struct CycleStats
{
   int total_operacoes;
   int total_entradas_executadas;

   int win_g0;
   int win_g1;
   int win_g2;
   int win_g3;

   int loss;

   double banca_final;
   double lucro_total;

   double maior_gale;
   double pico_banca;
   double max_drawdown;
   double max_drawdown_pct;
   double criterio_otimizacao;
   int primeira_quebra_apos_entradas;
};

struct OperationRecord
{
   datetime signal_time;
   int direction;
   int gale_used;
   int result_code;
   double lucro;
   double banca_apos;
};

CycleStats g_stats;

CCanvas g_curve_canvas;
CCanvas g_banner_canvas;
CCanvas g_best_curve_canvas;

double g_curve_balance[];

string g_curve_object_name = "OpBinEquityCurve";
string g_frame_banner_object_name = "OpBinFrameModeBanner";

double g_best_curve_balance[];
string g_best_curve_object_name = "OpBinBestOptimizationCurve";
string g_best_pass_params[];
ulong g_best_pass_number = 0;
double g_best_pass_score = -DBL_MAX;
double g_best_pass_profit = 0.0;
double g_best_pass_drawdown_pct = 0.0;
double g_best_pass_final_balance = 0.0;
int g_best_pass_total_ops = 0;
int g_best_pass_wins = 0;
int g_best_pass_losses = 0;

string g_frame_name = "OpBinCurveFrame";
string g_entry_marker_prefix = "OpBinEntry_";
string g_cycle_box_prefix = "OpBinCycle_";
string g_ma_line_prefix = "OpBinMA_";
string g_panel_background_name = "OpBinStatsPanelBg";
string g_panel_header_name = "OpBinStatsPanelHeader";
string g_panel_line1_name = "OpBinStatsPanelLine1";
string g_panel_line2_name = "OpBinStatsPanelLine2";
string g_panel_line3_name = "OpBinStatsPanelLine3";
string g_panel_line4_name = "OpBinStatsPanelLine4";
string g_panel_line5_name = "OpBinStatsPanelLine5";
string g_panel_line6_name = "OpBinStatsPanelLine6";
string g_panel_line7_name = "OpBinStatsPanelLine7";
string g_panel_line8_name = "OpBinStatsPanelLine8";
string g_panel_line9_name = "OpBinStatsPanelLine9";
string g_panel_line10_name = "OpBinStatsPanelLine10";
string g_panel_line11_name = "OpBinStatsPanelLine11";
string g_panel_line12_name = "OpBinStatsPanelLine12";
string g_panel_line13_name = "OpBinStatsPanelLine13";
string g_panel_line14_name = "OpBinStatsPanelLine14";

int g_total_frames_received = 0;
long g_result_chart_id = 0;
string g_diag_file_name = "OpBinOptimization\\opbin_diag.log";
MqlRates g_rates[];
double g_ma_buffer[];
int g_ma_handle = INVALID_HANDLE;
int g_rates_count = 0;
bool g_has_processed_frames = false;
OperationRecord g_operations[];
OperationRecord g_best_operations[];
const int OP_FRAME_RECORD_SIZE = 6;
const int OP_FRAME_MAX_RECORDS = 20;
datetime g_last_bridge_candle_time = 0;
datetime g_last_bridge_status_time = 0;

string GetBridgeInboxFolder()
{
   return InpBridgeRootFolder + "\\" + InpBridgeSignalsFolder;
}

string GetBridgeStatusFolder()
{
   return InpBridgeRootFolder + "\\" + InpBridgeStatusFolder;
}

bool EnsureBridgeFolders()
{
   if(!InpBridgeAtivo)
      return false;

   if(!FolderCreate(InpBridgeRootFolder, FILE_COMMON) && GetLastError() != 5019)
   {
      Print("Falha ao criar pasta da bridge. Erro: ", GetLastError());
      return false;
   }

   ResetLastError();

   string inbox_folder = GetBridgeInboxFolder();
   if(!FolderCreate(inbox_folder, FILE_COMMON) && GetLastError() != 5019)
   {
      Print("Falha ao criar pasta de sinais da bridge. Erro: ", GetLastError());
      return false;
   }

   ResetLastError();

   string status_folder = GetBridgeStatusFolder();
   if(!FolderCreate(status_folder, FILE_COMMON) && GetLastError() != 5019)
   {
      Print("Falha ao criar pasta de status da bridge. Erro: ", GetLastError());
      return false;
   }

   return true;
}

double GetBridgeAmountHint()
{
   if(InpTipoAporte == APORTE_FIXO)
      return InpValorAporte;

   return 0.0;
}

bool ExportBridgeSignal(const int shift, const int signal_direction)
{
   if(!InpBridgeAtivo)
      return false;

   if(shift < 0)
      return false;

   if(ArraySize(g_rates) <= shift)
      return false;

   if(signal_direction == 0 && !InpBridgeExportarMesmoSemSinal)
      return false;

   if(!EnsureBridgeFolders())
      return false;

   datetime signal_time = g_rates[shift].time;
   string direction_text = "NONE";
   if(signal_direction > 0)
      direction_text = "CALL";
   else if(signal_direction < 0)
      direction_text = "PUT";

   string file_name = StringFormat("%s\\signal_%s_%I64d.json",
      GetBridgeInboxFolder(),
      SanitizeFilePart(_Symbol),
      (long)signal_time);

   int handle = FileOpen(file_name, FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON);
   if(handle == INVALID_HANDLE)
   {
      Print("Falha ao abrir arquivo de sinal da bridge. Erro: ", GetLastError());
      return false;
   }

   string strategy_name = InpNomeEstrategia;
   StringReplace(strategy_name, "\"", "'");

   string json =
      "{\r\n"
      "  \"source\": \"mt5\",\r\n"
      "  \"strategy\": \"" + strategy_name + "\",\r\n"
      "  \"symbol\": \"" + _Symbol + "\",\r\n"
      "  \"timeframe\": \"" + EnumToString(InpTimeframe) + "\",\r\n"
      "  \"signal_time\": " + StringFormat("%I64d", (long)signal_time) + ",\r\n"
      "  \"signal_time_text\": \"" + TimeToString(signal_time, TIME_DATE | TIME_SECONDS) + "\",\r\n"
      "  \"direction\": \"" + direction_text + "\",\r\n"
      "  \"direction_value\": " + IntegerToString(signal_direction) + ",\r\n"
      "  \"expiration_minutes\": " + IntegerToString(InpBridgeExpirationMinutes) + ",\r\n"
      "  \"amount_hint\": " + DoubleToString(GetBridgeAmountHint(), 2) + ",\r\n"
      "  \"tipo_aporte\": \"" + EnumToString(InpTipoAporte) + "\",\r\n"
      "  \"valor_aporte\": " + DoubleToString(InpValorAporte, 2) + ",\r\n"
      "  \"payout_hint\": " + DoubleToString(InpPayout, 2) + ",\r\n"
      "  \"magic_number\": " + StringFormat("%I64d", InpMagicNumber) + "\r\n"
      "}\r\n";

   FileWriteString(handle, json);
   FileClose(handle);

   Print("Bridge: sinal exportado em Common\\Files\\", file_name, " direcao=", direction_text);
   return true;
}

bool ExportBridgeStatus()
{
   if(!InpBridgeAtivo)
      return false;

   if(!EnsureBridgeFolders())
      return false;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return false;

   datetime now = TimeCurrent();
   string file_name = StringFormat("%s\\status_%s.json",
      GetBridgeStatusFolder(),
      SanitizeFilePart(_Symbol));

   int handle = FileOpen(file_name, FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON);
   if(handle == INVALID_HANDLE)
   {
      Print("Falha ao abrir arquivo de status da bridge. Erro: ", GetLastError());
      return false;
   }

   string strategy_name = InpNomeEstrategia;
   StringReplace(strategy_name, "\"", "'");

   double point_value = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double bid = tick.bid;
   double ask = tick.ask;
   double last = tick.last;
   double spread_points = 0.0;
   int total_wins = g_stats.win_g0 + g_stats.win_g1 + g_stats.win_g2 + g_stats.win_g3;
   double winrate_total = (g_stats.total_operacoes > 0)
      ? ((double)total_wins / (double)g_stats.total_operacoes) * 100.0
      : 0.0;
   double media_entradas_semana = GetMediaEntradasPorSemana();
   if(point_value > 0.0)
      spread_points = (ask - bid) / point_value;

   string json =
      "{\r\n"
      "  \"source\": \"mt5\",\r\n"
      "  \"strategy\": \"" + strategy_name + "\",\r\n"
      "  \"symbol\": \"" + _Symbol + "\",\r\n"
      "  \"timeframe\": \"" + EnumToString(InpTimeframe) + "\",\r\n"
      "  \"bridge_active\": true,\r\n"
      "  \"ea_tipo_aporte\": \"" + EnumToString(InpTipoAporte) + "\",\r\n"
      "  \"ea_valor_aporte\": " + DoubleToString(InpValorAporte, 2) + ",\r\n"
      "  \"ea_amount_hint\": " + DoubleToString(GetBridgeAmountHint(), 2) + ",\r\n"
      "  \"ea_payout_hint\": " + DoubleToString(InpPayout, 2) + ",\r\n"
      "  \"ea_max_martingale\": " + IntegerToString(InpMaxMartingale) + ",\r\n"
      "  \"ea_entrar_martingale\": \"" + EnumToString(InpEntrarNoMartingale) + "\",\r\n"
      "  \"ea_bridge_expiration_minutes\": " + IntegerToString(InpBridgeExpirationMinutes) + ",\r\n"
      "  \"ea_total_operacoes\": " + IntegerToString(g_stats.total_operacoes) + ",\r\n"
      "  \"ea_total_entradas_executadas\": " + IntegerToString(g_stats.total_entradas_executadas) + ",\r\n"
      "  \"ea_total_wins\": " + IntegerToString(total_wins) + ",\r\n"
      "  \"ea_total_losses\": " + IntegerToString(g_stats.loss) + ",\r\n"
      "  \"ea_winrate_pct\": " + DoubleToString(winrate_total, 2) + ",\r\n"
      "  \"ea_win_g0\": " + IntegerToString(g_stats.win_g0) + ",\r\n"
      "  \"ea_win_g1\": " + IntegerToString(g_stats.win_g1) + ",\r\n"
      "  \"ea_win_g2\": " + IntegerToString(g_stats.win_g2) + ",\r\n"
      "  \"ea_win_g3\": " + IntegerToString(g_stats.win_g3) + ",\r\n"
      "  \"ea_banca_inicial\": " + DoubleToString(InpCapitalInicial, 2) + ",\r\n"
      "  \"ea_banca_final\": " + DoubleToString(g_stats.banca_final, 2) + ",\r\n"
      "  \"ea_lucro_total\": " + DoubleToString(g_stats.lucro_total, 2) + ",\r\n"
      "  \"ea_maior_gale\": " + DoubleToString(g_stats.maior_gale, 2) + ",\r\n"
      "  \"ea_max_drawdown\": " + DoubleToString(g_stats.max_drawdown, 2) + ",\r\n"
      "  \"ea_max_drawdown_pct\": " + DoubleToString(g_stats.max_drawdown_pct, 2) + ",\r\n"
      "  \"ea_media_entradas_semana\": " + DoubleToString(media_entradas_semana, 2) + ",\r\n"
      "  \"ea_primeira_quebra_apos_entradas\": " + IntegerToString(g_stats.primeira_quebra_apos_entradas) + ",\r\n"
      "  \"ea_score_otimizacao\": " + DoubleToString(g_stats.criterio_otimizacao, 6) + ",\r\n"
      "  \"ea_balance_mode\": \"BRIDGE_DEFINED\",\r\n"
      "  \"chart_id\": " + StringFormat("%I64d", ChartID()) + ",\r\n"
      "  \"server_time\": " + StringFormat("%I64d", (long)now) + ",\r\n"
      "  \"server_time_text\": \"" + TimeToString(now, TIME_DATE | TIME_SECONDS) + "\",\r\n"
      "  \"bid\": " + DoubleToString(bid, _Digits) + ",\r\n"
      "  \"ask\": " + DoubleToString(ask, _Digits) + ",\r\n"
      "  \"last\": " + DoubleToString(last, _Digits) + ",\r\n"
      "  \"spread_points\": " + DoubleToString(spread_points, 2) + ",\r\n"
      "  \"digits\": " + IntegerToString(_Digits) + ",\r\n"
      "  \"point\": " + DoubleToString(point_value, 10) + "\r\n"
      "}\r\n";

   FileWriteString(handle, json);
   FileClose(handle);
   g_last_bridge_status_time = now;
   return true;
}

void ProcessBridgeStatusHeartbeat()
{
   if(!InpBridgeAtivo)
      return;

   if(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_FRAME_MODE))
      return;

   datetime now = TimeCurrent();
   if(InpBridgeStatusIntervalSeconds > 0 &&
      g_last_bridge_status_time > 0 &&
      (now - g_last_bridge_status_time) < InpBridgeStatusIntervalSeconds)
      return;

   ExportBridgeStatus();
}

void ProcessBridgeSignalOnNewBar()
{
   if(!InpBridgeAtivo)
      return;

   if(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_FRAME_MODE))
      return;

   MqlRates latest_rates[];
   ArraySetAsSeries(latest_rates, true);
   int copied = CopyRates(_Symbol, InpTimeframe, 0, 3, latest_rates);
   if(copied < 2)
      return;

   datetime closed_candle_time = latest_rates[1].time;
   if(closed_candle_time <= 0 || closed_candle_time == g_last_bridge_candle_time)
      return;

   ArraySetAsSeries(g_rates, true);
   g_rates_count = CopyRates(_Symbol, InpTimeframe, 0, 300, g_rates);
   if(g_rates_count <= 2)
      return;

   if(UsaEstrategia1())
   {
      if(!LoadMovingAverageBuffer(g_rates_count))
         return;
   }

   int signal_direction = GetStrategyDirection(1);
   if(signal_direction == 0 && !InpBridgeExportarMesmoSemSinal)
   {
      g_last_bridge_candle_time = closed_candle_time;
      return;
   }

   if(ExportBridgeSignal(1, signal_direction))
      g_last_bridge_candle_time = closed_candle_time;
}

long GetRenderChartId()
{
   if(MQLInfoInteger(MQL_FRAME_MODE) && g_result_chart_id > 0)
      return g_result_chart_id;

   return ChartID();
}

void ApplyDefaultChartStyle()
{
   if(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_FRAME_MODE))
      return;

   long chart_id = ChartID();
   color light_slate_gray = C'119,136,153';
   color steel_blue = C'70,130,180';
   color olive = C'128,128,0';
   color live_blue = C'0,168,232';

   ChartSetInteger(chart_id, CHART_MODE, CHART_CANDLES);
   ChartSetInteger(chart_id, CHART_SHOW_GRID, false);
   ChartSetInteger(chart_id, CHART_SHOW_OHLC, false);
   ChartSetInteger(chart_id, CHART_SHOW_PERIOD_SEP, false);
   ChartSetInteger(chart_id, CHART_COLOR_BACKGROUND, clrBlack);
   ChartSetInteger(chart_id, CHART_COLOR_FOREGROUND, clrWhite);
   ChartSetInteger(chart_id, CHART_COLOR_GRID, light_slate_gray);
   ChartSetInteger(chart_id, CHART_COLOR_CHART_UP, clrLime);
   ChartSetInteger(chart_id, CHART_COLOR_CHART_DOWN, clrLime);
   ChartSetInteger(chart_id, CHART_COLOR_CANDLE_BULL, steel_blue);
   ChartSetInteger(chart_id, CHART_COLOR_CANDLE_BEAR, olive);
   ChartSetInteger(chart_id, CHART_COLOR_CHART_LINE, clrLime);
   ChartSetInteger(chart_id, CHART_COLOR_VOLUME, clrLimeGreen);
   ChartSetInteger(chart_id, CHART_COLOR_BID, light_slate_gray);
   ChartSetInteger(chart_id, CHART_COLOR_ASK, clrRed);
   ChartSetInteger(chart_id, CHART_COLOR_LAST, live_blue);
   ChartSetInteger(chart_id, CHART_COLOR_STOP_LEVEL, clrRed);
   ChartRedraw(chart_id);
}

bool EnsureMovingAverageHandle()
{
   if(g_ma_handle != INVALID_HANDLE)
      return true;

   g_ma_handle = iMA(_Symbol, InpTimeframe, InpMAPeriodo, 0, InpMAMetodo, PRICE_CLOSE);
   if(g_ma_handle == INVALID_HANDLE)
   {
      Print("Falha ao criar handle da media movel. Erro: ", GetLastError());
      return false;
   }

   return true;
}

void DeleteMovingAverageOverlay()
{
   long chart_id = GetRenderChartId();
   DeleteObjectsByPrefix(chart_id, g_ma_line_prefix);

   if(chart_id != ChartID())
      DeleteObjectsByPrefix(ChartID(), g_ma_line_prefix);
}

void ReleaseMovingAverageHandle()
{
   if(g_ma_handle == INVALID_HANDLE)
      return;

   IndicatorRelease(g_ma_handle);
   g_ma_handle = INVALID_HANDLE;
}

void DrawMovingAverageOverlay()
{
   if(!UsaEstrategia1())
      return;

   if(ArraySize(g_ma_buffer) < 2 || g_rates_count < 2)
      return;

   long chart_id = GetRenderChartId();
   DeleteMovingAverageOverlay();

   int max_segments = MathMin(g_rates_count - 1, ArraySize(g_ma_buffer) - 1);
   for(int shift = max_segments; shift >= 1; shift--)
   {
      datetime time_a = g_rates[shift].time;
      datetime time_b = g_rates[shift - 1].time;
      double price_a = g_ma_buffer[shift];
      double price_b = g_ma_buffer[shift - 1];

      if(price_a <= 0.0 || price_b <= 0.0)
         continue;

      string object_name = g_ma_line_prefix + IntegerToString(shift);
      ObjectDelete(chart_id, object_name);

      if(!ObjectCreate(chart_id, object_name, OBJ_TREND, 0, time_a, price_a, time_b, price_b))
         continue;

      ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, C'0,168,232');
      ObjectSetInteger(chart_id, object_name, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSetInteger(chart_id, object_name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(chart_id, object_name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(chart_id, object_name, OBJPROP_BACK, true);
      ObjectSetInteger(chart_id, object_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(chart_id, object_name, OBJPROP_HIDDEN, false);
      ObjectSetInteger(chart_id, object_name, OBJPROP_ZORDER, 0);
   }
}

bool EnsureResultChart()
{
   if(!MQLInfoInteger(MQL_FRAME_MODE))
      return false;

   if(g_result_chart_id > 0)
      return true;

   g_result_chart_id = ChartOpen(_Symbol, InpTimeframe);

   if(g_result_chart_id <= 0)
   {
      Print("Falha ao abrir grafico dedicado para resultados. Erro: ", GetLastError());
      g_result_chart_id = ChartID();
      return false;
   }

   ChartSetInteger(g_result_chart_id, CHART_SHOW, false);
   ChartSetInteger(g_result_chart_id, CHART_AUTOSCROLL, false);
   ChartSetInteger(g_result_chart_id, CHART_SHIFT, false);
   ChartSetInteger(g_result_chart_id, CHART_SHOW_GRID, false);
   ChartSetInteger(g_result_chart_id, CHART_SHOW_OHLC, false);
   ChartSetInteger(g_result_chart_id, CHART_SHOW_PERIOD_SEP, false);
   ChartSetInteger(g_result_chart_id, CHART_COLOR_BACKGROUND, clrBlack);
   ChartSetString(g_result_chart_id, CHART_COMMENT, "OpBin - Resultados da Otimizacao");
   ChartRedraw(g_result_chart_id);

   return true;
}

void AppendDiagnostic(const string message)
{
   int handle = FileOpen(g_diag_file_name, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON | FILE_SHARE_READ | FILE_SHARE_WRITE);

   if(handle == INVALID_HANDLE)
      return;

   FileSeek(handle, 0, SEEK_END);
   FileWriteString(handle, TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS) + " | " + message + "\r\n");
   FileClose(handle);
}

//+------------------------------------------------------------------+
//| FUNÇÕES UTILITÁRIAS                                              |
//+------------------------------------------------------------------+

void ResetStats()
{
   ZeroMemory(g_stats);
   ArrayResize(g_curve_balance, 0);
   ArrayResize(g_rates, 0);
   ArrayResize(g_ma_buffer, 0);
   ArrayResize(g_operations, 0);
   g_rates_count = 0;
}

void AddOperationRecord(
   datetime signal_time,
   int direction,
   int gale_used,
   int result_code,
   double lucro,
   double banca_apos
)
{
   int size = ArraySize(g_operations);
   if(ArrayResize(g_operations, size + 1) <= size)
      return;

   g_operations[size].signal_time = signal_time;
   g_operations[size].direction = direction;
   g_operations[size].gale_used = gale_used;
   g_operations[size].result_code = result_code;
   g_operations[size].lucro = lucro;
   g_operations[size].banca_apos = banca_apos;
}

double GetMediaEntradasPorSemana()
{
   int total_operacoes = ArraySize(g_operations);
   if(total_operacoes <= 0 || g_stats.total_entradas_executadas <= 0)
      return 0.0;

   datetime mais_antiga = g_operations[0].signal_time;
   datetime mais_recente = g_operations[0].signal_time;

   for(int i = 1; i < total_operacoes; i++)
   {
      datetime tempo = g_operations[i].signal_time;
      if(tempo < mais_antiga)
         mais_antiga = tempo;
      if(tempo > mais_recente)
         mais_recente = tempo;
   }

   double segundos_periodo = (double)(mais_recente - mais_antiga);
   double semanas = segundos_periodo / 604800.0;

   if(semanas < 1.0)
      semanas = 1.0;

   return (double)g_stats.total_entradas_executadas / semanas;
}

string NormalizeStrategyModeLabel(string label)
{
   StringReplace(label, "MODO_", "");
   return label;
}

string GetConfiguredStrategyModesLabel()
{
   ENUM_MODO_ENTRADA entradas[3] = { InpEntrada1, InpEntrada2, InpEntrada3 };
   string resumo = "";

   for(int i = 0; i < 3; i++)
   {
      if(entradas[i] == MODO_DESATIVADO)
         continue;

      string modo = NormalizeStrategyModeLabel(EnumToString(entradas[i]));
      if(StringLen(resumo) > 0)
         resumo += " + ";
      resumo += modo;
   }

   if(StringLen(resumo) == 0)
      return "SEM_ESTRATEGIA";

   return resumo;
}

string SanitizeFilePart(string value)
{
   string result = "";
   string invalid_chars = "\\/:*?\"<>| ";

   for(int i = 0; i < StringLen(value); i++)
   {
      string ch = StringSubstr(value, i, 1);

      if(StringFind(invalid_chars, ch) >= 0)
         result += "_";
      else
         result += ch;
   }

   return result;
}

bool EnsureOptimizationExportFolder(string &folder_path)
{
   string root_folder = "OpBinOptimization";
   string strategy_folder = root_folder + "\\" + SanitizeFilePart(InpNomeEstrategia);

   if(!FolderCreate(root_folder, FILE_COMMON) && GetLastError() != 5019)
   {
      Print("Falha ao criar pasta raiz de exportacao. Erro: ", GetLastError());
      return false;
   }

   ResetLastError();

   if(!FolderCreate(strategy_folder, FILE_COMMON) && GetLastError() != 5019)
   {
      Print("Falha ao criar pasta da estrategia. Erro: ", GetLastError());
      return false;
   }

   folder_path = strategy_folder;
   return true;
}

string BuildOptimizationPassId()
{
   string symbol_part = SanitizeFilePart(_Symbol);
   string timeframe_part = SanitizeFilePart(EnumToString(InpTimeframe));
   long timestamp = (long)TimeCurrent();
   uint tick = GetTickCount();
   long score_scaled = (long)MathRound(g_stats.criterio_otimizacao * 1000000.0);

   return StringFormat("%s_%s_t%I64d_k%u_s%I64d",
      symbol_part,
      timeframe_part,
      timestamp,
      tick,
      score_scaled);
}

void ExportOptimizationPassFiles()
{
   if(!InpExportarCurvasOtimizacao || !MQLInfoInteger(MQL_OPTIMIZATION))
      return;

   string folder_path;
   if(!EnsureOptimizationExportFolder(folder_path))
      return;

   string pass_id = BuildOptimizationPassId();
   string summary_path = folder_path + "\\summary_" + pass_id + ".csv";
   string curve_path = folder_path + "\\curve_" + pass_id + ".csv";
   string operations_path = folder_path + "\\operations_" + pass_id + ".csv";

   int summary_handle = FileOpen(summary_path, FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_COMMON, ';');

   if(summary_handle == INVALID_HANDLE)
   {
      Print("Falha ao abrir arquivo de resumo. Erro: ", GetLastError());
      return;
   }

   FileWrite(summary_handle,
      "strategy", "symbol", "timeframe", "capital_inicial", "tipo_aporte",
      "valor_aporte", "payout", "max_martingale", "entrar_no_martingale", "entrada_n_candles", "entrada_1",
      "entrada_2", "entrada_3", "tipo_medida", "usar_pavios", "min_corpo", "max_corpo", "min_pavio_sup", "max_pavio_sup", "min_pavio_inf", "max_pavio_inf", "aceitar_doji",
      "ma_periodo", "ma_metodo", "inclinacao_minima_pontos", "ciclo_primeira_entrada", "martingale_no_proximo_ciclo", "total_operacoes", "total_entradas_executadas", "win_g0", "win_g1", "win_g2",
      "win_g3", "loss", "banca_final", "lucro_total", "maior_gale",
      "max_drawdown", "max_drawdown_pct", "score_otimizacao");

   FileWrite(summary_handle,
      InpNomeEstrategia,
      _Symbol,
      EnumToString(InpTimeframe),
      DoubleToString(InpCapitalInicial, 2),
      EnumToString(InpTipoAporte),
      DoubleToString(InpValorAporte, 2),
      DoubleToString(InpPayout, 2),
      IntegerToString(InpMaxMartingale),
      EnumToString(InpEntrarNoMartingale),
      IntegerToString(InpEntradaNCandles),
      EnumToString(InpEntrada1),
      EnumToString(InpEntrada2),
      EnumToString(InpEntrada3),
      EnumToString(InpTipoMedida),
      (InpUsarPavios ? "true" : "false"),
      DoubleToString(InpMinCorpo, 4),
      DoubleToString(InpMaxCorpo, 4),
      DoubleToString(InpMinPavioSuperior, 4),
      DoubleToString(InpMaxPavioSuperior, 4),
      DoubleToString(InpMinPavioInferior, 4),
      DoubleToString(InpMaxPavioInferior, 4),
      (InpAceitarDoji ? "true" : "false"),
      IntegerToString(InpMAPeriodo),
      EnumToString(InpMAMetodo),
      IntegerToString(InpInclinacaoMinimaPontos),
      EnumToString(InpCicloPrimeiraEntrada),
      EnumToString(InpMartingaleNoProximoCiclo),
      IntegerToString(g_stats.total_operacoes),
      IntegerToString(g_stats.total_entradas_executadas),
      IntegerToString(g_stats.win_g0),
      IntegerToString(g_stats.win_g1),
      IntegerToString(g_stats.win_g2),
      IntegerToString(g_stats.win_g3),
      IntegerToString(g_stats.loss),
      DoubleToString(g_stats.banca_final, 2),
      DoubleToString(g_stats.lucro_total, 2),
      DoubleToString(g_stats.maior_gale, 2),
      DoubleToString(g_stats.max_drawdown, 2),
      DoubleToString(g_stats.max_drawdown_pct, 4),
      DoubleToString(g_stats.criterio_otimizacao, 6));

   FileClose(summary_handle);

   int curve_handle = FileOpen(curve_path, FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_COMMON, ';');

   if(curve_handle == INVALID_HANDLE)
   {
      Print("Falha ao abrir arquivo da curva. Erro: ", GetLastError());
      return;
   }

   FileWrite(curve_handle, "indice", "banca");

   for(int i = 0; i < ArraySize(g_curve_balance); i++)
      FileWrite(curve_handle, IntegerToString(i), DoubleToString(g_curve_balance[i], 6));

   FileClose(curve_handle);

   int operations_handle = FileOpen(operations_path, FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_COMMON, ';');
   if(operations_handle != INVALID_HANDLE)
   {
      FileWrite(operations_handle, "indice", "data_sinal", "direcao", "gale_usado", "resultado", "lucro", "banca_apos");

      for(int i = 0; i < ArraySize(g_operations); i++)
      {
         string direction = (g_operations[i].direction > 0) ? "CALL" : ((g_operations[i].direction < 0) ? "PUT" : "DOJI");
         FileWrite(
            operations_handle,
            IntegerToString(i + 1),
            TimeToString(g_operations[i].signal_time, TIME_DATE | TIME_MINUTES),
            direction,
            IntegerToString(g_operations[i].gale_used),
            IntegerToString(g_operations[i].result_code),
            DoubleToString(g_operations[i].lucro, 6),
            DoubleToString(g_operations[i].banca_apos, 6)
         );
      }

      FileClose(operations_handle);
   }

   Print("Exportacao de otimizacao salva em Common\\Files\\", summary_path);
   Print("Curva salva em Common\\Files\\", curve_path);
   Print("Operacoes salvas em Common\\Files\\", operations_path);
}

void AddCurvePoint(double banca)
{
   int size = ArraySize(g_curve_balance);

   if(ArrayResize(g_curve_balance, size + 1) <= size)
      return;

   g_curve_balance[size] = banca;

   if(size == 0 || banca > g_stats.pico_banca)
      g_stats.pico_banca = banca;

   double drawdown = g_stats.pico_banca - banca;

   if(drawdown > g_stats.max_drawdown)
      g_stats.max_drawdown = drawdown;

   if(g_stats.pico_banca > 0.0)
   {
      double drawdown_pct = (drawdown / g_stats.pico_banca) * 100.0;

      if(drawdown_pct > g_stats.max_drawdown_pct)
         g_stats.max_drawdown_pct = drawdown_pct;
   }
}

void DestroyCurveCanvas()
{
   g_curve_canvas.Destroy();
   g_banner_canvas.Destroy();
   g_best_curve_canvas.Destroy();
   long chart_id = GetRenderChartId();
   ObjectDelete(chart_id, g_curve_object_name);
   ObjectDelete(chart_id, g_best_curve_object_name);
   ObjectDelete(chart_id, g_frame_banner_object_name);
}

void DeleteObjectsByPrefix(const long chart_id, const string prefix)
{
   if(chart_id <= 0 || StringLen(prefix) == 0)
      return;

   ObjectsDeleteAll(chart_id, prefix, 0, -1);
   ChartRedraw(chart_id);
}

void DeleteEntryMarkers()
{
   long chart_id = GetRenderChartId();
   DeleteObjectsByPrefix(chart_id, g_entry_marker_prefix);
   DeleteObjectsByPrefix(chart_id, g_cycle_box_prefix);

   if(chart_id != ChartID())
   {
      DeleteObjectsByPrefix(ChartID(), g_entry_marker_prefix);
      DeleteObjectsByPrefix(ChartID(), g_cycle_box_prefix);
   }
}

void DeleteStatsPanel()
{
   long chart_id = GetRenderChartId();
   DeleteObjectsByPrefix(chart_id, "OpBinStatsPanel");

   if(chart_id != ChartID())
      DeleteObjectsByPrefix(ChartID(), "OpBinStatsPanel");
}

void DeleteAllOpBinObjects()
{
   long chart_id = GetRenderChartId();
   DeleteObjectsByPrefix(chart_id, "OpBin");

   if(chart_id != ChartID())
      DeleteObjectsByPrefix(ChartID(), "OpBin");
}

bool EnsurePanelLabel(const string object_name, const ENUM_OBJECT object_type)
{
   long chart_id = GetRenderChartId();

   if(ObjectFind(chart_id, object_name) >= 0)
      return true;

   if(!ObjectCreate(chart_id, object_name, object_type, 0, 0, 0))
   {
      Print("Falha ao criar objeto do painel: ", object_name, " erro=", GetLastError());
      return false;
   }

   return true;
}

void DrawCycleBox(
   const long chart_id,
   const string object_name,
   const int shift_inicio,
   const int shift_fim
)
{
   if(shift_inicio < 0 || shift_fim < 0)
      return;

   int left_shift = MathMax(shift_inicio, shift_fim);
   int right_shift = MathMin(shift_inicio, shift_fim);

   if(left_shift >= g_rates_count || right_shift >= g_rates_count)
      return;

   double cycle_high = CandleHigh(left_shift);
   double cycle_low = CandleLow(left_shift);

   for(int shift = left_shift; shift >= right_shift; shift--)
   {
      double high = CandleHigh(shift);
      double low = CandleLow(shift);

      if(high > cycle_high)
         cycle_high = high;
      if(low < cycle_low)
         cycle_low = low;
   }

   datetime left_time = iTime(_Symbol, InpTimeframe, left_shift);
   datetime right_time = iTime(_Symbol, InpTimeframe, right_shift);

   ObjectDelete(chart_id, object_name);

   if(!ObjectCreate(chart_id, object_name, OBJ_RECTANGLE, 0, left_time, cycle_high, right_time, cycle_low))
   {
      Print("Falha ao criar quadro do ciclo. Objeto=", object_name, " erro=", GetLastError());
      return;
   }

   ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, C'24,102,110');
   ObjectSetInteger(chart_id, object_name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(chart_id, object_name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(chart_id, object_name, OBJPROP_FILL, false);
   ObjectSetInteger(chart_id, object_name, OBJPROP_BACK, false);
   ObjectSetInteger(chart_id, object_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_id, object_name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(chart_id, object_name, OBJPROP_ZORDER, 5);
}

void DrawStatsPanel()
{
   if(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_FRAME_MODE))
      return;

   long chart_id = GetRenderChartId();
   int chart_width = (int)ChartGetInteger(chart_id, CHART_WIDTH_IN_PIXELS, 0);
   int chart_height = (int)ChartGetInteger(chart_id, CHART_HEIGHT_IN_PIXELS, 0);

   if(chart_width <= 0 || chart_height <= 0)
      return;

   int panel_height = 214;
   int panel_margin = 10;
   int panel_x = 8;
   int panel_y = chart_height - panel_height - 24;
   int panel_width = chart_width - 16;

   if(panel_y < 40)
      panel_y = 40;

   if(!EnsurePanelLabel(g_panel_background_name, OBJ_RECTANGLE_LABEL))
      return;

   ObjectSetInteger(chart_id, g_panel_background_name, OBJPROP_XDISTANCE, panel_x);
   ObjectSetInteger(chart_id, g_panel_background_name, OBJPROP_YDISTANCE, panel_y);
   ObjectSetInteger(chart_id, g_panel_background_name, OBJPROP_XSIZE, panel_width);
   ObjectSetInteger(chart_id, g_panel_background_name, OBJPROP_YSIZE, panel_height);
   ObjectSetInteger(chart_id, g_panel_background_name, OBJPROP_BGCOLOR, C'12,24,44');
   ObjectSetInteger(chart_id, g_panel_background_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(chart_id, g_panel_background_name, OBJPROP_COLOR, C'255,196,64');
   ObjectSetInteger(chart_id, g_panel_background_name, OBJPROP_BACK, false);
   ObjectSetInteger(chart_id, g_panel_background_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_id, g_panel_background_name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(chart_id, g_panel_background_name, OBJPROP_ZORDER, 1);

   int total_wins = g_stats.win_g0 + g_stats.win_g1 + g_stats.win_g2 + g_stats.win_g3;
   double winrate_total = (g_stats.total_operacoes > 0) ? ((double)total_wins / (double)g_stats.total_operacoes) * 100.0 : 0.0;
   double g0_rate = (total_wins > 0) ? ((double)g_stats.win_g0 / (double)total_wins) * 100.0 : 0.0;
   double mg1_rate = (total_wins > 0) ? ((double)g_stats.win_g1 / (double)total_wins) * 100.0 : 0.0;
   double mg2_rate = (total_wins > 0) ? ((double)g_stats.win_g2 / (double)total_wins) * 100.0 : 0.0;
   double mg3_rate = (total_wins > 0) ? ((double)g_stats.win_g3 / (double)total_wins) * 100.0 : 0.0;
   double media_entradas_semana = GetMediaEntradasPorSemana();
   double payout_decimal = InpPayout / 100.0;
   string primeira_quebra = (g_stats.primeira_quebra_apos_entradas > 0)
      ? IntegerToString(g_stats.primeira_quebra_apos_entradas)
      : "sem quebra";
   string aporte_header = "";
   string aporte_line1 = "";
   string aporte_line2 = "";
   string aporte_line3 = "";
   string aporte_line4 = "";

   string header = InpNomeEstrategia + "  |  " + GetConfiguredStrategyModesLabel() + "  |  Tabela de Estatisticas";
   string line1 = StringFormat(
      "Operacoes: %-5d  Entradas: %-5d  Wins: %-5d  Losses: %-5d  Winrate: %6.2f%%",
      g_stats.total_operacoes,
      g_stats.total_entradas_executadas,
      total_wins,
      g_stats.loss,
      winrate_total
   );
   string line2 = "Nivel |   Wins | % Wins";
   string line3 = StringFormat("G0    | %6d | %6.2f%%", g_stats.win_g0, g0_rate);
   string line4 = StringFormat("MG1   | %6d | %6.2f%%", g_stats.win_g1, mg1_rate);
   string line5 = StringFormat("MG2   | %6d | %6.2f%%", g_stats.win_g2, mg2_rate);
   string line6 = StringFormat("MG3   | %6d | %6.2f%%", g_stats.win_g3, mg3_rate);
   string line7 = StringFormat(
      "Banca Ini: %.2f  Banca Fin: %.2f  Lucro: %.2f  Maior Gale: %.2f",
      InpCapitalInicial,
      g_stats.banca_final,
      g_stats.lucro_total,
      g_stats.maior_gale
   );
   if(InpTipoAporte == APORTE_FIXO && payout_decimal > 0.0)
   {
      double stake_g0 = InpValorAporte;
      double perda_g0 = stake_g0;
      double stake_g1 = CalcularStakeMartingale(stake_g0, payout_decimal, perda_g0);
      double perda_g1 = perda_g0 + stake_g1;
      double stake_g2 = CalcularStakeMartingale(stake_g0, payout_decimal, perda_g1);
      double perda_g2 = perda_g1 + stake_g2;
      double stake_g3 = CalcularStakeMartingale(stake_g0, payout_decimal, perda_g2);

      aporte_header = "Aporte Fixo";
      aporte_line1 = StringFormat("E0  : %.2f", stake_g0);
      aporte_line2 = StringFormat("MG1 : %.2f", stake_g1);
      aporte_line3 = StringFormat("MG2 : %.2f", stake_g2);
      aporte_line4 = StringFormat("MG3 : %.2f", stake_g3);
   }
   else if(InpTipoAporte == APORTE_PERCENTUAL)
   {
      aporte_header = "Aporte %";
      aporte_line1 = StringFormat("Valor: %.2f%%", InpValorAporte);
   }
   string line8 = StringFormat(
      "DD Max: %.2f (%.2f%%)  Payout: %.2f%%  TF: %s",
      g_stats.max_drawdown,
      g_stats.max_drawdown_pct,
      InpPayout,
      EnumToString(InpTimeframe)
   );
   string line9 = StringFormat(
      "1a Quebra: %s  |  Media Entradas/Semana: %.2f",
      primeira_quebra,
      media_entradas_semana
   );

   string panel_objects[15] =
   {
      g_panel_header_name,
      g_panel_line1_name,
      g_panel_line2_name,
      g_panel_line3_name,
      g_panel_line4_name,
      g_panel_line5_name,
      g_panel_line6_name,
      g_panel_line7_name,
      g_panel_line8_name,
      g_panel_line9_name,
      g_panel_line10_name,
      g_panel_line11_name,
      g_panel_line12_name,
      g_panel_line13_name,
      g_panel_line14_name
   };

   string panel_texts[15] =
   {
      header,
      line1,
      line2,
      line3,
      line4,
      line5,
      line6,
      line7,
      line8,
      line9,
      aporte_header,
      aporte_line1,
      aporte_line2,
      aporte_line3,
      aporte_line4
   };

   int panel_y_offsets[15] = { 12, 38, 66, 86, 106, 126, 146, 86, 146, 174, 66, 86, 106, 126, 146 };
   int panel_x_offsets[15] = { 10, 10, 10, 10, 10, 10, 10, 470, 470, 10, 250, 250, 250, 250, 250 };
   int font_sizes[15] = { 11, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10 };
   color panel_colors[15] =
   {
      C'255,220,120',
      C'235,235,235',
      C'160,210,255',
      C'160,210,255',
      C'160,210,255',
      C'160,210,255',
      C'160,210,255',
      C'235,235,235',
      C'235,235,235',
      C'255,170,90',
      C'255,220,120',
      C'235,235,235',
      C'235,235,235',
      C'235,235,235',
      C'235,235,235'
   };

   for(int i = 0; i < 15; i++)
   {
      if(!EnsurePanelLabel(panel_objects[i], OBJ_LABEL))
         continue;

      ObjectSetInteger(chart_id, panel_objects[i], OBJPROP_XDISTANCE, panel_x + panel_x_offsets[i]);
      ObjectSetInteger(chart_id, panel_objects[i], OBJPROP_YDISTANCE, panel_y + panel_y_offsets[i]);
      ObjectSetInteger(chart_id, panel_objects[i], OBJPROP_COLOR, panel_colors[i]);
      ObjectSetInteger(chart_id, panel_objects[i], OBJPROP_FONTSIZE, font_sizes[i]);
      ObjectSetInteger(chart_id, panel_objects[i], OBJPROP_BACK, false);
      ObjectSetInteger(chart_id, panel_objects[i], OBJPROP_SELECTABLE, false);
      ObjectSetInteger(chart_id, panel_objects[i], OBJPROP_HIDDEN, false);
      ObjectSetInteger(chart_id, panel_objects[i], OBJPROP_ZORDER, 2);
      ObjectSetString(chart_id, panel_objects[i], OBJPROP_FONT, "Consolas");
      ObjectSetString(chart_id, panel_objects[i], OBJPROP_TEXT, panel_texts[i]);
   }

   ChartRedraw(chart_id);
}

void DrawEntryMarkers()
{
   if(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_FRAME_MODE))
      return;

   long chart_id = GetRenderChartId();
   int total = ArraySize(g_operations);
   int created = 0;
   int cycle_boxes_created = 0;

   DeleteEntryMarkers();

   for(int i = 0; i < total; i++)
   {
      datetime signal_time = g_operations[i].signal_time;
      int direction = g_operations[i].direction;
      int signal_shift = iBarShift(_Symbol, InpTimeframe, signal_time, false);

      if(signal_shift < 0)
         continue;

      int entry_shift = GetCandleOperacaoShift(signal_shift, GetTentativasIgnoradasAntesDaPrimeiraEntrada() + g_operations[i].gale_used);
      if(entry_shift < 0)
         continue;

      datetime entry_time = iTime(_Symbol, InpTimeframe, entry_shift);
      double candle_high = iHigh(_Symbol, InpTimeframe, entry_shift);
      double candle_low = iLow(_Symbol, InpTimeframe, entry_shift);
      double candle_range = candle_high - candle_low;
      double offset = MathMax(candle_range * 0.30, _Point * 28.0);
      double price = candle_low - offset;
      color marker_color = clrYellow;
      int arrow_code = 233;
      ENUM_ARROW_ANCHOR anchor = ANCHOR_TOP;

      if(direction < 0)
      {
         price = candle_high + offset;
         marker_color = clrYellow;
         arrow_code = 234;
         anchor = ANCHOR_BOTTOM;
      }

      string object_name = g_entry_marker_prefix + IntegerToString((int)signal_time) + "_" + IntegerToString(i);

      ObjectDelete(chart_id, object_name);

      if(!ObjectCreate(chart_id, object_name, OBJ_ARROW, 0, entry_time, price))
      {
         Print("Falha ao criar seta de entrada. Objeto=", object_name, " erro=", GetLastError());
         continue;
      }

      created++;
      ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, marker_color);
      ObjectSetInteger(chart_id, object_name, OBJPROP_ARROWCODE, arrow_code);
      ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor);
      ObjectSetInteger(chart_id, object_name, OBJPROP_WIDTH, 3);
      ObjectSetInteger(chart_id, object_name, OBJPROP_BACK, false);
      ObjectSetInteger(chart_id, object_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(chart_id, object_name, OBJPROP_HIDDEN, false);
      ObjectSetInteger(chart_id, object_name, OBJPROP_ZORDER, 10);
      ObjectSetString(
         chart_id,
         object_name,
         OBJPROP_TOOLTIP,
         StringFormat(
            "%s | %s | G%d | Lucro %.2f",
            InpNomeEstrategia,
            (direction > 0 ? "CALL" : "PUT"),
            g_operations[i].gale_used,
            g_operations[i].lucro
         )
      );

      if(UsaCicloPrimeiroCandle())
      {
         int total_boxes = (InpCicloPrimeiraEntrada == SO_PRIMEIRA_ENTRADA || UsaMartingaleNoProximoCiclo())
            ? 1
            : GetQuantidadeTentativasCiclo();

         for(int box_index = 0; box_index < total_boxes; box_index++)
         {
            int cycle_start_shift = signal_shift - (box_index * GetEntradaOffsetCandles());
            int cycle_end_shift = cycle_start_shift - GetEntradaOffsetCandles();
            if(cycle_start_shift < 0)
               break;
            if(cycle_end_shift < 0)
               cycle_end_shift = 0;

            string cycle_object_name =
               g_cycle_box_prefix + IntegerToString((int)signal_time) + "_" +
               IntegerToString(i) + "_" + IntegerToString(box_index);

            DrawCycleBox(chart_id, cycle_object_name, cycle_start_shift, cycle_end_shift);
            if(ObjectFind(chart_id, cycle_object_name) >= 0)
               cycle_boxes_created++;
         }
      }
   }

   Print("Setas de entrada criadas: ", created, " de ", total);
   if(UsaCicloPrimeiroCandle())
      Print("Quadros de ciclo criados: ", cycle_boxes_created);
   ChartRedraw(chart_id);
}

void CopyCurveArray(const double &source[], double &target[])
{
   int total = ArraySize(source);

   ArrayResize(target, total);

   for(int i = 0; i < total; i++)
      target[i] = source[i];
}

void BuildCurveFrame(double &frame_data[])
{
   int total = ArraySize(g_curve_balance);
   int operations_total = ArraySize(g_operations);
   int ops_to_send = (operations_total < OP_FRAME_MAX_RECORDS) ? operations_total : OP_FRAME_MAX_RECORDS;
   int frame_size = total + 9 + (ops_to_send * OP_FRAME_RECORD_SIZE);

   ArrayResize(frame_data, frame_size);

   frame_data[0] = (double)total;
   frame_data[1] = g_stats.banca_final;
   frame_data[2] = g_stats.lucro_total;
   frame_data[3] = g_stats.max_drawdown_pct;
   frame_data[4] = (double)g_stats.total_operacoes;
   frame_data[5] = (double)(g_stats.win_g0 + g_stats.win_g1 + g_stats.win_g2 + g_stats.win_g3);
   frame_data[6] = (double)g_stats.loss;
   frame_data[7] = g_stats.criterio_otimizacao;
   frame_data[8] = (double)ops_to_send;

   int op_start = operations_total - ops_to_send;
   int cursor = 9;
   for(int i = op_start; i < operations_total; i++)
   {
      frame_data[cursor++] = (double)g_operations[i].signal_time;
      frame_data[cursor++] = (double)g_operations[i].direction;
      frame_data[cursor++] = (double)g_operations[i].gale_used;
      frame_data[cursor++] = (double)g_operations[i].result_code;
      frame_data[cursor++] = g_operations[i].lucro;
      frame_data[cursor++] = g_operations[i].banca_apos;
   }

   for(int i = 0; i < total; i++)
      frame_data[cursor + i] = g_curve_balance[i];
}

void DrawFrameModeBanner(const string status_text)
{
   const int width = 760;
   const int height = 120;
   long chart_id = GetRenderChartId();

   ObjectDelete(chart_id, g_frame_banner_object_name);

   g_banner_canvas.Destroy();

   if(!g_banner_canvas.CreateBitmapLabel(chart_id, 0, g_frame_banner_object_name, 20, 40, width, height, COLOR_FORMAT_XRGB_NOALPHA))
   {
      Print("Falha ao criar banner de frame mode.");
      return;
   }

   g_banner_canvas.Erase(XRGB(26, 20, 12));
   g_banner_canvas.FillRectangle(0, 0, width - 1, height - 1, XRGB(26, 20, 12));
   g_banner_canvas.Rectangle(0, 0, width - 1, height - 1, XRGB(190, 150, 70));

   g_banner_canvas.FontSet("Arial", 16);
   g_banner_canvas.TextOut(20, 14, "FRAME MODE ATIVO", XRGB(255, 220, 120));

   g_banner_canvas.FontSet("Arial", 10);
   g_banner_canvas.TextOut(20, 46, status_text, XRGB(235, 235, 235));
   g_banner_canvas.TextOut(20, 64, "Frames recebidos: " + IntegerToString(g_total_frames_received), XRGB(210, 210, 210));
   g_banner_canvas.TextOut(20, 82, "A melhor curva da otimizacao sera desenhada abaixo.", XRGB(210, 210, 210));

   g_banner_canvas.Update();
}

void DrawOptimizationCurveCanvas()
{
   int total = ArraySize(g_best_curve_balance);
   long chart_id = GetRenderChartId();

   if(total < 2)
      return;

   const int width  = 760;
   const int height = 320;
   const int margin = 24;

   ObjectDelete(chart_id, g_best_curve_object_name);

   g_best_curve_canvas.Destroy();

   if(!g_best_curve_canvas.CreateBitmapLabel(chart_id, 0, g_best_curve_object_name, 20, 280, width, height, COLOR_FORMAT_XRGB_NOALPHA))
   {
      Print("Falha ao criar canvas do analisador de otimizacao.");
      return;
   }

   g_best_curve_canvas.Erase(XRGB(14, 14, 24));
   g_best_curve_canvas.FillRectangle(0, 0, width - 1, height - 1, XRGB(14, 14, 24));
   g_best_curve_canvas.Rectangle(0, 0, width - 1, height - 1, XRGB(110, 110, 110));

   double min_balance = g_best_curve_balance[0];
   double max_balance = g_best_curve_balance[0];

   for(int i = 1; i < total; i++)
   {
      if(g_best_curve_balance[i] < min_balance)
         min_balance = g_best_curve_balance[i];

      if(g_best_curve_balance[i] > max_balance)
         max_balance = g_best_curve_balance[i];
   }

   double range = max_balance - min_balance;

   if(range <= 0.0)
      range = 1.0;

   int x_points[];
   int y_points[];

   ArrayResize(x_points, total);
   ArrayResize(y_points, total);

   int plot_width  = width - (margin * 2);
   int plot_top = 86;
   int plot_bottom = height - 24;
   int plot_height = plot_bottom - plot_top;

   for(int i = 0; i < total; i++)
   {
      double x_ratio = (total == 1) ? 0.0 : (double)i / (double)(total - 1);
      double y_ratio = (g_best_curve_balance[i] - min_balance) / range;

      x_points[i] = margin + (int)MathRound(x_ratio * plot_width);
      y_points[i] = plot_bottom - (int)MathRound(y_ratio * plot_height);
   }

   for(int row = 0; row <= 4; row++)
   {
      int y = plot_top + (row * plot_height) / 4;
      g_best_curve_canvas.LineHorizontal(margin, width - margin, y, XRGB(45, 45, 60));
   }

   g_best_curve_canvas.LineVertical(margin, plot_top, plot_bottom, XRGB(90, 90, 110));
   g_best_curve_canvas.LineHorizontal(margin, width - margin, plot_bottom, XRGB(90, 90, 110));
   g_best_curve_canvas.PolylineWu(x_points, y_points, XRGB(80, 180, 255));

   g_best_curve_canvas.FontSet("Arial", 10);
   g_best_curve_canvas.TextOut(margin, 6, "Melhor curva recebida da otimizacao", XRGB(235, 235, 235));
   g_best_curve_canvas.TextOut(margin, 22, "Pass: " + IntegerToString((int)g_best_pass_number), XRGB(210, 210, 210));
   g_best_curve_canvas.TextOut(margin + 110, 22, "Score: " + DoubleToString(g_best_pass_score, 6), XRGB(210, 210, 210));
   g_best_curve_canvas.TextOut(margin + 320, 22, "Lucro: " + DoubleToString(g_best_pass_profit, 2), XRGB(210, 210, 210));
   g_best_curve_canvas.TextOut(margin + 470, 22, "DD Max: " + DoubleToString(g_best_pass_drawdown_pct, 2) + "%", XRGB(210, 210, 210));
   g_best_curve_canvas.TextOut(margin, 36, "Operacoes: " + IntegerToString(g_best_pass_total_ops), XRGB(210, 210, 210));
   g_best_curve_canvas.TextOut(margin + 140, 36, "Wins: " + IntegerToString(g_best_pass_wins), XRGB(210, 210, 210));
   g_best_curve_canvas.TextOut(margin + 240, 36, "Losses: " + IntegerToString(g_best_pass_losses), XRGB(210, 210, 210));
   g_best_curve_canvas.TextOut(margin + 360, 36, "Banca Final: " + DoubleToString(g_best_pass_final_balance, 2), XRGB(210, 210, 210));

   int params_to_show = (ArraySize(g_best_pass_params) < 6) ? ArraySize(g_best_pass_params) : 6;
   for(int i = 0; i < params_to_show; i++)
      g_best_curve_canvas.TextOut(margin, 58 + (i * 14), g_best_pass_params[i], XRGB(200, 200, 200));

   int ops_to_show = ArraySize(g_best_operations);
   int ops_column_x = width - 260;
   g_best_curve_canvas.TextOut(ops_column_x, 58, "Ultimas operacoes", XRGB(235, 235, 235));
   for(int i = 0; i < ops_to_show; i++)
   {
      string direction = (g_best_operations[i].direction > 0) ? "CALL" : ((g_best_operations[i].direction < 0) ? "PUT" : "DOJI");
      string op_line = TimeToString(g_best_operations[i].signal_time, TIME_MINUTES)
         + "  " + direction
         + " G" + IntegerToString(g_best_operations[i].gale_used)
         + "  L=" + DoubleToString(g_best_operations[i].lucro, 2)
         + "  B=" + DoubleToString(g_best_operations[i].banca_apos, 2);
      g_best_curve_canvas.TextOut(ops_column_x, 74 + (i * 12), op_line, XRGB(200, 200, 200));
   }

   g_best_curve_canvas.Update();
}

void ApplyFrameAsBest(ulong pass_number, double score, const double &frame_data[])
{
   int frame_size = ArraySize(frame_data);

   if(frame_size < 9)
      return;

   int total = (int)MathRound(frame_data[0]);
   int ops_to_read = (int)MathRound(frame_data[8]);
   int curve_offset = 9 + (ops_to_read * OP_FRAME_RECORD_SIZE);

   if(total < 2 || ops_to_read < 0 || frame_size < curve_offset + total)
      return;

   ArrayResize(g_best_operations, ops_to_read);
   int cursor = 9;
   for(int i = 0; i < ops_to_read; i++)
   {
      g_best_operations[i].signal_time = (datetime)MathRound(frame_data[cursor++]);
      g_best_operations[i].direction = (int)MathRound(frame_data[cursor++]);
      g_best_operations[i].gale_used = (int)MathRound(frame_data[cursor++]);
      g_best_operations[i].result_code = (int)MathRound(frame_data[cursor++]);
      g_best_operations[i].lucro = frame_data[cursor++];
      g_best_operations[i].banca_apos = frame_data[cursor++];
   }

   ArrayResize(g_best_curve_balance, total);

   for(int i = 0; i < total; i++)
      g_best_curve_balance[i] = frame_data[curve_offset + i];

   g_best_pass_number = pass_number;
   g_best_pass_score = score;
   g_best_pass_profit = frame_data[2];
   g_best_pass_drawdown_pct = frame_data[3];
    g_best_pass_final_balance = frame_data[1];
   g_best_pass_total_ops = (int)MathRound(frame_data[4]);
   g_best_pass_wins = (int)MathRound(frame_data[5]);
   g_best_pass_losses = (int)MathRound(frame_data[6]);
   g_has_processed_frames = true;

   ArrayResize(g_best_pass_params, 0);

   uint params_count = 0;
   string params[];

   if(FrameInputs(pass_number, params, params_count))
   {
      ArrayResize(g_best_pass_params, (int)params_count);

      for(uint i = 0; i < params_count; i++)
         g_best_pass_params[(int)i] = params[i];
   }

   DrawOptimizationCurveCanvas();
}

void ProcessOptimizationFrames()
{
   ulong pass_number = 0;
   string frame_name;
   long frame_id = 0;
   double frame_value = 0.0;
   double frame_data[];
   int processed = 0;

   while(FrameNext(pass_number, frame_name, frame_id, frame_value, frame_data))
   {
      if(frame_name != g_frame_name)
         continue;

      g_total_frames_received++;

      if(frame_value <= g_best_pass_score)
         continue;

      processed++;
      ApplyFrameAsBest(pass_number, frame_value, frame_data);
   }

    if(processed > 0)
       Print("OnTesterPass/Deinit: frames processados=", processed,
          ", melhor_pass=", (int)g_best_pass_number,
          ", melhor_score=", DoubleToString(g_best_pass_score, 6));

    if(MQLInfoInteger(MQL_FRAME_MODE))
       DrawFrameModeBanner("Ultima atualizacao: melhor pass " + IntegerToString((int)g_best_pass_number));
}

void DrawCurveCanvas()
{
   int total = ArraySize(g_curve_balance);
   long chart_id = GetRenderChartId();

   if(total < 2)
      return;

   const int width  = 640;
   const int height = 220;
   const int margin = 24;

   DestroyCurveCanvas();

   if(!g_curve_canvas.CreateBitmapLabel(chart_id, 0, g_curve_object_name, 20, 40, width, height, COLOR_FORMAT_XRGB_NOALPHA))
   {
      Print("Falha ao criar canvas da curva de banca.");
      return;
   }

   g_curve_canvas.Erase(XRGB(18, 18, 18));
   g_curve_canvas.FillRectangle(0, 0, width - 1, height - 1, XRGB(18, 18, 18));
   g_curve_canvas.Rectangle(0, 0, width - 1, height - 1, XRGB(110, 110, 110));

   double min_balance = g_curve_balance[0];
   double max_balance = g_curve_balance[0];

   for(int i = 1; i < total; i++)
   {
      if(g_curve_balance[i] < min_balance)
         min_balance = g_curve_balance[i];

      if(g_curve_balance[i] > max_balance)
         max_balance = g_curve_balance[i];
   }

   double range = max_balance - min_balance;

   if(range <= 0.0)
      range = 1.0;

   int x_points[];
   int y_points[];

   ArrayResize(x_points, total);
   ArrayResize(y_points, total);

   int plot_width  = width - (margin * 2);
   int plot_height = height - (margin * 2);

   for(int i = 0; i < total; i++)
   {
      double x_ratio = (total == 1) ? 0.0 : (double)i / (double)(total - 1);
      double y_ratio = (g_curve_balance[i] - min_balance) / range;

      x_points[i] = margin + (int)MathRound(x_ratio * plot_width);
      y_points[i] = height - margin - (int)MathRound(y_ratio * plot_height);
   }

   for(int row = 0; row <= 4; row++)
   {
      int y = margin + (row * plot_height) / 4;
      g_curve_canvas.LineHorizontal(margin, width - margin, y, XRGB(45, 45, 45));
   }

   g_curve_canvas.LineVertical(margin, margin, height - margin, XRGB(90, 90, 90));
   g_curve_canvas.LineHorizontal(margin, width - margin, height - margin, XRGB(90, 90, 90));
   g_curve_canvas.PolylineWu(x_points, y_points, XRGB(0, 210, 120));

   g_curve_canvas.FontSet("Arial", 10);
   g_curve_canvas.TextOut(margin, 6, "Curva interna da banca", XRGB(235, 235, 235));
   g_curve_canvas.TextOut(margin, height - 18, "Operacoes: " + IntegerToString(g_stats.total_operacoes), XRGB(210, 210, 210));
   g_curve_canvas.TextOut(width - 170, 6, "Max: " + DoubleToString(max_balance, 2), XRGB(210, 210, 210));
   g_curve_canvas.TextOut(width - 170, 22, "Min: " + DoubleToString(min_balance, 2), XRGB(210, 210, 210));
   g_curve_canvas.TextOut(width - 230, height - 18, "DD Max: " + DoubleToString(g_stats.max_drawdown_pct, 2) + "%", XRGB(210, 210, 210));

   g_curve_canvas.Update();
}

double CandleOpen(int shift)
{
   if(shift < 0 || shift >= g_rates_count)
      return 0.0;

   return g_rates[shift].open;
}

double CandleClose(int shift)
{
   if(shift < 0 || shift >= g_rates_count)
      return 0.0;

   return g_rates[shift].close;
}

double CandleHigh(int shift)
{
   if(shift < 0 || shift >= g_rates_count)
      return 0.0;

   return g_rates[shift].high;
}

double CandleLow(int shift)
{
   if(shift < 0 || shift >= g_rates_count)
      return 0.0;

   return g_rates[shift].low;
}

double MovingAverageValue(int shift)
{
   if(shift < 0 || shift >= ArraySize(g_ma_buffer))
      return 0.0;

   return g_ma_buffer[shift];
}

double GetMovingAverageSlopePoints(int shift)
{
   if(shift < 0 || (shift + 1) >= ArraySize(g_ma_buffer))
      return 0.0;

   return (MovingAverageValue(shift) - MovingAverageValue(shift + 1)) / _Point;
}

bool LoadMovingAverageBuffer(const int bars_to_copy)
{
   if(!EnsureMovingAverageHandle())
      return false;

   ArraySetAsSeries(g_ma_buffer, true);
   int copied = CopyBuffer(g_ma_handle, 0, 0, bars_to_copy, g_ma_buffer);

   if(copied <= 0)
   {
      Print("Falha ao carregar buffer da media movel. Erro: ", GetLastError());
      return false;
   }

   if(copied != bars_to_copy)
      ArrayResize(g_ma_buffer, copied);

   return true;
}

//+------------------------------------------------------------------+
//| DIREÇÃO DO CANDLE                                                |
//+------------------------------------------------------------------+

ENUM_DIRECAO GetDirecaoCandle(int shift)
{
   double open  = CandleOpen(shift);
   double close = CandleClose(shift);

   if(close > open)
      return DIRECAO_ALTA;

   if(close < open)
      return DIRECAO_BAIXA;

   return DIRECAO_DOJI;
}

bool UsaEstrategia1()
{
   return (InpEntrada1 == MODO_ESTRATEGIA_1 ||
           InpEntrada2 == MODO_ESTRATEGIA_1 ||
           InpEntrada3 == MODO_ESTRATEGIA_1);
}

bool UsaCicloPrimeiroCandle()
{
   return (InpEntrada1 == MODO_CICLO_PRIMEIRO_CANDLE_DIA ||
           InpEntrada2 == MODO_CICLO_PRIMEIRO_CANDLE_DIA ||
           InpEntrada3 == MODO_CICLO_PRIMEIRO_CANDLE_DIA);
}

bool UsaMartingaleNoProximoCiclo()
{
   return (UsaCicloPrimeiroCandle() &&
           InpCicloPrimeiraEntrada == EXTENDER_CICLOS &&
           InpMartingaleNoProximoCiclo == SIM);
}

int GetEntradaOffsetCandles()
{
   if(InpEntradaNCandles <= 0)
      return 1;

   return InpEntradaNCandles;
}

int GetTentativasIgnoradasAntesDaPrimeiraEntrada()
{
   switch(InpEntrarNoMartingale)
   {
      case ENTRAR_MARTINGALE_SEGUNDO:
         return 1;

      case ENTRAR_MARTINGALE_TERCEIRO:
         return 2;

      case ENTRAR_MARTINGALE_NAO_USAR:
      case ENTRAR_MARTINGALE_PRIMEIRO:
      default:
         return 0;
   }
}

int GetQuantidadeTentativasCiclo()
{
   if(InpCicloPrimeiraEntrada == SO_PRIMEIRA_ENTRADA)
      return GetTentativasIgnoradasAntesDaPrimeiraEntrada() + 1;

   return GetTentativasIgnoradasAntesDaPrimeiraEntrada() + InpMaxMartingale + 1;
}

int GetCandleOperacaoShift(int candle_sinal, int tentativa_index)
{
   int entrada_offset = GetEntradaOffsetCandles();
   if(UsaMartingaleNoProximoCiclo())
      return candle_sinal - entrada_offset;

   if(UsaCicloPrimeiroCandle())
      return candle_sinal - (entrada_offset + tentativa_index);

   return candle_sinal - (entrada_offset + tentativa_index);
}

int GetCicloRangeShiftFinal(int candle_sinal)
{
   if(!UsaCicloPrimeiroCandle())
      return candle_sinal;

   int shift_final = candle_sinal - GetEntradaOffsetCandles();
   if(InpCicloPrimeiraEntrada == EXTENDER_CICLOS && !UsaMartingaleNoProximoCiclo())
      shift_final = candle_sinal - (GetEntradaOffsetCandles() + GetTentativasIgnoradasAntesDaPrimeiraEntrada() + InpMaxMartingale);
   if(shift_final < 0)
      shift_final = 0;

   return shift_final;
}

ENUM_RESULTADO ResultadoWinPorNivel(int nivel)
{
   switch(nivel)
   {
      case 0: return RESULTADO_WIN_G0;
      case 1: return RESULTADO_WIN_G1;
      case 2: return RESULTADO_WIN_G2;
      default: return RESULTADO_WIN_G3;
   }
}

int GetDirecaoEntradaPorCandleSinal(int shift)
{
   ENUM_DIRECAO direcao_sinal = GetDirecaoCandle(shift);

   if(direcao_sinal == DIRECAO_DOJI)
      return 0;

   if(InpSentidoDoCandleSinal)
      return (int)direcao_sinal;

   return -(int)direcao_sinal;
}

int GetDirecaoTesteTodoCandle(int shift)
{
   if(InpDirecaoTesteTodoCandle == TESTE_CALL)
      return 1;

   if(InpDirecaoTesteTodoCandle == TESTE_PUT)
      return -1;

   if(ArraySize(g_rates) <= shift)
      return 0;

   return ((long)g_rates[shift].time % 2 == 0) ? 1 : -1;
}

//+------------------------------------------------------------------+
//| TAMANHO DO CORPO                                                 |
//+------------------------------------------------------------------+

double GetCorpoCandle(int shift)
{
   double open  = CandleOpen(shift);
   double close = CandleClose(shift);
   double high  = CandleHigh(shift);
   double low   = CandleLow(shift);

   double corpo = InpUsarPavios
      ? MathAbs(high - low)
      : MathAbs(close - open);

   if(InpTipoMedida == MEDIDA_PERCENTUAL)
   {
      double base_price = InpUsarPavios ? high : open;
      if(base_price == 0.0)
         return 0.0;

      return (corpo / base_price) * 100.0;
   }

   return corpo / _Point;
}

//+------------------------------------------------------------------+
//| PAVIO SUPERIOR                                                   |
//+------------------------------------------------------------------+

double GetPavioSuperior(int shift)
{
   double high  = CandleHigh(shift);
   double open  = CandleOpen(shift);
   double close = CandleClose(shift);

   double topo = MathMax(open, close);

   double pavio = high - topo;

   if(InpTipoMedida == MEDIDA_PERCENTUAL)
   {
      if(high == 0.0)
         return 0.0;

      return (pavio / high) * 100.0;
   }

   return pavio / _Point;
}

//+------------------------------------------------------------------+
//| PAVIO INFERIOR                                                   |
//+------------------------------------------------------------------+

double GetPavioInferior(int shift)
{
   double low   = CandleLow(shift);
   double open  = CandleOpen(shift);
   double close = CandleClose(shift);

   double fundo = MathMin(open, close);

   double pavio = fundo - low;

   if(InpTipoMedida == MEDIDA_PERCENTUAL)
   {
      if(low == 0.0)
         return 0.0;

      return (pavio / low) * 100.0;
   }

   return pavio / _Point;
}

//+------------------------------------------------------------------+
//| FILTRO PRINCIPAL                                                 |
//+------------------------------------------------------------------+

bool CandlePassaFiltroClassico(int shift)
{
   ENUM_DIRECAO direcao = GetDirecaoCandle(shift);

   if(direcao == DIRECAO_DOJI && !InpAceitarDoji)
      return false;

   double corpo = GetCorpoCandle(shift);

   if(corpo < InpMinCorpo)
      return false;

   if(corpo > InpMaxCorpo)
      return false;

   double pavioSup = GetPavioSuperior(shift);
   double pavioInf = GetPavioInferior(shift);

   if(pavioSup < InpMinPavioSuperior)
      return false;

   if(pavioSup > InpMaxPavioSuperior)
      return false;

   if(pavioInf < InpMinPavioInferior)
      return false;

   if(pavioInf > InpMaxPavioInferior)
      return false;

   return true;
}

bool CandlePassaEstrategia1(int shift)
{
   if(shift < 0 || (shift + 1) >= g_rates_count)
      return false;

   if(shift >= ArraySize(g_ma_buffer) || (shift + 1) >= ArraySize(g_ma_buffer))
      return false;

   ENUM_DIRECAO direcao = GetDirecaoCandle(shift);

   if(direcao == DIRECAO_DOJI)
      return false;

   double media = MovingAverageValue(shift);

   if(media <= 0.0)
      return false;

   double slope_points = GetMovingAverageSlopePoints(shift);
   double close_price = CandleClose(shift);

   if(close_price > media && slope_points >= InpInclinacaoMinimaPontos && direcao == DIRECAO_BAIXA)
      return true;

   if(close_price < media && slope_points <= -InpInclinacaoMinimaPontos && direcao == DIRECAO_ALTA)
      return true;

   return false;
}

bool IsPrimeiroCandleDoDia(int shift)
{
   if(shift < 0 || shift >= g_rates_count)
      return false;

   if((shift + 1) >= g_rates_count)
      return false;

   MqlDateTime atual;
   MqlDateTime anterior;
   TimeToStruct(g_rates[shift].time, atual);
   TimeToStruct(g_rates[shift + 1].time, anterior);

   if(atual.year != anterior.year)
      return true;

   if(atual.mon != anterior.mon)
      return true;

   return (atual.day != anterior.day);
}

int GetPrimeiroCandleDoDiaShift(int shift)
{
   if(shift < 0 || shift >= g_rates_count)
      return -1;

   MqlDateTime atual;
   TimeToStruct(g_rates[shift].time, atual);

   int primeiro_shift = shift;
   for(int i = shift + 1; i < g_rates_count; i++)
   {
      MqlDateTime candidato;
      TimeToStruct(g_rates[i].time, candidato);

      if(candidato.year != atual.year ||
         candidato.mon != atual.mon ||
         candidato.day != atual.day)
         break;

      primeiro_shift = i;
   }

   return primeiro_shift;
}

bool IsInicioCicloDoDia(int shift)
{
   int primeiro_shift = GetPrimeiroCandleDoDiaShift(shift);
   if(primeiro_shift < 0)
      return false;

   int intervalo = GetEntradaOffsetCandles();
   if(intervalo <= 0)
      intervalo = 1;

   int distancia = primeiro_shift - shift;
   if(distancia < 0)
      return false;

   if(InpCicloPrimeiraEntrada == SO_PRIMEIRA_ENTRADA)
      return (distancia == 0);

   return ((distancia % intervalo) == 0);
}

bool CandlePassaCicloPrimeiroCandleDia(int shift)
{
   if(!IsInicioCicloDoDia(shift))
      return false;

   return (GetDirecaoEntradaPorCandleSinal(shift) != 0);
}

bool EntradaPassaValidacao(ENUM_MODO_ENTRADA modo, int shift)
{
   if(modo == MODO_DESATIVADO)
      return false;

   if(modo == MODO_FILTRO)
      return CandlePassaFiltroClassico(shift);

   if(modo == MODO_ESTRATEGIA_1)
      return CandlePassaEstrategia1(shift);

   if(modo == MODO_CICLO_PRIMEIRO_CANDLE_DIA)
      return CandlePassaCicloPrimeiroCandleDia(shift);

   if(modo == MODO_TESTE_TODO_CANDLE)
      return (GetDirecaoTesteTodoCandle(shift) != 0);

   return false;
}

int GetEntradaSignal(ENUM_MODO_ENTRADA modo, int shift)
{
   if(modo == MODO_DESATIVADO)
      return 0;

   if(modo == MODO_FILTRO)
   {
      if(!CandlePassaFiltroClassico(shift))
         return 0;

      return GetDirecaoEntradaPorCandleSinal(shift);
   }

   if(modo == MODO_ESTRATEGIA_1)
   {
      if(!CandlePassaEstrategia1(shift))
         return 0;

      return GetDirecaoEntradaPorCandleSinal(shift);
   }

   if(modo == MODO_CICLO_PRIMEIRO_CANDLE_DIA)
   {
      if(!CandlePassaCicloPrimeiroCandleDia(shift))
         return 0;

      return GetDirecaoEntradaPorCandleSinal(shift);
   }

   if(modo == MODO_TESTE_TODO_CANDLE)
      return GetDirecaoTesteTodoCandle(shift);

   return 0;
}

int GetStrategyDirection(int shift)
{
   ENUM_MODO_ENTRADA entradas[3] = { InpEntrada1, InpEntrada2, InpEntrada3 };
   bool possui_entrada_ativa = false;
   int signal_final = 0;

   for(int i = 0; i < 3; i++)
   {
      ENUM_MODO_ENTRADA modo = entradas[i];
      if(modo == MODO_DESATIVADO)
         continue;

      int signal_atual = GetEntradaSignal(modo, shift);
      if(signal_atual == 0)
         return 0;

      if(signal_final == 0)
         signal_final = signal_atual;
      else if(signal_final != signal_atual)
         return 0;

      possui_entrada_ativa = true;
   }

   if(!possui_entrada_ativa)
      return 0;

   return signal_final;
}

//+------------------------------------------------------------------+
//| APORTE BASE                                                      |
//+------------------------------------------------------------------+

double CalcularAporteBase(double banca)
{
   if(InpTipoAporte == APORTE_FIXO)
      return InpValorAporte;

   return banca * (InpValorAporte / 100.0);
}

//+------------------------------------------------------------------+
//| MARTINGALE REAL                                                  |
//+------------------------------------------------------------------+

double CalcularStakeMartingale(
   double stake_inicial,
   double payout_decimal,
   double perda_acumulada
)
{
   double lucro_desejado = stake_inicial * payout_decimal;

   double alvo = perda_acumulada + lucro_desejado;

   return alvo / payout_decimal;
}

double CalcularStakeParaNivel(
   double stake_inicial,
   double payout_decimal,
   int nivel
)
{
   if(nivel <= 0)
      return stake_inicial;

   double stake_atual = stake_inicial;
   double perda_acumulada = 0.0;

   for(int i = 1; i <= nivel; i++)
   {
      perda_acumulada += stake_atual;
      stake_atual = CalcularStakeMartingale(
         stake_inicial,
         payout_decimal,
         perda_acumulada
      );
   }

   return stake_atual;
}

//+------------------------------------------------------------------+
//| PROCESSA OPERAÇÃO                                                |
//+------------------------------------------------------------------+

ENUM_RESULTADO ProcessarOperacao(
   int candle_sinal,
   int direcao_entrada,
   double &lucro_operacao,
   int &gale_usado,
   int &entradas_usadas
)
{
   gale_usado = 0;
   entradas_usadas = 0;

   if(direcao_entrada == 0)
   {
      lucro_operacao = 0.0;
      return RESULTADO_LOSS;
   }

   double payout_decimal = InpPayout / 100.0;

   double stake_base =
      CalcularAporteBase(g_stats.banca_final);

   double stake_atual = stake_base;

   double perda_acumulada = 0.0;
   int tentativas_ignoradas = GetTentativasIgnoradasAntesDaPrimeiraEntrada();
   int total_tentativas = UsaCicloPrimeiroCandle()
      ? GetQuantidadeTentativasCiclo()
      : (tentativas_ignoradas + InpMaxMartingale + 1);

   for(int mg = 0; mg < total_tentativas; mg++)
   {
      int candle_operacao = GetCandleOperacaoShift(candle_sinal, mg);

      if(candle_operacao < 0)
         break;

      ENUM_DIRECAO direcao_resultado =
         GetDirecaoCandle(candle_operacao);

      bool win =
         ((int)direcao_resultado == direcao_entrada);

      if(mg < tentativas_ignoradas)
      {
         if(win)
         {
            lucro_operacao = 0.0;
            gale_usado = 0;
            entradas_usadas = 0;
            return RESULTADO_LOSS;
         }

         continue;
      }

      int gale_real = mg - tentativas_ignoradas;
      entradas_usadas++;

      //------------------------------------------------
      // WIN
      //------------------------------------------------
      if(win)
      {
         gale_usado = gale_real;
         lucro_operacao =
            (stake_atual * payout_decimal)
            - perda_acumulada;

         if(stake_atual > g_stats.maior_gale)
            g_stats.maior_gale = stake_atual;

         switch(gale_real)
         {
            case 0: return RESULTADO_WIN_G0;
            case 1: return RESULTADO_WIN_G1;
            case 2: return RESULTADO_WIN_G2;
            default: return RESULTADO_WIN_G3;
         }
      }

      //------------------------------------------------
      // LOSS
      //------------------------------------------------
      perda_acumulada += stake_atual;

      stake_atual =
         CalcularStakeMartingale(
            stake_base,
            payout_decimal,
            perda_acumulada
         );

      if(stake_atual > g_stats.maior_gale)
         g_stats.maior_gale = stake_atual;
   }

   lucro_operacao = -perda_acumulada;
   gale_usado = InpMaxMartingale;
   if(entradas_usadas <= 0)
      entradas_usadas = 0;

   return RESULTADO_LOSS;
}

//+------------------------------------------------------------------+
//| PROCESSAMENTO PRINCIPAL                                          |
//+------------------------------------------------------------------+

void ProcessarHistorico()
{
   ResetStats();

   g_stats.banca_final = InpCapitalInicial;

   AddCurvePoint(g_stats.banca_final);

   int bars = iBars(_Symbol, InpTimeframe);
   int start_bar = bars - 100;

   if(MQLInfoInteger(MQL_OPTIMIZATION) && InpModoCurtoOtimizacao && InpMaxBarrasOtimizacao > 0)
   {
      start_bar = MathMin(start_bar, InpMaxBarrasOtimizacao);
      Print("Modo curto de otimizacao ativo. Barras processadas por passe: ", start_bar);
   }

   if(start_bar < 10)
      start_bar = 10;

   int rates_needed = start_bar + InpMaxMartingale + GetTentativasIgnoradasAntesDaPrimeiraEntrada() + 20;
   if(UsaEstrategia1())
      rates_needed += InpMAPeriodo;

   if(rates_needed > bars)
      rates_needed = bars;

   ArraySetAsSeries(g_rates, true);
   g_rates_count = CopyRates(_Symbol, InpTimeframe, 0, rates_needed, g_rates);

   if(g_rates_count <= 0)
   {
      Print("Falha ao carregar rates para processamento. Erro: ", GetLastError());
      return;
   }

   if(UsaEstrategia1())
   {
      if(!LoadMovingAverageBuffer(g_rates_count))
         return;
   }

   if(start_bar >= g_rates_count)
      start_bar = g_rates_count - 1;

   int min_signal_shift = UsaCicloPrimeiroCandle()
      ? (GetEntradaOffsetCandles() + (UsaMartingaleNoProximoCiclo() ? 0 : (GetTentativasIgnoradasAntesDaPrimeiraEntrada() + InpMaxMartingale)))
      : (GetEntradaOffsetCandles() + GetTentativasIgnoradasAntesDaPrimeiraEntrada() + InpMaxMartingale);
   if(min_signal_shift < 1)
      min_signal_shift = 1;

   int gale_proximo_ciclo = 0;
   double stake_base_proximo_ciclo = 0.0;
   bool cadeia_martingale_ativa = false;

   for(int i = start_bar; i >= min_signal_shift; )
   {
      int direcao_entrada = GetStrategyDirection(i);

      if(direcao_entrada == 0)
      {
         i--;
         continue;
      }

      if(UsaMartingaleNoProximoCiclo())
      {
         double payout_decimal = InpPayout / 100.0;
         int tentativas_ignoradas = GetTentativasIgnoradasAntesDaPrimeiraEntrada();
         if(payout_decimal <= 0.0)
         {
            i -= GetEntradaOffsetCandles();
            continue;
         }

         if(!cadeia_martingale_ativa)
         {
            stake_base_proximo_ciclo = CalcularAporteBase(g_stats.banca_final);
            cadeia_martingale_ativa = true;
            gale_proximo_ciclo = 0;
         }

         int candle_operacao = GetCandleOperacaoShift(i, gale_proximo_ciclo);
         if(candle_operacao < 0)
         {
            i -= GetEntradaOffsetCandles();
            continue;
         }

         ENUM_DIRECAO direcao_resultado = GetDirecaoCandle(candle_operacao);
         bool win = ((int)direcao_resultado == direcao_entrada);
         int gale_real = gale_proximo_ciclo - tentativas_ignoradas;

         if(gale_real < 0)
         {
            if(win)
            {
               gale_proximo_ciclo = 0;
               cadeia_martingale_ativa = false;
            }
            else
            {
               gale_proximo_ciclo++;
            }

            i -= GetEntradaOffsetCandles();
            continue;
         }

         double stake_atual = CalcularStakeParaNivel(
            stake_base_proximo_ciclo,
            payout_decimal,
            gale_real
         );

         double lucro = win ? (stake_atual * payout_decimal) : -stake_atual;
         int gale_usado = gale_real;
         int entradas_usadas = 1;
         ENUM_RESULTADO resultado = win
            ? ResultadoWinPorNivel(gale_real)
            : RESULTADO_LOSS;

         g_stats.total_operacoes++;
         g_stats.total_entradas_executadas += entradas_usadas;

         switch(resultado)
         {
            case RESULTADO_WIN_G0:
               g_stats.win_g0++;
               break;

            case RESULTADO_WIN_G1:
               g_stats.win_g1++;
               break;

            case RESULTADO_WIN_G2:
               g_stats.win_g2++;
               break;

            case RESULTADO_WIN_G3:
               g_stats.win_g3++;
               break;

            case RESULTADO_LOSS:
               g_stats.loss++;
               if(g_stats.primeira_quebra_apos_entradas == 0)
                  g_stats.primeira_quebra_apos_entradas = g_stats.total_entradas_executadas;
               break;
         }

         g_stats.banca_final += lucro;
         if(stake_atual > g_stats.maior_gale)
            g_stats.maior_gale = stake_atual;

         AddOperationRecord(
            g_rates[i].time,
            direcao_entrada,
            gale_usado,
            (int)resultado,
            lucro,
            g_stats.banca_final
         );
         AddCurvePoint(g_stats.banca_final);

         if(win || gale_real >= InpMaxMartingale)
         {
            gale_proximo_ciclo = 0;
            cadeia_martingale_ativa = false;
         }
         else
         {
            gale_proximo_ciclo++;
         }

         i -= GetEntradaOffsetCandles();
         continue;
      }

      double lucro = 0.0;
      int gale_usado = 0;
      int entradas_usadas = 0;

      ENUM_RESULTADO resultado =
         ProcessarOperacao(i, direcao_entrada, lucro, gale_usado, entradas_usadas);

      if(entradas_usadas <= 0)
      {
         if(UsaCicloPrimeiroCandle())
            i -= GetEntradaOffsetCandles();
         else
            i--;
         continue;
      }

      g_stats.total_operacoes++;
      g_stats.total_entradas_executadas += entradas_usadas;

      switch(resultado)
      {
         case RESULTADO_WIN_G0:
            g_stats.win_g0++;
            break;

         case RESULTADO_WIN_G1:
            g_stats.win_g1++;
            break;

         case RESULTADO_WIN_G2:
            g_stats.win_g2++;
            break;

         case RESULTADO_WIN_G3:
            g_stats.win_g3++;
            break;

         case RESULTADO_LOSS:
            g_stats.loss++;
            if(g_stats.primeira_quebra_apos_entradas == 0)
               g_stats.primeira_quebra_apos_entradas = g_stats.total_entradas_executadas;
            break;
      }

      g_stats.banca_final += lucro;
      AddOperationRecord(
         g_rates[i].time,
         direcao_entrada,
         gale_usado,
         (int)resultado,
         lucro,
         g_stats.banca_final
      );
      AddCurvePoint(g_stats.banca_final);

      if(UsaCicloPrimeiroCandle())
         i -= GetEntradaOffsetCandles();
      else
         i--;
   }

   g_stats.lucro_total =
      g_stats.banca_final
      - InpCapitalInicial;

   g_stats.criterio_otimizacao =
      g_stats.lucro_total
      / (1.0 + g_stats.max_drawdown_pct);
}

//+------------------------------------------------------------------+
//| ONINIT                                                           |
//+------------------------------------------------------------------+

int OnInit()
{
   ReleaseMovingAverageHandle();
   DeleteMovingAverageOverlay();
   DestroyCurveCanvas();
   DeleteEntryMarkers();
   DeleteStatsPanel();
   DeleteAllOpBinObjects();
   ApplyDefaultChartStyle();

   Print("OnInit: frame_mode=", (int)MQLInfoInteger(MQL_FRAME_MODE),
      ", optimization=", (int)MQLInfoInteger(MQL_OPTIMIZATION),
      ", visual_mode=", (int)MQLInfoInteger(MQL_VISUAL_MODE));

   if(MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_FRAME_MODE))
      AppendDiagnostic(StringFormat("PASS OnInit | symbol=%s | timeframe=%s | short=%s | maxbars=%d",
         _Symbol,
         EnumToString(InpTimeframe),
         (InpModoCurtoOtimizacao ? "true" : "false"),
         InpMaxBarrasOtimizacao));

   Print("====================================");
   Print("Estratégia: ", InpNomeEstrategia);
   Print("====================================");

   Print("Entrada N candles: ", InpEntradaNCandles);
   Print("Sentido do candle sinal: ", (InpSentidoDoCandleSinal ? "igual" : "contrario"));
   Print("Entrar no martingale: ", EnumToString(InpEntrarNoMartingale));
   Print("Ciclo primeiro candle do dia: ", EnumToString(InpCicloPrimeiraEntrada));
   Print("Martingale no proximo ciclo: ", EnumToString(InpMartingaleNoProximoCiclo));
   Print("Entradas configuradas: ",
      EnumToString(InpEntrada1), " | ",
      EnumToString(InpEntrada2), " | ",
      EnumToString(InpEntrada3));

   if(InpBridgeAtivo)
   {
      EnsureBridgeFolders();
      ExportBridgeStatus();
   }

   ProcessarHistorico();

   Print("Total Operações: ", g_stats.total_operacoes);

   Print("WIN G0: ", g_stats.win_g0);
   Print("WIN G1: ", g_stats.win_g1);
   Print("WIN G2: ", g_stats.win_g2);
   Print("WIN G3: ", g_stats.win_g3);

   Print("LOSS: ", g_stats.loss);

   Print("Lucro Total: ",
      DoubleToString(g_stats.lucro_total, 2));

   Print("Banca Final: ",
      DoubleToString(g_stats.banca_final, 2));

   Print("Maior Gale: ",
      DoubleToString(g_stats.maior_gale, 2));

   Print("Drawdown Max: ",
      DoubleToString(g_stats.max_drawdown, 2),
      " (",
      DoubleToString(g_stats.max_drawdown_pct, 2),
      "%)");

   Print("Score Otimizacao: ",
      DoubleToString(g_stats.criterio_otimizacao, 6));

   if(!MQLInfoInteger(MQL_OPTIMIZATION))
   {
      DrawMovingAverageOverlay();
      DestroyCurveCanvas();
      DrawEntryMarkers();
      DrawStatsPanel();
   }
   else if(MQLInfoInteger(MQL_FRAME_MODE))
   {
      DrawCurveCanvas();
   }

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| ONDEINIT                                                         |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
   DeleteMovingAverageOverlay();
   ReleaseMovingAverageHandle();
   DestroyCurveCanvas();
   DeleteEntryMarkers();
   DeleteStatsPanel();
   DeleteAllOpBinObjects();
}

//+------------------------------------------------------------------+
//| ONTESTER                                                         |
//+------------------------------------------------------------------+

double OnTester()
{
   Print("OnTester: score=", DoubleToString(g_stats.criterio_otimizacao, 6),
      ", pontos_curva=", ArraySize(g_curve_balance),
      ", drawdown_pct=", DoubleToString(g_stats.max_drawdown_pct, 2));

   AppendDiagnostic(StringFormat("PASS OnTester | symbol=%s | timeframe=%s | score=%s | ops=%d | curve=%d",
      _Symbol,
      EnumToString(InpTimeframe),
      DoubleToString(g_stats.criterio_otimizacao, 6),
      g_stats.total_operacoes,
      ArraySize(g_curve_balance)));

   ExportOptimizationPassFiles();

   if(MQLInfoInteger(MQL_OPTIMIZATION))
   {
      double frame_data[];
      BuildCurveFrame(frame_data);

      if(!FrameAdd(g_frame_name, 1, g_stats.criterio_otimizacao, frame_data))
         Print("Falha ao enviar frame da curva. Erro: ", GetLastError());
      else
         Print("OnTester: frame enviado com sucesso. Tamanho=", ArraySize(frame_data));
   }

   return g_stats.criterio_otimizacao;
}

//+------------------------------------------------------------------+
//| ONTESTERINIT                                                     |
//+------------------------------------------------------------------+

void OnTesterInit()
{
   Print("OnTesterInit: frame_mode=", (int)MQLInfoInteger(MQL_FRAME_MODE),
      ", optimization=", (int)MQLInfoInteger(MQL_OPTIMIZATION),
      ", symbol=", _Symbol,
      ", period=", EnumToString(_Period));

   bool preserve_existing_result = g_has_processed_frames && ArraySize(g_best_curve_balance) > 1;

   g_total_frames_received = 0;
   if(!preserve_existing_result)
   {
      g_best_pass_score = -DBL_MAX;
      g_best_pass_number = 0;
      g_best_pass_profit = 0.0;
      g_best_pass_drawdown_pct = 0.0;
      g_best_pass_final_balance = 0.0;
      g_best_pass_total_ops = 0;
      g_best_pass_wins = 0;
      g_best_pass_losses = 0;
      g_has_processed_frames = false;
      ArrayResize(g_best_curve_balance, 0);
      ArrayResize(g_best_pass_params, 0);
      ArrayResize(g_best_operations, 0);
   }

   EnsureResultChart();
   if(preserve_existing_result)
   {
      DrawFrameModeBanner("Resultado anterior preservado. Aguardando novos frames...");
      DrawOptimizationCurveCanvas();
   }
   else
   {
      DrawFrameModeBanner("Aguardando frames da otimizacao...");
   }
}

//+------------------------------------------------------------------+
//| ONTESTERPASS                                                     |
//+------------------------------------------------------------------+

void OnTesterPass()
{
   Print("OnTesterPass: evento recebido");
   ProcessOptimizationFrames();
}

//+------------------------------------------------------------------+
//| ONTESTERDEINIT                                                   |
//+------------------------------------------------------------------+

void OnTesterDeinit()
{
   Print("OnTesterDeinit: processando frames finais");
   ProcessOptimizationFrames();
   Print("OnTesterDeinit: melhor_pass=", (int)g_best_pass_number,
      ", melhor_score=", DoubleToString(g_best_pass_score, 6));

   if(g_total_frames_received <= 0)
   {
      if(!g_has_processed_frames)
      {
         DrawFrameModeBanner("Nenhum frame recebido. A otimizacao terminou sem passes concluidos.");
         Print("OnTesterDeinit: nenhum frame recebido. Verifique se houve ao menos um passe concluido antes de parar a otimizacao.");
      }
      else
      {
         DrawFrameModeBanner("Nenhum frame novo recebido nesta abertura. Mantendo melhor resultado anterior.");
         DrawOptimizationCurveCanvas();
      }
   }
}

//+------------------------------------------------------------------+
//| ONTICK                                                           |
//+------------------------------------------------------------------+

void OnTick()
{
   ProcessBridgeStatusHeartbeat();
   ProcessBridgeSignalOnNewBar();
}

//+------------------------------------------------------------------+
//| ONCHARTEVENT                                                     |
//+------------------------------------------------------------------+

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_CHART_CHANGE && !MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_FRAME_MODE))
   {
      DrawMovingAverageOverlay();
      DrawStatsPanel();
   }
}
