
/*Example 2 - 10. Single-Precision Floating-Point Division C Listing for _divf */

/**************************************************************/
/* DIVSPC.c Syd Poland 6-06-98 _divf function in C for 'C67xx */
/**************************************************************/

float _divf(float A, float B)
{
	float BH, X0, X1, X2, Y, TWO=2.0 ;

	X0 = _rcpsp(B) ;
	X1 = X0*( TWO - B*X0 ) ;
	X2 = X1*( TWO - B*X1 ) ;
	Y = A * X2 ;
	return (Y) ;
}
