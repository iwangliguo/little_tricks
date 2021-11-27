
; Example 3 - 27. DIT Radix-4 FFT C Listing

void radix4(int n, short x[], short w[])
{
	int n1, n2, ie, ia1, ia2, ia3, i0, i1, i2, i3, j, k;
	short t, r1, r2, s1, s2, co1, co2, co3, si1, si2, si3;
	n2 = n; ie = 1;
	for (k = n; k > 1; k >>= 2) { // number of stages
		n1 = n2; n2 >>= 2; ia1 = 0;
		for (j = 0; j < n2; j++) { // number of butterflies
			ia2 = ia1 + ia1; // per stage
			ia3 = ia2 + ia1;
			co1 = w[ia1 * 2 + 1];
			si1 = w[ia1 * 2];
			co2 = w[ia2 * 2 + 1];
			si2 = w[ia2 * 2];
			co3 = w[ia3 * 2 + 1];
			si3 = w[ia3 * 2];
			ia1 = ia1 + ie;
			for (i0 = j; i0 < n; i0 += n1) { // loop for butterfly
				i1 = i0 + n2; // calculations
				i2 = i1 + n2;
				i3 = i2 + n2;
				r1 = x[2 * i0] + x[2 * i2];
				r2 = x[2 * i0] - x[2 * i2];
				t = x[2 * i1] + x[2 * i3];
				x[2 * i0] = r1 + t;
				r1 = r1 - t;
				s1 = x[2 * i0 + 1] + x[2 * i2 + 1];
				s2 = x[2 * i0 + 1] - x[2 * i2 + 1];
				t = x[2 * i1 + 1] + x[2 * i3 + 1];
				x[2 * i0 + 1] = s1 + t;
				s1 = s1 - t;
				x[2 * i2] = (r1 * co2 + s1 * si2) >> 15;
				x[2 * i2 + 1] = (s1 * co2 - r1 * si2)>> 15;
				t = x[2 * i1 + 1] - x[2 * i3 + 1];
				r1 = r2 + t;
				r2 = r2 - t;
				t = x[2 * i1] - x[2 * i3];
				s1 = s2 - t;
				s2 = s2 + t;
				x[2 * i1] = (r1 * co1 + s1 * si1) >> 15;
				x[2 * i1 + 1] = (s1 * co1 - r1 * si1)>> 15;
				x[2 * i3] = (r2 * co3 + s2 * si3) >> 15;
				x[2 * i3 + 1] = (s2 * co3 - r2 * si3)>> 15;
			}
	}
	ie <<= 2;
}


