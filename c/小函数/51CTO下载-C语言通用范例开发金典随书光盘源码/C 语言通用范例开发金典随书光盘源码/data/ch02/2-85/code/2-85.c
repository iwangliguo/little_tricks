#include "math.h"
#include "stdio.h"
#include "equation.h"

int aitken_iterative(ITEP ap, NLFP fp)
{ 
	int    iter,done,l;
	double eps,u,v,x0;

	iter=ap->iter;
	eps=ap->eps;
	l=0; x0=ap->x; done=0;
	while ((!done)&&(l<iter)) { 
		l++;
		u=nlf(fp,x0); v=nlf(fp,u);
		if (fabs(u-v)<eps) { 
			x0=v; 
			done=1; 
		}
		else {
			x0=v-(v-u)*(v-u)/(v-2.0*u+x0);
		}
	}
	ap->x=x0;
	return iter-l;
}
  
main() 
{
	double a[] = { 7.0, 0.0, -3.0};
	NLF    fa = { 2, a};
	ITE    nit = { 30, 0.000001, 1.5 };
	int k;
	k=aitken_iterative(&nit, &fa);
	printf("\nk=%d  x=%13.7e\n\n", k, nit.x);

}
