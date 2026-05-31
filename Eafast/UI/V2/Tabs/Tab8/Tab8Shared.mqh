#ifndef __CONSTRUTOR_V2_TAB8_SHARED_MQH__
#define __CONSTRUTOR_V2_TAB8_SHARED_MQH__

#include "..\\..\\V2Shared.mqh"

bool V2CreateSectionPlaceholder(CWndCreate &wnd,CFrame &frame,CTextLabel &title,CTextLabel &body,CElement &owner,CTabs &tabs,const int window_index,const int tab_index,const int x,const int y,const int w,const int h,const string section_title,const string body_text)
  {
   if(!V2CreateCard(wnd,frame,tabs,window_index,tab_index,x,y,w,h,V2_COLOR_CARD_BACK,V2_COLOR_CARD_BORDER))
      return(false);
   if(!V2CreateCardTitle(wnd,title,section_title,frame,tabs,window_index,tab_index,16,12,w-32))
      return(false);
   if(!wnd.CreateTextLabel(body,body_text,frame,window_index,tabs,tab_index,16,42,w-32,h-58))
      return(false);
   body.FontSize(10);
   body.LabelColor(V2_COLOR_TEXT_SECONDARY);
   return(true);
  }

#endif // __CONSTRUTOR_V2_TAB8_SHARED_MQH__


