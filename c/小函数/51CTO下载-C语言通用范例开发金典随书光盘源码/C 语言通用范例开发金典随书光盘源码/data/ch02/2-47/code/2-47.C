#include<stdio.h>
#include<math.h>



int *  itervalrndsq(int a,int b ,int *r,int n)
  
  {  
     int s ,m ,ri,t,*value,*vp,i;
   
     s =b-a+1;
     for(m=2;m<s;m=m+m)
        {;}
     ri=*r;
     value=(int *)malloc(n*sizeof(int));

     for(i=0,vp=value;i<n;)
      {
        ri=ri*5%(4*m);
        t=ri/4+a;
        if(t<=b)
        {
           *(vp+i)=t;
		   i++;
        }
      }
    *r=ri;
    return value;

  }

main()
  {
    int a,b,r,n,*value,*vp,i;
    a=30;b=60;r=3;n=10;
    value=itervalrndsq(a,b,&r,n);

    printf("\nThe squence is:");
    for(i=0,vp=value;i<n;i++)
      {
       if(i<n-1)  {printf("%d,",*(vp+i));}
       else       {printf("%d!",*(vp+i));}
       }
  }
