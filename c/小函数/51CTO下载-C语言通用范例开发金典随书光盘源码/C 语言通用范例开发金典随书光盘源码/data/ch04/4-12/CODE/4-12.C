#include<stdio.h>

main()
{
   FILE * fp1,*fp2;
   char *c="Hello the world";
   int file_number;


   if((fp1=fopen("Infile1.txt","w+"))!=NULL)
      {
         fputs("\nYou are welcome", fp1);
         fputc(':', fp1);
         fprintf(fp1,"\n%s",c);

       }

    if((fp2=fopen("Infile2.txt","w+"))!=NULL)
     {

         fputs("\nYou are welcome", fp2);
         fputc(':', fp2);
         fprintf(fp2,"\n%s",c);
     }

      file_number =fcloseall();
	  printf("\n%d files colsed",file_number);

}