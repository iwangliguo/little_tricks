#include<graphics.h>
void main()
{
   int driver,mode;
   driver=DETECT;
   mode=0;
   initgraph(&driver,&mode,"c:\\tc");/*��ʼ��ͼ��ϵͳ*/
   outtext(" say hello by fuction outtext!");
   outtextxy(200,150," say hello by fuction outtextxy!");/*����Ļ����(200,150)������ַ���*/
   getch();
   restorecrtmode();/*�ָ��ı���ʾģʽ*/
}
