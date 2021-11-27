#include<stdio.h>
main()
{
   FILE * inputfile,*outputfile;
   char *c="Hello the world";
   char line[256];


   if((inputfile=fopen("Infile.txt","w+"))!=NULL)
      {
         fputs("\nYou are welcome", inputfile);
         fputc(':', inputfile);
         fprintf(inputfile,"\n%s",c);
         fclose(inputfile);
       }
    if((inputfile=fopen("Infile.txt","r"))!=NULL)
    {
    if((outputfile=fopen("Outfile.txt","w+"))!=NULL)
     { 
       while(fgets(line,sizeof(line),inputfile))
        {
           puts(line); 
            fputs(line,outputfile);
            fflush(outputfile);
        }
     }
     fclose(outputfile);
      fclose(inputfile);
    }
}