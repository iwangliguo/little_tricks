#include<stdio.h>
#include<dos.h>
main()
{
   struct date  curdt;
   getdate(&curdt);
   printf("\nCurrent date %02d-%02d-%04d",curdt.da_mon,curdt.da_day,curdt.da_year);
   curdt.da_year=2008;
   setdate(&curdt);
   getdate(&curdt);
   printf("\nAfter setting date %02d-%02d-%04d",curdt.da_mon,curdt.da_day,curdt.da_year);


}  

