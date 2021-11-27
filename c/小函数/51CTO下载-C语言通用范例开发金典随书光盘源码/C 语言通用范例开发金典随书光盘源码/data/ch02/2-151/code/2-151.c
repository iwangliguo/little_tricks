#include "stdio.h"

void alphabgfilter(int n,double x[],double t,double a,double b,double g,double y[])
{ 
	double s1,s2,v1,v2,a1,a2;
	int    i;

	a2=v2=s2=0.0;
	for (i=0; i<n; i++){ 
		s1=s2+t*v2+t*t*a2/2.0;
		v1=v2+t*a2; 
		a1=a2;
		s2=s1+a*(x[i]-s1); 
		y[i]=s2;
		v2=v1+b*(x[i]-s1);
		a2=a1+2.0*g*(x[i]-s1)/(t*t);
	}
	return;
}

void alphabgrnd(int n,double y[])
{ 
	int i,j,m;
	double s=65536.0,w=2053.0,v=13849.0,r=0.0,t=0.0;
	for (i=0; i<n; i++){ 
		t=0.0;
		for (j=0; j<12; j++){ 
			r=w*r+v; m=(int)(r/s); r=r-m*s; t=t+r/s;
		}
		y[i]=0.5*(t-6.0);
	}
	return;
}

main()
{ 
	double x[20],y[20],z[20];
	double a=0.271,b=0.0285,g=0.0005;
	double t,dt=0.05;
	int    i,k;
	
	k=20;
	alphabgrnd(20,y);
	for (i=0; i<20; i++) { 
		t=(i+1)*dt;
		z[i]=3.0*t*t-2.0*t+5.0;
		x[i]=z[i]+y[i];
	}
	alphabgfilter(20,x,dt,a,b,g,y);
	for (i=0; i<20; i=i+5){ 
		t=(i+1)*dt;
		printf("\n t=%5.2f  x(t)=%5.2f   y(t)=%5.2f   z(t)=%5.2f ",t,x[i],y[i],z[i]);
	}
	printf("\n");
}
