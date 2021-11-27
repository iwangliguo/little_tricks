#include "math.h"
#include "stdio.h"

void  quickfwt(double p[], int n, int k,double value[])
{ 
	int    m,l,it,i,j,is;
	double t;
	
	m=1; l=n; it=2;
	value[0]=1; 
	value[n>>1]=2;
	for (i=1; i<k; i++){ 
		m<<=1; l>>=1; it<<=1;
		for (j=0; j<m; j++)
			value[j*l+l/2]=it+1-value[j*l];
	}
	for (i=0; i<n; i++)
		value[i]=p[(int)(value[i]-1)];
	for (i=l=1; i<=k; i++,l<<=1){ 
		m=n/(2*l)-1;
		for (j=0; j<=m; j++){ 
			it=2*l*j;
			for (is=0; is<l; is++){ 
				t=value[it+is]-value[it+is+l];
				value[it+is]=value[it+is]+value[it+is+l];
				value[it+is+l]=t;
			}
		}
	}
}

main()
{ 
	int i;
	double p[8],value[8];

	for (i=0; i<8; i++) p[i]=i+1;
	quickfwt(p,8,3,value);
	printf("\n");
	for (i=0; i<8; i++)	{
		printf("%5.2lf\n",value[i]);
	}
	printf("\n");
}
