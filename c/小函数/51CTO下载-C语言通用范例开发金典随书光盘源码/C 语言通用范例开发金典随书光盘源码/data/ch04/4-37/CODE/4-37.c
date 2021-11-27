#include<stdio.h>
#include<dos.h>
main()
{
   struct fatinfo fat;
   getfatd(&fat);
   printf("The number of cluster %u\n",fat.fi_nclus);   
   printf("Sectors per cluster %d\n",fat.fi_sclus);
   printf("Bytes   per sectors %d\n",fat.fi_bysec);
   
}