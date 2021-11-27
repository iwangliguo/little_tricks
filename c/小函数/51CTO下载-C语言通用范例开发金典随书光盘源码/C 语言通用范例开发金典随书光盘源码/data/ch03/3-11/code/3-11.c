#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <graphics.h>
#include <math.h>
#include <conio.h>
#include <dos.h>
void main(void)
{
  int mode, maxcolor,maxx, maxy, ballsize;
  void *ball;
  int i, j;
  int gdriver = VGA;
  int gmode = 2;
  char msg[80];
  initgraph(&gdriver, &gmode, "c:\\tc");
  mode = getgraphmode();
  printf(" %d is the current mode number.\n", mode);
  printf("%15s is the current graphics mode\n", getmodename(mode));
  maxx=getmaxx();
  printf("X max = %d\n", maxx);
  maxy=getmaxy();
  printf("Y max = %d\n", maxy);
  maxcolor=getmaxcolor();
  printf("This mode supports colors %d\n", maxcolor);
  printf("This driver supports modes 0..%d\n", getmaxmode());
  printf("Press any key to continue");
  getch();
  cleardevice();
  j=0;
  for (i=0; i<=maxcolor; i++)
  {
    setfillstyle(SOLID_FILL,i);
    j=j+8;
    if (i==0)
      setcolor(15);
    else
      setcolor(i);
    sprintf(msg, "<---- Color number %d", i);
    bar (0,j,20,j+8);
    outtextxy(30,j, msg);
  }
  printf("\n\nPress any key to continue");
  getch();
  cleardevice();
  ballsize = imagesize(0,0,10,10);
  if ((ball = malloc(ballsize)) == NULL)
  {
    closegraph();
    printf("Error: not enough heap space. Aborting\n");
    exit(1);
  }
  i=0;
  for (i=1; i<=maxcolor; i++)
  {
    cleardevice();
    setcolor(15);
    circle(5,5,5);
    setfillstyle(SOLID_FILL,i);
    floodfill(5,5,15);
    getimage(0,0,10,10, ball);
    cleardevice();
    for (j=0;j<=(maxx-10);j=j+2)
    {
      putimage(j, 50, ball, XOR_PUT);
      delay(2);
      putimage(j, 50, ball, XOR_PUT);
    }
  }
  cleardevice();
  printf("\nThe graphics demo is done. Press any key to quit completely.");
  getch();
  closegraph();
  return ;
}