#include "stdio.h"
#include "math.h"
#include "interpolation.h"

void least_squares_fitting(LINTEP lp)
{ 
	int n,m,i,j,k;
	double z,p,c,g,q,d1,d2,s[20],t[20],b[20];
	double *x,*y,*coe,*dt;

	n=lp->n;m=lp->m;
	x=lp->x;y=lp->y;coe=lp->coe;dt=lp->dt;
    for (i=0; i<=m-1; i++) coe[i]=0.0;
    if (m>n) m=n;
    if (m>20) m=20;
	z=0.0;
	for (i=0; i<n; i++){
		z+=x[i]/(1.0*n);
	}
	b[0]=1.0; d1=1.0*n; p=0.0; c=0.0;
	for (i=0; i<n; i++) { 
		p+=(x[i]-z); c+=y[i];
	}
	c/=d1; p/=d1;
	coe[0]=c*b[0];
	if (m>1){ 
		t[1]=1.0; t[0]=-p;
		d2=0.0; c=0.0; g=0.0;
		for (i=0; i<n; i++){ 
			q=x[i]-z-p; 
			d2+=q*q;
			c+=y[i]*q;
			g+=(x[i]-z)*q*q;
		}
		c/=d2; p=g/d2; q=d2/d1;
		d1=d2;
		coe[1]=c*t[1]; coe[0]=c*t[0]+coe[0];
	}
	for (j=2; j<m; j++)	{ 
		s[j]=t[j-1];	
		s[j-1]=-p*t[j-1]+t[j-2];
		if (j>=3)
			for (k=j-2; k>0; k--)
				s[k]=-p*t[k]+t[k-1]-q*b[k];
		s[0]=-p*t[0]-q*b[0];
		d2=0.0; c=0.0; g=0.0;
		for (i=0; i<n; i++)	{ 
			q=s[j];	
			for (k=j-1; k>=0; k--)
				q=q*(x[i]-z)+s[k];
			d2=d2+q*q; c=c+y[i]*q;
			g+=(x[i]-z)*q*q;
		}
		c/=d2; p=g/d2; q=d2/d1;
		d1=d2;
		coe[j]=c*s[j]; t[j]=s[j];
		for (k=j-1; k>=0; k--)	{ 
			coe[k]+=c*s[k];
			b[k]=t[k]; t[k]=s[k];
		}
	}
	dt[0]=0.0; dt[1]=0.0; dt[2]=0.0;
	for (i=0; i<n; i++)	{ 
		q=coe[m-1];
		for (k=m-2; k>=0; k--)
			q=coe[k]+q*(x[i]-z);
		p=q-y[i];
		if (fabs(p)>dt[2]) 
			dt[2]=fabs(p);
		dt[0]+=p*p;
		dt[1]+=fabs(p);
	}
	return;
}

main()
{
	int i;
	double x[20],y[20],coe[6],dt[3];
	LINTE  la = {20, x, y, 6, coe, dt};

	for (i=0; i<20; i++){ 
		x[i]=0.2*i;	
		y[i]=3.0*x[i]-exp(-0.5*x[i]);
	}
	least_squares_fitting(&la);
	printf("\n");
	for (i=0; i<6; i++)
		printf("coe(%2d)=%e\n",i,coe[i]);
	printf("\n");
	for (i=0; i<3; i++)
		printf("dt(%2d)=%e  ",i,dt[i]);
	printf("\n\n");
}
