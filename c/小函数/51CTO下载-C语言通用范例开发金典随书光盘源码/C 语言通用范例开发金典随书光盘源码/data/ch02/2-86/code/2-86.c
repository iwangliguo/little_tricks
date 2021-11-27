#include "stdio.h"
#include "math.h"
#include "equation.h"

int continued_fraction(ITEP cp, NLFP fp)
{ 
	int    i,j,m,it,l;
	double a[10],y[10],z,h,x0,q;

	l=cp->iter; q=1.0e+35; x0=cp->x; h=0.0;
	while (l>0) { 
		l--; j=0; it=l;
		while (j<8) { 
			if (j<3) z=x0+0.1*j;
			else z=h;
			y[j]=nlf(fp,z);
			h=z;
			if (j==0) a[0]=z;
			else { 
				m=0; i=0;
				while ((m==0)&&(i<j)) { 
					if (fabs(h-a[i])+1.0==1.0) m=1;
					else h=(y[j]-y[i])/(h-a[i]);
					i++;
				}
				a[j]=h;
				if (m!=0) a[j]=q;
				h=0.0;
				for (i=j-1; i>=0; i--)	{ 
					if (fabs(a[i+1]+h)<0.0000001) h=q;
					else h=-y[i]/(a[i+1]+h);
				}
				h=h+a[0];
			}
			if (fabs(y[j])>=cp->eps) j++;
			else { j=cp->iter; l=0;}
		}
		x0=h;
	}
	cp->x=h;
	return(cp->iter-it);
}

main() {
	double a[] = { 6.0, 0.0, -5.0, 3.0 };
	NLF    fa = { 3, a};
	ITE    nit = { 10, 0.000001, -4.5 };
	int k;
	k=continued_fraction(&nit, &fa);
	printf("\nk=%d  x=%13.7e\n", k, nit.x);
	printf("\n");
}
