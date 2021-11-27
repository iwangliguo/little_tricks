#include<graphics.h>
#include<conio.h>
#include<stdio.h>
#include<stdlib.h>
#include<alloc.h>
#define ESC  0x1b /*ESC的ASCII码，十六进制*/
void InstallGraph(void); /*图形程序加载函数的说明语句*/
void DrawGun(void); /*画发射架函数的说明语句*/
void DrawPlan(void); /*画火箭函数的说明语句*/
void DrawStar(void);/*画星星函数的说明语句*/
void *buf;/*全局变量，用于存储火箭的图像*/
/*以下是火箭的位置初始化参数*/
int x0=300;
int y0=340;
int width1=5;
int width2=20;
int height=25;
int y1=8;
int y2=15;
int y3=23;
int y4=38;
/*主函数开始*/
main()
{
  int size;
  int i=0;
  int key;
  int station;
  InstallGraph();
  setbkcolor(BLACK);
  cleardevice();/*图形驱动程序和屏幕初始化工作完成*/
  setcolor(BLUE);/*设置字的颜色*/
  outtextxy(80,100,"Ready!...Any key to SET OFF !!!");
  DrawGun();
  getch();
  cleardevice();
  DrawGun();/*画出发射架*/
  DrawPlan();
  DrawStar();
  setcolor(LIGHTRED);
  do
  {
/*程序主循环开始，用于运动飞机，方法是用异或的方式在屏幕上连续画出飞机 的图像，每画一次，新图像和来的位置相差两个像素点。
这个值是可调的，值越大，飞机飞行的速度越快*/
    putimage(x0-width2,y0-height-3*width1-i,buf,XOR_PUT);
    i+=2;
    putimage(x0-width2,y0-height-3*width1-i,buf,XOR_PUT);
    key=getch();
    if(y0-height-3*width1-i==0)
      outtextxy(60,100,"Successfully!!! Press ESC to quit");
    if(key==ESC)
    {
      if(y0-height-3*width1-i>0)
      {
        cleardevice();
        outtextxy(100,100,"Failue. What did you do?");
        outtextxy(130,300,"Press any key to quit.");
        getch();
      }
    }
  }
  while(key!=ESC);
  free(buf);
  closegraph();
  return 0;       
}

void InstallGraph(void) /*图形程序加载函数*/
{
  int grdriver=DETECT;
  int grmode;
  int errorcode;
  char *errormsg;
  initgraph(&grdriver,&grmode,"");
  errorcode=graphresult();
  errormsg=grapherrormsg(errorcode);
  if(errorcode!=grOk)
  {
    printf("Graphics error: %s\n",errormsg);
    printf("Press any key to exit.\n");
    getch();
    exit(1);
  }
}

void DrawStar(void)/*画星星函数*/
{
  int seed=2000;
  int i,dotx,doty,height,width,color,maxcolor;
  maxcolor=getmaxcolor();
  width=getmaxx();
  height=getmaxy();
  srand(seed);
  for(i=0;i<250;i++)
  {
    dotx=i+random(width-1);
    doty=i+random(height-1);
    color=random(maxcolor);
    setcolor(color);
    putpixel(dotx,doty,color);
    circle(dotx+1,doty+1,1);
  }
  srand(seed);
}

void DrawGun(void)/*画发射架函数*/
{
  int x0=300;
  int y0=430;
  int height=45;
  int rx=20;
  int ry=5;
  int rightx,righty,leftx,lefty;
  int centery1=30;
  rightx=righty=leftx=lefty=12;
  setcolor(LIGHTGREEN);
  ellipse(x0,y0,180,360,rx,ry);
  ellipse(x0,y0-height,0,360,rx,ry);
  line(x0+rx,y0,x0+rx,y0-height);
  line(x0-rx,y0,x0-rx,y0-height);
  moveto(x0+rx,y0);
  lineto(x0+rx+rightx,y0+righty);
  moveto(x0+rx+rightx,y0+righty);
  lineto(x0+rx+rightx+10,y0+righty+10);
  circle(x0+rx+rightx+10,y0+righty+10,4);
  moveto(x0,y0+ry);
  lineto(x0,y0+centery1);
  moveto(x0,y0+centery1);
  lineto(x0,y0+centery1+10);
  circle(x0,y0+centery1+10,4);
  moveto(x0-rx,y0);
  lineto(x0-rx-leftx,y0+lefty);
  moveto(x0-rx-leftx,y0+lefty);
  lineto(x0-rx-leftx-10,y0+lefty+10);
  circle(x0-rx-leftx-10,y0+lefty+10,4);
  line(x0-rx-leftx,y0+lefty,x0,y0+centery1);
  line(x0,y0+centery1,x0+rx+rightx,y0+righty);
}

void DrawPlan(void)/*画火箭函数*/
{
  int size;
  setcolor(LIGHTRED);
  setfillstyle(1,BLUE);
  ellipse(x0,y0-height,0,180,width1,3*width1);
  moveto(x0+width1,y0);
  lineto(x0+width1,y0-height);
  moveto(x0+width1,y0);
  lineto(x0+width2,y0+y2);
  moveto(x0-width1,y0);
  lineto(x0-width1,y0-height);
  moveto(x0-width1,y0);
  lineto(x0-width2,y0+y2);
  moveto(x0+width2,y0+y3);
  lineto(x0+width2,y0+y1);
  moveto(x0+width2,y0+y3);
  lineto(x0+width1,y0+y2);
  moveto(x0-width2,y0+y3);
  lineto(x0-width2,y0+y1);
  moveto(x0-width2,y0+y3);
  lineto(x0-width1,y0+y2);
  moveto(x0,y0+y4);
  lineto(x0+width1,y0+y2);
  moveto(x0,y0+y4);
  lineto(x0-width1,y0+y2);
  setfillstyle(2,LIGHTRED);
  floodfill(x0,y0,LIGHTRED);
  size=imagesize(x0-width2-1,y0-height-3*width1,x0+width2+1,y0+y4);
  buf=malloc(size);
  if(!buf)
  {
    printf("No enough memory!");
    exit(0);
  }
  getimage(x0-width2,y0-height-3*width1,x0+width2,y0+y4,buf);
}