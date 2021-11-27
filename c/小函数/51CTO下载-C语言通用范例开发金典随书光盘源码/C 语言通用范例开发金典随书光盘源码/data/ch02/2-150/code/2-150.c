#include "stdlib.h"
#include "math.h"
#include "stdio.h"
#include "matrix.h"

int matrix_inverse(RMP ap)
{ 
	int    n = ap->row;
	double *data = ap->data;
	int    i,j,k,l,u,v;
	int    *is,*js;
	double d,p;
    
	is=malloc(n*sizeof(int));
	js=malloc(n*sizeof(int));
	for (k=0; k<n; k++)
	{ 
		d=0.0;
		for (i=k; i<n; i++)	
			for (j=k; j<n; j++)	{ 
				l=i*n+j;	
				p=fabs(data[l]);	
				if (p>d) {	
					d=p;	
					is[k]=i;	
					js[k]=j;
				}
			}
		if (d + 1.0 == 1.0)	{ 
			free(is);free(js);	
			printf("not inverse.\n");
			return -1;
		}
		if (is[k]!=k)	
			for (j=0; j<n; j++)	{ 
				u=k*n+j; 
				v=is[k]*n+j;	
				p=data[u]; 
				data[u]=data[v]; 
				data[v]=p;	
			}	
		if (js[k]!=k)	
			for (i=0; i<n; i++)	{ 
				u=i*n+k; 
				v=i*n+js[k];	
				p=data[u]; 
				data[u]=data[v]; 
				data[v]=p;	
			}
		l=k*n+k;
		data[l]=1.0/data[l];
		for (j=0; j<n; j++)	
			if (j!=k)	{ 
				u=k*n+j; 
				data[u]=data[u]*data[l];
			}
		for (i=0; i<n; i++)	
			if (i!=k)	
				for (j=0; j<n; j++)	
					if (j!=k)	{ 
						u=i*n+j;	
						data[u]=data[u]-data[i*n+k]*data[k*n+j];	
					}
		for (i=0; i<n; i++)	
			if (i!=k)	{ 
				u=i*n+k; data[u]=-data[u]*data[l];
			}
	}
	for (k=n-1; k>=0; k--)	{ 
		if (js[k]!=k)	
			for (j=0; j<n; j++)	{ 
				u=k*n+j; v=js[k]*n+j;	
				p=data[u]; data[u]=data[v]; data[v]=p;
	}
	if (is[k]!=k)	
		for (i=0; i<n; i++)	{ 
			u=i*n+k; v=i*n+is[k];	
			p=data[u]; data[u]=data[v]; data[v]=p;	
		}
	}

	free(is); free(js); /*释放动态分配的内存*/
	return 0;
}

int kalfilter(RMP fp,RMP qp,RMP rp,RMP hp,RMP yp,RMP xp,RMP pp,RMP gp)
{ 
	int    i,j,l,m,n,k,kk,ii,jj;
	double *e,*a,*b;
	double *f=fp->data,*q=qp->data,*r=rp->data,*h=hp->data;
	double *x=xp->data,*y=yp->data,*p=pp->data,*g=gp->data;
	RM     me;

	n=fp->row; m=rp->row; l=max(m,n);
	k=xp->row;
	e=malloc(m*m*sizeof(double));
	me.row=me.col=m; me.data=e;
	a=malloc(l*l*sizeof(double));
	b=malloc(l*l*sizeof(double));
	for (i=0; i<n; i++)
		for (j=0; j<n; j++)	{ 
			ii=i*l+j; 
			for (kk=0,a[ii]=0.0; kk<n; kk++)
				a[ii]+=p[i*n+kk]*f[j*n+kk];
		}
	for (i=0; i<n; i++)
		for (j=0; j<n; j++)	{ 
			ii=i*n+j; 
			for (kk=0,p[ii]=q[ii]; kk<=n-1; kk++)
				p[ii]+=f[i*n+kk]*a[kk*l+j];
		}
	for (ii=2; ii<=k; ii++)	{ 
		for (i=0; i<n; i++)
			for (j=0; j<m; j++) { 
				jj=i*l+j;
				for (kk=0,a[jj]=0.0; kk<=n-1; kk++)
					a[jj]+=p[i*n+kk]*h[j*n+kk];
			}
		for (i=0; i<m; i++)
			for (j=0; j<m; j++)	{ 
				jj=i*m+j; 
				for (kk=0,e[jj]=r[jj]; kk<=n-1; kk++)
					e[jj]+=h[i*n+kk]*a[kk*l+j];
			}
		if (matrix_inverse(&me)!=0) { 
			free(e); free(a); free(b); 
			return(0);
		}
		for (i=0; i<n; i++)
			for (j=0; j<m; j++)	{ 
				jj=i*m+j; 
				for (kk=0,g[jj]=0.0; kk<=m-1; kk++)
					g[jj]+=a[i*l+kk]*e[j*m+kk];
			}
		for (i=0; i<n; i++){ 
			jj=(ii-1)*n+i; 
			for (j=0,x[jj]=0.0; j<n; j++)
				x[jj]+=f[i*n+j]*x[(ii-2)*n+j];
		}
		for (i=0; i<m; i++)	{ 
			jj=i*l; 
			for (j=0,b[jj]=y[(ii-1)*m+i]; j<n; j++)
				b[jj]-=h[i*n+j]*x[(ii-1)*n+j];
		}
		for (i=0; i<n; i++){ 
			jj=(ii-1)*n+i;
			for (j=0; j<m; j++)
				x[jj]=x[jj]+g[i*m+j]*b[j*l];
		}
		if (ii<k)	{ 
			for (i=0; i<n; i++)		
				for (j=0; j<n; j++)	{ 
					jj=i*l+j;
					for (kk=0, a[jj]=0.0; kk<m; kk++)
						a[jj]-=g[i*m+kk]*h[kk*n+j];
					if (i==j) a[jj]+=1.0;
				}
			for (i=0; i<n; i++)
				for (j=0; j<n; j++){
					jj=i*l+j; 
					for (kk=0,b[jj]=0.0; kk<n; kk++)
						b[jj]+=a[i*l+kk]*p[kk*n+j];
				}
			for (i=0; i<n; i++)
				for (j=0; j<n; j++){ 
					jj=i*l+j; 
					for (kk=0,a[jj]=0.0; kk<n; kk++)
						a[jj]+=b[i*l+kk]*f[j*n+kk];
				}	
			for (i=0; i<n; i++)
				for (j=0; j<n; j++) { 
					jj=i*n+j;
					for (kk=0,p[jj]=q[jj]; kk<n; kk++)
						p[jj]+=f[i*n+kk]*a[j*l+kk];
				}
		}
	}
	free(e); free(a); free(b);/*释放动态分配的内存*/
	return 1;
}
	
	
void kalmanrnd(RMP ap) {
	double s=65536.0, w=2053.0,v=13849.0,r=0.0,t=0.0;
	int    i,j,m;
	
	for (i=0; i<ap->row*ap->col; i++){ 
		t=0.0;
		for (j=0; j<12; j++)	{ 
			r=w*r+v; m=(int)(r/s); r=r-m*s; t=t+r/s;
		}
	ap->data[i]=0.5*(t-6.0);
	}
	return;
}

main()
{ 
	double f[3][3]={{1.0,0.05,0.00125},{0.0,1.0,0.05},{0.0,0.0,1.0}};
	double q[3][3]={{0.25,0.0,0.0},{0.0,0.25,0.0},{0.0,0.0,0.25}};
	double r[1][1]={0.25};
	double h[1][3]={1.0,0.0,0.0};
	double p[3][3]={0},x[20][3]={0},y[20][1],g[3][1];
	RM     mf = {3, 3, (double*)f}; /*状态转移矩阵*/
	RM     mq = {3, 3, (double*)q}; /*模型噪声的协方差矩阵*/
	RM     mr = {1, 1, (double*)r}; /*观测噪声的协方差矩阵*/
	RM     mh = {1, 3, (double*)h}; /*观测矩阵*/
	RM     mp = {3, 3, (double*)p}; /*初值P，返回估计误差协方差阵*/
	RM     mx = {20,3, (double*)x}; /*状态向量估值序列*/
	RM     my = {20,1, (double*)y}; /*观测向量序列*/
	RM     mg = {3, 1, (double*)g}; /*返回稳定增益矩阵*/
	double t,s;
	int    i;
	
	kalmanrnd(&my);
	for (i=0; i<my.row; i++)	{ 
		t=0.05*i;
		y[i][0]=1.0+2.0*t-3.0*t*t+y[i][0];
	}
	if (kalfilter(&mf,&mq,&mr,&mh,&my,&mx,&mp,&mg)!=0){ 
		printf("\n");
		printf("   t      s      y    x(0)   x(1)   x(2)   \n");
		
		for (i=0; i<mx.row; i+=5)	{ 
			t=0.05*i; 
			s=5.0-2.0*t+3.0*t*t;
			printf("%5.2f  %5.2f  %5.2f  %5.2f  %5.2f  %5.2f\n",
				t,s,y[i][0],x[i][0],x[i][1],x[i][2]);
		}
		printf("\n");
	}
}
