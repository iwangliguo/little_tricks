#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
main()
{
    int handle;
     if((handle=creat("\\ExNtemp.txt",S_IWRITE))==-1)
       {
      printf("\n Error open the file ExNtemp.txt");
      }
   else
        {
     printf("\nThe file ExNtemp.txt has created!");
     close(handle);
     }
}