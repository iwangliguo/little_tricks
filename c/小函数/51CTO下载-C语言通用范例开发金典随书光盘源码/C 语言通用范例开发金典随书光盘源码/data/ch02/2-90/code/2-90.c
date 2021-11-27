#include "math.h"
#include "stdio.h"
#include "stdlib.h"
#include "equation.h"

int gradient_nonlinear(GCTLP gp)
{ 
	int n,number,l,j;
	double f,d,s,*x,*y;

	n=gp->n;
	y=malloc(n*sizeof(double));
	x=gp->x;
	f=(*gp->fuc)(n,x,y);
	l=number=gp->iter;
	while (f>=gp->eps) {
		l--;
		if (l==0) { 
			free(y); return(number);
		}
		d=0.0;
		for (j=0; j<n; j++) 
			d+=y[j]*y[j];
		if (fabs(d)<0.0000001) { 
			free(y); return(-1);
		}
		s=f/d;
		for (j=0; j<n; j++) 
			x[j]-=s*y[j];
		f=(*gp->fuc)(n,x,y);
	}
	free(y); /* 释放动态分配的内存 */
	return(number-l);
}
  
double gradient_ptr(int n,double x[],double y[])
{ 
	double z,f1,f2,f3,df1,df2,df3;

    f1=4.0*x[0]-7.0*x[1]*x[1]+8.0*x[2]*x[2]-13.0;
    f2=15.0*x[0]*x[1]+5*x[0]*x[2]-17.0*x[0];
    f3=11.0*x[1]*x[2]+27.0*x[0];
    z=f1*f1+f2*f2+f3*f3;
    df1=4.0; df2=15.0*x[1]+5*x[2]-17.0; df3=27.0;
    y[0]=2.0*(f1*df1+f2*df2+f3*df3);
    df1=14.0*x[1]; df2=15.0*x[0]; df3=11.0*x[2];
    y[1]=2.0*(f1*df1+f2*df2+f3*df3);
    df1=16.0*x[2]; df2=5*x[0]; df3=11.0*x[1];
    y[2]=2.0*(f1*df1+f2*df2+f3*df3);
    return(z);
}
  
main()
{
	double  x[3] = {3.0,7.0,11.0};
	GCTL    gc = {3, x, 0.000001, 500, gradient_ptr };
	int     i;

	i=gradient_nonlinear(&gc);
	printf("\n");
	if ((i>0)&&(i<gc.iter))	{ 
		for (i=0; i<=2; i++)
			printf("x(%d)=%13.7e\n",i,x[i]);
		printf("\n");
	}
}
