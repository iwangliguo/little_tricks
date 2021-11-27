#include "math.h"
#include "stdio.h"
#include "integration.h"

/*在本函数中取5阶切比雪夫多项式，其在[-1，1]上的5个零点为: */
static double gt[5]={-0.8324975,-0.3745414,0.0,0.3745414,0.8324975};

double chebyshev(INTEGP ap)
{ 
	int m,i,j;
	double h,d,p,ep,g,aa,bb,s,x;

	m=1;
	h=ap->b - ap->a; 
	d=fabs(0.001*h);
	p=1.0e+35; 
	do{ 
		g=0.0;
		for (i=1;i<=m;i++){ 
			aa=ap->a+(i-1.0)*h; 
			bb=ap->a+i*h;
			s=0.0;
			for (j=0;j<5;j++){ 
				x=((bb-aa)*gt[j]+(bb+aa))/2.0;
				s+=(*ap->ptr)(x);
			}
			g+=s;
		}
		g*=h/5.0;
		ep=fabs(g-p)/(1.0+fabs(g));
		p=g; m++; 
		h=(ap->b - ap->a)/m;
	} while ((ep>=ap->eps)&&(fabs(h)>d));
	return(g);
}
  
double chebyshev_ptr(double x)
{ 
	return 3.0*x*x+cos(x);
}
  
main()
{ 
	INTEG  ia = {2.0, 9.0, 0.000001, chebyshev_ptr};
    double s=chebyshev(&ia);
    printf("\ns=%e\n\n",s);
}
