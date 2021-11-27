#include "graphics.h" 
#include "math.h" 
#include "conio.h" 
#define pi 3.14 

void drawgoal(int x,int y,int flag)/*flagÑÕÉ«*/ 
{ 
  setcolor (0); 
  setfillstyle(1,0); 
  bar(x-10,y-10,x+10,y+10); 
  setcolor (flag+2); 
  setfillstyle(1,flag); 
  fillellipse(x, y, 10, 10 ); 
} 
main(void) 
{ 
  int x=320,y=240; 
  float r=0.1,d=0.001,R=0; 
  int gdriver=DETECT, gmode; 
  initgraph(&gdriver, &gmode, "c:\\tc");  
  while (!kbhit()) 
  {
    r=r+5*d; 
    if(r>120) 
    {
      r=-120;
      clrscr();
      d+=0.001;
    } 
    if(r<0.1&&r>-0.1) 
    {
      clrscr();
      d+=0.001;
    } 
    if(d>0.02) d=0.001; 
    R=R+0.01; 
    x=320+r*(sin(R)+cos(pi-R)); 
    y=240+r*(cos(R)+sin(pi-R)); 
    drawgoal(x,y,rand()%15+1); 
  } 
  closegraph(); 
}