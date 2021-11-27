#include<stdio.h> 
#include<sys\timeb.h>
#include<time.h>
main() 
{ 
   struct timeb tz;
   tzset();
   ftime(&tz);
   printf("\nSeconds since 1-1-1970(GMT) is %ld.%ld",tz.time,tz.millitm);
   printf("\n Minintes difference between local zone and GMT zone is %d",tz.timezone);

  
} 

