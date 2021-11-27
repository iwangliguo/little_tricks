#include<stdio.h>
#include<io.h>
main()
{
   int access_mod,i;
   FILE * fp;
   char c ='a';
   
     if((fp=fopen("Extemp.txt","w+"))!=NULL)
      {
         for(i=0;i<20;i++)
             fputc(c,fp);
         fclose(fp);
       }
     access_mod = access("Extemp.txt",0);
     if(access_mod!=0)
       {
          printf("\nFile:Extemp.txt does not exist !\n");
       }
     else
      {
            access_mod = access("Extemp.txt",2);
            if(access_mod!=0)
            {
            printf("File:Extemp.txt can not be written !\n");
            }
            else
            {
            printf("File:Extemp.txt can be written ! \n");
            }
            access_mod = access("Extemp.txt",4);
            if(access_mod!=0)
            {
            printf("File:Extemp.txt can not be read !\n");
            }
            else
            {
            printf("File:Extemp.txt can be read! \n");
            }
            access_mod = access("Extemp.txt",6);
            if(access_mod!=0)
            {
            printf("File:Extemp.txt can  be neither  read  nor  written!\n");
            }
            else
            {
            printf("File:Extemp.txt can be read and written!\n");
            }
            
      } 
}