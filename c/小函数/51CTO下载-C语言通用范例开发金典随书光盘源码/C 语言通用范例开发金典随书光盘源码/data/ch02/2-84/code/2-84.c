#include "stdio.h"
#include "math.h"
#include "equation.h"
  
int newton_iterative(ITEP np, NLFP fp)
{ 
	int    l;
	double eps,y[2],d,p,x0,x1;

	eps=np->eps;
	x0=np->x;
	nlf2(fp,x0,y);
	l=np->iter; d=eps+1.0;
	while ((d>=eps)&&(l>0)) { 
		if (fabs(y[1])<0.0000001) { 
			printf("error\n"); return(-1);
		}
		x1=x0-y[0]/y[1];
		nlf2(fp,x1,y);
		d=fabs(x1-x0);
		p=fabs(y[0]);
		if (p>d) d=p;
		x0=x1; 
		l--;
	}
	np->x=x1;
	return(np->iter - l);
}

main() {
	double a[] = { -1.0, 0.0, -2.0, 1.0 };
	NLF    fa = { 3, a};
	ITE    nit = { 50, 0.000001, 2.5 };
	int k;
	if ((k=newton_iterative(&nit, &fa))>=0)
		printf("\nk=%d  x=%13.7e\n", k, nit.x);
	printf("\n");
}
