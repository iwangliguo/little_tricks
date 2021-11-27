#include <graphics.h>
#include <conio.h>
#include <stdio.h>
int main() {
   int gdriver = EGA;
   int gmodo = EGAHI;
   int trama, color;
   int puntos[6] = { 300, 50, 500, 300, 100, 300 };
   initgraph( &gdriver, &gmodo, "C:\\tc" );
   trama = SLASH_FILL;
   color = 4;
   setfillstyle( trama, color );
   fillpoly( 3, puntos );
   getch();
   closegraph();
   return 0;
}
