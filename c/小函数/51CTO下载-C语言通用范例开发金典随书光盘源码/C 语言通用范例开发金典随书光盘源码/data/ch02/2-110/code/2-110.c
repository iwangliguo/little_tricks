#include "stdio.h"
#include "math.h"
#include "integration.h"

double integration_ladder(INTEGP ap)
{ 
	int    n,k;
	double fa,fb,h,t1,p,s,x,t;

	fa=(*ap->ptr)(ap->a); 
	fb=(*ap->ptr)(ap->b);
	n=1; 
	h=ap->b - ap->a;
	t1=h*(fa+fb)/2.0;
	do{ 
		s=0.0;
		for (k=0;k<n;k++) { 
			x=ap->a+(k+0.5)*h;	
			s+=(*ap->ptr)(x);
		}
		t=(t1+h*s)/2.0;
		p=fabs(t1-t);           /* p 为前后两次积分差 */
		t1=t; n+=n; h/=2.0;
	}while (p>=ap->eps); 
	return(t);
}
  
double ladder_ptr(double x)
{
	return 3*exp(-2*x*x);
}
  
main()
{ 
	INTEG  ia = { 0.0, 1.0, 0.000001, ladder_ptr};
	double t = integration_ladder(&ia);
    printf("\nt=%e\n\n",t);
}
