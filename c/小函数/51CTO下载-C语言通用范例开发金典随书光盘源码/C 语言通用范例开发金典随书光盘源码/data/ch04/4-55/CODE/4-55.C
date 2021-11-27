#include<stdio.h>
main()
{
 
        char c ,s[20]="hello"; 
	FILE  *fp;
        fp=fopen("Extem.txt","w+");
        fprintf(fp,"%s",s);
         fclose(fp);
		 if((fp=freopen("Extem.txt","r",stdin))!=NULL)
		 {
       printf("\n");
		while((c=getchar())!=EOF)
        {
			printf("%c",c);
        }
		 }
   

}


