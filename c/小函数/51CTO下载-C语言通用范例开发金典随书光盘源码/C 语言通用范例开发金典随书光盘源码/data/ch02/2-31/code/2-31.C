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

cnumber cpadd(cnumber a,cnumber b)
{
   cnumber value ;
   value.rpart=a.rpart + b.rpart ;
   value.ipart=a.ipart + b.ipart ;
   return  value;
}
cnumber cppolyval(cnumber a[],int n,cnumber x)
{
    int i;
    cnumber val={0.0,0.0};
     
	 for(i=n;i>=1;i--)
           {
                val=cpmul(val,x);/*  val=val*x */
                val=cpadd(val,a[i-1]);/* val=val+a[i-1];*/
             }
            
    return val;
}

main()
  {
	cnumber a[4]={{2.2,1.3},{-2.0,-1.9},{1.5,1.3}},x={-1.6,1.5},value;
        value = cppolyval(a,3,x);
	printf("\n The result is :%5.2lf",value.rpart);
        if(value.ipart>=0.0)     printf("+%5.2lfi",value.ipart);
        else                     printf("%5.2lfi",value.ipart);
        
  }


