#include<stdio.h>
#include<math.h>
double tdpolyval(double a[],int m,int n,double x,double y)
{
    int i,j;
    double val,srow,xrow;

	for (val=0.0,i=0,xrow=1.0;i<=m-1;i++,xrow=xrow*x)
          {

				for(srow=a[n-1+i*n]*xrow,j=n-2;j>=0;j--)
                   {
                       srow=srow*y+a[j+i*n]*xrow;
                   }
              val=val+srow;
          }

    return val;
}

main()
  {
	double a[3][2]={{5.6,7.9},{4.4,-2.0},{-2.0,-4.0}},x=1.37,y=-4.9;
	printf("\n The result is :%lf",tdpolyval(a,3,2,x,y));


  }


