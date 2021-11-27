
;Example 3 - 1. Generation of Twiddle Factor for Float-Point Complex Radix-2 FFT C Listing


/***************************************************************/
/*	twiFactor --- pointer to the twiddle factor array      */
/*	wLen        --- length of FFT			       */
/***************************************************************/

struct	complexData{
            float re;
            float im;
        };

void gen_w_r2(struct complexData * twiFactor, int wLen)
{
     int 	iFactor;
     float stepFactor;
      
     stepFactor=2.0*pi/wLen;      
     for (iFactor=0; iFactor<(wLen>>1); iFactor++){
            twiFactor[iFactor].re = cos(stepFactor*iFactor);
            twiFactor[iFactor].im = sin(stepFactor*iFactor);
               			// w[n] = exp(j*2*pi*n/N), n=0,1,...,(N/2-1).
     }
}
