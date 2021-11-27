
Example 3 - 21. Split Function C Listing for the FFT of two N-Point Real Sequences

/****************************************************************
FILE£ºsplit.c 
     This is the C source code for the implementation of the 
split routine which is the additional computations in computing 
the DFT of two N-point real-valued sequences using one N-point 
complex DFT.
****************************************************************/

#include "params.h"
void split(int N, COMPLEX *X, COMPLEX *X1, COMPLEX *X2)
{
	int k;
	X1[0].real = X[0].real; 	X1[0].imag = 0;
	X2[0].real = X[0].imag; 	X2[0].imag = 0;
	X1[N/2].real = X[N/2].real;	X1[N/2].imag = 0;
	X2[N/2].real = X[N/2].imag;	X2[N/2].imag = 0;
	for (k=1; k<N/2; k++){
		X1[k].real = (X[k].real + X[N-k].real)/2;
		X1[k].imag = (X[k].imag - X[N-k].imag)/2;
		X2[k].real = (X[k].imag + X[N-k].imag)/2;
		X2[k].imag = (X[N-k].real - X[k].real)/2;
		X1[N-k].real = X1[k].real;
		X1[N-k].imag = -X1[k].imag;
		X2[N-k].real = X2[k].real;
		X2[N-k].imag = -X2[k].imag;
	}
}

