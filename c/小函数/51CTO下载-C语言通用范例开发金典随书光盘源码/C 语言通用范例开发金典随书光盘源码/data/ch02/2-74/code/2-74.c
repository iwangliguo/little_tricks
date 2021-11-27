#include "stdio.h"
#include "math.h"
#include "matrix.h"

int equations_decomposition(RMP ap, RMP bp) 
{ 
	int    i,j,l,m,n,k,u,v,w,k1,k2,k3;
	double p,*a,*b;
	n = bp->row;
	m = bp->col;
	a = ap->data;
	b = bp->data;
	if (fabs(a[0])<0.0000001){ 
		printf("fail\n"); return -1;
	}
	for (i=1; i<n; i++)	{ 
		u=i*n; a[u]/=a[0];
	}
	for (i=1; i<n-1; i++)	{ 
		u=i*n+i;	
		for (j=1; j<=i; j++)	{ 
			v=i*n+j-1; l=(j-1)*n+j-1;	
			a[u]-=a[v]*a[v]*a[l];
		}	
		p=a[u];	
		if (fabs(p)<0.0000001) { 
			printf("fail\n"); return -2;
		}	
		for (k=i+1; k<n; k++)	{ 
			u=k*n+i;	
			for (j=1; j<=i; j++) { 
				v=k*n+j-1; l=i*n+j-1; w=(j-1)*n+j-1;
				a[u]-=a[v]*a[l]*a[w];
			}
			a[u]/=p;
		}
	}
	u=n*n-1;
	for (j=1; j<n; j++)	{ 
		v=(n-1)*n+j-1; w=(j-1)*n+j-1;
		a[u]-=a[v]*a[v]*a[w];
	}
	p=a[u];
	if (fabs(p)<0.0000001)	{ 
		printf("fail\n"); return -3;
	}
	for (j=0; j<m; j++)	
		for (i=1; i<n; i++)	{ 
			u=i*m+j;	
			for (k=1; k<=i; k++) { 
				v=i*n+k-1; w=(k-1)*m+j;
				b[u]-=a[v]*b[w];
			}
		}
	for (i=1; i<n; i++)	{ 
		u=(i-1)*n+i-1;
		for (j=i; j<=n-1; j++)	{ 
			v=(i-1)*n+j; w=j*n+i-1;
			a[v]=a[u]*a[w];
		}
	}
	for (j=0; j<m; j++)	{ 
		u=(n-1)*m+j;
		b[u]/=p;
		for (k=1; k<n; k++)		{ 
			k1=n-k; k3=k1-1; u=k3*m+j;
			for (k2=k1; k2<n; k2++)	{ 
				v=k3*n+k2; w=k2*m+j;
				b[u]-=a[v]*b[w];
			}
			b[u]/=a[k3*n+k3];
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
	double a[5][5]={{1.0,2.0,3.0,4.0,5.0},
					{2.0,6.0,7.0,8.0,9.0},
					{3.0,7.0,10.0,11.0,12.0},
					{4.0,8.0,11.0,13.0,14.0},
					{5.0,9.0,12.0,14.0,15.0}};
	double b[5][2]={{34.0,52.0},
					{62.0,85.0},
					{23.0,96.0},
					{65.0,48.0},
					{27.0,102.0}};
	RM ma = {5, 5, (double*)a};
	RM mb = {5, 2, (double*)b};
	if (0 == equations_decomposition(&ma,&mb)) {
		printx(&mb);
	}
}
