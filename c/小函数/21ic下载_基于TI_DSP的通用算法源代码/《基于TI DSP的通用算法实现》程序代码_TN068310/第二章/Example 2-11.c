
/*Example 2 - 11. Double-Precision Floating-Point Division C Listing for _divd*/

/***************************************************************/
/* divdpc.c Syd Poland 06-24-98 _divd function in C for 'C67xx */
/***************************************************************/

double _divd(double A, double B)
{
	double X0, X1, X2, X3, Y, TWO=2.0 ;

	X0 = _rcpdp(B) ;
	X1 = X0*( TWO - B*X0 ) ;
	X2 = X1*( TWO - B*X1 ) ;
	X3 = X2*( TWO - B*X2 ) ;
	Y = A * X3 ;
	return (Y) ;
}

