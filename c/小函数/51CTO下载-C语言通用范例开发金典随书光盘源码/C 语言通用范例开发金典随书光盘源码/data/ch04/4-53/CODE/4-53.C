#include<stdio.h>
#include<io.h>
main()
{
   FILE * fp;
   char *c="Hello the world",s[128];



   if((fp=fopen("Extem1.txt","w+"))!=NULL)
      {
	 fputs("You are welcome", fp);
         fputc(':', fp);
         fprintf(fp,"\n%s",c);
         fputc('\0', fp);
         fclose(fp);
       }
 if((fp=fopen("Extem1.txt","rb"))!=NULL)
   {
	 printf("\nthe content of the file is\n");
       	 while(!feof(fp))
             {
                fgets(s,sizeof(s),fp);
                printf("%s",s);
             }
         fseek(fp,8,SEEK_SET);
	 printf("\nthe content of the file from offset:8 is\n");
         while(!feof(fp))
             {
                fgets(s,sizeof(s),fp);
                printf("%s",s);
             }
         fclose(fp);
          
     }

  
}

