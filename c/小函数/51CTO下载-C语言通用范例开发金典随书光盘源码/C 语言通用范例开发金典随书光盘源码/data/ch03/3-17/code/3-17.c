#include <graphics.h>
void main()
{
  int gdriver=DETECT,gmode;
  initgraph(&gdriver,&gmode,"c:\\tc");
  cleardevice();
  printf("\n\n\n   To draw a ellipse.\n");
  ellipse(300,250,0,360,150,100);
  getch();
  cleardevice();
  printf("\n\n\n   To draw a fill ellipse.\n");
  fillellipse(300,250,150,100);
  getch();
  closegraph();
} 
