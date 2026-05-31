#ifndef __CONSTRUTOR_V2_TAB8_SINAIS_MAIN_VIEW_MQH__
#define __CONSTRUTOR_V2_TAB8_SINAIS_MAIN_VIEW_MQH__

#include "Tab8Shared.mqh"

class CTab8SinaisMainView : public CWndCreate
  {
private:
   CWndCreate *m_host;
   bool            m_created;
   bool            m_is_active;
   int             m_window_index;
   int             m_tab_index;
   int             m_last_ord_tab;
   int             m_last_sobre_tab;
   int             m_last_sobre_param_idx;
   int             m_last_cruz_tab;
   int             m_last_cruz_fast_idx;
   int             m_last_cruz_slow_idx;

   CFrame      m_card_ordens;
   CTextLabel  m_card_ordens_title;
   CCheckBox   m_ordem_market;
   CCheckBox   m_ordem_limit;
   CTabs       m_ord_tabs;
   CCheckBox   m_ord_ref_check;
   CCheckBox   m_ord_media_check;
   CFrame      m_ord_ref_card;
   CFrame      m_ord_media_card;
   CTextLabel  m_ord_ref_base_label;
   CComboBox   m_ord_ref_base_combo;
   CTextLabel  m_ord_ref_candle_label;
   CComboBox   m_ord_ref_candle_combo;
   CTextLabel  m_ord_ref_distance_label;
   CTextEdit   m_ord_ref_distance_spin;
   CTextLabel  m_ord_ref_expire_label;
   CComboBox   m_ord_ref_expire_combo;
   CTextLabel  m_ord_media_candles_label;
   CTextEdit   m_ord_media_candles_spin;
   CTextLabel  m_ord_media_base_label;
   CComboBox   m_ord_media_base_combo;
   CTextLabel  m_ord_media_distance_label;
   CTextEdit   m_ord_media_distance_spin;
   CTextLabel  m_ord_media_expire_label;
   CComboBox   m_ord_media_expire_combo;

   CFrame      m_card_filtro;
   CTextLabel  m_card_filtro_title;
   CCheckBox   m_use_filtro;
   CTextLabel  m_filtro_padrao_label;
   CComboBox   m_filtro_padrao_combo;
   CTextLabel  m_filtro_time_label;
   CComboBox   m_filtro_time_combo;
   CTextLabel  m_filtro_range_label[4];
   CTextEdit   m_filtro_range_spin[4];

   CFrame      m_card_canais;
   CTextLabel  m_card_canais_title;
   CTextLabel  m_canais_label;
   CCheckBox   m_canais_yes;
   CCheckBox   m_canais_no;
   CTextLabel  m_canais_indic_label;
   CComboBox   m_canais_indic_combo;
   CTextLabel  m_canais_type_label;
   CComboBox   m_canais_type_combo;
   CTextLabel  m_canais_period_label;
   CTextEdit   m_canais_period_spin;
   CTextLabel  m_canais_deviation_label;
   CTextEdit   m_canais_deviation_spin;
   CTextLabel  m_canais_shift_label;
   CTextEdit   m_canais_shift_spin;
   CTextLabel  m_canais_price_label;
   CComboBox   m_canais_price_combo;
   CFrame      m_card_cruz;
   CTextLabel  m_card_cruz_title;
   CTextLabel  m_cruz_label;
   CCheckBox   m_cruz_yes;
   CCheckBox   m_cruz_no;
   CTabs       m_cruz_tabs;
   CTextLabel  m_cruz_fast_label;
   CComboBox   m_cruz_fast_combo;
   CTextLabel  m_cruz_signal_label;
   CComboBox   m_cruz_signal_combo;
   CTextLabel  m_cruz_slow_label;
   CComboBox   m_cruz_slow_combo;
   CTextLabel  m_cruz_note;
   CTextLabel  m_cruz_fast_indic_label;
   CComboBox   m_cruz_fast_indic_combo;
   CFrame      m_cruz_fast_param_card;
   CTabs       m_cruz_fast_param_tabs;
   CTextLabel  m_cruz_fast_param_title[5];
   CTextLabel  m_cruz_fast_ma_period_label;
   CTextEdit   m_cruz_fast_ma_period_spin;
   CTextLabel  m_cruz_fast_ma_shift_label;
   CTextEdit   m_cruz_fast_ma_shift_spin;
   CTextLabel  m_cruz_fast_ma_type_label;
   CComboBox   m_cruz_fast_ma_type_combo;
   CTextLabel  m_cruz_fast_ma_price_label;
   CComboBox   m_cruz_fast_ma_price_combo;
   CTextLabel  m_cruz_fast_vidya_cmo_label;
   CTextEdit   m_cruz_fast_vidya_cmo_spin;
   CTextLabel  m_cruz_fast_vidya_ema_label;
   CTextEdit   m_cruz_fast_vidya_ema_spin;
   CTextLabel  m_cruz_fast_vidya_shift_label;
   CTextEdit   m_cruz_fast_vidya_shift_spin;
   CTextLabel  m_cruz_fast_vidya_price_label;
   CComboBox   m_cruz_fast_vidya_price_combo;
   CTextLabel  m_cruz_fast_dema_period_label;
   CTextEdit   m_cruz_fast_dema_period_spin;
   CTextLabel  m_cruz_fast_dema_shift_label;
   CTextEdit   m_cruz_fast_dema_shift_spin;
   CTextLabel  m_cruz_fast_dema_price_label;
   CComboBox   m_cruz_fast_dema_price_combo;
   CTextLabel  m_cruz_fast_tema_period_label;
   CTextEdit   m_cruz_fast_tema_period_spin;
   CTextLabel  m_cruz_fast_tema_shift_label;
   CTextEdit   m_cruz_fast_tema_shift_spin;
   CTextLabel  m_cruz_fast_tema_price_label;
   CComboBox   m_cruz_fast_tema_price_combo;
   CTextLabel  m_cruz_fast_frama_period_label;
   CTextEdit   m_cruz_fast_frama_period_spin;
   CTextLabel  m_cruz_fast_frama_shift_label;
   CTextEdit   m_cruz_fast_frama_shift_spin;
   CTextLabel  m_cruz_fast_frama_price_label;
   CComboBox   m_cruz_fast_frama_price_combo;
   CTextLabel  m_cruz_slow_indic_label;
   CComboBox   m_cruz_slow_indic_combo;
   CFrame      m_cruz_slow_param_card;
   CTabs       m_cruz_slow_param_tabs;
   CTextLabel  m_cruz_slow_param_title[5];
   CTextLabel  m_cruz_slow_ma_period_label;
   CTextEdit   m_cruz_slow_ma_period_spin;
   CTextLabel  m_cruz_slow_ma_shift_label;
   CTextEdit   m_cruz_slow_ma_shift_spin;
   CTextLabel  m_cruz_slow_ma_type_label;
   CComboBox   m_cruz_slow_ma_type_combo;
   CTextLabel  m_cruz_slow_ma_price_label;
   CComboBox   m_cruz_slow_ma_price_combo;
   CTextLabel  m_cruz_slow_vidya_cmo_label;
   CTextEdit   m_cruz_slow_vidya_cmo_spin;
   CTextLabel  m_cruz_slow_vidya_ema_label;
   CTextEdit   m_cruz_slow_vidya_ema_spin;
   CTextLabel  m_cruz_slow_vidya_shift_label;
   CTextEdit   m_cruz_slow_vidya_shift_spin;
   CTextLabel  m_cruz_slow_vidya_price_label;
   CComboBox   m_cruz_slow_vidya_price_combo;
   CTextLabel  m_cruz_slow_dema_period_label;
   CTextEdit   m_cruz_slow_dema_period_spin;
   CTextLabel  m_cruz_slow_dema_shift_label;
   CTextEdit   m_cruz_slow_dema_shift_spin;
   CTextLabel  m_cruz_slow_dema_price_label;
   CComboBox   m_cruz_slow_dema_price_combo;
   CTextLabel  m_cruz_slow_tema_period_label;
   CTextEdit   m_cruz_slow_tema_period_spin;
   CTextLabel  m_cruz_slow_tema_shift_label;
   CTextEdit   m_cruz_slow_tema_shift_spin;
   CTextLabel  m_cruz_slow_tema_price_label;
   CComboBox   m_cruz_slow_tema_price_combo;
   CTextLabel  m_cruz_slow_frama_period_label;
   CTextEdit   m_cruz_slow_frama_period_spin;
   CTextLabel  m_cruz_slow_frama_shift_label;
   CTextEdit   m_cruz_slow_frama_shift_spin;
   CTextLabel  m_cruz_slow_frama_price_label;
   CComboBox   m_cruz_slow_frama_price_combo;
   CFrame      m_card_sobre;
   CTextLabel  m_card_sobre_title;
   CCheckBox   m_use_sobre;
   CTabs       m_sobre_tabs;
   CTextLabel  m_sobre_indic_label;
   CComboBox   m_sobre_indic_combo;
   CTextLabel  m_sobre_entry_label;
   CComboBox   m_sobre_entry_combo;
   CTextLabel  m_sobre_sobrecompra_label;
   CTextEdit   m_sobre_sobrecompra_spin;
   CTextLabel  m_sobre_sobrevenda_label;
   CTextEdit   m_sobre_sobrevenda_spin;
   CTextLabel  m_sobre_sentido_label;
   CComboBox   m_sobre_sentido_combo;
   CFrame      m_sobre_param_card;
   CTabs       m_sobre_param_tabs;
   CTextLabel  m_sobre_param_title[15];
   CTextLabel  m_sobre_macd_fast_label;
   CTextEdit   m_sobre_macd_fast_spin;
   CTextLabel  m_sobre_macd_slow_label;
   CTextEdit   m_sobre_macd_slow_spin;
   CTextLabel  m_sobre_macd_signal_label;
   CTextEdit   m_sobre_macd_signal_spin;
   CTextLabel  m_sobre_macd_price_label;
   CComboBox   m_sobre_macd_price_combo;
   CTextLabel  m_sobre_stoch_k_label;
   CTextEdit   m_sobre_stoch_k_spin;
   CTextLabel  m_sobre_stoch_d_label;
   CTextEdit   m_sobre_stoch_d_spin;
   CTextLabel  m_sobre_stoch_slow_label;
   CTextEdit   m_sobre_stoch_slow_spin;
   CTextLabel  m_sobre_stoch_ma_label;
   CComboBox   m_sobre_stoch_ma_combo;
   CTextLabel  m_sobre_stoch_type_label;
   CComboBox   m_sobre_stoch_type_combo;
   CTextLabel  m_sobre_rsi_period_label;
   CTextEdit   m_sobre_rsi_period_spin;
   CTextLabel  m_sobre_rsi_price_label;
   CComboBox   m_sobre_rsi_price_combo;
   CTextLabel  m_sobre_demarker_period_label;
   CTextEdit   m_sobre_demarker_period_spin;
   CTextLabel  m_sobre_regressao_period_label;
   CTextEdit   m_sobre_regressao_period_spin;
   CTextLabel  m_sobre_regressao_ma_label;
   CComboBox   m_sobre_regressao_ma_combo;
   CTextLabel  m_sobre_regressao_price_label;
   CComboBox   m_sobre_regressao_price_combo;
   CTextLabel  m_sobre_desvio_period_label;
   CTextEdit   m_sobre_desvio_period_spin;
   CTextLabel  m_sobre_desvio_ma_label;
   CComboBox   m_sobre_desvio_ma_combo;
   CTextLabel  m_sobre_desvio_price_label;
   CComboBox   m_sobre_desvio_price_combo;
   CTextLabel  m_sobre_mfi_period_label;
   CTextEdit   m_sobre_mfi_period_spin;
   CTextLabel  m_sobre_mfi_volume_label;
   CComboBox   m_sobre_mfi_volume_combo;
   CTextLabel  m_sobre_bears_period_label;
   CTextEdit   m_sobre_bears_period_spin;
   CTextLabel  m_sobre_bulls_period_label;
   CTextEdit   m_sobre_bulls_period_spin;
   CTextLabel  m_sobre_cci_period_label;
   CTextEdit   m_sobre_cci_period_spin;
   CTextLabel  m_sobre_cci_price_label;
   CComboBox   m_sobre_cci_price_combo;
   CTextLabel  m_sobre_ichimoku_tenkan_label[5];
   CTextEdit   m_sobre_ichimoku_tenkan_spin[5];
   CTextLabel  m_sobre_ichimoku_kijun_label[5];
   CTextEdit   m_sobre_ichimoku_kijun_spin[5];
   CTextLabel  m_sobre_ichimoku_senkou_b_label[5];
   CTextEdit   m_sobre_ichimoku_senkou_b_spin[5];
   CTextLabel  m_sobre_param_hint;

   void SetFrameVisible(CFrame &frame,const bool visible)
     {
      if(visible)
         frame.Show();
      else
         frame.Hide();
      frame.Update(true);
     }

   void SetLabelVisible(CTextLabel &label,const bool visible)
     {
      if(visible)
         label.Show();
      else
         label.Hide();
      label.Update(true);
     }

   void SetCheckVisible(CCheckBox &check,const bool visible)
     {
      if(visible)
         check.Show();
      else
         check.Hide();
      check.Update(true);
     }

   void SetTabsVisible(CTabs &tabs,const bool visible)
     {
      if(visible)
         tabs.Show();
      else
         tabs.Hide();
      tabs.Update();
     }

   bool CreateComboControl(CComboBox &combo,CElement &owner,CTabs &tabs,const int tab_index,const int x,const int y,const int width,const int list_height,const string &items[],const int selected_index,const color border)
     {
      combo.MainPointer(owner);
      tabs.AddToElementsArray(tab_index,combo);
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

   bool CreateSpinControl(CTextEdit &spin,CElement &owner,CTabs &tabs,const int tab_index,const int x,const int y,const int width,const double max_value,const double min_value,const double step,const int digits,const string value,const color back,const color border)
     {
      spin.MainPointer(owner);
      tabs.AddToElementsArray(tab_index,spin);
      V2StyleSpin(spin,back,border,width,max_value,min_value,step,digits,value);
      if(!spin.CreateTextEdit("",x,y))
         return(false);
      CWndContainer::AddToElementsArray(m_window_index,spin);
      return(true);
     }

   void RefreshOrderChecks(void)
     {
      m_ordem_market.Update(true);
      m_ordem_limit.Update(true);
      m_ord_ref_check.Update(true);
      m_ord_media_check.Update(true);
     }

   void RefreshCanaisChecks(void)
     {
      m_canais_yes.Update(true);
      m_canais_no.Update(true);
     }

   void RefreshCruzChecks(void)
     {
      m_cruz_yes.Update(true);
      m_cruz_no.Update(true);
     }

   void SyncOrderTabChecks(void)
     {
      if(!m_created)
         return;

      const int selected=m_ord_tabs.SelectedTab();
      if(selected==m_last_ord_tab)
         return;

      m_last_ord_tab=selected;
      const bool use_ref=(selected!=1);
      m_ord_ref_check.IsPressed(use_ref);
      m_ord_media_check.IsPressed(!use_ref);
      m_ord_tabs.ShowTabElements();
      m_ord_ref_check.Update(true);
      m_ord_media_check.Update(true);
     }

   void SyncSobreParamView(void)
     {
      if(!m_created)
         return;

      const int sobre_selected=m_sobre_tabs.SelectedTab();
      const int indic_selected=V2ClampIndex(m_sobre_indic_combo.GetListViewPointer().SelectedItemIndex(),0,14);
      const bool tab_changed=(sobre_selected!=m_last_sobre_tab);
      const bool indic_changed=(indic_selected!=m_last_sobre_param_idx);

      if(!tab_changed && !indic_changed)
         return;

      m_last_sobre_tab=sobre_selected;
      m_last_sobre_param_idx=indic_selected;
      m_sobre_param_tabs.SelectTab(indic_selected);

      if(sobre_selected==1)
         m_sobre_param_tabs.ShowTabElements();
      else
         m_sobre_tabs.ShowTabElements();
     }

   void SyncCruzParamView(CComboBox &combo,CTabs &param_tabs,int &last_index)
     {
      const int selected=V2ClampIndex(combo.GetListViewPointer().SelectedItemIndex(),0,4);
      if(selected==last_index)
         return;

      last_index=selected;
      param_tabs.SelectTab(selected);
      param_tabs.ShowTabElements();
     }

   void SyncCruzTabs(void)
     {
      if(!m_created)
         return;

      const int selected=m_cruz_tabs.SelectedTab();
      const bool tab_changed=(selected!=m_last_cruz_tab);
      const int geral_fast=V2ClampIndex(m_cruz_fast_combo.GetListViewPointer().SelectedItemIndex(),0,4);
      const int geral_slow=V2ClampIndex(m_cruz_slow_combo.GetListViewPointer().SelectedItemIndex(),0,4);
      const int detal_fast=V2ClampIndex(m_cruz_fast_indic_combo.GetListViewPointer().SelectedItemIndex(),0,4);
      const int detal_slow=V2ClampIndex(m_cruz_slow_indic_combo.GetListViewPointer().SelectedItemIndex(),0,4);
      if(tab_changed)
        {
         m_last_cruz_tab=selected;
         m_cruz_tabs.ShowTabElements();
        }

      if(selected==0)
        {
         if(detal_fast!=geral_fast)
            m_cruz_fast_indic_combo.SelectItem(geral_fast);
         if(detal_slow!=geral_slow)
            m_cruz_slow_indic_combo.SelectItem(geral_slow);
        }
      else
        {
         if(geral_fast!=detal_fast)
            m_cruz_fast_combo.SelectItem(detal_fast);
         if(geral_slow!=detal_slow)
            m_cruz_slow_combo.SelectItem(detal_slow);
        }

      if(selected==1)
         SyncCruzParamView(m_cruz_fast_indic_combo,m_cruz_fast_param_tabs,m_last_cruz_fast_idx);
      else if(selected==2)
         SyncCruzParamView(m_cruz_slow_indic_combo,m_cruz_slow_param_tabs,m_last_cruz_slow_idx);
     }

   bool CreateCruzParamBlock(CTabs &tabs,const int tab_index,const int x,const int &y_start,const int width,const color back,const color border,const string title,
                             CTextLabel &title_label,CTextEdit &period_spin,CTextEdit &shift_spin,CComboBox &type_combo,CComboBox &price_combo,
                             CTextLabel &period_label,CTextLabel &shift_label,CTextLabel &type_label,CTextLabel &price_label,
                             const string period_value,const bool has_type,const string &type_items[],const string &price_items[])
     {
      int y=y_start;
      const int title_w=MathMax(72,width-64);
      if(!V2CreateFieldLabel(*m_host,title_label,title,tabs,tabs,m_window_index,tab_index,x,y,title_w,16))
         return(false);
      y+=18;
      if(!V2CreateFieldLabel(*m_host,period_label,"Periodo",tabs,tabs,m_window_index,tab_index,x,y,width,16))
         return(false);
      y+=16;
      if(!CreateSpinControl(period_spin,tabs,tabs,tab_index,x,y,width,9999.0,0.0,1.0,0,period_value,back,border))
         return(false);
      y+=38;
      if(!V2CreateFieldLabel(*m_host,shift_label,"Deslocamento",tabs,tabs,m_window_index,tab_index,x,y,width,16))
         return(false);
      y+=16;
      if(!CreateSpinControl(shift_spin,tabs,tabs,tab_index,x,y,width,9999.0,0.0,1.0,0,"0",back,border))
         return(false);
      y+=38;
      if(has_type)
        {
         if(!V2CreateFieldLabel(*m_host,type_label,"Tipo de media",tabs,tabs,m_window_index,tab_index,x,y,width,16))
            return(false);
         y+=16;
         if(!CreateComboControl(type_combo,tabs,tabs,tab_index,x,y,width,110,type_items,0,border))
            return(false);
         y+=38;
        }
      if(!V2CreateFieldLabel(*m_host,price_label,"Modo de preco",tabs,tabs,m_window_index,tab_index,x,y,width,16))
         return(false);
      y+=16;
      if(!CreateComboControl(price_combo,tabs,tabs,tab_index,x,y,width,140,price_items,0,border))
         return(false);
      return(true);
     }

   bool CreateCruzVidyaBlock(CTabs &tabs,const int tab_index,const int x,const int width,const color back,const color border,const string title,
                             CTextLabel &title_label,CTextEdit &cmo_spin,CTextEdit &ema_spin,CTextEdit &shift_spin,CComboBox &price_combo,
                             CTextLabel &cmo_label,CTextLabel &ema_label,CTextLabel &shift_label,CTextLabel &price_label,
                             const string &price_items[])
     {
      int y=8;
      const int title_w=MathMax(72,width-64);
      if(!V2CreateFieldLabel(*m_host,title_label,title,tabs,tabs,m_window_index,tab_index,x,y,title_w,16))
         return(false);
      y+=18;
      if(!V2CreateFieldLabel(*m_host,cmo_label,"Periodo CMO",tabs,tabs,m_window_index,tab_index,x,y,width,16))
         return(false);
      y+=16;
      if(!CreateSpinControl(cmo_spin,tabs,tabs,tab_index,x,y,width,9999.0,0.0,1.0,0,"9",back,border))
         return(false);
      y+=38;
      if(!V2CreateFieldLabel(*m_host,ema_label,"Periodo EMA",tabs,tabs,m_window_index,tab_index,x,y,width,16))
         return(false);
      y+=16;
      if(!CreateSpinControl(ema_spin,tabs,tabs,tab_index,x,y,width,9999.0,0.0,1.0,0,"12",back,border))
         return(false);
      y+=38;
      if(!V2CreateFieldLabel(*m_host,shift_label,"Deslocamento",tabs,tabs,m_window_index,tab_index,x,y,width,16))
         return(false);
      y+=16;
      if(!CreateSpinControl(shift_spin,tabs,tabs,tab_index,x,y,width,9999.0,0.0,1.0,0,"0",back,border))
         return(false);
      y+=38;
      if(!V2CreateFieldLabel(*m_host,price_label,"Modo de preco",tabs,tabs,m_window_index,tab_index,x,y,width,16))
         return(false);
      y+=16;
      if(!CreateComboControl(price_combo,tabs,tabs,tab_index,x,y,width,140,price_items,0,border))
         return(false);
      return(true);
     }

   bool CreateSobreIchimokuBlock(CTabs &tabs,const int tab_index,const int x,const int width,const color back,const color border,const string title,
                                 CTextLabel &title_label,CTextEdit &tenkan_spin,CTextEdit &kijun_spin,CTextEdit &senkou_b_spin,
                                 CTextLabel &tenkan_label,CTextLabel &kijun_label,CTextLabel &senkou_b_label)
     {
      int y=8;
      const int title_w=MathMax(72,width-64);
      if(!V2CreateFieldLabel(*m_host,title_label,title,tabs,tabs,m_window_index,tab_index,x,y,title_w,16))
         return(false);
      y+=18;
      if(!V2CreateFieldLabel(*m_host,tenkan_label,"Tenkan-sen",tabs,tabs,m_window_index,tab_index,x,y,width,16))
         return(false);
      y+=16;
      if(!CreateSpinControl(tenkan_spin,tabs,tabs,tab_index,x,y,width,9999.0,1.0,1.0,0,"9",back,border))
         return(false);
      y+=38;
      if(!V2CreateFieldLabel(*m_host,kijun_label,"Kijun-sen",tabs,tabs,m_window_index,tab_index,x,y,width,16))
         return(false);
      y+=16;
      if(!CreateSpinControl(kijun_spin,tabs,tabs,tab_index,x,y,width,9999.0,1.0,1.0,0,"26",back,border))
         return(false);
      y+=38;
      if(!V2CreateFieldLabel(*m_host,senkou_b_label,"Senkou Span B",tabs,tabs,m_window_index,tab_index,x,y,width,16))
         return(false);
      y+=16;
      if(!CreateSpinControl(senkou_b_spin,tabs,tabs,tab_index,x,y,width,9999.0,1.0,1.0,0,"52",back,border))
         return(false);
      return(true);
     }

public:
                     CTab8SinaisMainView(void) : m_host(NULL), m_created(false), m_is_active(false), m_window_index(-1), m_tab_index(-1), m_last_ord_tab(-1), m_last_sobre_tab(-1), m_last_sobre_param_idx(-1), m_last_cruz_tab(-1), m_last_cruz_fast_idx(-1), m_last_cruz_slow_idx(-1) {}

   bool Create(CWndCreate &host,int window_index,CTabs &tabs,const int tab_index)
     {
      if(m_created)
         return(true);

      m_host=&host;
      m_window_index=window_index;
      m_tab_index=tab_index;

      const int tabs_w=tabs.XSize();
      const int content_pad=24;
      const int content_y=44;
      const int content_w=tabs_w-(content_pad*2);
      const int gap=12;
      const int col_w=(content_w-(gap*4))/5;
      const int card_h=520;
      const int field_x=16;
      const int field_w=col_w-32;
      const color card_back=V2_COLOR_CARD_BACK;
      const color card_border=V2_COLOR_CARD_BORDER;
      const color sub_back=V2_COLOR_SURFACE;
      const color field_border=V2_COLOR_FIELD_BORDER;

      if(!V2CreateCard(*m_host,m_card_ordens,tabs,m_window_index,m_tab_index,content_pad,content_y,col_w,card_h,card_back,card_border))
         return(false);
      if(!V2CreateCardTitle(*m_host,m_card_ordens_title,"Tipo de ordens",m_card_ordens,tabs,m_window_index,m_tab_index,16,12,field_w))
         return(false);

      const int order_gap=12;
      const int order_w=(field_w-order_gap)/2;
      if(!m_host.CreateCheckbox(m_ordem_market,"Mercado",m_card_ordens,m_window_index,tabs,m_tab_index,16,44,order_w,true,false,false))
         return(false);
      m_ordem_market.FontSize(10);
      m_ordem_market.LabelColor(V2_COLOR_TEXT_PRIMARY);

      if(!m_host.CreateCheckbox(m_ordem_limit,"Limite",m_card_ordens,m_window_index,tabs,m_tab_index,16+order_w+order_gap,44,order_w,false,false,false))
         return(false);
      m_ordem_limit.FontSize(10);
      m_ordem_limit.LabelColor(V2_COLOR_TEXT_PRIMARY);

      string ord_tab_text[];
      int ord_tab_widths[];
      ArrayResize(ord_tab_text,2);
      ArrayResize(ord_tab_widths,2);
      ord_tab_text[0]="Referencia";
      ord_tab_text[1]="Media";
      ord_tab_widths[0]=(field_w/2);
      ord_tab_widths[1]=field_w-ord_tab_widths[0];

      m_ord_tabs.MainPointer(m_card_ordens);
      tabs.AddToElementsArray(m_tab_index,m_ord_tabs);
      m_ord_tabs.XSize(field_w);
      m_ord_tabs.YSize(card_h-96);
      m_ord_tabs.IsCenterText(true);
      m_ord_tabs.PositionMode(TABS_TOP);
      m_ord_tabs.TabsYSize(22);
      m_ord_tabs.AutoXResizeMode(false);
      m_ord_tabs.AutoYResizeMode(false);
      m_ord_tabs.BackColorPressed(sub_back);
      m_ord_tabs.BorderColor(card_border);
      m_ord_tabs.BorderColorHover(card_border);
      m_ord_tabs.BorderColorPressed(card_border);
      for(int i=0;i<2;i++)
         m_ord_tabs.AddTab(ord_tab_text[i],ord_tab_widths[i]);
      if(!m_ord_tabs.CreateTabs(16,84))
         return(false);
      CWndContainer::AddToElementsArray(m_window_index,m_ord_tabs);

      CButtonsGroup *ord_bg=m_ord_tabs.GetButtonsGroupPointer();
      if(ord_bg!=NULL)
        {
         for(int i=0;i<2;i++)
           {
            ord_bg.GetButtonPointer(i).FontSize(8);
            ord_bg.GetButtonPointer(i).BackColor(C'39,54,78');
            ord_bg.GetButtonPointer(i).BackColorHover(C'62,79,101');
            ord_bg.GetButtonPointer(i).BackColorPressed(C'226,114,64');
            ord_bg.GetButtonPointer(i).BorderColor(C'18,29,43');
            ord_bg.GetButtonPointer(i).BorderColorHover(C'62,79,101');
            ord_bg.GetButtonPointer(i).BorderColorPressed(C'240,140,86');
            ord_bg.GetButtonPointer(i).LabelColor(clrWhite);
            ord_bg.GetButtonPointer(i).LabelColorHover(clrWhite);
            ord_bg.GetButtonPointer(i).LabelColorPressed(clrWhite);
           }
        }

      const int ord_content_x=12;
      const int ord_content_y=6;
      const int ord_content_w=field_w-(ord_content_x*2);
      const int ord_sub_y=ord_content_y+18;
      const int ord_sub_h=(card_h-96)-ord_sub_y-10;

      if(!m_host.CreateCheckbox(m_ord_ref_check,"Referencia",m_ord_tabs,m_window_index,m_ord_tabs,0,ord_content_x,ord_content_y,140,true,false,false))
         return(false);
      m_ord_ref_check.FontSize(10);
      m_ord_ref_check.LabelColor(V2_COLOR_TEXT_PRIMARY);

      if(!m_host.CreateCheckbox(m_ord_media_check,"Media",m_ord_tabs,m_window_index,m_ord_tabs,1,ord_content_x,ord_content_y,140,false,false,false))
         return(false);
      m_ord_media_check.FontSize(10);
      m_ord_media_check.LabelColor(V2_COLOR_TEXT_PRIMARY);

      if(!V2CreateCard(*m_host,m_ord_ref_card,m_ord_tabs,m_window_index,0,ord_content_x,ord_sub_y,ord_content_w,ord_sub_h,sub_back,card_border))
         return(false);
      if(!V2CreateCard(*m_host,m_ord_media_card,m_ord_tabs,m_window_index,1,ord_content_x,ord_sub_y,ord_content_w,ord_sub_h,sub_back,card_border))
         return(false);

      string base_items[];
      ArrayResize(base_items,6);
      base_items[0]="Maxima";
      base_items[1]="Minima";
      base_items[2]="Abertura";
      base_items[3]="Fechamento";
      base_items[4]="Corpo";
      base_items[5]="Pavios";

      string candle_items[];
      V2ItemsPosicaoReferencia(candle_items);

      string expire_items[];
      V2ItemsExpirar(expire_items);

      int y=10;
      if(!V2CreateFieldLabel(*m_host,m_ord_ref_base_label,"Referencia:",m_ord_ref_card,m_ord_tabs,m_window_index,0,field_x,y,ord_content_w-24,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_ord_ref_base_combo,m_ord_ref_card,m_ord_tabs,0,field_x,y,ord_content_w-24,120,base_items,0,card_border))
         return(false);
      y+=28;
      if(!V2CreateFieldLabel(*m_host,m_ord_ref_candle_label,"Candle:",m_ord_ref_card,m_ord_tabs,m_window_index,0,field_x,y,ord_content_w-24,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_ord_ref_candle_combo,m_ord_ref_card,m_ord_tabs,0,field_x,y,ord_content_w-24,120,candle_items,0,card_border))
         return(false);
      y+=28;
      if(!V2CreateFieldLabel(*m_host,m_ord_ref_distance_label,"Distancia",m_ord_ref_card,m_ord_tabs,m_window_index,0,field_x,y,ord_content_w-24,16))
         return(false);
      y+=18;
      if(!CreateSpinControl(m_ord_ref_distance_spin,m_ord_ref_card,m_ord_tabs,0,field_x,y,ord_content_w-24,9999.0,0.0,1.0,0,"0",sub_back,card_border))
         return(false);
      y+=28;
      if(!V2CreateFieldLabel(*m_host,m_ord_ref_expire_label,"Expirar:",m_ord_ref_card,m_ord_tabs,m_window_index,0,field_x,y,ord_content_w-24,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_ord_ref_expire_combo,m_ord_ref_card,m_ord_tabs,0,field_x,y,ord_content_w-24,120,expire_items,0,card_border))
         return(false);

      y=10;
      if(!V2CreateFieldLabel(*m_host,m_ord_media_candles_label,"Cand. media",m_ord_media_card,m_ord_tabs,m_window_index,1,field_x,y,ord_content_w-24,16))
         return(false);
      y+=18;
      if(!CreateSpinControl(m_ord_media_candles_spin,m_ord_media_card,m_ord_tabs,1,field_x,y,ord_content_w-24,9999.0,0.0,1.0,0,"0",sub_back,card_border))
         return(false);
      y+=28;
      if(!V2CreateFieldLabel(*m_host,m_ord_media_base_label,"Referencia:",m_ord_media_card,m_ord_tabs,m_window_index,1,field_x,y,ord_content_w-24,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_ord_media_base_combo,m_ord_media_card,m_ord_tabs,1,field_x,y,ord_content_w-24,120,base_items,0,card_border))
         return(false);
      y+=28;
      if(!V2CreateFieldLabel(*m_host,m_ord_media_distance_label,"Distancia",m_ord_media_card,m_ord_tabs,m_window_index,1,field_x,y,ord_content_w-24,16))
         return(false);
      y+=18;
      if(!CreateSpinControl(m_ord_media_distance_spin,m_ord_media_card,m_ord_tabs,1,field_x,y,ord_content_w-24,9999.0,0.0,1.0,0,"0",sub_back,card_border))
         return(false);
      y+=28;
      if(!V2CreateFieldLabel(*m_host,m_ord_media_expire_label,"Expirar:",m_ord_media_card,m_ord_tabs,m_window_index,1,field_x,y,ord_content_w-24,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_ord_media_expire_combo,m_ord_media_card,m_ord_tabs,1,field_x,y,ord_content_w-24,120,expire_items,0,card_border))
         return(false);

      m_ord_tabs.SelectTab(0);
      m_ord_tabs.ShowTabElements();
      m_last_ord_tab=0;

      const int filtro_x=content_pad+col_w+gap;
      if(!V2CreateCard(*m_host,m_card_filtro,tabs,m_window_index,m_tab_index,filtro_x,content_y,col_w,card_h,card_back,card_border))
         return(false);
      if(!V2CreateCardTitle(*m_host,m_card_filtro_title,"Usar filtro",m_card_filtro,tabs,m_window_index,m_tab_index,16,12,field_w))
         return(false);
      if(!m_host.CreateCheckbox(m_use_filtro,"Ativar filtro",m_card_filtro,m_window_index,tabs,m_tab_index,16,44,field_w,false,false,false))
         return(false);
      m_use_filtro.FontSize(10);
      m_use_filtro.LabelColor(V2_COLOR_TEXT_PRIMARY);

      string stop_type_items[];
      V2ItemsStopTipo(stop_type_items);
      string tf_items[];
      V2ItemsTempoGrafico(tf_items);

      y=76;
      if(!V2CreateFieldLabel(*m_host,m_filtro_padrao_label,"Medir em",m_card_filtro,tabs,m_window_index,m_tab_index,field_x,y,field_w,18))
         return(false);
      y+=22;
      if(!CreateComboControl(m_filtro_padrao_combo,m_card_filtro,tabs,m_tab_index,field_x,y,field_w,80,stop_type_items,0,field_border))
         return(false);
      y+=42;
      if(!V2CreateFieldLabel(*m_host,m_filtro_time_label,"Tempo grafico",m_card_filtro,tabs,m_window_index,m_tab_index,field_x,y,field_w,18))
         return(false);
      y+=22;
      if(!CreateComboControl(m_filtro_time_combo,m_card_filtro,tabs,m_tab_index,field_x,y,field_w,200,tf_items,0,field_border))
         return(false);
      y+=42;

      string filter_labels[];
      ArrayResize(filter_labels,4);
      filter_labels[0]="Tam. min da vela";
      filter_labels[1]="Tam. max";
      filter_labels[2]="Min. pavios";
      filter_labels[3]="Max. pavios";

      for(int i=0;i<4;i++)
        {
         if(!V2CreateFieldLabel(*m_host,m_filtro_range_label[i],filter_labels[i],m_card_filtro,tabs,m_window_index,m_tab_index,field_x,y,field_w,16))
            return(false);
         y+=18;
         if(!CreateSpinControl(m_filtro_range_spin[i],m_card_filtro,tabs,m_tab_index,field_x,y,field_w,9999.0,0.0,1.0,0,"0",card_back,field_border))
            return(false);
         y+=28;
        }

      const int canais_x=content_pad+(col_w+gap)*2;
      if(!V2CreateCard(*m_host,m_card_canais,tabs,m_window_index,m_tab_index,canais_x,content_y,col_w,card_h,card_back,card_border))
         return(false);
      if(!V2CreateCardTitle(*m_host,m_card_canais_title,"Canais de bandas",m_card_canais,tabs,m_window_index,m_tab_index,16,12,field_w))
         return(false);
      if(!V2CreateFieldLabel(*m_host,m_canais_label,"Usar canais de bandas?",m_card_canais,tabs,m_window_index,m_tab_index,16,40,field_w,18))
         return(false);
      if(!m_host.CreateCheckbox(m_canais_yes,"Sim",m_card_canais,m_window_index,tabs,m_tab_index,16,58,60,false,false,false))
         return(false);
      m_canais_yes.FontSize(10);
      m_canais_yes.LabelColor(V2_COLOR_TEXT_SECONDARY);
      if(!m_host.CreateCheckbox(m_canais_no,"Nao",m_card_canais,m_window_index,tabs,m_tab_index,86,58,60,true,false,false))
         return(false);
      m_canais_no.FontSize(10);
      m_canais_no.LabelColor(V2_COLOR_TEXT_SECONDARY);

      string canais_indic_items[];
      ArrayResize(canais_indic_items,5);
      canais_indic_items[0]="Bandas de Bollinger";
      canais_indic_items[1]="Envelope";
      canais_indic_items[2]="Keltner";
      canais_indic_items[3]="Donchian";
      canais_indic_items[4]="Canal ATR";

      string canais_type_items[];
      ArrayResize(canais_type_items,6);
      canais_type_items[0]="Fechou fora";
      canais_type_items[1]="Fechou dentro e saiu";
      canais_type_items[2]="Fechou dentro e fechou fora";
      canais_type_items[3]="Fechou fora e voltou";
      canais_type_items[4]="Fechou fora e fechou dentro";
      canais_type_items[5]="Estando fora";

      string canais_price_items[];
      ArrayResize(canais_price_items,7);
      canais_price_items[0]="Fechamento";
      canais_price_items[1]="Abertura";
      canais_price_items[2]="Maximo";
      canais_price_items[3]="Minimo";
      canais_price_items[4]="Mediano";
      canais_price_items[5]="Tipico";
      canais_price_items[6]="Medio";

      y=84;
      if(!V2CreateFieldLabel(*m_host,m_canais_indic_label,"Indicador",m_card_canais,tabs,m_window_index,m_tab_index,field_x,y,field_w,16))
         return(false);
      y+=16;
      if(!CreateComboControl(m_canais_indic_combo,m_card_canais,tabs,m_tab_index,field_x,y,field_w,120,canais_indic_items,0,field_border))
         return(false);
      y+=42;
      if(!V2CreateFieldLabel(*m_host,m_canais_type_label,"Sinais",m_card_canais,tabs,m_window_index,m_tab_index,field_x,y,field_w,16))
         return(false);
      y+=16;
      if(!CreateComboControl(m_canais_type_combo,m_card_canais,tabs,m_tab_index,field_x,y,field_w,160,canais_type_items,0,field_border))
         return(false);

      y+=42;
      if(!V2CreateFieldLabel(*m_host,m_canais_period_label,"Periodo",m_card_canais,tabs,m_window_index,m_tab_index,field_x,y,field_w,16))
         return(false);
      y+=16;
      if(!CreateSpinControl(m_canais_period_spin,m_card_canais,tabs,m_tab_index,field_x,y,field_w,9999.0,0.0,1.0,0,"20",card_back,field_border))
         return(false);
      y+=38;
      if(!V2CreateFieldLabel(*m_host,m_canais_deviation_label,"Desvio",m_card_canais,tabs,m_window_index,m_tab_index,field_x,y,field_w,16))
         return(false);
      y+=16;
      if(!CreateSpinControl(m_canais_deviation_spin,m_card_canais,tabs,m_tab_index,field_x,y,field_w,9999.0,0.0,0.1,1,"2.0",card_back,field_border))
         return(false);
      y+=38;
      if(!V2CreateFieldLabel(*m_host,m_canais_shift_label,"Deslocamento",m_card_canais,tabs,m_window_index,m_tab_index,field_x,y,field_w,16))
         return(false);
      y+=16;
      if(!CreateSpinControl(m_canais_shift_spin,m_card_canais,tabs,m_tab_index,field_x,y,field_w,9999.0,0.0,1.0,0,"0",card_back,field_border))
         return(false);
      y+=38;
      if(!V2CreateFieldLabel(*m_host,m_canais_price_label,"Modo de preco",m_card_canais,tabs,m_window_index,m_tab_index,field_x,y,field_w,16))
         return(false);
      y+=16;
      if(!CreateComboControl(m_canais_price_combo,m_card_canais,tabs,m_tab_index,field_x,y,field_w,160,canais_price_items,0,field_border))
         return(false);

      const int cruz_x=content_pad+(col_w+gap)*3;
      if(!V2CreateCard(*m_host,m_card_cruz,tabs,m_window_index,m_tab_index,cruz_x,content_y,col_w,card_h,card_back,card_border))
         return(false);
      if(!V2CreateCardTitle(*m_host,m_card_cruz_title,"Cruzamentos",m_card_cruz,tabs,m_window_index,m_tab_index,16,12,field_w))
         return(false);
      if(!V2CreateFieldLabel(*m_host,m_cruz_label,"Usar cruzamentos",m_card_cruz,tabs,m_window_index,m_tab_index,16,40,field_w,18))
         return(false);
      if(!m_host.CreateCheckbox(m_cruz_yes,"Sim",m_card_cruz,m_window_index,tabs,m_tab_index,16,58,60,false,false,false))
         return(false);
      m_cruz_yes.FontSize(10);
      m_cruz_yes.LabelColor(V2_COLOR_TEXT_SECONDARY);
      if(!m_host.CreateCheckbox(m_cruz_no,"Nao",m_card_cruz,m_window_index,tabs,m_tab_index,86,58,60,true,false,false))
         return(false);
      m_cruz_no.FontSize(10);
      m_cruz_no.LabelColor(V2_COLOR_TEXT_SECONDARY);

      string cruz_tab_text[];
      int cruz_tab_widths[];
      ArrayResize(cruz_tab_text,3);
      ArrayResize(cruz_tab_widths,3);
      cruz_tab_text[0]="Geral";
      cruz_tab_text[1]="Rapida";
      cruz_tab_text[2]="Lenta";
      cruz_tab_widths[0]=field_w/3;
      cruz_tab_widths[1]=field_w/3;
      cruz_tab_widths[2]=field_w-cruz_tab_widths[0]-cruz_tab_widths[1];

      const int cruz_tabs_y=106;
      const int cruz_tabs_bottom_gap=12;
      const int cruz_tabs_h=card_h-cruz_tabs_y-cruz_tabs_bottom_gap;

      m_cruz_tabs.MainPointer(m_card_cruz);
      tabs.AddToElementsArray(m_tab_index,m_cruz_tabs);
      m_cruz_tabs.XSize(field_w);
      m_cruz_tabs.YSize(cruz_tabs_h);
      m_cruz_tabs.IsCenterText(true);
      m_cruz_tabs.PositionMode(TABS_TOP);
      m_cruz_tabs.TabsYSize(22);
      m_cruz_tabs.AutoXResizeMode(false);
      m_cruz_tabs.AutoYResizeMode(false);
      m_cruz_tabs.BackColorPressed(sub_back);
      m_cruz_tabs.BorderColor(card_border);
      m_cruz_tabs.BorderColorHover(card_border);
      m_cruz_tabs.BorderColorPressed(card_border);
      for(int i=0;i<3;i++)
         m_cruz_tabs.AddTab(cruz_tab_text[i],cruz_tab_widths[i]);
      if(!m_cruz_tabs.CreateTabs(16,cruz_tabs_y))
         return(false);
      CWndContainer::AddToElementsArray(m_window_index,m_cruz_tabs);

      CButtonsGroup *cruz_bg=m_cruz_tabs.GetButtonsGroupPointer();
      if(cruz_bg!=NULL)
        {
         for(int i=0;i<3;i++)
           {
            cruz_bg.GetButtonPointer(i).FontSize(8);
            cruz_bg.GetButtonPointer(i).BackColor(C'39,54,78');
            cruz_bg.GetButtonPointer(i).BackColorHover(C'62,79,101');
            cruz_bg.GetButtonPointer(i).BackColorPressed(C'226,114,64');
            cruz_bg.GetButtonPointer(i).BorderColor(C'18,29,43');
            cruz_bg.GetButtonPointer(i).BorderColorHover(C'62,79,101');
            cruz_bg.GetButtonPointer(i).BorderColorPressed(C'240,140,86');
            cruz_bg.GetButtonPointer(i).LabelColor(clrWhite);
            cruz_bg.GetButtonPointer(i).LabelColorHover(clrWhite);
            cruz_bg.GetButtonPointer(i).LabelColorPressed(clrWhite);
           }
        }

      string cruz_indic_items[];
      ArrayResize(cruz_indic_items,10);
      cruz_indic_items[0]="Nao usar";
      cruz_indic_items[1]="Fechamento da vela";
      cruz_indic_items[2]="Abertura da vela";
      cruz_indic_items[3]="Maxima da vela";
      cruz_indic_items[4]="Minima da vela";
      cruz_indic_items[5]="Media movel";
      cruz_indic_items[6]="VIDYA";
      cruz_indic_items[7]="DEMA";
      cruz_indic_items[8]="TEMA";
      cruz_indic_items[9]="FRAMA";

      string cruz_signal_items[];
      ArrayResize(cruz_signal_items,3);
      cruz_signal_items[0]="Cruzamento para baixo";
      cruz_signal_items[1]="Cruzamento para cima";
      cruz_signal_items[2]="Ambos";

      string cruz_price_items[];
      ArrayResize(cruz_price_items,7);
      cruz_price_items[0]="Fechamento";
      cruz_price_items[1]="Abertura";
      cruz_price_items[2]="Maximo";
      cruz_price_items[3]="Minimo";
      cruz_price_items[4]="Mediano";
      cruz_price_items[5]="Tipico";
      cruz_price_items[6]="Medio";

      string cruz_ma_items[];
      ArrayResize(cruz_ma_items,5);
      cruz_ma_items[0]="Simples";
      cruz_ma_items[1]="Exponencial";
      cruz_ma_items[2]="Suavizada";
      cruz_ma_items[3]="Linear ponderada";
      cruz_ma_items[4]="Smoothed";

      const int cruz_content_x=12;
      const int cruz_content_w=field_w-24;

      y=10;
      if(!V2CreateFieldLabel(*m_host,m_cruz_fast_label,"Linha rapida",m_cruz_tabs,m_cruz_tabs,m_window_index,0,cruz_content_x,y,cruz_content_w,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_cruz_fast_combo,m_cruz_tabs,m_cruz_tabs,0,cruz_content_x,y,cruz_content_w,120,cruz_indic_items,0,card_border))
         return(false);
      y+=36;
      if(!V2CreateFieldLabel(*m_host,m_cruz_signal_label,"Sinal",m_cruz_tabs,m_cruz_tabs,m_window_index,0,cruz_content_x,y,cruz_content_w,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_cruz_signal_combo,m_cruz_tabs,m_cruz_tabs,0,cruz_content_x,y,cruz_content_w,100,cruz_signal_items,0,card_border))
         return(false);
      y+=36;
      if(!V2CreateFieldLabel(*m_host,m_cruz_slow_label,"Linha lenta",m_cruz_tabs,m_cruz_tabs,m_window_index,0,cruz_content_x,y,cruz_content_w,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_cruz_slow_combo,m_cruz_tabs,m_cruz_tabs,0,cruz_content_x,y,cruz_content_w,120,cruz_indic_items,0,card_border))
         return(false);
      y+=40;
      if(!m_host.CreateTextLabel(m_cruz_note,"As abas Rapida e Lenta acompanham o indicador escolhido aqui.",m_cruz_tabs,m_window_index,m_cruz_tabs,0,cruz_content_x,y,cruz_content_w,42))
         return(false);
      m_cruz_note.FontSize(10);
      m_cruz_note.LabelColor(V2_COLOR_TEXT_SECONDARY);

      y=10;
      if(!V2CreateFieldLabel(*m_host,m_cruz_fast_indic_label,"Indicador rapido",m_cruz_tabs,m_cruz_tabs,m_window_index,1,cruz_content_x,y,cruz_content_w,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_cruz_fast_indic_combo,m_cruz_tabs,m_cruz_tabs,1,cruz_content_x,y,cruz_content_w,120,cruz_indic_items,0,card_border))
         return(false);
      y+=34;
      if(!V2CreateCard(*m_host,m_cruz_fast_param_card,m_cruz_tabs,m_window_index,1,cruz_content_x,y,cruz_content_w,cruz_tabs_h-y-10,sub_back,card_border))
         return(false);

      m_cruz_fast_param_tabs.MainPointer(m_cruz_fast_param_card);
      m_cruz_tabs.AddToElementsArray(1,m_cruz_fast_param_tabs);
      m_cruz_fast_param_tabs.XSize(cruz_content_w-24);
      m_cruz_fast_param_tabs.YSize(cruz_tabs_h-y-34);
      m_cruz_fast_param_tabs.IsCenterText(true);
      m_cruz_fast_param_tabs.PositionMode(TABS_TOP);
      m_cruz_fast_param_tabs.TabsYSize(0);
      m_cruz_fast_param_tabs.AutoXResizeMode(false);
      m_cruz_fast_param_tabs.AutoYResizeMode(false);
      m_cruz_fast_param_tabs.BackColor(sub_back);
      m_cruz_fast_param_tabs.BackColorHover(sub_back);
      m_cruz_fast_param_tabs.BackColorPressed(sub_back);
      m_cruz_fast_param_tabs.BorderColor(sub_back);
      m_cruz_fast_param_tabs.BorderColorHover(sub_back);
      m_cruz_fast_param_tabs.BorderColorPressed(sub_back);
      for(int i=0;i<5;i++)
         m_cruz_fast_param_tabs.AddTab(IntegerToString(i+1),0);
      if(!m_cruz_fast_param_tabs.CreateTabs(12,12))
         return(false);
      CWndContainer::AddToElementsArray(m_window_index,m_cruz_fast_param_tabs);

      y=10;
      if(!V2CreateFieldLabel(*m_host,m_cruz_slow_indic_label,"Indicador lento",m_cruz_tabs,m_cruz_tabs,m_window_index,2,cruz_content_x,y,cruz_content_w,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_cruz_slow_indic_combo,m_cruz_tabs,m_cruz_tabs,2,cruz_content_x,y,cruz_content_w,120,cruz_indic_items,1,card_border))
         return(false);
      y+=34;
      if(!V2CreateCard(*m_host,m_cruz_slow_param_card,m_cruz_tabs,m_window_index,2,cruz_content_x,y,cruz_content_w,cruz_tabs_h-y-10,sub_back,card_border))
         return(false);

      m_cruz_slow_param_tabs.MainPointer(m_cruz_slow_param_card);
      m_cruz_tabs.AddToElementsArray(2,m_cruz_slow_param_tabs);
      m_cruz_slow_param_tabs.XSize(cruz_content_w-24);
      m_cruz_slow_param_tabs.YSize(cruz_tabs_h-y-34);
      m_cruz_slow_param_tabs.IsCenterText(true);
      m_cruz_slow_param_tabs.PositionMode(TABS_TOP);
      m_cruz_slow_param_tabs.TabsYSize(0);
      m_cruz_slow_param_tabs.AutoXResizeMode(false);
      m_cruz_slow_param_tabs.AutoYResizeMode(false);
      m_cruz_slow_param_tabs.BackColor(sub_back);
      m_cruz_slow_param_tabs.BackColorHover(sub_back);
      m_cruz_slow_param_tabs.BackColorPressed(sub_back);
      m_cruz_slow_param_tabs.BorderColor(sub_back);
      m_cruz_slow_param_tabs.BorderColorHover(sub_back);
      m_cruz_slow_param_tabs.BorderColorPressed(sub_back);
      for(int i=0;i<5;i++)
         m_cruz_slow_param_tabs.AddTab(IntegerToString(i+1),0);
      if(!m_cruz_slow_param_tabs.CreateTabs(12,12))
         return(false);
      CWndContainer::AddToElementsArray(m_window_index,m_cruz_slow_param_tabs);

      CButtonsGroup *cruz_fast_bg=m_cruz_fast_param_tabs.GetButtonsGroupPointer();
      if(cruz_fast_bg!=NULL)
        {
         for(int i=0;i<5;i++)
           {
            cruz_fast_bg.GetButtonPointer(i).FontSize(1);
            cruz_fast_bg.GetButtonPointer(i).LabelXGap(0);
            cruz_fast_bg.GetButtonPointer(i).LabelYGap(0);
            cruz_fast_bg.GetButtonPointer(i).BackColor(sub_back);
            cruz_fast_bg.GetButtonPointer(i).BackColorHover(sub_back);
            cruz_fast_bg.GetButtonPointer(i).BackColorPressed(sub_back);
            cruz_fast_bg.GetButtonPointer(i).BorderColor(sub_back);
            cruz_fast_bg.GetButtonPointer(i).BorderColorHover(sub_back);
            cruz_fast_bg.GetButtonPointer(i).BorderColorPressed(sub_back);
            cruz_fast_bg.GetButtonPointer(i).LabelColor(sub_back);
            cruz_fast_bg.GetButtonPointer(i).LabelColorHover(sub_back);
            cruz_fast_bg.GetButtonPointer(i).LabelColorPressed(sub_back);
           }
        }
      CButtonsGroup *cruz_slow_bg=m_cruz_slow_param_tabs.GetButtonsGroupPointer();
      if(cruz_slow_bg!=NULL)
        {
         for(int i=0;i<5;i++)
           {
            cruz_slow_bg.GetButtonPointer(i).FontSize(1);
            cruz_slow_bg.GetButtonPointer(i).LabelXGap(0);
            cruz_slow_bg.GetButtonPointer(i).LabelYGap(0);
            cruz_slow_bg.GetButtonPointer(i).BackColor(sub_back);
            cruz_slow_bg.GetButtonPointer(i).BackColorHover(sub_back);
            cruz_slow_bg.GetButtonPointer(i).BackColorPressed(sub_back);
            cruz_slow_bg.GetButtonPointer(i).BorderColor(sub_back);
            cruz_slow_bg.GetButtonPointer(i).BorderColorHover(sub_back);
            cruz_slow_bg.GetButtonPointer(i).BorderColorPressed(sub_back);
            cruz_slow_bg.GetButtonPointer(i).LabelColor(sub_back);
            cruz_slow_bg.GetButtonPointer(i).LabelColorHover(sub_back);
            cruz_slow_bg.GetButtonPointer(i).LabelColorPressed(sub_back);
           }
        }

      const int cruz_param_x=12;
      const int cruz_param_w=cruz_content_w-48;
      const int cruz_param_y=8;

      if(!CreateCruzParamBlock(m_cruz_fast_param_tabs,0,cruz_param_x,cruz_param_y,cruz_param_w,sub_back,card_border,"Media movel",
                               m_cruz_fast_param_title[0],m_cruz_fast_ma_period_spin,m_cruz_fast_ma_shift_spin,m_cruz_fast_ma_type_combo,m_cruz_fast_ma_price_combo,
                               m_cruz_fast_ma_period_label,m_cruz_fast_ma_shift_label,m_cruz_fast_ma_type_label,m_cruz_fast_ma_price_label,"14",true,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCruzVidyaBlock(m_cruz_fast_param_tabs,1,cruz_param_x,cruz_param_w,sub_back,card_border,"VIDYA",
                               m_cruz_fast_param_title[1],m_cruz_fast_vidya_cmo_spin,m_cruz_fast_vidya_ema_spin,m_cruz_fast_vidya_shift_spin,m_cruz_fast_vidya_price_combo,
                               m_cruz_fast_vidya_cmo_label,m_cruz_fast_vidya_ema_label,m_cruz_fast_vidya_shift_label,m_cruz_fast_vidya_price_label,cruz_price_items))
         return(false);
      if(!CreateCruzParamBlock(m_cruz_fast_param_tabs,2,cruz_param_x,cruz_param_y,cruz_param_w,sub_back,card_border,"DEMA",
                               m_cruz_fast_param_title[2],m_cruz_fast_dema_period_spin,m_cruz_fast_dema_shift_spin,m_cruz_fast_ma_type_combo,m_cruz_fast_dema_price_combo,
                               m_cruz_fast_dema_period_label,m_cruz_fast_dema_shift_label,m_cruz_fast_ma_type_label,m_cruz_fast_dema_price_label,"14",false,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCruzParamBlock(m_cruz_fast_param_tabs,3,cruz_param_x,cruz_param_y,cruz_param_w,sub_back,card_border,"TEMA",
                               m_cruz_fast_param_title[3],m_cruz_fast_tema_period_spin,m_cruz_fast_tema_shift_spin,m_cruz_fast_ma_type_combo,m_cruz_fast_tema_price_combo,
                               m_cruz_fast_tema_period_label,m_cruz_fast_tema_shift_label,m_cruz_fast_ma_type_label,m_cruz_fast_tema_price_label,"14",false,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCruzParamBlock(m_cruz_fast_param_tabs,4,cruz_param_x,cruz_param_y,cruz_param_w,sub_back,card_border,"FRAMA",
                               m_cruz_fast_param_title[4],m_cruz_fast_frama_period_spin,m_cruz_fast_frama_shift_spin,m_cruz_fast_ma_type_combo,m_cruz_fast_frama_price_combo,
                               m_cruz_fast_frama_period_label,m_cruz_fast_frama_shift_label,m_cruz_fast_ma_type_label,m_cruz_fast_frama_price_label,"14",false,cruz_ma_items,cruz_price_items))
         return(false);

      if(!CreateCruzParamBlock(m_cruz_slow_param_tabs,0,cruz_param_x,cruz_param_y,cruz_param_w,sub_back,card_border,"Media movel",
                               m_cruz_slow_param_title[0],m_cruz_slow_ma_period_spin,m_cruz_slow_ma_shift_spin,m_cruz_slow_ma_type_combo,m_cruz_slow_ma_price_combo,
                               m_cruz_slow_ma_period_label,m_cruz_slow_ma_shift_label,m_cruz_slow_ma_type_label,m_cruz_slow_ma_price_label,"21",true,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCruzVidyaBlock(m_cruz_slow_param_tabs,1,cruz_param_x,cruz_param_w,sub_back,card_border,"VIDYA",
                               m_cruz_slow_param_title[1],m_cruz_slow_vidya_cmo_spin,m_cruz_slow_vidya_ema_spin,m_cruz_slow_vidya_shift_spin,m_cruz_slow_vidya_price_combo,
                               m_cruz_slow_vidya_cmo_label,m_cruz_slow_vidya_ema_label,m_cruz_slow_vidya_shift_label,m_cruz_slow_vidya_price_label,cruz_price_items))
         return(false);
      if(!CreateCruzParamBlock(m_cruz_slow_param_tabs,2,cruz_param_x,cruz_param_y,cruz_param_w,sub_back,card_border,"DEMA",
                               m_cruz_slow_param_title[2],m_cruz_slow_dema_period_spin,m_cruz_slow_dema_shift_spin,m_cruz_slow_ma_type_combo,m_cruz_slow_dema_price_combo,
                               m_cruz_slow_dema_period_label,m_cruz_slow_dema_shift_label,m_cruz_slow_ma_type_label,m_cruz_slow_dema_price_label,"21",false,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCruzParamBlock(m_cruz_slow_param_tabs,3,cruz_param_x,cruz_param_y,cruz_param_w,sub_back,card_border,"TEMA",
                               m_cruz_slow_param_title[3],m_cruz_slow_tema_period_spin,m_cruz_slow_tema_shift_spin,m_cruz_slow_ma_type_combo,m_cruz_slow_tema_price_combo,
                               m_cruz_slow_tema_period_label,m_cruz_slow_tema_shift_label,m_cruz_slow_ma_type_label,m_cruz_slow_tema_price_label,"21",false,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCruzParamBlock(m_cruz_slow_param_tabs,4,cruz_param_x,cruz_param_y,cruz_param_w,sub_back,card_border,"FRAMA",
                               m_cruz_slow_param_title[4],m_cruz_slow_frama_period_spin,m_cruz_slow_frama_shift_spin,m_cruz_slow_ma_type_combo,m_cruz_slow_frama_price_combo,
                               m_cruz_slow_frama_period_label,m_cruz_slow_frama_shift_label,m_cruz_slow_ma_type_label,m_cruz_slow_frama_price_label,"21",false,cruz_ma_items,cruz_price_items))
         return(false);

      m_cruz_fast_param_tabs.SelectTab(0);
      m_cruz_fast_param_tabs.ShowTabElements();
      m_cruz_slow_param_tabs.SelectTab(1);
      m_cruz_slow_param_tabs.ShowTabElements();
      m_cruz_tabs.SelectTab(0);
      m_cruz_tabs.ShowTabElements();
      m_last_cruz_tab=0;
      m_last_cruz_fast_idx=0;
      m_last_cruz_slow_idx=1;
      const int sobre_x=content_pad+(col_w+gap)*4;
      if(!V2CreateCard(*m_host,m_card_sobre,tabs,m_window_index,m_tab_index,sobre_x,content_y,col_w,card_h,card_back,card_border))
         return(false);
      if(!V2CreateCardTitle(*m_host,m_card_sobre_title,"Sobrecomprado / sobrevenda",m_card_sobre,tabs,m_window_index,m_tab_index,16,12,field_w))
         return(false);
      if(!m_host.CreateCheckbox(m_use_sobre,"Usar sobrecomprado / sobrevenda",m_card_sobre,m_window_index,tabs,m_tab_index,16,44,field_w,false,false,false))
         return(false);
      m_use_sobre.FontSize(10);
      m_use_sobre.LabelColor(V2_COLOR_TEXT_PRIMARY);

      string sobre_tab_text[];
      int sobre_tab_widths[];
      ArrayResize(sobre_tab_text,2);
      ArrayResize(sobre_tab_widths,2);
      sobre_tab_text[0]="Indicador";
      sobre_tab_text[1]="Parametros";
      sobre_tab_widths[0]=field_w/2;
      sobre_tab_widths[1]=field_w-sobre_tab_widths[0];

      m_sobre_tabs.MainPointer(m_card_sobre);
      tabs.AddToElementsArray(m_tab_index,m_sobre_tabs);
      m_sobre_tabs.XSize(field_w);
      m_sobre_tabs.YSize(card_h-96);
      m_sobre_tabs.IsCenterText(true);
      m_sobre_tabs.PositionMode(TABS_TOP);
      m_sobre_tabs.TabsYSize(22);
      m_sobre_tabs.AutoXResizeMode(false);
      m_sobre_tabs.AutoYResizeMode(false);
      m_sobre_tabs.BackColorPressed(sub_back);
      m_sobre_tabs.BorderColor(card_border);
      m_sobre_tabs.BorderColorHover(card_border);
      m_sobre_tabs.BorderColorPressed(card_border);
      for(int i=0;i<2;i++)
         m_sobre_tabs.AddTab(sobre_tab_text[i],sobre_tab_widths[i]);
      if(!m_sobre_tabs.CreateTabs(16,84))
         return(false);
      CWndContainer::AddToElementsArray(m_window_index,m_sobre_tabs);

      CButtonsGroup *sobre_bg=m_sobre_tabs.GetButtonsGroupPointer();
      if(sobre_bg!=NULL)
        {
         for(int i=0;i<2;i++)
           {
            sobre_bg.GetButtonPointer(i).FontSize(8);
            sobre_bg.GetButtonPointer(i).BackColor(C'39,54,78');
            sobre_bg.GetButtonPointer(i).BackColorHover(C'62,79,101');
            sobre_bg.GetButtonPointer(i).BackColorPressed(C'226,114,64');
            sobre_bg.GetButtonPointer(i).BorderColor(C'18,29,43');
            sobre_bg.GetButtonPointer(i).BorderColorHover(C'62,79,101');
            sobre_bg.GetButtonPointer(i).BorderColorPressed(C'240,140,86');
            sobre_bg.GetButtonPointer(i).LabelColor(clrWhite);
            sobre_bg.GetButtonPointer(i).LabelColorHover(clrWhite);
            sobre_bg.GetButtonPointer(i).LabelColorPressed(clrWhite);
           }
        }

      string sobre_indic_items[];
      ArrayResize(sobre_indic_items,15);
      sobre_indic_items[0]="MACD";
      sobre_indic_items[1]="Estocastico";
      sobre_indic_items[2]="RSI";
      sobre_indic_items[3]="DeMarker";
      sobre_indic_items[4]="Regressao linear";
      sobre_indic_items[5]="Desvio da media";
      sobre_indic_items[6]="MFI";
      sobre_indic_items[7]="Bears Power";
      sobre_indic_items[8]="Bulls Power";
      sobre_indic_items[9]="CCI";
      sobre_indic_items[10]="Ichimoku Tenkan-sen";
      sobre_indic_items[11]="Ichimoku Kijun-sen";
      sobre_indic_items[12]="Ichimoku Senkou Span A";
      sobre_indic_items[13]="Ichimoku Senkou Span B";
      sobre_indic_items[14]="Ichimoku Chinkou Spa";

      string sobre_entry_items[];
      ArrayResize(sobre_entry_items,3);
      sobre_entry_items[0]="Ao entrar";
      sobre_entry_items[1]="Ao sair";
      sobre_entry_items[2]="Estando";

      string sobre_sentido_items[];
      ArrayResize(sobre_sentido_items,2);
      sobre_sentido_items[0]="Sobrecompra compra";
      sobre_sentido_items[1]="Sobrecompra venda";

      const int sobre_content_x=12;
      const int sobre_content_w=field_w-24;
      const int sobre_tab_h=card_h-96;

      y=10;
      if(!V2CreateFieldLabel(*m_host,m_sobre_indic_label,"Indicador",m_sobre_tabs,m_sobre_tabs,m_window_index,0,sobre_content_x,y,sobre_content_w,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_sobre_indic_combo,m_sobre_tabs,m_sobre_tabs,0,sobre_content_x,y,sobre_content_w,180,sobre_indic_items,0,card_border))
         return(false);
      y+=34;
      if(!V2CreateFieldLabel(*m_host,m_sobre_entry_label,"Entrada",m_sobre_tabs,m_sobre_tabs,m_window_index,0,sobre_content_x,y,sobre_content_w,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_sobre_entry_combo,m_sobre_tabs,m_sobre_tabs,0,sobre_content_x,y,sobre_content_w,90,sobre_entry_items,0,card_border))
         return(false);
      y+=34;
      if(!V2CreateFieldLabel(*m_host,m_sobre_sobrecompra_label,"Sobrecompra",m_sobre_tabs,m_sobre_tabs,m_window_index,0,sobre_content_x,y,sobre_content_w,16))
         return(false);
      y+=18;
      if(!CreateSpinControl(m_sobre_sobrecompra_spin,m_sobre_tabs,m_sobre_tabs,0,sobre_content_x,y,sobre_content_w,100000.0,0.0,1.0,0,"2",sub_back,card_border))
         return(false);
      y+=34;
      if(!V2CreateFieldLabel(*m_host,m_sobre_sobrevenda_label,"Sobrevenda",m_sobre_tabs,m_sobre_tabs,m_window_index,0,sobre_content_x,y,sobre_content_w,16))
         return(false);
      y+=18;
      if(!CreateSpinControl(m_sobre_sobrevenda_spin,m_sobre_tabs,m_sobre_tabs,0,sobre_content_x,y,sobre_content_w,100000.0,-100000.0,1.0,0,"-2",sub_back,card_border))
         return(false);
      y+=34;
      if(!V2CreateFieldLabel(*m_host,m_sobre_sentido_label,"Sentido",m_sobre_tabs,m_sobre_tabs,m_window_index,0,sobre_content_x,y,sobre_content_w,16))
         return(false);
      y+=18;
      if(!CreateComboControl(m_sobre_sentido_combo,m_sobre_tabs,m_sobre_tabs,0,sobre_content_x,y,sobre_content_w,70,sobre_sentido_items,0,card_border))
         return(false);

      if(!V2CreateCard(*m_host,m_sobre_param_card,m_sobre_tabs,m_window_index,1,sobre_content_x,10,sobre_content_w,sobre_tab_h-20,sub_back,card_border))
         return(false);
      m_sobre_param_tabs.MainPointer(m_sobre_param_card);
      m_sobre_tabs.AddToElementsArray(1,m_sobre_param_tabs);
      m_sobre_param_tabs.XSize(sobre_content_w-24);
      m_sobre_param_tabs.YSize(sobre_tab_h-44);
      m_sobre_param_tabs.IsCenterText(true);
      m_sobre_param_tabs.PositionMode(TABS_TOP);
      m_sobre_param_tabs.TabsYSize(0);
      m_sobre_param_tabs.AutoXResizeMode(false);
      m_sobre_param_tabs.AutoYResizeMode(false);
      m_sobre_param_tabs.BackColor(sub_back);
      m_sobre_param_tabs.BackColorHover(sub_back);
      m_sobre_param_tabs.BackColorPressed(sub_back);
      m_sobre_param_tabs.BorderColor(sub_back);
      m_sobre_param_tabs.BorderColorHover(sub_back);
      m_sobre_param_tabs.BorderColorPressed(sub_back);
      for(int i=0;i<15;i++)
         m_sobre_param_tabs.AddTab(IntegerToString(i+1),0);
      if(!m_sobre_param_tabs.CreateTabs(12,12))
         return(false);
      CWndContainer::AddToElementsArray(m_window_index,m_sobre_param_tabs);

      CButtonsGroup *sobre_param_bg=m_sobre_param_tabs.GetButtonsGroupPointer();
      if(sobre_param_bg!=NULL)
        {
         for(int i=0;i<15;i++)
           {
            sobre_param_bg.GetButtonPointer(i).FontSize(1);
            sobre_param_bg.GetButtonPointer(i).LabelXGap(0);
            sobre_param_bg.GetButtonPointer(i).LabelYGap(0);
            sobre_param_bg.GetButtonPointer(i).BackColor(sub_back);
            sobre_param_bg.GetButtonPointer(i).BackColorHover(sub_back);
            sobre_param_bg.GetButtonPointer(i).BackColorPressed(sub_back);
            sobre_param_bg.GetButtonPointer(i).BorderColor(sub_back);
            sobre_param_bg.GetButtonPointer(i).BorderColorHover(sub_back);
            sobre_param_bg.GetButtonPointer(i).BorderColorPressed(sub_back);
            sobre_param_bg.GetButtonPointer(i).LabelColor(sub_back);
            sobre_param_bg.GetButtonPointer(i).LabelColorHover(sub_back);
            sobre_param_bg.GetButtonPointer(i).LabelColorPressed(sub_back);
           }
        }

      string sobre_param_titles[];
      ArrayResize(sobre_param_titles,15);
      sobre_param_titles[0]="MACD";
      sobre_param_titles[1]="Estocastico";
      sobre_param_titles[2]="RSI";
      sobre_param_titles[3]="DeMarker";
      sobre_param_titles[4]="Regressao linear";
      sobre_param_titles[5]="Desvio da media";
      sobre_param_titles[6]="MFI";
      sobre_param_titles[7]="Bears Power";
      sobre_param_titles[8]="Bulls Power";
      sobre_param_titles[9]="CCI";
      sobre_param_titles[10]="Ichimoku Tenkan-sen";
      sobre_param_titles[11]="Ichimoku Kijun-sen";
      sobre_param_titles[12]="Ichimoku Senkou Span A";
      sobre_param_titles[13]="Ichimoku Senkou Span B";
      sobre_param_titles[14]="Ichimoku Chinkou Spa";

      string sobre_price_items[];
      ArrayResize(sobre_price_items,7);
      sobre_price_items[0]="Fechamento";
      sobre_price_items[1]="Abertura";
      sobre_price_items[2]="Maximo";
      sobre_price_items[3]="Minimo";
      sobre_price_items[4]="Mediano";
      sobre_price_items[5]="Tipico";
      sobre_price_items[6]="Medio";

      string sobre_ma_items[];
      ArrayResize(sobre_ma_items,5);
      sobre_ma_items[0]="Simples";
      sobre_ma_items[1]="Exponencial";
      sobre_ma_items[2]="Suavizada";
      sobre_ma_items[3]="Linear ponderada";
      sobre_ma_items[4]="Smoothed";

      string sobre_stoch_type_items[];
      ArrayResize(sobre_stoch_type_items,2);
      sobre_stoch_type_items[0]="Minimo/Maximo";
      sobre_stoch_type_items[1]="Fechamento/Abertura";

      string sobre_volume_items[];
      ArrayResize(sobre_volume_items,2);
      sobre_volume_items[0]="Tick";
      sobre_volume_items[1]="Real";

      const int param_x=12;
      const int param_w=sobre_content_w-48;
      const int param_title_w=MathMax(72,param_w-70);
      int py=8;

      if(!V2CreateFieldLabel(*m_host,m_sobre_param_title[0],sobre_param_titles[0],m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,0,param_x,py,param_title_w,16))
         return(false);
      py+=18;
      if(!V2CreateFieldLabel(*m_host,m_sobre_macd_fast_label,"EMA rapida",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,0,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_macd_fast_spin,m_sobre_param_tabs,m_sobre_param_tabs,0,param_x,py,param_w,9999.0,0.0,1.0,0,"12",sub_back,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_macd_slow_label,"EMA lenta",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,0,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_macd_slow_spin,m_sobre_param_tabs,m_sobre_param_tabs,0,param_x,py,param_w,9999.0,0.0,1.0,0,"16",sub_back,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_macd_signal_label,"Sinal",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,0,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_macd_signal_spin,m_sobre_param_tabs,m_sobre_param_tabs,0,param_x,py,param_w,9999.0,0.0,1.0,0,"9",sub_back,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_macd_price_label,"Modo de preco",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,0,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateComboControl(m_sobre_macd_price_combo,m_sobre_param_tabs,m_sobre_param_tabs,0,param_x,py,param_w,140,sobre_price_items,0,card_border))
         return(false);

      py=8;
      if(!V2CreateFieldLabel(*m_host,m_sobre_param_title[1],sobre_param_titles[1],m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,1,param_x,py,param_title_w,16))
         return(false);
      py+=18;
      if(!V2CreateFieldLabel(*m_host,m_sobre_stoch_k_label,"K",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,1,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_stoch_k_spin,m_sobre_param_tabs,m_sobre_param_tabs,1,param_x,py,param_w,9999.0,0.0,1.0,0,"5",sub_back,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_stoch_d_label,"D",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,1,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_stoch_d_spin,m_sobre_param_tabs,m_sobre_param_tabs,1,param_x,py,param_w,9999.0,0.0,1.0,0,"3",sub_back,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_stoch_slow_label,"Slowing",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,1,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_stoch_slow_spin,m_sobre_param_tabs,m_sobre_param_tabs,1,param_x,py,param_w,9999.0,0.0,1.0,0,"3",sub_back,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_stoch_ma_label,"Media",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,1,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateComboControl(m_sobre_stoch_ma_combo,m_sobre_param_tabs,m_sobre_param_tabs,1,param_x,py,param_w,140,sobre_ma_items,0,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_stoch_type_label,"Tipo",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,1,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateComboControl(m_sobre_stoch_type_combo,m_sobre_param_tabs,m_sobre_param_tabs,1,param_x,py,param_w,80,sobre_stoch_type_items,0,card_border))
         return(false);

      py=8;
      if(!V2CreateFieldLabel(*m_host,m_sobre_param_title[2],sobre_param_titles[2],m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,2,param_x,py,param_title_w,16))
         return(false);
      py+=18;
      if(!V2CreateFieldLabel(*m_host,m_sobre_rsi_period_label,"Periodo",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,2,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_rsi_period_spin,m_sobre_param_tabs,m_sobre_param_tabs,2,param_x,py,param_w,9999.0,0.0,1.0,0,"14",sub_back,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_rsi_price_label,"Modo de preco",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,2,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateComboControl(m_sobre_rsi_price_combo,m_sobre_param_tabs,m_sobre_param_tabs,2,param_x,py,param_w,140,sobre_price_items,0,card_border))
         return(false);

      py=8;
      if(!V2CreateFieldLabel(*m_host,m_sobre_param_title[3],sobre_param_titles[3],m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,3,param_x,py,param_title_w,16))
         return(false);
      py+=18;
      if(!V2CreateFieldLabel(*m_host,m_sobre_demarker_period_label,"Periodo",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,3,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_demarker_period_spin,m_sobre_param_tabs,m_sobre_param_tabs,3,param_x,py,param_w,9999.0,0.0,1.0,0,"14",sub_back,card_border))
         return(false);

      py=8;
      if(!V2CreateFieldLabel(*m_host,m_sobre_param_title[4],sobre_param_titles[4],m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,4,param_x,py,param_title_w,16))
         return(false);
      py+=18;
      if(!V2CreateFieldLabel(*m_host,m_sobre_regressao_period_label,"Periodo",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,4,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_regressao_period_spin,m_sobre_param_tabs,m_sobre_param_tabs,4,param_x,py,param_w,9999.0,0.0,1.0,0,"20",sub_back,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_regressao_ma_label,"Tipo de regressao",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,4,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateComboControl(m_sobre_regressao_ma_combo,m_sobre_param_tabs,m_sobre_param_tabs,4,param_x,py,param_w,140,sobre_ma_items,0,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_regressao_price_label,"Modo de fechamento",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,4,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateComboControl(m_sobre_regressao_price_combo,m_sobre_param_tabs,m_sobre_param_tabs,4,param_x,py,param_w,140,sobre_price_items,0,card_border))
         return(false);

      py=8;
      if(!V2CreateFieldLabel(*m_host,m_sobre_param_title[5],sobre_param_titles[5],m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,5,param_x,py,param_title_w,16))
         return(false);
      py+=18;
      if(!V2CreateFieldLabel(*m_host,m_sobre_desvio_period_label,"Periodo",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,5,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_desvio_period_spin,m_sobre_param_tabs,m_sobre_param_tabs,5,param_x,py,param_w,9999.0,0.0,1.0,0,"20",sub_back,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_desvio_ma_label,"Tipo de desvio",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,5,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateComboControl(m_sobre_desvio_ma_combo,m_sobre_param_tabs,m_sobre_param_tabs,5,param_x,py,param_w,140,sobre_ma_items,0,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_desvio_price_label,"Modo de fechamento",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,5,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateComboControl(m_sobre_desvio_price_combo,m_sobre_param_tabs,m_sobre_param_tabs,5,param_x,py,param_w,140,sobre_price_items,0,card_border))
         return(false);

      py=8;
      if(!V2CreateFieldLabel(*m_host,m_sobre_param_title[6],sobre_param_titles[6],m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,6,param_x,py,param_title_w,16))
         return(false);
      py+=18;
      if(!V2CreateFieldLabel(*m_host,m_sobre_mfi_period_label,"Periodo",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,6,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_mfi_period_spin,m_sobre_param_tabs,m_sobre_param_tabs,6,param_x,py,param_w,9999.0,0.0,1.0,0,"14",sub_back,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_mfi_volume_label,"Volume",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,6,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateComboControl(m_sobre_mfi_volume_combo,m_sobre_param_tabs,m_sobre_param_tabs,6,param_x,py,param_w,80,sobre_volume_items,0,card_border))
         return(false);

      py=8;
      if(!V2CreateFieldLabel(*m_host,m_sobre_param_title[7],sobre_param_titles[7],m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,7,param_x,py,param_title_w,16))
         return(false);
      py+=18;
      if(!V2CreateFieldLabel(*m_host,m_sobre_bears_period_label,"Periodo",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,7,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_bears_period_spin,m_sobre_param_tabs,m_sobre_param_tabs,7,param_x,py,param_w,9999.0,0.0,1.0,0,"14",sub_back,card_border))
         return(false);

      py=8;
      if(!V2CreateFieldLabel(*m_host,m_sobre_param_title[8],sobre_param_titles[8],m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,8,param_x,py,param_title_w,16))
         return(false);
      py+=18;
      if(!V2CreateFieldLabel(*m_host,m_sobre_bulls_period_label,"Periodo",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,8,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_bulls_period_spin,m_sobre_param_tabs,m_sobre_param_tabs,8,param_x,py,param_w,9999.0,0.0,1.0,0,"14",sub_back,card_border))
         return(false);

      py=8;
      if(!V2CreateFieldLabel(*m_host,m_sobre_param_title[9],sobre_param_titles[9],m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,9,param_x,py,param_title_w,16))
         return(false);
      py+=18;
      if(!V2CreateFieldLabel(*m_host,m_sobre_cci_period_label,"Periodo",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,9,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateSpinControl(m_sobre_cci_period_spin,m_sobre_param_tabs,m_sobre_param_tabs,9,param_x,py,param_w,9999.0,0.0,1.0,0,"14",sub_back,card_border))
         return(false);
      py+=38;
      if(!V2CreateFieldLabel(*m_host,m_sobre_cci_price_label,"Modo de preco",m_sobre_param_tabs,m_sobre_param_tabs,m_window_index,9,param_x,py,param_w,16))
         return(false);
      py+=16;
      if(!CreateComboControl(m_sobre_cci_price_combo,m_sobre_param_tabs,m_sobre_param_tabs,9,param_x,py,param_w,140,sobre_price_items,0,card_border))
         return(false);

      for(int ichimoku_idx=0;ichimoku_idx<5;ichimoku_idx++)
        {
         const int tab_index=10+ichimoku_idx;
         if(!CreateSobreIchimokuBlock(m_sobre_param_tabs,tab_index,param_x,param_w,sub_back,card_border,sobre_param_titles[tab_index],
                                      m_sobre_param_title[tab_index],
                                      m_sobre_ichimoku_tenkan_spin[ichimoku_idx],
                                      m_sobre_ichimoku_kijun_spin[ichimoku_idx],
                                      m_sobre_ichimoku_senkou_b_spin[ichimoku_idx],
                                      m_sobre_ichimoku_tenkan_label[ichimoku_idx],
                                      m_sobre_ichimoku_kijun_label[ichimoku_idx],
                                      m_sobre_ichimoku_senkou_b_label[ichimoku_idx]))
            return(false);
        }

      if(!m_host.CreateTextLabel(m_sobre_param_hint,"Os parametros acompanham o indicador selecionado na aba ao lado.",m_sobre_param_card,m_window_index,m_sobre_tabs,1,12,sobre_tab_h-44,sobre_content_w-24,20))
         return(false);
      m_sobre_param_hint.FontSize(10);
      m_sobre_param_hint.LabelColor(V2_COLOR_TEXT_SECONDARY);

      m_sobre_param_tabs.SelectTab(0);
      m_sobre_tabs.SelectTab(0);
      m_sobre_tabs.ShowTabElements();
      m_last_sobre_tab=0;
      m_last_sobre_param_idx=0;

      m_created=true;
      return(true);
     }

   void SetActive(const bool active)
     {
      if(!m_created)
         return;

      m_is_active=active;

      SetFrameVisible(m_card_ordens,active);
      SetLabelVisible(m_card_ordens_title,active);
      SetCheckVisible(m_ordem_market,active);
      SetCheckVisible(m_ordem_limit,active);
      SetTabsVisible(m_ord_tabs,active);
      SetCheckVisible(m_ord_ref_check,active);
      SetCheckVisible(m_ord_media_check,active);
      SetFrameVisible(m_ord_ref_card,active);
      SetFrameVisible(m_ord_media_card,active);

      SetFrameVisible(m_card_filtro,active);
      SetLabelVisible(m_card_filtro_title,active);
      SetCheckVisible(m_use_filtro,active);

      SetFrameVisible(m_card_canais,active);
      SetLabelVisible(m_card_canais_title,active);
      SetLabelVisible(m_canais_label,active);
      SetCheckVisible(m_canais_yes,active);
      SetCheckVisible(m_canais_no,active);

      SetFrameVisible(m_card_cruz,active);
      SetLabelVisible(m_card_cruz_title,active);
      SetLabelVisible(m_cruz_label,active);
      SetCheckVisible(m_cruz_yes,active);
      SetCheckVisible(m_cruz_no,active);
      SetTabsVisible(m_cruz_tabs,active);
      SetFrameVisible(m_cruz_fast_param_card,active);
      SetTabsVisible(m_cruz_fast_param_tabs,active);
      SetFrameVisible(m_cruz_slow_param_card,active);
      SetTabsVisible(m_cruz_slow_param_tabs,active);

      SetFrameVisible(m_card_sobre,active);
      SetLabelVisible(m_card_sobre_title,active);
      SetCheckVisible(m_use_sobre,active);
      SetTabsVisible(m_sobre_tabs,active);
      SetFrameVisible(m_sobre_param_card,active);
      SetTabsVisible(m_sobre_param_tabs,active);
      SetLabelVisible(m_sobre_param_hint,active);

      if(active)
        {
         m_ord_tabs.ShowTabElements();
         m_cruz_tabs.ShowTabElements();
         m_sobre_tabs.ShowTabElements();
         SyncOrderTabChecks();
         SyncCruzTabs();
         SyncSobreParamView();
        }
     }

   void OnTimerEvent(void)
     {
      if(!m_created || !m_is_active)
         return;

      SyncOrderTabChecks();
      SyncCruzTabs();
      SyncSobreParamView();
     }

   bool HandleEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
      if(!m_created)
         return(false);
      if(id!=CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX)
         return(false);

      const int clicked_id=(int)lparam;
      if(m_ordem_market.Id()==clicked_id)
        {
         if(!m_ordem_market.IsPressed())
            m_ordem_market.IsPressed(true);
         m_ordem_limit.IsPressed(false);
         RefreshOrderChecks();
         return(true);
        }
      if(m_ordem_limit.Id()==clicked_id)
        {
         if(!m_ordem_limit.IsPressed())
            m_ordem_limit.IsPressed(true);
         m_ordem_market.IsPressed(false);
         RefreshOrderChecks();
         return(true);
        }
      if(m_ord_ref_check.Id()==clicked_id)
        {
         if(!m_ord_ref_check.IsPressed())
            m_ord_ref_check.IsPressed(true);
         m_ord_media_check.IsPressed(false);
         m_ord_tabs.SelectTab(0);
         m_ord_tabs.ShowTabElements();
         m_last_ord_tab=0;
         RefreshOrderChecks();
         return(true);
        }
      if(m_ord_media_check.Id()==clicked_id)
        {
         if(!m_ord_media_check.IsPressed())
            m_ord_media_check.IsPressed(true);
         m_ord_ref_check.IsPressed(false);
         m_ord_tabs.SelectTab(1);
         m_ord_tabs.ShowTabElements();
         m_last_ord_tab=1;
         RefreshOrderChecks();
         return(true);
        }
      if(m_canais_yes.Id()==clicked_id)
        {
         if(!m_canais_yes.IsPressed())
            m_canais_yes.IsPressed(true);
         m_canais_no.IsPressed(false);
         RefreshCanaisChecks();
         return(true);
        }
      if(m_canais_no.Id()==clicked_id)
        {
         if(!m_canais_no.IsPressed())
            m_canais_no.IsPressed(true);
         m_canais_yes.IsPressed(false);
         RefreshCanaisChecks();
         return(true);
        }
      if(m_cruz_yes.Id()==clicked_id)
        {
         if(!m_cruz_yes.IsPressed())
            m_cruz_yes.IsPressed(true);
         m_cruz_no.IsPressed(false);
         RefreshCruzChecks();
         return(true);
        }
      if(m_cruz_no.Id()==clicked_id)
        {
         if(!m_cruz_no.IsPressed())
            m_cruz_no.IsPressed(true);
         m_cruz_yes.IsPressed(false);
         RefreshCruzChecks();
         return(true);
        }
      return(false);
     }
  };

#endif // __CONSTRUTOR_V2_TAB8_SINAIS_MAIN_VIEW_MQH__


