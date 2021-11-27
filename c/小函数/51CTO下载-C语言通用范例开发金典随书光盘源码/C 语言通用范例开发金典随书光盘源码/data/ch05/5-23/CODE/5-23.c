#include <stdio.h>
#include <stdlib.h>
main()
{
   char s1[50]="asdfdafdafadfg\0",s2[50]="\0";
   printf("\nBefore swab s1:%s;s2:%s",s1,s2 );

   swab(s1,s2,sizeof(s1));
	printf("\nAfter swab s1:%s;\n\t   s2:%s",s1,s2 );

  

} 

