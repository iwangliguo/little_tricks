#include <graphics.h>
void main()
{
	int gdriver=DETECT,gmode;
	initgraph(&gdriver,&gmode,"c:\\tc");
	cleardevice();
	printf("\n\n\n   To draw a rectangle.\n");
	rectangle( 30, 80, 500, 400 );
	getch();
	closegraph();
}
