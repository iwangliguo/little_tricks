#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "matrix.h"

int toeplitz_levinson(TMP tp, RMP bp, RMP xp)
{ 
	int    i,j,k,n;
	double a,beta,q,c,h,*t,*b,*x,*y,*s;

	n=tp->row;
	t=tp->tdata;
	b=bp->data;
	x=xp->data;
	s=malloc(n*sizeof(double));
	y=malloc(n*sizeof(double));
	a=t[0];
	if (fabs(a)<0.0000001){ 
		free(s); free(y); 
		printf("fail\n"); return -1;
	}
	y[0]=1.0; x[0]=b[0]/a;
	for (k=1; k<n; k++)	{ 
		beta=0.0; q=0.0;
		for (j=0; j<k; j++) { 
			beta+=y[j]*t[j+1];
			q+=x[j]*t[k-j];
		}
		if (fabs(a)<0.0000001){ 
			free(s); free(y); 
			printf("fail\n"); return -2;
		}
		c=-beta/a; s[0]=c*y[k-1]; y[k]=y[k-1];
		if (k!=1)
			for (i=1; i<k; i++)
				s[i]=y[i-1]+c*y[k-i-1];
		a+=c*beta;
		if (fabs(a)<0.0000001) { 
			free(s); free(y); 
			printf("fail\n"); return -3;
		}
		h=(b[k]-q)/a;
		for (i=0; i<k; i++) { 
			x[i]+=h*s[i]; y[i]=s[i];
		}
		x[k]=h*y[k];
	}
	free(s); free(y); /* 释放动态分配的内存 */
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
	double t[8]={8.0,7.0,6.0,5.0,4.0,3.0,2.0,1.0};
	double b[8]={13.0,21.0,7.0,22.0,9.0,5.0,11.0,14.0};
	double x[8];
	TM mt = {8, (double*)t, NULL};
	RM mb = {8, 1, (double*)b};
	RM mx = {8, 1, (double*)x};

	if (toeplitz_levinson(&mt, &mb, &mx)==0) {
		printx(&mx);
	}
}
