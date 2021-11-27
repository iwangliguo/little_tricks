#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
main()
{
     int handle,old_mode;
	 char buf[128]="Hello the world \n",*temp,c='\0';
	 if((handle=creat("\\tc\\ExNtemp.txt",S_IWRITE))==-1)
       {
       printf("\n Error open the file ExNtemp.txt!");
      }
    else
       {
         printf("\nThe file ExNtemp.txt has created!");
         if((old_mode=setmode(handle,O_TEXT))==-1)     
          {
	   printf("\nError change file mode! ");
          }
         else
          {
	   printf("\nThe file mode has changed to O_TEXT! ");
          }
	close(handle);
     }
}