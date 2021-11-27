#include <stdio.h> 
#include <stdlib.h> 
#include <time.h>
main() 
{ 
int i; 
   time_t t; 

   srand((unsigned) time(&t)); 
   printf("\nTen random numbers from 0 to 99\n"); 
   for(i=0; i<10; i++) 
       printf("%d .", rand() %100); 

} 

