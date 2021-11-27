#include<stdio.h>
#include<io.h>
#include<fcntl.h>
#include<sys\stat.h>
#include<dos.h>
main()
{
     int handle;
     struct date dt,rdt;
     struct time tm,rtm;



   if((handle=creat("\\tc\\Extime.txt",S_IWRITE))==-1)
         /*创建文件*/
       {
       printf("\n Error creat the file Extime.txt");
       }
   else
       {
        printf("\nThe file Extime.txt has created!");
      	getdate	(&dt);
        /*获取日期*/
        gettime	(&tm);
        /*获取时间*/
        write(handle,&dt,sizeof(struct date));
        write(handle,&tm,sizeof(struct time));
        close(handle);

        if((handle=open("\\tc\\Extime.txt",O_RDONLY))==-1)
          /*打开文件*/
        {
       printf("\n Error open the file Extime.txt");
         }
      else
        {


        read(handle,&rdt,sizeof(struct date));
        read(handle,&rtm,sizeof(struct time));
        close(handle);

		printf("\nThe content of the file is:");
		printf("\n%u:%u:%u;", rtm.ti_hour, rtm.ti_min,rtm.ti_sec);
        printf("%u/%u/%u\n", rdt.da_mon, rdt.da_day, rdt.da_year);

	}
     }
}
