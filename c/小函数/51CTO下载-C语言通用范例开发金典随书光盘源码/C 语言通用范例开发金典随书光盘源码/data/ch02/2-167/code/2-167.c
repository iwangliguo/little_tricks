#include "stdio.h"
#include "math.h"

#define PI  3.1415926
double gt[5]={-0.9061798459,-0.5384693101,0.0,
		0.5384693101,0.9061798459};
double gc[5]={0.2369268851,0.4786286705,0.5688888889,
		0.4786286705,0.2369268851};

double ellipse1(double k,double f)
{ 
	int m,i,j;
	double s,p,ep,h,aa,bb,w,xx,g,q;
	
	m=1; h=fabs(f); s=fabs(0.0001*h); p=1.0e+35;
	do { 
		g=0.0;
		for (i=0;i<m;i++){ 
			aa=i*h; bb=i*h+h;
			for (j=0, w=0.0; j<=4; j++){ 
				xx=((bb-aa)*gt[j]+(bb+aa))/2.0;
				q=sqrt(1.0-k*k*sin(xx)*sin(xx));
				w+=gc[j]/q;
			}
			g+=w;
		}
		h/=2.0; g*=h;
		ep=fabs(g-p)/(1.0+fabs(g));
		p=g; m<<=1; 
	}while ((ep>=0.0000001)&&(fabs(h)>s));
	return(g);
}

double ellipseintegral1(double k,double f)
{ 
	int    n;
	double y,e,ff;
	
	k=fabs(k);
	if (k>1.0) k=1.0/k;
	n=0;
	y=fabs(f);
	while (y>=PI){ 
		n++; y-=PI;
	}
	e=1.0;
	if (y>=PI/2.0){ 
		n++; e=-e; y=PI-y;
	}
	if (n==0)
		ff=ellipse1(k,y);
	else{ 
		ff=ellipse1(k,PI/2.0);
		ff=2.0*n*ff+e*ellipse1(k,y);
	}
	if (f<0.0) ff=-ff;
	return(ff);
}

main()
{ 
	int n;
	
	for (n=1; n<6; n++){  
		printf("\nellipseintegral1(0.5,%3.1f)=%5.2f",
			PI*n/6,ellipseintegral1 (0.5, PI*n/6));
	}
}
