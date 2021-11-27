#include<stdio.h>
main()
{
   FILE *temp_file;
   char ch ='a';
   int i ,c;
   
       if((temp_file=tmpfile())!=NULL)
      {
        
        for(i=0;i<20;i++)
             {
             fputc(ch+i,temp_file);
            
             }
             rewind(temp_file); 
			printf("\n");
        while((c=fgetc(temp_file))!=EOF)
             printf("%c",c);

			 fclose(temp_file);
       }
         

}