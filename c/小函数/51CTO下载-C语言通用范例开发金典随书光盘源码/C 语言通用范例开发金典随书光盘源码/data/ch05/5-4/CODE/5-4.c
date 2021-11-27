#include<stdio.h> 
#include<dos.h>

main() 
{ 
   long ticks;
   ticks =biostime(0,ticks);
   printf("\n Ticks since midnight %ld \n", ticks);
  
} 

