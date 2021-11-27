#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
main()
{
   int i,file_handle;
   long file_size;
   FILE * fp;
   char *c="Hello the world";
   char line[256];


   if((fp=fopen("Exfile.txt","w+"))!=NULL)
      {
         fputs("\nYou are welcome", fp);
         fputc(':', fp);
         fprintf(fp,"\n%s",c);
         fprintf(fp,"\n%s",c);
         fprintf(fp,"\n%s",c);
         fclose(fp);
       }
    if((file_handle=open("Exfile.txt",O_RDONLY))==-1)
      {
		 printf("\nError opening the file :Exfile.txt!");
      }
    else
      {
        file_size =filelength(file_handle);
		printf("\nThe file size in bytes is %ld",file_size);
        close(file_handle);
      }
}