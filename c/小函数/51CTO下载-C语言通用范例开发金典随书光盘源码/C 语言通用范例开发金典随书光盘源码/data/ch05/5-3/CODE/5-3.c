#include <stdio.h> 
#include<time.h>

 main() 
{ 
   time_t start_time,end_time;
   time(&start_time);
   do
   {
     time(&end_time);
   }while(difftime(end_time,start_time)<5.00);
   printf("\The programme has delay 5 seconds!");

}


