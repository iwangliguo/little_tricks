#include<stdio.h>
#include<dir.h>
main()
{
   char directory[MAXPATH];

      getcwd(directory,MAXPATH);
      printf("\nThe current directory is:");
      puts(directory);
	  if(!mkdir("\\TC\\TEMP"))
      {
		  printf("\nthe \\TC\\TEMP has sucessful ceeated!");
       }
      
}