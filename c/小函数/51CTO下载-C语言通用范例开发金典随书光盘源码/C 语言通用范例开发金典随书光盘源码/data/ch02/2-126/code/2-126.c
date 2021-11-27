#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "ode.h"

void euler_variable(EODEP ap)
{ 
	int n,i,j,m;
	double hh,p,x,q,*a,*b,*c,*d,*y;

	n=ap->n;
	a=malloc(n*sizeof(double));
	b=malloc(n*sizeof(double));
	c=malloc(n*sizeof(double));
	d=malloc(n*sizeof(double));
	hh=ap->lens; m=1;
	y=ap->y;
	for (i=0; i<n; i++) 
		a[i]=y[i];
	do { 
		for (i=0; i<n; i++)	{ 
			b[i]=y[i]; y[i]=a[i];
		}
		for (j=0; j<m; j++)	{ 
			for (i=0; i<n; i++) c[i]=y[i];
				x=ap->t+j*hh;
			(*ap->ptr)(y,d);
			for (i=0; i<n; i++)
				y[i]=c[i]+hh*d[i];
			x=ap->t+(j+1)*hh;
			(*ap->ptr)(y,d);
			for (i=0; i<n; i++) {
				d[i]*=hh;
				d[i]+=c[i];
			}
			for (i=0; i<n; i++)
				y[i]=(y[i]+d[i])/2.0;
		}
		p=0.0;
		for (i=0; i<n; i++)	{ 
			q=fabs(y[i]-b[i]);
			if (q>p) p=q;
		}
		hh/=2.0; m<<=1;
	} while (p>=ap->eps);
	free(a); free(b); free(c); free(d);  /*释放动态分配的内存*/
}

void variable_ptr(double y[],double d[])
{ 
	d[0]=2.0*y[1]; 
	d[1]=-2.0*y[0]; 
	d[2]=-2.0*y[2];
}
  
main()
{ 
	int i,j;
	double t = 0.0;
	double y[3] = {-1.5, 0.0, 1.5};
	EODE   ea = {3, 0.01, 0.00001, 0.0, y, variable_ptr};

	printf("\n");
	printf("t=%5.2f\n",t);
	for (i=0; i<ea.n; i++)
		printf("y(%d)=%e  ",i,y[i]);

	printf("\n");
	for (j=0; j<10; j++)	{ 
		ea.t = t;
		euler_variable(&ea);
		t += ea.lens;
		printf("t=%5.2f\n",t);
		for (i=0; i<ea.n; i++)
			printf("y(%d)=%e  ",i,y[i]);
		printf("\n");
	}
}
