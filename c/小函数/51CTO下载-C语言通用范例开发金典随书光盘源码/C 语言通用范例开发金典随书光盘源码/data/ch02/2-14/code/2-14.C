#include <stdio.h> 
#include <stdlib.h> 

main() 
{ 
div_t x;  

x = div(10,3);  
printf("10 div 3 = %d remainder %d\n", x.quot, x.rem);  


} 

