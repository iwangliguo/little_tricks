#include <stdio.h>
#include <math.h>
#include <graphics.h>
#include <stdlib.h>
#define Pi 3.1415926535

static void KochFractal(double size,int order);
static void DrawFractalLine(double len,double theta,int order);
static void DrawPolarLine(double r,double theta);
static void InitGraphics();
int oldx=0,oldy=0;
void main()
{
  double size=300.0;
  int order=3;
  int gdriver=DETECT,gmode=0;
  initgraph(&gdriver,&gmode,"");
  setcolor(RED);
  setviewport(319-size/2,239+size*sin(Pi/3)/3,639,479,0);
  KochFractal(size,order);
  getch();
  closegraph();
}

static void KochFractal(double size,int order)
{
  DrawFractalLine(size,0,order);
  DrawFractalLine(size,120,order);
  DrawFractalLine(size,240,order);
}

static void DrawPolarLine(double r,double theta)
{
  double radians;
  radians=(double)((double)theta*Pi)/180; 
  lineto((int)(r*cos(radians))+oldx,oldy-(int)(r*sin(radians)));   
  oldx+=(int)(r*cos(radians));
  oldy+= -(int)(r*sin(radians));
}

static void DrawFractalLine(double len,double theta,int order)
{
  if(order==0)
  {       
    DrawPolarLine(len,theta);
  }else
  {
    DrawFractalLine(len/3,theta,order-1);
    DrawFractalLine(len/3,theta-60,order-1);
    DrawFractalLine(len/3,theta+60,order-1);
    DrawFractalLine(len/3,theta,order-1);
  }
}
