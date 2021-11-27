#include<stdio.h>
#include<math.h>



int  itervalrnd(int a,int b ,int *r)
  
  {  
     int s ,m ,ri,t,value;
   
     s =b-a+1;
     for(m=2;m<s;m=m+m)
        {;}
	 ri=*r;
	while(1)
      {
        ri=ri*5%(4*m);
        t=ri/4+a;
        if(t<=b)
        {
           value =t;
           break;
        }
      }
    *r=ri;
    return value;

  }

main()
  {
    int a,b,r;
    a=30;b=60;r=3;
    printf("\nThe number is:");
    printf("%d",itervalrnd(a,b,&r));


  }
