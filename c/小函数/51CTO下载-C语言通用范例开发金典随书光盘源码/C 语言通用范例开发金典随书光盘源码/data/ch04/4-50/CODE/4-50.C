#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
main()
{
	 FILE *fp;
     int handle,dup_handle,i;
	 char buf[128]="Hello the world \n",*temp,c='\0',tbuf[128];


   if((handle=open("ExATemp.txt",O_RDWR|O_CREAT,S_IWRITE))==-1)
      {
	   printf("\nError open the file ExTemp.txt");
      }
    else
     {

	  printf("\nThe file ExATemp.txt has created!");
      for(i=0;i<2;i++)
      {
        write(handle,buf,17);
      }

      if((dup_handle=dup(handle))==-1)
      {printf("\n Error duplicate  handle of the file ExTemp.txt.txt");}
       else
     {

      write(dup_handle,"Using dup_handle\n",sizeof("Using dup_handle\n")-1);
      write(dup_handle,buf,17);
      write(handle,c,1);
      close(handle);

      }

	}
	printf("\n");
     if((fp=fopen("ExATemp.txt","r"))!=NULL)
     {
    	while(fgets(tbuf,sizeof(tbuf),fp))
        {
		   printf("%s",tbuf);
          }


     fclose(fp);
    }

}