
/* Example 2 - 17. Double-Precision Floating-Point Square Root C Listing for sqrt */

/***************************************************************/
/* SQRDPC.c Syd Poland 6-24-98 _sqrt function in C for 'C67xx */
/***************************************************************/

double sqrt(double A)
{
	double ZERO=0.0, HALF=0.5, K15=1.5, AH, X0, X1, X2, X3, Y ;

	if (A < ZERO) A = -A ; /* square root of absolute A */
	AH = A * HALF ;
	X0 = _rsqrdp(A) ;
	X1 = X0 * (K15 - (AH*X0)*X0 ) ;
	X2 = X1 * (K15 - (AH*X1)*X1 );
	X3 = X2 * (K15 - (AH*X2)*X2 );
	Y = A * X3 ;

	return (Y) ;
}
