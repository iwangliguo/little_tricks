#include<stdio.h>
#include<io.h>
main()
{
   FILE * fp,*stream;
   char *c="Hello the world",s[128];



   if((fp=fopen("Extem1.txt","w+"))!=NULL)
      {
         fputs("\nYou are welcome", fp);
         fputc(':', fp);
         fprintf(fp,"\n%s",c);  
           fputc('\0', fp);
          
         fclose(fp);
       }
   


 if(((fp=fopen("Extem1.txt","rb"))!=NULL&&(stream=fopen("Extem2.txt","w+"))!=NULL))
     {
       	    while(!feof(fp))
             {
                fgets(s,sizeof(s),fp);
                   fputs(s,stream);
			  printf("%s",s);
             }
             fclose(fp);
            fclose(stream);
     }

  
}
