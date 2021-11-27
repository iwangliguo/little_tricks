#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
main()
{
     int handle,i;
     long position =0;
     char buf[128]="Hello the world \n",*temp,c='\0';
     struct ftime ft,mft;

      mft.ft_hour =mft.ft_min=mft.ft_tsec=0;
      mft.ft_month=mft.ft_day=8;
       mft.ft_year=28;

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
        getftime(handle, &ft);
        printf("\nThe last visited time is ");
        printf("\n%u:%u:%u ;", ft.ft_hour, ft.ft_min, ft.ft_tsec*2);
	printf("%u/%u/%u", ft.ft_month, ft.ft_day, ft.ft_year+1980);

	setftime(handle, &mft);
        getftime(handle, &ft);
        printf("\nAfter modified the last visited time is");
        printf("\n%u:%u:%u ;", ft.ft_hour, ft.ft_min, ft.ft_tsec*2);
        printf("%u/%u/%u\n", ft.ft_month, ft.ft_day, ft.ft_year+1980);
        
	close(handle);
     }
}