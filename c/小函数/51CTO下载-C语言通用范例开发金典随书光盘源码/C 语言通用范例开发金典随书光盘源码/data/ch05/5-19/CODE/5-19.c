#include<stdio.h>
#include<mem.h>
main()
{
   char str[64]="Hello",*p;
   printf("\n The content of str is %s",str);
   p=memset(str,NULL,sizeof(str));
   if(*p==NULL)
  {
   printf("\n After setting,the content of str is NULL");
   }
  else
   {
   printf("\n After setting,the content of str is %s",p);
   }
} 

