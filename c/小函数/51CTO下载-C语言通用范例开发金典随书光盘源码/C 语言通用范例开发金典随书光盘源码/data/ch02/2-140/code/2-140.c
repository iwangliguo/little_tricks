#include "math.h"
#include "stdio.h"
#include "stdlib.h"
#include "matrix.h"

int equations_square_root(RMP ap, RMP bp)
{ 
	int    i,j,m,n,k,u,v;
	double *a,*d;

	n=ap->row;
	m=bp->col;
	a=ap->data; 
	d=bp->data;
	if (a[0]<0.0000001) { 
		printf("fail\n"); return -1;
	}
	a[0]=sqrt(a[0]);
	for (j=1; j<n; j++) 
		a[j]/=a[0];
	for (i=1; i<n; i++)	{ 
		u=i*n+i;
		for (j=1; j<=i; j++){ 
			v=(j-1)*n+i;
			a[u]-=a[v]*a[v];
		}
		if (a[u]<0.0000001) { 
			printf("fail\n"); return -2;
		}
		a[u]=sqrt(a[u]);
		if (i!=(n-1)){ 
			for (j=i+1; j<n; j++){ 
				v=i*n+j;
				for (k=1; k<=i; k++)
					a[v]-=a[(k-1)*n+i]*a[(k-1)*n+j];
				a[v]/=a[u];
			}
		}
	}
	for (j=0; j<m; j++)	{ 
		d[j]/=a[0];
		for (i=1; i<n; i++)	{ 
			u=i*n+i; v=i*m+j;
			for (k=1; k<=i; k++)
				d[v]-=a[(k-1)*n+i]*d[(k-1)*m+j];
			d[v]/=a[u];
		}
	}
	for (j=0; j<m; j++)	{ 
		u=(n-1)*m+j;
		d[u]/=a[n*n-1];
		for (k=n-1; k>0; k--)	{ 
			u=(k-1)*m+j;
			for (i=k; i<n; i++)	{ 
				v=(k-1)*n+i;
				d[u]-=a[v]*d[i*m+j];
			}
			v=(k-1)*n+k-1;
			d[u]/=a[v];
		}
	}
	return 0;
}
  
void mulliregression(double x[],double y[],int m,int n,double a[],double dt[],double v[])
{ 
	int     i,j,k,m1;
	double  q,e,u,p,ay,s,r,pp,*b;
	RM      ma, mb;
	
	m1=m+1;
	b=malloc(m1*m1*sizeof(double));
	b[m1*m1-1]=n;
	for (j=0; j<m; j++)	{ 
		for (i=0,p=0.0; i<n; i++)
			p+=x[j*n+i];
		b[m*m1+j]=b[j*m1+m]=p;
	}
	for (i=0; i<m; i++)
		for (j=i; j<m; j++)	{ 
			for (k=0,p=0.0; k<=n-1; k++)
				p+=x[i*n+k]*x[j*n+k];
			b[j*m1+i]=b[i*m1+j]=p;
		}
	for (i=0,a[m]=0.0; i<n; i++)
		a[m]+=y[i];
	for (i=0; i<m; i++)	
		for (j=0,a[i]=0.0; j<n; j++)
			a[i]+=x[i*n+j]*y[j];
	ma.row=m1; ma.col=1; ma.data=a;
	mb.row=mb.col=m1; mb.data=b;
	equations_square_root(&mb, &ma);
	for (i=0,ay=0.0; i<n; i++)
		ay+=y[i];
	ay/=n;
	for (i=0,q=e=u=0.0; i<n; i++)	{ 
		for (j=0,p=a[m]; j<m; j++)
			p+=a[j]*x[j*n+i];
		q+=(y[i]-p)*(y[i]-p);
		e+=(y[i]-ay)*(y[i]-ay);
		u+=(ay-p)*(ay-p);
	}
	s=sqrt(q/n);
	r=sqrt(1.0-q/e);
	for (j=0; j<m; j++)	{ 
		for (i=0,p=0.0; i<n; i++)	{ 
			for (k=0,pp=a[m]; k<=m-1; k++)
				if (k!=j) pp+=a[k]*x[k*n+i];
			p+=(y[i]-pp)*(y[i]-pp);
		}
		v[j]=sqrt(1.0-q/p);
	}
	dt[0]=q; /*偏差平方和*/
	dt[1]=s; /*平均标准差*/
	dt[2]=r; /*复相关系数*/
	dt[3]=u; /*回归平方和*/
	free(b); /*释放动态分配的内存*/
}

main()
{
	double a[4],v[3],dt[4];
	double x[3][4]={ {2.2,2.3,2.2,2.0},{1.9,1.8,2.0,2.1},{3.1,3.1,3.0,2.9}};
	double y[4]={8.1,8.0,8.1,8.0};
	int    i, m=3, n=4;

	mulliregression((double*)x,y,m,n,a,dt,v);
	printf("\n");
	for (i=0; i<=3; i++)
		printf("a[%d]=%e ",i,a[i]);
	printf("\n");
	printf("q=%e  s=%e  r=%e",dt[0],dt[1],dt[2]);
	printf("\n");
	for (i=0; i<=2; i++)
		printf("v[%d]=%e ",i,v[i]);
	printf("\n");
	printf("u=%e",dt[3]);
}
