#include<stdio.h>
#include<math.h>
#define PI 3.1415926
typedef struct complexnumber
{
   double rpart;
   double ipart;
}cnumber;

cnumber * cproot(cnumber a,int n)
{
   cnumber * value =NULL,*vp;
   double  theta,r,t;
   int k;
   
   
   if(n>0)
   {
   
       r=sqrt(a.rpart*a.rpart +a.ipart* a.ipart);
       theta =atan2(a.ipart,a.rpart);
       value =(cnumber * )malloc(n*sizeof(cnumber));
   if(r!=0.0)
   {
     r=pow(r,1.0/n);
     for(k=0,vp=value;k<=n-1;k++,vp++)
     {
     t=(2.0*k*PI+theta)/n;
     
     vp->rpart=r*cos(t);
     vp->ipart=r*sin(t);
     }
   
      return  value;
    }
   }
}

main()
{
   
    cnumber a={3.2,1.7},*value,*vp;
    int n =4,i;
    
     value = cproot(a,n);
     printf("\nvalue[%d]={",n);
     for(vp=value,i=0;i<n;i++,vp++)
     {
	if(i%2==0) printf("\n");
        printf("%5.2lfe",vp->rpart);
        if(vp->ipart>=0.0)     printf("+%5.2lfi",vp->ipart);
        else                     printf("%5.2lfi",vp->ipart);
        if(i<n-1)  printf(",");
      }
     printf("}");
}
