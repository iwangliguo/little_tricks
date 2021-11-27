#include<stdio.h>
#include<io.h>
main()
{
   FILE * fp,*stream;
   char *c="Hello the world";
   int  handle;
   long file_length;


   if((fp=fopen("Extemp.txt","w+"))!=NULL)
      {
         fputs("\nYou are welcome", fp);
         fputc(':', fp);
         fprintf(fp,"\n%s",c);
         fclose(fp);
       }
   if((stream=fopen("Extemp.txt","r"))!=NULL)
     {
       handle =fileno(stream);
       file_length =filelength(handle);
	   printf(" \nThe filelength is %ld",file_length);
     }
   else
     {
	   printf("\nCan't open the file!");
     }
}