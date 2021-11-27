#include "math.h"
#include "stdio.h"

void fittingln(int n,double x[],double y[],double a[])
{ 
	int    i;
	double ax,ay,dx,dy,u;
	
	for (i=0,ax=ay=0.0; i<n; i++)	{ 
		ax+=log(x[i]); 
		ay+=log(y[i]);
	}
	ax/=n; ay/=n;
	for (i=0,dx=dy=0.0; i<n; i++){ 
		u=log(x[i])-ax; 
		dx+=u*u;
		dy+=u*(log(y[i])-ay);
	}
	a[0]=exp(ay-dy/dx*ax);
	a[1]=dy/dx; 
	a[2]=a[6]=a[4]=0.0; a[5]=1.0e+30;
	for (i=0; i<n; i++){ 
		a[3]=a[0]*exp(a[1]*log(x[i]));
		u=fabs(y[i]-a[3]);
		a[2]+=u*u;
		if (u>a[4]) a[4]=u;
		if (u<a[5]) a[5]=u;
		a[6]+=u;
	}
	a[3]=sqrt(a[2]/n);
	a[6]/=n;
}

main()
{ 
	int    n=9;
	double x[9]={0.6,2.1,4.0,5.2,8.4,10.0,32.4,57.0,87.6,};
	double y[9]={0.5,2.9,4.8,6.6,8.8,14.9,38.0,55.0,69.0};
	double a[7];

	fittingln(n,x,y,a);
	printf("\na=%e   b=%e  ",a[1],a[0]);
	printf("\nq=%e   s=%e  ",a[2],a[3]);
	printf("\numax=%e  umin=%e  u=%e ",a[4],a[5],a[6]);
}
