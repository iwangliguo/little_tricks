#include<stdio.h>
#include<dos.h>
#include<io.h>
main()
{
   int attributes,i;
   FILE * fp;
   char c ='a';
   
     if((fp=fopen("Extemp.txt","w+"))!=NULL)
      {
         for(i=0;i<20;i++)
             fputc(c,fp);
         fclose(fp);
       }
	 if((attributes = _chmod("Extemp.txt",0))==-1)
      {
	   printf(" \nError accessing  Extemp.txt" );
      }
    else
     {
	   if(attributes & FA_ARCH)  printf("\nArchive ");
       if(attributes & FA_DIREC) printf("\tDirectory");
       if(attributes & FA_HIDDEN) printf("\tHidden");
       if(attributes & FA_LABEL) printf("\tVolume label");
       if(attributes & FA_RDONLY) printf("\tReadonly");
       if(attributes & FA_SYSTEM) printf("\tSystem");
     } 
}