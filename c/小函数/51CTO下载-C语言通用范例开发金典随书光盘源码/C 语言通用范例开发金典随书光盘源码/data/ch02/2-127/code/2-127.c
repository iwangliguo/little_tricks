#include "stdio.h"
#include "stdlib.h"
#include "ode.h"

void witty(FODEP ap)
{ 
	int    n,steps,i,j;
	double lens,t,x,*a,*d,*y,*z;

	n=ap->n; steps=ap->steps;
	lens=ap->lens; t=ap->t; y=ap->y; z=ap->z;
	a=malloc(n*sizeof(double));
	d=malloc(n*sizeof(double));
	for (i=0; i<n; i++) 
		z[i*steps]=y[i];
	(*ap->ptr)(y,d);
	for (j=1; j<steps; j++) 	{ 
		for (i=0; i<n; i++)
			a[i]=z[i*steps+j-1]+lens*d[i]/2.0;
		x=t+(j-0.5)*lens;
		(*ap->ptr)(a,y);
		for (i=0; i<n; i++)	{ 
			d[i]=2.0*y[i]-d[i];
			z[i*steps+j]=z[i*steps+j-1]+lens*y[i];
		}
	}
	free(a); free(d);/*释放动态分配的内存*/
	return;
}
  
void witty_ptr(double y[],double d[])
{ 
	d[0]=2.0*y[1]; 
	d[1]=-2.0*y[0]; 
	d[2]=-2.0*y[2];
}
  
main()
{ 
	int i,j;
	double y[3] = {-1.5, 0.0, 1.5};
	double z[3][11] = {0.0};
	FODE   fa={3, 11, 0.01, 0.0, y, (double*)z, witty_ptr};

	witty(&fa);
	for (i=0; i<11; i++)	{ 
		printf("t=%5.2f\n",fa.lens * i);
		for (j=0; j<3; j++)
			printf("y(%d)=%e  ",j,z[j][i]);
		printf("\n");
	}
}
