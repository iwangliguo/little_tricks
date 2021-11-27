#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
main()
{
     int handle,i;
     long position =0;
     char buf[128]="Hello the world \n",*temp,c='\0';
     struct ftime ft;
	if((handle=creat("\\tc\\ExNtemp.txt",S_IWRITE))==-1)
       {
       printf("\n Failed to creat the file ExNtemp.txt");
      }
    else
       {

     printf("\nThe file ExNtemp.txt has created!");
      for(i=0;i<4;i++)
      {
	  write(handle,buf,17);
	  }
	 write(handle,c,1);
        getftime(handle, &ft);
		printf("\nThe last visited time is %u:%u:%u ;", ft.ft_hour, ft.ft_min, ft.ft_tsec*2);
        printf("%u/%u/%u\n", ft.ft_month, ft.ft_day, ft.ft_year+1980);

        
	close(handle);
     }
}