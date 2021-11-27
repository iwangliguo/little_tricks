#include "stdio.h"
#include "math.h"
#include "matrix.h"

int triangular_decomposition(RMP ap, RMP bp,RMP cp)
{ 
	int n,i,j,k,w,v,ll;
	double *a, *b, *c;
	n = ap->row;
	bp->row = bp->col = n;
	cp->row = cp->col = n;
	a = ap->data; b = bp->data; c = cp->data;
	for (k=0; k<n-1; k++) { 
		ll=k*n+k;	
		if (fabs(a[ll])<0.0000001) { 
			printf("fail\n"); 
			return -1;
		}
		for (i=k+1; i<n; i++) { 
			w=i*n+k; a[w]/=a[ll];
		}	
		for (i=k+1; i<n; i++) { 
			w=i*n+k; 
			for (j=k+1; j<n; j++) { 
				v=i*n+j;
				a[v]-=a[w]*a[k*n+j];
			}
		}
	}
	for (i=0; i<n; i++) { 
		for (j=0; j<i; j++) { 
			w=i*n+j; b[w]=a[w]; c[w]=0.0;
		}	
		w=i*n+i;	
		b[w]=1.0; c[w]=a[w];
		for (j=i+1; j<n; j++) { 
			w=i*n+j; b[w]=0.0; c[w]=a[w];
		}
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
	double a[4][4]={{1.0,0.0,2.0,3.0},
					{1.0,1.0,6.0,8.0},
					{0.0,0.0,-1.0,0.0},
					{1.0,0.0,2.0,4.0}};
	double b[4][4],c[4][4];
	RM ma = {4, 4, (double*)a};
	RM mb = {0, 0, (double*)b};
	RM mc = {0, 0, (double*)c};

	if (0 == triangular_decomposition(&ma,&mb,&mc))	{ 
		printrm("\nMatrix L Is:\n", &mb);
		printrm("\nMatrix U Is:\n", &mc);
	}
}

