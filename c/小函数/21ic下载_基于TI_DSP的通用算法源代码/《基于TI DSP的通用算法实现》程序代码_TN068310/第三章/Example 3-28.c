
; Example 3 - 28. Autoscaling DIT Radix-4 FFT with C62x C Intrinsics

int r4_fft(short n, int x[], const int w[])
{
	int n1, n2, ie, ia1, ia2, ia3, i0, i1, i2, i3, j, k;
	int t0, t1, t2;
	int xtmph, xtmpl;
	int shift, exp=19, scale=0;
	n2 = n; ie = 1;
	for ( k=n; k>1; k>>=2 ) {
		n1 = n2; n2 >>= 2; ia1 = 0;
		for ( j=0; j<n2; j++ ) {
			ia2 = ia1 + ia1;	ia3 = ia2 + ia1;
			for ( i0=j; i0<n; i0+=n1) {
				i1 = i0 + n2;
				i2 = i1 + n2;
				i3 = i2 + n2;
				t0 = _add2(x[i1],x[i3]);
				t1 = _add2(x[i0],x[i2]);
				t2 = _sub2(x[i0],x[i2]);
				x[i0] = _add2(t0,t1);
				t1 = _sub2(t1,t0);
				xtmph = (_smpyh(t1,w[ia2]) - _smpy(t1,w[ia2])) & 
								0xffff0000;
				xtmpl = ((_smpylh(t1,w[ia2]) + _smpyhl(t1,w[ia2])) >>
							 	16) & 0x0000ffff;
				x[i2] = xtmph | xtmpl;
				t0 = _sub2(x[i1],x[i3]);
				t1 = -(t0 << 16);
				t0 = t1 | ((t0 >> 16) & 0x0000ffff);
				t1 = _add2(t2,t0);
				t2 = _sub2(t2,t0);
				xtmph = (_smpyh(t1,w[ia1]) - _smpy(t1,w[ia1])) & 									0xffff0000;
				xtmpl = ((_smpylh(t1,w[ia1]) + _smpyhl(t1,w[ia1])) >> 
								16) & 0x0000ffff;
				x[i1] = xtmph | xtmpl;
				xtmph = (_smpyh(t2,w[ia3]) - _smpy(t2,w[ia3])) & 									0xffff0000;
				xtmpl = ((_smpylh(t2,w[ia3]) + _smpyhl(t2,w[ia3])) >> 
								16) & 0x0000ffff;
				x[i3] = xtmph | xtmpl;
			}
			ia1 = ia1 + ie;
		}
		if ( k > 4 ) {
			ie <<= 2; j=0;
			while ( (exp > 16) && (j < n) ) {
				xtmph = _norm(x[j] >> 16);
				xtmpl = _norm(x[j] << 16 >> 16);
				if ( xtmph < exp ) exp=xtmph;
				if ( xtmpl < exp ) exp=xtmpl;
				j++;
			}
			if ( exp < 19 ) {
				shift = 19-exp; exp = 19; scale += shift; _nassert(j>15);
				for ( j=0; j<n; j++ ) {
					xtmph = (x[j] >> shift) & 0xffff0000;
					xtmpl = ((x[j] << 16) >> (16+shift)) & 0x0000ffff;
					x[j] = xtmph | xtmpl;
				}
			}
		}
	}
	return scale;
}

