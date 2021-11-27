#include<stdio.h>
#include<math.h>
#include<stdlib.h>

typedef struct complexnumber
{
   double rpart;
   double ipart;
}cnumber;



cnumber cpsub(cnumber a,cnumber b)
{
   cnumber value ;
   value.rpart=a.rpart - b.rpart ;
   value.ipart=a.ipart - b.ipart ;
   return  value;
}

 cnumber cpmul(cnumber a,cnumber b)
{
   cnumber value ;
   value.rpart=a.rpart * b.rpart -a.ipart * b.ipart;
   value.ipart=a.rpart * b.ipart +a.ipart * b.rpart;
   return  value;
}

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


void cppolydiv(cnumber p[],int m,cnumber q[],int n,cnumber s[],int k,cnumber r[],int l)

  { int i,j,mp,mrp;
    double t;
    cnumber temp;
    /*mp指向被除数-多项式p的位置*/
    for (i=0; i<=k-1; i++) 
     {
     s[i].rpart=0.0; /*初始化商*/
     s[i].ipart=0.0; /*初始化商*/
     }
     t =q[n-1].rpart*q[n-1].rpart+q[n-1].ipart*q[n-1].ipart;
    if(t!=0.0)
    {
  
    for (i=k,mp=1; i>=1; i--,mp++)
      { 
        s[i-1]=cpdiv(p[m-mp],q[n-1]);/* p[m-mp]/q[n-1]*/
       
        
        /*mrp只向mp位置的下一位，从新开始计算被除数*/
        for (mrp=m-mp,j=1; j<=n-1; j++)
          { 
             temp=cpmul(s[i-1],q[n-j-1]);
             p[mrp-j]=cpsub(p[mrp-j],temp);
            
          }

      }
    for (i=0; i<=l-1; i++) 
        {
           r[i].rpart=p[i].rpart; /*获得余数*/
           r[i].ipart=p[i].ipart; /*获得余数*/
        }
   }
  }


main()
  {
   
    cnumber p[3]={{-5.7,-6.5},{2.9,7.3},{3.4,2.1}};
    cnumber q[2]={{3.0,-1.0},{2.4,3.0}};
    cnumber s[2],r[1];
    int i,m,n,k,l;
    
    m=sizeof(p)/sizeof(cnumber);
    n=sizeof(q)/sizeof(cnumber);
    k=m-n+1;
    l=n-1;
    cppolydiv(p,m,q,n,s,k,r,l);

    printf("\ns[%d]={",k);
    for (i=0; i<k; i++)
      {
        if(i%2==0) printf("\n");
        printf("%5.2lf",s[i].rpart);
        if(s[i].ipart>=0.0)    printf("+%5.2lfi",s[i].ipart);
        else                  printf("%5.2lfi",s[i].ipart);
        if(i<k-1)  printf(",");
      }
    printf("}");
    
    printf("\nr[%d]={",l);
    for (i=0; i<l; i++)
      {
        if(i%2==0) printf("\n");
        printf("%5.2lf",r[i].rpart);
        if(r[i].ipart>=0.0)    printf("+%5.2lfi",r[i].ipart);
        else                  printf("%5.2lfi",r[i].ipart);
        if(i<l-1)  printf(",");
      }
   printf("}");
  }
