

// Example 5 - 9. Real-Valued FIR Filter C Listing Using Intrinsic Functions for the TMS320C64x DSP

void rv_fir_C64x(double * x, double * h, int * r, int nh, int nr)
{
	int 	i, j;
	double sum;
	for (i = 0; i < nr; i += 1){
		sum = 0;
		for (j = 0; j < nh/4; j += 1){
			sum += _dotp2(_lo(x[i]), _lo(h[i])) + 
						_dotp2(_hi(x[i]), _hi(b[i]));
		}
		r[i] = sum >> 31;
	}
}
