#include "stdio.h"
#include "stdlib.h"
#include "ode.h"

void runge_kutta(FODEP ap)
{ 
	int n,steps,i,j,l;
	double t,lens,*y,*z,a[4],*b,*d;

	n=ap->n; steps=ap->steps;
	b=malloc(n*sizeof(double));
	d=malloc(n*sizeof(double));
	t=ap->t; lens=ap->lens; y=ap->y; z=ap->z;
	a[1]=a[0]=lens/2.0;
	a[3]=a[2]=lens;
	for (i=0; i<n; i++) {
		z[i*steps]=y[i];
	}
	for (l=1; l<steps; l++)	{ 
		(*ap->ptr)(y,d);
		for (i=0; i<n; i++) 
			b[i]=y[i];
		for (j=0; j<3; j++) { 
			for (i=0; i<n; i++) 	{ 
				y[i]=z[i*steps+l-1]+a[j]*d[i];
				b[i]+=a[j+1]*d[i]/3.0;
			}
			(*ap->ptr)(y,d);
		}
		for (i=0; i<n; i++)
			y[i]=b[i]+lens*d[i]/6.0;
		for (i=0; i<n; i++)
			z[i*steps+l]=y[i];
		t+=lens;
	}
	free(b); free(d);/*释放动态分配的内存*/
	return;
}

void runge_kutta_ptr(double y[],double d[])
{
	d[0]=2.0*y[1]; 
	d[1]=-2.0*y[0]; 
	d[2]=-2.0*y[2];
}

main()
{ 
	double y[3]={-1.5, 0.0, 1.5}; 
	double z[3][11]={0};
	FODE   fa={3, 11, 0.01, 0.0, y, (double*)z, runge_kutta_ptr};
	int    i,j;

	runge_kutta(&fa);
	printf("\n");
	for (i=0; i<fa.steps; i++)	{ 
		printf("t=%5.2f\n", i*fa.lens);
		for (j=0; j<fa.n; j++)
			printf("y(%d)=%e  ",j,z[j][i]);
		printf("\n");
	}
}
