#include "stdio.h"
#include "math.h"

static double gt[5]={-0.9061798459,-0.5384693101,0.0,
		0.5384693101,0.9061798459};
static double gc[5]={0.2369268851,0.4786286705,0.5688888889,
		0.4786286705,0.2369268851};

double expintegral(double x)
{
	int m,i,j;
	double s,p,ep,h,aa,bb,w,xx,g,q;
	const double r=0.57721566490153286060651;
	
	m=1;
	if (x==0) x=1.0e-10;
	if (x<0.0) x=-x;
	q=r+log(x);
	h=x; s=fabs(0.0001*h);
	p=1.0e+35;
	do { 
		g=0.0;
		for (i=0;i<m;i++){ 
			aa=i*h;	bb=i*h+h;
			for (j=0,w=0.0;j<=4;j++){ 
				xx=((bb-aa)*gt[j]+(bb+aa))/2.0;
				w+=(exp(-xx)-1.0)/xx*gc[j];
			}
			g+=w;
		}
		g*=0.5*h;
		ep=fabs(g-p)/(1.0+fabs(g));
		p=g; m++; h=x/m;
	}while ((ep>=0.0000001)&&(fabs(h)>s));
	g=q+g;
	return(g);
}

main()
{ 
	int n;

	for (n=1; n<6; n++){  
		printf("\nexpintegral(%3.1f)=%5.2f",0.5*n,expintegral(0.5*n));
	}
}
