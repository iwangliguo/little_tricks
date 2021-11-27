#include<stdio.h>
#include<mem.h>
main( )
{
	char scr[64]="qwertyuiopasdfghjklzxcvbnm\0",dest[64],*p;
	p=NULL;
   printf("\n The content of scr is %s",scr);
   p=memccpy(dest,scr,'j',26);

  if(*dest==NULL)
   {
   printf("\n After copy,the content of dest is NULL");
   }
  else
   {
   printf("\n After copy,the content of dest is %s",dest);
   }


   if(*p==NULL)
  {
   printf("\n After copy,the content of p is NULL");
   }
  else
   {
   printf("\n After copy,the content of p is %s",p);
   }

}

