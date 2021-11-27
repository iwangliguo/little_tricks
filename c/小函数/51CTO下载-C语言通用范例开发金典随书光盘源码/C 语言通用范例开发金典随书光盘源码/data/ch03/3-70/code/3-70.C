#include "stdio.h"
#include "graphics.h"
#include "math.h" 
#include "conio.h" 
#define pi 3.14 

void drawgoal(int x,int y,int flag)
{ 
  setcolor (flag+2); 
  setfillstyle(1,flag); 
  fillellipse(x, y, 20, 20 ); 
} 
main(void) 
{ 
  int x=320,y=240; 
  float r=-120,d=0.1; 
  int gdriver=DETECT, gmode;
  initgraph(&gdriver, &gmode, "c:\\tc");
  while (!kbhit()) 
  {
    r=r+d; 
    if(r>120) 
    {
      r=-120;
      clrscr();
      d=d+0.1;
    } 
    if(r<0.1&&r>-0.1) 
    {
      clrscr();
      d=d+0.1;
    } 
    if(d>6.5) 
      d=0.1; 
    x=320+r*(sin(r)+cos(pi-r)); 
    y=240+r*(cos(r)+sin(pi-r)); 
    drawgoal(x,y,rand()%15+1); 
    delay(500);
  } 
  closegraph(); 
} 
 
