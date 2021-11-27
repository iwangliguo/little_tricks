
// Example 4 - 14. Biquad IIR Filter C Listing Using Intrinsic Functions for the TMS320C62x DSP

// Feedback section
mult1 = _mpy(dn_2, a12) >> 15;		//d[n-2]*a12
mult2 = _mpy(an_1, a11) >> 15;		//d[n-1]*a11
dn = xin - (short)(mult1+mult2)	
									//d[n]=xin+d[n-2]*a12+ d[n-1]*a11
//Feedforward section
mult3 = _mpy (dn_2, b12) >> 15;		//d[n-2]*b12
mult4 = _mpy (dn_1, b10) >> 15;		//d[n-2]*b12
mult5 = _mpy (dn, b10) >> 15;			//d[n-2]*b12
yout = (short)(mult3+mult4+mult5);	//y[n]

//Data shifting
dn_2 = dn_1;								//d[n-1] -> d[n-2]
dn_1 = dn;								//d[n] -> d[n-1]

