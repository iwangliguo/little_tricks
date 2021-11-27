#include "math.h"
#include "stdio.h"
#include "math.h"
#include "interpolation.h"

void remez_method(RINTEP rp)
{ 
	int n,i,j,k,m;
	double a,b,eps,*coe,x[21],g[21],d,t,u,s,xx,x0,h,yy;
	double (*ptr)()=rp->ptr;

	n=rp->n;
	a=rp->a; b=rp->b; coe=rp->coe; eps=rp->eps;
	if (n>20) n=20; /*若n＞20，则本函数自动取n=20。*/
	m=n+1; d=1.0e+35;
	for (k=0; k<=n; k++) { 
		t=cos((n-k)*3.1415926/(1.0*n));	
		x[k]=(b+a+(b-a)*t)/2.0;
	}
	while (1) 	{ 
		u=1.0;
		for (i=0; i<m; i++)	{ 
			coe[i]=(*ptr)(x[i]);	
			g[i]=-u; u=-u;
		}
		for (j=0; j<n; j++)	{ 
			k=m; s=coe[k-1]; xx=g[k-1];
			for (i=j; i<n; i++) 	{ 
				t=coe[n-i+j-1]; x0=g[n-i+j-1];
				coe[k-1]=(s-t)/(x[k-1]-x[m-i-2]);
				g[k-1]=(xx-x0)/(x[k-1]-x[m-i-2]);
				k=n-i+j; s=t; xx=x0;
			}
		}
		u=-coe[m-1]/g[m-1];
		for (i=0; i<m; i++)
			coe[i]=coe[i]+g[i]*u;
		for (j=1; j<n; j++) 	{ 
			k=n-j; h=x[k-1]; s=coe[k-1];
			for (i=m-j; i<=n; i++) 	{ 
				t=coe[i-1]; coe[k-1]=s-h*t;
				s=t; k=i;
			}
		}
		coe[m-1]=fabs(u); u=coe[m-1];
		/*如果本次偏差绝对值u与上次求得的d,已充分接近，则终止迭代。*/
		if (fabs(u-d)<=eps) 
			return; 
		d=u; h=0.1*(b-a)/(1.0*n);
		xx=a; x0=a;
		while (x0<=b) 	{ 
			s=(*ptr)(x0); t=coe[n-1];
			for (i=n-2; i>=0; i--) {
				t*=x0;	t+=coe[i];
			}
			s=fabs(s-t);
			if (s>u) { u=s; xx=x0;}
			x0=x0+h;
		}
		s=(*ptr)(xx); t=coe[n-1];
		for (i=n-2; i>=0; i--) {
			t*=xx; t+=coe[i];
		}
		yy=s-t; i=1; j=n+1;
		while ((j-i)!=1) { 
			k=(i+j)/2;
			if (xx<x[k-1]) j=k;
			else i=k;
		}
		if (xx<x[0])	{ 
			s=(*ptr)(x[0]); t=coe[n-1];
			for (k=n-2; k>=0; k--) {
				t*=x[0]; t+=coe[k];
			}
			s-=t;
			if (s*yy>0.0) x[0]=xx;
			else { 
				for (k=n; k>0; k--)
					x[k]=x[k-1];
				x[0]=xx;
			}
		}
		else { 
			if (xx>x[n]) { 
				s=(*ptr)(x[n]); t=coe[n-1];
				for (k=n-2; k>=0; k--)
				t=t*x[n]+coe[k];
				s-=t;
				if (s*yy>0.0) x[n]=xx;
				else { 
					for (k=0; k<=n-1; k++)
						x[k]=x[k+1];
					x[n]=xx;
				}
			}
			else { 
				i--; j--;
				s=(*ptr)(x[i]); t=coe[n-1];
				for (k=n-2; k>=0; k--) {
					t*=x[i]; t+=coe[k];
				}
				s-=t;
				if (s*yy>0.0) x[i]=xx;
				else x[j]=xx;
			}
		}
	}
}
  
main()
{ 
	double coe[5]={0};
	RINTE  ra = {4, coe, -1.0, 1.0, 1.0e-10, exp};
	int i;
	
	remez_method(&ra);
	printf("\n");
	for (i=0; i<=3; i++)
		printf("coe(%2d)=%e\n",i,coe[i]);
	printf("\nMAX=%e\n\n",coe[4]);
}
