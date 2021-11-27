#include<stdio.h>
main()
{
    FILE * input;
    if((input=fopen("Extemp.txt","w+"))==NULL)
       {
      printf("Error open Extemp.txt\n");
       }
       else
      {
         printf("Handle for Extemp.txt %d \n",input->fd);
         printf("Handle for stdin %d \n",stdin->fd);
         fclose(input);
      }
}