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

double betafraction(double a,double b, double x)
{ 
	int    k,l;
	double d,p0,q0,p1,q1,s0,s1;

	p0=0.0; q0=1.0; p1=1.0; q1=1.0;
	for (k=1; k<101; k++){ 
		d=(a+k)*(a+b+k)*x;
		l=k<<1;
		d=-d/((a+l)*(a+l+1.0));
		p0*=d; p0+=p1; 
		q0*=d; q0+=q1; 
		s0=p0/q0;
		d=k*(b-k)*x;
		d=d/((a+l-1)*(a+l));
		p1*=d; p1+=p0; 
		q1*=d; q1+=q0; 
		s1=p1/q1;
		if (fabs(1.0-s0/s1)<1.0e-07){
			return(s1);
		}
	}
	printf("a or b is too big !");
	return(s1);
}

double beta(double a,double b,double x)
{ 
	double y;

	if (a<=0.0)	{ 
		printf("parameter a<=0!"); 
		return(-1.0);
	}
	if (b<=0.0) { 
		printf("parameter b<=0!"); 
		return(-1.0);
	}
	if ((x<0.0)||(x>1.0))	{ 
		printf("parameter x<0 or x>1 !");
		return(1.0e+70);
	}
	if ((x==0.0)||(x==1.0)) { 
		y=0.0;
	}
	else	{ 
		y=exp(a*log(x)+b*log(1.0-x));
		y*=gamma(a+b)/(gamma(a)*gamma(b));
	}
	if (x<(a+1.0)/(a+b+2.0)) {
		y*=betafraction(a,b,x)/a;
	}
	else{
		y*=-betafraction(b,a,1.0-x)/b;
		y+=1.0;
	}
	return(y);
}

double tdistribution(double t,int n)
{ 
	t=fabs(t);
	return 1.0-beta(n/2.0,0.5,n/(n+t*t));
}

main()
{ 
	int n;

	for (n=1; n<6; n++)	{  
		printf("\ntdistribution(%4.2f,%d)=%e",
			0.5*n,n,tdistribution(0.5*n,n));
	}
}
