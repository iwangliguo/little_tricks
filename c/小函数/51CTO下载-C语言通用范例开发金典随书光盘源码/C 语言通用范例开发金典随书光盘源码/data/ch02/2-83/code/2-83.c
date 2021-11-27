#include "math.h"
#include "stdio.h"
#include "equation.h"

int nonlinear_dichotomy(DICP dp, NLFP fp)
{ 
	int    m,n;
	double lp,rp,step,eps,z,y,z1,y1,z0,y0;
	double *x;

	m=dp->m;
	lp=dp->left;
	rp=dp->right;
	step=dp->step;
	eps=dp->eps;
	x=dp->x;
	n=0; z=lp; y=nlf(fp,z);
	while ((z<=rp+step/2.0)&&(n!=m)) { 
		if (fabs(y)<eps) { 
			n++; x[n-1]=z;
			z+=step/2.0; y=nlf(fp,z);
		}
		else { 
			z1=z+step; y1=nlf(fp,z1);
			if (fabs(y1)<eps)	{ 
				n++; x[n-1]=z1;
				z=z1+step/2.0; y=nlf(fp,z);
			}
			else if (y*y1>0.0)	{ 
				y=y1; z=z1;
			}
			else	{ 
				while (1)	{ 
					if (fabs(z1-z)<eps)	{ 
						n++; x[n-1]=(z1+z)/2.0;
						z=z1+step/2.0; y=nlf(fp,z);
						break;
					}
					else { 
						z0=(z1+z)/2.0; y0=nlf(fp,z0);
						if (fabs(y0)<eps)	{ 
							x[n]=z0; n++;
							z=z0+step/2.0; y=nlf(fp, z);
							break;
						}
						else if ((y*y0)<0.0) { 
							z1=z0; y1=y0;
						}
						else { 
							z=z0; y=y0;
						}
					}
				}
			}
		}
	}
	return dp->n=n;
}

main()
{ 
	double a[7] = { -13.0, -12.0, 4.0, -5.0, -9.0, 3.0, 1.0 };
	NLF    fa = { 6, a};
	double x[6];
	DIC    d = {-7.0, 7.0, 0.2, 0.000001, 6, 0, (double*)&x };
	int    i;

	nonlinear_dichotomy(&d, &fa);
    printf("M=%d\n", d.n);
    for (i=0; i<d.n; i++)
      printf("x(%d)=%13.7e\n",i,d.x[i]);
    printf("\n");
}
