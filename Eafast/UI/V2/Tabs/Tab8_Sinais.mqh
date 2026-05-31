#ifndef __CONSTRUTOR_V2_TAB8_SINAIS_MQH__
#define __CONSTRUTOR_V2_TAB8_SINAIS_MQH__

#include "..\\V2Shared.mqh"
#include "Tab8\\Tab8SinaisMainView.mqh"
#include "Tab8\\Tab8MontarMainView.mqh"

class CTab8SinaisV2 : public CWndCreate
  {
private:
   CWndCreate           *m_host;
   bool                  m_created;
   bool                  m_is_active;
   int                   m_window_index;
   int                   m_last_selected_tab;

   CTabs                 m_inner_tabs;
   CV2BusyProgress       m_busy_progress;
   CTab8SinaisMainView   m_sinais_view;
   CTab8MontarMainView   m_montar_view;

public:
                        CTab8SinaisV2(void) : m_host(NULL), m_created(false), m_is_active(false), m_window_index(-1), m_last_selected_tab(-1) {}

   bool Create(CWndCreate &host,int window_index,CElement &owner,const int x,const int y,const int width,const int height)
     {
      if(m_created)
         return(true);

      m_host=&host;
      m_window_index=window_index;

      string inner_text[];
      int inner_widths[];
      ArrayResize(inner_text,2);
      ArrayResize(inner_widths,2);
      inner_text[0]="Sinais";
      inner_text[1]="Montar sinais";
      inner_widths[0]=width/2;
      inner_widths[1]=width-inner_widths[0];

      m_inner_tabs.MainPointer(owner);
      m_inner_tabs.XSize(width);
      m_inner_tabs.YSize(height);
      m_inner_tabs.IsCenterText(true);
      m_inner_tabs.PositionMode(TABS_TOP);
      m_inner_tabs.TabsYSize(28);
      m_inner_tabs.BackColorPressed(V2_COLOR_CARD_BACK);
      m_inner_tabs.BorderColor(V2_COLOR_CARD_BORDER);
      m_inner_tabs.BorderColorHover(V2_COLOR_CARD_BORDER);
      m_inner_tabs.BorderColorPressed(V2_COLOR_CARD_BORDER);

      for(int i=0;i<2;i++)
         m_inner_tabs.AddTab(inner_text[i],inner_widths[i]);

      if(!m_inner_tabs.CreateTabs(x,y))
         return(false);
      CWndContainer::AddToElementsArray(m_window_index,m_inner_tabs);

      if(!m_busy_progress.Create(*m_host,owner,m_window_index,x+2,y+34,width-4))
         return(false);

      CButtonsGroup *bg=m_inner_tabs.GetButtonsGroupPointer();
      if(bg!=NULL)
        {
         for(int i=0;i<2;i++)
           {
            bg.GetButtonPointer(i).FontSize(9);
            bg.GetButtonPointer(i).BackColor(C'39,54,78');
            bg.GetButtonPointer(i).BackColorHover(C'62,79,101');
            bg.GetButtonPointer(i).BackColorPressed(C'226,114,64');
            bg.GetButtonPointer(i).BorderColor(C'18,29,43');
            bg.GetButtonPointer(i).BorderColorHover(C'62,79,101');
            bg.GetButtonPointer(i).BorderColorPressed(C'240,140,86');
            bg.GetButtonPointer(i).LabelColor(clrWhite);
            bg.GetButtonPointer(i).LabelColorHover(clrWhite);
            bg.GetButtonPointer(i).LabelColorPressed(clrWhite);
           }
        }

      if(!m_sinais_view.Create(*m_host,m_window_index,m_inner_tabs,0))
         return(false);
      if(!m_montar_view.Create(*m_host,m_window_index,m_inner_tabs,1))
         return(false);

      m_inner_tabs.SelectTab(0);
      m_last_selected_tab=0;
      m_created=true;
      return(true);
     }

   void SetActive(const bool active,const bool redraw=true)
     {
      if(!m_created)
         return;

      m_is_active=active;
      if(!active)
        {
         m_sinais_view.SetActive(false);
         m_montar_view.SetActive(false,redraw);
         m_inner_tabs.Hide();
         if(redraw)
            m_inner_tabs.Update();
         return;
        }

      m_inner_tabs.Show();
      m_inner_tabs.Update();
      m_inner_tabs.ShowTabElements();
      const int selected=m_inner_tabs.SelectedTab();
      m_sinais_view.SetActive(selected==0);
      m_montar_view.SetActive(selected==1);
      if(selected==1)
         m_montar_view.RefreshSlots();
      if(redraw)
         ChartRedraw();
     }

   void OnTimerEvent(void)
     {
      if(!m_created || !m_is_active)
         return;

      const int selected=m_inner_tabs.SelectedTab();
      if(selected!=m_last_selected_tab)
        {
         m_last_selected_tab=selected;
         m_inner_tabs.ShowTabElements();
         m_sinais_view.SetActive(selected==0);
         m_montar_view.SetActive(selected==1);
         if(selected==1)
            m_montar_view.RefreshSlots();
        }

      m_sinais_view.OnTimerEvent();
      m_montar_view.OnTimerEvent();
     }

   bool HandleEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
      if(!m_created || !m_is_active)
         return(false);

      if(m_sinais_view.HandleEvent(id,lparam,dparam,sparam))
         return(true);

      return(false);
     }
  };

#endif // __CONSTRUTOR_V2_TAB8_SINAIS_MQH__
