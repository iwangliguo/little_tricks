#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "ode.h"

static double ga[4]={0.5,0.29289321881,1.7071067812,0.166666667};
static double gb[4]={2.0,1.0,1.0,2.0};
static double gc[4]={0.5,0.29289321881,1.7071067812,0.5};
static double ge[4]={0.5,0.5,1.0,1.0};

void gill(EODE2P ap)
{ 
	int    n,j,k,m,ii;
	double eps,lens,t,x,p,hh,r,s,t0,dt,qq,*d,*u,*v,*g,*y,*q;

	n=ap->n;
	d=malloc(n*sizeof(double));
	u=malloc(n*sizeof(double));
	v=malloc(n*sizeof(double));
	g=malloc(n*sizeof(double));
	eps=ap->eps; lens=ap->lens; t=ap->t; y=ap->y; q=ap->q;
	x=t; hh=lens; m=1;
	for (j=0; j<n; j++) 
		u[j]=y[j];
	do { 
		for (j=0; j<=n-1; j++) 	{ 
			v[j]=y[j]; y[j]=u[j]; g[j]=q[j];
		}
		dt=lens/m; t=x;
		for (k=0; k<=m-1; k++) 	{ 
			(*ap->ptr)(y,d);
			for (ii=0; ii<=3; ii++) { 
				for (j=0; j<n; j++)
					d[j]*=hh;
				for (j=0; j<n; j++){ 
					r=(ga[ii]*(d[j]-gb[ii]*g[j])+y[j])-y[j];
					y[j]=y[j]+r;
					s=g[j]+3.0*r;
					g[j]=s-gc[ii]*d[j];
				}
				t0=t+ge[ii]*hh;
				(*ap->ptr)(y,d);
			}
			t+=dt;
		}
		p=0.0;
		for (j=0; j<n; j++)	{ 
			qq=fabs(y[j]-v[j]);
			if (qq>p) p=qq;
		}
		hh=hh/2.0; m=m+m;
	}while (p>=eps);
	for (j=0; j<n; j++) 
		q[j]=g[j];
	free(g); free(d); free(u); free(v);/*释放动态分配的内存*/
	return;
}

void gill_ptr(double y[],double d[])
{ 
	d[0]=2.0*y[1]; 
	d[1]=-2.0*y[0]; 
	d[2]=-2.0*y[2];
}

main()
{ 
	double q[3]={0.0};
	double y[3]={0.0,1.0,1.0};
	EODE2  ea = {3, 0.3, 0.000001, 0.0, y, q, gill_ptr};
	int i,j;

	for (i=1; i<12; i++)	{ 
		printf("\nt=%7.3f\n",ea.t);
		for (j=0; j<ea.n; j++)
			printf("y(%d)=%e  ",j,y[j]);
		gill(&ea);
		ea.t += ea.lens;
	}
	printf("\n");
}
