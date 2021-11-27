#include <stdio.h>
#include <dos.h>

main( )
{
	unsigned  segment =0xe00,offset;
	printf("\n");
	for(offset=0;offset<200;offset++)
	   printf("%c",peekb(segment,offset));
}

