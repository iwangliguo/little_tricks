#include<stdio.h>
main()
{
   FILE * fp ;
   char *c="Hello the world" ;
   if((fp=fopen("Extem1.txt","w+"))!=NULL)
      {
         fputs("You are welcome", fp);
         fputc(':', fp);
         fprintf(fp,"\n%s",c);
         fclose(fp);
       }
  }

