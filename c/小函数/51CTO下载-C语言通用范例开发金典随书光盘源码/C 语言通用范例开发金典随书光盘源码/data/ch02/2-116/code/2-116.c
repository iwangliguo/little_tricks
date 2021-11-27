#include "math.h"
#include "stdio.h"
#include "integration.h"

/*在本函数中取5阶勒让德多项式，其在[-1，1]上的5个零点为: */
static double gt[5]={-0.9061798459,-0.5384693101,0.0,0.5384693101,0.9061798459};
/*对应的积分系数: */
static double gc[5]={0.2369268851,0.4786286705,0.5688888889,0.4786286705,0.2369268851};
double legendre_gauss(INTEGP ap)
{ 
	int m,i,j;
	double s,p,ep,h,aa,bb,w,x,g;

	m=1;
	h=ap->b - ap->a; 
	s=fabs(0.001*h);
	p=1.0e+35; 
	do 
	{
		g=0.0;
		for (i=1;i<m+1;i++) { 
			aa=ap->a+(i-1.0)*h; 
			bb=ap->a+i*h;
			w=0.0;
			for (j=0;j<5;j++) { 
				x=((bb-aa)*gt[j]+(bb+aa))/2.0;
				w+=(*ap->ptr)(x)*gc[j];
			}
			g+=w;
		}
		g*=h/2.0;
		ep=fabs(g-p)/(1.0+fabs(g));
		p=g; m++; 
		h=(ap->b - ap->a)/m;
	} while ((ep>=ap->eps)&&(fabs(h)>s));
	return(g);
}
  
double legendre_gauss_ptr(double x)
{ 
	double y;
    y=1.2*x*x+cos(x);
    return(y);
}
  
main()
{ 
	INTEG  ia = {3.0, 7.0, 0.000001, legendre_gauss_ptr};
    double g = legendre_gauss(&ia);
    printf("\n");
    printf("g=%e\n",g);
    printf("\n");
}
