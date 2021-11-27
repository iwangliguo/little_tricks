
/* Example 2 - 16. Single-Precision Floating-Point Square Root C Listing for sqrtf */

/***************************************************************/
/* SQRSPC.c Syd Poland 6-06-98 _sqrtf function in C for 'C67xx */
/***************************************************************/

float sqrtf(float A)
{
	float ZERO=0.0, HALF=0.5, K15=1.5, AH, X0, X1, X2, Y ;

	if (A < ZERO) A = -A ; /* square root of absolute A */
	AH = A * HALF ;
	X0 = _rsqrsp(A) ;
	X1 = X0 * ( K15 - AH*X0*X0 ) ;
	X2 = X1 * ( K15 - AH*X1*X1 ) ;
	Y = A * X2 ;

	return (Y) ;
}

