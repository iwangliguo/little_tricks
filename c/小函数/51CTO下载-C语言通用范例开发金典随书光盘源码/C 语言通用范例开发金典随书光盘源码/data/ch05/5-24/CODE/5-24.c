#include<stdio.h>
#include<alloc.h> 

main(void) 
{ 
    int *ptr ;
    printf("\n the start address available for heap:%u",coreleft());
    
    ptr=(int *)malloc(sizeof(int));
    printf("\n the end address available for heap:%u",coreleft());
    if(brk(ptr+128)==0)
    {
    printf("\n After modify,the end address available for heap:%u",coreleft());
    }

} 

