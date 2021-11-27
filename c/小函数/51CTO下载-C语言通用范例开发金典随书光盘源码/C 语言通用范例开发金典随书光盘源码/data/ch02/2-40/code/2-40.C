#include<stdio.h>
#include<math.h>

typedef struct complexnumber
{
   double rpart;
   double ipart;
}cnumber;

cnumber  cpexp(cnumber a)
{
   cnumber value ;
   
   value.rpart =exp(a.rpart)*cos(a.ipart);
   value.ipart =exp(a.rpart)*sin(a.ipart);
   return  value;
    
}

main()
{
   
    cnumber a={-3.2,-5.7},value;
    
    value = cpexp(a);
    printf("\nThe result is :%5.2lf",value.rpart);
      
        if(value.ipart>=0.0)     printf("+%5.2lfi",value.ipart);
        else                     printf("%5.2lfi",value.ipart);
        
     
}
