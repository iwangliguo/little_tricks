#include<graphics.h>
void main()
{
   int driver,mode;
   static int polypoints1[18]={100,100,110,120,100,130,120,125,140,140,130,120,
   140,110,120,115,100,100};
   static int polypoints2[18]={180,100,210,120,200,130,220,125,240,140,230,120,
   240,110,220,115,220,110};
   driver=DETECT;
   mode=0;
   initgraph(&driver,&mode,"");
   drawpoly(9,polypoints1);
   drawpoly(9,polypoints2);
   getch();
   restorecrtmode();
}