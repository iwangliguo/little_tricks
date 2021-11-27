
;Example 3 - 3. Float-Point Complex DIT Radix-2 FFT C Listing

/****************************************************************/
/*	x --- pointer to input data array in normal order	*/
/*	w --- pointer to the twiddle factor array		*/
/*	n --- length of FFT					*/
/****************************************************************/

void sp_cfftr2_dit(float *x, float *w, short n)
{
	short n2, ie, ia, i, j, k, m;
	float rtemp, itemp, c, s;
	
	n2 = n; ie = 1;
	for(k=n; k > 1; k >>= 1){				/*** Loop (c) ***/
		n2 >>= 1; ia = 0;
		for(j=0; j < ie; j++){				/*** Loop (b) ***/
			c = w[2*j];
			s = w[2*j+1];
			for(i=0; i < n2; i++){			/*** Loop (a) ***/
				m = ia + n2;
				rtemp = c * x[2*m] + s * x[2*m+1];
				itemp = c * x[2*m+1] - s * x[2*m];
				x[2*m] = x[2*ia] - rtemp;
				x[2*m+1] = x[2*ia+1] - itemp;
				x[2*ia] = x[2*ia] + rtemp;
				x[2*ia+1] = x[2*ia+1] + itemp;
				ia++;
			} 					
			ia += n2; 
		}	
		ie <<= 1;
	}	
}
