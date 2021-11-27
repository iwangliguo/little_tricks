#include "stdio.h"
#include "math.h"
#include "matrix.h"

int tridiagonal_chase(TDMP ap, RMP bp)
{ 
	int    m,n,k,j;
	double s,*a,*b;

	n = ap->row;
	m = 3*n - 2;
	a = ap->data; b = bp->data;
	for (k=0;k<n-1;k++){ 
		j=3*k; s=a[j];
		if (fabs(s)<0.0000001){ 
			printf("fail\n"); 
			return -1;
		}
		a[j+1]/=s;
		b[k]/=s;
		a[j+3]-=a[j+2]*a[j+1];
		b[k+1]-=a[j+2]*b[k];
	}
	s=a[3*n-3];
	if (fabs(s)<0.0000001){ 
		printf("fail\n"); 
		return -2;
	}
	b[n-1]/=s;
	for (k=n-2;k>=0;k--)
		b[k]-=a[3*k+1]*b[k+1];
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
    double a[13]={4.0,5.0,4.0,8.0,6.0,7.0,1.0,8.0,11.0,3.0,2.0,12.0,5.0};
    double b[5]={4.0,6.0,2.0,3.0,7.0};
	TDM ma = {5, (double*)a};
	RM  mb = {5, 1, (double*)b};

    if (tridiagonal_chase(&ma, &mb) == 0) {
		printx(&mb);
	}
}
