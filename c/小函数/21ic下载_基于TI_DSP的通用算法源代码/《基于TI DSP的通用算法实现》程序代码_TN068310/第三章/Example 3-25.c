
; Example 3 - 25. Split Function C Listing for the FFT of a 2N-Point Real Sequences


/****************************************************************
FILE
Split2.c - This is the C source code for the implementation of the
split routine which is the additional computations in computing the
DFT of an 2N-point real-valued sequences using a N-point complex DFT.
****************************************************************/
#include "params1.h"
#include "params.h"
void split2(int N, COMPLEX *X, COMPLEX *A, COMPLEX *B, COMPLEX *G)
{
	int k;
	int Tr, Ti;
	for (k=0; k<N; k++){
		Tr = (int)X[k].real*(int)A[k].real-(int)X[k].imag*(int)A[k].imag+(int)X[N-k].real*(int)B[k].real+(int)X[N-k].imag*(int)B[k].imag;
		G[k].real = (short)(Tr>>15);
		Ti = (int)X[k].imag*(int)A[k].real+(int)X[k].real*(int)A[k].imag+(int)X[N-k].real*(int)B[k].imag-(int)X[N-k].imag*(int)B[k].real;
		G[k].imag = (short)(Ti>>15);
	}
}

