#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "stdio.h"
#include "ode.h"

int tridiagonal_chase(int n,int m,double b[],double d[])
{ 
	int    k,j;
	double s;
	if (m!=(3*n-2))	{ 
		printf("error\n"); 
		return(-2);
	}
	for (k=0;k<n-1;k++)	{ 
		j=3*k; s=b[j];
		if (fabs(s)<0.0000001)	{ 
			printf("fail\n"); 
			return(0);
		}
		b[j+1]/=s;
		d[k]/=s;
		b[j+3]-=b[j+2]*b[j+1];
		d[k+1]-=b[j+2]*d[k];
	}
	s=b[3*n-3];
	if (fabs(s)<0.0000001) { 
		printf("fail\n"); 
		return(0);
	}
	d[n-1]/=s;
	for (k=n-2;k>=0;k--)
		d[k]-=b[3*k+1]*d[k+1];
	return(2);
}
  
void finite_difference(DODEP ap)
{ 
	int    num,i,k,nn,m1;
	double z[4],h,x,*g,*d,*y;
	num=ap->n;
	g=malloc(6*num*sizeof(double));
	d=malloc(2*num*sizeof(double));
	h=(ap->b - ap->a)/(num-1); nn=2*num-1;
	g[0]=1.0; g[1]=0.0; g[3*num-3]=1.0; g[3*num-4]=0.0;
	y=ap->y; 
	y[0]=ap->ya; y[num-1]=ap->yb;
	for (i=2; i<num; i++) { 
		x=ap->a+(i-1)*h;
		(*ap->ptr)(x,z);
		k=3*(i-1)-1;
		g[k]=z[0]-h*z[1]/2.0;
		g[k+1]=h*h*z[2]-2.0*z[0];
		g[k+2]=z[0]+h*z[1]/2.0;
		y[i-1]=h*h*z[3];
	}
	m1=3*num-2;
	tridiagonal_chase(num,m1,g,y);
	h=h/2.0;
	g[0]=1.0; g[1]=0.0;
	d[0]=ap->ya; d[nn-1]=ap->yb;
	g[3*nn-3]=1.0; g[3*nn-4]=0.0;
	for (i=2; i<nn; i++) { 
		x=ap->a+(i-1)*h;
		(*ap->ptr)(x,z);
		k=3*(i-1)-1;
		g[k]=z[0]-h*z[1]/2.0;
		g[k+1]=h*h*z[2]-2.0*z[0];
		g[k+2]=z[0]+h*z[1]/2.0;
		d[i-1]=h*h*z[3];
	}
	m1=3*nn-2;
	tridiagonal_chase(nn,m1,g,d);
	for (i=2; i<num; i++){ 
		k=2*i-1;
		y[i-1]=(4.0*d[k-1]-y[i-1])/3.0;
	}
	free(g); free(d);/*释放动态分配的内存*/
	return;
}

void finite_difference_ptr(double x,double z[4])
{ 
	z[0]=-2.0; 
	z[1]=0.0;
    z[2]=3.0/(x*x); 
	z[3]=11.0/x;
}
  
main()
{ 
	double y[11] = {0};
	DODE   da = {11, 3.0, 4.0, 0.0, 0.0, y, finite_difference_ptr};
	int    i;

	finite_difference(&da);
	printf("\n");
	for (i=0; i<da.n; i++)
		printf("y(%2d)=%e\n",i,y[i]);
	printf("\n");
}
