#include <graphics.h> 
#include <stdlib.h> 
#include <stdio.h> 
#include <conio.h> 

int main(void) 
{ 
  int gdriver = DETECT, gmode;
  initgraph(&gdriver, &gmode, "c:\\tc");
  /* 设定文字的类型 */
  settextstyle(TRIPLEX_FONT, HORIZ_DIR, 4);
  /* 设定文字开始的位置 */ 
  moveto(0, getmaxy() / 2); 
  /* 输出正常文字*/ 
  outtext("Norm "); 
  /* 设定1/3倍于普通文字*/ 
  setusercharsize(1, 3, 1, 1); 
  outtext("Short "); 
  /* 设定3倍于普通文字*/ 
  setusercharsize(3, 1, 1, 1); 
  outtext("Wide"); 
  getch(); 
  closegraph(); 
  return 0; 
} 
