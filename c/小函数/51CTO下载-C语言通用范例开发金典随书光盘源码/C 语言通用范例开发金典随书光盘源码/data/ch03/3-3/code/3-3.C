#include<graphics.h>
#include<conio.h>
void main()
{
   int driver,mode;
   driver=DETECT;
   mode=0;
   initgraph(&driver,&mode,"c:\\tc");
   outtext("Normal");
   settextstyle(GOTHIC_FONT,HORIZ_DIR,2);
   outtext("Gothic");
   settextstyle(TRIPLEX_FONT,HORIZ_DIR,2);
   outtext("Triplex");
   settextstyle(SANS_SERIF_FONT,HORIZ_DIR,7);
   outtext("Sans serif");
   getch();
   restorecrtmode();
}
