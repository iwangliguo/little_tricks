#include "stdio.h"
#include "math.h"
#include "matrix.h"

void trans_hessenbreg(RMP ap)
{ 
	int    i,j,k,n,u,v;
    double d,t,*a;
	n = ap->row;
	a = ap->data;
    for (k=1; k<n-1; k++)
      { d=0.0;
        for (j=k; j<n; j++)
          { u=j*n+k-1; t=a[u];
            if (fabs(t)>fabs(d))
              { d=t; i=j;}
          }
        if (fabs(d)>0.0000001)
          { if (i!=k)
              { for (j=k-1; j<n; j++)
                  { u=i*n+j; v=k*n+j;
                    t=a[u]; a[u]=a[v]; a[v]=t;
                  }
                for (j=0; j<n; j++)
                  { u=j*n+i; v=j*n+k;
                    t=a[u]; a[u]=a[v]; a[v]=t;
                  }
              }
            for (i=k+1; i<n; i++)
              { u=i*n+k-1; t=a[u]/d; a[u]=0.0;
                for (j=k; j<n; j++)
                  { v=i*n+j;
                    a[v] -= t*a[k*n+j];
                  }
                for (j=0; j<n; j++)
                  { v=j*n+k;
                    a[v] += t*a[j*n+i];
                  }
              }
          }
      }
}

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

void printrm(char *title, RMP vp) 
{
	int i, j;

	printf(title);
	for(i=0; i<vp->row; i++) {    
		for(j=0; j<vp->col; j++)
			printf("%13.7e ", vp->data[i*vp->col + j]);
		printf("\n");
	}
}

main()
{ 
	double a[5][5]={{1.0,7.0,4.0,3.0,5.0},
					{2.0,9.0,6.0,23.0,8.0},
					{11.0,13.0,2.0,12.0,7.0},
					{6.0,8.0,19.0,11.0,2.0},
					{15.0,21.0,6.0,9.0,17.0}};
	static double u[5],v[5];
	int i,t=60;
	double eps=0.000001;
	RM ma = {5, 5, (double*)a};
	trans_hessenbreg(&ma); /* 矩阵A --> 上H矩阵 */
	printrm("Matrix H Is:\n", &ma);
	if(0 == hessenbreg_qr(&ma,u,v,t,eps)) {
		printf("\n");
		for (i=0; i<=4; i++)
			printf("%13.7e +J %13.7e\n",u[i],v[i]);
		printf("\n");
	}
}
