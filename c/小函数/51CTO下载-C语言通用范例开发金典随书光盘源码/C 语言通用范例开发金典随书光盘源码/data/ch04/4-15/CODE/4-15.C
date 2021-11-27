#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
main()
{
    int handle;
     char buf[128]="Hello the world \n";
	 if((handle=creat("\\tc\\ExNtemp.txt",S_IWRITE))==-1)
       {
       printf("\n Error open the file ExNtemp.txt");
      }
   else
        {
     
     printf("\nThe file ExNtemp.txt has created!");
     write(handle,buf,30);
     close(handle);
     }
}