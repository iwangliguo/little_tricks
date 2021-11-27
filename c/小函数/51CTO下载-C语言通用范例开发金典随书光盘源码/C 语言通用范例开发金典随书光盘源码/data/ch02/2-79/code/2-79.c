#include "stdio.h"
#include "math.h"
#include "stdlib.h"
#include "matrix.h"

void matrix_mul(double a[],double b[],int m,int n,int k,double c[])
{ 
	int i,j,l,u;
	for (i=0; i<=m-1; i++)
		for (j=0; j<=k-1; j++){ 
			u=i*k+j; c[u]=0.0;
			for (l=0; l<=n-1; l++)
				c[u]=c[u]+a[i*n+l]*b[l*k+j];
		}
}

void conjugate_gradient_method(RMP ap, RMP bp, RMP xp, double eps)
{ 
	int    i,k,n;
	double *a,*b,*x,*p,*r,*s,*q,alpha,beta,d,e;

	n=ap->row;
	a=ap->data;
	b=bp->data;
	x=xp->data;
	p=malloc(n*sizeof(double));
	r=malloc(n*sizeof(double));
	s=malloc(n*sizeof(double));
	q=malloc(n*sizeof(double));
	for (i=0; i<n; i++) { 
		x[i]=0.0; p[i]=r[i]=b[i]; 
	}
	for (i=0; i<n; i++) { 
		matrix_mul(a,p,n,n,1,s);	
		d=0.0; e=0.0;	
		for (k=0; k<n; k++) { 
			d+=p[k]*b[k]; e+=p[k]*s[k]; 
		}	
		alpha=d/e;	
		for (k=0; k<n; k++)	
			x[k]+=alpha*p[k];	

		matrix_mul(a,x,n,n,1,q);	
		d=0.0;	
		for (k=0; k<n; k++)	{ 
			r[k]=b[k]-q[k]; d+=r[k]*s[k]; 
		}	
		beta=d/e; d=0.0;	
		for (k=0; k<n; k++) 
			d+=r[k]*r[k];	
		d=sqrt(d);	
		if (d<eps) { 
			break;
		}	
		for (k=0; k<n; k++)	
			p[k]=r[k]-beta*p[k];
	}
	free(p); free(r); free(s); free(q);/* 释放动态分配的内存 */
	return;
}

void printx(RMP bp) {
	int i,j;
	for(i=0; i<bp->row; i++) {
		printf("x(%d)=", i);
		for(j=0; j<bp->col; j++) {
			printf("%13.7e", bp->data[i*bp->col + j]);
			if(j<bp->col-1) printf(",  ");
		}
		printf("\n");
	}
}  

main()
{
	double a[3][3]={{2.0,2.0,-2.0},
					{2.0,5.0,-4.0},
					{-2.0,-4.0,5.0}};
	static double b[3]={12.0,9.0,15.0};
	double x[3];
	double eps=0.000001;
	RM ma = {3, 3, (double*)a};
	RM mb = {3, 1, (double*)b};
	RM mx = {3, 1, (double*)x};

	conjugate_gradient_method(&ma, &mb, &mx, eps);
	printx(&mx);
}
