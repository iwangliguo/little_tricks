
;Example 3 - 22. Split Function ASM Listing for the FFT of two N-Point Real Sequences for the TMS320C62x DSP


*================================================================
* TEXAS INSTRUMENTS, INC.
* Real FFT/IFFT split operation 
*================================================================
	.global _split
_split:
	ldh		.d2 *XPtr,X1r 				; X1r = Xr[0]
	ldh 	.d2 *+XPtr[1],X2r 			; X2r = Xi[0]
	sth 	.d1 X1r, *X1Ptr 				; X1r[0]=Xr[0]
	shl 	.s1 N, 2, N4 					; N4 = 4*N
||	sth 	.d2 X2r, *X2Ptr 				; X2r[0]=Xi[0]
||	zero 	.l2 nullB 						; nullA = 0
||	zero 	.l1 nullA 						; nullB = 0
	sub 	.l1 N4, 4, N4 				; N4 = N4 - 1
|| 	sth 	.d1 nullA, *+X1Ptr[1] 		; X1i[0]=0
|| 	sth 	.d2 nullB, *+X2Ptr[1] 		; X2i[0]=0
	add 	.l1x N4, XPtr, XNmkPtr 		; XNmkPtr -> X[N-1]
|| 	add 	.l2 XPtr, 4, XPtr 			; XPTR -> X[1]
	ldw 	.d2 *XPtr++[1], XiXr 		; load X[k].re and X2[k].im
|| 	ldw 	.d1 *XNmkPtr--[1], XNiXNr	; load X[N-k].re and X[N-k].im
	shr 	.s2x N, 1, CNT 				; CNT = N/2
	sub 	.s2 CNT, 1, CNT 				; CNT = N/2 - 1
	add 	.l1 N4, X1Ptr, X1NmkPtr 	; X1NmkPtr -> X1[N-1]
|| 	add 	.l2x N4, X2Ptr, X2NmkPtr 	; X2NmkPtr -> X2[N-1]
	add 	.l X1Ptr, 4, X1Ptr 			; X1Ptr -> X1[1]
|| 	add 	.l X2Ptr, 4, X2Ptr 			; X2Ptr -> X2[1]
	add2 	.s1x XiXr, XNiXNr, X2rX1r 	; X2[k].re = X[k].im + X[N-k].im
											; 	(upper 16 bits)
											; X1[k].re = X[k].re + X[N-k].re
											; 	(lower 16 bits)
|| 	sub2 	.s2x XiXr, XNiXNr, X1iX2i 	; X1[k].im = X[k].im - X[N-k].im
											;	(upper 16 bits)
											; X2[k].im = X[k].re - X[N-k].re
											; 	(lower 16 bits)
|| 	ldw 	.d2 *XPtr++[1], XiXr 		; load X[k].real and X2[k].imag
|| 	ldw 	.d1 *XNmkPtr--[1], XNiXNr 	; load X[N-k].re and X[N-k].im
	shr 	.s1 X2rX1r, 17, X2r 		; X2[k].re=(X[k].im+X[N-k].im)/2
										; X2r = X2rX1r>>17
|| 	sub2 	.s2 nullB, X1iX2i, X2i 	; X2[k].im=X[N-k].re-X[k].re
										;		(lower 16 bits)
										; upper 16 bits are don't cares
	shr 	.s2 X1iX2i, 17, X1i 		; X1[k].im=(X[k].im+X[N-k].im)/2
										; X1i = X1iX2i>>17
|| 	b 	.s1 LOOP 				; branch for the first time through loop
LOOP:
	ext 	.s1 X2rX1r, 16,17, X1r 		; X1[k].real = X1[k].real/2
|| 	ext 	.s2 X2i, 16,17, X2i 			; X2[k].imag = X2[k].imag/2
|| 	sth 	.d1 X1i, *+X1Ptr[1] 			; store X1[k].imag
|| 	sth 	.d2 X2r, *X2Ptr++[1] 		; store X2[k].real
	mv 		.l1 X1r, X1Nr 				; X1[N-k].real = X1[k].real
|| 	mv 		.s1 X2r, X2Nr 				; X2[N-k].real = X2[k].real
|| 	sub 	.l2 nullB, X1i, X1Ni 		; X1[N-k].imag = -X1[k].imag
|| 	sub 	.s2 nullB, X2i, X2Ni 		; X2[N-k].imag = -X2[k].imag
|| 	sth 	.d2 X2i, *X2Ptr++[1] 		; store X2[k].imag
|| 	sth 	.d1 X1r, *X1Ptr++[2] 		; store X1[k].real
	add2 	.s1x XiXr, XNiXNr, X2rX1r 	; X2[k].re = X[k].im + X[N-k].im
											; 		(upper 16 bits)
											; X1[k].re = X[k].re + X[N-k].re
											;		(lower 16 bits)
|| 	sub2 	.s2x XiXr, XNiXNr, X1iX2i 	; X1[k].im = X[k].im - X[N-k].im
											; 		(upper 16 bits)
											; X2[k].im = X[k].re - X[N-k].re
											; 		(lower 16 bits)
|| 	ldw 	.d2 *XPtr++[1], XiXr 		; load X[k].real and X2[k].imag
|| 	ldw 	.d1 *XNmkPtr--[1], XNiXNr	; load X[N-k].re and X[N-k].im
	shr 	.s1 X2rX1r, 17, X2r 		; X2[k].re=(X[k].im+X[N-k].im)/2
										; X2r = X2rX1r>>17
|| 	sub2 	.s2 nullB, X1iX2i, X2i 	; X2[k].im=X[N-k].re-X[k].re
											; 		(lower 16 bits)
											; upper 16 bits are don't cares
|| 	sth 	.d1 X1Ni, *+X1NmkPtr[1] 	; store X1[N-k].imag
|| 	sth 	.d2 X2Nr, *X2NmkPtr--[2] 	; store X2[N-k].real
||[CNT] sub .l2 CNT, 1, CNT 			; decrement loop counter
	shr 	.s2 X1iX2i, 17, X1i 		; X1[k].im=(X[k].im+X[N-k].im)/2
										; X1i = X1iX2i>>17
|| 	sth 	.d1 X1Nr, *X1NmkPtr--[2] 	; store X1[N-k].real
|| 	sth 	.d2 X2Ni, *+X2NmkPtr[3] 	; store X2[N-k].imag
||[CNT] b	.s1 LOOP 						; LOOP END
	nop 3 									; fill delay slots

