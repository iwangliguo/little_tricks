#include <dos.h> 
#include <graphics.h> 
#include <math.h> 
/*Ãµ¹å»¨*/ 
#define FNX(x) (int)(xo+(x)*1.0) 
#define FNY(y) (int)(getmaxy()-(yo+(y)*1.0)) 
#define FNX2(phi) cos(phi)*ac-sin(phi)*bs 
#define FNY2(phi) cos(phi)*as+sin(phi)*bc 

/*»­Ðý×ªµÄÍÖÔ²*/ 
void elli(int xo,int yo,int a,int b,double theta) 
{ 
  int i; 
  double da,c,s,ac,as,bc,bs,xf,yf,phi,x,y; 
  theta=theta*0.01745; 
  da=3*0.1745; 
  c=cos(theta);s=sin(theta); 
  ac=a*c;as=a*s;bc=b*c;bs=b*s; 
  x=FNX2(0);y=FNY2(0); 
  moveto(FNX(x),FNY(y)); 
  for(i=1;i<=360;i++) 
  { 
    phi=i*da;xf=x*cos(phi)*0.1;yf=b*sin(phi)*0.1; 
    x=FNX2(phi);y=FNY2(phi); 
    lineto(FNX(x),FNY(y)); 
  } 
} 

void draw(int x,int y) 
{ 
  register i; 
/*»­·ÛºìÉ«Ãµ¹å*/ 
  setcolor(12); 
  arc(x+65,y-60,150,350,8); 
  arc(x+66,y-54,300,470,8); 
  arc(x+65,y-56,30,230,10); 
  arc(x+64,y-57,300,490,17); 
  ellipse(x+73,y-30,250,450,27,40); 
  ellipse(x+59,y-30,100,290,27,40); 
  ellipse(x+65,y-40,140,270,20,30); 
  setfillstyle(SOLID_FILL,5); 
  floodfill(x+65,y-20,12); 
/*»­ºìÉ«Ãµ¹å*/ 
  arc(x,y,150,350,12); 
  arc(x+1,y+8,280,470,12); 
  arc(x,y+2,30,230,16); 
  arc(x,y+3,80,240,28); 
  arc(x+2,y+8,180,330,22); 
  arc(x-2,y+2,310,460,25); 
  ellipse(x-12,y+30,120,300,30,40); 
  ellipse(x+10,y+28,250,423,30,42); 
  ellipse(x-4,y+10,290,393,30,40); 
  setfillstyle(SOLID_FILL,4); 
  floodfill(x+5,y+31,12); 
/*»­×ÏÉ«»¨¹Ç¶ä*/ 
  ellipse(x+120,y+5,0,360,15,25); 
  setfillstyle(SOLID_FILL,1); 
  floodfill(x+120,y,12); 
/*»­»ÆÉ«»¨¹Ç¶ä*/ 
  ellipse(x-70,y+10,0,360,14,20); 
  setfillstyle(SOLID_FILL,14); 
  floodfill(x-70,y+10,12); 
  setcolor(10); 
/*»­ºì»¨»¨Ýà*/ 
  ellipse(x-15,y+32,190,310,30,35); 
  ellipse(x+16,y+32,235,355,26,35); 
  ellipse(x,y+35,190,350,43,50); 
  arc(x,y+82,190,350,6); 
  setfillstyle(SOLID_FILL,2); 
  floodfill(x,y+75,10); 
/*»­·Û»¨»¨Ýà*/ 
  ellipse(x+50,y-48,190,320,22,50); 
  ellipse(x+80,y-48,220,350,22,50); 
  ellipse(x+65,y-28,180,360,36,50); 
  floodfill(x+65,y+18,10); 
/*»­Ö÷Ö¦*/ 
  for(i=0;i<3;i++ ) 
  { 
    ellipse(x-98,y+100+i,255,371,100,80); 
    ellipse(x-20,y+30+i,260,358,140,140); 
    ellipse(x+224,y+20+i,180,218,160,140); 
  } 
/*»­²àÖ¦*/ 
  ellipse(x+70,y+34,180,233,140,140); 
  ellipse(x,y+40,205,255,100,120); 
  ellipse(x+135,y-30,209,249,72,120); 
  ellipse(x,y+20,263,301,100,120); 
  ellipse(x+85,y-10,278,305,100,120); 
  ellipse(x+100,y-62,282,308,90,120); 
  ellipse(x-50,y-10,277,314,30,120); 
  ellipse(x+70,y+80,222,266,52,120); 
  ellipse(x-60,y-45,229,266,52,120); 
  ellipse(x+79,y-45,229,266,52,120); 
  ellipse(x+84,y,224,273,52,120); 
  ellipse(x+110,y+40,240,282,100,120); 
/*»­×Ï»¨¹Ç¶ä»¨Ýà*/ 
  ellipse(x+120,y-6,200,340,17,25); 
  ellipse(x+120,y+7,160,380,17,27); 
  floodfill(x+122,y+30,10); 
/*»­»Æ»¨¹Ç¶ä»¨Ýà*/ 
  ellipse(x-70,y+15,140,390,17,20); 
  ellipse(x-75,y-10,205,340,10,30); 
  ellipse(x-60,y-10,195,340,5,30); 
  floodfill(x-70,y+32,10); 
/*»­Ò¶*/ 
/*»­ÓÒ±ßµÄÒ¶×Ó*/ 
  elli(x+168,y+282,10,20,-40); 
  elli(x+160,y+252,8,16,260); 
  elli(x+145,y+270,8,16,-15); 
  elli(x+156,y+224,10,20,-45); 
  elli(x+150,y+200,8,16,270); 
  elli(x+135,y+220,8,16,-10); 
  elli(x+146,y+144,8,16,-80); 
  elli(x+130,y+130,6,12,235); 
  elli(x+125,y+154,7,14,-10); 
  elli(x+78,y+98,6,12,-90); 
  elli(x+60,y+90,5,10,180); 
  elli(x+70,y+109,5,10,-45); 
/*»­×ó±ßµÄÒ¶×Ó*/ 
  elli(x-125,y+270,12,24,60); 
  elli(x-95,y+270,10,20,10); 
  elli(x-110,y+245,10,20,90); 
  elli(x-105,y+220,10,20,45); 
  elli(x-100,y+190,8,16,135); 
  elli(x-75,y+210,8,16,-45); 
/*»­ÖÐ¼äµÄÒ¶×Ó*/ 
  elli(x+65,y+190,10,20,-45); 
  elli(x+40,y+185,8,16,0); 
  elli(x+55,y+165,8,16,90); 
} 

/*Ö÷³ÌÐò*/ 
main() 
{ 
  int driver=VGA,mode=VGAHI; 
  initgraph(&driver,&mode,"C:\\TC"); 
  cleardevice(); 
  draw(450,90); 
  setcolor(2); 
  rectangle(0,0,639,479); 
  getch(); 
  closegraph(); 
} 

