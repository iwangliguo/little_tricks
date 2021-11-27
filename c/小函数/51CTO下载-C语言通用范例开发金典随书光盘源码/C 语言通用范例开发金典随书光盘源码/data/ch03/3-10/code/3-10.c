#include "conio.h"
void main()
{
   gotoxy(1,4);
   printf("the one line");
   gotoxy(1,5);
   printf("the two line");
   getch();
   gotoxy(1,5);
   insline();
   getch();
   gotoxy(1,4);
   delline();
   getch();
}
