#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "ode.h"

static void bilateral_method(int n,double eps,double t,double lens,double y[],void (*ptr)())
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
	for (i=0; i<n; i++) c[i]=y[i];
	do 	{ 
		a[1]=a[0]=hh/2.0; a[3]=a[2]=hh;
		for (i=0; i<n; i++) 	{ 
			g[i]=y[i]; y[i]=c[i];
		}
		dt=lens/m; t=x;
		for (j=0; j<m; j++){ 
			(*ptr)(t,y,n,d);
			for (i=0; i<n; i++) { 
				b[i]=y[i]; e[i]=y[i];
			}
			for (k=0; k<3; k++) { 
				for (i=0; i<n; i++) { 
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
		for (i=0; i<n; i++) { 
			q=fabs(y[i]-g[i]);
		if (q>p) p=q;
		}
		hh=hh/2.0; m<<=1;
	} while (p>=eps);
	/*释放动态分配的内存*/
	free(g); free(b); free(c); free(d); free(e);
	return;
}

void bilateral(FODE2P ap)
{
	int    n,steps,i,j;
	double lens,eps,t,t0,qq;
	double *d,*p,*u,*v,*w,*y,*z;

	n=ap->n; steps=ap->steps; 
	d=malloc(n*sizeof(double));
	p=malloc(n*sizeof(double));
	u=malloc(n*sizeof(double));
	v=malloc(n*sizeof(double));
	w=malloc(n*sizeof(double));
	lens=ap->lens; eps=ap->eps; 
	y=ap->y; z=ap->z;
	for (i=0; i<n; i++) {
		p[i]=0.0; z[i*steps]=y[i];
	}
	t0=t=ap->t;
	(*ap->ptr)(t,y,n,d);
	for (j=0; j<n; j++) u[j]=d[j];
	bilateral_method(n,eps,t,lens,y,ap->ptr);
	t+=lens;
	(*ap->ptr)(t,y,n,d);
	for (j=0; j<n; j++)	{ 
		z[j*steps+1]=y[j]; 
		v[j]=d[j];
	}
	for (j=0; j<n; j++){ 
		p[j]=-4.0*z[j*steps+1]+5.0*z[j*steps]+2.0*lens*(2.0*v[j]+u[j]);
		y[j]=p[j];
	}
	t+=lens;
	(*ap->ptr)(t,y,n,d);
	for (j=0; j<n; j++){ 
		qq=2.0*lens*(d[j]-2.0*v[j]-2.0*u[j])/3.0
			+4.0*z[j*steps+1]-3.0*z[j*steps];
		z[j*steps+2]=(p[j]+qq)/2.0;
		y[j]=z[j*steps+2];
	}
	for (i=3; i<steps; i++)	{ 
		t=t0+(i-1)*lens;
		(*ap->ptr)(t,y,n,d);
		for (j=0; j<=n-1; j++)	{ 
			u[j]=v[j]; v[j]=d[j];
		}
		for (j=0; j<n; j++){ 
			qq=-4.0*z[j*steps+i-1]+5.0*z[j*steps+i-2];
			p[j]=qq+2.0*lens*(2.0*v[j]+u[j]);
			y[j]=p[j];
		}
		t+=lens;
		(*ap->ptr)(t,y,n,d);
		for (j=0; j<n; j++){ 
			qq=2.0*lens*(d[j]-2.0*v[j]-2.0*u[j])/3.0
				+4.0*z[j*steps+i-1]-3.0*z[j*steps+i-2];
			y[j]=(p[j]+qq)/2.0;
			z[j*steps+i]=y[j];
		}
	}
	/*释放动态分配的内存*/
	free(d); free(p); free(u); free(v); free(w);
	return;
}

void bilateral_ptr(double t,double y[],int n,double d[])
{ 
	t=t; n=n;
	d[0]=-2.0*y[1]; d[1]=2.0*y[0];
	return;
}

main()
{ 
	double y[2]={0.0, 1.0};
	double z[2][11]={0};
	FODE2  fa={2, 11, 0.1, 0.00001, 0.1, y, (double*)z, bilateral_ptr};
	int    i;

	bilateral(&fa);
	printf("\n");
	for (i=0; i<fa.steps; i++)
		printf("t=%7.3f  y(0)=%e  y(1)=%e\n", i*fa.lens,z[0][i],z[1][i]);
	printf("\n");
}
