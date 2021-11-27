#include "stdio.h"
#include "stdlib.h"
#include "math.h"
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

int gauss_elimination(RMP ap, RMP bp)  
{ 
	int    *js,n,k,i,j,is,p,q;
	double d,t,*a,*b;

	n=ap->row;
	a=ap->data;
	b=bp->data;
	js=malloc(n*sizeof(int));
	for (k=0;k<n-1;k++) { 
		d=0.0;
		for (i=k;i<n;i++)
			for (j=k;j<n;j++) { 
				t=fabs(a[i*n+j]);
				if (t>d) { d=t; js[k]=j; is=i;}
			}
		if (fabs(d)<0.0000001) { 
			free(js); printf("fail\n");
			return -1;
		}
		else { 
			if (js[k]!=k)
				for (i=0;i<n;i++) { 
					p=i*n+k; q=i*n+js[k];
					t=a[p]; a[p]=a[q]; a[q]=t;
				}	
			if (is!=k)	{ 
				for (j=k;j<n;j++){ 
					p=k*n+j; q=is*n+j;
					t=a[p]; a[p]=a[q]; a[q]=t;
				}
				t=b[k]; b[k]=b[is]; b[is]=t;
			}
		}
		d=a[k*n+k];
		for (j=k+1;j<n;j++)	{ 
			p=k*n+j; a[p]/=d;
		}
		b[k]/=d;
		for (i=k+1;i<n;i++)	{ 
			for (j=k+1;j<n;j++)	{ 
				p=i*n+j;
				a[p]-=a[i*n+k]*a[k*n+j];
			}
			b[i]-=a[i*n+k]*b[k];
		}
	}
	d=a[(n-1)*n+n-1];
	if (fabs(d)<0.0000001)	{ 
		free(js); printf("fail\n");
		return -2;
	}
	b[n-1]/=d;
	for (i=n-2;i>=0;i--){ 
		t=0.0;	
		for (j=i+1;j<n;j++)
			t+=a[i*n+j]*b[j];
		b[i]-=t;
	}
	js[n-1]=n-1;
	for (k=n-1;k>=0;k--)
		if (js[k]!=k){ 
			t=b[k]; b[k]=b[js[k]]; b[js[k]]=t;
		}
	free(js); /*释放动态分配的内存*/
	return 0;
}

int morbid_equations(RMP ap, RMP bp, RMP xp, double eps)
{ 
	int i,j,k,n;
	double *a,*b,*w,*p,*r,*e,q,qq;
	RM     mp,mr;

	n=ap->row;
	a=ap->data;
	b=bp->data;
	w=xp->data;
	p=malloc(n*n*sizeof(double));
	r=malloc(n*sizeof(double));
	e=malloc(n*sizeof(double));
	mp.row = n;	mp.col = 1;	mp.data = p;
	mr.row = n; mr.col = 1; mr.data = r;
	i=60; /*指定最大迭代次数*/
	for (k=0; k<n; k++)
		for (j=0; j<n; j++)
			p[k*n+j]=a[k*n+j];
	for (k=0; k<n; k++) w[k]=b[k];
	if (gauss_elimination(&mp, xp) < 0)  { 
		free(p); free(r); free(e); 
		return -1; 
	}
	do { 
		if (i==0) { 
			free(p); free(r); free(e); 
			return -2; 
		}
		i--;
		matrix_mul(a,w,n,n,1,e);
		for ( k=0; k<n; k++) 
			r[k]=b[k]-e[k];
		for ( k=0; k<n; k++)
			for ( j=0; j<n; j++)
				p[k*n+j]=a[k*n+j];
		if (gauss_elimination(&mp,&mr)) { 
			free(p); free(r); free(e); 
			return -3; 	
		}	
		q=0.0;
		for ( k=0; k<n; k++)	{ 
			qq=fabs(r[k])/(1.0+fabs(w[k]+r[k]));
			if (qq>q) 			
				q=qq;
		}
		for ( k=0; k<n; k++) 
			w[k]+=r[k];
	} while (q>=eps);
	free(p); free(r); free(e); /* 释放动态分配的内存 */
	return 0;
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
	double a[4][4]={{10.0,7.0,8.0,7.0},
					{7.0,5.0,6.0,5.0},
					{8.0,6.0,10.0,9.0},
					{7.0,5.0,9.0,10.0}};
	double b[4]={32.0,23.0,33.0,31.0};
	double w[4];
	double eps=0.000001;
	RM  ma = {4, 4, (double*)a};
	RM  mb = {4, 1, (double*)b};
	RM  mx = {4, 1, (double*)w};

	if (morbid_equations(&ma, &mb, &mx,eps)==0)	{ 
		printx(&mx);
	}
}
