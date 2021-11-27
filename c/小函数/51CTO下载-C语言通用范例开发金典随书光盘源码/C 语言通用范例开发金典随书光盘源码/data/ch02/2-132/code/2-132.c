#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "ode.h"

void continued_method(int n,double t,double lens,double y[],double b[],double d[],double e[],void (*ptr)())
{
	int    i,k;
	double a[4],tt;

	a[1]=a[0]=lens/2.0;  a[3]=a[2]=lens;
	(*ptr)(y,d);
	for (i=0; i<n; i++) { 
		b[i]=y[i]; 
		e[i]=y[i];
	}
	for (k=0; k<3; k++)	{ 
		for (i=0; i<n; i++)	{ 
			y[i]=e[i]+a[k]*d[i];
			b[i]+=a[k+1]*d[i]/3.0;
		}
		tt=t+a[k];
		(*ptr)(y,d);
	}
	for (i=0; i<n; i++)
		y[i]=b[i]+lens*d[i]/6.0;
	return;
}

void continued_step(EODEP ap)
{
	int    n,i,j,k,m,nn;
	double lens,eps,t,x,hh,dd,q,p,g[10];
	double *y,*b,*d,*u,*v,*w,*e;

	n=ap->n;
	b=malloc(10*n*sizeof(double));
	d=malloc(n*sizeof(double));
	u=malloc(n*sizeof(double));
	v=malloc(n*sizeof(double));
	w=malloc(n*sizeof(double));
	e=malloc(n*sizeof(double));
	lens=ap->lens; eps=ap->lens; 
	t=ap->t; y=ap->y;
	for (j=0; j<n; j++) v[j]=y[j];
	x=t; nn=1; g[0]=hh=lens;
	continued_method(n,x,hh,y,w,d,e,ap->ptr);
	for (j=0; j<n; j++){ 
		b[j]=y[j]; u[j]=y[j];
	}
	k=1; 
	do { 
		nn<<=1; hh/=2.0; 
		g[k]=hh;
		for (j=0; j<n; j++) y[j]=v[j];
		t=x;
		for (j=0; j<nn; j++)	{ 
			continued_method(n,t,hh,y,w,d,e,ap->ptr);
			t+=hh;
		}
		for (j=0; j<n; j++) { 
			dd=y[j]; m=0;
			for (i=0; i<k; i++)
			if (m==0) { 
				q=dd-b[i*n+j];
				if (fabs(q)+1.0==1.0) m=1;
				else dd=(g[k]-g[i])/q;
			}
			b[k*n+j]=dd;
			if (m!=0) b[k*n+j]=1.0e+35;
		}
		for (j=0; j<n; j++){ 
			dd=0.0;
			for (i=k-1; i>=0; i--)
				dd=-g[i]/(b[(i+1)*n+j]+dd);
			y[j]=dd+b[j];
		}
		p=0.0;
		for (j=0; j<n; j++){ 
			q=fabs(y[j]-u[j]);
			if (q>p) p=q;
		}
		if ((p>=eps)&&(k<7)){ 
			for (j=0; j<=n-1; j++) 
				u[j]=y[j];
			k++; 
		}
	} while ((p>=eps)&&(k<7));
	/*释放动态分配的内存*/
	free(b); free(d); free(u); free(v); free(w); free(e);
	return;
}

void step_ptr(double y[],double d[])
{
	d[0]=-2.0*y[1]; 
	d[1]=2.0*y[0];
}

main()
{ 
	double y[2]={0.0, 1.0};
	EODE   ea = {2, 0.1, 0.000001, 0.0, y, step_ptr};
	int i;

	for (i=0; i<11; i++) { 
		printf("\nt=%7.3f  y(0)=%e  y(1)=%e",ea.t,y[0],y[1]);
		continued_step(&ea);
		ea.t += ea.lens;
	}
	printf("\n");
}
