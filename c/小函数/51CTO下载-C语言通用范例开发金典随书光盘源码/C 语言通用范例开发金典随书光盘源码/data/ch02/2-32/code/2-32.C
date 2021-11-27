#include<stdio.h>
#include<math.h>
#include<stdlib.h>

 double * polymul(double p[],int m,double q[],int n)
  
  { 
    int i,j,k=m+n-1;
    double *val =(double *)malloc(k*sizeof(double));
    for (i=0; i<=k-1; i++) *(val+i)=0.0;
    
    for (i=0; i<=m-1; i++)
    for (j=0; j<=n-1; j++)
      *(val+i+j)=*(val+i+j)+p[i]*q[j];
    return  val;
  }
  

main()
  { 
	double p[3]={3.0,-6.7,2.1};
	double q[2]={2.4,3.5};
    double *valpq;
    int m,n,i;
    m=sizeof(p)/sizeof(double);
	n=sizeof(q)/sizeof(double);
	valpq=polymul(p,m,q,n);

    printf("\n valpq[%d]={",m+n-1);
    for (i=0; i<m+n-1; i++)
      printf("%5.2lf ",*(valpq+i));


    printf("}");
  }
