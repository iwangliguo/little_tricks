#include<stdio.h>
#include<stdlib.h>
main()
{  
   char * pathname,*filename="";
   FILE * fp;
   char c ='a';
   int i ;
   pathname =getenv("TEMP");
   filename =strcat(pathname,"\\Extemp.txt");
    
     if((fp=fopen(filename,"w+"))!=NULL)
      {
         for(i=0;i<20;i++)
             fputc(c,fp);
        
       
         rewind(fp); 
         printf("\nThe name of the file is");
         printf("\n%s",filename);
         printf("\nThe content of the file is");
         printf("\n");

         while((c=fgetc(fp))!=EOF)
             printf("%c",c);
 	 fclose(fp);

     }
}