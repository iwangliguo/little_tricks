#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
main()
{
     int handle,i;
	 char buf[128]="Hello the world \n",*temp,c='\0';
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
     close(handle);
	 printf("\nThe content of the file is:\n");
	 handle=open("\\tc\\ExNtemp.txt",O_RDONLY,S_IREAD);
	  while(!eof(handle))
          /*判断文件句柄是否到达文件尾部*/
      {
		read(handle,temp,100);
		printf("%s",temp);
      }
	close(handle);
     }
}