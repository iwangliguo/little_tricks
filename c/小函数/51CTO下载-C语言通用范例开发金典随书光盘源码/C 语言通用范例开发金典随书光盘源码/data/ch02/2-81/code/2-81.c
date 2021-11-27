#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "matrix.h"

void method1(double a[],double e[],double s[],double v[],int m,int n)
{ 
	int     i,j,p,q;
	double d;
	i= m>n ? n:m;
	for (j=1; j<i; j++) { 
		a[(j-1)*n+j-1]=s[j-1];
		a[(j-1)*n+j]=e[j-1];
	}
	a[(i-1)*n+i-1]=s[i-1];
	if (m<n) 
		a[(i-1)*n+i]=e[i-1];
	for (i=1; i<n; i++)
		for (j=i+1; j<=n; j++) { 
			p=(i-1)*n+j-1; q=(j-1)*n+i-1;
			d=v[p]; v[p]=v[q]; v[q]=d;
		}
}

void method2(double fg[2],double cs[2])
{ 
	double r,d;
	if ((fabs(fg[0])+fabs(fg[1])) <0.0000001) { 
		cs[0]=1.0; cs[1]=0.0; d=0.0;
	}
	else { 
		d=sqrt(fg[0]*fg[0]+fg[1]*fg[1]);
		if (fabs(fg[0])>fabs(fg[1])) { 
			d=fabs(d);
			if (fg[0]<0.0) d=-d;
		}
		if (fabs(fg[1])>=fabs(fg[0])) { 
			d=fabs(d);
			if (fg[1]<0.0) d=-d;
		}
		cs[0]=fg[0]/d; cs[1]=fg[1]/d;
	}
	r=1.0;
	if (fabs(fg[0])>fabs(fg[1])) r=cs[1];
	else
		if (cs[0]!=0.0) r=1.0/cs[0];
	fg[0]=d; fg[1]=r;
}

int singular_value_decomposition(RMP ap,RMP up,RMP vp,double eps,int ka)
{ 
	int    i,j,k,l,m,n,it,ll,kk,ix,iy,mm,nn,iz,m1,ks;
    double d,dd,t,sm,sm1,em1,sk,ek,b,c,shh,fg[2],cs[2];
    double *a,*u,*v,*s,*e,*w;
    s=malloc(ka*sizeof(double));
    e=malloc(ka*sizeof(double));
    w=malloc(ka*sizeof(double));
	m=ap->row;
	n=ap->col;
	up->row=up->col=m;
	vp->row=vp->col=n;
	a=ap->data;
	u=up->data;
	v=vp->data;
    it=60; k=n;
    if (m-1<n) k=m-1;
    l=m;
    if (n-2<m) l=n-2;
    if (l<0) l=0;
    ll=k;
    if (l>k) ll=l;
    if (ll>0)
      { for (kk=1; kk<=ll; kk++)
          { if (kk<=k)
              { d=0.0;
                for (i=kk; i<=m; i++)
                  { ix=(i-1)*n+kk-1; d=d+a[ix]*a[ix];}
                s[kk-1]=sqrt(d);
                if (s[kk-1]!=0.0)
                  { ix=(kk-1)*n+kk-1;
                    if (a[ix]!=0.0)
                      { s[kk-1]=fabs(s[kk-1]);
                        if (a[ix]<0.0) s[kk-1]=-s[kk-1];
                      }
                    for (i=kk; i<=m; i++)
                      { iy=(i-1)*n+kk-1;
                        a[iy]=a[iy]/s[kk-1];
                      }
                    a[ix]=1.0+a[ix];
                  }
                s[kk-1]=-s[kk-1];
              }
            if (n>=kk+1)
              { for (j=kk+1; j<=n; j++)
                  { if ((kk<=k)&&(s[kk-1]!=0.0))
                      { d=0.0;
                        for (i=kk; i<=m; i++)
                          { ix=(i-1)*n+kk-1;
                            iy=(i-1)*n+j-1;
                            d=d+a[ix]*a[iy];
                          }
                        d=-d/a[(kk-1)*n+kk-1];
                        for (i=kk; i<=m; i++)
                          { ix=(i-1)*n+j-1;
                            iy=(i-1)*n+kk-1;
                            a[ix]=a[ix]+d*a[iy];
                          }
                      }
                    e[j-1]=a[(kk-1)*n+j-1];
                  }
              }
            if (kk<=k)
              { for (i=kk; i<=m; i++)
                  { ix=(i-1)*m+kk-1; iy=(i-1)*n+kk-1;
                    u[ix]=a[iy];
                  }
              }
            if (kk<=l)
              { d=0.0;
                for (i=kk+1; i<=n; i++)
                  d=d+e[i-1]*e[i-1];
                e[kk-1]=sqrt(d);
                if (e[kk-1]!=0.0)
                  { if (e[kk]!=0.0)
                      { e[kk-1]=fabs(e[kk-1]);
                        if (e[kk]<0.0) e[kk-1]=-e[kk-1];
                      }
                    for (i=kk+1; i<=n; i++)
                      e[i-1]=e[i-1]/e[kk-1];
                    e[kk]=1.0+e[kk];
                  }
                e[kk-1]=-e[kk-1];
                if ((kk+1<=m)&&(e[kk-1]!=0.0))
                  { for (i=kk+1; i<=m; i++) w[i-1]=0.0;
                    for (j=kk+1; j<=n; j++)
                      for (i=kk+1; i<=m; i++)
                        w[i-1]=w[i-1]+e[j-1]*a[(i-1)*n+j-1];
                    for (j=kk+1; j<=n; j++)
                      for (i=kk+1; i<=m; i++)
                        { ix=(i-1)*n+j-1;
                          a[ix]=a[ix]-w[i-1]*e[j-1]/e[kk];
                        }
                  }
                for (i=kk+1; i<=n; i++)
                  v[(i-1)*n+kk-1]=e[i-1];
              }
          }
      }
    mm=n;
    if (m+1<n) mm=m+1;
    if (k<n) s[k]=a[k*n+k];
    if (m<mm) s[mm-1]=0.0;
    if (l+1<mm) e[l]=a[l*n+mm-1];
    e[mm-1]=0.0;
	nn=m>n?n:m;
    if (nn>=k+1)
      { for (j=k+1; j<=nn; j++)
          { for (i=1; i<=m; i++)
              u[(i-1)*m+j-1]=0.0;
            u[(j-1)*m+j-1]=1.0;
          }
      }
    if (k>0)
      { for (ll=1; ll<=k; ll++)
          { kk=k-ll+1; iz=(kk-1)*m+kk-1;
            if (s[kk-1]!=0.0)
              { if (nn>=kk+1)
                  for (j=kk+1; j<=nn; j++)
                    { d=0.0;
                      for (i=kk; i<=m; i++)
                        { ix=(i-1)*m+kk-1;
                          iy=(i-1)*m+j-1;
                          d=d+u[ix]*u[iy]/u[iz];
                        }
                      d=-d;
                      for (i=kk; i<=m; i++)
                        { ix=(i-1)*m+j-1;
                          iy=(i-1)*m+kk-1;
                          u[ix]=u[ix]+d*u[iy];
                        }
                    }
                  for (i=kk; i<=m; i++)
                    { ix=(i-1)*m+kk-1; u[ix]=-u[ix];}
                  u[iz]=1.0+u[iz];
                  if (kk-1>=1)
                    for (i=1; i<=kk-1; i++)
                      u[(i-1)*m+kk-1]=0.0;
              }
            else
              { for (i=1; i<=m; i++)
                  u[(i-1)*m+kk-1]=0.0;
                u[(kk-1)*m+kk-1]=1.0;
              }
          }
      }
    for (ll=1; ll<=n; ll++)
      { kk=n-ll+1; iz=kk*n+kk-1;
        if ((kk<=l)&&(e[kk-1]!=0.0))
          { for (j=kk+1; j<=n; j++)
              { d=0.0;
                for (i=kk+1; i<=n; i++)
                  { ix=(i-1)*n+kk-1; iy=(i-1)*n+j-1;
                    d=d+v[ix]*v[iy]/v[iz];
                  }
                d=-d;
                for (i=kk+1; i<=n; i++)
                  { ix=(i-1)*n+j-1; iy=(i-1)*n+kk-1;
                    v[ix]=v[ix]+d*v[iy];
                  }
              }
          }
        for (i=1; i<=n; i++)
          v[(i-1)*n+kk-1]=0.0;
        v[iz-n]=1.0;
      }
    for (i=1; i<=m; i++)
    for (j=1; j<=n; j++)
      a[(i-1)*n+j-1]=0.0;
    m1=mm; it=60;
    while (1)
      { if (mm==0)
          { method1(a,e,s,v,m,n);
            free(s); free(e); free(w); return 0;
          }
        if (it==0)
          { method1(a,e,s,v,m,n);
            free(s); free(e); free(w); return -1;
          }
        kk=mm-1;
	while ((kk!=0)&&(fabs(e[kk-1])!=0.0))
          { d=fabs(s[kk-1])+fabs(s[kk]);
            dd=fabs(e[kk-1]);
            if (dd>eps*d) kk=kk-1;
            else e[kk-1]=0.0;
          }
        if (kk==mm-1)
          { kk=kk+1;
            if (s[kk-1]<0.0)
              { s[kk-1]=-s[kk-1];
                for (i=1; i<=n; i++)
                  { ix=(i-1)*n+kk-1; v[ix]=-v[ix];}
              }
            while ((kk!=m1)&&(s[kk-1]<s[kk]))
              { d=s[kk-1]; s[kk-1]=s[kk]; s[kk]=d;
                if (kk<n)
                  for (i=1; i<=n; i++)
                    { ix=(i-1)*n+kk-1; iy=(i-1)*n+kk;
                      d=v[ix]; v[ix]=v[iy]; v[iy]=d;
                    }
                if (kk<m)
                  for (i=1; i<=m; i++)
                    { ix=(i-1)*m+kk-1; iy=(i-1)*m+kk;
                      d=u[ix]; u[ix]=u[iy]; u[iy]=d;
                    }
                kk=kk+1;
              }
            it=60;
            mm=mm-1;
          }
        else
          { ks=mm;
            while ((ks>kk)&&(fabs(s[ks-1])!=0.0))
              { d=0.0;
                if (ks!=mm) d=d+fabs(e[ks-1]);
                if (ks!=kk+1) d=d+fabs(e[ks-2]);
                dd=fabs(s[ks-1]);
                if (dd>eps*d) ks=ks-1;
                else s[ks-1]=0.0;
              }
            if (ks==kk)
              { kk++;
                d=fabs(s[mm-1]);
                t=fabs(s[mm-2]);
                if (t>d) d=t;
                t=fabs(e[mm-2]);
                if (t>d) d=t;
                t=fabs(s[kk-1]);
                if (t>d) d=t;
                t=fabs(e[kk-1]);
                if (t>d) d=t;
                sm=s[mm-1]/d; sm1=s[mm-2]/d;
                em1=e[mm-2]/d;
                sk=s[kk-1]/d; ek=e[kk-1]/d;
                b=((sm1+sm)*(sm1-sm)+em1*em1)/2.0;
                c=sm*em1; c=c*c; shh=0.0;
                if ((b!=0.0)||(c!=0.0))
                  { shh=sqrt(b*b+c);
                    if (b<0.0) shh=-shh;
                    shh=c/(b+shh);
                  }
                fg[0]=(sk+sm)*(sk-sm)-shh;
                fg[1]=sk*ek;
                for (i=kk; i<=mm-1; i++)
                  { method2(fg,cs);
                    if (i!=kk) e[i-2]=fg[0];
                    fg[0]=cs[0]*s[i-1]+cs[1]*e[i-1];
                    e[i-1]=cs[0]*e[i-1]-cs[1]*s[i-1];
                    fg[1]=cs[1]*s[i];
                    s[i]=cs[0]*s[i];
                    if ((cs[0]!=1.0)||(cs[1]!=0.0))
                      for (j=1; j<=n; j++)
                        { ix=(j-1)*n+i-1;
                          iy=(j-1)*n+i;
                          d=cs[0]*v[ix]+cs[1]*v[iy];
                          v[iy]=-cs[1]*v[ix]+cs[0]*v[iy];
                          v[ix]=d;
                        }
                    method2(fg,cs);
                    s[i-1]=fg[0];
                    fg[0]=cs[0]*e[i-1]+cs[1]*s[i];
                    s[i]=-cs[1]*e[i-1]+cs[0]*s[i];
                    fg[1]=cs[1]*e[i];
                    e[i]=cs[0]*e[i];
                    if (i<m)
                      if ((cs[0]!=1.0)||(cs[1]!=0.0))
                        for (j=1; j<=m; j++)
                          { ix=(j-1)*m+i-1;
                            iy=(j-1)*m+i;
                            d=cs[0]*u[ix]+cs[1]*u[iy];
                            u[iy]=-cs[1]*u[ix]+cs[0]*u[iy];
                            u[ix]=d;
                          }
                  }
                e[mm-2]=fg[0];
                it=it-1;
              }
            else
              { if (ks==mm)
                  { kk++;
                    fg[1]=e[mm-2]; e[mm-2]=0.0;
                    for (ll=kk; ll<=mm-1; ll++)
                      { i=mm+kk-ll-1;
                        fg[0]=s[i-1];
                        method2(fg,cs);
                        s[i-1]=fg[0];
                        if (i!=kk)
                          { fg[1]=-cs[1]*e[i-2];
                            e[i-2]=cs[0]*e[i-2];
                          }
                        if ((cs[0]!=1.0)||(cs[1]!=0.0))
                          for (j=1; j<=n; j++)
                            { ix=(j-1)*n+i-1;
                              iy=(j-1)*n+mm-1;
                              d=cs[0]*v[ix]+cs[1]*v[iy];
                              v[iy]=-cs[1]*v[ix]+cs[0]*v[iy];
                              v[ix]=d;
                            }
                      }
                  }
                else
                  { kk=ks+1;
                    fg[1]=e[kk-2];
                    e[kk-2]=0.0;
                    for (i=kk; i<=mm; i++)
                      { fg[0]=s[i-1];
                        method2(fg,cs);
                        s[i-1]=fg[0];
                        fg[1]=-cs[1]*e[i-1];
                        e[i-1]=cs[0]*e[i-1];
                        if ((cs[0]!=1.0)||(cs[1]!=0.0))
                          for (j=1; j<=m; j++)
                            { ix=(j-1)*m+i-1;
                              iy=(j-1)*m+kk-2;
                              d=cs[0]*u[ix]+cs[1]*u[iy];
                              u[iy]=-cs[1]*u[ix]+cs[0]*u[iy];
                              u[ix]=d;
                            }
                      }
                  }
              }
          }
      }
    return 0;
}

int generalized_inverses(RMP ap, RMP aap, double eps, RMP up, RMP vp,int ka)
{ 
	int i,j,k,l,m,n,t,p,q,f;
	double *a, *aa, *u, *v;
    if( singular_value_decomposition(ap,up,vp,eps,ka) < 0) {
		return -1;
	}
	m=ap->row;
	n=ap->col;
	a=ap->data;
	aa=aap->data;
	aap->row=ap->col;
	aap->col=ap->row;
	u=up->data;
	v=vp->data;
    j=m<n?m:n;
    j--;
    k=0;
    while ((k<=j)&&(a[k*n+k]!=0.0)) 
		k++;
    k=k-1;
    for (i=0; i<n; i++)
		for (j=0; j<m; j++)
		  { t=i*m+j; aa[t]=0.0;
			for (l=0; l<=k; l++)
			  { f=l*n+i; p=j*m+l; q=l*n+l;
				aa[t]+=v[f]*u[p]/a[q];
			  }
		  }
    return 0;
}

int least_squares_reversion(RMP ap, RMP bp, RMP xp, RMP aap, RMP up, RMP vp, int ka,double eps)
{ 
	int      m,n,i,j;
	double  *x,*aa,*b;
	if (generalized_inverses(ap,aap,eps,up,vp,ka)<0)  {
		return -1;
	}
	m = ap->row;
	n = ap->col;
	x = xp->data;
	aa = aap->data;
	b = bp->data;
	for (i=0; i<n; i++) { 
		x[i]=0.0;	
		for (j=0; j<m; j++)	
			x[i]+=aa[i*m+j]*b[j];
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
    double a[12][3]={   {1.24,1.27,1.0},{1.36,1.74,1.0},{1.38,1.64,1.0},{1.38,1.82,1.0},
						{1.38,1.90,1.0},{1.40,1.70,1.0},{1.48,1.82,1.0},{1.54,1.82,1.0},
						{1.56,2.08,1.0},{1.14,1.78,1.0},{1.18,1.96,1.0},{1.20,1.86,1.0}};
    double b[12]={1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,-1.0,-1.0,-1.0};
    double x[3],aa[3][12],u[12][12],v[3][3];
	
	double eps=0.000001;
	int    ka= max(12,3) + 1;
	RM     ma   = { 12, 3, (double*)a };
	RM     mb   = { 12, 1, (double*)b };
	RM     mx   = { 3, 1, (double*)x };
	RM     maa  = { 0, 0, (double*)aa };
	RM     mu   = { 0, 0, (double*)u };
	RM     mv   = { 0, 0, (double*)v };

    if (least_squares_reversion(&ma,&mb,&mx,&maa,&mu,&mv,ka,eps) ==0) {	
		printx(&mx);
        printrm("\nMatrix A+ :\n", &maa);
	}
}
