#include<stdio.h>
main()
{
   int i;
   FILE * fp;
   char *c="Hello the world";
   char line[256];


   if((fp=fopen("Exfile.txt","w+"))!=NULL)
      {
		 fputs("\nYou are welcome", fp);
         fputc(':', fp);
         fprintf(fp,"\n%s",c);
         fclose(fp);
       }
    if(fp=fopen("Exfile.txt","r"))
      {
         while(fgets(line,sizeof(line),fp))
          {
            if(ferror(fp))
             {
              fprintf(stderr,"Error reading from Exfile.txt \n");
              exit(0); 
             }
             else
             {
              fputs(line,stdout);
              if(ferror(fp))
             {
              fprintf(stderr,"Error writing to stdout \n");
              exit(0); 
             }
              }
          }
       }
    else
    {
     printf("Error opening Exfile.txt \n");
    }
}