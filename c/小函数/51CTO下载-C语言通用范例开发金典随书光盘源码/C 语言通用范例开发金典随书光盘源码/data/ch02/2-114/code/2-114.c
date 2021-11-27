#include "math.h"
#include "stdio.h"
#include "integration.h"

double continued_fractions(INTEGP ip)
{ 
	int m,n,k,l,j;
	double h[10],bb[10],hh,t1,s1,ep,s,x,t2,g;

	m=n=1;
	hh=ip->b - ip->a; h[0]=hh;
	t1=hh*((*ip->ptr)(ip->a)+(*ip->ptr)(ip->b))/2.0;
	bb[0]=s1=t1; 
	do { 
		s=0.0;
		for (k=0;k<n;k++){ 
			x=ip->a+(k+0.5)*hh;
			s+=(*ip->ptr)(x);
		}
		t2=(t1+hh*s)/2.0;
		m++;
		h[m-1]=h[m-2]/2.0;
		g=t2;
		l=0; j=2;
		while ((l==0)&&(j<=m))	{ 
			s=g-bb[j-2];
			if (fabs(s)+1.0==1.0) l=1;
			else g=(h[m-1]-h[j-2])/s;
			j++;
		}
		bb[m-1]=g;
		if (l!=0) bb[m-1]=1.0e+35;
		g=bb[m-1];
		for (j=m;j>1;j--)
			g=bb[j-2]-h[j-2]/g;
		ep=fabs(g-s1);
		s1=g; t1=t2; 
		hh/=2.0; n<<=1;
	}while ((ep>=ip->eps)&&(m<=9)); /* m<=9, 本函数最多计算到十节连分式 */

	return(g);
}
  
double continued_fractions_ptr(double x)
{ 
	return 3.0*exp(-5.0*x*x);
}
  
main()
{
	INTEG ia = {0.0, 1.0, 0.000001, continued_fractions_ptr};
    double s=continued_fractions(&ia);
    printf("\n");
    printf("s=%e\n",s);
    printf("\n");
}
