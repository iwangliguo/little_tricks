# include "graphics.h"
# include "stdlib.h"
# include "conio.h"
main()
{ 
  int gdriver=VGA;
  int gmode=VGAHI;
  initgraph (&gdriver,&gmode,"c:\\tc");
  printf("press any key to stop.");
  while(!kbhit())/*当按下键盘的任意键，循环终止*/
  putpixel(rand()%640,rand()%440+40,rand()%15+1);/*利用随机函数产生X坐标在0~640范围，Y坐标在40~480范围，颜色在1~15范围的点，然后利用画点函数来画这些点*/
  getch();
  getch();
  closegraph();
}