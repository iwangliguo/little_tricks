#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
main()
{
     int handle,i,previous_mode;
     char buf[128]="Hello the world \n",c='\0';
      
      previous_mode =umask(S_IWRITE);

   if((handle=creat("\\tc\\ExMtemp.txt",S_IWRITE))==-1)
      {
       printf("\n Error open the file ExNtemp.txt");
      }
    else
     {

      printf("\nThe file ExMtemp.txt has created!");
      for(i=0;i<4;i++)
      {
        write(handle,buf,17);
      }
      write(handle,c,1);
      close(handle);


     

     if((handle=open("\\tc\\ExMtemp.txt", O_RDONLY))==-1)
     {
	   printf("\nError open the file ExNtemp.txt for read");
     }
     else
     {
          printf("\nFile successful read!");
	  close(handle);
	 }

     if((handle=open("\\tc\\ExMtemp.txt",O_WRONLY))==-1)
     {
	   printf("\nError open the file ExNtemp.txt for written");
     }
     else
     {
          write(handle,buf,17);
          printf("\nFile successful written to !");
	  close(handle);
	 }

	 }
}
