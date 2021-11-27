#include <dos.h>


 main(void)
{ 
   unsigned fre=50;
   int times =30;
   for(;times>0;times--)
   {
     fre=(fre+50)%40000;
     sound(fre);
     delay(600);
     fre=(fre+50)%40000;
     sound(fre);
     delay(600);
   }

   nosound(); 
  
} 

