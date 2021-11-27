#include "math.h"
#include "stdio.h"
#include "stdlib.h"
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

void monte_carlo_equation(MCTLP mp)
{ 
	int    num,k,i;
	double eps,a,r,*x,*y,z,z1;
	num=mp->n;
	x=mp->x;
	y=malloc(num*sizeof(double));
	a=mp->b; k=1; r=1.0; 
	z=(*mp->fuc)(x);
	eps=mp->eps;
	while (a>=eps){ 
		for (i=0; i<num; i++)
			y[i]=-a+2.0*a*rand_num(&r)+x[i];
		z1=(*mp->fuc)(y);
		k++;
		if (z1>=z)	{ 
			if (k>mp->m) { 
				k=1; a/=2.0; 
			}
		}
		else{ 
			k=1; 	
			for (i=0; i<num; i++)
				x[i]=y[i];
			z=z1;
			if (z<eps)  {
				free(y);  return;
			}
		}
	}
	free(y); /*释放动态分配的内存*/
	return;
}

double equation_ptr(double x[])
{ 
	double f,f1,f2,f3;
	f1=5.0*x[0]+7*x[1]+x[2]*x[2]-11.0;
	f2=-13.0*x[0]+2.0*x[1]*x[1]+3.0*x[0]*x[2]-5.0;
	f3=17.0*x[0]*x[1]+22.0*x[2]+9.0;
	f=sqrt(f1*f1+f2*f2+f3*f3);
	return(f);
}

main()
{ 
	double x[] = {0.0, 0.0, 0.0};
	MCTL   mc = {3, x, NULL, 2.0, 10, 0.000001, equation_ptr};
	int    i;

	monte_carlo_equation(&mc);
    printf("\n");
	for(i=0; i<mc.n; i++) {
       printf("x(%d)=%13.7e\n",i, mc.x[i]);
	}
    printf("\n");
}
