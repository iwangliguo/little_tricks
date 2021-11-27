#include<stdio.h>
#include<dir.h>
#include<dos.h>
main()
{

struct dfree disk_info;
long disk_space;
getdfree(getdisk(),&disk_info);
disk_space=(long)disk_info.df_avail* (long)disk_info.df_bsec*(long)disk_info.df_sclus;
printf("Available disk space of the current dirve %c is%ld KB",getdisk()+'A',(long)(disk_space/1024));
}