#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
#include<dos.h>
main()
{
     int handle,i,result;
     long position =0;
     char buf[128]="Hello the world \n", c='\0';
       

   if((handle=creat("\\tc\\ExNtemp.txt",S_IWRITE))==-1)
      {
       printf("\n Error open the file ExNtemp.txt");
      }
    else
     {

      printf("\nThe file ExNtemp.txt has created!");
      for(i=0;i<4;i++)
      {
        write(handle,buf,17);
      }
      write(handle,c,1);

      printf("\nThe original file size is %ld .",filelength(handle));

      close(handle);

      
	  

     if((handle=open("\\tc\\ExNtemp.txt",O_RDWR,S_IWRITE))==-1)
     {
	   printf("\nError open the file ExNtemp.txt");
     }
     else
     {
         if((result=chsize (handle,200l))==-1)
         {
         printf("\nError change the file size!");
         }
         
		 printf("\nAfter change the file size is %ld .",filelength(handle));
         
         close(handle);
       }
     }
}
