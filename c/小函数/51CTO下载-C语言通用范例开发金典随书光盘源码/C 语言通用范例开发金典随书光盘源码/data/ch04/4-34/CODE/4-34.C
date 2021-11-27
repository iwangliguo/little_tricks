#include<stdio.h>
#include<dir.h>
main()
{

   FILE * fp;
   char *c="Hello the world",*path;



   if((fp=fopen("Exfile.txt","w+"))!=NULL)
      {
         fputs("\nYou are welcome", fp);
         fputc(':', fp);
         fprintf(fp,"\n%s",c);
         fprintf(fp,"\n%s",c);
         fprintf(fp,"\n%s",c);
         fclose(fp);
       }
   if(path =searchpath("Exfile.txt"))
      {
	   printf("\nThe pathname of Exfile.txt is");
		printf("\n%s",path);
     }
   else
      {
	   printf("\nThe  Exfile.txt can not found");
     }

}