#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "matrix.h"
#include "equation.h"

int hessenbreg_qr(RMP ap, double *u, double*v,int t,double eps)
{ 
	int    m,n,it,i,j,k,l,ii,jj,kk,ll;
	double b,c,w,g,sgn,p,q,r,x,s,e,f,z,y;
	double *a=ap->data;
	it=0; m=n=ap->row;
	while (m!=0)
	{ 
		l=m-1;
		while ((l>0)&&(fabs(a[l*n+l-1])>eps*(fabs(a[(l-1)*n+l-1])+fabs(a[l*n+l])))) 
			l--;
		ii=(m-1)*n+m-1; jj=(m-1)*n+m-2;
		kk=(m-2)*n+m-1; ll=(m-2)*n+m-2;
		if (l==m-1)	{ 
			u[m-1]=a[(m-1)*n+m-1]; v[m-1]=0.0;
			m--; it=0;
		}
		else if (l==m-2)
		{ 
			b=-(a[ii]+a[ll]);
			c=a[ii]*a[ll]-a[jj]*a[kk];
			w=b*b-4.0*c;
			y=sqrt(fabs(w));
			if (w>0.0){ 
				sgn= (b<0.0)?-1.0:1.0;
				u[m-1]=(-b-sgn*y)/2.0;
				u[m-2]=c/u[m-1];
				v[m-1]=0.0; v[m-2]=0.0;
			}
			else
			{ 
				u[m-1]=-b/2.0; u[m-2]=u[m-1];
				v[m-1]=y/2.0; v[m-2]=-v[m-1];
			}
			m=m-2; it=0;
		}
		else
		{ 
			if (it>=t){ 
				printf("fail\n");
				return -1;
			}
			it++;
			for (j=l+2; j<m; j++)
				a[j*n+j-2]=0.0;
			for (j=l+3; j<m; j++)
				a[j*n+j-3]=0.0;
			for (k=l; k<m-1; k++) {
				/* 计算p,q,r */
				if (k!=l){ 
					p=a[k*n+k-1]; q=a[(k+1)*n+k-1];
					r=0.0;
					if (k!=m-2) r=a[(k+2)*n+k-1];
				}
				else
				{ 
					x=a[ii]+a[ll];
					y=a[ll]*a[ii]-a[kk]*a[jj];
					ii=l*n+l; jj=l*n+l+1;
					kk=(l+1)*n+l; ll=(l+1)*n+l+1;
					p=a[ii]*(a[ii]-x)+a[jj]*a[kk]+y;
					q=a[kk]*(a[ii]+a[ll]-x);
					r=a[kk]*a[(l+2)*n+l+1];
				}
				/* 构造变换 */
				if ((fabs(p)+fabs(q)+fabs(r))!=0.0)	{ 
					sgn=(p<0.0)?-1.0:1.0;
					s=sgn*sqrt(p*p+q*q+r*r);
					if (k!=l) a[k*n+k-1]=-s;
					e=-q/s; f=-r/s; x=-p/s;
					y=-x-f*r/(p+s);
					g=e*r/(p+s);
					z=-x-e*q/(p+s);
					for (j=k; j<m; j++){ 
						ii=k*n+j; jj=(k+1)*n+j;
						p=x*a[ii]+e*a[jj];
						q=e*a[ii]+y*a[jj];
						r=f*a[ii]+g*a[jj];
						if (k!=m-2)	{ 
							kk=(k+2)*n+j;
							p+=f*a[kk];
							q+=g*a[kk];
							r+=z*a[kk]; 
							a[kk]=r;
						}
						a[jj]=q; a[ii]=p;
					}
					j=k+3;
					if (j>m-1) j=m-1;
					for (i=l; i<=j; i++) { 
						ii=i*n+k; jj=i*n+k+1;
						p=x*a[ii]+e*a[jj];
						q=e*a[ii]+y*a[jj];
						r=f*a[ii]+g*a[jj];
						if (k!=m-2)	{ 
							kk=i*n+k+2;
							p+=f*a[kk];
							q+=g*a[kk];
							r+=z*a[kk]; 
							a[kk]=r;
						}
						a[jj]=q; a[ii]=p;
					}
				}
			}
		}
	}
	return 0;
}
  
int qr_all(ITEP qp, NLFP fp, double xr[], double xi[])
{ 
	int    n,i,j;
    double *a,*q;
	RM     mq;

	n=fp->n;
	a=fp->c;
    q=malloc(n*n*sizeof(double));
	mq.row = mq.col = n;
	mq.data = q;
	for (j=0; j<n; j++)
      q[j]=-a[n-j-1]/a[n];
    for (j=n; j<n*n; j++)
      q[j]=0.0;
    for (i=0; i<n-1; i++)
      q[(i+1)*n+i]=1.0;
    i=hessenbreg_qr(&mq,xr,xi,qp->iter,qp->eps);
    free(q); /* 释放动态分配的内存 */
	return(i);
}

 
main()
{ 
    double a[7]={-23.0,13,-5.0,8.0,7.0,13.0,18.0};
    double xr[6],xi[6];
	NLF    fa = {6, a};
	ITE    nit = { 60, 0.000001, 0.0 };
	int    i;

    printf("\n");
    if (qr_all(&nit, &fa, xr, xi) == 0) { 
		for (i=0; i<6; i++)
			printf("x(%d)=%13.7e  %13.7e j\n",i,xr[i],xi[i]);
        printf("\n");
	}
}
