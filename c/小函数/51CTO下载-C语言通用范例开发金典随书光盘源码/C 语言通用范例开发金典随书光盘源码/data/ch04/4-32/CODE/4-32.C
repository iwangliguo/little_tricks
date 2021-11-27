#include<stdio.h>
#include<io.h>
main()
{
   int handle;
   if((handle=creatnew("newEx.txt",0)==-1))
     {
      printf("\nError creat newEx.txt.");
     }
   else
     {
         printf("\nFile newEx.txt has created !");
         close(handle);
     }
 }
