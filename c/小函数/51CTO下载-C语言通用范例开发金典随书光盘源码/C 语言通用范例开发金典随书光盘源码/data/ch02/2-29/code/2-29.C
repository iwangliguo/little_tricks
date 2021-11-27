#include<stdio.h>
#include<math.h>
double polyval(double a[],int n,double x)
{
    int i;
    double val;

	for (val=0.0,i=n;i>=1;i--)
            val=val*x+a[i-1];
    return val;
}

main()
  {
	double a[3]={4.0,2.0,-1.4},x=3.4;

	printf("\n The result is :%lf",polyval(a,3,x));
    
  }


