#include<stdio.h>
#include<dir.h>
main()
{
   char path[MAXPATH];
   char drive[MAXDRIVE];
   char dir[MAXDIR];
   char name[MAXFILE];
   char ext[MAXEXT];
   getcwd(path,MAXPATH) ;
   strcat(path,"\\");
   fnsplit(path,drive,dir,name,ext);
   strcpy(name,"Extemp");
   strcpy(ext,".txt");
   fnmerge(path,drive,dir,name,ext);
   puts(path);
}