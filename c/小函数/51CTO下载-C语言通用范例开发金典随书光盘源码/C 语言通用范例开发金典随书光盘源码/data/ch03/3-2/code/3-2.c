#include<graphics.h>
void main()
{
   int driver,mode;
   driver=DETECT;
   mode=0;
   initgraph(&driver,&mode,"c:\\tc");/*初始化图形系统*/
   outtext(" say hello by fuction outtext!");
   outtextxy(200,150," say hello by fuction outtextxy!");/*在屏幕坐标(200,150)处输出字符串*/
   getch();
   restorecrtmode();/*恢复文本显示模式*/
}
