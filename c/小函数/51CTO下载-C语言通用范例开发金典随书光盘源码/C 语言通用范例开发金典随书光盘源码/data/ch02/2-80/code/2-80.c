#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "matrix.h"

int qr_decomposition(RMP ap, RMP qp)
{ 
	int i,j,k,l,m,n,nn,p,jj;
	double u,alpha,w,t;
	double *a, *q;
	
	m = ap->row;
	n = ap->col;
	if (m<n) { 
		printf("fail\n"); 
		return -1;
	}
	qp->row = qp->col = ap->row;
	a = ap->data;
	q = qp->data;
	for (i=0; i<m; i++)	
		for (j=0; j<m; j++) { 
			l=i*m+j; q[l]=0.0;	
			if (i==j) q[l]=1.0;	
		}	
	nn=n;	
	if (m==n) nn=m-1;	
	for (k=0; k<nn; k++)	{ 
		u=0.0; l=k*n+k;	
		for (i=k; i<m; i++)	{ 
			w=fabs(a[i*n+k]);	
			if (w>u) u=w;	
		}	
		alpha=0.0;	
		for (i=k; i<m; i++)	{ 
			t=a[i*n+k]/u; alpha+=t*t;
		}	
		if (a[l]>0.0) u=-u;	
		alpha=u*sqrt(alpha);	
		if (fabs(alpha)<0.0000001)	{ 
			printf("fail\n"); 
			return -2;
		}	
		u=sqrt(2.0*alpha*(alpha-a[l]));	
		if ((u+1.0)!=1.0) { 
			a[l]=(a[l]-alpha)/u;	
			for (i=k+1; i<m; i++) { 
				p=i*n+k; a[p]=a[p]/u;
			}
			for (j=0; j<m; j++) { 
				t=0.0;	
				for (jj=k; jj<m; jj++) 
					t+=a[jj*n+k]*q[jj*m+j];
				for (i=k; i<m; i++) { 
					p=i*m+j; 
					q[p]-=2.0*t*a[i*n+k];
				}
			}
			for (j=k+1; j<n; j++) { 
				t=0.0;	
				for (jj=k; jj<m; jj++)	
					t+=a[jj*n+k]*a[jj*n+j];	
				for (i=k; i<m; i++)	{ 
					p=i*n+j; 
					a[p]-=2.0*t*a[i*n+k];
				}
			}	
			a[l]=alpha;	
			for (i=k+1; i<m; i++)	
				a[i*n+k]=0.0;
		}
	}
	for (i=0; i<m-1; i++)	
		for (j=i+1; j<m;j++)	{ 
			p=i*m+j; l=j*m+i;	
			t=q[p]; q[p]=q[l]; q[l]=t;	
		}
	return 0;
}

int least_square_householder(RMP ap, RMP bp, RMP qp)
{ 
	int    m,n,i,j;
	double *a,*b,*q,*c,d;

	m=ap->row;
	n=ap->col;
	a=ap->data;
	b=bp->data;
	q=qp->data;
	c=malloc(n*sizeof(double));
	if (qr_decomposition(ap,qp) <0) { 
		free(c); 
		return -1;
	}
	for (i=0; i<n; i++) { 
		d=0.0;	
		for (j=0; j<m; j++)	
			d+=q[j*m+i]*b[j];	
		c[i]=d;
	}
	b[n-1]=c[n-1]/a[n*n-1];
	for (i=n-2; i>=0; i--)	{ 
		d=0.0;	
		for (j=i+1; j<n; j++)	
			d+=a[i*n+j]*b[j];	
		b[i]=(c[i]-d)/a[i*n+i];
	}
	free(c); /* 释放动态分配的内存 */
	return 0;
}

void printrm(char *title, RMP vp) 
{
	int i, j;

	printf(title);
	for(i=0; i<vp->row; i++) {    
		for(j=0; j<vp->col; j++)
			printf("%13.7e ", vp->data[i*vp->col + j]);
		printf("\n");
	}
}

main()
{ 
	double a[12][3]={   {1.24,1.27,1.0},{1.36,1.74,1.0},{1.38,1.64,1.0},{1.38,1.82,1.0},
						{1.38,1.90,1.0},{1.40,1.70,1.0},{1.48,1.82,1.0},{1.54,1.82,1.0},
						{1.56,2.08,1.0},{1.14,1.78,1.0},{1.18,1.96,1.0},{1.20,1.86,1.0}};
	double b[12]={1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,-1.0,-1.0,-1.0};
	double q[12][12];
	RM ma = {12, 3, (double*)a};
	RM mb = {12, 1, (double*)b};
	RM mq = {0, 0, (double*)q};
	int i;

	if (least_square_householder(&ma,&mb,&mq)==0) { 
		for (i=0; i<=2; i++)	
			printf("x(%d)=%13.7e\n",i,b[i]);	
		
		/*printrm("\nMatrix Q Is:\n", &mq);*/
		printf("\nMatrix Q Is:\n");
		for (i=0; i<=11; i++)
			printf("%13.7e %13.7e %13.7e %13.7e\n",	q[i][0],q[i][1],q[i][2],q[i][3]);
		printf("\n");

		printrm("\nMatrix R Is:\n", &ma);	
	}
}
