#include <graphics.h>
void main()
{
  int i,j;
  int gdriver=DETECT,gmode;
  initgraph(&gdriver,&gmode,"c:\\tc");
  cleardevice();
  setbkcolor(9);
  for(i=0;i<4;i++)
  {
    setcolor(i+1);
    setlinestyle(i,0,1);
    circle(100+i*150,150,60);
    line(50,50+i*50+200,200,200+i*50+200);
  }
  for(j=0;j<4;j++)
  {
    setcolor(j+5);
    setlinestyle(j,0,3);
    circle(100+j*150,300,60);
    line(100,50+j*50,300,200+j*50);
  }
  getch();
  closegraph();
}
