#include<stdio.h>
#include<math.h>

double doublemod(double a,double b)
{
  int i;
  double value;
  i = (int)(a/b);
  value = a -i*b;
  return  value;
}

double edisrnd(double *r)
  /*产生0-1之间均匀分布的随机数*/
  { double value;


    *r =doublemod(*r,65536.0);
    *r =doublemod((*r)*2053.0+13849.0,65536.0);
    value = *r/65536.0;
    return(value);
  }

double nordisrnd(double u,double g,double *r)
{
   double value;
   int i;
   for(i=1,value=0.0;i<=12;i++)
        value=value+edisrnd(r);
   value=u+g*(value-6.0);

   return(value);

}

main()
  {

     double u,g,r;
     u=2.7; g=4.3;r=3.0;
     printf("\nThe random number is :%5.2lf",nordisrnd(u,g,&r));

  }
