#include<stdio.h>
#include<dos.h> 
main() 
{ 
   printf("\n The status of Ctrl-Break %s",(getcbrk())?"On":"Off");
   setcbrk(1);
   printf("\n The status of Ctrl-Break %s",(getcbrk())?"On":"Off");
} 

