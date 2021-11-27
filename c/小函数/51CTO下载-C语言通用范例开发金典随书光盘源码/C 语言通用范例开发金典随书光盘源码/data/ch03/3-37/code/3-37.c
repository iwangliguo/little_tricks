#include<dos.h>
#include<graphics.h>
#include<stdio.h>
#include<stdlib.h>
#include<conio.h>
union REGS in,o;

circ()/*绘制第二个视觉欺骗图形：分辨线是否为直的*/
{
  int i;
  for(i=0;i<15;i++)
    circle(320,240,i*10);
  rectangle(240,160,400,320);
}

bulb()/*绘制第三个视觉欺骗图形：是否在在旋转*/
{
  int i=1,c=1;
  randomize();
  while(!kbhit())
  {
    if((i%2)==0)
    setcolor(c++);
    setfillstyle(1,getcolor());
    circle(320,240,i*20);
    putpixel(320-i+2,240-i+2,1);
    floodfill(320-i+2,240-i+2,getcolor());
    delay(1000);
    i++;
    if(i>=5)
      i=1;
  }
}

dot()/*用来绘制第一个视觉欺骗图形：分辨黑色点的个数*/
{
  int i,j,of=40,wid=5;
  setcolor(8);
  setfillstyle(1,getcolor());
  for(i=of;i<getmaxx();i+=of)
    bar(i,0,i+wid,getmaxy());
  for(i=of;i<getmaxy();i+=of)
    bar(0,i,getmaxx(),i+wid);
  for(i=of;i<getmaxx();i+=of)
    for(j=of;j<getmaxy();j+=of)
    {
      setcolor(15);
      setfillstyle(1,getcolor());
      circle(i+2,j+2,4);
      floodfill(i+2,j+2,getcolor());
    }
}

void main()
{
  int gd=DETECT,gm,i;
  initgraph(&gd,&gm,"c:\\tc");
  setcolor(YELLOW);
  settextstyle(1,0,6);
  outtextxy(0,240,"Count the black dots.....");
  sleep(4);
  cleardevice();
  dot();
  getch();
  cleardevice();
  setcolor(YELLOW);
  settextstyle(1,0,4);
  outtextxy(0,240,"I bet the lines of rectangle are straight.....");
  sleep(4);
  getch();
  cleardevice();
  circ();
  getch();
  cleardevice();
  setcolor(YELLOW);
  settextstyle(1,0,4);
  outtextxy(0,240,"I bet the circle is rounding.....");
  sleep(4);
  getch();
  cleardevice();
  bulb();
  getch();
  closegraph();
}