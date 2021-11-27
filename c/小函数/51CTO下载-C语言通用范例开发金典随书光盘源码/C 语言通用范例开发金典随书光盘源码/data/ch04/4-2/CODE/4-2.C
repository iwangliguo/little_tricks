#include<stdio.h>
#include<dir.h>
main()
{
   int driver_count ;
   driver_count = setdisk(3);
   printf("The number of available dirve is %d \n",driver_count);
}