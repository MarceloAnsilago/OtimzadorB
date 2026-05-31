#ifndef __CONSTRUTOR_V2_TAB8_MONTAR_MAIN_VIEW_MQH__
#define __CONSTRUTOR_V2_TAB8_MONTAR_MAIN_VIEW_MQH__

#include "Tab8Shared.mqh"
#include "Tab8MontarSlotCard.mqh"

class CTab8MontarMainView : public CWndCreate
  {
private:
   CWndCreate        *m_host;
   bool                   m_created;
   bool                   m_is_active;
   int                    m_window_index;
   int                    m_tab_index;
   CTab8MontarSlotCard    m_slot_cards[4];
   STab8MontarSlotState   m_slot_states[4];
   CFrame             m_logic_card;
   CTextLabel         m_logic_title;
   CTextLabel         m_logic_note;
   CTextLabel         m_logic_cols[6];
   CComboBox          m_logic_operator_combo[5];
   CComboBox          m_logic_candle_combo[5];
   CComboBox          m_logic_value_combo[5];
   CComboBox          m_logic_compare_combo[5];
   CComboBox          m_logic_compare_value_combo[5];
   CComboBox          m_logic_compare_candle_combo[5];
   int                    m_logic_slot_last[4];

   void SetLabelVisible(CTextLabel &label,const bool visible,const bool redraw=true)
     {
      if(visible)
         label.Show();
      else
         label.Hide();
      if(redraw)
         label.Update(true);
     }

   void SetFrameVisible(CFrame &frame,const bool visible,const bool redraw=true)
     {
      if(visible)
         frame.Show();
      else
         frame.Hide();
      if(redraw)
         frame.Update(true);
     }

   void SetComboVisible(CComboBox &combo,const bool visible,const bool redraw=true)
     {
      if(visible)
         combo.Show();
      else
         combo.Hide();
      if(redraw)
         combo.Update(true);
     }

   bool CreateComboControl(CComboBox &combo,CElement &owner,CTabs &tabs,const int x,const int y,const int width,const int list_height,string &items[],const int selected_index,const color border)
     {
      combo.MainPointer(owner);
      tabs.AddToElementsArray(m_tab_index,combo);
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

   int SlotIndicatorIndex(const int slot) const
     {
      return(V2ClampIndex(m_slot_states[slot].selected_indicator,0,40));
     }

   void SaveAllSlotStates(void)
     {
      for(int i=0;i<4;i++)
         m_slot_cards[i].SaveState(m_slot_states[i]);
     }

   void BuildLogicValueItems(string &items[])
     {
      ArrayResize(items,115);
      int total=0;

      items[total++]="Nao usar";
      items[total++]="Valor absoluto";
      items[total++]="Valor em pontos";
      items[total++]="Preco de entrada";
      items[total++]="Preco medio";
      items[total++]="Preco atual";
      items[total++]="Fechamento da vela";
      items[total++]="Abertura da vela";
      items[total++]="Maxima da vela";
      items[total++]="Minima da vela";
      items[total++]="Fechamento do dia";
      items[total++]="Abertura do dia";
      items[total++]="Maxima do dia";
      items[total++]="Minima do dia";
      items[total++]="Tamanho da vela";
      items[total++]="Corpo da vela";
      items[total++]="Empty Value";

      for(int slot=0;slot<4;slot++)
        {
         const int idx=SlotIndicatorIndex(slot);
         const string prefix=(string)(slot+1)+" ";

         if(idx==1)
           {
            items[total++]=prefix+"keltner Central";
            items[total++]=prefix+"keltner superior";
            items[total++]=prefix+"keltner inferior";
           }
         else if(idx==2)
           {
            items[total++]=prefix+"dochian superior";
            items[total++]=prefix+"dochian central";
            items[total++]=prefix+"dochian inferior";
           }
         else if(idx==3)
           {
            items[total++]=prefix+"regressao Ratio";
           }
         else if(idx==4)
           {
            items[total++]=prefix+"afastamento medio";
           }
         else if(idx==5)
           {
            items[total++]=prefix+"desvio afastamento";
            items[total++]=prefix+"desvio medio";
           }
         else if(idx==6)
           {
            items[total++]=prefix+"atr superior";
            items[total++]=prefix+"atr central";
            items[total++]=prefix+"atr inferior";
           }
         else if(idx==7)
           {
            items[total++]=prefix+"media movel";
           }
         else if(idx==8)
           {
            items[total++]=prefix+"bandas superior";
            items[total++]=prefix+"bandas central";
            items[total++]=prefix+"bandas inferior";
           }
         else if(idx==9)
           {
            items[total++]=prefix+"envelope superior";
            items[total++]=prefix+"envelope inferior";
           }
         else if(idx==10)
           {
            items[total++]=prefix+"estocastico principal";
            items[total++]=prefix+"estocastico sinal";
           }
         else if(idx==11)
           {
            items[total++]=prefix+"rsi";
           }
         else if(idx==12)
           {
            items[total++]=prefix+"desvio padrao";
           }
         else if(idx==13)
           {
            items[total++]=prefix+"volume";
           }
         else if(idx==14)
           {
            items[total++]=prefix+"atr";
           }
         else if(idx==15)
           {
            items[total++]=prefix+"parabolic sar";
           }
         else if(idx==16)
           {
            items[total++]=prefix+"fractal superior";
            items[total++]=prefix+"fractal inferior";
           }
         else if(idx==17)
           {
            items[total++]=prefix+"obv";
           }
         else if(idx==18)
           {
            items[total++]=prefix+"macd histograma";
            items[total++]=prefix+"mack sinal";
           }
         else if(idx==19)
           {
            items[total++]=prefix+"acumulacao/distribuicao (a/d)";
           }
         else if(idx==20)
           {
            items[total++]=prefix+"mfi (money flow index)";
           }
         else if(idx==21)
           {
            items[total++]=prefix+"vidya - valor";
           }
         else if(idx==22)
           {
            items[total++]=prefix+"tema - valor";
           }
         else if(idx==23)
           {
            items[total++]=prefix+"frama-valor";
           }
         else if(idx==24)
           {
            items[total++]=prefix+"trix valor";
           }
         else if(idx==25)
           {
            items[total++]=prefix+"bears power valor";
           }
         else if(idx==26)
           {
            items[total++]=prefix+"bulls power valor";
           }
         else if(idx==27)
           {
            items[total++]=prefix+"chaikin oscilador valor";
           }
         else if(idx==28)
           {
            items[total++]=prefix+"accelerator oscillator valor";
           }
         else if(idx==29)
           {
            items[total++]=prefix+"awesome oscillator valor";
           }
         else if(idx==30)
           {
            items[total++]=prefix+"cci (commodity channel index) valor";
           }
         else if(idx==31)
           {
            items[total++]=prefix+"demarker valor";
           }
         else if(idx==32)
           {
            items[total++]=prefix+"alligator mandibula";
            items[total++]=prefix+"alligator dente";
            items[total++]=prefix+"alligator boca";
           }
         else if(idx==33)
           {
            items[total++]=prefix+"ichimoku tenkan-sen";
            items[total++]=prefix+"ichimoku kijun-sen";
            items[total++]=prefix+"ichimoku senkou span a";
            items[total++]=prefix+"ichimoku senkou span b";
            items[total++]=prefix+"ichimoku chinkou span";
           }
         else if(idx==34)
           {
            items[total++]=prefix+"adx";
            items[total++]=prefix+"di+";
            items[total++]=prefix+"di-";
           }
         else if(idx==35)
           {
            items[total++]=prefix+"adx wilder";
            items[total++]=prefix+"adx wilder di +";
            items[total++]=prefix+"adx wilder di-";
           }
         else if(idx==36)
           {
            items[total++]=prefix+"gator superior";
            items[total++]=prefix+"gator inferior";
           }
         else if(idx==37)
           {
            items[total++]=prefix+"wpr";
           }
         else if(idx==38)
           {
            items[total++]=prefix+"market facilitation index";
           }
         else if(idx==39)
           {
            items[total++]=prefix+"momentum";
           }
         else if(idx==40)
           {
            items[total++]=prefix+"rvi sinal";
            items[total++]=prefix+"rvi principal";
           }
        }

      ArrayResize(items,total);
     }

   void RefreshLogicValueCombos(void)
     {
      string items[];
      BuildLogicValueItems(items);

      for(int row=0;row<5;row++)
        {
         const int selected_idx=m_logic_value_combo[row].GetListViewPointer().SelectedItemIndex();
         const int compare_selected_idx=m_logic_compare_value_combo[row].GetListViewPointer().SelectedItemIndex();

         m_logic_value_combo[row].ItemsTotal(ArraySize(items));
         m_logic_compare_value_combo[row].ItemsTotal(ArraySize(items));

         for(int item_idx=0;item_idx<ArraySize(items);item_idx++)
           {
            m_logic_value_combo[row].SetValue(item_idx,items[item_idx]);
            m_logic_compare_value_combo[row].SetValue(item_idx,items[item_idx]);
           }

         const int next_selected=(selected_idx>=0 && selected_idx<ArraySize(items) ? selected_idx : 0);
         const int next_compare_selected=(compare_selected_idx>=0 && compare_selected_idx<ArraySize(items) ? compare_selected_idx : 0);

         m_logic_value_combo[row].SelectItem(next_selected);
         m_logic_compare_value_combo[row].SelectItem(next_compare_selected);
         m_logic_value_combo[row].Update(true);
         m_logic_value_combo[row].GetButtonPointer().Update(true);
         m_logic_value_combo[row].GetListViewPointer().Update(true);
         m_logic_compare_value_combo[row].Update(true);
         m_logic_compare_value_combo[row].GetButtonPointer().Update(true);
         m_logic_compare_value_combo[row].GetListViewPointer().Update(true);
        }
     }

public:
                        CTab8MontarMainView(void) : m_host(NULL), m_created(false), m_is_active(false), m_window_index(-1), m_tab_index(-1)
                          {
                           for(int i=0;i<4;i++)
                             {
                              m_logic_slot_last[i]=-1;
                              m_slot_states[i].selected_indicator=0;
                             }
                          }

   bool Create(CWndCreate &host,int window_index,CTabs &tabs,const int tab_index)
     {
      if(m_created)
         return(true);

      m_host=&host;
      m_window_index=window_index;
      m_tab_index=tab_index;

      const int tabs_w=tabs.XSize();
      const int tabs_h=tabs.YSize();
      const int content_pad=18;
      const int content_y=8;
      const int content_w=tabs_w-(content_pad*2);
      const int gap=4;
      const int top_h=(tabs_h-content_y-20)/3;
      const int slot_grid_y=content_y+6;
      const int slot_w=(content_w-(gap*3))/4;
      const int slot_h=top_h+56;
      int slot_x[4];
      int slot_y[4];
      slot_x[0]=content_pad;
      slot_x[1]=content_pad+slot_w+gap;
      slot_x[2]=content_pad+(slot_w+gap)*2;
      slot_x[3]=content_pad+(slot_w+gap)*3;
      slot_y[0]=slot_grid_y;
      slot_y[1]=slot_grid_y;
      slot_y[2]=slot_grid_y;
      slot_y[3]=slot_grid_y;
      const int logic_y=slot_grid_y+slot_h+32;
      const int logic_h=tabs_h-logic_y-14;
      for(int i=0;i<4;i++)
        {
         if(!m_slot_cards[i].Create(*m_host,m_window_index,tabs,m_tab_index,i,slot_x[i],slot_y[i],slot_w,slot_h,true))
            return(false);
         m_slot_cards[i].SaveState(m_slot_states[i]);
        }

      if(!V2CreateCard(*m_host,m_logic_card,tabs,m_window_index,m_tab_index,content_pad,logic_y,content_w,logic_h,V2_COLOR_CARD_BACK,V2_COLOR_CARD_BORDER))
         return(false);
      if(!V2CreateCardTitle(*m_host,m_logic_title,"ComposiÃ§Ã£o lÃ³gica dos sinais",m_logic_card,tabs,m_window_index,m_tab_index,16,12,content_w-32))
         return(false);
      if(!m_host.CreateTextLabel(m_logic_note,"Conectores lÃ³gicos migrados da V1 para montar as comparaÃ§Ãµes entre os 4 indicadores salvos no editor acima.",m_logic_card,m_window_index,tabs,m_tab_index,16,40,content_w-32,20))
         return(false);
      m_logic_note.FontSize(10);
      m_logic_note.LabelColor(V2_COLOR_TEXT_SECONDARY);

      string col_titles[];
      ArrayResize(col_titles,6);
      col_titles[0]="Operador";
      col_titles[1]="Valor ref.";
      col_titles[2]="Velas";
      col_titles[3]="ComparaÃ§Ã£o";
      col_titles[4]="Valor comp.";
      col_titles[5]="Velas comp.";

      string logic_items[];
      ArrayResize(logic_items,7);
      logic_items[0]="SE";
      logic_items[1]="E";
      logic_items[2]="OU";
      logic_items[3]="E SE";
      logic_items[4]="OU SE";
      logic_items[5]="E Tambem";
      logic_items[6]="OU Tambem";

      string candle_items[];
      ArrayResize(candle_items,4);
      candle_items[0]="Vela atual";
      candle_items[1]="Vela anterior";
      candle_items[2]="PenÃºltima vela";
      candle_items[3]="AntepenÃºltima";

      string compare_items[];
      ArrayResize(compare_items,10);
      compare_items[0]="Maior que";
      compare_items[1]="Menor que";
      compare_items[2]="Maior ou igual que";
      compare_items[3]="Menor ou igual que";
      compare_items[4]="Igual que";
      compare_items[5]="Diferente de";
      compare_items[6]="Cruzar p/ cima de";
      compare_items[7]="Cruzar p/ baixo de";
      compare_items[8]="Cruzar&fechar acima de";
      compare_items[9]="Cruzar&fechar abaixo de";

      string value_items[];
      BuildLogicValueItems(value_items);

      const int table_x=16;
      const int table_y=64;
      const int table_w=content_w-32;
      const int col_gap=6;
      const int logic_w=84;
      const int candle_w=92;
      const int compare_w=126;
      const int value_w=(table_w-logic_w-(2*candle_w)-compare_w-(5*col_gap))/2;
      int col_x[6];
      int col_w[6];
      col_x[0]=table_x;
      col_x[1]=table_x+logic_w+col_gap;
      col_x[2]=col_x[1]+value_w+col_gap;
      col_x[3]=col_x[2]+candle_w+col_gap;
      col_x[4]=col_x[3]+compare_w+col_gap;
      col_x[5]=col_x[4]+value_w+col_gap;
      col_w[0]=logic_w;
      col_w[1]=value_w;
      col_w[2]=candle_w;
      col_w[3]=compare_w;
      col_w[4]=value_w;
      col_w[5]=candle_w;

      for(int i=0;i<6;i++)
        {
         if(!V2CreateFieldLabel(*m_host,m_logic_cols[i],col_titles[i],m_logic_card,tabs,m_window_index,m_tab_index,col_x[i],table_y,col_w[i],16))
            return(false);
        }

      int row_y=table_y+20;
      for(int i=0;i<5;i++)
        {
         if(!CreateComboControl(m_logic_operator_combo[i],m_logic_card,tabs,col_x[0],row_y,col_w[0],96,logic_items,0,V2_COLOR_CARD_BORDER))
            return(false);
         if(!CreateComboControl(m_logic_value_combo[i],m_logic_card,tabs,col_x[1],row_y,col_w[1],132,value_items,0,V2_COLOR_CARD_BORDER))
            return(false);
         if(!CreateComboControl(m_logic_candle_combo[i],m_logic_card,tabs,col_x[2],row_y,col_w[2],96,candle_items,0,V2_COLOR_CARD_BORDER))
            return(false);
         if(!CreateComboControl(m_logic_compare_combo[i],m_logic_card,tabs,col_x[3],row_y,col_w[3],120,compare_items,0,V2_COLOR_CARD_BORDER))
            return(false);
         if(!CreateComboControl(m_logic_compare_value_combo[i],m_logic_card,tabs,col_x[4],row_y,col_w[4],132,value_items,0,V2_COLOR_CARD_BORDER))
            return(false);
         if(!CreateComboControl(m_logic_compare_candle_combo[i],m_logic_card,tabs,col_x[5],row_y,col_w[5],96,candle_items,0,V2_COLOR_CARD_BORDER))
            return(false);
         row_y+=30;
        }

      m_created=true;
      SetActive(false,false);
      return(true);
     }

   void OnTimerEvent(void)
     {
      if(!m_created || !m_is_active)
         return;

      for(int i=0;i<4;i++)
         m_slot_cards[i].OnTimerEvent();
      SaveAllSlotStates();

      bool changed=false;
      for(int i=0;i<4;i++)
        {
         const int selected=SlotIndicatorIndex(i);
         if(selected!=m_logic_slot_last[i])
           {
            m_logic_slot_last[i]=selected;
            changed=true;
           }
        }

      if(changed)
         RefreshLogicValueCombos();
     }

   void RefreshSlots(void)
     {
      if(!m_created || !m_is_active)
         return;

      for(int i=0;i<4;i++)
         m_slot_cards[i].RefreshView();
      SaveAllSlotStates();

      for(int i=0;i<4;i++)
         m_logic_slot_last[i]=SlotIndicatorIndex(i);
      RefreshLogicValueCombos();
     }

   void SetActive(const bool active,const bool redraw=true)
     {
      if(!m_created)
         return;

      m_is_active=active;
      for(int i=0;i<4;i++)
         m_slot_cards[i].SetActive(active,redraw);
      SetFrameVisible(m_logic_card,active,redraw);
      SetLabelVisible(m_logic_title,active,redraw);
      SetLabelVisible(m_logic_note,active,redraw);
      for(int i=0;i<6;i++)
         SetLabelVisible(m_logic_cols[i],active,redraw);
      for(int i=0;i<5;i++)
        {
         SetComboVisible(m_logic_operator_combo[i],active,redraw);
         SetComboVisible(m_logic_value_combo[i],active,redraw);
         SetComboVisible(m_logic_candle_combo[i],active,redraw);
         SetComboVisible(m_logic_compare_combo[i],active,redraw);
         SetComboVisible(m_logic_compare_value_combo[i],active,redraw);
         SetComboVisible(m_logic_compare_candle_combo[i],active,redraw);
        }

      if(active)
         RefreshSlots();
     }
  };

#endif // __CONSTRUTOR_V2_TAB8_MONTAR_MAIN_VIEW_MQH__


