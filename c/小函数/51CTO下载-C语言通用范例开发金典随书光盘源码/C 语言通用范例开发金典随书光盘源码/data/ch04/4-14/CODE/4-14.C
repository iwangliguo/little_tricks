#include<stdio.h>
main()
{
    FILE *fp;
    int num;
    if((fp=fopen("Exwtmp.txt","wb"))==NULL)
    {
       printf(" \nError opening Exwtmp.txt !");
       exit(0);
    }
    else
    {
         printf(" \nExwtmp.txt has created!");
		 for(num=1;num<=10;num++)
            putw(num,fp);
         fclose(fp);
    }
     if((fp=fopen("Exwtmp.txt","rb"))==NULL)
    {
       printf(" \nError opening Exwtmp.txt !");
       exit(0);
    }
    else
    {
	   printf("\nThe content of the Exwtmp.txt is:");
	   printf("\n");
       while((num=getw(fp))!=EOF&&(!feof(fp)))
             {
             printf("%d ",num);
             }
         fclose(fp);
    }
   
}