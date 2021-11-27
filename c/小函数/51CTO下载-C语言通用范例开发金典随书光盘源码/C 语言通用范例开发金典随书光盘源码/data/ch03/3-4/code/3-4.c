#include <graphics.h>
#include <conio.h>

int main() {
   int gdriver = EGA;
   int gmodo = EGAHI;
   initgraph( &gdriver, &gmodo, "C:\\TC" );

   settextjustify( RIGHT_TEXT, BOTTOM_TEXT );
   moveto(300, 200);
   outtext( "(RIGHT_TEXT, BOTTOM_TEXT)" );

   settextjustify( RIGHT_TEXT, TOP_TEXT );
   moveto(300, 200);
   outtext( "(RIGHT_TEXT, TOP_TEXT)" );

   settextjustify( LEFT_TEXT, BOTTOM_TEXT );
   moveto(300, 200);
   outtext( "(LEFT_TEXT, BOTTOM_TEXT)" );

   settextjustify( LEFT_TEXT, TOP_TEXT );
   moveto(300, 200);
   outtext( "(LEFT_TEXT, TOP_TEXT)" );

   setcolor( 1 );
   line( 300, 200, 300, 100 );

   setcolor( 2 );
   line( 300, 200, 300, 300 );

   setcolor( 3 );
   line( 300, 200, 100, 200 );

   setcolor( 4 );
   line( 300, 200, 500, 200 );

   getch();
   closegraph();

   return 0;
}
