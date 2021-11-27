#include <stdio.h> 
#include <math.h> 

main() 
{ 
double value; 
double x = 2; 
int exponent =3;
value = ldexp(x,exponent); 
printf("The ldexp value is: %lf\n",value); 


} 

