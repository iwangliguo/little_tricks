#include <graphics.h>
#include <math.h>
#define PI 3.1415926
void circles(int x0,int y0, int R1, int Rs)
{
  int x,y;
  double a;
  for(a=0;a<=2*PI;a+=PI/18)
  {	
    x=x0+R1*cos(a);
    y=y0+R1*sin(a);
    circle(x,y,Rs);	
  }
  return;
}

void main()
{	
  double a;	
  int x,y,r1,rs;	
  int gdriver=9,gmode=2;
  initgraph(&gdriver,&gmode,"c:\\tc");
  cleardevice();
  setcolor(WHITE);
  outtextxy(80,20,"This program show the Circles picture.");
  setcolor(RED);
  outtextxy(80,60,"R1<RS");
  r1=50;rs=70;
  circles(120,200,r1,rs);
  setcolor(GREEN);
  outtextxy(200,60,"R1=RS");
  r1=50;rs=50;
  circles(300,200,r1,rs);
  setcolor(BLUE);
  outtextxy(300,60,"R1>RS");
  r1=50;rs=35;
  circles(420,200,r1,rs);
  outtextxy(80,460,"Press any key to quit...");
  getch();
  closegraph();
}
