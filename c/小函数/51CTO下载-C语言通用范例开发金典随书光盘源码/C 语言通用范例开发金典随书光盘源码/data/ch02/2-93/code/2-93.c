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

void monte_carlo_realplex(MCTLP mp)
{ 
	int k;
	double eps,xx,yy,a,r,z,x1,y1,z1;

	a=mp->b; k=1; r=1.0; 
	xx=mp->x[0]; yy=mp->y[0];
	z=(*mp->fuc)(xx,yy);
	eps=mp->eps;
	while (a>=eps) { 
		x1=xx-a+2.0*a*rand_num(&r); 
		y1=yy-a+2.0*a*rand_num(&r); 
		z1=(*mp->fuc)(x1,y1);	
		k++;	
		if (z1>=z)	{ 
			if (k>mp->m) { 
				k=1; a/=2.0; 
			}
		}	
		else { 
			k=1; xx=x1; yy=y1;  z=z1;	
			if (z<eps)	break;
		}
	}
	mp->x[0]=xx; mp->y[0]=yy; 
	return;
}

double realplex_ptr(double x,double y)
{ 
	double u,v,z;
    u=3*x*x-5*y*y-2.0*x+11.0;
    v=7.0*x*y-13.0*y;
    z=sqrt(u*u+v*v);
    return(z);
}

main()
{ 
	double x[] = {0.5};
	double y[] = {0.5};
	MCTL   mc = {1, x, y, 1.0, 10, 0.00001, realplex_ptr};

	monte_carlo_realplex(&mc);
	printf("\nz=%e +j %e\n\n",mc.x[0], mc.y[0]);;
}
