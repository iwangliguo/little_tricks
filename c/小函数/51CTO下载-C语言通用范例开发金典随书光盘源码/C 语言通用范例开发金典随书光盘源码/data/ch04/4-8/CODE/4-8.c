#include<stdio.h>
main()
{
   FILE * fp;
   if((fp=fopen("Extemp.txt","r"))!=NULL)
     {
       printf("Extemp.txt successfully opened!");
     }
   else 
    {
      printf("Extemp.txt can't be opened!");
    }
}