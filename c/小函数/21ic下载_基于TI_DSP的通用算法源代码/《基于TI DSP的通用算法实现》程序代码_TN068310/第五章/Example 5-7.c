
// Example 5 - 7. Real-Valued FIR Filter C Listing Using Intrinsic Functions for the TMS320C62x DSP

void rv_fir_C62x(short * x, short * h, short * r, int nh, int nr)
{
	int i, j, sum;
	for (i = 0; i < nr; i += 1){
		sum = 0;
		for (j = 0; j < nh/2; j += 1){
			sum + = ((_mpy( b[j] ,x[j])) <<1);
			sum + = ((_mpyh( b[j] ,x[j])) <<1);
		}
		r[i] = sum >> 15;
	}
}
