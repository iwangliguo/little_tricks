#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "matrix.h"

int sparse_gauss_jordan(RMP ap, RMP bp)
{
	int    *js,n,i,j,k,is,u,v;
	double *a,*b,d,t;

	n=bp->row;
	a=ap->data;
	b=bp->data;
	js=malloc(n*sizeof(int));
	for (k=0; k<n; k++)	{ 
		d=0.0;
		for (i=k; i<n; i++)
			for (j=k; j<n; j++)	{ 
				t=fabs(a[i*n+j]);
				if (t>d) {
					d=t; js[k]=j; is=i;
				}
			}
		if (fabs(d)<0.0000001)		{ 
			free(js); printf("fail\n"); return -1;
		}
		if (is!=k)	{ 
			for (j=k; j<n; j++)	{ 
				u=k*n+j; v=is*n+j;
				t=a[u]; a[u]=a[v]; a[v]=t;
			}
			t=b[k]; b[k]=b[is]; b[is]=t;
		}
		if (js[k]!=k)
			for (i=0; i<n; i++)	{ 
				u=i*n+k; v=i*n+js[k];
				t=a[u]; a[u]=a[v]; a[v]=t;
			}
		t=a[k*n+k];
		for (j=k+1; j<n; j++)	{ 
			u=k*n+j;
			if (a[u]!=0.0) a[u]/=t;
		}
		b[k]/=t;
		for (j=k+1; j<n; j++)	{ 
			u=k*n+j;
			if (a[u]!=0.0)	{ 
				for (i=0; i<n; i++)	{ 
					v=i*n+k;
					if ((i!=k)&&(a[v]!=0.0)) { 
						is=i*n+j;
						a[is]-=a[v]*a[u];
					}
				}
			}
		}
		for (i=0; i<n; i++)	{ 
			u=i*n+k;
			if ((i!=k)&&(a[u]!=0.0))
				b[i]-=a[u]*b[k];
		}
	}
	for (k=n-1; k>=0; k--)
		if (k!=js[k])	{ 
			t=b[k]; b[k]=b[js[k]]; b[js[k]]=t;
		}
	free(js); /* 释放动态分配的内存 */
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
	double a[8][8]={{4.0,0.0,0.0,0.0,5.0,0.0,0.0,0.0},
					{0.0,7.0,0.0,0.0,0.0,8.0,0.0,0.0},
					{0.0,0.0,2.0,0.0,0.0,0.0,3.0,0.0},
					{0.0,0.0,0.0,9.0,0.0,0.0,0.0,10.0},
					{0.0,0.0,0.0,12.0,11.0,0.0,0.0,0.0},
					{1.0,0.0,14.0,0.0,0.0,0.13,0.0,0.0},
					{0.0,16.0,0.0,0.0,0.0,0.0,0.0,15.0},
					{6.0,0.0,0.0,0.0,0.0,8.0,0.0,0.0}};
	double b[8]={5.0,6.0,7.0,8.0,9.0,10.0,4.0,3.0};
	RM ma = {8, 8, (double*)a};
	RM mb = {8, 1, (double*)b};

	if (sparse_gauss_jordan(&ma,&mb)==0) {
		printx(&mb);
	}
}
