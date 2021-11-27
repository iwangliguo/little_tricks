#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
#include<time.h>
main()
{
   FILE * fp;
   int handle,result;
   char *c="Hello the world";
   struct stat statbuf;



   if((fp=fopen("Extem1.txt","w+"))!=NULL)
      {
         fputs("You are welcome", fp);
         fputc(':', fp);
         fprintf(fp,"\n%s",c);
         fputc('\0', fp);
         fclose(fp);
       }


   if((handle=open("Extem1.txt",O_RDONLY))==-1)
   {
    printf("\n Error open Extem1.txt!");
   }
   else
   {
    if (result=(fstat(handle,&statbuf))!=0)
    {
     printf("\n Error get the file information!");
    }
    else
    {
	 printf("\nExtem1.txt is %ld bytes ",statbuf.st_size);
          printf("\nand last modified %s ",ctime(&statbuf.st_mtime));
     close(handle);
    }
   }


  
}


