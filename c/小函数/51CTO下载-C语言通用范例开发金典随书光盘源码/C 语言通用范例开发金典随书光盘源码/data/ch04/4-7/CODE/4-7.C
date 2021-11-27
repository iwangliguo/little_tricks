#include<stdio.h>
#include<dir.h>
main()
{
   char directory[MAXPATH];

      getcwd(directory,MAXPATH);
      printf("\nThe current directory is:");
       printf("%s",directory);
	 if(!rmdir("\\TC\\TEMP"))
      {
        printf("\nthe \\TC\\TEMP has sucessful deleted!");
       }
      
}