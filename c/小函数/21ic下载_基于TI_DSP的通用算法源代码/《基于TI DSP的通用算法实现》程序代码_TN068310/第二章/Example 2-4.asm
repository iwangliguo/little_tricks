
;Example 2 - 4. Unsigned Fixed-Point Division ASM Subroutine for C6x

*==============================================================================
*
* TEXAS INSTRUMENTS, INC.
* DIVMODU32 (32 bits unsigned division and modulo)
* Revision Date: 07/15/97
*
* USAGE
* 	This routine is C Callable and can be called as:
*
* 	struct divmodu divmodu32(unsigned int a, unsigned int b);
*
* 	a 每每每 unsigned numerator
* 	b 每每每 unsigned denominator
*
* 	If routine is not to be used as a C callable function then
* 	you need to initialize values for all of the values passed
* 	as these are assumed to be in registers as defined by the
* 	calling convention of the compiler, (refer to the C compiler
* 	reference guide).
*
* C CODE
* 	This is the C equivalent of the assembly code. Note that
* 	the assembly code is hand optimized and restrictions may
* 	apply.
**
* 	struct divmodu {
* 		unsigned int div;
* 		unsigned int mod;
* 	};
**
* 	struct divmodu divmodu32(unsigned int a, unsigned int b)
* 	{
* 		struct divmodu tmp;
*
* 		tmp.div = a / b;
* 		tmp.mod = a % b;
*
* 		return tmp;
* 	}
*
* DESCRIPTION
* 	This routine divides two unsigned 32 bit values and returns
* 	their quotient and remainder. The inputs are unsigned 32每bit
* 	numbers, and the result is a unsigned 32每bit number.
*
* TECHNIQUE
* 	The loop is executed at least 6 times. In the loop, the
* 	conditional subtract divide step (SUBC) is block from doing
* 	extraneous executions. In short, the SUBC instruction
* 	is conditional and will not necessarily be executed.
*
* MEMORY NOTE
* 	No memory bank hits under any conditions.
*
* CYCLES
* 	Minimum execution time 每> 18 cycles
* 	Maximum execution time 每> 42 cycles
*
*==============================================================================

	.global _divmodu32
	.text

_divmodu32:

*** BEGIN Benchmark Timing ***
B_START:
	LMBD 	.L2X 	1, A4, B1 			; mag_num = lmbd(1, num)
|| 	LMBD 	.L1X 	1, B4, A1 			; mag_den = lmbd(1, den)
|| 	MVK 	.S1 	32, A0 				; const 32
|| 	ZERO 	.D1 	A8 				; first_div = 1
	CMPGTU 	.L1X 	B4, A4, A1 		; zero = (den > num)
|| 	SUB 	.L2X 	A1, B1, B0 		; i = mag_den 每 mag_num
|| 	MV 	.D1 	A4, A5 			; save num
||[!B1] MVK 	.S1 	1, A8 			; if (num32) first_div = 1
	SHL 	.S2 	B4, B0, B4 		; den <<= i
||[B1] 	ADD 	.D2 	B0, 1, B0 		; if (!num32) i++
|| 	MV 		B0, A6
	CMPGTU 	.L2X 	B4, A4, B2 		; gt = den > num
|| 	SUB 	.L1X 	A0, B0, A0 		; qs = 32 每 i
|| 	SHL 	.S1 	A8, A6, A8 		; first_div <<= i
|| 	B 	.S2 	LOOP 			;
||[B1] 	MPY 	.M2 	B2, 0, B2 		; num32 && gt
	ADD 	.L1X 	0, B0, A2
||[B2] 	MV 	.D2 	B2, B1 			; !(num32 && !gt)
||[B2] 	SHRU 	.S1 	A8, 1, A8 		; first_div >>= 1
|| 	B 	.S2 	LOOP ;
  [B2] 	SHRU 	.S2 	B4, 1, B4 		; if (num32 && gt) den >> 1
||[!B1] SUB 	.L1X 	A4, B4, A4 		; if (num32 && !gt) num 每= den
||[B0] 	SUB 	.D2 	B0, 1, B0 		; i每每
|| 	B 	.S1 	LOOP 			;
[!B1] 	SHRU 	.S2 	B4, 1, B4 		; if (num32 && !gt) den >> 1
||[B2] 	SUB 	.L1X 	A4, B4, A4 		; if (num32 && gt) num 每= den
|| 	CMPLT 	.L2 	B0, 6, B2 		; check for neg. loop counter
|| 	SUB 	.D2 	B0, 6, B1 		; generate loop counter
|| 	B 	.S1 	LOOP 			;
  [B2] 	ZERO 	.L2 	B1 			; zero negative loop counter
||[A2] 	SUBC 	.L1X 	A4, B4, A4 		; num = subc(num, den)
|| 	B 	.S2 	LOOP 			;

LOOP:
  [B0] 	SUBC 	.L1X 	A4, B4, A4 		; num = subc(num, den)
||[B0] 	SUB 	.L2 	B0, 1, B0 		; i每每
||[B1] 	SUB 	.D2 	B1, 1, B1 		; i每每
||[B1] 	B 	.S1 	LOOP			; for
;end of LOOP

	ADD 	.L2 	A3, 4, B7 		; address for mod result
||[!A1] SHL 	.S1 	A4, A0, A6 		; q = num << qs
||[A1] 	MPY 	.M1 	0, A6, A6 		; if (zero) q = zero
|| 	B 	.S2 	B3
  [!A1] SHRU 	.S1	A6, A0, A6 		; q = num >> qs
||[A1] 	MV 	.L1 	A5, A2 			; if (zero) mod = num
|| 	MV 		A8, B5 			;
	ADD 	.L2X 	A6, B5, B8 		;
||[!A1] SHRU 	.S1 	A4, A2, A2 		; mod = n >> ms
	STW 	.D1 	B8, *A3++ 		; c[2 * i] = q
|| 	STW 	.D2 	A2, *B7++ 		; c[2 * i + 1] = mod
B_END:
*** END Benchmark Timing ***
NOP 2