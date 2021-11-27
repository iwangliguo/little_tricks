#include <graphics.h>
void main()
{
  int i,j;
  int gdriver=DETECT,gmode;
  initgraph(&gdriver,&gmode,"c:\\tc");
  cleardevice();
  printf("\n\n\n To use the putpixel function.\n");
  for(i=300;i<350;i++)
  {
    for(j=200;j<250;j++)
    {
      putpixel(i,j,RED);
    }
  }
  getch();
  closegraph();
} 
