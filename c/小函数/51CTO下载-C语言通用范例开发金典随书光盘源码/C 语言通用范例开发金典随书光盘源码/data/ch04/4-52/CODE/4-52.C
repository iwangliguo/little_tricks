#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>

main()
{
     int handle,i;
     char buf[128]="Hello the world \n",c='\0';


   if((handle=open("\\tc\\ExATemp.txt",O_RDWR|O_CREAT,S_IWRITE))==-1)
      {
	   printf("\nError open the file ExTemp.txt");
      }
    else
     {

	  printf("\nThe file ExATemp.txt has created!");
      for(i=0;i<4;i++)
      {
     
       write(handle,buf,17);
        printf("\nNow the offset from the beginning of the file is %ld ",tell(handle)); 
      }

     
      write(handle,c,1);
       printf("\nNow the offset from the beginning of the file is %ld ",tell(handle)); 
      close(handle);

      }

   
}
