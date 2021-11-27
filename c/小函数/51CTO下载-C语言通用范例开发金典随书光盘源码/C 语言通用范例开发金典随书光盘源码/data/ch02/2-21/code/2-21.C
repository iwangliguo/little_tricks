#include <stdio.h> 
#include <math.h> 

main() 
{ 
double fraction, integer; 
double number = 100.567; 
fraction = modf(number, &integer); 
printf("The whole and fractional parts of\n"); 
printf("%lf are %lf and %lf\n",number, integer, fraction); 
} 

