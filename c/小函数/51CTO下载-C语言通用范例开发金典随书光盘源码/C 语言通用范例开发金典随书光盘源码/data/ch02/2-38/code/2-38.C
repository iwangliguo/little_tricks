#include<stdio.h>
#include<math.h>

typedef struct complexnumber
{
   double rpart;
   double ipart;
}cnumber;

cnumber cppower(cnumber a,int n)
{
   cnumber value ;
   double  theta,r,rpower;
   r=sqrt(a.rpart*a.rpart +a.ipart* a.ipart);
   
   if(r!=0.0)
   {
   theta =atan2(a.ipart,a.rpart);
   rpower = pow(r,n);
   value.rpart=rpower *cos(n*theta);
   value.ipart=rpower *sin(n*theta);
   return  value;
   }
   
}

main()
{
   
    cnumber a={2.3,4.2},value;
    int n =3;
    
     value = cppower(a,3);
	printf("\n The result is :%5.2lf",value.rpart);
        if(value.ipart>=0.0)     printf("+%5.2lfi",value.ipart);
        else                     printf("%5.2lfi",value.ipart);
 
}
