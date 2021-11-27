#include<stdio.h>
#include<bios.h>
main()
{
  char buf[1024*8];
  if(biosdisk(2,0,1,1,1,1,buf))
     {printf("Failure accessing floppy driver.\n");}
  else
     {printf("Floppy driver is ready!");}  
}