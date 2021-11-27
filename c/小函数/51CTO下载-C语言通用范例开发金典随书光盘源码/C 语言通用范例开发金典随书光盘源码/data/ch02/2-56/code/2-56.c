#include "stdio.h"
#include "math.h"
#include "matrix.h"

double determinant_value(RMP ap)
{ 
	int i,j,k,is,js,l,n,u,v;
	double f,det,q,d;
	double *a = ap->data;
	n = ap->row;
	f=1.0; det=1.0;
	for (k=0; k<n-1; k++)	{ 
		q=0.0;
		for (i=k; i<n; i++)
			for (j=k; j<n; j++)	{ 
				l=i*n+j; d=fabs(a[l]);	
				if (d>q) { q=d; is=i; js=j;}	
			}
		if (fabs(q) < 0.0000001)	{ 
			return 0.0; 
		}
		if (is!=k) 	{ 
			f=-f;	
			for (j=k; j<n; j++)	{ 
				u=k*n+j; v=is*n+j;	
				d=a[u]; a[u]=a[v]; a[v]=d;	
			}
		}
		if (js!=k)	{ 
			f=-f;	
			for (i=k; i<n; i++)	{ 
				u=i*n+js; v=i*n+k;	
				d=a[u]; a[u]=a[v]; a[v]=d;	
			}
		}
		l=k*n+k;
		det=det*a[l];
		for (i=k+1; i<n; i++) { 
			d=a[i*n+k]/a[l];	
			for (j=k+1; j<n; j++) { 
				u=i*n+j;	
				a[u]=a[u]-d*a[k*n+j];	
			}	
		}
	}
	return f*det*a[n*n-1];
}
  
main() { 
	double a[3][3] = {  {1.0,2.0,2.0},
						{2.0,1.0,-2.0},
						{2.0,-2.0,1.0}};
	double b[4][4] = {  {1.0,0.0,2.0,3.0},
						{1.0,1.0,6.0,8.0},
						{0.0,0.0,-1.0,0.0},
						{1.0,0.0,2.0,4.0}};
	RM ma = {3, 3, (double*)a};
	RM mb = {4, 4, (double*)b};
	
	double det;
	det=determinant_value(&ma);
	printf("det(A)=%13.7e\n",det);
	printf("\n");
	det=determinant_value(&mb);
	printf("det(B)=%13.7e\n",det);
	printf("\n");
}
