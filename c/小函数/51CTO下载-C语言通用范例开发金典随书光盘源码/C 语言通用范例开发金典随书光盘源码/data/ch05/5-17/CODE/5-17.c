#include <stdio.h> 
#include <bios.h> 

main() 
{ 
  int msize;
  msize=biosmemory();
  printf("\nBIOS regular memory size is %dKb",msize);
  
} 

