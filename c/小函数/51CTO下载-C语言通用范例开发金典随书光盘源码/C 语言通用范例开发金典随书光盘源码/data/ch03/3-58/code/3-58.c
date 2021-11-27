#include <graphics.h>
#include <stdio.h>
#include <stdlib.h>
#include <bios.h>

#define MenuNum 3
#define FALSE 0
#define TRUE 1
#define START 1
#define LEFTSHIFT 2
#define RIGHTSHIFT 3
#define ENTER 4
#define EXIT 5
#define UP 6
#define DOWN 7

typedef struct{              /*菜单的数据结构*/
  int menuID;
  char MenuName[8];
  int itemCount;
  char itemName[4][8];
}menu;

void *saveImage;       /*保存菜单覆盖的区域*/

int mHeight,mWidth;          /*窗口高,宽*/
int mutex=0;

menu MainMenu[]={{0,"Menu0",4,{"Open","New","Save","Exit"}},
         {1,"Menu1",2,{"Copy","Paste"}},
         {2,"Menu2",2,{"Find","Instead"}}};


void showItems(int NewID)                 /*显示*/
{
  int LL,TT,j;
  LL=mWidth*NewID+50;
  TT=70;
  saveImage=malloc(imagesize(LL,70,LL+mWidth,70+25*(MainMenu[NewID].itemCount)));
  getimage(LL,70,LL+mWidth,70+25*(MainMenu[NewID].itemCount),saveImage);
  setfillstyle(SOLID_FILL,3);
  settextstyle(1,HORIZ_DIR,1);
  bar(LL,70,LL+mWidth-80,70+25*(MainMenu[NewID].itemCount));
  setcolor(RED);
  rectangle(LL+5,70,LL+mWidth-85,65+25*(MainMenu[NewID].itemCount));
  outtextxy(LL+15,TT,(MainMenu[NewID].itemName[0]));
  setcolor(BLACK);
  outtextxy(LL+12,50,(MainMenu[NewID].MenuName));
  for(j=1;j<(MainMenu[NewID].itemCount);j=j+1)
  {
    TT=TT+25;
    outtextxy(LL+15,TT,MainMenu[NewID].itemName[j]);
  }
}


void init()
{
  int gdriver,gmode;
  gdriver=DETECT;
  initgraph(&gdriver,&gmode,"c:\\tc");
}


initm()
{
  int L,T,R,B,i;
  mWidth=550/MenuNum;
  mHeight=20;
  L=50;  
  T=50;  
  R=mWidth+L+5;  
  B=mHeight+T;
  setfillstyle(SOLID_FILL,7);
  bar(50,50,600,400);
  setfillstyle(SOLID_FILL,3);
  bar(50,50,600,70);
  setcolor(RED);
  settextstyle(1,HORIZ_DIR,1);
  outtextxy(L+12,T,MainMenu[0].MenuName);
  L=R;  
  R=mWidth+L;
  for(i=1;i<MenuNum;i++)
  {
    setcolor(BLACK);
    settextstyle(1,HORIZ_DIR,1);
    outtextxy(L+7,T,MainMenu[i].MenuName);
    L=R;  
    R=R+mWidth;
  }
}

void process(int OldID,int NewID)       /*主菜单移动*/
{
  int L,T;
  L=50+mWidth*OldID;
  T=50;
  settextstyle(1,HORIZ_DIR,1);
  setcolor(BLACK);
  outtextxy(L+12,T,MainMenu[OldID].MenuName);
  L=50+mWidth*NewID;
  setcolor(RED);
  outtextxy(L+12,T,MainMenu[NewID].MenuName);
}

void process3(int OldID,int NewID,int m)       /*子菜单移动*/
{
  int L,T;
  L=50+mWidth*m;
  T=70+OldID*25;
  settextstyle(1,HORIZ_DIR,1);
  setcolor(BLACK);
  outtextxy(L+15,T,MainMenu[m].itemName[OldID]);
  T=70+NewID*25;
  setcolor(RED);
  outtextxy(L+15,T,MainMenu[m].itemName[NewID]);
}
process1(int d)             /* 退出 */
{
  if(d==2) exit(1);
}

main()
{
  int OldID,NewID,head,tail,selectID,quit,c;
  int OldID1,NewID1,head1,tail1;
  head=0;  tail=2;
  OldID=0;  NewID=0;
  OldID1=0;  NewID1=0;
  head1=0;
  quit=0;
  init();
  initm();
  while(!quit)
  {
    while(bioskey(1)==0);
    c=bioskey(0);
    if(c==17400) selectID=START;
    else if(c==19200) selectID=LEFTSHIFT;
    else if(c==19712) selectID=RIGHTSHIFT;
    else if(c==7181) selectID=ENTER;
    else if(c==283) selectID=EXIT;
    else if(c==20480) selectID=DOWN;
    else if(c==18432) selectID=UP;
    else selectID=NULL;
    switch (selectID)
    {
      case START:
           OldID=NewID;
           NewID=0;
           process(OldID,NewID);
           break;
      case LEFTSHIFT:
           if(mutex==0)
           {
             if(NewID==head)
             {
               OldID=NewID;
               NewID=tail;
             }
             else
             {
               OldID=NewID;
               NewID--;
             }
             process(OldID,NewID);
           }
           break;
       case RIGHTSHIFT:
           if(mutex==0)
           {
           if(NewID==tail)
           {
          OldID=NewID;
          NewID=head;
           }
           else
           {
           OldID=NewID;
           NewID++;
           }
           process(OldID,NewID);
           }
           break;
        case ENTER:
           if(mutex==0)
           {
           showItems(NewID);
           mutex=1;
           tail1=MainMenu[NewID].itemCount-1;
           }
           else
           process1(NewID);
           break;
        case EXIT:
           if(mutex!=0)
           {
           putimage(mWidth*NewID+50,70,saveImage,0);
           setcolor(RED);
           outtextxy(mWidth*NewID+62,50,(MainMenu[NewID].MenuName));
           mutex=0;
           }
           else
           quit=TRUE;
           break;
        case DOWN:
           if(mutex==1)
           {
         if(NewID1==tail1)
      {
             OldID1=NewID1;
             NewID1=head1;
      }
         else
      {
             OldID1=NewID1;
             NewID1++;
      }
         process3(OldID1,NewID1,NewID);
     }
        break;
        case UP:
          if(mutex!=0)
          {
           if(NewID1==head1)
           {
          OldID1=NewID1;
          NewID1=tail1;
           }
           else
           {
           OldID1=NewID1;
           NewID1--;
           }
           process3(OldID1,NewID1,NewID);
          }
           break;

        default: break;
      }
       }
    getch();
    closegraph();
}
