#include<stdio.h>
#include<dos.h>
main()
{
   struct date  curdt;
   gettime(&curdt);
   printf("\nCurrent date %02d-%02d-%04d",curdt.da_mon,curdt.da_day,curdt.da_year);

} 
