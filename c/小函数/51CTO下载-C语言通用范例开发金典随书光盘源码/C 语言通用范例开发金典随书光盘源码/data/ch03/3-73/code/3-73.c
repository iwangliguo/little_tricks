#include <bios.h>
#include <math.h>
#include <graphics.h>
#include <stdio.h>
#include <time.h>
#include <dos.h>
#define r 15
#define c(c) setfillstyle(1,c)
main()
{
  int x,y;float j;double i;char k='d';
  char c;
  int gdriver=DETECT,gmode;
  initgraph(&gdriver,&gmode,"c:\\tc");
  x=320;
  y=240;
  setcolor(0);
  drawGlass();
  printf("press w,a,s,d to move");
  i=getch();
  i=0;
  printf("\n");
  while(k!='q')
  {
    while(bioskey(1)==0)
    {
      c(YELLOW);fillellipse(x,y,r,r);
      j=45*sin(i)*sin(i);
      c(0);
      switch(k)
      {
        case 'a': pieslice(x,y,180-j,180+j,r);break;
        case 'd': pieslice(x,y,0,0+j,r);pieslice(x,y,360-j,360,r);break;
        case 's': pieslice(x,y,270-j,270+j,r);break;
        case 'w': pieslice(x,y,90-j,90+j,r);break;
      }
      delay(10000);
      c(0);bar(x-r,y-r,x+r,y+r);
      i+=0.3;
    }
    k=bioskey(0);
    switch(k)
    {
      case 'a':x-=3;break;
      case 'd':x+=3;break;
      case 's':y+=3;break;
      case 'w':y-=3;break;
    }
  }
}

drawGlass()
{
  int i,rx,ry;
  for(i=1;i<=20000;i++)
  putpixel(rand()%640,rand()%480,2);
  for(i=1;i<=1000;i++)
  {
    rx=rand()%640;ry=rand()%480;
    putpixel(rx,ry,12);
    putpixel(rx+1,ry,12);
    putpixel(rx+1,ry+1,12);
  }
  for(i=1;i<=20000;i++)
    putpixel(rand()%640,rand()%480,10);
  return;
}

