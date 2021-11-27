#include "math.h"
#include "stdio.h"
#include "equation.h"

static void fuction1(double *t,double *x,double *y,double *x1,double *y1,
		double *dx,double *dy,double *p,double *q,int *k,int *it)
{ 
	*it=1;
	while (*it==1)	{ 
		*t/=1.67; 
		*it=0;
		*x1=*x-*t*(*dx);
		*y1=*y-*t*(*dy);
		if (*k>=30)	{ 
			*p=sqrt(*x1*(*x1)+*y1*(*y1));
			*q=exp(75.0/(*k));
			if (*p>=*q) *it=1;
		}
	}
}

static void fuction2(double xr[],double xi[],double ar[],double ai[],
		double *x,double *y, double *p,double *w,int *k)
{ 
	int i;
	for (i=1; i<=*k; i++){ 
		ar[i]+=ar[i-1]*(*x)-ai[i-1]*(*y);
		ai[i]+=ar[i-1]*(*y)+ai[i-1]*(*x);
	}
	xr[*k-1]=*x*(*w); 
	xi[*k-1]=*y*(*w);
	(*k)--;
	if (*k==1) { 
		*p=ar[0]*ar[0]+ai[0]*ai[0];
		xr[0]=-*w*(ar[0]*ar[1]+ai[0]*ai[1])/(*p);
		xi[0]=*w*(ar[1]*ai[0]-ar[0]*ai[1])/(*p);
	}
}

static void fuction3(double *x,double *y,double *x1,double *y1,
		double *dx,double *dy,double *dd,double *dc,double *c,int *k,int *is,int *it)
{ 
	if (*it==0)	{ 
		*is=1;
		*dd=sqrt(*dx*(*dx)+*dy*(*dy));
		if (*dd>1.0) *dd=1.0;
		*dc=6.28/(4.5*(*k)); 
		*c=0.0;
	}
	while(1){ 
		*c+=*dc;
		*dx=*dd*cos(*c); 
		*dy=*dd*sin(*c);
		*x1=*x+*dx; 
		*y1=*y+*dy;
		if (*c<=6.29){ 
			*it=0; return;
		}
		*dd/=1.67;
		if (*dd<=1.0e-07) { 
			*it=1; return;
		}
		*c=0.0;
	}
}

int newton_descent_complex(CNLFP fp, ROOTP rp)
{ 
	int    m,n,i,k,is,it,once;
	double t,x,y,x1,y1,dx,dy,p,q,w,dd,dc,c;
	double g,u,v,pq,g1,u1,v1;
	double *ar, *ai, *xr, *xi;

	m=n=fp->n;
	ar=fp->cr; ai=fp->ci;
	xr=rp->rr; xi=rp->ri;
	p=sqrt(ar[m]*ar[m]+ai[m]*ai[m]);
	while ((m>0)&&(fabs(p)<0.0000001))	{  
		m--;
		p=sqrt(ar[m]*ar[m]+ai[m]*ai[m]);
	}
	if (m<=0)	{ 
		printf("fail\n"); return(-1);
	}
	for (i=0; i<=m; i++){ 
		ar[i]/=p; ai[i]/=p;
	}
	for (i=0; i<=m/2; i++)	{ 
		w=ar[i]; ar[i]=ar[m-i]; ar[m-i]=w;
		w=ai[i]; ai[i]=ai[m-i]; ai[m-i]=w;
	}
	k=m; is=0; w=1.0;
	do { 
		pq=sqrt(ar[k]*ar[k]+ai[k]*ai[k]);
		while (pq<1.0e-12)	{ 
			xr[k-1]=0.0; xi[k-1]=0.0; k=k-1;
			if (k==1)	{ 
				p=ar[0]*ar[0]+ai[0]*ai[0];	
				xr[0]=-w*(ar[0]*ar[1]+ai[0]*ai[1])/p;
				xi[0]=w*(ar[1]*ai[0]-ar[0]*ai[1])/p;
				return(1);
			}
			pq=sqrt(ar[k]*ar[k]+ai[k]*ai[k]);
		}
		q=log(pq); q=q/(1.0*k); q=exp(q);
		p=q; w=w*p;
		for (i=1; i<=k; i++){ 
			ar[i]/=q; ai[i]/=q; q=q*p;
		}
		x=0.0001; x1=x; y=0.2; y1=y; dx=1.0;
		g=1.0e+37;
		once = 1;
		while(once--) {
			u=ar[0]; v=ai[0];
			for (i=1; i<=k; i++)	{ 
				p=u*x1; q=v*y1;
				pq=(u+v)*(x1+y1);
				u=p-q+ar[i]; v=pq-p-q+ai[i];
			}
			g1=u*u+v*v;
			if (g1>=g)	{ 
				if (is!=0)	{ 
					it=1;	
					fuction3(&x,&y,&x1,&y1,&dx,&dy,&dd,&dc,&c,&k,&is,&it);
					if (it==0) {once=1; continue;};
				}
				else{ 
					fuction1(&t,&x,&y,&x1,&y1,&dx,&dy,&p,&q,&k,&it);	
					if (t>=1.0e-03) {once=1; continue;};
					if (g>1.0e-18)	{ 
						it=0;	
						fuction3(&x,&y,&x1,&y1,&dx,&dy,&dd,&dc,&c,&k,&is,&it);	
						if (it==0) {once=1; continue;};
					}	
				}	
				fuction2(xr,xi,ar,ai,&x,&y,&p,&w,&k);
			}
			else { 
				g=g1; x=x1; y=y1; is=0;
				if (g<=1.0e-22)
					fuction2(xr,xi,ar,ai,&x,&y,&p,&w,&k);
				else { 
					u1=k*ar[0]; v1=ai[0];
					for (i=2; i<=k; i++) { 
						p=u1*x; q=v1*y; pq=(u1+v1)*(x+y);
						u1=p-q+(k-i+1)*ar[i-1];	
						v1=pq-p-q+(k-i+1)*ai[i-1];	
					}	
					p=u1*u1+v1*v1;	
					if (p<=1.0e-20)	{ 
						it=0;	
						fuction3(&x,&y,&x1,&y1,&dx,&dy,&dd,&dc,&c,&k,&is,&it);	
						if (it==0) {once=1; continue;};	
						fuction2(xr,xi,ar,ai,&x,&y,&p,&w,&k);	
					}	
					else { 
						dx=(u*u1+v*v1)/p;	
						dy=(u1*v-v1*u)/p;	
						t=1.0+4.0/k;	
						fuction1(&t,&x,&y,&x1,&y1,&dx,&dy,&p,&q,&k,&it);	
						if (t>=1.0e-03) {once=1; continue;};	
						if (g>1.0e-18)	{ 
							it=0;	
							fuction3(&x,&y,&x1,&y1,&dx,&dy,&dd,&dc,&c,&k,&is,&it);	
							if (it==0) {once=1; continue;};	
						}	
						fuction2(xr,xi,ar,ai,&x,&y,&p,&w,&k);	
					}	
				}
			}
		}
	}while (k!=1);
	return(1);
}

void printr(ROOTP rp) {
	int      i;

    printf("\n");
	for (i=0; i<rp->n; i++)
		printf("x(%d)=%13.7e j %13.7e\n",i,rp->rr[i],rp->ri[i]);
	printf("\n");
}

main()
{ 
    double ar[6]={12,23.0,14.0,0.0,3.0,9.0};
    double ai[6]={-5.0,3.0,0.0,5.0,13.0,5.0};
    double xr[5],xi[5];
	CNLF   fa = {5, ar, ai};
	ROOT   r = {5, xr, xi};
	if (newton_descent_complex(&fa, &r)>0) { 
		printr(&r);
	}
}
