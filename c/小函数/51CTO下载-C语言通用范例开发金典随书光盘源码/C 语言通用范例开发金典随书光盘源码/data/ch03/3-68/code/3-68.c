#include<graphics.h>
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
void mysector(int x,int y,int startangle,int endangle,int rx,int ry);

main()
{
  int graphdriver=VGA,  graphmode=VGAHI  ;
  int x0=320,y0=240;
  int degree=0;
  int size=0;
  void *buffer=NULL;
  int xt=0,yt=0;
  struct palettetype palette;
  initgraph(&graphdriver,&graphmode,"c:\\tc");
  cleardevice();
  size=imagesize(160,80,320,320);
  buffer=malloc(size);
  getimage(160,80,320,320,buffer);
  getpalette(&palette);

  while(!kbhit())
  {
  putimage(160,80,buffer,COPY_PUT);
  setcolor(15);
  circle(x0,y0,160);
  degree=(degree+10)%360;
  xt=(int)80* sin( (degree+90)*(2*M_PI)/360  ) ;
  yt=(int)80* cos( (degree+90)*(2*M_PI)/360  ) ;

  setfillstyle(1,15);
  mysector(x0,y0,  0+degree,180+degree,160,160);
  setfillstyle(1,0);
  mysector(x0,y0,180+degree,360+degree,160,160);

  setcolor(0);
  setfillstyle(1,0);
  mysector(x0+xt,y0+yt, 0+degree,180+degree,80,80); /*ÓÒ°ëÔ² */

  setcolor(15);
  setfillstyle(1,15);
  mysector(x0-xt,y0-yt,180+degree,360+degree,80,80); /*×ó°ëÔ²*/

  setcolor(15);
  setfillstyle(1,15);
  mysector(x0+xt,y0+yt,0,360,30,30); /*ÓÒ±ßÐ¡Ô²*/

  setcolor(0);
  setfillstyle(1,0);
  mysector(x0-xt,y0-yt,0,360,30,30); /*×ó±ßÐ¡Ô²*/
  getimage(160,80,320,320,buffer);
}
  getch();
  closegraph();
}

void mysector(int x,int y,int startangle,int endangle,int rx,int ry)
{
  if(startangle<360 && endangle>360)
  {
   sector(x, y,startangle,  360,rx,ry);
   sector(x, y, 0, endangle-360,rx,ry);
   }
  else if(startangle==360)
    sector(x, y,0,endangle-360,rx,ry);
  else if(startangle>360 && endangle>360)
    sector(x,y,startangle-360,endangle-360,rx,ry);
  else 
    sector(x,y,startangle,endangle,rx,ry);
}

