#include "stdio.h"
#include "math.h"
#include "matrix.h"

void jacobi_clearance(RMP ap, RMP vp, double eps)
{ 
	int    i,j,p,q,u,w,t,s,n;
	double ff,fm,cn,sn,omega,x,y,d;
	double *a,*v;
	int    loop;

	vp->row=vp->col=n=ap->row;
	a=ap->data;
	v=vp->data;
	for (i=0; i<n; i++) { 
		v[i*n+i]=1.0;
		for (j=0; j<n; j++)
			if (i!=j) v[i*n+j]=0.0;
	}
	ff=0.0;
	for (i=1; i<n; i++)
		for (j=0; j<i; j++)	{ 
			d=a[i*n+j]; ff+=d*d; 
		}
	ff=sqrt(2.0*ff);
	do {
		ff/=n;
		do {
			loop = 0;
			for (i=1; i<n; i++){
				for (j=0; j<i; j++)	{ 
					if ((d=fabs(a[i*n+j]))>ff){ 
						p=i; q=j;
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
						for (i=0; i<n; i++)
							if ((i!=p)&&(i!=q))	{ 
								u=i*n+p; w=i*n+q;
								fm=a[u];
								a[u]=fm*cn+a[w]*sn;
								a[w]=-fm*sn+a[w]*cn;
							}
						for (i=0; i<n; i++)	{ 
							u=i*n+p; w=i*n+q;
							fm=v[u];
							v[u]=fm*cn+v[w]*sn;
							v[w]=-fm*sn+v[w]*cn;
						}
						loop = 1;
						break;
					}
				}
				if(loop) break;
			}
		} while(loop);
	}while(ff>=eps);
}

void printrm(char *title, RMP vp) 
{
	int i, j;

	printf(title);
	for(i=0; i<vp->row; i++) {    
		for(j=0; j<vp->col; j++)
			printf("%12.6e ", vp->data[i*vp->col + j]);
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
	double eps=0.000001;
	int i;
	RM ma = {5, 5, (double*)a};
	RM mv = {0, 0, (double*)v};

	jacobi_clearance(&ma,&mv,eps);
	for (i=0; i<5; i++)
		printf("%13.7e\n",a[i][i]);
	printrm("\n", &mv);
}
