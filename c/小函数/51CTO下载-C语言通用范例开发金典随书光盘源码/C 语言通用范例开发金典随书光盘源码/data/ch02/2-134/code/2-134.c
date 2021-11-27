#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "ode.h"

void adams_method(int n,double eps,double t,double lens,double y[],void (*ptr)())
{ 
	int    m,i,j,k;
	double hh,p,dt,x,tt,q,a[4],*g,*b,*c,*d,*e;
	g=malloc(n*sizeof(double));
	b=malloc(n*sizeof(double));
	c=malloc(n*sizeof(double));
	d=malloc(n*sizeof(double));
	e=malloc(n*sizeof(double));
	hh=lens; m=1; x=t;
	for (i=0; i<n; i++) {
		c[i]=y[i];
	}
	do { 
		a[1]=a[0]=hh/2.0; a[3]=a[2]=hh;
		for (i=0; i<n; i++)	{ 
			g[i]=y[i]; y[i]=c[i];
		}
		dt=lens/m; t=x;
		for (j=0; j<m; j++) { 
			(*ptr)(t,y,n,d);
			for (i=0; i<n; i++)	{ 
				b[i]=y[i]; e[i]=y[i];
			}
			for (k=0; k<=2; k++){ 
				for (i=0; i<n; i++)	{ 
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
	} while (p>=eps) ;
	/*释放动态分配的内存*/
	free(g); free(b); free(c); free(d); free(e);
	return;
}

void adams(FODE2P ap)
{
	int    n,steps,i,j,m;
	double lens,eps,t,t0,q;
	double *b,*e,*s,*g,*d,*y,*z;

	n=ap->n; steps=ap->steps;
	b=malloc(4*n*sizeof(double));
	e=malloc(n*sizeof(double));
	s=malloc(n*sizeof(double));
	g=malloc(n*sizeof(double));
	d=malloc(n*sizeof(double));
	lens=ap->lens; eps=ap->eps;
	y=ap->y; z=ap->z;
	t0=t=ap->t;
	for (i=0; i<n; i++) 
		z[i*steps]=y[i];
	(*ap->ptr)(t,y,n,d);
	for (i=0; i<n; i++) 
		b[i]=d[i];
	for (i=1; i<4; i++)
		if (i<steps)	{ 
			t=t0+i*lens;
			adams_method(n,eps,t,lens,y,ap->ptr);
			for (j=0; j<n; j++) z[j*steps+i]=y[j];
			(*ap->ptr)(t,y,n,d);
			for (j=0; j<n; j++) b[i*n+j]=d[j];
		}
	for (i=4; i<steps; i++)	{ 
		for (j=0; j<n; j++){ 
			q=55.0*b[3*n+j]-59.0*b[2*n+j];
			q=q+37.0*b[n+j]-9.0*b[j];
			y[j]=z[j*steps+i-1]+lens*q/24.0;
			b[j]=b[n+j];
			b[n+j]=b[2*n+j];
			b[2*n+j]=b[3*n+j];
		}
		t=t0+i*lens;
		(*ap->ptr)(t,y,n,d);
		for (m=0; m<n; m++) 
			b[3*n+m]=d[m];
		for (j=0; j<n; j++){ 
			q=9.0*b[3*n+j]+19.0*b[n+n+j]-5.0*b[n+j]+b[j];
			y[j]=z[j*steps+i-1]+lens*q/24.0;
			z[j*steps+i]=y[j];
		}
		(*ap->ptr)(t,y,n,d);
		for (m=0; m<n; m++) b[3*n+m]=d[m];
	}
	/*释放动态分配的内存*/
	free(b); free(e); free(s); free(g); free(d);
	return;
}

void adams_ptr(double t,double y[],int n,double d[])
{ 
	t=t; n=n;
	d[0]=2.0*y[1]; d[1]=-2.0*y[0]; d[2]=-2.0*y[2];
	return;
}

main()
{ 
	double y[3] = {0.0, 1.0, 2.0};
	double z[3][11]={0};
	FODE2  fa = {3, 11, 0.1, 0.0001, 0.0, y, (double*)z, adams_ptr};
	int i,j;

	adams(&fa);
	printf("\n");
	for (i=0; i<11; i++){ 
		printf("t=%7.3f\n",i*fa.lens);
		for (j=0; j<3; j++)
			printf("y(%d)=%e  ",j,z[j][i]);
		printf("\n");
	}
	printf("\n");
}
