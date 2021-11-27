#include<stdio.h>
main()
{
   FILE *fp;
   int int_number[3] ={20,30,40},i,itemp[3];
   float float_number[3] ={1.2,2.3,3.1415},ftemp[3];


   if((fp=fopen("Extemp.txt","w+"))!=NULL)
   {
     for(i=0;i<3;i++)
     {
       fprintf(fp,"\n%d %f",int_number[i],float_number[i]);
     }
    rewind(fp);
    /*将fp文件指针移到文件头部*/
     for(i=0;i<3;i++)
     {
	   fscanf(fp,"\n%d %f",&itemp[i],&ftemp[i]);
     }
    fclose(fp);
   }
    for(i=0;i<3;i++)
     {
       printf("\n%d %f",itemp[i],ftemp[i]);
     }  
}