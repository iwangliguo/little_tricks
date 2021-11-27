#include<stdio.h>
#include<mem.h>

main()
{
   char s1[5]="asdf",s2[5]="asdd",s3[5]="asDF";
   printf("\nThe result of %s and %s with memcmp is %d",s1,s2,memcmp(s1,s2,sizeof(s1)));
   printf("\nThe result of %s and %s with memcmp is %d",s2,s1,memcmp(s2,s1,sizeof(s2)));
   printf("\nThe result of %s and %s with memcmp is %d",s1,s3,memcmp(s1,s3,sizeof(s1)));
   printf("\nThe result of %s and %s with memicmp is %d",s1,s2,memicmp(s1,s2,sizeof(s1)));
   printf("\nThe result of %s and %s with memicmp is %d",s1,s3,memicmp(s1,s3,sizeof(s1)));

} 

