#include<stdio.h>
main()
{
    FILE * fp;
   if((fp=fopen("Extemp.txt","r"))!=NULL)
     {
       printf("\nExtemp.txt successfully opened!\n");
       if(fclose(fp)==EOF)
            {
          printf("\nExtemp.txt failured closed!\n");
            }
       else
          {
           printf("\nExtemp.txt successfully closed!\n");
          }
     }
   else 
    {
      printf("Extemp.txt can't be opened!");
       if((fp=fopen("Extemp.txt","w+"))!=NULL)
      {
         printf("\nExtemp.txt successfully opened and created!");
         if(fclose(fp)==EOF)
            {
          printf("\nExtemp.txt failured closed!\n");
            }
       else
          {
           printf("\nExtemp.txt successfully closed!\n");
          }
      }
    }
}