#include<stdio.h>
main()
{
    FILE * fp;
    char c ='a';
    int i ;
 
       if((fp=fopen("Extemp.txt","w+"))!=NULL)
      {
        printf("\n Extemp.txt has created!"); 
        for(i=0;i<20;i++)
             fputc(c+i,fp);
         fclose(fp);
       }
        remove("Extemp.txt");
        if((fp=fopen("Extemp.txt","r"))==NULL)
      {
         printf("\n Extemp.txt has removed!"); 
       }
    
}