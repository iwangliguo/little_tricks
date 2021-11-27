#include <stdio.h>
#include <graphics.h>
#include <math.h>
main()
{
  int gd,gm;
  int i;
  unsigned long t;
  double alfa=0;
  double x,y;
  int time;
  /*图形初始化*/
  detectgraph(&gd,&gm);
  initgraph(&gd, &gm, "c:\\tc");
  setbkcolor(BLACK);/*设置背景色*/
  setcolor(WHITE);/*设置画笔颜色*/
  x=0; y=0;
  /*当前点移动到开始点*/
  moveto(x*40+20,y*100+300);
  for(x=0;x<15;x=x+0.1)
  {
    y=sin(x+alfa);
    lineto(x*40+20,y*100+300);
  }
  getch();
  closegraph();
} 
