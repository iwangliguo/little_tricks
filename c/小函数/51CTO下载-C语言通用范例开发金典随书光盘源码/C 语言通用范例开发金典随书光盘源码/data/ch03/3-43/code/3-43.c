#include <conio.h>
#include <stdio.h>
#include <math.h>
#include <graphics.h>
#include<dos.h>
#include<stdlib.h>

void fractal(int x,int y,int k)
{ 
  rectangle(x-k/2,y-k/2,x+k/2,y+k/2);
  line(x-k/2,y-k/6,x+k/2,y-k/6);
  line(x-k/2,y+k/6,x+k/2,y+k/6);
  line(x-k/6,y-k/2,x-k/6,y+k/2);
  line(x+k/6,y-k/2,x+k/6,y+k/2);
  floodfill(x,y,WHITE);
  if (k>5)
  {
    fractal(x-3*k/4,y,k/2);
    fractal(x+3*k/4,y,k/2);
    fractal(x,y-3*k/4,k/2);
    fractal(x,y+3*k/4,k/2);}
  }

void main()
{
  int cul,gd,gm;
  gd=DETECT;
  randomize();
  initgraph(&gd,&gm,"c:\\tc");
  fractal(300,250,150);
  getch();
  closegraph();
}

