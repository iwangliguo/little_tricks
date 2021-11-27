#include<stdio.h>
#include<dir.h>
main()
{
   char *path_1="G:\\TC\\Extemp.txt";
   char *path_2="TC\\Extemp.txt";
   char *path_3="Extemp.txt";
   char drive[MAXDRIVE];
   char dir[MAXDIR];
   char name[MAXFILE];
   char ext[MAXEXT];
   if(fnsplit(path_1,drive,dir,name,ext))
     {
      printf("\n Splitting %s:",path_1);
	  printf("\n Drive %s,Directionay %s,Filename %s,Extension %s",drive,dir,name,ext);
     }
  if(fnsplit(path_2,drive,dir,name,ext))
     {
      printf("\n Splitting %s:",path_2);
	  printf("\n Drive %s,Directionay %s,Filename %s,Extension %s",drive,dir,name,ext);
     }
  if(fnsplit(path_3,drive,dir,name,ext))
     {
      printf("\n Splitting %s:",path_3);
	  printf("\n Drive %s,Directionay %s,Filename %s,Extension %s",drive,dir,name,ext);
     }

}