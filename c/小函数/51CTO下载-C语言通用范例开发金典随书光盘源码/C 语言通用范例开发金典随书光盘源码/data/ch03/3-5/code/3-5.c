#include <graphics.h> 
#include <stdlib.h> 
#include <stdio.h> 
#include <conio.h> 

int main(void) 
{ 
  int gdriver = DETECT, gmode;
  initgraph(&gdriver, &gmode, "c:\\tc");
  /* �趨���ֵ����� */
  settextstyle(TRIPLEX_FONT, HORIZ_DIR, 4);
  /* �趨���ֿ�ʼ��λ�� */ 
  moveto(0, getmaxy() / 2); 
  /* �����������*/ 
  outtext("Norm "); 
  /* �趨1/3������ͨ����*/ 
  setusercharsize(1, 3, 1, 1); 
  outtext("Short "); 
  /* �趨3������ͨ����*/ 
  setusercharsize(3, 1, 1, 1); 
  outtext("Wide"); 
  getch(); 
  closegraph(); 
  return 0; 
} 
