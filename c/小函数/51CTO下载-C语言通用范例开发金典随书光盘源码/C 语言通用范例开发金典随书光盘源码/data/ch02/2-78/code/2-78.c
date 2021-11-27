#include "stdio.h"
#include "math.h"
#include "matrix.h"

int gauss_seidel_iteration(RMP ap,RMP bp,RMP xp,double eps)
{ 
	int    i,j,n,u,v;
	double *a,*b,*w,p,t,s,q;

	n=ap->row;
	a=ap->data;
	b=bp->data;
	w=xp->data;
	for (i=0; i<n; i++)	{ 
		u=i*n+i; p=0.0; w[i]=0.0;
		for (j=0; j<n; j++)
			if (i!=j) { 
				v=i*n+j; p+=fabs(a[v]);
			}
		if (p>=fabs(a[u]))	{ 
			printf("fail\n"); return -1;
		}
	}
	do { 
		p=0.0;
		for (i=0; i<n; i++) 	{ 
			t=w[i]; s=0.0;
			for (j=0; j<n; j++)
				if (j!=i) s+=a[i*n+j]*w[j];
			w[i]=(b[i]-s)/a[i*n+i];
			q=fabs(w[i]-t)/(1.0+fabs(w[i]));
			if (q>p) p=q;
		} 
	} while (p>=eps);
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
	double a[4][4]={{35.0,5.0,2.0,4.0},
					{7.0,43.0,8.0,4.0},	
					{1.0,7.0,39.0,8.0},
					{2.0,4.0,6.0,17.0}};
	double b[4]={3.0,5.0,7.0,11.0};
	double w[4]={0};
	double eps=0.000001;
	RM ma = {4,4,(double*)a};
	RM mb = {4,1,(double*)b};
	RM mx = {4,1,(double*)w};

	if (gauss_seidel_iteration(&ma,&mb,&mx,eps)==0) {
		printx(&mx);
	}
}
