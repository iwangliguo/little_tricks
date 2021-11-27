#include<stdio.h>
#include<mem.h>
main()
{
   int source[8]={1,2,3,4,5,6,7,8},dest[8],i;
   memmove(dest,source,sizeof(source));
   printf("\nAfter copy,the content of dest :");
   for(i=0;i<8;i++)
    {
     printf("%3d",dest[i]);
    }
} 

