
;Example 2 - 5. Signed Fixed-Point Division ASM Subroutine for C6x


*================================================================
*
*	TEXAS INSTRUMENTS, INC.
*	DIVMOD32 (signed division)
*	Revision Date:  07/09/97
*
*	USAGE
*			This routine is C Callable and can be called as:
*
*			struct  divmod divmod32(int a, int b);
*
*			a 每每每 numerator
*			b 每每每 denominator
*
*			If routine is not to be used as a C callable function then
*			you need to initialize values for all of the values passed
*			as these are assumed to be in registers as defined by the
*			calling convention of the compiler, (refer to the C compiler
*			reference guide).
*
*	C CODE
*			This is the C equivalent of the assembly code.  Note that
*			the assembly code is hand optimized and restrictions may
*			apply.
*
* 			struct  divmod {
*				int div;
*				int mod;
*			};
*
*			struct  divmod divmod32(int a, int b)
*			{
*				struct divmod tmp;
*
*				tmp.div = a / b;
*				tmp.mod = a % b;
*				return tmp;
*			}
*
*	DESCRIPTION
*			This routine divides two 32 bit values and returns their
*			quotient and remainder.  The inputs are 32每bit numbers, and
*			the result is a 32每bit number.
*
*	TECHNIQUE
*			The loop is executed at least 6 times.  In the loop, the
*			conditional subtract divide step (SUBC) is block from doing
*			extraneous executions.  In short, the SUBC instruction
*			is conditional and will not necessarily be executed.
*
*
*	MEMORY NOTE
*			No memory bank hits under any conditions.
*
*	CYCLES
*			Minimum execution time 每> 16 cycles
*			Maximum execution time 每> 41 cycles
*        
*================================================================

	.global _divmod32
        .text

_divmod32:

*** BEGIN Benchmark Timing ***
B_START:
		SHRU	.S1     A4,     31,     A1	; neg_num = num < 0
||		CMPLT	.L2     B4,     0,      B1	; neg_den = den < 0
||		MV	.D1     A4,     A5 		; copy num
  [A1]		NEG	.L1     A4,     A4		; abs_num = abs(num)
||[B1]		NEG	.S2     B4,     B4		; abs_den = abs(den)
||		MPY	.M1     每1,     A1,     A6	; copy neg_num
||		MPY	.M2     每1,     B1,     B9	; copy neg_den
||		B	.S1     LOOP			; 
		NORM	.L1     A4,     A2		; mag_num = norm(abs_num)
||		NORM	.L2     B4,     B2		; mag_den = norm(abs_den)
||		B	.S1     LOOP			;
||		ADD	.S2X    A3,     4,      B8	; address for mod result
		CMPGTU	.L1X    B4,     A4,     A1	; zero = (abs_den > abs_num)
||		SUB	.L2X    B2,     A2,     B0	; i = mag_den 每 mag_num
||		MVK	.S1     31,     A0		;
||		B	.S2     LOOP			;
		SHL	.S2     B4,     B0,     B4	; abs_den <<= i
||		CMPLT	.L2     B0,     6,      B2	; check for neg. loop count.
||		SUB	.D2     B0,     6,      B1	; generate loop counter
||		SUB	.L1X    A0,     B0,     A0 	; qs = 31 每 i
||		B	.S1     LOOP 			;
  [B2]		ZERO	.L2     B1			; zero negative loop counter
||		SUBC	.L1X    A4,     B4,     A4	
							; abs_num=subc(abs_num, abs_den)
||		ADD	.D2     1,      B0,     B2	; ms = i + 1
||		B	.S2     LOOP			;

LOOP:
  [B0]		SUBC 	.L1X    A4,     B4,     A4	; abs_num=subc(abs_num, abs_den)
||[B0]		SUB	.L2     B0,     1,      B0 	; i每每
||[B1]		SUB	.D2     B1,     1,      B1	; i每每
||[B1]		B	.S1     LOOP			; for
;end of LOOP

  [!A1]		SHRU	.S2X    A4,     B2,     B1	; mod = n >> ms
||[!A1]		SHL	.S1     A4,     A0,     A4	; q = abs_num << qs
||[A1]		MPY	.M1     0,      A4,     A4	; if (zero) q = zero
||		XOR	.L1X    A6,     B9,     A2	; neg_q = neg_num ^ neg_den
  [!A1]		SHRU	.S1     A4,     A0,     A4	; q = abs_num >> qs
||[A1]		MV	.L2X    A5,     B1		; if (zero) mod = num
||[!A1]		MV	.L1     A6,     A1		; \ neg_mod = !zero && neg_num
||[A1]		ZERO	.D1     A1						; /
  [A2]		NEG	.L1     A4,     A4		; if (neg_q) q = 每q
||[A1]		NEG	.L2     B1,     B1		; if (neg_mod) mod = 每mod
||		B	.S2     B3			; return
		STW	.D1     A4,     *A3++		; c[2 * i] = c_tmp.div
||		STW	.D2     B1,     *B8++		; c[2 * i + 1] = c_tmp.mod
B_END:
*** END Benchmark Timing ***

        NOP     4
