#include <stdio.h>
#include <string.h>

int main ()
{
   char str1[15];
   char str2[15];
   int ret;


   strcpy(str1, "ABCDEF\0abc");
   strcpy(str2, "ABCDEF");

   ret = strcmp(str1, str2);

   if(ret < 0)
   {
      printf("str1 С�� str2");
   }
   else if(ret > 0)
   {
      printf("str2 С�� str1");
   }
   else
   {
      printf("str1 ���� str2");
   }

   return(0);
}
