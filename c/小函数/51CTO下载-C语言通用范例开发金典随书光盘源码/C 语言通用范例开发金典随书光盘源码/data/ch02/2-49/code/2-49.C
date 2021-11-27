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

double* nordisrndsq(double u,double g,double *r,int n)
{
   double *value,*vp,temp;
   int i,count;
   value=(double *)malloc(n*sizeof(double));
   
   for(count=0,vp=value;count<n;count++,vp++)
   {
     for(i=1,temp=0.0;i<=12;i++)
        temp=temp+edisrnd(r);
   
     *vp=u+g*(temp-6.0);
   
   }
   return(value);

}

main()
  {

     double u,g,r,*valsq,*vp;
     int i,n ;
     u=2.7; g=4.3;r=3.0;
     n=10;
     
    
    valsq=nordisrndsq(u,g,&r,n);
    printf("\nThe sequence of normal distributed  random number is:\n");
    for(i=0,vp=valsq;i<n;i++,vp++)
     {
     if(i<n-1)  printf("%5.2lf;",*vp);
     else       printf("%5.2lf!",*vp);
     }

  }
