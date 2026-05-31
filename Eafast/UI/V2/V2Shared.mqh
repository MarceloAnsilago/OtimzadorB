#ifndef __CONSTRUTOR_V2_SHARED_MQH__
#define __CONSTRUTOR_V2_SHARED_MQH__

#include "..\\..\\EasyAndFastGUI\\WndCreate.mqh"

const color V2_COLOR_CARD_BACK=C'233,220,203';
const color V2_COLOR_CARD_BORDER=C'197,168,136';
const color V2_COLOR_FIELD_BORDER=C'91,78,64';
const color V2_COLOR_TEXT_PRIMARY=C'43,43,43';
const color V2_COLOR_TEXT_SECONDARY=C'91,78,64';
const color V2_COLOR_SURFACE=C'239,231,218';

int V2ClampIndex(const int value,const int min_value,const int max_value)
  {
   if(value<min_value)
      return(min_value);
   if(value>max_value)
      return(max_value);
   return(value);
  }

bool V2TryParseHourMin(const string value,int &hour,int &minute)
  {
   if(StringLen(value)<5)
      return(false);
   const int sep=StringFind(value,":");
   if(sep<0)
      return(false);

   hour=(int)StringToInteger(StringSubstr(value,0,sep));
   minute=(int)StringToInteger(StringSubstr(value,sep+1));
   return(true);
  }

void V2ItemsSimNao(string &items[])
  {
   ArrayResize(items,2);
   items[0]="Nao";
   items[1]="Sim";
  }

void V2ItemsMercado(string &items[])
  {
   ArrayResize(items,2);
   items[0]="B3";
   items[1]="Forex";
  }

void V2ItemsTipoOperacional(string &items[])
  {
   ArrayResize(items,2);
   items[0]="Day trade";
   items[1]="Swing trade";
  }

void V2ItemsModoProcessamento(string &items[])
  {
   ArrayResize(items,2);
   items[0]="Cada tick";
   items[1]="Cada segundo";
  }

void V2ItemsTempoGrafico(string &items[])
  {
   ArrayResize(items,21);
   items[0]="Corrente";
   items[1]="M1";
   items[2]="M2";
   items[3]="M3";
   items[4]="M4";
   items[5]="M5";
   items[6]="M6";
   items[7]="M10";
   items[8]="M12";
   items[9]="M15";
   items[10]="M30";
   items[11]="H1";
   items[12]="H2";
   items[13]="H3";
   items[14]="H4";
   items[15]="H6";
   items[16]="H8";
   items[17]="H12";
   items[18]="D1";
   items[19]="W1";
   items[20]="MN1";
  }

void V2ItemsHoras(string &items[])
  {
   ArrayResize(items,24);
   for(int i=0;i<24;i++)
      items[i]=StringFormat("%02d",i);
  }

void V2ItemsMinutos(string &items[])
  {
   ArrayResize(items,60);
   for(int i=0;i<60;i++)
      items[i]=StringFormat("%02d",i);
  }

void V2ItemsStopTipo(string &items[])
  {
   ArrayResize(items,2);
   items[0]="Pontos";
   items[1]="Percentual";
  }

void V2ItemsBaseMedia(string &items[])
  {
   ArrayResize(items,4);
   items[0]="Maxima";
   items[1]="Minima";
   items[2]="Abertura";
   items[3]="Fechamento";
  }

void V2ItemsBaseMultiplicador(string &items[])
  {
   ArrayResize(items,2);
   items[0]="Corpo do candle";
   items[1]="Range (pavio a pavio)";
  }

void V2ItemsPosicaoReferencia(string &items[])
  {
   ArrayResize(items,4);
   items[0]="Atual";
   items[1]="Ultimo";
   items[2]="Penultimo";
   items[3]="Antepenultimo";
  }

void V2ItemsExpirar(string &items[])
  {
   ArrayResize(items,5);
   items[0]="Nao expirar";
   items[1]="1 candle";
   items[2]="2 candles";
   items[3]="3 candles";
   items[4]="4 candles";
  }

string V2SignalDirectionMessage(const bool is_buy)
  {
   if(is_buy)
      return("Voce esta criando um sinal de compra, o de venda sera gerado automaticamente.");
   return("Voce esta criando um sinal de venda, o de compra sera gerado automaticamente.");
  }

void V2StyleCombo(CComboBox &combo,const color border,const int width,const int list_height,const int button_width)
  {
   combo.XSize(width);
   combo.YSize(20);
   combo.BackColor(clrWhite);
   combo.BackColorHover(clrWhite);
   combo.BackColorPressed(clrWhite);
   combo.BorderColor(border);
   combo.BorderColorHover(border);
   combo.BorderColorPressed(border);
   combo.FontSize(10);
   combo.CheckBoxMode(false);
   combo.GetButtonPointer().XSize(button_width);
   combo.GetButtonPointer().XGap(1);
   combo.GetButtonPointer().YSize(20);
   combo.GetButtonPointer().AnchorRightWindowSide(false);
   combo.GetButtonPointer().BackColor(clrWhite);
   combo.GetButtonPointer().BackColorHover(clrWhite);
   combo.GetButtonPointer().BackColorPressed(clrWhite);
   combo.GetButtonPointer().BorderColor(border);
   combo.GetButtonPointer().BorderColorHover(border);
   combo.GetButtonPointer().BorderColorPressed(border);
   combo.GetButtonPointer().IconXGap(button_width-18);
   combo.GetButtonPointer().LabelXGap(10);
   combo.GetButtonPointer().LabelColor(V2_COLOR_TEXT_PRIMARY);
   combo.GetListViewPointer().YSize(list_height);
   combo.GetListViewPointer().LightsHover(true);
   combo.GetListViewPointer().BackColor(clrWhite);
  }

void V2StyleSpin(CTextEdit &spin,const color back,const color border,const int width,const double max_value,const double min_value,const double step,const int digits,const string value)
  {
   spin.XSize(width);
   spin.MaxValue(max_value);
   spin.MinValue(min_value);
   spin.StepValue(step);
   spin.SetDigits(digits);
   spin.SpinEditMode(true);
   spin.CheckBoxMode(false);
   spin.SetValue(value);
   spin.GetTextBoxPointer().XSize(width-34);
   spin.GetTextBoxPointer().AutoSelectionMode(true);
   spin.GetTextBoxPointer().AnchorRightWindowSide(false);
   spin.GetTextBoxPointer().XGap(1);
   spin.BackColor(back);
   spin.BackColorHover(back);
   spin.BackColorPressed(back);
   spin.BorderColor(border);
   spin.BorderColorHover(border);
   spin.BorderColorPressed(border);
   spin.GetTextBoxPointer().BackColor(clrWhite);
   spin.GetTextBoxPointer().BackColorHover(clrWhite);
   spin.GetTextBoxPointer().BackColorPressed(clrWhite);
   spin.GetTextBoxPointer().BorderColor(border);
   spin.GetTextBoxPointer().BorderColorHover(border);
   spin.GetTextBoxPointer().BorderColorPressed(border);
   spin.GetIncButtonPointer().BackColor(clrWhite);
   spin.GetIncButtonPointer().BackColorHover(clrWhite);
   spin.GetIncButtonPointer().BackColorPressed(clrWhite);
   spin.GetIncButtonPointer().BorderColor(border);
   spin.GetIncButtonPointer().BorderColorHover(border);
   spin.GetIncButtonPointer().BorderColorPressed(border);
   spin.GetDecButtonPointer().BackColor(clrWhite);
   spin.GetDecButtonPointer().BackColorHover(clrWhite);
   spin.GetDecButtonPointer().BackColorPressed(clrWhite);
   spin.GetDecButtonPointer().BorderColor(border);
   spin.GetDecButtonPointer().BorderColorHover(border);
   spin.GetDecButtonPointer().BorderColorPressed(border);
  }

void V2StyleTextEdit(CTextEdit &edit,const color border,const int width)
  {
   edit.XSize(width);
   edit.YSize(20);
   edit.CheckBoxMode(false);
   edit.SpinEditMode(false);
   edit.BackColor(clrWhite);
   edit.BackColorHover(clrWhite);
   edit.BackColorPressed(clrWhite);
   edit.BorderColor(border);
   edit.BorderColorHover(border);
   edit.BorderColorPressed(border);
   edit.GetTextBoxPointer().BackColor(clrWhite);
   edit.GetTextBoxPointer().BackColorHover(clrWhite);
   edit.GetTextBoxPointer().BackColorPressed(clrWhite);
   edit.GetTextBoxPointer().BorderColor(border);
   edit.GetTextBoxPointer().BorderColorHover(border);
   edit.GetTextBoxPointer().BorderColorPressed(border);
  }

bool V2CreateCard(CWndCreate &wnd,CFrame &frame,CTabs &tabs,const int window_index,const int tab_index,const int x,const int y,const int w,const int h,const color back,const color border)
  {
   if(!wnd.CreateFrame(frame,"",tabs,window_index,tabs,tab_index,x,y,w,h,1))
      return(false);
   frame.BackColor(back);
   frame.BorderColor(border);
   return(true);
  }

bool V2CreateCardTitle(CWndCreate &wnd,CTextLabel &label,const string text,CElement &owner,CTabs &tabs,const int window_index,const int tab_index,const int x,const int y,const int w)
  {
   if(!wnd.CreateTextLabel(label,text,owner,window_index,tabs,tab_index,x,y,w,22))
      return(false);
   label.FontSize(12);
   label.LabelColor(V2_COLOR_TEXT_PRIMARY);
   return(true);
  }

bool V2CreateFieldLabel(CWndCreate &wnd,CTextLabel &label,const string text,CElement &owner,CTabs &tabs,const int window_index,const int tab_index,const int x,const int y,const int w,const int h=18)
  {
   if(!wnd.CreateTextLabel(label,text,owner,window_index,tabs,tab_index,x,y,w,h))
      return(false);
   label.FontSize(10);
   label.LabelColor(V2_COLOR_TEXT_SECONDARY);
   return(true);
  }

class CV2BusyProgress
  {
private:
   CProgressBar m_bar;
   bool             m_created;

public:
                     CV2BusyProgress(void) : m_created(false) {}

   bool Create(CWndCreate &wnd,CElement &owner,const int window_index,const int x,const int y,const int width,const string text="Organizando interface")
     {
      if(m_created)
         return(true);

      m_bar.XSize(width);
      m_bar.YSize(18);
      m_bar.BarYSize(12);
      m_bar.BarBorderWidth(1);
      m_bar.BarYGap(4);
      m_bar.LabelXGap(0);
      m_bar.LabelYGap(0);
      m_bar.PercentXGap(6);
      m_bar.PercentYGap(0);
      m_bar.FontSize(9);
      m_bar.LabelColor(V2_COLOR_TEXT_SECONDARY);
      m_bar.BorderColor(V2_COLOR_CARD_BORDER);
      m_bar.IndicatorBackColor(clrWhite);
      m_bar.IndicatorColor(C'226,114,64');
      if(!wnd.CreateProgressBar(m_bar,text,owner,window_index,x,y))
         return(false);

      m_bar.Hide();
      m_created=true;
      return(true);
     }

   void Begin(const string text,const int total=3)
     {
      if(!m_created)
         return;
      m_bar.LabelText(text);
      m_bar.Show();
      m_bar.Update(0,total);
      ChartRedraw();
     }

   void Step(const int index,const int total=3)
     {
      if(!m_created)
         return;
      m_bar.Update(index,total);
      ChartRedraw();
     }

   void Finish(void)
     {
      if(!m_created)
         return;
      m_bar.Hide();
      ChartRedraw();
     }
  };

#endif // __CONSTRUTOR_V2_SHARED_MQH__


