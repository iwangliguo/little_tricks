#include <stdio.h> 
#include <math.h> 

main() 
{ 
double coeffs[] = {  1.0, 4.0, 6.0, 4.0 ,1.0};
double x=1.0,result;
int  degree=4;
result = poly(1.0, 4, coeffs);
printf("The polynomial: x^4 +4x^3+6x^2+4x+1 at 1.0 is %lf\n",result);



  

} 

