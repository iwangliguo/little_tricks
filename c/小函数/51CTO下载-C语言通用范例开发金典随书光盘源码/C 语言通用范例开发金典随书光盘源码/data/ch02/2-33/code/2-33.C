#include<stdio.h>
#include<math.h>
#include<stdlib.h>

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

 cnumber * cppolymul(cnumber p[],int m,cnumber q[],int n)
  
  { 
    int i,j,k=m+n-1;
    cnumber *cpval =(cnumber *)malloc(k*sizeof(cnumber));
    cnumber temp,*tp;
    for (i=0,tp=cpval; i<=k-1; i++,tp++)
       {
       tp->rpart=0.0;
       tp->ipart=0.0;
       }
    for (i=0; i<=m-1; i++)
    for (j=0; j<=n-1; j++)
       {
          temp=cpmul(p[i],q[j]); /*p[i]*q[j]*/
          *(cpval+i+j)=cpadd(*(cpval+i+j),temp);
       }
    return  cpval;
  }


main()
  {
	cnumber p[3]={{-5.7,-6.5},{2.9,7.3},{3.4,2.1}};
	cnumber q[2]={{3.0,-1.0},{2.4,3.0}};
    cnumber *valpq,*tp;
    int m,n,i;
    m=sizeof(p)/sizeof(cnumber);
	n=sizeof(q)/sizeof(cnumber);
	valpq=cppolymul(p,m,q,n);

    printf("\nvalpq[%d]={",m+n-1);
    for (i=0,tp=valpq; i<m+n-1; i++,tp++)
      {
      if(i%2==0) printf("\n");
     
      printf("%5.2lf",tp->rpart);
      if(tp->ipart>=0.0)    printf("+%5.2lfi",tp->ipart);
      else                  printf("%5.2lfi",tp->ipart);

      if(i<m+n-2)    printf(",");
      
      }    
    printf("}");
  }
