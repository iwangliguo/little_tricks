#include<stdio.h>
#include<sys\stat.h>
#include<io.h>
main()
{
   int i;
   FILE * fp;
   char c ='a';
   if((fp=fopen("Extemp1.txt","w+"))!=NULL)
      {
         for(i=0;i<20;i++)
             {
             fputc(c,fp); 
             }
          fclose(fp);
	       if((chmod("Extemp1.txt",S_IREAD))!=0)
              {
               printf("Error setting the file Extemp1.txt ");
              }
             
         
       }
    if((fp=fopen("Extemp2.txt","w+"))!=NULL)
      {
         for(i=0;i<20;i++)
             {
             fputc(c,fp);
             }
         fclose(fp);
	if((chmod("Extemp2.txt",S_IWRITE))!=0)
              {
               printf("Error setting the file Extemp2.txt ");
              } 
             
       }
}