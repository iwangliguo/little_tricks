#include <conio.h>
void main(void)
{
  int color;
  for(color=0;color<8;color++)
  {
    textcolor(10);
    textbackground(color);
    cprintf("this is color %d\r\n.",color);
    cprintf("press any key to continue.\r\n",color);
    getch();
  }
}