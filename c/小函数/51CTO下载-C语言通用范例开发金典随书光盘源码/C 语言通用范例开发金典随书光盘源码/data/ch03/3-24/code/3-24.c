#include <graphics.h>
#include <conio.h>
int main() 
{
   int gdriver = EGA;
   int gmodo = EGAHI;
   char trama1[8] = { 0x33, 0xEE, 0x33, 0xEE, 0x33, 0xEE, 0x33, 0xEE };
   char trama2[8] = { 0x0A, 0xF0, 0xF0, 0x0A, 0x0A, 0xF0, 0xF0, 0x0A };
   initgraph( &gdriver, &gmodo, "C:\\TC" );
   bar( 50, 50, 150, 150 );
   setfillpattern( trama1, 9 );
   bar( 160, 50, 260, 150 );
   setfillpattern( trama2, 4 );
   bar( 105, 160, 205, 260 );
   getch();
   closegraph();
   return 0;
}
