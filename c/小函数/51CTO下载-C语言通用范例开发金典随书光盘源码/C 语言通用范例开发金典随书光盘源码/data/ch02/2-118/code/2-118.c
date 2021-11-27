#include "stdio.h"
#include "math.h"

/*�ڱ�������ȡ5�װ������ض���ʽ������(-�����+�����)�ϵ�5�����Ϊ: */
static double gt[5]={-2.02018200,-0.95857190,0.0,0.95857190,2.02018200};
/*��Ӧ�Ļ���ϵ��: */
static double gc[5]={1.181469599,0.9865791417,0.9453089237,0.9865791417,1.181469599};

double hermite_gauss(double (*ptr)())
{ 
	int    i;
	double g=0.0;

	for (i=0; i<5; i++)  {
		g+=gc[i]*(*ptr)(gt[i]); 
	}
	return(g);
}

double hermite_gauss_ptr(double x)
{ 
	return 3.0*x*x*exp(-1.1*x*x);
}

main()
{
	double g=hermite_gauss(hermite_gauss_ptr);
	printf("\ng=%e\n\n",g);
}
