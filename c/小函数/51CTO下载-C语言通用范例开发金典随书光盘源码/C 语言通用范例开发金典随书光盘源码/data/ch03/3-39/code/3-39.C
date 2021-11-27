#include<graphics.h>
#include<math.h>

#define FNX(x1) (int)(x+(x1)*sl)
#define FNY(y1) (int)(MAXY-(y+(y1)*sl))
#define R(theta) 1-pow(cos(1*theta),1)

int sl=50,MAXY;
float x1,y1,xs,ys,r,theta;
/*画心*/
void draw(int x,int y)
{
  for(theta=0;theta<2*3.14;theta+=0.01)
  {
    r=R(theta);
    x1=r*sin(theta);y1=r*cos(theta);
    xs=FNX(x1);ys=FNY(y1);
    if(theta==0)
      moveto(xs,ys);
    else 
      lineto(xs,ys);
  }
}

/*画箭头*/
void arrow()
{
  line(205,235,200,240);
  line(200,240,205,245);
  line(200,240,214,240);
  line(400,240,500,240);
  line(485,235,480,240);
  line(480,240,485,245);
  line(490,235,485,240);
  line(485,240,490,245);
  line(495,235,490,240);
  line(490,240,495,245);
  line(500,235,495,240);
  line(495,240,500,245);
  line(505,235,500,240);
  line(500,240,505,245);
  line(485,235,505,235);
  line(485,245,505,245);
}
/*主程序*/
main()
{
  int driver=DETECT,mode;
  initgraph(&driver,&mode,"c:\\tc");
  setbkcolor(1);
  setcolor(4);
  MAXY=getmaxy();
  draw(280,280);/*左心*/
  draw(370,280);/*右心*/
  arrow();
  getch();
  closegraph();
}

