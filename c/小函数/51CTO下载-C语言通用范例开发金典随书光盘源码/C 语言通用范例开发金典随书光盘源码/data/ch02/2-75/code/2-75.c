#include "stdio.h"
#include "math.h"
#include "matrix.h"

int equations_square_root(RMP ap, RMP bp)
{ 
	int    i,j,m,n,k,u,v;
	double *a,*d;

	n=ap->row;
	m=bp->col;
	a=ap->data; 
	d=bp->data;
	if (a[0]<0.0000001) { 
		printf("fail\n"); return -1;
	}
	a[0]=sqrt(a[0]);
	for (j=1; j<n; j++) 
		a[j]/=a[0];
	for (i=1; i<n; i++)	{ 
		u=i*n+i;
		for (j=1; j<=i; j++){ 
			v=(j-1)*n+i;
			a[u]-=a[v]*a[v];
		}
		if (a[u]<0.0000001) { 
			printf("fail\n"); return -2;
		}
		a[u]=sqrt(a[u]);
		if (i!=(n-1)){ 
			for (j=i+1; j<n; j++){ 
				v=i*n+j;
				for (k=1; k<=i; k++)
					a[v]-=a[(k-1)*n+i]*a[(k-1)*n+j];
				a[v]/=a[u];
			}
		}
	}
	for (j=0; j<m; j++)	{ 
		d[j]/=a[0];
		for (i=1; i<n; i++)	{ 
			u=i*n+i; v=i*m+j;
			for (k=1; k<=i; k++)
				d[v]-=a[(k-1)*n+i]*d[(k-1)*m+j];
			d[v]/=a[u];
		}
	}
	for (j=0; j<m; j++)	{ 
		u=(n-1)*m+j;
		d[u]/=a[n*n-1];
		for (k=n-1; k>0; k--)	{ 
			u=(k-1)*m+j;
			for (i=k; i<n; i++)	{ 
				v=(k-1)*n+i;
				d[u]-=a[v]*d[i*m+j];
			}
			v=(k-1)*n+k-1;
			d[u]/=a[v];
		}
	}
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
	double a[3][3]={{2.0,2.0,-2.0},
					{2.0,5.0,-4.0},
					{-2.0,-4.0,5.0}};
	double b[3][2]={{12.0,2.0},
					{15.0,36.0},
					{25.0,8.0}};
	RM ma = {3, 3, (double*)a};
	RM mb = {3, 2, (double*)b};

	if (0 == equations_square_root(&ma, &mb)) {
		printx(&mb);
	}
}
