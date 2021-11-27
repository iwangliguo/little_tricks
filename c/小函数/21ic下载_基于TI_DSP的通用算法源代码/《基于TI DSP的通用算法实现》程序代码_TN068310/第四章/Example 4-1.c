
/* Example 4 - 1. Single-Precision Biquad C Listing */

void sp_biquad(float *x, float *b, float *a, float *delay, float r, int nx)
{
	int i;
	float a1, a2, b0, b1, b2, d0, d1, x_i;
	a1 = a[0]; a2 = a[1];
	b0 = b[0]; b1 = b[1]; b2 = b[2];
	d0 = delay[0]; d1 = delay[1];
	for (i = 0; i < nx; i++){
		x_i = x[i];
		r[i] = b0 * x_i + d0;
		d0 = b1 * x_i - a1 * r[i] + d1;
		d1 = b2 * x_i - a2 * r[i];
	}
	delay[0] = d0; delay[1] = d1;
}
