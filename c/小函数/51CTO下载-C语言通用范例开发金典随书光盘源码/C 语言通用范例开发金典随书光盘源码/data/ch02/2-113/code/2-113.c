#include "stdio.h"
#include "math.h"
#include "integration.h"

double integration_romberg(INTEGP ip)
{ 
	int    m,n,i,k;
	double y[10],h,ep,p,x,s,q;

	h=ip->b - ip->a;
	y[0]=h*((*ip->ptr)(ip->a)+(*ip->ptr)(ip->b))/2.0;
	m=n=1;
	do { 
		p=0.0;
		for (i=0;i<n;i++) { 
			x=ip->a+(i+0.5)*h;	
			p+=(*ip->ptr)(x);
		}	
		p=(y[0]+h*p)/2.0;
		s=1.0;
		for (k=1;k<=m;k++)	{ 
			s=4.0*s;
			q=(s*p-y[k-1])/(s-1.0);
			y[k-1]=p; p=q;
		}
		ep=fabs(q-y[m-1]);
		m++; 
		y[m-1]=q; 
		n<<=1; h/=2.0;
	}while ((ep>=ip->eps)&&(m<=9)); /*m限制为9,如果达到m=9,不管精度要求,返回结果*/
	return(q);
}

double romberg_ptr(double x)
{ 
	return (3.0*x+1.0)/(11.0+2.0*x*x);
}

main()
{ 
	INTEG  ia = {0.0, 1.0, 0.000001, romberg_ptr};
	double t=integration_romberg(&ia);
	printf("\n");
	printf("t=%e\n",t);
	printf("\n");
}
