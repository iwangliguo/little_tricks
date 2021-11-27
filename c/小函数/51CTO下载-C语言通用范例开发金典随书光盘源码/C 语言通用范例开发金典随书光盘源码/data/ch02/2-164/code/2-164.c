#include "stdio.h"
#include "math.h"

double gt[5]={-0.9061798459,-0.5384693101,0.0,
	0.5384693101,0.9061798459};
double gc[5]={0.2369268851,0.4786286705,0.5688888889,
	0.4786286705,0.2369268851};

double sinintegral(double x)
{ 
	int    m,i,j;
	double s,p,ep,h,aa,bb,w,xx,g;
	
	if (x==0){
		return(0.0);
	}
	m=1; h=fabs(x); s=fabs(0.0001*h);	p=1.0e+35;  
	do { 
		g=0.0;
		for (i=0;i<m;i++){ 
			aa=i*h;	bb=i*h+h;
			w=0.0;
			for (j=0;j<5;j++){ 
				xx=0.5*((bb-aa)*gt[j]+(bb+aa));
				w+=sin(xx)/xx*gc[j];
			}
			g+=w;
		}
		g*=h/2.0;
		ep=fabs(g-p)/(1.0+fabs(g));
		p=g; m++; h=fabs(x)/m;
	}while ((ep>=0.0000001)&&(fabs(h)>s));
	return(g);
}

main()
{ 
	int n;

	for (n=1; n<6; n++){  
		printf("\nsinintegral(%3.1f)=%5.2f",
			0.5*n,sinintegral(0.5*n));
	}
}
