#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
main()
{
    int handle;
	if((handle=open("Extemp.txt",O_CREAT,S_IWRITE))==-1)
       {
      printf("\n Error open the file Extemp.txt");
      }
   else
        {
     printf("\nThe file Extemp.txt has created!");
     printf("\nThe file Extemp.txt has opened!");
     close(handle);
     }
}