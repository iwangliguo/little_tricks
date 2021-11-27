#include <stdio.h> 
#include <math.h> 

main() 
{ 
  double x = 5.0, y = 2.0; 
  double result; 
  result = fmod(x,y); 
  printf("The remainder of (%lf / %lf) is %lf\n", x, y, result); 


} 
 

