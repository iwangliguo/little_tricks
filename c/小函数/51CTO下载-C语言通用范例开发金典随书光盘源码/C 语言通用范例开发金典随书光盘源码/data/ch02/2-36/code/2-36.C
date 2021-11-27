#include<stdio.h>
#include<math.h>

typedef struct complexnumber
{
   double rpart;
   double ipart;
}cnumber;

cnumber cpmul(cnumber a,cnumber b)
{
   cnumber value ;
   value.rpart=a.rpart * b.rpart -a.ipart * b.ipart;
   value.ipart=a.rpart * b.ipart +a.ipart * b.rpart;
   return  value;
}

main()
{
   
    cnumber a={-5.7,-6.5},b={2.9,7.3};
    cnumber value;
     value = cpmul(a,b);
	printf("\n The result is :%5.2lf",value.rpart);
        if(value.ipart>=0.0)     printf("+%5.2lfi",value.ipart);
        else                     printf("%5.2lfi",value.ipart);
 
}
