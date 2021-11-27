#include<stdio.h>
#include<dos.h> 
 main() 
{ 
   int drive;
   drive=bdos(0x19,0,0);
   printf("\nCrruent driver is %c",'A'+drive);
  
} 

