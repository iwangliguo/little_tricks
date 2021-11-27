#include<stdio.h>
#include<math.h>

typedef struct complexnumber
{
   double rpart;
   double ipart;
}cnumber;

cnumber  cplog(cnumber a)
{
   cnumber value ;
   
   value.rpart =log(sqrt(a.rpart*a.rpart+a.ipart*a.ipart));
   value.ipart =atan2(a.ipart,a.rpart);
   return  value;

}

main()
{

	cnumber a={-1.0,3.6},value;

    value = cplog(a);
    printf("\nThe result is :%5.2lf",value.rpart);

        if(value.ipart>=0.0)     printf("+%5.2lfi",value.ipart);
        else                     printf("%5.2lfi",value.ipart);


}
