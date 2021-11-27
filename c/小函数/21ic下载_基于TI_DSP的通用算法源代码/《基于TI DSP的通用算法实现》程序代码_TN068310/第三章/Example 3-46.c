
; Example 3 - 46. Creation of Cosine TBL of FCT ASM Listing for the TMS320C3x DSP

	for (k = 2, i = 0; k = N/2; k *= 2)
		for (j = k/2; j < N/2; j += k){
			cos_table(i++) = 1/(2*cos(j*pi/(2*N))):
			cos_table(i++) = 1/(2*cos((N-j)*pi/(2*N)));
		}
	cos_table(N-2) = cos(pi/4);
	cos_table(N-1) = 2/N;

