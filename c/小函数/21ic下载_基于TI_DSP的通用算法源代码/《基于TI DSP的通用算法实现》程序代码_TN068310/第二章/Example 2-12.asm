
;Example 2 - 12. Single-Precision Floating-Point Square Root ASM Listing for sqrtf

;================================================================
; Copyright 1998 by Texas Instruments Inc. All rights reserved.
; sqrsp1.asm Syd Poland 06-22-98
; a4 = a4
; ans = square root (arg1) all in SP FP for 'C67xx DSPs
;================================================================

	.global _SQRSP, _sqrtf		; entry labels
	.text				; program section
	.align 32			; Fetch Packet boundary

arg1	.set a4				; input argument SPFP
ans	.set a4				; output answer SPFP
xn	.set a0				; nth iteration square root reciprocal
exp1	.set a1				; input exponent switch
Half	.set b4				; SPFP exp of 1 = 0x0080_0000
K15	.set b5				; SPFP constant 1.5 = 0x3fc0_0000
tmp	.set a3				; temp
wrk	.set a5				; work
etc	.set a2				; etc.

_sqrtf							; entry in rts6701 library
_SQRSP							; find square root of arg1 SP FP

	clr	.S1 arg1, 31, 31, arg1		; force + sign
||	zero	.L2 Half			; 0
||	zero	.D2 K15				; 1.5
	extu	.S1 arg1, 1, 24, exp1		; get exponent field
|| 	set	.S2 Half, 23, 23, Half		; one in exponent field

	rsqrsp	.S1 arg1, xn			; X0 = TLU to 8-bits
||	set	.S2 K15, 22, 29, K15		; 1.5 in SPFP
  [exp1]sub	.L2x arg1, Half, Half		; V=arg1/2 if exp1 is NZ

	mpysp	.M1x xn, Half, tmp		; V*X0
	nop 3

	mpysp	.M1 xn, tmp, wrk		; (V*X0) * X0
	nop 3

	subsp	.L1x K15, wrk, etc		; 1.5 - V*X0*X0
	nop 3

	mpysp	.M1 xn, etc, xn			; X1 = X0*(1.5 - V*X0*X0)
	nop 3

	mpysp	.M1x xn, Half, tmp		; V*X1
	nop 3

	mpysp	.M1 xn, tmp, wrk		; (V*X1) * X1
	nop 3

	subsp	.L1x K15, wrk, etc		; 1.5 - V*X1*X1
	nop 3

	mpysp	.M1 xn, etc, xn			; X2 = X1*(1.5 - V*X1*X1)
	nop 1

	b	.S2 b3				; normal return
	nop 1

  [exp1]mpysp	.M1 xn, arg1, ans	; ans = arg1*X2 if exp1 is NZ
||[!exp1]zero	.D1 ans			; return 0 if exp1 = 0
	nop 3				; wait for answer in register

	.end

