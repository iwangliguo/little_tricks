
// Example 5 - 1. Single-Precision Complex FIR Filter C Listing


void sp_fir_cplx(float * x, float * h, float * r, 	int nh, int nr)
{
	int i,j;
	float imag, real;
	for (i = 0; i < 2*nr; i += 2){
		imag = 0; real = 0;
		for (j = 0; j < 2*nh; j += 2){
			real += h[j] * x[i+j] - h[j+1] * x[i+1+j];
			imag += h[j] * x[i+1+j] + h[j+1] * x[i+j];
		}
		r[i] = real; r[i+1] = imag;
	}
}
