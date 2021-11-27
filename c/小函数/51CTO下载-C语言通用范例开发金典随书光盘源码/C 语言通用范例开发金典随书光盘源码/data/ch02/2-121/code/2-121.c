#include "math.h"
#include "stdio.h"
#include "integration.h"

double simpson_method(double x,double eps,void (*ud)(),double (*ptr)())
{ 
	int    n,i;
	double y[2],h,d,t1,yy,t2,g,ep,g0;

	n=1;
	(*ud)(x,y);
	h=0.5*(y[1]-y[0]);
	d=fabs(h*2.0e-06);
	t1=h*((*ptr)(x,y[0])+(*ptr)(x,y[1]));
	g0=1.0e+35;
	do { 
		yy=y[0]-h;
		t2=0.5*t1;
		for (i=1;i<=n;i++){ 
			yy+=2.0*h;
			t2+=h*(*ptr)(x,yy);
		}
		g=(4.0*t2-t1)/3.0;
		ep=fabs(g-g0)/(1.0+fabs(g));
		n<<=1; g0=g; 
		t1=t2; h/=2.0;
	} while (((ep>=eps)&&(fabs(h)>d))||(n<16));
	return(g);
}

double simpson(INTEG2P ap)
{ 
	int    n,j;
	double h,d,s1,s2,t1,x,t2,g,s,s0,ep;
	double a, b, eps;

	a=ap->a; b=ap->b; eps=ap->eps;
	n=1; h=(b-a)/2.0;
	d=fabs((b-a)*1.0e-06);
	s1=simpson_method(a,eps,ap->ud,ap->ptr); 
	s2=simpson_method(b,eps,ap->ud,ap->ptr);
	t1=h*(s1+s2);
	s0=1.0e+35;
	do{ 
		x=a-h; t2=t1/2.0;
		for (j=1;j<=n;j++)	{ 
			x+=2.0*h;	
			g=simpson_method(x,eps,ap->ud,ap->ptr);
			t2+=h*g;
		}
		s=(4.0*t2-t1)/3.0;
		ep=fabs(s-s0)/(1.0+fabs(s));
		n<<=1; s0=s; 
		t1=t2; h/=2.0;
	} while (((ep>=eps)&&(fabs(h)>d))||(n<16));
	return(s);
}

void simpson_ud_ptr(double x,double y[2])
{ 
	y[0]=-sqrt(2.0-x*x);
	y[1]=-y[0];
	return;
}

double simpson_ptr(double x,double y)
{ 
	double z;
	z=exp(0.9*x*x+1.1*y*y);
	return(z);
}

main()
{ 
	INTEG2  sa = {0.0, 1.0, 0.0001, simpson_ud_ptr, simpson_ptr};
	double   s=simpson(&sa);
	printf("\ns=%e\n\n",s);
}
