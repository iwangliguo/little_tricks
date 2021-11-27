
; Example 6 - 16. Residu Implementation C Listing Using Intrisics for the TMS320C62x DSP


#define L_add(a,b) 		(_sadd((a),(b)))
#define L_mult(a,b) 		(_smpy((a),(b)))
#define extract_h(a) 	(_extu(a,0,16))//((unsigned)(a)>>16)
#define L_shl(a,b) 		((b) < 0 ? (a) >> (¨C b) : s_shl((a),(b)))
#define round(a) 		((unsigned)(_sadd((a),0x8000))>>16)

#define m 10 				/* m = LPC order == 10 				*/
typedef short Word16;
typedef int Word32;
void Residu (
	Word16 a[], 			/* (i) : prediction coefficients */
	Word16 x[], 			/* (i) : speech signal 				*/
	Word16 y[], 			/* (o) : residual signal 			*/
	Word16 lg 			/* (i) : size of filtering 		*/
)


void main()
{
	Word16	i, j;
	Word32	s;
	for (i = 0; i < lg; i++){
		s = L_mult(x[i], a[0]);
		for (j = 1; j <= m; j++){
			s = L_mac(s, a[j], xi[¨Cj]);
		}
		s = L_shl (s, 3);
		y[i] = round (s);
	}
	return;
}
