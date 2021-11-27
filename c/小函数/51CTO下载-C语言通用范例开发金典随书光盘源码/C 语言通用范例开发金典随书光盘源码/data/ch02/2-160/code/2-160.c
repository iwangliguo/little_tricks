#include "stdio.h"
#include "math.h"

static double ga[11]={ 0.0000677106, -0.0003442342, 0.0015397681,
	-0.0024467480, 0.0109736958, -0.0002109075, 0.0742379071,
	0.0815782188, 0.4118402518, 0.4227843370, 1.0};

double gamma(double x)
{ 
	double y,t,s,u;
	int    i;
	if (x<=0.0)	{ 
		printf("the parameter x<=0!\n");
		return(-1.0);
	}
	y=x;
	if (y<=1.0) { 
		t=1.0/(y*(y+1.0)); y+=2.0;
	}
	else if (y<=2.0) { 
		t=1.0/y; y+=1.0;
	}
	else if (y<=3.0) {
		t=1.0;
	}
	else { 
		t=1.0;
		do  { 
			y-=1.0; t=t*y;
		} while (y>3.0);
	}
	s=ga[0]; u=y-2.0;
	for (i=1; i<11; i++)
		s=s*u+ga[i];
	return(s*t);
}

double incomgam(double a,double x)
{ 
	double p,q,d,s,s1,p0,q0,p1,q1,q2;
	int    n=0;
	
	if (a<=0.0) {
		printf("the parameter a<=0!\n");
		return(-1.0);
	}
	if (x<0.0) {
		printf("the parameter x<0!\n");
		return(-1.0);
	}
	if (fabs(x) < 0.0000001) 
		return(0.0);
	if (x>1.0e+35) 
		return(1.0);
		
	q=a*log(x); q2=exp(q);
	if (x<1.0+a){ 
		p=a; d=1.0/a; s=d;
		while (++n<=100){ 
			p+=1.0; d*=x/p; s+=d;
			if (fabs(d/s)<1.0e-07){ 
				s*=exp(-x)*q2/gamma(a);
				return(s);
			}
		}
	}
	else{ 
		s=1.0/x; p0=0.0; p1=1.0; q0=1.0; q1=x;
		while (++n<=100){ 
			p0=p1+(n-a)*p0; 
			q0=q1+(n-a)*q0;
			p=x*p0+n*p1; 
			q=x*q0+n*q1;
			if (fabs(q)>0.0000001){ 
				s1=p/q; p1=p; q1=q;
				if (fabs((s1-s)/s1)<1.0e-07){ 
					s=s1*exp(-x)*q2/gamma(a);
					return(1.0-s);
				}
				s=s1;
			}
			p1=p; q1=q;
		}
	}
	printf("the parameter a is too large !\n");
	s=1.0-s*exp(-x)*q2/gamma(a);
	return(s);
}

double errorfun(double x)
{ 
	return (x>=0.0)? incomgam(0.5,x*x):-incomgam(0.5,x*x);
}

double gauss(double a,double d,double x)
{ 
	if (d<=0.0)	d=1.0e-10;
	return (1.0+errorfun((x-a)/(sqrt(2.0)*d)))/2.0;
}

main()
{ 
	int n;

	for (n=0; n<4; n++)	{ 
		printf("\ngauss(0.5,2.0,%4.2f)=%2.5f",
			(n+1)*0.2, gauss(0.5,2.0,(n+1)*0.2));
	}
}
