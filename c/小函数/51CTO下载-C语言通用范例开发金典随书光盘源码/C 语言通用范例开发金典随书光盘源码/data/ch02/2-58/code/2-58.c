#include "stdio.h"
#include "math.h"
#include "matrix.h"
  
int cholesky_method(RMP ap,double *det)
{ 
	int i,j,k,u,l,n;
	double d,*a;
	
	n = ap->row;
	a = ap->data;
	if ( a[0]<0.0000001 ) { 
		printf("fail\n");
		return -1;
	}
	a[0]=sqrt(a[0]);
	d=a[0];
	for (i=1; i<n; i++) { 
		u=i*n; a[u]=a[u]/a[0];
	}
	for (j=1; j<n; j++)	{ 
		l=j*n+j;	
		for (k=0; k<j; k++)	{ 
			u=j*n+k; a[l]-=a[u]*a[u];
		}	
		if (a[l]<0.0000001) { 
			printf("fail\n"); 
			return -2;
		}
		a[l]=sqrt(a[l]);
		d=d*a[l];
		for (i=j+1; i<n; i++) { 
			u=i*n+j;	
			for (k=0; k<j; k++)	
				a[u]=a[u]-a[i*n+k]*a[j*n+k];	
			a[u]/=a[l];	
		}
	}
	*det=d*d;
	for (i=0; i<=n-2; i++)	
		for (j=i+1; j<=n-1; j++)	
			a[i*n+j]=0.0;
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
	double det;
	double a[3][3]={{2.0,2.0,-2.0},
					{2.0,5.0,-4.0},
					{-2.0,-4.0,5.0}};
	RM ma = {3, 3, (double*)a};

	if (0 == cholesky_method(&ma, &det))	{ 
		printrm("Matrix L Is:\n", &ma);
		printf("\ndet(A)=%13.7e\n",det);
	}
}
