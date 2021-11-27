#include "math.h"
#include "stdio.h"
#define  UNUM   50 /*一个输出单元代表的样本点数*/

void rndsplanalysis(double x[],int n, double x0,double h,int m,int l, double dt[],int g[],int q[])
{ 
	int    i,j,k,t;
	double s;
	char   ch[UNUM + 1];
	
	for (i=0,dt[0]=0.0; i<n; i++) 
		dt[0]+=x[i];
	dt[0]/=n;                     /*dt[0]: 算术平均*/
	for (i=0,dt[1]=0.0; i<n; i++)
		dt[1]+=pow(x[i]-dt[0],2);
	dt[1]/=n;                     /*dt[1]: 方差*/
	dt[2]=sqrt(dt[1]);            /*dt[2]: 标准差*/
	for (i=0; i<m; i++)	{ 
		s=x0+(i+0.5)*h-dt[0];
		s=exp(-s*s/(2.0*dt[1]));
		g[i]=(int)(n*s*h/(dt[2]*2.5066));  /*高斯分布理论样本点数*/
	}
	for (i=0; i<m; i++)	q[i]=0;
	s=x0+m*h;
	for (i=0; i<n; i++)
		if ((x[i]>=x0) && x[i]<=s)	{ 
			j=(int)((x[i]-x0)/h);
			q[j]++;              /*实际点数*/
		}
	if (l==0) return; /*l: 0不输出直方图,1输出直方图*/
	printf("n=%d",n);
	printf("\nx0=%5.3lf  h=%5.3lf  m=%d",x0,h,m);
	printf("\n a=%5.3lf  s=%5.3lf  t=%5.3lf  ",dt[0],dt[1],dt[2]);
	printf("\n");
	for (i=0,t=0; i<m; i++)
		if (q[i]>t) t=q[i];
	for(k=1;t>UNUM;)	{ 
		k<<=1; t>>=1; 
	}
	for (i=0; i<m; i++)	{ 
		s=x0+(i+0.5)*h;
		for (j=0; j<=UNUM; j++) ch[j]=' ';
		j=q[i]/k;
		for (t=0; t<j; t++) ch[t]='+';
		j=g[i]/k;
		if ((j>0)&&(j<=UNUM)) ch[j]='*';
		printf("%5.3lf  %7d  ",s,q[i]);
		for (j=0; j<=UNUM; j++)
		printf("%c",ch[j]);
		printf("\n");
	}
	printf("the ratio is 1:%d",k);
	return;
}

main()
{ 
	int    g[10],q[10],n,m,l;
	double dt[3],x0,h;
	double x[50]={
			201.123,195.673,195.757,196.051,196.092,
			197.392,202.004,198.189,193.850,198.944,
			199.237,199.698,199.572,199.614,199.824,
			200.746,200.830,200.914,200.956,200.998,
			200.160,200.243,200.285,200.453,200.704,
			202.004,202.088,202.172,202.172,202.297,
			202.884,202.507,202.591,202.716,202.633,
			203.051,203.052,203.094,203.094,203.177,
			204.267,204.352,204.352,204.729,205.106,
			205.148,205.357,205.400,205.483,206.070,
		};
	
	x0=195.0; 
	n=50;
	h=1.0;
	m=8;
	l=1;
	rndsplanalysis(x,n,x0,h,m,l,dt,g,q);
}
