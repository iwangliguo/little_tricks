#include "stdio.h"
#include "math.h"
#include "matrix.h"

int principal_gauss(RMP bp, RMP dp)
{
	int n, l, f, m;
	int ls,k,i,j,is,u,v;
	double p,t,*b,*d;

	n=bp->row;
	f=bp->col;  /* 系数矩阵的带宽 */
	l=(f-1)/2;  /* 系数矩阵的半带宽 f=2l + 1 */
	m=dp->col;
	b=bp->data;
	d=dp->data;
	ls=l;
	for (k=0;k<n-1;k++){ 
		p=0.0;
		for (i=k;i<=ls;i++)	{ 
			t=fabs(b[i*f]);
			if (t>p) {p=t; is=i;}
		}
		if (fabs(p)<0.0000001){ 
			printf("fail\n"); return -1;
		}
		for (j=0;j<m;j++){ 
			u=k*m+j; v=is*m+j;
			t=d[u]; d[u]=d[v]; d[v]=t;
		}
		for (j=0;j<f;j++) { 
			u=k*f+j; v=is*f+j;
			t=b[u]; b[u]=b[v]; b[v]=t;
		}
		for (j=0;j<m;j++){ 
			u=k*m+j; d[u]/=b[k*f];
		}
		for (j=1;j<f;j++){ 
			u=k*f+j; b[u]/=b[k*f];
		}
		for (i=k+1;i<=ls;i++) { 
			t=b[i*f];
			for (j=0;j<m;j++){ 
				u=i*m+j; v=k*m+j;
				d[u]-=t*d[v];
			}
			for (j=1;j<f;j++) { 
				u=i*f+j; v=k*f+j;
				b[u-1]=b[u]-t*b[v];
			}
			u=i*f+f-1; b[u]=0.0;
		}
		if (ls!=(n-1)) ls++;
	}

	p=b[(n-1)*f];
	if (fabs(p)<0.0000001)	{ 
		printf("fail\n"); return -2;
	}
	for (j=0;j<m;j++) { 
		u=(n-1)*m+j; d[u]/=p;
	}
	ls=1;
	for (i=n-2;i>=0;i--){ 
		for (k=0;k<m;k++) { 
			u=i*m+k;
			for (j=1;j<=ls;j++)	{ 
				v=i*f+j; is=(i+j)*m+k;	
				d[u]-=b[v]*d[is];
			}
		}
		if (ls!=(f-1)) ls++;
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
	double b[8][5]={{3.0,-4.0,1.0,0.0,0.0},
					{-2.0,-5.0,6.0,1.0,0.0},
					{1.0,3.0,-1.0,2.0,-3.0},
					{2.0,5.0,-5.0,6.0,-1.0},
					{-3.0,1.0,-1.0,2.0,-5.0},
					{6.0,1.0,-3.0,2.0,-9.0},
					{-4.0,1.0,-1.0,2.0,0.0},
					{5.0,1.0,-7.0,0.0,0.0}};
	double d[8][3]={{13.0,29.0,-13.0},
					{-6.0,17.0,-21.0},
					{-31.0,-6.0,4.0},
					{64.0,3.0,16.0},
					{-20.0,1.0,-5.0},
					{-22.0,-41.0,56.0},
					{-29.0,10.0,-21.0},
					{7.0,-24.0,20.0}};
	RM mb = {8, 5, (double*)b};
	RM md = {8, 3, (double*)d};

	if (0 == principal_gauss(&mb, &md)) {
		printx(&md);
	}
}
