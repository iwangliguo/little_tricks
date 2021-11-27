#include<stdio.h>
#include<math.h>
#include<graphics.h>
#define PI 3.14
int main()
{
    float i ,j ,x ,y;
    int MAXX2 ,MAXY2;
    int gd = DETECT,gm = 0;
    initgraph(&gd,&gm,"c:\\tc");
    MAXX2 = getmaxx()/2;
    MAXY2 = getmaxy()/2;
    for(i = -6*PI;i < 6*PI;i +=0.02)
      for(j = -3*PI;j < 3*PI;j += 0.02)
      {
        y = sin(i-j*2)*i*3+j*5;
        x = cos(i*2+y)*j+2*y;
        putpixel(y*i/5+MAXX2 ,MAXY2*1.5-x*j/5 ,((int)abs(i+j)*4)%15+1);
        if(kbhit())
          exit(0);
      }
    getch();
} 
