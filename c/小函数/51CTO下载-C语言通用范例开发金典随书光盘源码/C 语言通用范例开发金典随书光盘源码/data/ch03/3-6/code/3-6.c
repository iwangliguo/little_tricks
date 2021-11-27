#include <conio.h>
int main(void)
{
   clrscr();
   normvideo();
   cprintf("say hello with normal video.");
   highvideo();
   gotoxy(1,2);
   cprintf("say hello with high video.");
   lowvideo();
   gotoxy(1,3);
   cprintf("say hello with low video.");
   getch();
   return 0;
} 