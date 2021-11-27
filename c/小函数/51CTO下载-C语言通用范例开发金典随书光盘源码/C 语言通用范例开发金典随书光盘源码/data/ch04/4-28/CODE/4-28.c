#include<stdio.h>
main()
{
   char buffer[128];
   int counter;
   for(counter=0;counter<3;counter++)
     printf(" \nTemporary file is %s ",tmpnam(buffer));

}