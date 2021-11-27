
; Example 3 - 26. Split Function ASM Listing for the FFT of a 2N-Point Real Sequences for the TMS320C62x DSP

*================================================================
* TEXAS INSTRUMENTS, INC.
* Real FFT/IFFT split operation
* Revision Date: 5/15/97
*
* CYCLES 4*N + 32
*================================================================

	.global _split2

_split2:
	sub 	.l2x N,1,CNT 			; initialize loop count register
 	shl 	.s1 N,2,N 			; calculate offset to initialize
						; a pointer to the bottom of the
						; input data buffer
	stw	.d2 B12,*B15++[1] 		; push B12 onto the stack
|| 	add 	.l1x N,XPtr,XNPtr 		; XNPtr -> yx[N]
	ldw 	.d1 *APtr++[1],aI_aR 		; load a coefficient pointed by APtr
|| 	ldw 	.d2 *XPtr++[1],xI_xR 		; load a data value pointed by XPtr
	nop 					; fill a delay slot
	ldw 	.d1 *XNPtr--[1],x2I_x2R		; load a data value pointed by XNPtr
|| 	ldw 	.d2 *BPtr++[1],bI_bR 		; load a coefficient pointed by BPtr
	nop 					; fill a delay slot
	ldw 	.d1 *APtr++[1],aI_aR 		; load the next value pointed by APtr
						; (note, it will not overwrite the
						; the current value of aI_aR until
						; 4 delay slots later).
|| 	ldw 	.d2 *XPtr++[1],xI_xR 		; load the next value pointed by XPtr
						; for performing the multiplies, we take advantage of the feature
						; feature that allows you to choose the operands from either the upper
						; or lower halves of the register
	mpy 	.m1x xI_xR,aI_aR,xRaR 		; xRaR=xR*aR-mpy lower*lower
|| 	mpyhl 	.m2x xI_xR,aI_aR,xIaR 		; xIaR=xI*aR-mpy upper*lower
	mpylh 	.m2x xI_xR,aI_aR,xRaI 		; xRaI=xR*aI-mpy lower*upper
|| 	mpyh 	.m1x xI_xR,aI_aR,xIaI 		; xIaI=xI*aI-mpy upper*upper
|| 	ldw 	.d1 *XNPtr--[1],x2I_x2R		; load a data value pointed by XNPtr
|| 	ldw 	.d2 *BPtr++[1],bI_bR		; load a coefficient pointed by BPtr
	mpy 	.m1x x2I_x2R,bI_bR,x2RbR 	; x2RbR=x2R*bR-mpy lower*lower
|| 	mpyhl 	.m2x x2I_x2R,bI_bR,x2IbR 	; x2IbR=x2I*bR-mpy upper*lower
	mpylh 	.m2x x2I_x2R,bI_bR,x2RbI 	; x2RbI=x2R*bI-mpy lower*upper
|| 	mpyh 	.m1x x2I_x2R,bI_bR,x2IbI 	; x2IbI=x2I*bI-mpy upper*upper
|| 	sub 	.l1 xRaR,xIaI,re1 		; re1 = xRaR - xIaI
|| 	add 	.l2 xRaI,xIaR,im1 		; im1 = xRaI + xIaR
|| 	ldw 	.d1 *APtr++[1],aI_aR 		; 3rd load of aI_aR
|| 	ldw 	.d2 *XPtr++[1],xI_xR 		; 3rd load of xI_xR the second 
						; loads of xI_xR and aI_aR are now avaiable, thus we can use
						; them to begin the 2nd iteration of X's and A's multiplies
	mpy 	.m1 xI_xR,aI_aR,xRaR 		; xRaR=xR*aR-mpy lower*lower
|| 	mpyhl 	.m2x xI_xR,aI_aR,xIaR		; xIaR=xI*aR-mpy upper*lower
	mpylh 	.m2 xI_xR,aI_aR,xRaI 		; xRaI=xR*aI-mpy lower*upper
|| 	mpyh 	.m1x xI_xR,aI_aR,xIaI 		; xIaI=xI*aI-mpy upper*upper
|| 	add 	.l1 x2RbR,x2IbI,re2 		; re2 = x2RbR + x2IbI
|| 	sub 	.l2 x2RbI,x2IbR,im2 		; im2 = x2RbI - x2IbR
|| 	ldw 	.d1 *XNPtr--[1],x2I_x2R		; 3rd load of x2I_x2R
|| 	ldw 	.d2 *BPtr++[1],bI_bR 		; 3rd load of bI_bR the second loads 
						; of x2I_x2R and bI_bR are now available, thus we can use
						; them to begin the 2nd iteration of X2's and B's multiplies
	mpy 	.m1 x2I_x2R,bI_bR,x2RbR 	; x2RbR=x2R*bR-mpy lower*lower
|| 	mpyhl 	.m2x x2I_x2R,bI_bR,x2IbR 	; x2IbR=x2I*bR-mpy upper*lower
|| 	add 	.l1 re1,re2,real 		; real = re1 + re2
|| 	add 	.l2 im1,im2,imag 		; imag = im1 + im2
|| 	b 		.s2 LOOP 				; branch to LOOP - note, this is the
								; branch for the first time through the 
								; loop, because of this, we only need to 
								; do count-1 branches to LOOP within LOOP
	mpylh 	.m2 x2I_x2R,bI_bR,x2RbI		; x2RbI=x2R*bI-mpy lower*upper
|| 	mpyh 	.m1x x2I_x2R,bI_bR,x2IbI	; x2IbI=x2I*bI-mpy upper*upper
|| 	sub 	.l1 xRaR,xIaI,re1		; rel = xRaR - xIaI
|| 	add 	.l2 xRaI,xIaR,im1		; im1 = xRaI + xIaR
|| 	shr 	.s1 real,15,real			; real = real >> 15
|| 	shr 	.s2 imag,15,imag			; imag = imag >> 15
|| 	ldw 	.d1 *APtr++[1],aI_aR		; 4th load of aI_aR
|| 	ldw 	.d2 *XPtr++[1],xI_xR		; 4th load of xI_xR
LOOP:									; this loop is executed N times
	mpy 	.m1 xI_xR,aI_aR,xRaR 		; xRaR = xR * aR - mpy lower * lower
|| 	mpyhl 	.m2x xI_xR,aI_aR,xIaR 		; xIaR = xI * aR - mpy upper * lower
|| 	sth 	.d1 real,*GPtr++[1]
||[CNT] sub .l2 CNT,1,CNT 			; if (CNT != 0), CNT = CNT - 1
	mpylh 	.m2 xI_xR,aI_aR,xRaI 		; xRaI = xR * aI - mpy lower * upper
|| 	mpyh 	.m1x xI_xR,aI_aR,xIaI 		; xIaI = xI * aI - mpy upper * upper
|| 	add 	.l1 x2RbR,x2IbI,re2 		; re2 = x2RbR + x2IbI
|| 	sub 	.l2 x2RbI,x2IbR,im2 		; im2 = x2RbI - x2IbR
|| 	ldw 	.d1 *XNPtr--[1],x2I_x2R 	; next load of x2I_x2R
|| 	ldw 	.d2 *BPtr++[1],bI_bR 		; next load of bI_bR
	mpy 	.m1 x2I_x2R,bI_bR,x2RbR 	; x2RbR=x2R*bR-mpy lower*lower
|| 	mpyhl 	.m2x x2I_x2R,bI_bR,x2IbR 	; x2IbR=x2I*bR-mpy upper*lower
|| 	add 	.l1 re1,re2,real 			; real = re1 + re2
|| 	add 	.l2 im1,im2,imag 			; imag = im1 + im2
|| 	sth 	.d1 imag,*GPtr++[1]
||[CNT] b 	.s2 LOOP 						; if (CNT != 0), branch to LOOP
	mpylh 	.m2x x2I_x2R,bI_bR,x2RbI 	; x2RbI=x2R*bI-mpy lower*upper
|| 	mpyh 	.m1x x2I_x2R,bI_bR,x2IbI 	; x2IbI=x2I*bI-mpy upper*upper
|| 	sub 	.l1 xRaR,xIaI,re1 			; rel = xRaR - xIaI
|| 	add 	.l2 xRaI,xIaR,im1 			; im1 = xRaI + xIaR
|| 	shr 	.s1 real,15,real 			; real = real >> 15
|| 	shr 	.s2 imag,15,imag 			; imag = imag >> 15
|| 	ldw 	.d1 *APtr++[1],aI_aR 		; next load of aI_aR
|| 	ldw 	.d2 *XPtr++[1],xI_xR 		; next load of xI_xR

