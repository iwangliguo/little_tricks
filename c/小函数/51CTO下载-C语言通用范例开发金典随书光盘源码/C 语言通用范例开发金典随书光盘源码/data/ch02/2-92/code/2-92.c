#include "math.h"
#include "stdio.h"
#include "equation.h"

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

void monte_carlo_nonlinear(MCTLP mp)
{ 
	int    k;
	double eps,xx,a,r,y,x1,y1;
	eps=mp->eps;
	a=mp->b; k=1; r=1.0; xx=mp->x[0]; 
	y=(*mp->fuc)(xx);
	while (a>=eps) { 
		x1=rand_num(&r); 
		x1=xx-a+2.0*a*x1;
		y1=(*mp->fuc)(x1);
		k=k+1;
		if (fabs(y1)>=fabs(y))	{ 
			if (k>mp->m) { 
				k=1; a/=2.0; 		
			}
		}
		else{ 
			k=1; xx=x1; y=y1;
			if (fabs(y)<eps){ 
				mp->x[0]=xx; return; 
			}
		}
	}
	mp->x[0]=xx; 
}
  
double monte_carlo_ptr(double x)
{
	return exp(-3*x*x*x)-7*sin(x)/cos(x)+650.0;
}
  
main()
{ 
	double x[] = {0.5};
	MCTL   mc = {1, x, NULL, 1.0, 10, 0.00001, monte_carlo_ptr};

	monte_carlo_nonlinear(&mc);
	printf("\nx=%13.7e\n\n",mc.x[0]);
}
