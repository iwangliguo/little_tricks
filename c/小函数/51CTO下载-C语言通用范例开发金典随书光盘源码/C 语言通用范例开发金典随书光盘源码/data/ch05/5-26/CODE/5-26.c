#include <stdio.h>
#include <dos.h>

main( )
{
	unsigned  segment =0x2e00,offset,i;
        char value='a';
	printf("\n");
	for(offset=0,i=0;offset<20;offset++,i++)
           {
		 pokeb(segment,offset,value+i);
			 printf("%c",peekb(segment,offset));
           }
}

