#include "stdio.h"
#include "stdlib.h"
#include "ode.h"

void euler_step(FODEP ap)
{ 
	int    n,steps,i,j;
	double x,lens,t,*y,*z,*d;

	n=ap->n; steps=ap->steps;
	lens=ap->lens; t=ap->t; 
	y=ap->y; z=ap->z;
	d=malloc(n*sizeof(double));
	for (i=0; i<n; i++) 
		z[i*steps]=y[i];
	for (j=1; j<steps; j++){ 
		x=t+(j-1)*lens;
		(*ap->ptr)(y,d);
		for (i=0; i<n; i++)
			y[i]=z[i*steps+j-1]+lens*d[i];
		x=t+j*lens;
		(*ap->ptr)(y,d);
		for (i=0; i<n; i++)
			d[i]=z[i*steps+j-1]+lens*d[i];
		for (i=0; i<n; i++) 	{ 
			y[i]=0.5*(y[i]+d[i]);
			z[i*steps+j]=y[i];
		}
	}
	free(d);/*释放动态分配的内存*/
}
  
void step_ptr(double y[],double d[])
{ 
	d[0]=2.0*y[1]; 
	d[1]=-2.0*y[0]; 
	d[2]=-2.0*y[2];
}
  
main()
{ 
	int i,j;
	double y[3] = {-1.5, 0.0, 1.5};
	double z[3][11] = {0};
	FODE   fa = {3, 11, 0.01, 0.0, y, (double*)z, step_ptr};

	euler_step(&fa);
	printf("\n");
	for (i=0; i<fa.steps; i++)	{ 
		printf("t=%5.2f\n",i* fa.lens);
		for (j=0; j<fa.n; j++)
			printf("y(%d)=%e  ",j,z[j][i]);
		printf("\n");
	}
	printf("\n");
}
