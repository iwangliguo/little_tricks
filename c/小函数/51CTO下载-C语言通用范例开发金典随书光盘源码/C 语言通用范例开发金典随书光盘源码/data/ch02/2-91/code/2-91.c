#include "stdlib.h"
#include "math.h"
#include "stdio.h"
#include "equation.h"
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

int quasi_newton_nonlinear(QNCTLP qp) 
{ 
	int    n,i,j,l;
	double eps,r,init,am,z,beta,d,*x,*y,*a,*b;
	RM  ma, mb;

	n=qp->n;
	eps=qp->eps;
	r=qp->h;
	init=qp->t;
	x=qp->x;
	y=malloc(n*sizeof(double));
	a=malloc(n*n*sizeof(double));
	b=malloc(n*sizeof(double));
	ma.row = ma.col = n; ma.data = a; 
	mb.row = n; mb.col = 1; mb.data = b;
	l=qp->iter; 
	do	{ 
		(*qp->fuc)(n,x,b);
		am=0.0;
		for (i=0; i<n; i++)	{ 
			z=fabs(b[i]);
			if (z>am) am=z;
		}
		if (am>=eps){ 
			l--;
			if (l==0) { 
				free(y); free(b); free(a);
				printf("fail\n"); return(0);
			}
			for (j=0; j<n; j++)	{ 
				z=x[j]; x[j]=x[j]+init;
				(*qp->fuc)(n,x,y);
				for (i=0; i<n; i++) 
					a[i*n+j]=y[i];
				x[j]=z;
			}
			if (gauss_elimination(&ma,&mb)<0){ 
				free(y); free(a); free(b); return(-1);
			}
			beta=1.0;
			for (i=0; i<n; i++) 
				beta-=b[i];
			if (fabs(beta)<0.0000001){ 
				free(y); free(a); free(b);
				printf("fail\n"); return(-2);
			}
			d=init/beta;
			for (i=0; i<n; i++) 
				x[i]-=d*b[i];
			init*=r;
		}
	}while (am>=eps);
	free(y); free(a); free(b);/*释放动态分配的内存*/
	return(qp->iter-l);
}
  
void quasi_newton_ptr(int n,double x[],double y[])
{ 
	y[0]=7*x[0]*x[0]+3*x[1]*x[1]+x[2]*x[2]-1.0;
    y[1]=3.0*x[0]*x[0]+x[1]*x[1]-5.0*x[2];
    y[2]=2*x[0]*x[0]-5.0*x[1]+3*x[2]*x[2];
}
  
main()
{ 
    double x[3]={1.0,1.0,1.0};
	QNCTL  qc = {3, x, 0.0000001, 200, 0.1, 0.1, quasi_newton_ptr};
	int    i;

    i=quasi_newton_nonlinear(&qc);
    printf("\ni=%d\n\n",i);
    for (i=0; i<=2; i++)
      printf("x(%d)=%13.7e\n",i,x[i]);
    printf("\n");
}
