#include <conio.h>
void border(int startx,int starty,int endx,int endy)
{
   register int i;
   gotoxy(1,1);
   for(i=0;i<=endx-startx;i++)
      putch('-');
   gotoxy(1,endy-starty);
   for(i=0;i<=endx-startx;i++)
      putch('-');
   for(i=2;i<=endy-starty;i++){
      gotoxy(1,i);
      putch('|');
      gotoxy(endx-startx+1,i);
      putch('|');
   }
}

main()
{
   void border(int,int,int,int);
   clrscr();
   window(6,8,38,12);
   border(6,8,38,12);
   gotoxy(2,2);
   printf("window 1");
   window(8,16,40,24);
   border(8,16,40,24);
   gotoxy(3,2);
   printf("window 2");
   getch();
}
