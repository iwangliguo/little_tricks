#include "stdio.h"
#include "math.h"
#include "matrix.h"

int determinant_rank(RMP ap)
{ 
	int    i,j,k,m,n,nn,is,js,l,ll,u,v;
	double q,d;
	double *a = ap->data;
	m = ap->row;
	n = ap->col;
	nn=	(m<=n) ? m:n;	
	k=0;
	for (l=0; l<nn; l++)	{ 
		q=0.0;	
		for (i=l; i<m; i++)	
			for (j=l; j<n; j++)	{ 
				ll=i*n+j; d=fabs(a[ll]);	
				if (d>q) { q=d; is=i; js=j;}	
			}	
			if (fabs(q) < 0.0000001) return k;	
			k=k+1;	
			if (is!=l)	{ 
				for (j=l; j<n; j++)	{ 
					u=l*n+j; v=is*n+j;	
					d=a[u]; a[u]=a[v]; a[v]=d;	
				}	
			}	
			if (js!=l)	{ 
				for (i=l; i<m; i++)	{ 
					u=i*n+js; v=i*n+l;	
					d=a[u]; a[u]=a[v]; a[v]=d;	
				}	
			}	
			ll=l*n+l;	
			for (i=l+1; i<m; i++) {	
				d=a[i*n+l]/a[ll];	
				for (j=l+1; j<n; j++) { 
					u=i*n+j;	
					a[u] -= d*a[l*n+j];	
				}	
			}	
	}
	return k;
}

main()
{  
	double a[3][5]={{7.0,2.0,1.0,0.0,1.0},
					{0.0,0.0,1.0,0.0,1.0},
					{0.0,0.0,0.0,0.0,5.0}};
	RM     ma = {3, 5, (double*)a}; 

	printf("\ndeterminant rank=%d\n\n",determinant_rank(&ma));
}
