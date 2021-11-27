#include<stdio.h>
main()
{
    FILE * fp;
    char c ='a';
    int i ;

	   if((fp=fopen("Extemp.txt","w+"))!=NULL)
	  {
		 printf("\n");
         for(i=0;i<20;i++)
			{
			 fputc(c+i,fp);
			 printf("%c",c+i);
			}
         fclose(fp);

      }

}