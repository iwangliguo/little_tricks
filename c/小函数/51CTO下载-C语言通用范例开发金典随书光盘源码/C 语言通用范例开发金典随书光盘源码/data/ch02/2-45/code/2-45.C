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

double * edisrndsq(double *r,int n)
  
  {  double *value,*vp;
     int i;
     if(n>=1)
    {
    value =(double *)malloc(n*sizeof(double));
    for(i=0,vp=value;i<n;i++,vp++)
    {   
    *r =doublemod(*r,65536.0);
    *r =doublemod((*r)*2053.0+13849.0,65536.0);  
    *vp=*r/65536.0;
    }
    return(value);
    
   }
  }

main()
  { int i,n;
    double *valsq,*vp,r;
    r=3.2;
    n=10;
    valsq=edisrndsq(&r,n);
    printf("\nThe sequence of evenly distributed  random number is:\n");
    for(i=0,vp=valsq;i<n;i++,vp++)
     {
     if(i<n-1)  printf("%5.2lf;",*vp);
     else       printf("%5.2lf!",*vp);
     }
  }
