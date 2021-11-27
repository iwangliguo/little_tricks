#include <graphics.h>
void main()
{
	int gdriver=DETECT,gmode;
	initgraph(&gdriver,&gmode,"c:\\tc");
	cleardevice();
	printf("\n\n\n   To draw a arc.\n");
	arc(300,250,100,240,120);
	getch();
	closegraph();
}
