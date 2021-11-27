#include<stdio.h>
#include<dos.h>
#include<io.h>
#include<dir.h>
main(void)
{
   char path[128]="c:\\Mytemp\\";
   int handle;
    if(mkdir("c:\\Mytemp"))
      /*´´½¨Ä¿Â¼*/
      {
          printf("\nthe c:\\Mytemp\\ has sucessful ceeated!");
         if((handle=creattemp(path,0))==-1)
         {
	     printf("\nError creating file");
         }
         else
         {
	   printf("\nComplete file path:\%s",path);
			  close(handle);
          }

       }

   
  
} 

