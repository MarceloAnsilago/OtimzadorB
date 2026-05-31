//+------------------------------------------------------------------+
//|                                                       Eafast.mq5 |
//+------------------------------------------------------------------+
#property strict

#include "EasyAndFastGUI\\WndCreate.mqh"

class CEAFastUI : public CWndCreate
  {
private:
   CWindow     m_window;
   CStatusBar  m_status_bar;
   CTabs       m_tabs;
   CFrame      m_card_filtro;
   CFrame      m_card_canais;
   CFrame      m_card_cruzamentos;
   CFrame      m_card_sobre;
   CTextLabel  m_card_filtro_title;
   CTextLabel  m_card_canais_title;
   CTextLabel  m_card_cruzamentos_title;
   CTextLabel  m_card_sobre_title;
   CCheckBox   m_use_filtro;
   CTextLabel  m_filtro_time_label;
   CComboBox   m_filtro_time_combo;
   CTextLabel  m_filtro_range_label[4];
   CTextEdit   m_filtro_range_spin[4];
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
   CTextLabel  m_cruz_slow_indic_label;
   CComboBox   m_cruz_slow_indic_combo;
   CFrame      m_cruz_fast_param_card;
   CTabs       m_cruz_fast_param_tabs;
   CFrame      m_cruz_slow_param_card;
   CTabs       m_cruz_slow_param_tabs;
   CTextLabel  m_cruz_fast_param_title[5];
   CTextLabel  m_cruz_slow_param_title[5];
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
   int         m_last_cruz_fast_general;
   int         m_last_cruz_slow_general;

   bool CreatePlainCombo(CComboBox &combo,CElement &owner,CTabs &tabs,const int tab_index,const int x,const int y,const int width,const int list_height,string &items[],const int selected_index=0)
     {
      combo.MainPointer(owner);
      tabs.AddToElementsArray(tab_index,combo);
      combo.XSize(width);
      combo.YSize(20);
      combo.CheckBoxMode(false);
      combo.ItemsTotal(ArraySize(items));
      combo.GetButtonPointer().XSize(width-2);
      combo.GetButtonPointer().XGap(1);
      combo.GetButtonPointer().YSize(20);
      combo.GetButtonPointer().AnchorRightWindowSide(false);
      combo.GetButtonPointer().IconXGap(width-18);
      combo.GetButtonPointer().LabelXGap(10);
      for(int i=0;i<ArraySize(items);i++)
         combo.SetValue(i,items[i]);
      combo.GetListViewPointer().YSize(list_height);
      combo.GetListViewPointer().LightsHover(true);
      combo.SelectItem(selected_index);
      if(!combo.CreateComboBox("",x,y))
         return(false);
      CWndContainer::AddToElementsArray(0,combo);
      return(true);
     }

   int SyncCrossParamTabIndex(const int indicator_index) const
     {
      if(indicator_index<5 || indicator_index>9)
         return(0);
      return(indicator_index-5);
     }

   bool IsTabsButtonClicked(CTabs &tabs,const long clicked_id) const
     {
      CButtonsGroup *group=tabs.GetButtonsGroupPointer();
      if(group==NULL)
         return(false);
      const int total=group.ButtonsTotal();
      for(int i=0;i<total;i++)
        {
         if(group.GetButtonPointer(i).Id()==clicked_id)
            return(true);
        }
      return(false);
     }

   void SyncCrossCombosFromGeneral(void)
     {
      const int fast_general=m_cruz_fast_combo.GetListViewPointer().SelectedItemIndex();
      const int slow_general=m_cruz_slow_combo.GetListViewPointer().SelectedItemIndex();

      if(fast_general!=m_last_cruz_fast_general && fast_general!=WRONG_VALUE)
        {
         m_last_cruz_fast_general=fast_general;
         m_cruz_fast_indic_combo.SelectItem(fast_general);
         m_cruz_fast_indic_combo.Update(true);
         m_cruz_fast_param_tabs.SelectTab(SyncCrossParamTabIndex(fast_general));
         m_cruz_fast_param_tabs.ShowTabElements();
        }

      if(slow_general!=m_last_cruz_slow_general && slow_general!=WRONG_VALUE)
        {
         m_last_cruz_slow_general=slow_general;
         m_cruz_tabs.SelectTab(2);
         m_cruz_tabs.ShowTabElements();
         m_cruz_slow_indic_combo.SelectItem(slow_general);
         m_cruz_slow_indic_combo.Update(true);
         m_cruz_slow_param_tabs.SelectTab(SyncCrossParamTabIndex(slow_general));
         m_cruz_slow_param_tabs.ShowTabElements();
        }
     }

   void SyncCrossParamTabsFromIndicatorCombos(void)
     {
      const int fast_indicator=m_cruz_fast_indic_combo.GetListViewPointer().SelectedItemIndex();
      const int slow_indicator=m_cruz_slow_indic_combo.GetListViewPointer().SelectedItemIndex();

      if(fast_indicator!=WRONG_VALUE)
        {
         m_cruz_fast_param_tabs.SelectTab(SyncCrossParamTabIndex(fast_indicator));
         m_cruz_fast_param_tabs.ShowTabElements();
        }

      if(slow_indicator!=WRONG_VALUE)
        {
         m_cruz_slow_param_tabs.SelectTab(SyncCrossParamTabIndex(slow_indicator));
         m_cruz_slow_param_tabs.ShowTabElements();
        }
     }

   void StyleFrame(CFrame &frame)
     {
      frame.BackColor(C'245,245,245');
      frame.BorderColor(C'120,120,120');
      frame.BorderColorHover(C'120,120,120');
      frame.BorderColorPressed(C'120,120,120');
     }

   void StyleTabsButtons(CTabs &tabs,const int font_size,const color back,const color hover,const color pressed,const color border)
     {
      CButtonsGroup *group=tabs.GetButtonsGroupPointer();
      if(group==NULL)
         return;

      const int total=group.ButtonsTotal();
      for(int i=0;i<total;i++)
        {
         group.GetButtonPointer(i).FontSize(font_size);
         group.GetButtonPointer(i).LabelXGap(0);
         group.GetButtonPointer(i).LabelYGap(0);
         group.GetButtonPointer(i).BackColor(back);
         group.GetButtonPointer(i).BackColorHover(hover);
         group.GetButtonPointer(i).BackColorPressed(pressed);
         group.GetButtonPointer(i).BorderColor(border);
         group.GetButtonPointer(i).BorderColorHover(border);
         group.GetButtonPointer(i).BorderColorPressed(border);
         group.GetButtonPointer(i).LabelColor(clrBlack);
         group.GetButtonPointer(i).LabelColorHover(clrBlack);
         group.GetButtonPointer(i).LabelColorPressed(clrBlack);
        }
     }

   bool CreateSpin(CTextEdit &spin,CElement &owner,CTabs &tabs,const int tab_index,const int x,const int y,const int width,const double max_value,const double min_value,const double step,const int digits,const double value)
     {
      return(CWndCreate::CreateTextEdit(spin,"",owner,0,tabs,tab_index,false,x,y,width,width-34,max_value,min_value,step,digits,value));
     }

   bool CreateCrossParamBlock(CTabs &tabs,const int tab_index,const int x,const int y,const int width,const string title,CTextLabel &title_label,CTextEdit &period_spin,CTextEdit &shift_spin,CComboBox &ma_type_combo,CComboBox &price_combo,CTextLabel &period_label,CTextLabel &shift_label,CTextLabel &ma_type_label,CTextLabel &price_label,const double period_value,const bool with_ma_type,string &ma_items[],string &price_items[])
     {
      if(!CWndCreate::CreateTextLabel(title_label,title,tabs,0,tabs,tab_index,x,y,width,18))
         return(false);
      if(!CWndCreate::CreateTextLabel(period_label,"Periodo",tabs,0,tabs,tab_index,x,y+24,width,16))
         return(false);
      if(!CreateSpin(period_spin,tabs,tabs,tab_index,x,y+42,width,9999.0,0.0,1.0,0,period_value))
         return(false);
      if(!CWndCreate::CreateTextLabel(shift_label,"Deslocamento",tabs,0,tabs,tab_index,x,y+76,width,16))
         return(false);
      if(!CreateSpin(shift_spin,tabs,tabs,tab_index,x,y+94,width,9999.0,0.0,1.0,0,0))
         return(false);
      int next_y=y+128;
      if(with_ma_type)
        {
         if(!CWndCreate::CreateTextLabel(ma_type_label,"Tipo de media",tabs,0,tabs,tab_index,x,next_y,width,16))
            return(false);
         if(!CreatePlainCombo(ma_type_combo,tabs,tabs,tab_index,x,next_y+18,width,100,ma_items,0))
            return(false);
         next_y+=54;
        }
      if(!CWndCreate::CreateTextLabel(price_label,"Modo de preco",tabs,0,tabs,tab_index,x,next_y,width,16))
         return(false);
      if(!CreatePlainCombo(price_combo,tabs,tabs,tab_index,x,next_y+18,width,120,price_items,0))
         return(false);
      return(true);
     }

   bool CreateCrossVidyaBlock(CTabs &tabs,const int tab_index,const int x,const int y,const int width,const string title,CTextLabel &title_label,CTextEdit &cmo_spin,CTextEdit &ema_spin,CTextEdit &shift_spin,CComboBox &price_combo,CTextLabel &cmo_label,CTextLabel &ema_label,CTextLabel &shift_label,CTextLabel &price_label,string &price_items[])
     {
      if(!CWndCreate::CreateTextLabel(title_label,title,tabs,0,tabs,tab_index,x,y,width,18))
         return(false);
      if(!CWndCreate::CreateTextLabel(cmo_label,"Periodo CMO",tabs,0,tabs,tab_index,x,y+24,width,16))
         return(false);
      if(!CreateSpin(cmo_spin,tabs,tabs,tab_index,x,y+42,width,9999.0,0.0,1.0,0,9))
         return(false);
      if(!CWndCreate::CreateTextLabel(ema_label,"Periodo EMA",tabs,0,tabs,tab_index,x,y+76,width,16))
         return(false);
      if(!CreateSpin(ema_spin,tabs,tabs,tab_index,x,y+94,width,9999.0,0.0,1.0,0,12))
         return(false);
      if(!CWndCreate::CreateTextLabel(shift_label,"Deslocamento",tabs,0,tabs,tab_index,x,y+128,width,16))
         return(false);
      if(!CreateSpin(shift_spin,tabs,tabs,tab_index,x,y+146,width,9999.0,0.0,1.0,0,0))
         return(false);
      if(!CWndCreate::CreateTextLabel(price_label,"Modo de preco",tabs,0,tabs,tab_index,x,y+180,width,16))
         return(false);
      if(!CreatePlainCombo(price_combo,tabs,tabs,tab_index,x,y+198,width,120,price_items,0))
         return(false);
      return(true);
     }

public:
   CEAFastUI(void) : m_last_cruz_fast_general(-1), m_last_cruz_slow_general(-1) {}

   bool CreateGUI(void)
     {
      if(!CWndCreate::CreateWindow(m_window,"EA FAST",20,40,1280,760,true,true,true,true))
         return(false);

      string sb_text[2];
      sb_text[0] = "EA FAST";
      sb_text[1] = "Tela base";
      int sb_width[] = {0, 120};
      if(!CWndCreate::CreateStatusBar(m_status_bar,m_window,1,23,22,sb_text,sb_width))
         return(false);

      string tab_text[] = {"Sinais prontos", "Montar sinais", "Teste"};
      int tab_width[] = {140, 140, 100};
      if(!CWndCreate::CreateTabs(m_tabs,m_window,0,1,46,1278,690,tab_text,tab_width,TABS_TOP,true,true,2,24))
         return(false);

      if(!CWndCreate::CreateFrame(m_card_filtro,"",m_window,0,m_tabs,0,20,90,240,560,1))
         return(false);
      StyleFrame(m_card_filtro);
      if(!CWndCreate::CreateTextLabel(m_card_filtro_title,"Usar filtro",m_card_filtro,0,m_tabs,0,12,10,220,20))
         return(false);
      if(!CWndCreate::CreateCheckbox(m_use_filtro,"Ativar filtro",m_card_filtro,0,m_tabs,0,12,40,220,false,false,false))
         return(false);

      string tf_items[];
      ArrayResize(tf_items,21);
      tf_items[0]="Corrente";
      tf_items[1]="M1";
      tf_items[2]="M2";
      tf_items[3]="M3";
      tf_items[4]="M4";
      tf_items[5]="M5";
      tf_items[6]="M6";
      tf_items[7]="M10";
      tf_items[8]="M12";
      tf_items[9]="M15";
      tf_items[10]="M30";
      tf_items[11]="H1";
      tf_items[12]="H2";
      tf_items[13]="H3";
      tf_items[14]="H4";
      tf_items[15]="H6";
      tf_items[16]="H8";
      tf_items[17]="H12";
      tf_items[18]="D1";
      tf_items[19]="W1";
      tf_items[20]="MN1";

      if(!CWndCreate::CreateTextLabel(m_filtro_time_label,"Tempo grafico",m_card_filtro,0,m_tabs,0,12,76,220,18))
         return(false);
      if(!CreatePlainCombo(m_filtro_time_combo,m_card_filtro,m_tabs,0,12,98,200,200,tf_items,0))
         return(false);

      string filter_labels[];
      ArrayResize(filter_labels,4);
      filter_labels[0]="Tam. min da vela";
      filter_labels[1]="Tam. max";
      filter_labels[2]="Min. pavios";
      filter_labels[3]="Max. pavios";
      int filter_y = 140;
      for(int i=0;i<4;i++)
        {
         if(!CWndCreate::CreateTextLabel(m_filtro_range_label[i],filter_labels[i],m_card_filtro,0,m_tabs,0,12,filter_y,200,16))
            return(false);
         filter_y+=18;
         if(!CWndCreate::CreateTextEdit(m_filtro_range_spin[i],"",m_card_filtro,0,m_tabs,0,false,12,filter_y,200,166,9999.0,0.0,1.0,0,0))
            return(false);
         filter_y+=28;
        }

      if(!CWndCreate::CreateFrame(m_card_canais,"",m_window,0,m_tabs,0,272,90,260,560,1))
         return(false);
      StyleFrame(m_card_canais);
      if(!CWndCreate::CreateTextLabel(m_card_canais_title,"Canais de bandas",m_card_canais,0,m_tabs,0,12,10,220,20))
         return(false);
      if(!CWndCreate::CreateTextLabel(m_canais_label,"Usar canais de bandas?",m_card_canais,0,m_tabs,0,12,40,220,18))
         return(false);
      if(!CWndCreate::CreateCheckbox(m_canais_yes,"Sim",m_card_canais,0,m_tabs,0,12,58,60,false,false,false))
         return(false);
      if(!CWndCreate::CreateCheckbox(m_canais_no,"Nao",m_card_canais,0,m_tabs,0,82,58,60,true,false,false))
         return(false);

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

      if(!CWndCreate::CreateTextLabel(m_canais_indic_label,"Indicador",m_card_canais,0,m_tabs,0,12,84,220,16))
         return(false);
      if(!CreatePlainCombo(m_canais_indic_combo,m_card_canais,m_tabs,0,12,100,220,120,canais_indic_items,0))
         return(false);

      if(!CWndCreate::CreateTextLabel(m_canais_type_label,"Sinais",m_card_canais,0,m_tabs,0,12,142,220,16))
         return(false);
      if(!CreatePlainCombo(m_canais_type_combo,m_card_canais,m_tabs,0,12,158,220,160,canais_type_items,0))
         return(false);

      if(!CWndCreate::CreateTextLabel(m_canais_period_label,"Periodo",m_card_canais,0,m_tabs,0,12,200,220,16))
         return(false);
      if(!CWndCreate::CreateTextEdit(m_canais_period_spin,"",m_card_canais,0,m_tabs,0,false,12,216,220,186,9999.0,0.0,1.0,0,20))
         return(false);

      if(!CWndCreate::CreateTextLabel(m_canais_deviation_label,"Desvio",m_card_canais,0,m_tabs,0,12,254,220,16))
         return(false);
      if(!CWndCreate::CreateTextEdit(m_canais_deviation_spin,"",m_card_canais,0,m_tabs,0,false,12,270,220,186,9999.0,0.0,0.1,1,2.0))
         return(false);

      if(!CWndCreate::CreateTextLabel(m_canais_shift_label,"Deslocamento",m_card_canais,0,m_tabs,0,12,308,220,16))
         return(false);
      if(!CWndCreate::CreateTextEdit(m_canais_shift_spin,"",m_card_canais,0,m_tabs,0,false,12,324,220,186,9999.0,0.0,1.0,0,0))
         return(false);

      if(!CWndCreate::CreateTextLabel(m_canais_price_label,"Modo de preco",m_card_canais,0,m_tabs,0,12,362,220,16))
         return(false);
      if(!CreatePlainCombo(m_canais_price_combo,m_card_canais,m_tabs,0,12,378,220,160,canais_price_items,0))
         return(false);

      if(!CWndCreate::CreateFrame(m_card_cruzamentos,"",m_window,0,m_tabs,0,544,90,430,560,1))
         return(false);
      StyleFrame(m_card_cruzamentos);
      if(!CWndCreate::CreateTextLabel(m_card_cruzamentos_title,"Cruzamentos",m_card_cruzamentos,0,m_tabs,0,12,10,220,20))
         return(false);
      if(!CWndCreate::CreateTextLabel(m_cruz_label,"Usar cruzamentos",m_card_cruzamentos,0,m_tabs,0,12,40,220,18))
         return(false);
      if(!CWndCreate::CreateCheckbox(m_cruz_yes,"Sim",m_card_cruzamentos,0,m_tabs,0,12,58,60,false,false,false))
         return(false);
      if(!CWndCreate::CreateCheckbox(m_cruz_no,"Nao",m_card_cruzamentos,0,m_tabs,0,82,58,60,true,false,false))
         return(false);

      string cruz_tab_text[];
      int cruz_tab_width[];
      ArrayResize(cruz_tab_text,3);
      ArrayResize(cruz_tab_width,3);
      cruz_tab_text[0]="Geral";
      cruz_tab_text[1]="Rapida";
      cruz_tab_text[2]="Lenta";
      cruz_tab_width[0]=120;
      cruz_tab_width[1]=120;
      cruz_tab_width[2]=120;

      if(!CWndCreate::CreateTabs(m_cruz_tabs,m_card_cruzamentos,0,m_tabs,0,12,122,390,404,cruz_tab_text,cruz_tab_width,TABS_TOP,false,false,0,0))
         return(false);
      m_cruz_tabs.TabsYSize(20);
      StyleTabsButtons(m_cruz_tabs,8,C'238,238,238',C'232,232,232',C'225,225,225',C'180,180,180');

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

      if(!CWndCreate::CreateTextLabel(m_cruz_fast_label,"Linha rapida",m_cruz_tabs,0,m_cruz_tabs,0,12,10,320,16))
         return(false);
      if(!CreatePlainCombo(m_cruz_fast_combo,m_cruz_tabs,m_cruz_tabs,0,12,28,340,120,cruz_indic_items,0))
         return(false);
      if(!CWndCreate::CreateTextLabel(m_cruz_signal_label,"Sinal",m_cruz_tabs,0,m_cruz_tabs,0,12,64,320,16))
         return(false);
      if(!CreatePlainCombo(m_cruz_signal_combo,m_cruz_tabs,m_cruz_tabs,0,12,82,340,100,cruz_signal_items,0))
         return(false);
      if(!CWndCreate::CreateTextLabel(m_cruz_slow_label,"Linha lenta",m_cruz_tabs,0,m_cruz_tabs,0,12,118,320,16))
         return(false);
      if(!CreatePlainCombo(m_cruz_slow_combo,m_cruz_tabs,m_cruz_tabs,0,12,136,340,120,cruz_indic_items,0))
         return(false);
      if(!CWndCreate::CreateTextLabel(m_cruz_note,"As abas Rapida e Lenta acompanham o indicador escolhido aqui.",m_cruz_tabs,0,m_cruz_tabs,0,12,176,340,42))
         return(false);

      if(!CWndCreate::CreateTextLabel(m_cruz_fast_indic_label,"Indicador rapido",m_cruz_tabs,0,m_cruz_tabs,1,12,10,320,16))
         return(false);
      if(!CreatePlainCombo(m_cruz_fast_indic_combo,m_cruz_tabs,m_cruz_tabs,1,12,28,340,120,cruz_indic_items,0))
         return(false);
      if(!CWndCreate::CreateFrame(m_cruz_fast_param_card,"",m_cruz_tabs,0,m_cruz_tabs,1,12,82,360,300,1))
         return(false);
      StyleFrame(m_cruz_fast_param_card);

      string cruz_param_tabs_text[];
      int cruz_param_tabs_width[];
      ArrayResize(cruz_param_tabs_text,5);
      ArrayResize(cruz_param_tabs_width,5);
      cruz_param_tabs_text[0]="MA";
      cruz_param_tabs_text[1]="VIDYA";
      cruz_param_tabs_text[2]="DEMA";
      cruz_param_tabs_text[3]="TEMA";
      cruz_param_tabs_text[4]="FRAMA";
      cruz_param_tabs_width[0]=32;
      cruz_param_tabs_width[1]=40;
      cruz_param_tabs_width[2]=38;
      cruz_param_tabs_width[3]=38;
      cruz_param_tabs_width[4]=48;
      if(!CWndCreate::CreateTabs(m_cruz_fast_param_tabs,m_cruz_fast_param_card,0,m_cruz_tabs,1,8,18,344,268,cruz_param_tabs_text,cruz_param_tabs_width,TABS_TOP,false,false,0,0))
         return(false);
      m_cruz_fast_param_tabs.TabsYSize(0);
      StyleTabsButtons(m_cruz_fast_param_tabs,1,C'245,245,245',C'245,245,245',C'245,245,245',C'245,245,245');

      if(!CWndCreate::CreateTextLabel(m_cruz_slow_indic_label,"Indicador lento",m_cruz_tabs,0,m_cruz_tabs,2,12,10,320,16))
         return(false);
      if(!CreatePlainCombo(m_cruz_slow_indic_combo,m_cruz_tabs,m_cruz_tabs,2,12,28,340,120,cruz_indic_items,1))
         return(false);
      if(!CWndCreate::CreateFrame(m_cruz_slow_param_card,"",m_cruz_tabs,0,m_cruz_tabs,2,12,82,360,300,1))
         return(false);
      StyleFrame(m_cruz_slow_param_card);
      if(!CWndCreate::CreateTabs(m_cruz_slow_param_tabs,m_cruz_slow_param_card,0,m_cruz_tabs,2,8,18,344,268,cruz_param_tabs_text,cruz_param_tabs_width,TABS_TOP,false,false,0,0))
         return(false);
      m_cruz_slow_param_tabs.TabsYSize(0);
      StyleTabsButtons(m_cruz_slow_param_tabs,1,C'245,245,245',C'245,245,245',C'245,245,245',C'245,245,245');

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

      if(!CreateCrossParamBlock(m_cruz_fast_param_tabs,0,10,8,300,"Media movel",m_cruz_fast_param_title[0],m_cruz_fast_ma_period_spin,m_cruz_fast_ma_shift_spin,m_cruz_fast_ma_type_combo,m_cruz_fast_ma_price_combo,m_cruz_fast_ma_period_label,m_cruz_fast_ma_shift_label,m_cruz_fast_ma_type_label,m_cruz_fast_ma_price_label,14,true,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCrossVidyaBlock(m_cruz_fast_param_tabs,1,10,8,300,"VIDYA",m_cruz_fast_param_title[1],m_cruz_fast_vidya_cmo_spin,m_cruz_fast_vidya_ema_spin,m_cruz_fast_vidya_shift_spin,m_cruz_fast_vidya_price_combo,m_cruz_fast_vidya_cmo_label,m_cruz_fast_vidya_ema_label,m_cruz_fast_vidya_shift_label,m_cruz_fast_vidya_price_label,cruz_price_items))
         return(false);
      if(!CreateCrossParamBlock(m_cruz_fast_param_tabs,2,10,8,300,"DEMA",m_cruz_fast_param_title[2],m_cruz_fast_dema_period_spin,m_cruz_fast_dema_shift_spin,m_cruz_fast_ma_type_combo,m_cruz_fast_dema_price_combo,m_cruz_fast_dema_period_label,m_cruz_fast_dema_shift_label,m_cruz_fast_ma_type_label,m_cruz_fast_dema_price_label,14,false,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCrossParamBlock(m_cruz_fast_param_tabs,3,10,8,300,"TEMA",m_cruz_fast_param_title[3],m_cruz_fast_tema_period_spin,m_cruz_fast_tema_shift_spin,m_cruz_fast_ma_type_combo,m_cruz_fast_tema_price_combo,m_cruz_fast_tema_period_label,m_cruz_fast_tema_shift_label,m_cruz_fast_ma_type_label,m_cruz_fast_tema_price_label,14,false,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCrossParamBlock(m_cruz_fast_param_tabs,4,10,8,300,"FRAMA",m_cruz_fast_param_title[4],m_cruz_fast_frama_period_spin,m_cruz_fast_frama_shift_spin,m_cruz_fast_ma_type_combo,m_cruz_fast_frama_price_combo,m_cruz_fast_frama_period_label,m_cruz_fast_frama_shift_label,m_cruz_fast_ma_type_label,m_cruz_fast_frama_price_label,14,false,cruz_ma_items,cruz_price_items))
         return(false);

      if(!CreateCrossParamBlock(m_cruz_slow_param_tabs,0,10,8,300,"Media movel",m_cruz_slow_param_title[0],m_cruz_slow_ma_period_spin,m_cruz_slow_ma_shift_spin,m_cruz_slow_ma_type_combo,m_cruz_slow_ma_price_combo,m_cruz_slow_ma_period_label,m_cruz_slow_ma_shift_label,m_cruz_slow_ma_type_label,m_cruz_slow_ma_price_label,21,true,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCrossVidyaBlock(m_cruz_slow_param_tabs,1,10,8,300,"VIDYA",m_cruz_slow_param_title[1],m_cruz_slow_vidya_cmo_spin,m_cruz_slow_vidya_ema_spin,m_cruz_slow_vidya_shift_spin,m_cruz_slow_vidya_price_combo,m_cruz_slow_vidya_cmo_label,m_cruz_slow_vidya_ema_label,m_cruz_slow_vidya_shift_label,m_cruz_slow_vidya_price_label,cruz_price_items))
         return(false);
      if(!CreateCrossParamBlock(m_cruz_slow_param_tabs,2,10,8,300,"DEMA",m_cruz_slow_param_title[2],m_cruz_slow_dema_period_spin,m_cruz_slow_dema_shift_spin,m_cruz_slow_ma_type_combo,m_cruz_slow_dema_price_combo,m_cruz_slow_dema_period_label,m_cruz_slow_dema_shift_label,m_cruz_slow_ma_type_label,m_cruz_slow_dema_price_label,21,false,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCrossParamBlock(m_cruz_slow_param_tabs,3,10,8,300,"TEMA",m_cruz_slow_param_title[3],m_cruz_slow_tema_period_spin,m_cruz_slow_tema_shift_spin,m_cruz_slow_ma_type_combo,m_cruz_slow_tema_price_combo,m_cruz_slow_tema_period_label,m_cruz_slow_tema_shift_label,m_cruz_slow_ma_type_label,m_cruz_slow_tema_price_label,21,false,cruz_ma_items,cruz_price_items))
         return(false);
      if(!CreateCrossParamBlock(m_cruz_slow_param_tabs,4,10,8,300,"FRAMA",m_cruz_slow_param_title[4],m_cruz_slow_frama_period_spin,m_cruz_slow_frama_shift_spin,m_cruz_slow_ma_type_combo,m_cruz_slow_frama_price_combo,m_cruz_slow_frama_period_label,m_cruz_slow_frama_shift_label,m_cruz_slow_ma_type_label,m_cruz_slow_frama_price_label,21,false,cruz_ma_items,cruz_price_items))
         return(false);

      m_cruz_fast_param_tabs.SelectTab(0);
      m_cruz_fast_param_tabs.ShowTabElements();
      m_cruz_slow_param_tabs.SelectTab(0);
      m_cruz_slow_param_tabs.ShowTabElements();
      m_cruz_tabs.SelectTab(0);
      m_cruz_tabs.ShowTabElements();

      if(!CWndCreate::CreateFrame(m_card_sobre,"",m_window,0,m_tabs,0,986,90,250,560,1))
         return(false);
      StyleFrame(m_card_sobre);
      if(!CWndCreate::CreateTextLabel(m_card_sobre_title,"Sobrecomprado / sobrevenda",m_card_sobre,0,m_tabs,0,12,10,250,20))
         return(false);

      CWndEvents::CompletedGUI();
      return(true);
     }

   void OnDeinitEvent(const int reason)
     {
      CWndEvents::Destroy();
     }

   virtual void OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
      if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
        {
         if(IsTabsButtonClicked(m_cruz_tabs,lparam))
            m_cruz_tabs.ShowTabElements();
         if(IsTabsButtonClicked(m_cruz_fast_param_tabs,lparam))
            m_cruz_fast_param_tabs.ShowTabElements();
         if(IsTabsButtonClicked(m_cruz_slow_param_tabs,lparam))
            m_cruz_slow_param_tabs.ShowTabElements();
         return;
        }

      if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM)
        {
         SyncCrossCombosFromGeneral();
         SyncCrossParamTabsFromIndicatorCombos();
         return;
        }
     }
  };

CEAFastUI g_ui;

int OnInit()
  {
   if(!g_ui.CreateGUI())
     {
      Print(__FUNCTION__," > falha ao criar GUI");
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   g_ui.OnDeinitEvent(reason);
  }

void OnTick()
  {
  }

void OnTimer()
  {
   g_ui.OnTimerEvent();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   g_ui.ChartEvent(id,lparam,dparam,sparam);
  }
