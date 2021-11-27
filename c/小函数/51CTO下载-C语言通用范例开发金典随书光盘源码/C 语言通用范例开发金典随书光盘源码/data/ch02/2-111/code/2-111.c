#include "stdio.h"
#include "math.h"
#include "integration.h"

double integration_simpson(INTEGP ap)
{ 
	int n,k;
	double h,t1,t2,s1,s2,ep,p,x;

	n=1; 
	h=ap->b - ap->a;
	t1=h*((*ap->ptr)(ap->a)+(*ap->ptr)(ap->b))/2.0;
	s1=t1;
	do 	{ 
		p=0.0;
		for (k=0;k<=n-1;k++) { 
			x=ap->a+(k+0.5)*h;	
			p+=(*ap->ptr)(x);
		}
		t2=(t1+h*p)/2.0;
		s2=(4.0*t2-t1)/3.0;
		ep=fabs(s2-s1);             /* ep 为前后两次积分差 */
		t1=t2; s1=s2; 
		n<<=1; h/=2.0;
	}	while (ep>=ap->eps);
	return(s2);
}
  
double simpson_ptr(double x)
{ 
	double y;
	y=1.1*log(7.0+3*x)/(11.0+5*x*x);
	return(y);
}
  
main()
{
	INTEG ia = {0.0, 1.0, 0.000001, simpson_ptr};
	double s=integration_simpson(&ia);
	printf("\n");
	printf("s=%e\n",s);
	printf("\n");
}
