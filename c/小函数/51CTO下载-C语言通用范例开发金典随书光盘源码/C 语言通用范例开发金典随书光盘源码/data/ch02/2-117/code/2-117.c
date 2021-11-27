#include "stdio.h"
#include "math.h"

/*在本函数中取5阶拉盖尔多项式，其在[0，+无穷大)上的5个零点为: */
static double gt[5]={0.26355990,1.41340290,3.59642600,7.08580990,12.64080000};
/*对应的积分系数: */
static double gc[5]={0.6790941054,1.638487956,2.769426772,4.315944000,7.104896230};

double laguerre_gauss(double (*ptr)())
{ 
	int    i;
	double g=0.0;

	for (i=0; i<5; i++) {
		g+=gc[i]*(*ptr)(gt[i]); 
	}
	return(g);
}

double laguerre_gauss_ptr(double x)
{ 
	return 3.0*x*exp(-1.1*x);
}

main()
{
	double g = laguerre_gauss(laguerre_gauss_ptr);
	printf("\ng=%e\n\n",g);
}
