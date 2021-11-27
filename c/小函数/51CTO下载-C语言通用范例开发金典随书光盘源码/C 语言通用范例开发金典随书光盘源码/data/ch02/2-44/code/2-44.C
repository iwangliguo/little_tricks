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
  
  { double value;
    
   
    *r =doublemod(*r,65536.0);
    *r =doublemod((*r)*2053.0+13849.0,65536.0);  
    value = *r/65536.0;
    return(value);
  }

main()
  { int i;
    double r;
    for(r=3.2,i=1;i<5;i++)
     printf("\nThe %d random number is :%5.2lf",i,edisrnd(&r));
   
  }
