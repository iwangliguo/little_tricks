#include "math.h"
#include "stdio.h"

void fittinglogt(int n,double x[],double y[],double t,double a[])
{ 
	int    i;
	double ax,ay,dx,dy,u;
	
	for (i=0,ax=ay=0.0; i<n; i++){ 
		ax+=x[i]; 
		ay+=log(y[i])/log(t);
	}
	ax/=n; ay/=n;
	for (i=0,dx=dy=0.0; i<n; i++){ 
		u=x[i]-ax; 
		dx+=u*u;
		dy+=u*(log(y[i])/log(t)-ay);
	}
	a[0]=exp((ay-dy/dx*ax)*log(t));
	a[1]=dy/dx; 
	a[2]=a[6]=a[4]=0.0; 
	a[5]=1.0e+30;
	for (i=0; i<n; i++){ 
		a[3]=a[0]*exp(a[1]*x[i]*log(t));
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
	double x[9]={0.95,0.93,0.91,0.69,0.73,0.66,0.77,0.83};
	double y[9]={670.0,310.0,274.0,197.0,150.0,71.3,23.4,10.6,5.8};
	double t=10.0, a[7];

	fittinglogt(n,x,y,t,a);
	printf("\na=%e   b=%e  ",a[1],a[0]);
	printf("\nq=%e   s=%e  ",a[2],a[3]);
	printf("\numax=%e  umin=%e  u=%e ",a[4],a[5],a[6]);
}
