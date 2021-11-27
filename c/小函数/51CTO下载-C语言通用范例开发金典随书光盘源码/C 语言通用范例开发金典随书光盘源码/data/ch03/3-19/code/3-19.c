#include<graphics.h>
void main()
{
   int driver,mode;
   driver=DETECT;
   mode=0;
   initgraph(&driver,mode,"");
   setfillstyle(SOLID_FILL,4);
   pieslice(300,250,0,135,120);
   getch();
   cleardevice();
   sector(300,250,45,180,150,100);
   getch();
   restorecrtmode();
}
