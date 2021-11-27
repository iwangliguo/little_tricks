#include<stdio.h>
#include<math.h>


 void polydiv(double p[],int m,double q[],int n,double s[],int k,double r[],int l)

  { int i,j,mp,mrp;
    /*mp指向被除数-多项式p的位置*/
    for (i=0; i<=k-1; i++) s[i]=0.0; /*初始化商*/
    
    if(q[n-1]!=0.0)
    {
  
    for (i=k,mp=1; i>=1; i--,mp++)
      { 
        
        s[i-1]=p[m-mp]/q[n-1];
        
        /*mrp只向mp位置的下一位，从新开始计算被除数*/
        for (mrp=m-mp,j=1; j<=n-1; j++)
          { 
             p[mrp-j]=p[mrp-j]-s[i-1]*q[n-j-1];
          }

      }
    for (i=0; i<=l-1; i++) r[i]=p[i]; /*获得余数*/
   }
  }


main()
  {
   
    double p[6]={4.0,-3.4,7.0,-4.3,5.2};
    double q[4]={3.5,5.0,-6.4,7.0};
    double s[3],r[3];
    int i,m,n,k,l;
    
    m=sizeof(p)/sizeof(double);
    n=sizeof(q)/sizeof(double);
    k=m-n+1;
    l=n-1;
    polydiv(p,m,q,n,s,k,r,l);

    printf("\ns[%d]={",k);
    for (i=0; i<k; i++)
      printf(" %5.2lf ",s[i]);
     printf("}");
    
    printf("\nr[%d]={",l);
    for (i=0; i<l; i++)
      printf(" %5.2lf ",r[i]);
   printf("}");
  }
