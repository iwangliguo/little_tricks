#include "stdio.h"
#include "math.h"
#include "matrix.h"

int jacobi_method(RMP ap,RMP vp,int jt,double eps)
{ 
	int    i,j,p,q,u,w,t,s,l,n;
	double fm,cn,sn,omega,x,y,d;
	double *a,*v;

	vp->row=vp->col=n=ap->row;
	a=ap->data;
	v=vp->data;
	for (i=0; i<n; i++)	{ 
		v[i*n+i]=1.0;
		for (j=0; j<n; j++)
			if (i!=j) v[i*n+j]=0.0;
	}
	l=1;
	while (1) { 
		fm=0.0;
		for (i=1; i<n; i++)
			for (j=0; j<i; j++)		{ 
				d=fabs(a[i*n+j]);
				if ((i!=j)&&(d>fm))	{ fm=d; p=i; q=j;}
			}
		if (fm<eps)  return 0;
		if (l>jt)  return -1;
		l++;
		u=p*n+q; w=p*n+p; t=q*n+p; s=q*n+q;
		x=-a[u]; y=(a[s]-a[w])/2.0;
		omega=x/sqrt(x*x+y*y);
		if (y<0.0) omega=-omega;
		sn=1.0+sqrt(1.0-omega*omega);
		sn=omega/sqrt(2.0*sn);
		cn=sqrt(1.0-sn*sn);
		fm=a[w];
		a[w]=fm*cn*cn+a[s]*sn*sn+a[u]*omega;
		a[s]=fm*sn*sn+a[s]*cn*cn-a[u]*omega;
		a[u]=0.0; a[t]=0.0;
		for (j=0; j<n; j++)
			if ((j!=p)&&(j!=q))	{ 
				u=p*n+j; w=q*n+j;
				fm=a[u];
				a[u]=fm*cn+a[w]*sn;
				a[w]=-fm*sn+a[w]*cn;
			}
		for (i=0; i<=n-1; i++)
			if ((i!=p)&&(i!=q)) { 
				u=i*n+p; w=i*n+q;
				fm=a[u];
				a[u]=fm*cn+a[w]*sn;
				a[w]=-fm*sn+a[w]*cn;
			}
		for (i=0; i<=n-1; i++)	{ 
			u=i*n+p; w=i*n+q;
			fm=v[u];
			v[u]=fm*cn+v[w]*sn;
			v[w]=-fm*sn+v[w]*cn;
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
	double a[5][5]={{1.0,2.0,3.0,4.0,5.0},
					{2.0,6.0,7.0,8.0,9.0},
					{3.0,7.0,10.0,11.0,12.0},
					{4.0,8.0,11.0,13.0,14.0},
					{5.0,9.0,12.0,14.0,15.0}};
	double v[5][5];
	int i,j=100; /*最大迭代次数:100*/
	double eps=0.000001; /*控制精度:0.000001*/
	RM ma = {5, 5, (double*)a};
	RM mv = {0, 0, (double*)v};

	if(0 == jacobi_method(&ma, &mv,j,eps)) {
		for (i=0; i<=4; i++)
			printf("%13.7e  ",a[i][i]);
		printrm("\n", &mv);
	}
}