#include <conio.h>
void main()
{
   register int i;
   gotoxy(6,8);
   printf("This is a test of the clreol function.");
   getch();
   gotoxy(6,8);
   clreol();
   getch();
   clrscr();
}
