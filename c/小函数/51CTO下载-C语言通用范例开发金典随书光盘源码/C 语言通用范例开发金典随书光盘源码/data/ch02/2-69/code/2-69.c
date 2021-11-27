#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "matrix.h"

int gauss_jordan_elimination(RMP ap, RMP bp)
{ 
	int    *js,n,m,k,i,j,is,p,q;
	double d,t,*a,*b;
	n = bp->row; m = bp->col;
	a = ap->data;
	b = bp->data;
	js=malloc(n*sizeof(int));
	for (k=0;k<n;k++) 
	{ 
		d=0.0;
		for (i=k;i<n;i++)
			for (j=k;j<n;j++){ 
				t=fabs(a[i*n+j]);
				if (t>d) { d=t; js[k]=j; is=i;}
			}
		if (fabs(d)<0.0000001) { 
			free(js); printf("fail\n");
			return -1;
		}
		else{ 
			if (js[k]!=k)
				for (i=0;i<n;i++) { 
					p=i*n+k; q=i*n+js[k];
					t=a[p]; a[p]=a[q]; a[q]=t;
				}
			if (is!=k) { 
				for (j=k;j<n;j++) { 
					p=k*n+j; q=is*n+j;
					t=a[p]; a[p]=a[q]; a[q]=t;
				}
				for (j=0;j<m;j++){
					p=k*m+j; q=is*m+j;
					t=b[p]; b[p]=b[q]; b[q]=t;
				}
			}
		}
		d=a[k*n+k];
		for (j=k+1;j<n;j++){ 
			p=k*n+j; a[p]/=d;
		}
		for (j=0;j<m;j++){ 
			p=k*m+j; b[p]/=d;
		}
		for (j=k+1;j<n;j++)
			for (i=0;i<n;i++){ 
				p=i*n+j;
				if (i!=k)
					a[p]-=a[i*n+k]*a[k*n+j];
			}
		for (j=0;j<m;j++)
			for (i=0;i<n;i++){ 
				p=i*m+j;
				if (i!=k)	  
					b[p]-=a[i*n+k]*b[k*m+j];
		}
	}
	for (k=n-1;k>=0;k--)
		if (js[k]!=k)
			for (j=0;j<m;j++)	{ 
				p=k*m+j; q=js[k]*m+j;
				t=b[p]; b[p]=b[q]; b[q]=t;
			}
	free(js);/*释放动态分配的内存*/
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
	double a[4][4]={{1.0,1.0,-2.0,-1.0},
					{3.0,-2.0,-1.0,2.0},
					{2.0,5.0,7.0,3.0},
					{2.0,-3.0,-5.0,-1.0}};
	double b[4][2]={{4.0,3.0},
					{2.0,4.0},
					{-2.0,7.0},
					{4.0,-1.0}};
	RM ma = {4, 4, (double*)a};
	RM mb = {4, 2, (double*)b};
	
	if(0 == gauss_jordan_elimination(&ma, &mb)) {
		printx(&mb);
	}
}
