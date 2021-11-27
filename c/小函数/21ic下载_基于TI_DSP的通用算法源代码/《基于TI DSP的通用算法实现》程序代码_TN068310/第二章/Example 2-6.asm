
;Example 2 - 6. Single-Precision Floating-Point Division ASM Listing for _divf

; 	Copyright 1998 by Texas Instruments Inc. All rights reserved.

; 	DIVSP1.asm Syd Poland 05-01-98 for TMS320C67xx DSPs
; 	a4 = a4 / b4
; 	ans = arg1/arg2 SP FP divide subroutine

	.text 			; program memory
	.global _DIVSP,__divf 	; entry label
	.align 32 		; fetch packet boundary

arg1 	.set a4 	; input 32-bit floating point argument 1
arg2 	.set b4 	; input 32-bit floating point argument 2
ans 	.set a4 	; output 32-bit floating point answer
xn 	.set b5 	; nth iteration value
two 	.set a3 	; constant 2.0
tmp 	.set b6 	; temp register
V 	.set b0 	; divide by 0 switch (exp2 = 0)

__divf 				; entry in rts6701 library
_DIVSP 				; entry to SP FP divide subroutine

	rcpsp 	.S2 	arg2,xn 	; x1 = 1/arg2 [8-bits]

	zero 	.L1 	two 		; two = 0

	mpysp 	.M2 	arg2,xn,tmp 	; tmp = arg2 * x1

	extu 	.S2 	arg2,1,24,V 	; is exp2 = 0 ?
	set 	.S1 	two,30,30,two 	; two = 2.0 in SP FP (0x4000_0000)
	nop 		1

	subsp 	.L2X 	two,tmp,tmp 	; tmp = 2.0 - (arg2*x1)
	nop 		3
	
	mpysp 	.M2 	xn,tmp,xn 	; x2 = x1*(2 - arg2*x1) [16-bits]
	nop 		3

	mpysp 	.M2 	arg2,xn,tmp 	; tmp = arg2 * x2
	nop 		3
		
	subsp 	.L2X 	two,tmp,tmp 	; tmp = 2.0 - (arg2*x2)
	nop 		3

	mpysp 	.M2 	xn,tmp,xn 	; x3 = x2*(2 - arg2*x2) [32-bits]
	nop 		1

	b 	.S2 	b3 		; normal return
	nop 		1

[V] 	mpysp 	.M1 	arg1,xn,ans 	; ans = arg1*(x3) where x3 = 1/arg2
|| [!V] set 	.S1 	ans,0,31,ans 	; return exp/mant = all 1s (/ 0)
	nop 		3 		; wait for answer in register

	.end
