
// Example 6 - 17. Residu Implementation Optimized C Listing for the TMS320C62x DSP


#define DWORD_ALIGNED(x) (_nassert(((int)(x) & 0x7) == 0))

typedef short Word16;
typedef int Word32;
#define lg 40
#define L_mult(a,b) (_smpy((a),(b)))
#define L_mac(a,b,c) (_sadd((a),_smpy((b),(c))))
#define L_add(a,b) (_sadd(a,b))
#define L_shl(a,b) ((b<0) ? (a) >> (�Cb) : _sshl(a,b))
#define round(a) ((unsigned)(_sadd(a,0x8000L))>>16)
void Residu_co(
	const Word32 a[], /* (i) Q12: prediction coefficients */
	const Word32 x[], /* (i) : speech (values x[�Cm..�C1] are needed */
	Word16 y[], /* (o) : residual signal */
	Word16 lg /* (i) : size of filtering */
)

{
	Word16 i, j;
	Word32 s0, s1;
	Word32 a0, a1, a2, a3, a4, a5;
	DWORD_ALIGNED(a);
	DWORD_ALIGNED(x);

	a0 = a[0];
	a1 = a[1];
	a2 = a[2];
	a3 = a[3];
	a4 = a[4];
	a5 = a[5];

	for (i = 0, j = 0; j < lg; j+=2, i++)
	{
		s1 = L_mult((x[i]>>16), a0) ; /* a0 * x[i+1] */
		s0 = L_mult((x[i]), a0) ; /* a0 * x[i] */
		s1 = L_mac(s1, a0>>16, x[i]) ; /* a1 * x[i] */
		s0 = L_mac(s0, a0>>16, x[i�C1]>>16); /* a1 * x[i�C1] */
		s1 = L_mac(s1, a1, x[i�C1]>>16); /* a2 * x[i�C1] */
		s0 = L_mac(s0, a1, x[i�C1]); /* a2 * x[i�C2] */
		s1 = L_mac(s1, a1>>16, x[i�C1]); /* a3 * x[i�C2] */
		s0 = L_mac(s0, a1>>16, x[i�C2]>>16); /* a3 * x[i�C3] */
		s1 = L_mac(s1, a2, x[i�C2]>>16); /* a4 * x[i�C3] */
		s0 = L_mac(s0, a2, x[i�C2]); /* a4 * x[i�C4] */
		s1 = L_mac(s1, a2>>16, x[i�C2]); /* a5 * x[i�C4] */
		s0 = L_mac(s0, a2>>16, x[i�C3]>>16); /* a5 * x[i�C5] */
		s1 = L_mac(s1, a3, x[i�C3]>>16); /* a6 * x[i�C5] */
		s0 = L_mac(s0, a3, x[i�C3]); /* a6 * x[i�C6] */
		s1 = L_mac(s1, a3>>16, x[i�C3]); /* a7 * x[i�C6] */
		s0 = L_mac(s0, a3>>16, x[i�C4]>>16); /* a7 * x[i�C7] */
		s1 = L_mac(s1, a4, x[i�C4]>>16); /* a8 * x[i�C7] */

		s0 = L_mac(s0, a4, x[i�C4]); /* a8 * x[i�C8] */
		s1 = L_mac(s1, a4>>16, x[i�C4]); /* a9 * x[i�C8] */
		s0 = L_mac(s0, a4>>16, x[i�C5]>>16); /* a9 * x[i�C9] */
		s1 = L_mac(s1, a5, x[i�C5]>>16); /* a10 * x[i�C9] */
		s0 = L_mac(s0, a5, x[i�C5]); /* a10 * x[i�C10] */
		s1 = L_add(s1, 4096);
		s0 = L_add(s0, 4096);
		s1 = L_shl(s1, 3);
		s0 = L_shl(s0, 3);
		y[j] = (short)(s0 >>16);
		y[j+1] = (short)(s1 >>16);
	}
	return;
}

