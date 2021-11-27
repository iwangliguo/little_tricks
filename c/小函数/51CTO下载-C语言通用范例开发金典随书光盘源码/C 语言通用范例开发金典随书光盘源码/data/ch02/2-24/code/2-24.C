#include <stdio.h> 
#include <stdlib.h> 

main() 
{ 
int i;

   printf("\nTen random numbers from 0 to 99\n");
   for(i=0; i<10; i++)
      printf("%d .", rand() %100);
        
  

} 

