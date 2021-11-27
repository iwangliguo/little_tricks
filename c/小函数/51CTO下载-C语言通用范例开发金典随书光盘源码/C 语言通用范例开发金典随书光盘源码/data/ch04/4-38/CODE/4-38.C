#include<stdio.h>
main()
{
    FILE * fp;
    char c ='a';
    int i ;
 
       if((fp=fopen("Extemp.txt","w+"))!=NULL)
      {
             printf("Current position is %ld",ftell(fp));
             for(i=0;i<20;i++)
              { fputc(c+i,fp);
             if(i%6==0)
             printf("\nCurrent position is %ld",ftell(fp));
               }
         fclose(fp);
          
      }
    
}