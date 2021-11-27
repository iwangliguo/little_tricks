#include "math.h"
#include "stdio.h"
#define PI 3.1415926

void seriesfour( double f[],int n, double a[],double b[])
{ 
	int    i,j;
	double t,cost,sint,c1,s1,u1,u2,u0;
	t=2*PI/(2.0*n+1.0);
	cost=cos(t); 
	sint=sin(t);
	t=2.0/(2.0*n+1.0); 
	for (i=0,c1=1.0,s1=0.0; i<=n; i++){ 
		for (j=2*n, u1=u2=0.0; j>0; j--){ 
			u0=f[j]+2.0*c1*u1-u2;
			u2=u1; u1=u0;
		}
		a[i]=t*(f[0]+u1*c1-u2);
		b[i]=t*u1*s1;
		u0=cost*c1-sint*s1; 
		s1=cost*s1+sint*c1; 
		c1=u0;
	}
}

main()
{ 
	int    i;
	double f[10+1],a[5+1],b[5+1],c,h;
	
	h=2*PI/11.0;
	for (i=0; i<=10; i++){ 
		c=(i+0.5)*h; 
		f[i]=c*c;
	}
	seriesfour(f,5,a,b);
	printf("\n");
	for (i=0; i<=5; i++)
		printf("a[%d]=%3.5lf  b[%d]=%3.5lf\n",i,a[i],i,b[i]);
	printf("\n");
}
