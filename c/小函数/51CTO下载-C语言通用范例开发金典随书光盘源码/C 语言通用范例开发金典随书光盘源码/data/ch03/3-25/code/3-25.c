# include "graphics.h"
# include "stdlib.h"
# include "conio.h"
main()
{ 
  int gdriver=VGA;
  int gmode=VGAHI;
  initgraph (&gdriver,&gmode,"c:\\tc");
  printf("press any key to stop.");
  while(!kbhit())/*�����¼��̵��������ѭ����ֹ*/
  putpixel(rand()%640,rand()%440+40,rand()%15+1);/*���������������X������0~640��Χ��Y������40~480��Χ����ɫ��1~15��Χ�ĵ㣬Ȼ�����û��㺯��������Щ��*/
  getch();
  getch();
  closegraph();
}