#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "ode.h"

void hamming_method(int n,double eps,double t,double lens,double y[],void (*ptr)())
{ 
	int    m,i,j,k;
	double hh,p,dt,x,tt,q,a[4];
	double *g,*b,*c,*d,*e;

	g=malloc(n*sizeof(double));
	b=malloc(n*sizeof(double));
	c=malloc(n*sizeof(double));
	d=malloc(n*sizeof(double));
	e=malloc(n*sizeof(double));
	hh=lens; m=1; x=t;
	for (i=0; i<n; i++){
		c[i]=y[i];
	}
	do { 
		a[1]=a[0]=hh/2.0; a[3]=a[2]=hh;
		for (i=0; i<n; i++)	{ 
			g[i]=y[i]; y[i]=c[i];
		}
		dt=lens/m; t=x;
		for (j=0; j<m; j++) 	{ 
			(*ptr)(t,y,n,d);
			for (i=0; i<n; i++)	{ 
				b[i]=y[i]; e[i]=y[i];
			}
			for (k=0; k<3; k++){ 
				for (i=0; i<n; i++){ 
					y[i]=e[i]+a[k]*d[i];
					b[i]+=a[k+1]*d[i]/3.0;
				}
				tt=t+a[k];
				(*ptr)(tt,y,n,d);
			}
			for (i=0; i<n; i++)
				y[i]=b[i]+hh*d[i]/6.0;
			t+=dt;
		}
		p=0.0;
		for (i=0; i<n; i++)	{ 
			q=fabs(y[i]-g[i]);
			if (q>p) p=q;
		}
		hh/=2.0; m<<=1;
	}while (p>=eps);
	/*释放动态分配的内存*/
	free(g); free(b); free(c); free(d); free(e);
	return;
}

void hamming(FODE2P ap)
{
	int    n,steps,i,j,m;
	double lens,eps,t,t0,q;
	double *b,*d,*u,*v,*w,*g,*y,*z;

	n=ap->n; steps=ap->steps;
	b=malloc(4*n*sizeof(double));
	d=malloc(n*sizeof(double));
	u=malloc(n*sizeof(double));
	v=malloc(n*sizeof(double));
	w=malloc(n*sizeof(double));
	g=malloc(n*sizeof(double));
	lens=ap->lens;eps=ap->eps;
	y=ap->y;z=ap->z;
	t0=t=ap->t;
	for (i=0; i<n; i++) 
		z[i*steps]=y[i];
	(*ap->ptr)(t,y,n,d);
	for (i=0; i<n; i++) 
		b[i]=d[i];
	for (i=1; i<4; i++)
		if (i<steps)	{ 
			t=t0+i*lens;
			hamming_method(n,eps,t,lens,y,ap->ptr);
			for (m=0; m<n; m++) 
				z[m*steps+i]=y[m];
			(*ap->ptr)(t,y,n,d);
			for (m=0; m<n; m++)
				b[i*n+m]=d[m];
		}
	for (i=0; i<n; i++) 
		u[i]=0.0;
	for (i=4; i<steps; i++){ 
		for (j=0; j<n; j++){ 
			q=2.0*b[3*n+j]-b[n+n+j]+2.0*b[n+j];
			y[j]=z[j*steps+i-4]+4.0*lens*q/3.0;
		}
		for (j=0; j<n; j++)
			y[j]+=112.0*u[j]/121.0;
		t=t0+i*lens;
		(*ap->ptr)(t,y,n,d);
		for (j=0; j<n; j++){ 
			q=9.0*z[j*steps+i-1]-z[j*steps+i-3];
			q=(q+3.0*lens*(d[j]+2.0*b[3*n+j]-b[n+n+j]))/8.0;
			u[j]=q-y[j];
			z[j*steps+i]=q-9.0*u[j]/121.0;
			y[j]=z[j*steps+i];
			b[n+j]=b[2*n+j];
			b[2*n+j]=b[3*n+j];
		}
		(*ap->ptr)(t,y,n,d);
		for (m=0; m<n; m++) 
			b[3*n+m]=d[m];
	}
	/*释放动态分配的内存*/
	free(b); free(d); free(u); free(v); free(w); free(g);
	return;
}

void hamming_ptr(double t,double y[],int n,double d[])
{
	t=t; n=n;
	d[0]=2.0*y[1]; 
	d[1]=-2.0*y[0]; 
	d[2]=2.0*y[2];
	return;
}

main()
{ 
	double y[3]={1.0, 2.0, 3.0};
	double z[3][11]={0};
	FODE2  fa={3, 11, 0.1, 0.0001, 0.0, y, (double*)z, hamming_ptr};
	int    i,j;

	hamming(&fa);
	printf("\n");
	for (i=0; i<fa.steps; i++)	{
		printf("t=%7.3f\n",i*fa.lens);
		for (j=0; j<fa.n; j++)
			printf("y(%d)=%e  ",j,z[j][i]);
		printf("\n");
	}
	printf("\n");
}
