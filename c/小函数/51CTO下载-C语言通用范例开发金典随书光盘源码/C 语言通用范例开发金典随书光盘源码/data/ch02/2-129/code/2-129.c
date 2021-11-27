#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "ode.h"

void runge_kutta_steps(EODEP ap)
{ 
	int	   n,m,i,j,k;
	double eps,t,lens,*y,hh,p,dt,x,tt,q,a[4],*g,*b,*c,*d,*e;

	n=ap->n;
	g=malloc(n*sizeof(double));
	b=malloc(n*sizeof(double));
	c=malloc(n*sizeof(double));
	d=malloc(n*sizeof(double));
	e=malloc(n*sizeof(double));
	lens=ap->lens; eps=ap->eps; t=ap->t; y=ap->y;
	hh=lens; m=1; x=t;
	for (i=0; i<n; i++) 
		c[i]=y[i];
	do { 
		a[1]=a[0]=hh/2.0; 
		a[3]=a[2]=hh;
		for (i=0; i<n; i++) { 
			g[i]=y[i]; 
			y[i]=c[i];
		}
		dt=lens/m; t=x;
		for (j=0; j<m; j++){ 
			(*ap->ptr)(y,d);
			for (i=0; i<n; i++){ 
				b[i]=y[i]; e[i]=y[i];
			}
			for (k=0; k<=2; k++){ 
				for (i=0; i<n; i++)	{ 
					y[i]=e[i]+a[k]*d[i];
					b[i]+=a[k+1]*d[i]/3.0;
				}
				tt=t+a[k];
				(*ap->ptr)(y,d);
			}
			for (i=0; i<n; i++)
				y[i]=b[i]+hh*d[i]/6.0;
			t+=dt;
		}
		p=0.0;
		for (i=0; i<n; i++){ 
			q=fabs(y[i]-g[i]);
			if (q>p) p=q;
		}
		hh/=2.0; m<<=1;
	} while (p>=eps);
	free(g); free(b); free(c); free(d); free(e);/*释放动态分配的内存*/
	return;
}

void steps_ptr(double y[],double d[])
{ 
	d[0]=2.0*y[1]; 
	d[1]=-2.0*y[0];
}

main()
{ 
	double y[2] = {1.0, 3.0};
	EODE   ea = {2, 0.2, 0.00001, 1.0, y, steps_ptr};
	int i;

	printf("\n");
	for (i=0; i<11; i++)	{ 
		printf("t=%7.3f  y(0)=%e  y(1)=%e\n",ea.t,y[0],y[1]);
		runge_kutta_steps(&ea);
		ea.t += ea.lens;
	}
}
