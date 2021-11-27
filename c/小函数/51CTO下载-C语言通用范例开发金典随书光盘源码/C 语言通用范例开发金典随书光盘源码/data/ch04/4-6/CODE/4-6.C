#include<stdio.h>
#include<dir.h>
main()
{
   char directory[MAXPATH];

      getcwd(directory,MAXPATH);
	  printf("\nCurrent directory is:");
	  printf("%s",directory);
      chdir("\\TEMP");
      getcwd(directory,MAXPATH);
	  printf("\nCurrent directory is:");
       printf("%s",directory);
}