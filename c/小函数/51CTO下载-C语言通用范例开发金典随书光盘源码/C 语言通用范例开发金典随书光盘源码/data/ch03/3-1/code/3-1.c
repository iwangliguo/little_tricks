/* scanf and printf example */
#include <stdio.h>
int main ()
{
  char str [80];
  int i;
  printf ("Enter your family name: ");
  scanf ("%s",str);/*输入姓*/  
  printf ("Enter your age: ");
  scanf ("%d",&i);/*输入年龄*/
  printf ("Mr. %s , %d years old.\n",str,i);
  printf ("Enter a hexadecimal number: ");
  scanf ("%x",&i);/*输入一个十六进制的数字*/
  printf ("You have entered %#x (%d).\n",i,i);
  getch();
  return 0;
}
 
