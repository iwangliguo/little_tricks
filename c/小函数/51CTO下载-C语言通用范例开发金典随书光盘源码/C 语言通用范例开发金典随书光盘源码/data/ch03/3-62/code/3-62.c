#define N 20
#include "stdlib.h"
#include <graphics.h>
int i,j;
Funscore(int *score,int *bilv)/*输入N个学生的成绩,这里采用随机赋值*/
{
  randomize();
  for(i=0;i<N;i++)
  score[i]=random(101);/*随机赋值*/
  for(i=0;i<N;i++)
  {
    if(score[i]==100)
      bilv[9]++;
    else
    {
      j=(score[i]/10);
      bilv[j-1]++;
    }/*这个是计算比率的数组*/
  }
  gotoxy(1,1);
  for(i=0;i<N;i++)/*输出数据演示用*/
  printf("%4d",score[i]);
}

Drowxy()/*画坐标轴函数*/
{
  line(50,400,460,400);/*x轴*/
  line(460,400,455,405);
  line(460,400,455,395);
  line(50,400,50,90);/*y轴*/
  line(50,90,45,95);
  line(50,90,55,95);
  for(i=373;i>=100;i-=30)/*x轴具体画图*/
    line(48,i,52,i);
  outtextxy(35,400,"0");
  outtextxy(30,370,"10");
  outtextxy(30,340,"20");
  outtextxy(30,310,"30");
  outtextxy(30,280,"40");
  outtextxy(30,250,"50");
  outtextxy(30,220,"60");
  outtextxy(30,190,"70");
  outtextxy(30,160,"80");
  outtextxy(30,130,"90");
  outtextxy(23,100,"100");
  for(i=90;i<450;i+=40)/*y轴具体画图*/
  line(i,402,i,398);
  outtextxy(60,410,"10");
  outtextxy(100,410,"20");
  outtextxy(140,410,"30");
  outtextxy(180,410,"40");
  outtextxy(220,410,"50");
  outtextxy(260,410,"60");
  outtextxy(300,410,"70");
  outtextxy(340,410,"80");
  outtextxy(380,410,"90");
  outtextxy(420,410,"100");
  outtextxy(470,400,"score");/*坐标内容声明*/
  outtextxy(25,80,"(%)");
}

Fundrow(int *bilv)/*画柱状图形*/
{
  for(i=60,j=0;i<450;i+=40,j++)
  {
    setfillstyle(SOLID_FILL,j+2);
    bar(i,399-300*bilv[j]/N,i+20,399);
  }
}

main()
{
  int gd=DETECT,gr;
  int score[N],bilv[10]={0};
  initgraph(&gd,&gr,"c:\\tc");
  Funscore(score,bilv);/*输入数据*/
  Drowxy();/*画坐标*/
  Fundrow(bilv);/*具体画柱状图形*/
  getch();
  closegraph();
}