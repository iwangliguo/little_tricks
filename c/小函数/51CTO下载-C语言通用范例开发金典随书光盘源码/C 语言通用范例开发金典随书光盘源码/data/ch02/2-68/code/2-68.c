#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "matrix.h"
  
int gauss_elimination(RMP ap, RMP bp)  
{ 
	int    *js,n,k,i,j,is,p,q;
	double d,t,*a,*b;

	n=ap->row;
	a=ap->data;
	b=bp->data;
	js=malloc(n*sizeof(int));
	for (k=0;k<n-1;k++) { 
		d=0.0;
		for (i=k;i<n;i++)
			for (j=k;j<n;j++) { 
				t=fabs(a[i*n+j]);
				if (t>d) { d=t; js[k]=j; is=i;}
			}
		if (fabs(d)<0.0000001) { 
			free(js); printf("fail\n");
			return -1;
		}
		else { 
			if (js[k]!=k)
				for (i=0;i<n;i++) { 
					p=i*n+k; q=i*n+js[k];
					t=a[p]; a[p]=a[q]; a[q]=t;
				}	
			if (is!=k)	{ 
				for (j=k;j<n;j++){ 
					p=k*n+j; q=is*n+j;
					t=a[p]; a[p]=a[q]; a[q]=t;
				}
				t=b[k]; b[k]=b[is]; b[is]=t;
			}
		}
		d=a[k*n+k];
		for (j=k+1;j<n;j++)	{ 
			p=k*n+j; a[p]/=d;
		}
		b[k]/=d;
		for (i=k+1;i<n;i++)	{ 
			for (j=k+1;j<n;j++)	{ 
				p=i*n+j;
				a[p]-=a[i*n+k]*a[k*n+j];
			}
			b[i]-=a[i*n+k]*b[k];
		}
	}
	d=a[(n-1)*n+n-1];
	if (fabs(d)<0.0000001)	{ 
		free(js); printf("fail\n");
		return -2;
	}
	b[n-1]/=d;
	for (i=n-2;i>=0;i--){ 
		t=0.0;	
		for (j=i+1;j<n;j++)
			t+=a[i*n+j]*b[j];
		b[i]-=t;
	}
	js[n-1]=n-1;
	for (k=n-1;k>=0;k--)
		if (js[k]!=k){ 
			t=b[k]; b[k]=b[js[k]]; b[js[k]]=t;
		}
	free(js); /*释放动态分配的内存*/
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
	double a[3][3]={{2.0,4.0,-1.0},
					{1.0,-2.0,1.0},
					{3.0,6.0,2.0}};
	double b[3]={6.0,4.0,-1.0};
	RM ma = {3, 3, (double*)a};
	RM mb = {3, 1, (double*)b};

	if (0 == gauss_elimination(&ma,&mb)) {
		printx(&mb);
	}
}
