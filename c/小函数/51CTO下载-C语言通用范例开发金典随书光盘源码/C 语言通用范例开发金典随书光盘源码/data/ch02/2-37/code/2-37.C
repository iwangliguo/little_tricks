#include<stdio.h>
#include<math.h>

typedef struct complexnumber
{
   double rpart;
   double ipart;
}cnumber;

cnumber cpdiv(cnumber a,cnumber b)
{
   cnumber value ;
   double t=b.rpart*b.rpart +b.ipart* b.ipart;
   if(t!=0.0)
   {
   value.rpart=(a.rpart * b.rpart +a.ipart * b.ipart)/t;
   value.ipart=(-a.rpart * b.ipart +a.ipart * b.rpart)/t;
   return  value;
   }
   
}

main()
{
   
    cnumber a={-5.7,-6.5},b={2.9,7.3};
    cnumber value;
     value = cpdiv(a,b);
	printf("\n The result is :%5.2lf",value.rpart);
        if(value.ipart>=0.0)     printf("+%5.2lfi",value.ipart);
        else                     printf("%5.2lfi",value.ipart);
 
}
