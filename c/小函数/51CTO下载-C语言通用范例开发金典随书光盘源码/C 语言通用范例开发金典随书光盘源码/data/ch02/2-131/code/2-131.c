#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "ode.h"

void merson(FODE2P ap)
{ 
	int    n,steps,i,j,m,nn;
	double eps,lens,t,aa,bb,x,hh,p,dt,t0,qq;
	double *a,*b,*c,*d,*u,*v,*y,*z;

	n=ap->n;
	a=malloc(n*sizeof(double));
	b=malloc(n*sizeof(double));
	c=malloc(n*sizeof(double));
	d=malloc(n*sizeof(double));
	u=malloc(n*sizeof(double));
	v=malloc(n*sizeof(double));
	steps=ap->steps;
	eps=ap->eps; lens=ap->lens; t=ap->t;   aa=t;
	y=ap->y; z=ap->z;
	for (i=0; i<n; i++) {
		z[i*steps]=y[i];
	}
	for (i=1; i<steps; i++)	{ 
		x=aa+(i-1)*lens; nn=1; hh=lens;
		for (j=0; j<n; j++) u[j]=y[j];
		do { 
			for (j=0; j<=n-1; j++) 	{ 
				v[j]=y[j]; y[j]=u[j];
			}
			dt=lens/nn; t=x;
			for (m=0; m<nn; m++) { 
				(*ap->ptr)(t,y,d);
			for (j=0; j<n; j++)	{ 
				a[j]=d[j]; 
				y[j]+=hh*d[j]/3.0;}
				t0=t+hh/3.0;
				(*ap->ptr)(t0,y,d);
				for (j=0; j<n; j++)	{ 
					b[j]=d[j]; 
					y[j]+=hh*(d[j]-a[j])/6.0;
				}
				(*ap->ptr)(t0,y,d);
				for (j=0; j<n; j++) 	{ 
					b[j]=d[j];
					bb=(d[j]-4.0*(b[j]+a[j]/4.0)/9.0)/8.0;
					y[j]+=3.0*hh*bb;
				}
				t0=t+hh/2.0;
				(*ap->ptr)(t0,y,d);
				for (j=0; j<n; j++)	{ 
					c[j]=d[j];
					qq=d[j]-15.0*(b[j]-a[j]/5.0)/16.0;
					y[j]+=2.0*hh*qq;
				}
				t0=t+hh;
				(*ap->ptr)(t0,y,d);
				for (j=0; j<n; j++)	{ 
					qq=c[j]-9.0*(b[j]-2.0*a[j]/9.0)/8.0;
					qq=d[j]-8.0*qq;
					y[j]+=hh*qq/6.0;
				}
				t+=dt;
			}
			p=0.0;
			for (j=0; j<n; j++) { 
				qq=fabs(y[j]-v[j]);
				if (qq>p) p=qq;
			}
			hh/=2.0; nn<<=1;
		}while (p>=eps);
		for (j=0; j<=n-1; j++) 
			z[j*steps+i]=y[j];
	}
	/*释放动态分配的内存*/
	free(a); free(b); free(c); free(d); free(u); free(v);
	return;
}

void merson_ptr(double t,double y[],double d[])
{ 
	double q;

	q=11.0*(3.0+t*(t-2.0));
	d[0]=7.0*q*y[1]; 
	d[1]=-7.0*q*y[0];
	return;
}

main()
{ 
	double y[2]={0.0, 1.0};
	double z[2][11];
	FODE2  fa={2, 11, 0.1, 0.00001, 0.0, y, (double*)z,  merson_ptr};
	int i;

	merson(&fa);
	printf("\n");
	for (i=0; i<11; i++)	{ 
		printf("t=%7.3f  y(0)=%e  y(1)=%e\n", i*fa.lens, z[0][i], z[1][i]);
	}
	printf("\n");
}
