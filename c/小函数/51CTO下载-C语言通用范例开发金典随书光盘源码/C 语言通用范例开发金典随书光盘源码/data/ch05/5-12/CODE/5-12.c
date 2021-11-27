#include<stdio.h>
#include <bios.h> 


main(void)
{ 
  int printstatus=0;
  printstatus=biosprint(2,0,0);
  if(printstatus&1)
   {
     printf("\n Time out!");
   }
  else if(printstatus&8)
  {
     printf("\n Input or output error!");
   
  }
  else if(printstatus&16)
  {
     printf("\n Print being selected!");
  }
  else if(printstatus&32)
  {
     printf("\n Out of paper!");
  }
  else if(printstatus&64)
  {
     printf("\n Acknowledge!");
  }
  else 
  {
     printf("\n Printer is not busy!");
  }
} 

