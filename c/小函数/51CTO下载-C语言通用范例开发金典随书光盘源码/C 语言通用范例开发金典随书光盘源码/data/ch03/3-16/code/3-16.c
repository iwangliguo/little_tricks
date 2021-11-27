#include <graphics.h>
void main()
{
	int b;
	int gdriver=DETECT,gmode;
	initgraph(&gdriver,&gmode,"c:\\tc");
	cleardevice();
	printf("\n\n\n To draw a circle.\n");
	circle(300,250,120);
	getch();
	closegraph();
}
