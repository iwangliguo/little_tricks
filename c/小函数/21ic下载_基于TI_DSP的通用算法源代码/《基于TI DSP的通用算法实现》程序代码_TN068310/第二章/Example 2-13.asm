
;Example 2 - 13. Double-Precision Floating-Point Square Root ASM Listing for sqrt

;================================================================
; Copyright 1998 by Texas Instruments Inc. All rights reserved.
; SQRDP1.asm Syd Poland 08-08-98 for TMS320C67xx DSPs
; a5:a4 = a5:a4
; ans = Square Root (arg1) DP FP Square Root Subroutine
;================================================================

	.text			; program memory
	.global _SQRDP, _sqrt	; entry labels
	.align 32		; fetch packet boundary

arg1H	.set a5			; input DP FP argument1 register pair
arg1L	.set a4
ansH	.set a5			; output DP FP answer register pair
ansL	.set a4
VH	.set a1			; arg1/2 register pair
VL	.set a0
KH	.set b5			; constant 1.5 register pair
KL	.set b4
xH	.set a7			; xn register pair
xL	.set a6
tH	.set a9			; temp register pair
tL	.set a8
exp1	.set a2			; exp1 = 0 switch

_sqrt					; entry in rts6701 library
_SQRDP					; entry to DP FP square root function

	clr	.S1 arg1H, 31, 31, arg1H	; force sign bit to + 
||	zero	.D1 VH				; V = 0

	extu	.S1 arg1H, 1, 21, exp1		; get exponent 1 field
  [exp1]set	.S1 VH, 20, 20, VH		; V = 1 in exponent field

	rsqrdp	.S1 arg1H:arg1L, xH:xL		; x1 = TLU (1/arg1) [8-bits]
	sub	.L1 arg1H, VH, VH		; V = arg1 / 2 if exp1 > 0
||	mv	.D1 arg1L, VL

	mpydp	.M1 VH:VL, xH:xL, tH:tL		; t = (arg1/2) * x1
|| 	zero	.L2 KH				; K = 0
|| 	zero	.D2 KL
	set	.S2 KH, 19, 29, KH		; 1.5 in DP FP (0x3ff8_0000)
	nop 7

	mpydp	.M1 xH:xL, tH:tL, tH:tL		; t = [(arg1/2)*x1]*x1
	nop 8

	subdp	.L1x KH:KL, tH:tL, tH:tL	; t = 1.5-[(arg1/2)*x1]*x1
	nop 5

	mpydp	.M1 xH:xL, tH:tL, xH:xL 	; x2=x1*{1.5-(arg1/2)*(x1*x1)}
	nop 8

	mpydp	.M1 VH:VL, xH:xL, tH:tL		; t = (arg1/2) * x2
	nop 8

	mpydp	.M1 xH:xL, tH:tL, tH:tL		; t = [(arg1/2)*x2] * x2
	nop 8

	subdp	.L1x KH:KL, tH:tL, tH:tL	; t = 1.5-[(arg1/2)*x2]*x2
	nop 5

	mpydp	.M1 xH:xL, tH:tL, xH:xL		; x3=x2*{1.5-(arg1/2)*(x2*x2)}
	nop 8

	mpydp	.M1 VH:VL, xH:xL, tH:tL		; t = (arg1/2) * x3
	nop 8

	mpydp	.M1 xH:xL, tH:tL, tH:tL		; t = [(arg1/2)*x3] * x3
	nop 8

	subdp	.L1x KH:KL, tH:tL, tH:tL	; t = 1.5-[(arg1/2)*x3]*x3
	nop 5

	mpydp	.M1 xH:xL, tH:tL, xH:xL 	; x4=x3*{1.5-(arg1/2)*(x3*x3)}
	nop 8

  [exp1]mpydp	.M1 arg1H:arg1L, xH:xL, ansH:ansL
						; ans=arg1*x4 if exp1>0
||[!exp1]zero	.L1 ansH			; ans = 0 if exp1 = 0
||[!exp1]zero	.D1 ansL
	nop 3

	b		.S2 b3			; normal return
	nop 5					; wait for ans in register pair

	.end

