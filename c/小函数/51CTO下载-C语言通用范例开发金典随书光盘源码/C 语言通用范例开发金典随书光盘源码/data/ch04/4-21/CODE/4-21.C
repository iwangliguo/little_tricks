#include<stdio.h>
main()
{
static char buf[BUFSIZ];
 setbuf(stdout, buf);

   puts("\noutput will go into buf");
   puts("unless the buffer filled up"); 
   puts("or we flush the stream.");
   fflush(stdout);
   /*强制刷新stdout流*/
   printf("\nThe content of the buf is:%s",buf);
 


}