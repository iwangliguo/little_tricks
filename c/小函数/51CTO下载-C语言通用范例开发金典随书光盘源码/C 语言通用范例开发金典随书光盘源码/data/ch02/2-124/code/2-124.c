#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "integration.h"

double rand_num(double *r)
{
    int m;
    double s,u,v,p;
    s=65536.0; u=2053.0; v=13849.0;
    m=(int)(*r/s); *r=*r-m*s;
    *r=u*(*r)+v; m=(int)(*r/s);
    *r=*r-m*s; p=*r/s;
    return(p);
}

double monte_carlo_multi(MINTEG2P ap)
{ 
	int n,m,i;
	double r,s,*a,*b,*x;

	n=ap->n;
	x=malloc(n*sizeof(double));
	a=ap->a; b=ap->b;
	r=1.0; s=0.0;
	for (m=0; m<ap->m; m++)	{ 
		for (i=0; i<n; i++)
			x[i]=a[i]+(b[i]-a[i])*rand_num(&r);
		s=s+(*ap->ptr)(n,x)/ap->m;
	}
	for (i=0; i<n; i++)
		s*=(b[i]-a[i]);
	free(x); /*释放动态分配的内存*/
	return(s);
}
  
double multi_ptr(int n,double x[])
{ 
	int    i;
	double f;

	f=0.0;
	for (i=0; i<n; i++) {
		f+=x[i]*x[i];
	}
	return(f);
}
  
main()
{
	double a[3]={ 2.0,2.0,2.0};
	double b[3]={ 3.0,3.0,3.0};
	MINTEG2 ma = {3,10000,a,b,multi_ptr};
	double s = monte_carlo_multi(&ma);
	printf("\ns=%e\n\n",s);
}
