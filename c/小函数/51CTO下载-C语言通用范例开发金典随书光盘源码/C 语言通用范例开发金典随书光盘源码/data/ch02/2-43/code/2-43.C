#include<stdio.h>
#include<math.h>

typedef struct complexnumber
{
   double rpart;
   double ipart;
}cnumber;

cnumber  cpcos(cnumber a)
{
   cnumber value ;
   
   value.rpart =cos(a.rpart)*(exp(a.ipart)+exp(-a.ipart))/2.0;
   value.ipart =-sin(a.rpart)*(exp(a.ipart)-exp(-a.ipart))/2.0;
   return  value;
    
}

main()
{
   
    cnumber a={-1.6,4.9},value;
    
    value = cpcos(a);
    printf("\nThe result is :%5.2lf",value.rpart);
      
        if(value.ipart>=0.0)     printf("+%5.2lfi",value.ipart);
        else                     printf("%5.2lfi",value.ipart);
        
     
}
