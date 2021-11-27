
;Example 2 - 7. Double-Precision Floating-Point Division ASM Listing for _divd

;===============================================================
; Copyright 1998 by Texas Instruments Inc. All rights reserved.

; DIVDP1.asm Syd Poland 08-08-98 for TMS320C67xx DSPs
; a5:a4 = a5:a4/b5:b4
; ans = arg1/arg2 DP FP divide subroutine

;===============================================================

	.text				; program memory
	.global _DIVDP, __divd		; entry labels
	.align 32			; fetch packet boundary

arg1H	.set a5				; input DP FP argument1 register pair
arg1L	.set a4
arg2H	.set b5				; input DP FP argument2 register pair
arg2L	.set b4
ansH	.set a5				; output DP FP answer register pair
ansL	.set a4
xH	.set b7				; x register pair
xL	.set b6
twoH	.set a7				; DP FP 2.0 constant register pair
twoL	.set a6
tH	.set b9				; DP FP temporary register pair
tL	.set b8
V	.set b2				; divide by 0 switch

__divd					; entry in rts6701 library
_DIVDP:					; ans = arg1/arg2 (all DP FP)
	rcpdp	.S2 arg2H:arg2L, xH:xL		; x1 = 1/arg2 [8-bits]
||	zero	.L1 twoH			; MS word = 0
||	zero	.D1 twoL			; LS word = 0

	set	.S1 twoH,30,30,twoH		; DP FP 2 (0x4000_0000)

	mpydp	.M2 arg2H:arg2L, xH:xL, tH:tL	; t = arg2*x1
||	extu	.S2 arg2H,1,21,V		; exp2 = 0 ?
	nop 8

	subdp	.L2x twoH:twoL, tH:tL, tH:tL	; t = 2.0 - (arg2*x1)
	nop 5

	mpydp	.M2 xH:xL, tH:tL, xH:xL		; x2 = x1*(2-arg2*x1)
	nop 8

	mpydp	.M2 arg2H:arg2L, xH:xL, tH:tL	; t = arg2*x2
	nop 8

	subdp	.L2x twoH:twoL, tH:tL, tH:tL	; t = 2.0-(arg2*x2)
	nop 5

	mpydp	.M2 xH:xL, tH:tL, xH:xL		; x3 = x2*(2-arg2*x2)
	nop 8

	mpydp	.M2 arg2H:arg2L, xH:xL, tH:tL	; t = arg2*x3
	nop 8

	subdp	.L2x twoH:twoL, tH:tL, tH:tL	; t = 2.0-(arg2*x3)
	nop 5

	mpydp	.M2 xH:xL, tH:tL, xH:xL		; x4 = x3*(2-arg2*x3)
	nop 8

[V]	mpydp	.M1x arg1H:arg1L, xH:xL, ansH:ansL	; ans = arg1*x4
||[!V]	set	.S1 arg1H, 0, 30, ansH			; exp/mant = all 1s (div by 0)
||[!V]	or	.L1 -1, ansL, ansL			; lower mantissa = all 1s
	nop 3

	b	.S2 b3					; normal function return
	nop 5						; wait for ans in register pair

.end    
