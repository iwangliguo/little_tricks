#include "stdio.h"
#include "math.h"
#include "integration.h"

void self_adaptive(double x0,double x1,double h,double f0,double f1,
	double t0,double eps,double d,double t[],double (*ptr2)())
{
	double x,f,t1,t2,p,g,eps1;

	x=x0+h/2.0; f=(*ptr2)(x);  
	t1=h*(f0+f)/4.0; 
	t2=h*(f+f1)/4.0;
	p=fabs(t0-(t1+t2));            /* 区间和子区间之间的积分差 */
	if ((p<eps)||(h/2.0<d))
	{   /* 积分差满足精度要求 或 区间宽度小于指定的最小步长 */
		t[0]+=(t1+t2); 
		return;
	}    
	else      
	{   /* 采用递归法, 并把一个区间分割为两个子区间 */
		g=h/2.0; 
		eps1=eps/1.4;
		self_adaptive(x0,x,g,f0,f,t1,eps1,d,t,ptr2);
		self_adaptive(x,x1,g,f,f1,t2,eps1,d,t,ptr2);
		return;
	}
}

double integration_self_adaptive(SINTEGP sp)
{ 
	double h,t[2],f0,f1,t0;

	h=sp->b - sp->a; 
	t[0]=0.0;
	f0=(*sp->ptr)(sp->a); 
	f1=(*sp->ptr)(sp->b);
	t0=h*(f0+f1)/2.0;
	self_adaptive(sp->a,sp->b,h,f0,f1,t0,sp->eps,sp->step,t,sp->ptr);
	return t[0]; 
}

double self_adaptive_ptr(double x)
{ 
	return (5.0*x+1.0)/(3.0+11.0*x*x);
}

main()
{ 
	SINTEG  sa = { -1.0, 1.0, 0.000001, 0.0001, self_adaptive_ptr };
	double  t = integration_self_adaptive(&sa);
	printf("\n");
	printf("t=%e\n",t);
	printf("\n");
}
