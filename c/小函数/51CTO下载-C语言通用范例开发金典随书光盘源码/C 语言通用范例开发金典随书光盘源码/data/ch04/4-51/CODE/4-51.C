#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>

#define dup_handle2 12

main()
{
     FILE *fp;
     int handle,i;
     char buf[128]="Hello the world \n",*temp,c='\0',tbuf[128];


   if((handle=open("\\tc\\ExATemp.txt",O_RDWR|O_CREAT,S_IWRITE))==-1)
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

      if((i=dup2(handle,dup_handle2))==-1)
      {printf("\n Error duplicate  handle of the file ExTemp.txt");}
       else
     {
      write(dup_handle2,"Using dup_handle2\n",sizeof("Using dup_handle2\n")-1);
      write(dup_handle2,buf,17);
      write(dup_handle2,c,1);
      close(dup_handle2);

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
   }

}
