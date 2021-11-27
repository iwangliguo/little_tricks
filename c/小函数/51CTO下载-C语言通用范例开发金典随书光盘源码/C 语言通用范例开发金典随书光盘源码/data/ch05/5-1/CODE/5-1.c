#include <stdio.h>
#include<time.h>

 main()
{
   time_t tm;
   time(&tm);
  printf("\nThe current date and time is:%s",ctime(&tm));

} 

