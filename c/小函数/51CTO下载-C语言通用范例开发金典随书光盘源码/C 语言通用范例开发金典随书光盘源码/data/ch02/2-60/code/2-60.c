#include "stdio.h"
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
	double a[4][3]={{2.0,1.0,-2.0},
					{2.0,2.0,-3.0},
					{-8.0,-1.0,4.0},
					{-2.0,-1.0,2.0}};
	double q[4][4];
	RM  ma = {4, 3, (double*)a};
	RM  mq = {0, 0, (double*)q};

	if (0 == qr_decomposition(&ma, &mq)) { 
		printrm("\nMatrix  Q Is:\n", &mq);
		printrm("\nMatrix  R Is:\n", &ma);
	}
}
