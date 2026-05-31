#ifndef __CONSTRUTOR_V2_TAB8_MONTAR_SLOT_CARD_MQH__
#define __CONSTRUTOR_V2_TAB8_MONTAR_SLOT_CARD_MQH__

#include "Tab8Shared.mqh"

struct STab8MontarSlotState
  {
   int               selected_indicator;
   string            spin_values[];
   int               combo_indices[];
  };

class CTab8MontarSlotCard : public CWndCreate
  {
private:
   CWndCreate *m_host;
   CTabs      *m_tabs;
   bool            m_created;
   bool            m_is_active;
   bool            m_silent_updates;
   bool            m_embedded_mode;
   int             m_window_index;
   int             m_tab_index;
   int             m_slot_index;
   int             m_last_selected_index;

   CFrame      m_card;
   CTextLabel  m_combo_label;
   CComboBox   m_combo;
   CFrame      m_body;

   CTextLabel  m_view_title;
   CTextLabel  m_view_note;

   CTextLabel  m_rsi_period_label;
   CTextEdit   m_rsi_period_spin;
   CTextLabel  m_rsi_price_label;
   CComboBox   m_rsi_price_combo;

   CTextLabel  m_reg_period_label;
   CTextEdit   m_reg_period_spin;
   CTextLabel  m_reg_ma_type_label;
   CComboBox   m_reg_ma_type_combo;
   CTextLabel  m_reg_price_label;
   CComboBox   m_reg_price_combo;

   CTextLabel  m_keltner_period_label;
   CTextEdit   m_keltner_period_spin;
   CTextLabel  m_keltner_deviation_label;
   CTextEdit   m_keltner_deviation_spin;
   CTextLabel  m_keltner_ma_type_label;
   CComboBox   m_keltner_ma_type_combo;

   CTextLabel  m_donchian_period_label;
   CTextEdit   m_donchian_period_spin;

   CTextLabel  m_afast_period_label;
   CTextEdit   m_afast_period_spin;
   CTextLabel  m_afast_shift_label;
   CTextEdit   m_afast_shift_spin;
   CTextLabel  m_afast_ma_type_label;
   CComboBox   m_afast_ma_type_combo;
   CTextLabel  m_afast_price_label;
   CComboBox   m_afast_price_combo;

   CTextLabel  m_desvio_period_label;
   CTextEdit   m_desvio_period_spin;
   CTextLabel  m_desvio_ma_type_label;
   CComboBox   m_desvio_ma_type_combo;
   CTextLabel  m_desvio_price_label;
   CComboBox   m_desvio_price_combo;

   CTextLabel  m_atr_channel_period_label;
   CTextEdit   m_atr_channel_period_spin;
   CTextLabel  m_atr_channel_deviation_label;
   CTextEdit   m_atr_channel_deviation_spin;

   CTextLabel  m_ma_period_label;
   CTextEdit   m_ma_period_spin;
   CTextLabel  m_ma_shift_label;
   CTextEdit   m_ma_shift_spin;
   CTextLabel  m_ma_type_label;
   CComboBox   m_ma_type_combo;
   CTextLabel  m_ma_price_label;
   CComboBox   m_ma_price_combo;

   CTextLabel  m_bbands_period_label;
   CTextEdit   m_bbands_period_spin;
   CTextLabel  m_bbands_deviation_label;
   CTextEdit   m_bbands_deviation_spin;
   CTextLabel  m_bbands_shift_label;
   CTextEdit   m_bbands_shift_spin;
   CTextLabel  m_bbands_price_label;
   CComboBox   m_bbands_price_combo;

   CTextLabel  m_env_period_label;
   CTextEdit   m_env_period_spin;
   CTextLabel  m_env_shift_label;
   CTextEdit   m_env_shift_spin;
   CTextLabel  m_env_ma_type_label;
   CComboBox   m_env_ma_type_combo;
   CTextLabel  m_env_deviation_label;
   CTextEdit   m_env_deviation_spin;

   CTextLabel  m_stoch_k_label;
   CTextEdit   m_stoch_k_spin;
   CTextLabel  m_stoch_d_label;
   CTextEdit   m_stoch_d_spin;
   CTextLabel  m_stoch_slow_label;
   CTextEdit   m_stoch_slow_spin;
   CTextLabel  m_stoch_ma_type_label;
   CComboBox   m_stoch_ma_type_combo;
   CTextLabel  m_stoch_price_type_label;
   CComboBox   m_stoch_price_type_combo;

   CTextLabel  m_macd_fast_label;
   CTextEdit   m_macd_fast_spin;
   CTextLabel  m_macd_slow_label;
   CTextEdit   m_macd_slow_spin;
   CTextLabel  m_macd_signal_label;
   CTextEdit   m_macd_signal_spin;
   CTextLabel  m_macd_price_label;
   CComboBox   m_macd_price_combo;

   CTextLabel  m_ad_volume_label;
   CComboBox   m_ad_volume_combo;

   CTextLabel  m_mfi_period_label;
   CTextEdit   m_mfi_period_spin;
   CTextLabel  m_mfi_volume_label;
   CComboBox   m_mfi_volume_combo;

   CTextLabel  m_vidya_cmo_period_label;
   CTextEdit   m_vidya_cmo_period_spin;
   CTextLabel  m_vidya_ema_period_label;
   CTextEdit   m_vidya_ema_period_spin;
   CTextLabel  m_vidya_shift_label;
   CTextEdit   m_vidya_shift_spin;
   CTextLabel  m_vidya_price_label;
   CComboBox   m_vidya_price_combo;

   CTextLabel  m_tema_period_label;
   CTextEdit   m_tema_period_spin;
   CTextLabel  m_tema_shift_label;
   CTextEdit   m_tema_shift_spin;
   CTextLabel  m_tema_price_label;
   CComboBox   m_tema_price_combo;

   CTextLabel  m_frama_period_label;
   CTextEdit   m_frama_period_spin;
   CTextLabel  m_frama_shift_label;
   CTextEdit   m_frama_shift_spin;
   CTextLabel  m_frama_price_label;
   CComboBox   m_frama_price_combo;

   CTextLabel  m_trix_period_label;
   CTextEdit   m_trix_period_spin;
   CTextLabel  m_trix_price_label;
   CComboBox   m_trix_price_combo;

   CTextLabel  m_bears_power_period_label;
   CTextEdit   m_bears_power_period_spin;
   CTextLabel  m_bulls_power_period_label;
   CTextEdit   m_bulls_power_period_spin;
   CTextLabel  m_chaikin_fast_label;
   CTextEdit   m_chaikin_fast_spin;
   CTextLabel  m_chaikin_slow_label;
   CTextEdit   m_chaikin_slow_spin;
   CTextLabel  m_chaikin_ma_type_label;
   CComboBox   m_chaikin_ma_type_combo;
   CTextLabel  m_chaikin_volume_label;
   CComboBox   m_chaikin_volume_combo;
   CTextLabel  m_cci_period_label;
   CTextEdit   m_cci_period_spin;
   CTextLabel  m_cci_price_label;
   CComboBox   m_cci_price_combo;
   CTextLabel  m_demarker_period_label;
   CTextEdit   m_demarker_period_spin;
   CTextLabel  m_alligator_jaw_period_label;
   CTextEdit   m_alligator_jaw_period_spin;
   CTextLabel  m_alligator_jaw_shift_label;
   CTextEdit   m_alligator_jaw_shift_spin;
   CTextLabel  m_alligator_teeth_period_label;
   CTextEdit   m_alligator_teeth_period_spin;
   CTextLabel  m_alligator_teeth_shift_label;
   CTextEdit   m_alligator_teeth_shift_spin;
   CTextLabel  m_alligator_lips_period_label;
   CTextEdit   m_alligator_lips_period_spin;
   CTextLabel  m_alligator_lips_shift_label;
   CTextEdit   m_alligator_lips_shift_spin;
   CTextLabel  m_alligator_ma_type_label;
   CComboBox   m_alligator_ma_type_combo;
   CTextLabel  m_alligator_price_label;
   CComboBox   m_alligator_price_combo;

   CTextLabel  m_ichimoku_tenkan_label;
   CTextEdit   m_ichimoku_tenkan_spin;
   CTextLabel  m_ichimoku_kijun_label;
   CTextEdit   m_ichimoku_kijun_spin;
   CTextLabel  m_ichimoku_senkou_b_label;
   CTextEdit   m_ichimoku_senkou_b_spin;

   CTextLabel  m_adx_period_label;
   CTextEdit   m_adx_period_spin;
   CTextLabel  m_adx_wilder_period_label;
   CTextEdit   m_adx_wilder_period_spin;

   CTextLabel  m_gator_period_label;
   CTextEdit   m_gator_period_spin;
   CTextLabel  m_gator_jaw_period_label;
   CTextEdit   m_gator_jaw_period_spin;
   CTextLabel  m_gator_jaw_shift_label;
   CTextEdit   m_gator_jaw_shift_spin;
   CTextLabel  m_gator_teeth_period_label;
   CTextEdit   m_gator_teeth_period_spin;
   CTextLabel  m_gator_teeth_shift_label;
   CTextEdit   m_gator_teeth_shift_spin;
   CTextLabel  m_gator_lips_period_label;
   CTextEdit   m_gator_lips_period_spin;
   CTextLabel  m_gator_lips_shift_label;
   CTextEdit   m_gator_lips_shift_spin;
   CTextLabel  m_gator_ma_type_label;
   CComboBox   m_gator_ma_type_combo;
   CTextLabel  m_gator_price_label;
   CComboBox   m_gator_price_combo;

   CTextLabel  m_wpr_period_label;
   CTextEdit   m_wpr_period_spin;
   CTextLabel  m_wpr_deviation_label;
   CTextEdit   m_wpr_deviation_spin;
   CTextLabel  m_mfi_market_volume_label;
   CComboBox   m_mfi_market_volume_combo;

   CTextLabel  m_momentum_period_label;
   CTextEdit   m_momentum_period_spin;
   CTextLabel  m_momentum_price_label;
   CComboBox   m_momentum_price_combo;

   CTextLabel  m_rvi_period_label;
   CTextEdit   m_rvi_period_spin;

   CTextLabel  m_obv_volume_label;
   CComboBox   m_obv_volume_combo;

   CTextLabel  m_stddev_period_label;
   CTextEdit   m_stddev_period_spin;
   CTextLabel  m_stddev_ma_type_label;
   CComboBox   m_stddev_ma_type_combo;
   CTextLabel  m_stddev_price_label;
   CComboBox   m_stddev_price_combo;

   CTextLabel  m_volume_type_label;
   CComboBox   m_volume_type_combo;

   CTextLabel  m_atr_period_label;
   CTextEdit   m_atr_period_spin;

   CTextLabel  m_sar_step_label;
   CTextEdit   m_sar_step_spin;
   CTextLabel  m_sar_max_label;
   CTextEdit   m_sar_max_spin;

   string GetSpinValue(CTextEdit &spin) { return(spin.GetValue()); }
   void SetSpinValue(CTextEdit &spin,const string value) { spin.SetValue(value); if(!m_silent_updates) spin.Update(true); }
   int GetComboIndex(CComboBox &combo) { const int index=combo.GetListViewPointer().SelectedItemIndex(); return(index>=0 ? index : 0); }
   void SetComboIndex(CComboBox &combo,const int index) { combo.SelectItem(index>=0 ? index : 0); if(!m_silent_updates) combo.Update(true); }
   void HideFrame(CFrame &frame) { frame.Hide(); if(!m_silent_updates) frame.Update(true); }
   void ShowFrame(CFrame &frame) { frame.Show(); if(!m_silent_updates) frame.Update(true); }

   string IndicatorNameByCode(const int code) const
     {
      switch(code)
        {
         case 0: return("Nao usar");
         case 1: return("Keltner");
         case 2: return("Donchian");
         case 3: return("Regressao");
         case 4: return("Afastamento da media");
         case 5: return("Desvio medio");
         case 6: return("ATR com desvio");
         case 7: return("Media movel");
         case 8: return("Bandas de Bollinger");
         case 9: return("Envelopes");
         case 10: return("Estocastico");
         case 11: return("RSI");
         case 12: return("StdDev");
         case 13: return("Volume");
         case 14: return("ATR");
         case 15: return("Parabolic SAR");
         case 16: return("Fractal");
         case 17: return("OBV");
         case 18: return("MACD");
         case 19: return("Acumulacao/Distribuicao (A/D)");
         case 20: return("MFI (Money Flow Index)");
         case 21: return("Vidya");
         case 22: return("Tema");
         case 23: return("FRAMA");
         case 24: return("Trix");
         case 25: return("Bears Power");
         case 26: return("Bulls Power");
         case 27: return("Chaikin Oscilador");
         case 28: return("Accelerator Oscillator");
         case 29: return("Awesome Oscillator");
         case 30: return("CCI (Commodity Channel Index)");
         case 31: return("DeMarker");
         case 32: return("Alligator");
         case 33: return("Nuvem de Ichimoku");
         case 34: return("ADX (Average Direcional index)");
         case 35: return("ADX Wilder");
         case 36: return("Gator");
         case 37: return("Williams Percentual Range");
         case 38: return("Market Facilitation Index");
         case 39: return("Momentum");
         case 40: return("Relative Vigor Index");
        }
      return("Nao usar");
     }

   int DisplayIndexToIndicatorCode(const int display_index) const
     {
      switch(display_index)
        {
         case 0: return(0);
         case 1: return(28);
         case 2: return(19);
         case 3: return(34);
         case 4: return(35);
         case 5: return(4);
         case 6: return(32);
         case 7: return(14);
         case 8: return(6);
         case 9: return(29);
         case 10: return(8);
         case 11: return(25);
         case 12: return(26);
         case 13: return(30);
         case 14: return(27);
         case 15: return(31);
         case 16: return(2);
         case 17: return(5);
         case 18: return(9);
         case 19: return(10);
         case 20: return(23);
         case 21: return(16);
         case 22: return(36);
         case 23: return(1);
         case 24: return(18);
         case 25: return(38);
         case 26: return(7);
         case 27: return(20);
         case 28: return(39);
         case 29: return(33);
         case 30: return(17);
         case 31: return(15);
         case 32: return(3);
         case 33: return(40);
         case 34: return(11);
         case 35: return(12);
         case 36: return(22);
         case 37: return(24);
         case 38: return(21);
         case 39: return(13);
         case 40: return(37);
        }
      return(0);
     }

   int IndicatorCodeToDisplayIndex(const int indicator_code) const
     {
      switch(indicator_code)
        {
         case 0: return(0);
         case 28: return(1);
         case 19: return(2);
         case 34: return(3);
         case 35: return(4);
         case 4: return(5);
         case 32: return(6);
         case 14: return(7);
         case 6: return(8);
         case 29: return(9);
         case 8: return(10);
         case 25: return(11);
         case 26: return(12);
         case 30: return(13);
         case 27: return(14);
         case 31: return(15);
         case 2: return(16);
         case 5: return(17);
         case 9: return(18);
         case 10: return(19);
         case 23: return(20);
         case 16: return(21);
         case 36: return(22);
         case 1: return(23);
         case 18: return(24);
         case 38: return(25);
         case 7: return(26);
         case 20: return(27);
         case 39: return(28);
         case 33: return(29);
         case 17: return(30);
         case 15: return(31);
         case 3: return(32);
         case 40: return(33);
         case 11: return(34);
         case 12: return(35);
         case 22: return(36);
         case 24: return(37);
         case 21: return(38);
         case 13: return(39);
         case 37: return(40);
        }
      return(0);
     }

   bool CreateBodyLabel(CTextLabel &label,const string text,CElement &owner,const int x,const int y,const int width,const int height,const int font_size=10,const color text_color=clrNONE)
     {
      if(m_tabs==NULL)
         return(false);
      if(!m_host.CreateTextLabel(label,text,owner,m_window_index,*m_tabs,m_tab_index,x,y,width,height))
         return(false);
      label.FontSize(font_size);
      label.LabelColor(text_color==clrNONE ? V2_COLOR_TEXT_SECONDARY : text_color);
      return(true);
     }

   bool CreateComboControl(CComboBox &combo,CElement &owner,const int x,const int y,const int width,const int list_height,string &items[],const int selected_index,const color border)
     {
      if(m_tabs==NULL)
         return(false);
      combo.MainPointer(owner);
      (*m_tabs).AddToElementsArray(m_tab_index,combo);
      combo.ItemsTotal(ArraySize(items));
      for(int i=0;i<ArraySize(items);i++)
         combo.SetValue(i,items[i]);
      V2StyleCombo(combo,border,width,list_height,width-2);
      if(!combo.CreateComboBox("",x,y))
         return(false);
      CWndContainer::AddToElementsArray(m_window_index,combo);
      combo.SelectItem(V2ClampIndex(selected_index,0,ArraySize(items)-1));
      return(true);
     }

   bool CreateSpinControl(CTextEdit &spin,CElement &owner,const int x,const int y,const int width,const double max_value,const double min_value,const double step,const int digits,const string value,const color back,const color border)
     {
      if(m_tabs==NULL)
         return(false);
      spin.MainPointer(owner);
      (*m_tabs).AddToElementsArray(m_tab_index,spin);
      V2StyleSpin(spin,back,border,width,max_value,min_value,step,digits,value);
      if(!spin.CreateTextEdit("",x,y))
         return(false);
      CWndContainer::AddToElementsArray(m_window_index,spin);
      return(true);
     }

   void BuildIndicatorItems(string &items[])
     {
      ArrayResize(items,41);
      for(int i=0;i<41;i++)
         items[i]=IndicatorNameByCode(DisplayIndexToIndicatorCode(i));
     }

   void BuildPlaceholderText(const string &indicator_name,string &title_text,string &body_text)
     {
      if(indicator_name=="Nao usar")
        {
         title_text="Nao usar";
         body_text="Este slot nao participa da composicao do sinal enquanto estiver desativado.";
         return;
        }

      title_text=indicator_name;
      body_text="Os parametros de "+indicator_name+" serao portados aqui no proprio card deste slot.";
     }

   void HideLabel(CTextLabel &label) { label.Hide(); if(!m_silent_updates) label.Update(true); }
   void ShowLabel(CTextLabel &label) { label.Show(); if(!m_silent_updates) label.Update(true); }
   void HideCombo(CComboBox &combo) { combo.Hide(); if(!m_silent_updates) combo.Update(true); }
   void ShowCombo(CComboBox &combo) { combo.Show(); if(!m_silent_updates) combo.Update(true); }
   void HideSpin(CTextEdit &spin) { spin.Hide(); if(!m_silent_updates) spin.Update(true); }
   void ShowSpin(CTextEdit &spin) { spin.Show(); if(!m_silent_updates) spin.Update(true); }

   void HideAllContent(void)
     {
      HideLabel(m_view_title);
      HideLabel(m_view_note);

      HideLabel(m_rsi_period_label);
      HideSpin(m_rsi_period_spin);
      HideLabel(m_rsi_price_label);
      HideCombo(m_rsi_price_combo);

      HideLabel(m_reg_period_label);
      HideSpin(m_reg_period_spin);
      HideLabel(m_reg_ma_type_label);
      HideCombo(m_reg_ma_type_combo);
      HideLabel(m_reg_price_label);
      HideCombo(m_reg_price_combo);

      HideLabel(m_keltner_period_label);
      HideSpin(m_keltner_period_spin);
      HideLabel(m_keltner_deviation_label);
      HideSpin(m_keltner_deviation_spin);
      HideLabel(m_keltner_ma_type_label);
      HideCombo(m_keltner_ma_type_combo);

      HideLabel(m_donchian_period_label);
      HideSpin(m_donchian_period_spin);

      HideLabel(m_afast_period_label);
      HideSpin(m_afast_period_spin);
      HideLabel(m_afast_shift_label);
      HideSpin(m_afast_shift_spin);
      HideLabel(m_afast_ma_type_label);
      HideCombo(m_afast_ma_type_combo);
      HideLabel(m_afast_price_label);
      HideCombo(m_afast_price_combo);

      HideLabel(m_desvio_period_label);
      HideSpin(m_desvio_period_spin);
      HideLabel(m_desvio_ma_type_label);
      HideCombo(m_desvio_ma_type_combo);
      HideLabel(m_desvio_price_label);
      HideCombo(m_desvio_price_combo);

      HideLabel(m_atr_channel_period_label);
      HideSpin(m_atr_channel_period_spin);
      HideLabel(m_atr_channel_deviation_label);
      HideSpin(m_atr_channel_deviation_spin);

      HideLabel(m_ma_period_label);
      HideSpin(m_ma_period_spin);
      HideLabel(m_ma_shift_label);
      HideSpin(m_ma_shift_spin);
      HideLabel(m_ma_type_label);
      HideCombo(m_ma_type_combo);
      HideLabel(m_ma_price_label);
      HideCombo(m_ma_price_combo);

      HideLabel(m_bbands_period_label);
      HideSpin(m_bbands_period_spin);
      HideLabel(m_bbands_deviation_label);
      HideSpin(m_bbands_deviation_spin);
      HideLabel(m_bbands_shift_label);
      HideSpin(m_bbands_shift_spin);
      HideLabel(m_bbands_price_label);
      HideCombo(m_bbands_price_combo);

      HideLabel(m_env_period_label);
      HideSpin(m_env_period_spin);
      HideLabel(m_env_shift_label);
      HideSpin(m_env_shift_spin);
      HideLabel(m_env_ma_type_label);
      HideCombo(m_env_ma_type_combo);
      HideLabel(m_env_deviation_label);
      HideSpin(m_env_deviation_spin);

      HideLabel(m_stoch_k_label);
      HideSpin(m_stoch_k_spin);
      HideLabel(m_stoch_d_label);
      HideSpin(m_stoch_d_spin);
      HideLabel(m_stoch_slow_label);
      HideSpin(m_stoch_slow_spin);
      HideLabel(m_stoch_ma_type_label);
      HideCombo(m_stoch_ma_type_combo);
      HideLabel(m_stoch_price_type_label);
      HideCombo(m_stoch_price_type_combo);

      HideLabel(m_macd_fast_label);
      HideSpin(m_macd_fast_spin);
      HideLabel(m_macd_slow_label);
      HideSpin(m_macd_slow_spin);
      HideLabel(m_macd_signal_label);
      HideSpin(m_macd_signal_spin);
      HideLabel(m_macd_price_label);
      HideCombo(m_macd_price_combo);

      HideLabel(m_ad_volume_label);
      HideCombo(m_ad_volume_combo);

      HideLabel(m_mfi_period_label);
      HideSpin(m_mfi_period_spin);
      HideLabel(m_mfi_volume_label);
      HideCombo(m_mfi_volume_combo);

      HideLabel(m_vidya_cmo_period_label);
      HideSpin(m_vidya_cmo_period_spin);
      HideLabel(m_vidya_ema_period_label);
      HideSpin(m_vidya_ema_period_spin);
      HideLabel(m_vidya_shift_label);
      HideSpin(m_vidya_shift_spin);
      HideLabel(m_vidya_price_label);
      HideCombo(m_vidya_price_combo);

      HideLabel(m_tema_period_label);
      HideSpin(m_tema_period_spin);
      HideLabel(m_tema_shift_label);
      HideSpin(m_tema_shift_spin);
      HideLabel(m_tema_price_label);
      HideCombo(m_tema_price_combo);

      HideLabel(m_frama_period_label);
      HideSpin(m_frama_period_spin);
      HideLabel(m_frama_shift_label);
      HideSpin(m_frama_shift_spin);
      HideLabel(m_frama_price_label);
      HideCombo(m_frama_price_combo);

      HideLabel(m_trix_period_label);
      HideSpin(m_trix_period_spin);
      HideLabel(m_trix_price_label);
      HideCombo(m_trix_price_combo);

      HideLabel(m_bears_power_period_label);
      HideSpin(m_bears_power_period_spin);
      HideLabel(m_bulls_power_period_label);
      HideSpin(m_bulls_power_period_spin);
      HideLabel(m_chaikin_fast_label);
      HideSpin(m_chaikin_fast_spin);
      HideLabel(m_chaikin_slow_label);
      HideSpin(m_chaikin_slow_spin);
      HideLabel(m_chaikin_ma_type_label);
      HideCombo(m_chaikin_ma_type_combo);
      HideLabel(m_chaikin_volume_label);
      HideCombo(m_chaikin_volume_combo);
      HideLabel(m_cci_period_label);
      HideSpin(m_cci_period_spin);
      HideLabel(m_cci_price_label);
      HideCombo(m_cci_price_combo);
      HideLabel(m_demarker_period_label);
      HideSpin(m_demarker_period_spin);
      HideLabel(m_alligator_jaw_period_label);
      HideSpin(m_alligator_jaw_period_spin);
      HideLabel(m_alligator_jaw_shift_label);
      HideSpin(m_alligator_jaw_shift_spin);
      HideLabel(m_alligator_teeth_period_label);
      HideSpin(m_alligator_teeth_period_spin);
      HideLabel(m_alligator_teeth_shift_label);
      HideSpin(m_alligator_teeth_shift_spin);
      HideLabel(m_alligator_lips_period_label);
      HideSpin(m_alligator_lips_period_spin);
      HideLabel(m_alligator_lips_shift_label);
      HideSpin(m_alligator_lips_shift_spin);
      HideLabel(m_alligator_ma_type_label);
      HideCombo(m_alligator_ma_type_combo);
      HideLabel(m_alligator_price_label);
      HideCombo(m_alligator_price_combo);

      HideLabel(m_ichimoku_tenkan_label);
      HideSpin(m_ichimoku_tenkan_spin);
      HideLabel(m_ichimoku_kijun_label);
      HideSpin(m_ichimoku_kijun_spin);
      HideLabel(m_ichimoku_senkou_b_label);
      HideSpin(m_ichimoku_senkou_b_spin);

      HideLabel(m_adx_period_label);
      HideSpin(m_adx_period_spin);
      HideLabel(m_adx_wilder_period_label);
      HideSpin(m_adx_wilder_period_spin);

      HideLabel(m_gator_period_label);
      HideSpin(m_gator_period_spin);
      HideLabel(m_gator_jaw_period_label);
      HideSpin(m_gator_jaw_period_spin);
      HideLabel(m_gator_jaw_shift_label);
      HideSpin(m_gator_jaw_shift_spin);
      HideLabel(m_gator_teeth_period_label);
      HideSpin(m_gator_teeth_period_spin);
      HideLabel(m_gator_teeth_shift_label);
      HideSpin(m_gator_teeth_shift_spin);
      HideLabel(m_gator_lips_period_label);
      HideSpin(m_gator_lips_period_spin);
      HideLabel(m_gator_lips_shift_label);
      HideSpin(m_gator_lips_shift_spin);
      HideLabel(m_gator_ma_type_label);
      HideCombo(m_gator_ma_type_combo);
      HideLabel(m_gator_price_label);
      HideCombo(m_gator_price_combo);

      HideLabel(m_wpr_period_label);
      HideSpin(m_wpr_period_spin);
      HideLabel(m_wpr_deviation_label);
      HideSpin(m_wpr_deviation_spin);
      HideLabel(m_mfi_market_volume_label);
      HideCombo(m_mfi_market_volume_combo);
      HideLabel(m_momentum_period_label);
      HideSpin(m_momentum_period_spin);
      HideLabel(m_momentum_price_label);
      HideCombo(m_momentum_price_combo);
      HideLabel(m_rvi_period_label);
      HideSpin(m_rvi_period_spin);

      HideLabel(m_obv_volume_label);
      HideCombo(m_obv_volume_combo);

      HideLabel(m_stddev_period_label);
      HideSpin(m_stddev_period_spin);
      HideLabel(m_stddev_ma_type_label);
      HideCombo(m_stddev_ma_type_combo);
      HideLabel(m_stddev_price_label);
      HideCombo(m_stddev_price_combo);

      HideLabel(m_volume_type_label);
      HideCombo(m_volume_type_combo);

      HideLabel(m_atr_period_label);
      HideSpin(m_atr_period_spin);

      HideLabel(m_sar_step_label);
      HideSpin(m_sar_step_spin);
      HideLabel(m_sar_max_label);
      HideSpin(m_sar_max_spin);
    }

   void SetViewText(const string title,const string note)
     {
      m_view_title.LabelText(title);
      m_view_title.Update(true);
      m_view_note.LabelText(note);
      m_view_note.Update(true);
     }

   void ShowPlaceholderView(const string title,const string body)
     {
      HideAllContent();
      SetViewText(title,body);
      ShowLabel(m_view_title);
      ShowLabel(m_view_note);
     }

   void ShowMediaMovelView(void)
     {
      HideAllContent();
      SetViewText("Media movel","");
      ShowLabel(m_view_title);

      ShowLabel(m_ma_period_label);
      ShowSpin(m_ma_period_spin);
      ShowLabel(m_ma_shift_label);
      ShowSpin(m_ma_shift_spin);
      ShowLabel(m_ma_type_label);
      ShowCombo(m_ma_type_combo);
      ShowLabel(m_ma_price_label);
      ShowCombo(m_ma_price_combo);
     }

   void ShowRSIView(void)
     {
      HideAllContent();
      SetViewText("RSI","");
      ShowLabel(m_view_title);

      ShowLabel(m_rsi_period_label);
      ShowSpin(m_rsi_period_spin);
      ShowLabel(m_rsi_price_label);
      ShowCombo(m_rsi_price_combo);
     }

   void ShowFractalView(void)
     {
      ShowPlaceholderView("Fractal","Sem parametros.");
     }

   void ShowDonchianView(void)
     {
      HideAllContent();
      SetViewText("Donchian","");
      ShowLabel(m_view_title);
      ShowLabel(m_donchian_period_label);
      ShowSpin(m_donchian_period_spin);
     }

   void ShowAfastamentoView(void)
     {
      HideAllContent();
      SetViewText("Afastamento da media","");
      ShowLabel(m_view_title);
      ShowLabel(m_afast_period_label);
      ShowSpin(m_afast_period_spin);
      ShowLabel(m_afast_shift_label);
      ShowSpin(m_afast_shift_spin);
      ShowLabel(m_afast_ma_type_label);
      ShowCombo(m_afast_ma_type_combo);
      ShowLabel(m_afast_price_label);
      ShowCombo(m_afast_price_combo);
     }

   void ShowDesvioMedioView(void)
     {
      HideAllContent();
      SetViewText("Desvio medio","");
      ShowLabel(m_view_title);
      ShowLabel(m_desvio_period_label);
      ShowSpin(m_desvio_period_spin);
      ShowLabel(m_desvio_ma_type_label);
      ShowCombo(m_desvio_ma_type_combo);
      ShowLabel(m_desvio_price_label);
      ShowCombo(m_desvio_price_combo);
     }

   void ShowAtrChannelView(void)
     {
      HideAllContent();
      SetViewText("ATR com desvio","");
      ShowLabel(m_view_title);
      ShowLabel(m_atr_channel_period_label);
      ShowSpin(m_atr_channel_period_spin);
      ShowLabel(m_atr_channel_deviation_label);
      ShowSpin(m_atr_channel_deviation_spin);
     }

   void ShowRegressaoView(void)
     {
      HideAllContent();
      SetViewText("Regressao linear","");
      ShowLabel(m_view_title);

      ShowLabel(m_reg_period_label);
      ShowSpin(m_reg_period_spin);
      ShowLabel(m_reg_ma_type_label);
      ShowCombo(m_reg_ma_type_combo);
      ShowLabel(m_reg_price_label);
      ShowCombo(m_reg_price_combo);
     }

   void ShowKeltnerView(void)
     {
      HideAllContent();
      SetViewText("Keltner","");
      ShowLabel(m_view_title);

      ShowLabel(m_keltner_period_label);
      ShowSpin(m_keltner_period_spin);
      ShowLabel(m_keltner_deviation_label);
      ShowSpin(m_keltner_deviation_spin);
      ShowLabel(m_keltner_ma_type_label);
      ShowCombo(m_keltner_ma_type_combo);
     }

   void ShowBandasView(void)
     {
      HideAllContent();
      SetViewText("Bandas de Bollinger","");
      ShowLabel(m_view_title);
      ShowLabel(m_bbands_period_label);
      ShowSpin(m_bbands_period_spin);
      ShowLabel(m_bbands_deviation_label);
      ShowSpin(m_bbands_deviation_spin);
      ShowLabel(m_bbands_shift_label);
      ShowSpin(m_bbands_shift_spin);
      ShowLabel(m_bbands_price_label);
      ShowCombo(m_bbands_price_combo);
     }

   void ShowEnvelopesView(void)
     {
      HideAllContent();
      SetViewText("Envelopes","");
      ShowLabel(m_view_title);
      ShowLabel(m_env_period_label);
      ShowSpin(m_env_period_spin);
      ShowLabel(m_env_shift_label);
      ShowSpin(m_env_shift_spin);
      ShowLabel(m_env_ma_type_label);
      ShowCombo(m_env_ma_type_combo);
      ShowLabel(m_env_deviation_label);
      ShowSpin(m_env_deviation_spin);
     }

   void ShowEstocasticoView(void)
     {
      HideAllContent();
      SetViewText("Estocastico","");
      ShowLabel(m_view_title);
      ShowLabel(m_stoch_k_label);
      ShowSpin(m_stoch_k_spin);
      ShowLabel(m_stoch_d_label);
      ShowSpin(m_stoch_d_spin);
      ShowLabel(m_stoch_slow_label);
      ShowSpin(m_stoch_slow_spin);
      ShowLabel(m_stoch_ma_type_label);
      ShowCombo(m_stoch_ma_type_combo);
      ShowLabel(m_stoch_price_type_label);
      ShowCombo(m_stoch_price_type_combo);
     }

   void ShowMACDView(void)
     {
      HideAllContent();
      SetViewText("MACD","");
      ShowLabel(m_view_title);

      ShowLabel(m_macd_fast_label);
      ShowSpin(m_macd_fast_spin);
      ShowLabel(m_macd_slow_label);
      ShowSpin(m_macd_slow_spin);
      ShowLabel(m_macd_signal_label);
      ShowSpin(m_macd_signal_spin);
      ShowLabel(m_macd_price_label);
      ShowCombo(m_macd_price_combo);
     }

   void ShowOBVView(void)
     {
      HideAllContent();
      SetViewText("OBV","");
      ShowLabel(m_view_title);

      ShowLabel(m_obv_volume_label);
      ShowCombo(m_obv_volume_combo);
     }

   void ShowAccumDistView(void)
     {
      HideAllContent();
      SetViewText("Acumulacao/Distribuicao (A/D)","");
      ShowLabel(m_view_title);

      ShowLabel(m_ad_volume_label);
      ShowCombo(m_ad_volume_combo);
     }

   void ShowMFIView(void)
     {
      HideAllContent();
      SetViewText("MFI (Money Flow Index)","");
      ShowLabel(m_view_title);

      ShowLabel(m_mfi_period_label);
      ShowSpin(m_mfi_period_spin);
      ShowLabel(m_mfi_volume_label);
      ShowCombo(m_mfi_volume_combo);
     }

   void ShowVidyaView(void)
     {
      HideAllContent();
      SetViewText("Vidya","");
      ShowLabel(m_view_title);

      ShowLabel(m_vidya_cmo_period_label);
      ShowSpin(m_vidya_cmo_period_spin);
      ShowLabel(m_vidya_ema_period_label);
      ShowSpin(m_vidya_ema_period_spin);
      ShowLabel(m_vidya_shift_label);
      ShowSpin(m_vidya_shift_spin);
      ShowLabel(m_vidya_price_label);
      ShowCombo(m_vidya_price_combo);
     }

   void ShowTemaView(void)
     {
      HideAllContent();
      SetViewText("Tema","");
      ShowLabel(m_view_title);

      ShowLabel(m_tema_period_label);
      ShowSpin(m_tema_period_spin);
      ShowLabel(m_tema_shift_label);
      ShowSpin(m_tema_shift_spin);
      ShowLabel(m_tema_price_label);
      ShowCombo(m_tema_price_combo);
     }

   void ShowFRAMAView(void)
     {
      HideAllContent();
      SetViewText("FRAMA","");
      ShowLabel(m_view_title);

      ShowLabel(m_frama_period_label);
      ShowSpin(m_frama_period_spin);
      ShowLabel(m_frama_shift_label);
      ShowSpin(m_frama_shift_spin);
      ShowLabel(m_frama_price_label);
      ShowCombo(m_frama_price_combo);
     }

   void ShowTrixView(void)
     {
      HideAllContent();
      SetViewText("Trix","");
      ShowLabel(m_view_title);

      ShowLabel(m_trix_period_label);
      ShowSpin(m_trix_period_spin);
      ShowLabel(m_trix_price_label);
      ShowCombo(m_trix_price_combo);
     }

   void ShowBearsPowerView(void)
     {
      HideAllContent();
      SetViewText("Bears Power","");
      ShowLabel(m_view_title);

      ShowLabel(m_bears_power_period_label);
      ShowSpin(m_bears_power_period_spin);
     }

   void ShowBullsPowerView(void)
     {
      HideAllContent();
      SetViewText("Bulls Power","");
      ShowLabel(m_view_title);

      ShowLabel(m_bulls_power_period_label);
      ShowSpin(m_bulls_power_period_spin);
     }

   void ShowChaikinOsciladorView(void)
     {
      HideAllContent();
      SetViewText("Chaikin Oscilador","");
      ShowLabel(m_view_title);

      ShowLabel(m_chaikin_fast_label);
      ShowSpin(m_chaikin_fast_spin);
      ShowLabel(m_chaikin_slow_label);
      ShowSpin(m_chaikin_slow_spin);
      ShowLabel(m_chaikin_ma_type_label);
      ShowCombo(m_chaikin_ma_type_combo);
      ShowLabel(m_chaikin_volume_label);
      ShowCombo(m_chaikin_volume_combo);
     }

   void ShowAcceleratorOscillatorView(void)
     {
      ShowPlaceholderView("Accelerator Oscillator","Sem parametros.");
     }

   void ShowAwesomeOscillatorView(void)
     {
      ShowPlaceholderView("Awesome Oscillator","Sem parametros.");
     }

   void ShowCCIView(void)
     {
      HideAllContent();
      SetViewText("CCI (Commodity Channel Index)","");
      ShowLabel(m_view_title);

      ShowLabel(m_cci_period_label);
      ShowSpin(m_cci_period_spin);
      ShowLabel(m_cci_price_label);
      ShowCombo(m_cci_price_combo);
     }

   void ShowDeMarkerView(void)
     {
      HideAllContent();
      SetViewText("DeMarker","");
      ShowLabel(m_view_title);

      ShowLabel(m_demarker_period_label);
      ShowSpin(m_demarker_period_spin);
     }

   void ShowAlligatorView(void)
     {
      HideAllContent();
      SetViewText("Alligator","");
      ShowLabel(m_view_title);

      ShowLabel(m_alligator_jaw_period_label);
      ShowSpin(m_alligator_jaw_period_spin);
      ShowLabel(m_alligator_jaw_shift_label);
      ShowSpin(m_alligator_jaw_shift_spin);
      ShowLabel(m_alligator_teeth_period_label);
      ShowSpin(m_alligator_teeth_period_spin);
      ShowLabel(m_alligator_teeth_shift_label);
      ShowSpin(m_alligator_teeth_shift_spin);
      ShowLabel(m_alligator_lips_period_label);
      ShowSpin(m_alligator_lips_period_spin);
      ShowLabel(m_alligator_lips_shift_label);
      ShowSpin(m_alligator_lips_shift_spin);
      ShowLabel(m_alligator_ma_type_label);
      ShowCombo(m_alligator_ma_type_combo);
      ShowLabel(m_alligator_price_label);
      ShowCombo(m_alligator_price_combo);
     }

   void ShowIchimokuView(void)
     {
      HideAllContent();
      SetViewText("Nuvem de Ichimoku","");
      ShowLabel(m_view_title);
      ShowLabel(m_ichimoku_tenkan_label);
      ShowSpin(m_ichimoku_tenkan_spin);
      ShowLabel(m_ichimoku_kijun_label);
      ShowSpin(m_ichimoku_kijun_spin);
      ShowLabel(m_ichimoku_senkou_b_label);
      ShowSpin(m_ichimoku_senkou_b_spin);
     }

   void ShowADXView(void)
     {
      HideAllContent();
      SetViewText("ADX (Average Direcional index)","");
      ShowLabel(m_view_title);
      ShowLabel(m_adx_period_label);
      ShowSpin(m_adx_period_spin);
     }

   void ShowADXWilderView(void)
     {
      HideAllContent();
      SetViewText("ADX Wilder","");
      ShowLabel(m_view_title);
      ShowLabel(m_adx_wilder_period_label);
      ShowSpin(m_adx_wilder_period_spin);
     }

   void ShowGatorView(void)
     {
      HideAllContent();
      SetViewText("Gator","");
      ShowLabel(m_view_title);
      ShowLabel(m_gator_period_label);
      ShowSpin(m_gator_period_spin);
      ShowLabel(m_gator_jaw_period_label);
      ShowSpin(m_gator_jaw_period_spin);
      ShowLabel(m_gator_jaw_shift_label);
      ShowSpin(m_gator_jaw_shift_spin);
      ShowLabel(m_gator_teeth_period_label);
      ShowSpin(m_gator_teeth_period_spin);
      ShowLabel(m_gator_teeth_shift_label);
      ShowSpin(m_gator_teeth_shift_spin);
      ShowLabel(m_gator_lips_period_label);
      ShowSpin(m_gator_lips_period_spin);
      ShowLabel(m_gator_lips_shift_label);
      ShowSpin(m_gator_lips_shift_spin);
      ShowLabel(m_gator_ma_type_label);
      ShowCombo(m_gator_ma_type_combo);
      ShowLabel(m_gator_price_label);
      ShowCombo(m_gator_price_combo);
     }

   void ShowWPRView(void)
     {
      HideAllContent();
      SetViewText("Williams Percentual Range","");
      ShowLabel(m_view_title);
      ShowLabel(m_wpr_period_label);
      ShowSpin(m_wpr_period_spin);
      ShowLabel(m_wpr_deviation_label);
      ShowSpin(m_wpr_deviation_spin);
     }

   void ShowMarketFacilitationIndexView(void)
     {
      HideAllContent();
      SetViewText("Market Facilitation Index","");
      ShowLabel(m_view_title);
      ShowLabel(m_mfi_market_volume_label);
      ShowCombo(m_mfi_market_volume_combo);
     }

   void ShowMomentumView(void)
     {
      HideAllContent();
      SetViewText("Momentum","");
      ShowLabel(m_view_title);
      ShowLabel(m_momentum_period_label);
      ShowSpin(m_momentum_period_spin);
      ShowLabel(m_momentum_price_label);
      ShowCombo(m_momentum_price_combo);
     }

   void ShowRVIView(void)
     {
      HideAllContent();
      SetViewText("Relative Vigor Index","");
      ShowLabel(m_view_title);
      ShowLabel(m_rvi_period_label);
      ShowSpin(m_rvi_period_spin);
     }

   void ShowStdDevView(void)
     {
      HideAllContent();
      SetViewText("StdDev","");
      ShowLabel(m_view_title);

      ShowLabel(m_stddev_period_label);
      ShowSpin(m_stddev_period_spin);
      ShowLabel(m_stddev_ma_type_label);
      ShowCombo(m_stddev_ma_type_combo);
      ShowLabel(m_stddev_price_label);
      ShowCombo(m_stddev_price_combo);
     }

   void ShowVolumeView(void)
     {
      HideAllContent();
      SetViewText("Volume","");
      ShowLabel(m_view_title);
      ShowLabel(m_volume_type_label);
      ShowCombo(m_volume_type_combo);
     }

   void ShowATRView(void)
     {
      HideAllContent();
      SetViewText("ATR","");
      ShowLabel(m_view_title);
      ShowLabel(m_atr_period_label);
      ShowSpin(m_atr_period_spin);
     }

   void ShowParabolicSarView(void)
     {
      HideAllContent();
      SetViewText("Parabolic SAR","");
      ShowLabel(m_view_title);
      ShowLabel(m_sar_step_label);
      ShowSpin(m_sar_step_spin);
      ShowLabel(m_sar_max_label);
      ShowSpin(m_sar_max_spin);
     }

   void ApplySelectedIndicator(const int selected)
     {
      string items[];
      const int indicator_code=V2ClampIndex(selected,0,40);
      const string indicator_name=IndicatorNameByCode(indicator_code);

      if(indicator_code==1)
        {
         ShowKeltnerView();
         return;
        }
      if(indicator_code==3)
        {
         ShowRegressaoView();
         return;
        }
      if(indicator_code==2)
        {
         ShowDonchianView();
         return;
        }
      if(indicator_code==4)
        {
         ShowAfastamentoView();
         return;
        }
      if(indicator_code==5)
        {
         ShowDesvioMedioView();
         return;
        }
      if(indicator_code==6)
        {
         ShowAtrChannelView();
         return;
        }
      if(indicator_code==7)
        {
         ShowMediaMovelView();
         return;
        }
      if(indicator_code==8)
        {
         ShowBandasView();
         return;
        }
      if(indicator_code==9)
        {
         ShowEnvelopesView();
         return;
        }
      if(indicator_code==10)
        {
         ShowEstocasticoView();
         return;
        }
      if(indicator_code==11)
        {
         ShowRSIView();
         return;
        }
      if(indicator_code==12)
        {
         ShowStdDevView();
         return;
        }
      if(indicator_code==13)
        {
         ShowVolumeView();
         return;
        }
      if(indicator_code==14)
        {
         ShowATRView();
         return;
        }
      if(indicator_code==15)
        {
         ShowParabolicSarView();
         return;
        }
      if(indicator_code==16)
        {
         ShowFractalView();
         return;
        }
      if(indicator_code==17)
        {
         ShowOBVView();
         return;
        }
      if(indicator_code==18)
        {
         ShowMACDView();
         return;
        }
      if(indicator_code==19)
        {
         ShowAccumDistView();
         return;
        }
      if(indicator_code==20)
        {
         ShowMFIView();
         return;
        }
      if(indicator_code==21)
        {
         ShowVidyaView();
         return;
        }
      if(indicator_code==22)
        {
         ShowTemaView();
         return;
        }
      if(indicator_code==23)
        {
         ShowFRAMAView();
         return;
        }
      if(indicator_code==24)
        {
         ShowTrixView();
         return;
        }
      if(indicator_code==25)
        {
         ShowBearsPowerView();
         return;
        }
      if(indicator_code==26)
        {
         ShowBullsPowerView();
         return;
        }
      if(indicator_code==27)
        {
         ShowChaikinOsciladorView();
         return;
        }
      if(indicator_code==28)
        {
         ShowAcceleratorOscillatorView();
         return;
        }
      if(indicator_code==29)
        {
         ShowAwesomeOscillatorView();
         return;
        }
      if(indicator_code==30)
        {
         ShowCCIView();
         return;
        }
      if(indicator_code==31)
        {
         ShowDeMarkerView();
         return;
        }
      if(indicator_code==32)
        {
         ShowAlligatorView();
         return;
        }
      if(indicator_code==33)
        {
         ShowIchimokuView();
         return;
        }
      if(indicator_code==34)
        {
         ShowADXView();
         return;
        }
      if(indicator_code==35)
        {
         ShowADXWilderView();
         return;
        }
      if(indicator_code==36)
        {
         ShowGatorView();
         return;
        }
      if(indicator_code==37)
        {
         ShowWPRView();
         return;
        }
      if(indicator_code==38)
        {
         ShowMarketFacilitationIndexView();
         return;
        }
      if(indicator_code==39)
        {
         ShowMomentumView();
         return;
        }
      if(indicator_code==40)
        {
         ShowRVIView();
         return;
        }

      string placeholder_title;
      string placeholder_body;
      BuildPlaceholderText(indicator_name,placeholder_title,placeholder_body);
      ShowPlaceholderView(placeholder_title,placeholder_body);
     }

   void HideCardContent(void)
     {
      HideAllContent();
     }

   void HideSlot(void)
     {
      HideCardContent();
      HideFrame(m_body);
      HideCombo(m_combo);
      HideLabel(m_combo_label);
      HideFrame(m_card);
     }

   void ShowSlot(void)
     {
      ShowFrame(m_card);
      ShowLabel(m_combo_label);
      ShowCombo(m_combo);
      ShowFrame(m_body);
     }

public:
                     CTab8MontarSlotCard(void) : m_host(NULL), m_tabs(NULL), m_created(false), m_is_active(false), m_silent_updates(false), m_embedded_mode(false), m_window_index(-1), m_tab_index(-1), m_slot_index(-1), m_last_selected_index(-1) {}

   bool Create(CWndCreate &host,const int window_index,CTabs &tabs,const int tab_index,const int slot_index,
               const int x,const int y,const int w,const int h,const bool embedded_mode=false)
     {
      if(m_created)
         return(true);

      m_host=&host;
      m_tabs=&tabs;
      m_window_index=window_index;
      m_tab_index=tab_index;
      m_slot_index=slot_index;
      m_embedded_mode=embedded_mode;

      const color card_back=V2_COLOR_CARD_BACK;
      const color card_border=V2_COLOR_CARD_BORDER;
      const color field_border=V2_COLOR_FIELD_BORDER;
      const color sub_back=V2_COLOR_SURFACE;
      const int frame_pad=(m_embedded_mode ? 8 : 16);
      const int outer_pad=(m_embedded_mode ? 0 : 8);
      const int body_w=(m_embedded_mode ? w-(frame_pad*2) : w-(outer_pad*2));
      const int body_x=(m_embedded_mode ? x+frame_pad : x+outer_pad);
      const int body_y=(m_embedded_mode ? y+50 : y+60);
      const int body_h=(m_embedded_mode ? h-50 : h-68);
      const int content_x=(m_embedded_mode ? 8 : 12);
      const int content_y=8;
      const int inner_w=body_w-(content_x*2);

      if(!V2CreateCard(*m_host,m_card,tabs,m_window_index,m_tab_index,x,y,w,h,card_back,(m_embedded_mode ? card_back : card_border)))
         return(false);
      HideFrame(m_card);

      if(!V2CreateFieldLabel(*m_host,m_combo_label,"Indicador",m_card,tabs,m_window_index,m_tab_index,frame_pad,(m_embedded_mode ? 2 : 24),w-(frame_pad*2),16))
         return(false);
      HideLabel(m_combo_label);

      string indicator_items[];
      BuildIndicatorItems(indicator_items);
      if(!CreateComboControl(m_combo,m_card,frame_pad,(m_embedded_mode ? 16 : 38),w-(frame_pad*2),220,indicator_items,0,field_border))
         return(false);
      HideCombo(m_combo);

      if(!V2CreateCard(*m_host,m_body,tabs,m_window_index,m_tab_index,body_x,body_y,body_w,body_h,sub_back,card_border))
         return(false);
      HideFrame(m_body);

      if(!CreateBodyLabel(m_view_title,"Nao usar",m_body,content_x,content_y,inner_w,16,11,V2_COLOR_TEXT_PRIMARY))
         return(false);
      if(!CreateBodyLabel(m_view_note,"Este slot nao participa da composicao do sinal enquanto estiver desativado.",m_body,content_x,content_y+24,inner_w,72,10,V2_COLOR_TEXT_SECONDARY))
         return(false);

      string price_items[];
      ArrayResize(price_items,7);
      price_items[0]="Fechamento";
      price_items[1]="Abertura";
      price_items[2]="Maximo";
      price_items[3]="Minimo";
      price_items[4]="Mediano";
      price_items[5]="Tipico";
      price_items[6]="Medio";

      string ma_type_items[];
      ArrayResize(ma_type_items,5);
      ma_type_items[0]="Simples";
      ma_type_items[1]="Exponencial";
      ma_type_items[2]="Suavizada";
      ma_type_items[3]="Linear ponderada";
      ma_type_items[4]="Smoothed";

      string volume_items[];
      ArrayResize(volume_items,2);
      volume_items[0]="Tick";
      volume_items[1]="Real";

      string stoch_type_items[];
      ArrayResize(stoch_type_items,2);
      stoch_type_items[0]="Minimo/Maximo";
      stoch_type_items[1]="Fechamento/Fechamento";

      int y_cursor=content_y+18;
      if(!CreateBodyLabel(m_keltner_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_keltner_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"20",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_keltner_deviation_label,"Desvio",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_keltner_deviation_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,0.1,1,"2.0",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_keltner_ma_type_label,"Tipo de media",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_keltner_ma_type_combo,m_body,content_x,y_cursor,inner_w,140,ma_type_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_donchian_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_donchian_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"21",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_afast_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_afast_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_afast_shift_label,"Deslocamento",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_afast_shift_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"0",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_afast_ma_type_label,"Tipo de media",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_afast_ma_type_combo,m_body,content_x,y_cursor,inner_w,140,ma_type_items,0,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_afast_price_label,"Modo de preco",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_afast_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_desvio_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_desvio_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_desvio_ma_type_label,"Tipo de media",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_desvio_ma_type_combo,m_body,content_x,y_cursor,inner_w,140,ma_type_items,0,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_desvio_price_label,"Modo de fechamento",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_desvio_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_atr_channel_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_atr_channel_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"20",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_atr_channel_deviation_label,"Desvio",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_atr_channel_deviation_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"0",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_ma_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_ma_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_ma_shift_label,"Deslocamento",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_ma_shift_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"0",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_ma_type_label,"Tipo de media",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_ma_type_combo,m_body,content_x,y_cursor,inner_w,120,ma_type_items,0,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_ma_price_label,"Modo de preco",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_ma_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_bbands_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_bbands_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_bbands_deviation_label,"Desvio",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_bbands_deviation_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,0.1,1,"2.0",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_bbands_shift_label,"Deslocamento",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_bbands_shift_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"0",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_bbands_price_label,"Modo de preco",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_bbands_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_env_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_env_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_env_shift_label,"Deslocamento",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_env_shift_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"0",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_env_ma_type_label,"Tipo de media",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_env_ma_type_combo,m_body,content_x,y_cursor,inner_w,140,ma_type_items,0,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_env_deviation_label,"Desvio",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_env_deviation_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,0.1,1,"0.0",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      const int stoch_col_gap=10;
      const int stoch_half_w=(inner_w-stoch_col_gap)/2;
      const int stoch_right_x=content_x+stoch_half_w+stoch_col_gap;

      if(!CreateBodyLabel(m_stoch_k_label,"K periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_stoch_k_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"5",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_stoch_d_label,"D periodo",m_body,content_x,y_cursor,stoch_half_w,16))
         return(false);
      if(!CreateBodyLabel(m_stoch_slow_label,"Lentidao",m_body,stoch_right_x,y_cursor,stoch_half_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_stoch_d_spin,m_body,content_x,y_cursor,stoch_half_w,9999.0,1.0,1.0,0,"3",sub_back,field_border))
         return(false);
      if(!CreateSpinControl(m_stoch_slow_spin,m_body,stoch_right_x,y_cursor,stoch_half_w,9999.0,1.0,1.0,0,"3",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_stoch_ma_type_label,"Tipo de media",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_stoch_ma_type_combo,m_body,content_x,y_cursor,inner_w,140,ma_type_items,0,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_stoch_price_type_label,"Tipo de estocastico",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_stoch_price_type_combo,m_body,content_x,y_cursor,inner_w,100,stoch_type_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_rsi_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_rsi_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_rsi_price_label,"Modo de preco",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_rsi_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_reg_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_reg_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"20",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_reg_ma_type_label,"Tipo de regressao",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_reg_ma_type_combo,m_body,content_x,y_cursor,inner_w,140,ma_type_items,0,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_reg_price_label,"Modo de fechamento",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_reg_price_combo,m_body,content_x,y_cursor,inner_w,140,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_macd_fast_label,"EMA rapida",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_macd_fast_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"12",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_macd_slow_label,"EMA lenta",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_macd_slow_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"26",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_macd_signal_label,"Sinal",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_macd_signal_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"9",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_macd_price_label,"Modo de preco",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_macd_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_ad_volume_label,"Volume",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_ad_volume_combo,m_body,content_x,y_cursor,inner_w,80,volume_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_mfi_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_mfi_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_mfi_volume_label,"Volume",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_mfi_volume_combo,m_body,content_x,y_cursor,inner_w,80,volume_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_vidya_cmo_period_label,"Periodo CMO",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_vidya_cmo_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"9",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_vidya_ema_period_label,"Periodo EMA",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_vidya_ema_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"12",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_vidya_shift_label,"Deslocamento",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_vidya_shift_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"0",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_vidya_price_label,"Modo de preco",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_vidya_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_tema_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_tema_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_tema_shift_label,"Deslocamento",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_tema_shift_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"0",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_tema_price_label,"Modo de preco",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_tema_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_frama_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_frama_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_frama_shift_label,"Deslocamento",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_frama_shift_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"0",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_frama_price_label,"Modo de preco",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_frama_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_trix_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_trix_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_trix_price_label,"Modo de preco",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_trix_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_bears_power_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_bears_power_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"13",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_bulls_power_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_bulls_power_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"13",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_chaikin_fast_label,"Media rapida",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_chaikin_fast_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"3",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_chaikin_slow_label,"Media lenta",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_chaikin_slow_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"10",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_chaikin_ma_type_label,"Tipo de media",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_chaikin_ma_type_combo,m_body,content_x,y_cursor,inner_w,140,ma_type_items,0,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_chaikin_volume_label,"Volume",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_chaikin_volume_combo,m_body,content_x,y_cursor,inner_w,80,volume_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_cci_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_cci_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_cci_price_label,"Modo de preco",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_cci_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_demarker_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_demarker_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"14",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      const int pair_col_gap=10;
      const int pair_col_w=(inner_w-pair_col_gap)/2;
      const int pair_right_x=content_x+pair_col_w+pair_col_gap;
      if(!CreateBodyLabel(m_alligator_jaw_period_label,"Periodo mandibula",m_body,content_x,y_cursor,pair_col_w,16))
         return(false);
      if(!CreateBodyLabel(m_alligator_jaw_shift_label,"Desloc. mandibula",m_body,pair_right_x,y_cursor,pair_col_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_alligator_jaw_period_spin,m_body,content_x,y_cursor,pair_col_w,9999.0,1.0,1.0,0,"14",sub_back,field_border))
         return(false);
      if(!CreateSpinControl(m_alligator_jaw_shift_spin,m_body,pair_right_x,y_cursor,pair_col_w,9999.0,0.0,1.0,0,"8",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_alligator_teeth_period_label,"Periodo dente",m_body,content_x,y_cursor,pair_col_w,16))
         return(false);
      if(!CreateBodyLabel(m_alligator_teeth_shift_label,"Desloc. dente",m_body,pair_right_x,y_cursor,pair_col_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_alligator_teeth_period_spin,m_body,content_x,y_cursor,pair_col_w,9999.0,1.0,1.0,0,"8",sub_back,field_border))
         return(false);
      if(!CreateSpinControl(m_alligator_teeth_shift_spin,m_body,pair_right_x,y_cursor,pair_col_w,9999.0,0.0,1.0,0,"5",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_alligator_lips_period_label,"Periodo boca",m_body,content_x,y_cursor,pair_col_w,16))
         return(false);
      if(!CreateBodyLabel(m_alligator_lips_shift_label,"Desloc. boca",m_body,pair_right_x,y_cursor,pair_col_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_alligator_lips_period_spin,m_body,content_x,y_cursor,pair_col_w,9999.0,1.0,1.0,0,"5",sub_back,field_border))
         return(false);
      if(!CreateSpinControl(m_alligator_lips_shift_spin,m_body,pair_right_x,y_cursor,pair_col_w,9999.0,0.0,1.0,0,"3",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_alligator_ma_type_label,"Tipo de media",m_body,content_x,y_cursor,pair_col_w,16))
         return(false);
      if(!CreateBodyLabel(m_alligator_price_label,"Modo de preco",m_body,pair_right_x,y_cursor,pair_col_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_alligator_ma_type_combo,m_body,content_x,y_cursor,pair_col_w,140,ma_type_items,0,field_border))
         return(false);
      if(!CreateComboControl(m_alligator_price_combo,m_body,pair_right_x,y_cursor,pair_col_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_ichimoku_tenkan_label,"Tenkan-sen",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_ichimoku_tenkan_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"9",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_ichimoku_kijun_label,"Kijun-sen",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_ichimoku_kijun_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"26",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_ichimoku_senkou_b_label,"Senkou Span B",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_ichimoku_senkou_b_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"52",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_adx_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_adx_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"14",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_adx_wilder_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_adx_wilder_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"9",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_gator_period_label,"Periodo",m_body,content_x,y_cursor,pair_col_w,14))
         return(false);
      y_cursor+=14;
      if(!CreateSpinControl(m_gator_period_spin,m_body,content_x,y_cursor,pair_col_w,9999.0,1.0,1.0,0,"9",sub_back,field_border))
         return(false);
      y_cursor+=20;
      if(!CreateBodyLabel(m_gator_jaw_period_label,"Periodo mandibula",m_body,content_x,y_cursor,pair_col_w,15))
         return(false);
      if(!CreateBodyLabel(m_gator_jaw_shift_label,"Desloc. mandibula",m_body,pair_right_x,y_cursor,pair_col_w,15))
         return(false);
      y_cursor+=15;
      if(!CreateSpinControl(m_gator_jaw_period_spin,m_body,content_x,y_cursor,pair_col_w,9999.0,1.0,1.0,0,"13",sub_back,field_border))
         return(false);
      if(!CreateSpinControl(m_gator_jaw_shift_spin,m_body,pair_right_x,y_cursor,pair_col_w,9999.0,0.0,1.0,0,"8",sub_back,field_border))
         return(false);
      y_cursor+=20;
      if(!CreateBodyLabel(m_gator_teeth_period_label,"Periodo dente",m_body,content_x,y_cursor,pair_col_w,15))
         return(false);
      if(!CreateBodyLabel(m_gator_teeth_shift_label,"Desloc. dente",m_body,pair_right_x,y_cursor,pair_col_w,15))
         return(false);
      y_cursor+=15;
      if(!CreateSpinControl(m_gator_teeth_period_spin,m_body,content_x,y_cursor,pair_col_w,9999.0,1.0,1.0,0,"8",sub_back,field_border))
         return(false);
      if(!CreateSpinControl(m_gator_teeth_shift_spin,m_body,pair_right_x,y_cursor,pair_col_w,9999.0,0.0,1.0,0,"5",sub_back,field_border))
         return(false);
      y_cursor+=20;
      if(!CreateBodyLabel(m_gator_lips_period_label,"Periodo boca",m_body,content_x,y_cursor,pair_col_w,15))
         return(false);
      if(!CreateBodyLabel(m_gator_lips_shift_label,"Desloc. boca",m_body,pair_right_x,y_cursor,pair_col_w,15))
         return(false);
      y_cursor+=15;
      if(!CreateSpinControl(m_gator_lips_period_spin,m_body,content_x,y_cursor,pair_col_w,9999.0,1.0,1.0,0,"5",sub_back,field_border))
         return(false);
      if(!CreateSpinControl(m_gator_lips_shift_spin,m_body,pair_right_x,y_cursor,pair_col_w,9999.0,0.0,1.0,0,"3",sub_back,field_border))
         return(false);
      y_cursor+=20;
      if(!CreateBodyLabel(m_gator_ma_type_label,"Tipo de media",m_body,content_x,y_cursor,pair_col_w,15))
         return(false);
      if(!CreateBodyLabel(m_gator_price_label,"Modo de preco",m_body,pair_right_x,y_cursor,pair_col_w,15))
         return(false);
      y_cursor+=15;
      if(!CreateComboControl(m_gator_ma_type_combo,m_body,content_x,y_cursor,pair_col_w,120,ma_type_items,0,field_border))
         return(false);
      if(!CreateComboControl(m_gator_price_combo,m_body,pair_right_x,y_cursor,pair_col_w,140,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_wpr_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_wpr_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"14",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_wpr_deviation_label,"Desvios",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_wpr_deviation_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,1.0,0,"2",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_mfi_market_volume_label,"Volume",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_mfi_market_volume_combo,m_body,content_x,y_cursor,inner_w,80,volume_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_momentum_period_label,"Periodo medio",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_momentum_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"9",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_momentum_price_label,"Modo de preco",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_momentum_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_rvi_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_rvi_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"13",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_obv_volume_label,"Volume",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_obv_volume_combo,m_body,content_x,y_cursor,inner_w,80,volume_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_stddev_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_stddev_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"20",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_stddev_ma_type_label,"Tipo de desvio",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_stddev_ma_type_combo,m_body,content_x,y_cursor,inner_w,140,ma_type_items,0,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_stddev_price_label,"Modo de fechamento",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_stddev_price_combo,m_body,content_x,y_cursor,inner_w,160,price_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_volume_type_label,"Volume",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateComboControl(m_volume_type_combo,m_body,content_x,y_cursor,inner_w,80,volume_items,0,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_atr_period_label,"Periodo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_atr_period_spin,m_body,content_x,y_cursor,inner_w,9999.0,1.0,1.0,0,"14",sub_back,field_border))
         return(false);

      y_cursor=content_y+18;
      if(!CreateBodyLabel(m_sar_step_label,"Passo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_sar_step_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,0.01,2,"0.02",sub_back,field_border))
         return(false);
      y_cursor+=22;
      if(!CreateBodyLabel(m_sar_max_label,"Maximo",m_body,content_x,y_cursor,inner_w,16))
         return(false);
      y_cursor+=16;
      if(!CreateSpinControl(m_sar_max_spin,m_body,content_x,y_cursor,inner_w,9999.0,0.0,0.01,2,"0.20",sub_back,field_border))
         return(false);

      m_combo.SelectItem(IndicatorCodeToDisplayIndex(0));
      m_silent_updates=true;
      HideSlot();
      m_silent_updates=false;
      m_last_selected_index=-1;
      m_created=true;
      return(true);
     }

   void RefreshView(void)
     {
      if(!m_created || !m_is_active)
         return;

      const int selected=DisplayIndexToIndicatorCode(V2ClampIndex(m_combo.GetListViewPointer().SelectedItemIndex(),0,40));
      m_last_selected_index=selected;
      ApplySelectedIndicator(selected);
     }

   void SetSlotIndex(const int slot_index)
     {
      m_slot_index=slot_index;
     }

   void SaveState(STab8MontarSlotState &state)
     {
      state.selected_indicator=SelectedIndicatorIndex();
      ArrayResize(state.spin_values,65);
      ArrayResize(state.combo_indices,34);

      state.spin_values[0]=GetSpinValue(m_adx_period_spin);
      state.spin_values[1]=GetSpinValue(m_adx_wilder_period_spin);
      state.spin_values[2]=GetSpinValue(m_afast_period_spin);
      state.spin_values[3]=GetSpinValue(m_afast_shift_spin);
      state.spin_values[4]=GetSpinValue(m_alligator_jaw_period_spin);
      state.spin_values[5]=GetSpinValue(m_alligator_jaw_shift_spin);
      state.spin_values[6]=GetSpinValue(m_alligator_lips_period_spin);
      state.spin_values[7]=GetSpinValue(m_alligator_lips_shift_spin);
      state.spin_values[8]=GetSpinValue(m_alligator_teeth_period_spin);
      state.spin_values[9]=GetSpinValue(m_alligator_teeth_shift_spin);
      state.spin_values[10]=GetSpinValue(m_atr_channel_deviation_spin);
      state.spin_values[11]=GetSpinValue(m_atr_channel_period_spin);
      state.spin_values[12]=GetSpinValue(m_atr_period_spin);
      state.spin_values[13]=GetSpinValue(m_bbands_deviation_spin);
      state.spin_values[14]=GetSpinValue(m_bbands_period_spin);
      state.spin_values[15]=GetSpinValue(m_bbands_shift_spin);
      state.spin_values[16]=GetSpinValue(m_bears_power_period_spin);
      state.spin_values[17]=GetSpinValue(m_bulls_power_period_spin);
      state.spin_values[18]=GetSpinValue(m_cci_period_spin);
      state.spin_values[19]=GetSpinValue(m_chaikin_fast_spin);
      state.spin_values[20]=GetSpinValue(m_chaikin_slow_spin);
      state.spin_values[21]=GetSpinValue(m_demarker_period_spin);
      state.spin_values[22]=GetSpinValue(m_desvio_period_spin);
      state.spin_values[23]=GetSpinValue(m_donchian_period_spin);
      state.spin_values[24]=GetSpinValue(m_env_deviation_spin);
      state.spin_values[25]=GetSpinValue(m_env_period_spin);
      state.spin_values[26]=GetSpinValue(m_env_shift_spin);
      state.spin_values[27]=GetSpinValue(m_frama_period_spin);
      state.spin_values[28]=GetSpinValue(m_frama_shift_spin);
      state.spin_values[29]=GetSpinValue(m_gator_jaw_period_spin);
      state.spin_values[30]=GetSpinValue(m_gator_jaw_shift_spin);
      state.spin_values[31]=GetSpinValue(m_gator_lips_period_spin);
      state.spin_values[32]=GetSpinValue(m_gator_lips_shift_spin);
      state.spin_values[33]=GetSpinValue(m_gator_period_spin);
      state.spin_values[34]=GetSpinValue(m_gator_teeth_period_spin);
      state.spin_values[35]=GetSpinValue(m_gator_teeth_shift_spin);
      state.spin_values[36]=GetSpinValue(m_ichimoku_kijun_spin);
      state.spin_values[37]=GetSpinValue(m_ichimoku_senkou_b_spin);
      state.spin_values[38]=GetSpinValue(m_ichimoku_tenkan_spin);
      state.spin_values[39]=GetSpinValue(m_keltner_deviation_spin);
      state.spin_values[40]=GetSpinValue(m_keltner_period_spin);
      state.spin_values[41]=GetSpinValue(m_ma_period_spin);
      state.spin_values[42]=GetSpinValue(m_ma_shift_spin);
      state.spin_values[43]=GetSpinValue(m_macd_fast_spin);
      state.spin_values[44]=GetSpinValue(m_macd_signal_spin);
      state.spin_values[45]=GetSpinValue(m_macd_slow_spin);
      state.spin_values[46]=GetSpinValue(m_mfi_period_spin);
      state.spin_values[47]=GetSpinValue(m_momentum_period_spin);
      state.spin_values[48]=GetSpinValue(m_reg_period_spin);
      state.spin_values[49]=GetSpinValue(m_rsi_period_spin);
      state.spin_values[50]=GetSpinValue(m_rvi_period_spin);
      state.spin_values[51]=GetSpinValue(m_sar_max_spin);
      state.spin_values[52]=GetSpinValue(m_sar_step_spin);
      state.spin_values[53]=GetSpinValue(m_stddev_period_spin);
      state.spin_values[54]=GetSpinValue(m_stoch_d_spin);
      state.spin_values[55]=GetSpinValue(m_stoch_k_spin);
      state.spin_values[56]=GetSpinValue(m_stoch_slow_spin);
      state.spin_values[57]=GetSpinValue(m_tema_period_spin);
      state.spin_values[58]=GetSpinValue(m_tema_shift_spin);
      state.spin_values[59]=GetSpinValue(m_trix_period_spin);
      state.spin_values[60]=GetSpinValue(m_vidya_cmo_period_spin);
      state.spin_values[61]=GetSpinValue(m_vidya_ema_period_spin);
      state.spin_values[62]=GetSpinValue(m_vidya_shift_spin);
      state.spin_values[63]=GetSpinValue(m_wpr_deviation_spin);
      state.spin_values[64]=GetSpinValue(m_wpr_period_spin);

      state.combo_indices[0]=GetComboIndex(m_ad_volume_combo);
      state.combo_indices[1]=GetComboIndex(m_afast_ma_type_combo);
      state.combo_indices[2]=GetComboIndex(m_afast_price_combo);
      state.combo_indices[3]=GetComboIndex(m_alligator_ma_type_combo);
      state.combo_indices[4]=GetComboIndex(m_alligator_price_combo);
      state.combo_indices[5]=GetComboIndex(m_bbands_price_combo);
      state.combo_indices[6]=GetComboIndex(m_cci_price_combo);
      state.combo_indices[7]=GetComboIndex(m_chaikin_ma_type_combo);
      state.combo_indices[8]=GetComboIndex(m_chaikin_volume_combo);
      state.combo_indices[9]=GetComboIndex(m_desvio_ma_type_combo);
      state.combo_indices[10]=GetComboIndex(m_desvio_price_combo);
      state.combo_indices[11]=GetComboIndex(m_env_ma_type_combo);
      state.combo_indices[12]=GetComboIndex(m_frama_price_combo);
      state.combo_indices[13]=GetComboIndex(m_gator_ma_type_combo);
      state.combo_indices[14]=GetComboIndex(m_gator_price_combo);
      state.combo_indices[15]=GetComboIndex(m_keltner_ma_type_combo);
      state.combo_indices[16]=GetComboIndex(m_ma_price_combo);
      state.combo_indices[17]=GetComboIndex(m_ma_type_combo);
      state.combo_indices[18]=GetComboIndex(m_macd_price_combo);
      state.combo_indices[19]=GetComboIndex(m_mfi_market_volume_combo);
      state.combo_indices[20]=GetComboIndex(m_mfi_volume_combo);
      state.combo_indices[21]=GetComboIndex(m_momentum_price_combo);
      state.combo_indices[22]=GetComboIndex(m_obv_volume_combo);
      state.combo_indices[23]=GetComboIndex(m_reg_ma_type_combo);
      state.combo_indices[24]=GetComboIndex(m_reg_price_combo);
      state.combo_indices[25]=GetComboIndex(m_rsi_price_combo);
      state.combo_indices[26]=GetComboIndex(m_stddev_ma_type_combo);
      state.combo_indices[27]=GetComboIndex(m_stddev_price_combo);
      state.combo_indices[28]=GetComboIndex(m_stoch_ma_type_combo);
      state.combo_indices[29]=GetComboIndex(m_stoch_price_type_combo);
      state.combo_indices[30]=GetComboIndex(m_tema_price_combo);
      state.combo_indices[31]=GetComboIndex(m_trix_price_combo);
      state.combo_indices[32]=GetComboIndex(m_vidya_price_combo);
      state.combo_indices[33]=GetComboIndex(m_volume_type_combo);
     }

   void LoadState(const STab8MontarSlotState &state)
     {
      if(!m_created)
         return;

      const bool previous_silent=m_silent_updates;
      m_silent_updates=true;

      SetSpinValue(m_adx_period_spin,(ArraySize(state.spin_values)>0 ? state.spin_values[0] : GetSpinValue(m_adx_period_spin)));
      SetSpinValue(m_adx_wilder_period_spin,(ArraySize(state.spin_values)>1 ? state.spin_values[1] : GetSpinValue(m_adx_wilder_period_spin)));
      SetSpinValue(m_afast_period_spin,(ArraySize(state.spin_values)>2 ? state.spin_values[2] : GetSpinValue(m_afast_period_spin)));
      SetSpinValue(m_afast_shift_spin,(ArraySize(state.spin_values)>3 ? state.spin_values[3] : GetSpinValue(m_afast_shift_spin)));
      SetSpinValue(m_alligator_jaw_period_spin,(ArraySize(state.spin_values)>4 ? state.spin_values[4] : GetSpinValue(m_alligator_jaw_period_spin)));
      SetSpinValue(m_alligator_jaw_shift_spin,(ArraySize(state.spin_values)>5 ? state.spin_values[5] : GetSpinValue(m_alligator_jaw_shift_spin)));
      SetSpinValue(m_alligator_lips_period_spin,(ArraySize(state.spin_values)>6 ? state.spin_values[6] : GetSpinValue(m_alligator_lips_period_spin)));
      SetSpinValue(m_alligator_lips_shift_spin,(ArraySize(state.spin_values)>7 ? state.spin_values[7] : GetSpinValue(m_alligator_lips_shift_spin)));
      SetSpinValue(m_alligator_teeth_period_spin,(ArraySize(state.spin_values)>8 ? state.spin_values[8] : GetSpinValue(m_alligator_teeth_period_spin)));
      SetSpinValue(m_alligator_teeth_shift_spin,(ArraySize(state.spin_values)>9 ? state.spin_values[9] : GetSpinValue(m_alligator_teeth_shift_spin)));
      SetSpinValue(m_atr_channel_deviation_spin,(ArraySize(state.spin_values)>10 ? state.spin_values[10] : GetSpinValue(m_atr_channel_deviation_spin)));
      SetSpinValue(m_atr_channel_period_spin,(ArraySize(state.spin_values)>11 ? state.spin_values[11] : GetSpinValue(m_atr_channel_period_spin)));
      SetSpinValue(m_atr_period_spin,(ArraySize(state.spin_values)>12 ? state.spin_values[12] : GetSpinValue(m_atr_period_spin)));
      SetSpinValue(m_bbands_deviation_spin,(ArraySize(state.spin_values)>13 ? state.spin_values[13] : GetSpinValue(m_bbands_deviation_spin)));
      SetSpinValue(m_bbands_period_spin,(ArraySize(state.spin_values)>14 ? state.spin_values[14] : GetSpinValue(m_bbands_period_spin)));
      SetSpinValue(m_bbands_shift_spin,(ArraySize(state.spin_values)>15 ? state.spin_values[15] : GetSpinValue(m_bbands_shift_spin)));
      SetSpinValue(m_bears_power_period_spin,(ArraySize(state.spin_values)>16 ? state.spin_values[16] : GetSpinValue(m_bears_power_period_spin)));
      SetSpinValue(m_bulls_power_period_spin,(ArraySize(state.spin_values)>17 ? state.spin_values[17] : GetSpinValue(m_bulls_power_period_spin)));
      SetSpinValue(m_cci_period_spin,(ArraySize(state.spin_values)>18 ? state.spin_values[18] : GetSpinValue(m_cci_period_spin)));
      SetSpinValue(m_chaikin_fast_spin,(ArraySize(state.spin_values)>19 ? state.spin_values[19] : GetSpinValue(m_chaikin_fast_spin)));
      SetSpinValue(m_chaikin_slow_spin,(ArraySize(state.spin_values)>20 ? state.spin_values[20] : GetSpinValue(m_chaikin_slow_spin)));
      SetSpinValue(m_demarker_period_spin,(ArraySize(state.spin_values)>21 ? state.spin_values[21] : GetSpinValue(m_demarker_period_spin)));
      SetSpinValue(m_desvio_period_spin,(ArraySize(state.spin_values)>22 ? state.spin_values[22] : GetSpinValue(m_desvio_period_spin)));
      SetSpinValue(m_donchian_period_spin,(ArraySize(state.spin_values)>23 ? state.spin_values[23] : GetSpinValue(m_donchian_period_spin)));
      SetSpinValue(m_env_deviation_spin,(ArraySize(state.spin_values)>24 ? state.spin_values[24] : GetSpinValue(m_env_deviation_spin)));
      SetSpinValue(m_env_period_spin,(ArraySize(state.spin_values)>25 ? state.spin_values[25] : GetSpinValue(m_env_period_spin)));
      SetSpinValue(m_env_shift_spin,(ArraySize(state.spin_values)>26 ? state.spin_values[26] : GetSpinValue(m_env_shift_spin)));
      SetSpinValue(m_frama_period_spin,(ArraySize(state.spin_values)>27 ? state.spin_values[27] : GetSpinValue(m_frama_period_spin)));
      SetSpinValue(m_frama_shift_spin,(ArraySize(state.spin_values)>28 ? state.spin_values[28] : GetSpinValue(m_frama_shift_spin)));
      SetSpinValue(m_gator_jaw_period_spin,(ArraySize(state.spin_values)>29 ? state.spin_values[29] : GetSpinValue(m_gator_jaw_period_spin)));
      SetSpinValue(m_gator_jaw_shift_spin,(ArraySize(state.spin_values)>30 ? state.spin_values[30] : GetSpinValue(m_gator_jaw_shift_spin)));
      SetSpinValue(m_gator_lips_period_spin,(ArraySize(state.spin_values)>31 ? state.spin_values[31] : GetSpinValue(m_gator_lips_period_spin)));
      SetSpinValue(m_gator_lips_shift_spin,(ArraySize(state.spin_values)>32 ? state.spin_values[32] : GetSpinValue(m_gator_lips_shift_spin)));
      SetSpinValue(m_gator_period_spin,(ArraySize(state.spin_values)>33 ? state.spin_values[33] : GetSpinValue(m_gator_period_spin)));
      SetSpinValue(m_gator_teeth_period_spin,(ArraySize(state.spin_values)>34 ? state.spin_values[34] : GetSpinValue(m_gator_teeth_period_spin)));
      SetSpinValue(m_gator_teeth_shift_spin,(ArraySize(state.spin_values)>35 ? state.spin_values[35] : GetSpinValue(m_gator_teeth_shift_spin)));
      SetSpinValue(m_ichimoku_kijun_spin,(ArraySize(state.spin_values)>36 ? state.spin_values[36] : GetSpinValue(m_ichimoku_kijun_spin)));
      SetSpinValue(m_ichimoku_senkou_b_spin,(ArraySize(state.spin_values)>37 ? state.spin_values[37] : GetSpinValue(m_ichimoku_senkou_b_spin)));
      SetSpinValue(m_ichimoku_tenkan_spin,(ArraySize(state.spin_values)>38 ? state.spin_values[38] : GetSpinValue(m_ichimoku_tenkan_spin)));
      SetSpinValue(m_keltner_deviation_spin,(ArraySize(state.spin_values)>39 ? state.spin_values[39] : GetSpinValue(m_keltner_deviation_spin)));
      SetSpinValue(m_keltner_period_spin,(ArraySize(state.spin_values)>40 ? state.spin_values[40] : GetSpinValue(m_keltner_period_spin)));
      SetSpinValue(m_ma_period_spin,(ArraySize(state.spin_values)>41 ? state.spin_values[41] : GetSpinValue(m_ma_period_spin)));
      SetSpinValue(m_ma_shift_spin,(ArraySize(state.spin_values)>42 ? state.spin_values[42] : GetSpinValue(m_ma_shift_spin)));
      SetSpinValue(m_macd_fast_spin,(ArraySize(state.spin_values)>43 ? state.spin_values[43] : GetSpinValue(m_macd_fast_spin)));
      SetSpinValue(m_macd_signal_spin,(ArraySize(state.spin_values)>44 ? state.spin_values[44] : GetSpinValue(m_macd_signal_spin)));
      SetSpinValue(m_macd_slow_spin,(ArraySize(state.spin_values)>45 ? state.spin_values[45] : GetSpinValue(m_macd_slow_spin)));
      SetSpinValue(m_mfi_period_spin,(ArraySize(state.spin_values)>46 ? state.spin_values[46] : GetSpinValue(m_mfi_period_spin)));
      SetSpinValue(m_momentum_period_spin,(ArraySize(state.spin_values)>47 ? state.spin_values[47] : GetSpinValue(m_momentum_period_spin)));
      SetSpinValue(m_reg_period_spin,(ArraySize(state.spin_values)>48 ? state.spin_values[48] : GetSpinValue(m_reg_period_spin)));
      SetSpinValue(m_rsi_period_spin,(ArraySize(state.spin_values)>49 ? state.spin_values[49] : GetSpinValue(m_rsi_period_spin)));
      SetSpinValue(m_rvi_period_spin,(ArraySize(state.spin_values)>50 ? state.spin_values[50] : GetSpinValue(m_rvi_period_spin)));
      SetSpinValue(m_sar_max_spin,(ArraySize(state.spin_values)>51 ? state.spin_values[51] : GetSpinValue(m_sar_max_spin)));
      SetSpinValue(m_sar_step_spin,(ArraySize(state.spin_values)>52 ? state.spin_values[52] : GetSpinValue(m_sar_step_spin)));
      SetSpinValue(m_stddev_period_spin,(ArraySize(state.spin_values)>53 ? state.spin_values[53] : GetSpinValue(m_stddev_period_spin)));
      SetSpinValue(m_stoch_d_spin,(ArraySize(state.spin_values)>54 ? state.spin_values[54] : GetSpinValue(m_stoch_d_spin)));
      SetSpinValue(m_stoch_k_spin,(ArraySize(state.spin_values)>55 ? state.spin_values[55] : GetSpinValue(m_stoch_k_spin)));
      SetSpinValue(m_stoch_slow_spin,(ArraySize(state.spin_values)>56 ? state.spin_values[56] : GetSpinValue(m_stoch_slow_spin)));
      SetSpinValue(m_tema_period_spin,(ArraySize(state.spin_values)>57 ? state.spin_values[57] : GetSpinValue(m_tema_period_spin)));
      SetSpinValue(m_tema_shift_spin,(ArraySize(state.spin_values)>58 ? state.spin_values[58] : GetSpinValue(m_tema_shift_spin)));
      SetSpinValue(m_trix_period_spin,(ArraySize(state.spin_values)>59 ? state.spin_values[59] : GetSpinValue(m_trix_period_spin)));
      SetSpinValue(m_vidya_cmo_period_spin,(ArraySize(state.spin_values)>60 ? state.spin_values[60] : GetSpinValue(m_vidya_cmo_period_spin)));
      SetSpinValue(m_vidya_ema_period_spin,(ArraySize(state.spin_values)>61 ? state.spin_values[61] : GetSpinValue(m_vidya_ema_period_spin)));
      SetSpinValue(m_vidya_shift_spin,(ArraySize(state.spin_values)>62 ? state.spin_values[62] : GetSpinValue(m_vidya_shift_spin)));
      SetSpinValue(m_wpr_deviation_spin,(ArraySize(state.spin_values)>63 ? state.spin_values[63] : GetSpinValue(m_wpr_deviation_spin)));
      SetSpinValue(m_wpr_period_spin,(ArraySize(state.spin_values)>64 ? state.spin_values[64] : GetSpinValue(m_wpr_period_spin)));

      SetComboIndex(m_ad_volume_combo,(ArraySize(state.combo_indices)>0 ? state.combo_indices[0] : GetComboIndex(m_ad_volume_combo)));
      SetComboIndex(m_afast_ma_type_combo,(ArraySize(state.combo_indices)>1 ? state.combo_indices[1] : GetComboIndex(m_afast_ma_type_combo)));
      SetComboIndex(m_afast_price_combo,(ArraySize(state.combo_indices)>2 ? state.combo_indices[2] : GetComboIndex(m_afast_price_combo)));
      SetComboIndex(m_alligator_ma_type_combo,(ArraySize(state.combo_indices)>3 ? state.combo_indices[3] : GetComboIndex(m_alligator_ma_type_combo)));
      SetComboIndex(m_alligator_price_combo,(ArraySize(state.combo_indices)>4 ? state.combo_indices[4] : GetComboIndex(m_alligator_price_combo)));
      SetComboIndex(m_bbands_price_combo,(ArraySize(state.combo_indices)>5 ? state.combo_indices[5] : GetComboIndex(m_bbands_price_combo)));
      SetComboIndex(m_cci_price_combo,(ArraySize(state.combo_indices)>6 ? state.combo_indices[6] : GetComboIndex(m_cci_price_combo)));
      SetComboIndex(m_chaikin_ma_type_combo,(ArraySize(state.combo_indices)>7 ? state.combo_indices[7] : GetComboIndex(m_chaikin_ma_type_combo)));
      SetComboIndex(m_chaikin_volume_combo,(ArraySize(state.combo_indices)>8 ? state.combo_indices[8] : GetComboIndex(m_chaikin_volume_combo)));
      SetComboIndex(m_desvio_ma_type_combo,(ArraySize(state.combo_indices)>9 ? state.combo_indices[9] : GetComboIndex(m_desvio_ma_type_combo)));
      SetComboIndex(m_desvio_price_combo,(ArraySize(state.combo_indices)>10 ? state.combo_indices[10] : GetComboIndex(m_desvio_price_combo)));
      SetComboIndex(m_env_ma_type_combo,(ArraySize(state.combo_indices)>11 ? state.combo_indices[11] : GetComboIndex(m_env_ma_type_combo)));
      SetComboIndex(m_frama_price_combo,(ArraySize(state.combo_indices)>12 ? state.combo_indices[12] : GetComboIndex(m_frama_price_combo)));
      SetComboIndex(m_gator_ma_type_combo,(ArraySize(state.combo_indices)>13 ? state.combo_indices[13] : GetComboIndex(m_gator_ma_type_combo)));
      SetComboIndex(m_gator_price_combo,(ArraySize(state.combo_indices)>14 ? state.combo_indices[14] : GetComboIndex(m_gator_price_combo)));
      SetComboIndex(m_keltner_ma_type_combo,(ArraySize(state.combo_indices)>15 ? state.combo_indices[15] : GetComboIndex(m_keltner_ma_type_combo)));
      SetComboIndex(m_ma_price_combo,(ArraySize(state.combo_indices)>16 ? state.combo_indices[16] : GetComboIndex(m_ma_price_combo)));
      SetComboIndex(m_ma_type_combo,(ArraySize(state.combo_indices)>17 ? state.combo_indices[17] : GetComboIndex(m_ma_type_combo)));
      SetComboIndex(m_macd_price_combo,(ArraySize(state.combo_indices)>18 ? state.combo_indices[18] : GetComboIndex(m_macd_price_combo)));
      SetComboIndex(m_mfi_market_volume_combo,(ArraySize(state.combo_indices)>19 ? state.combo_indices[19] : GetComboIndex(m_mfi_market_volume_combo)));
      SetComboIndex(m_mfi_volume_combo,(ArraySize(state.combo_indices)>20 ? state.combo_indices[20] : GetComboIndex(m_mfi_volume_combo)));
      SetComboIndex(m_momentum_price_combo,(ArraySize(state.combo_indices)>21 ? state.combo_indices[21] : GetComboIndex(m_momentum_price_combo)));
      SetComboIndex(m_obv_volume_combo,(ArraySize(state.combo_indices)>22 ? state.combo_indices[22] : GetComboIndex(m_obv_volume_combo)));
      SetComboIndex(m_reg_ma_type_combo,(ArraySize(state.combo_indices)>23 ? state.combo_indices[23] : GetComboIndex(m_reg_ma_type_combo)));
      SetComboIndex(m_reg_price_combo,(ArraySize(state.combo_indices)>24 ? state.combo_indices[24] : GetComboIndex(m_reg_price_combo)));
      SetComboIndex(m_rsi_price_combo,(ArraySize(state.combo_indices)>25 ? state.combo_indices[25] : GetComboIndex(m_rsi_price_combo)));
      SetComboIndex(m_stddev_ma_type_combo,(ArraySize(state.combo_indices)>26 ? state.combo_indices[26] : GetComboIndex(m_stddev_ma_type_combo)));
      SetComboIndex(m_stddev_price_combo,(ArraySize(state.combo_indices)>27 ? state.combo_indices[27] : GetComboIndex(m_stddev_price_combo)));
      SetComboIndex(m_stoch_ma_type_combo,(ArraySize(state.combo_indices)>28 ? state.combo_indices[28] : GetComboIndex(m_stoch_ma_type_combo)));
      SetComboIndex(m_stoch_price_type_combo,(ArraySize(state.combo_indices)>29 ? state.combo_indices[29] : GetComboIndex(m_stoch_price_type_combo)));
      SetComboIndex(m_tema_price_combo,(ArraySize(state.combo_indices)>30 ? state.combo_indices[30] : GetComboIndex(m_tema_price_combo)));
      SetComboIndex(m_trix_price_combo,(ArraySize(state.combo_indices)>31 ? state.combo_indices[31] : GetComboIndex(m_trix_price_combo)));
      SetComboIndex(m_vidya_price_combo,(ArraySize(state.combo_indices)>32 ? state.combo_indices[32] : GetComboIndex(m_vidya_price_combo)));
      SetComboIndex(m_volume_type_combo,(ArraySize(state.combo_indices)>33 ? state.combo_indices[33] : GetComboIndex(m_volume_type_combo)));

      m_combo.SelectItem(IndicatorCodeToDisplayIndex(V2ClampIndex(state.selected_indicator,0,40)));
      m_last_selected_index=-1;
      ApplySelectedIndicator(V2ClampIndex(state.selected_indicator,0,40));

      m_silent_updates=previous_silent;
      if(m_is_active)
         RefreshView();
     }

   void SetActive(const bool active,const bool redraw=true)
     {
      if(!m_created)
         return;

      const bool previous_silent=m_silent_updates;
      if(!redraw)
         m_silent_updates=true;

      m_is_active=active;
      if(!active)
        {
         HideSlot();
         m_silent_updates=previous_silent;
         return;
        }

      ShowSlot();
      RefreshView();
      m_silent_updates=previous_silent;
     }

   void OnTimerEvent(void)
     {
      if(!m_created || !m_is_active)
         return;

      const int selected=DisplayIndexToIndicatorCode(V2ClampIndex(m_combo.GetListViewPointer().SelectedItemIndex(),0,40));
      if(selected!=m_last_selected_index)
        {
         m_last_selected_index=selected;
         ApplySelectedIndicator(selected);
        }
     }

   int SelectedIndicatorIndex(void)
     {
      if(!m_created)
         return(0);
      if(m_last_selected_index>=0)
         return(V2ClampIndex(m_last_selected_index,0,40));
      return(DisplayIndexToIndicatorCode(V2ClampIndex(m_combo.GetListViewPointer().SelectedItemIndex(),0,40)));
    }
  };

#endif // __CONSTRUTOR_V2_TAB8_MONTAR_SLOT_CARD_MQH__


