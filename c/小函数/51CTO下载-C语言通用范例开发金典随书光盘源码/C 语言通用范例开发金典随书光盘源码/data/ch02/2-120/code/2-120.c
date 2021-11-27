#include "stdio.h"
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

double monte_carlo(MINTEGP ap)
{ 
	int m;
    double a,b,r,x,s;
    a=ap->a; b=ap->b; r=1.0; s=0.0; 
    for (m=0; m<ap->m; m++) { 
		x=a+(b-a)*rand_num(&r);
        s=s+(*ap->ptr)(x)/ap->m;
    }
    s=s*(b-a);
    return(s);
}

double monte_carlo_ptr(double x)
{ 
	double y;
    y=3.0*x*x+cos(x);
    return(y);
}
  
main()
{
	MINTEG ia = {2.0, 9.0, 10000, monte_carlo_ptr};
	double s = monte_carlo(&ia);
    printf("\ns=%e\n\n",s);
}
