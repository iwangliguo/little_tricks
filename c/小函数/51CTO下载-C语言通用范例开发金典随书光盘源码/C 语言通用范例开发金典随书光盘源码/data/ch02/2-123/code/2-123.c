#include "math.h"
#include "stdio.h"
#include "integration.h"

double dual_method(double x,double eps,void (*ud)(),double (*ptr)())
{ 
	int m,n,k,l,j;
	double b[10],h[10],y[2],hh,t1,t2,s0,yy,g,ep,s;

	m=n=1;
	(*ud)(x,y);
	hh=y[1]-y[0]; h[0]=hh;
	t1=0.5*hh*((*ptr)(x,y[0])+(*ptr)(x,y[1]));
	s0=t1; b[0]=t1; 
	do{ 
		t2=t1/2.0;
		for (k=0;k<n;k++){ 
			yy=y[0]+(k+0.5)*hh;
			t2+=hh/2.0*(*ptr)(x,yy);
		}
		m++;
		h[m-1]=h[m-2]/2.0;
		g=t2; l=0; j=2;
		while ((l==0)&&(j<=m))	{ 
			s=g-b[j-2];
			if (fabs(s)<0.0000001) l=1;
			else g=(h[m-1]-h[j-2])/s;
			j++;
		}
		b[m-1]=g;
		if (l!=0) b[m-1]=1.0e+35;
		s=b[m-1];
		for (j=m;j>1;j--) 
			s=b[j-2]-h[j-2]/s;
		ep=fabs(s-s0)/(1.0+fabs(s));
		n<<=1; t1=t2; 
		s0=s; hh/=2.0;
	}while ((ep>=eps)&&(m<=9)); /* m<=9, 本函数最多计算到十节连分式 */
	return(s);
}

double continued_fractions_dual(INTEG2P ap)
{ 
	int    m,n,k,l,j;
	double a,b,eps;
	double bb[10],h[10],hh,s1,s2,t1,t2,x,g,s0,ep,s;

	a=ap->a; b=ap->b; eps=ap->eps;
	m=n=1;
	hh=b-a; h[0]=hh;
	s1=dual_method(a,eps,ap->ud,ap->ptr);
	s2=dual_method(b,eps,ap->ud,ap->ptr);
	t1=hh*(s1+s2)/2.0;
	s0=t1; bb[0]=t1; 
	do { 
		t2=t1/2.0;
		for (k=0;k<n;k++){ 
			x=a+(k+0.5)*hh;
			s1=dual_method(x,eps,ap->ud,ap->ptr);
			t2+=s1*hh/2.0;
		}
		m++;
		h[m-1]=h[m-2]/2.0;
		g=t2; l=0; j=2;
		while ((l==0)&&(j<=m)){ 
			s=g-bb[j-2];
			if (fabs(s)<0.0000001) l=1;
			else g=(h[m-1]-h[j-2])/s;
			j++;
		}
		bb[m-1]=g;
		if (l!=0) bb[m-1]=1.0e+35;
		s=bb[m-1];
		for (j=m;j>1;j--) 
			s=bb[j-2]-h[j-2]/s;
		ep=fabs(s-s0)/(1.0+fabs(s));
		n<<=1; t1=t2; 
		s0=s; hh/=2.0;
	} while ((ep>=eps)&&(m<=9));
	return(s);
}

void dual_ud_ptr(double x,double y[2])
{ 
	y[1]=sqrt(2.0-x*x);
	y[0]=-y[1];
	return;
}

double dual_ptr(double x,double y)
{
	return exp(x*x*cos(y)+y*y*sin(x));
}
  
main()
{ 
	INTEG2 ia = {0.0, 1.0, 0.00005, dual_ud_ptr, dual_ptr};
	double s=continued_fractions_dual(&ia);
	printf("\ns=%e\n\n",s);
}
