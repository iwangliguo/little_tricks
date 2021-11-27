
;Example 3 - 23. Complex Bit Reversion ASM Listing for the TMS320C62x DSP

;****************************************************************
; FILE
; digit.asm - C62xx assembly source for a C callable FFT digit reversal
; function. 
;
; DESCRIPTION
; 	This functions implements, by table look up, digit/bit reversal 
;	for FFT algorithms. The function assumes that index tables which 
;	contain the indexes of data pairs that get swapped are pre-computed 
;	and stored as two separate arrays. Since this is a table look up 
;	method, this is a generic routine. It can be used for bit-reversal 
;	of radix-2 FFTs, or digit-reversal of radix-4 FFTs etc.
;****************************************************************
	.global _digit_reverse
	.text
_digit_reverse:
	ldh		.d1 *IIndexPtr++[1], I 		; load a I index
|| 	ldh		.d2 *JIndexPtr++[1], J 		; load a J index
|| 	mv		.l2x AXPtr, BXPtr 			; copy AXPtr to BXPtr
	nop 2 									; fill the delay slots
	ldh		.d1 *IIndexPtr++[1], I 		; load the next I index
|| 	ldh		.d2 *JIndexPtr++[1], J 		; load the next J index
|| 	sub 	.l2 count,1,CNT 				; decrement the count by
											; one, and put into a register
											; that can be used as a
											; condition register
	nop 1 									; fill a delay slot
	ldw 	.d1 *+AXPtr[J],XJ 			; load the value pointed by
											; the first J index loaded
|| 	ldw 	.d2 *+BXPtr[I],XI 			; load the value pointed by
											; the first I index loaded
|| 	b 	LOOP 								; branch for the first time
											; through the loop
	nop 									; fill a delay slot
	mv 		.l1 J,TJ 						; make a copy of J so that
											; the value is not lost due to 
											; the reloading of J
|| 	mv 		.l2 I,TI 						; make a copy of I so that
											; the value is not lost due
											; to the reloading of I
LOOP:
	ldw 	.d1 *+AXPtr[J],XJ 			; load the value pointed by J
|| 	ldw 	.d2 *+BXPtr[I],XI 			; load the value pointed by I
||[CNT] b	.s1 LOOP 						; conditional branch
	ldh 	.d1 *IIndexPtr++[1], I 		; load the next I index
|| 	ldh 	.d2 *JIndexPtr++[1], J 		; load the next J index
||[CNT] sub .l2 CNT,1,CNT 				; decrement the loop counter
	stw 	.d1 XI,*+AXPtr[TJ] 			; data loaded from the I index
											; is stored at the location
											; pointed by the J index
|| 	stw 	.d2 XJ,*+BXPtr[TI] 			; data loaded from the J index
											; is stored at the location
											; pointed by the I index
											; note, TJ and TI have the I
											; and J values 3 iterations back
|| 	mv 		.l1 J,TJ 						; make a copy of J so that
											; the value is not lost due
											; to the reloading of J
|| 	mv 		.l2 I,TI 						; make a copy of I so that
											; the value is not lost due
											; to the reloading of I

