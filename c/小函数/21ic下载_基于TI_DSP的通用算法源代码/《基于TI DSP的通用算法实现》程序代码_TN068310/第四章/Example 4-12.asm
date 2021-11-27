
; Example 4 - 12. Implementation of an IIR 16¡Á32-bit Direct Form I for the TMS320C54x DSP

; TEXAS INSTRUMENTS FRANCE
;
; AUTHOR MESSINA Nathalie
; CAVALIER Philippe
;
; (C) Copyright 1997. Texas Instruments France. All rights reserved
;
;
**********************************************************
* macro definitions *
**********************************************************
	.mmregs
	.include "init54x.inc"
	
	
	
**********************************************************
* reset/interrupt/trap vectors *
**********************************************************
*
* Always start from Reset.
*
	.global Start
	.sect "vecs"
Start
	BD Init ; Branch to MainLine.
	NOP
	NOP
	
	
	
**********************************************************
* Set up constant and filter coeff *
**********************************************************
K_FRAME_SIZE 		.set 128 ; Number of samples
K_NB_FILTER 		.set 1 ; Number of 2nd-order IIR filter
K_BUFFER_INDEX 		.set 1 ; Circ buff index
K_BUFFER_SIZE		.set (3*(K_NB_FILTER+1)-1) ; Circ buff size
BPFilterCoffTable 	.sect"iir_coff"
			.word 0100Ah ; A2 high
			.word 00000h ; A2 low
			.word 02014h ; A1 high
			.word 00000h ; A1 low
			.word 0100Ah ; A0 high
			.word 00000h ; A0 low
			.word 0DC01h ; -B2 high
			.word 00000h ; -B2 low
			.word 063D6h ; -B1 high
			.word 00000h ; -B1 low
		
		
**********************************************************
* Set up in/out buffer *
**********************************************************
DataFilin 	.usect "iir_vars",128 ; for 128 samples
DataFilout 	.usect "iir_vars",128 ; for 128 samples
DataInternal 	.usect "iir_bfr",K_BUFFER_SIZE
DataTempBuff 	.usect "iir_bfr",1




**********************************************************
* Init section *
**********************************************************
	.text
Init
	LD #0,A 		; acc = >00000000.
	STLM A,SWWSR 		; 0 Wait States.
	STLM A,BSCR 		; Bank shift.
	STM #K_ST0,ST0
	STM #K_ST1,ST1
	STM #K_PMST,PMST


**********************************************************
* *
* Main program *
* *
**********************************************************
Main
	CALL IirFilterInit
Continue
	NOP
	NOP
	CALL IirFilterTask
	NOP
	NOP
	B Continue


**********************************************************
* *
* Sub routines *
* *
**********************************************************
	.asg AR0,IIR_INDEX 		; Circ buff index
	.asg AR2,pIIR_DATA 		; High word of data buffer
	.asg AR3,pIIR_COEFF 		; Coefficient pointer 1
	.asg AR4,pINBUF 		; Input data
	.asg AR5,pOUTBUF 		; Output data
	
	.sect "iir_prog"

IirFilterInit
	STM #DataInternal,pIIR_DATA
	RPTZ A,#(K_BUFFER_SIZE-1) 	; Clear the internaldata
	STL A,*pIIR_DATA+		; data buffer
	STM #DataInternal,pIIR_DATA
					; pIIR_DATA points on the first high
					; word of the data buffer
	STM #BPFilterCoffTable,pIIR_COEFF
	STM #K_BUFFER_SIZE,BK 		; Load circ buff size
	RETD
	STM #K_BUFFER_INDEX,IIR_INDEX 	; Load circ buff index


;---------------------------------------------------------------------
IirFilterTask
	STM #(DataFilin),pINBUF 	; Load input add mem

IirFilterBegin
	STM #(K_FRAME_SIZE-1),BRC

	RPTBD IirFilterLoopEnd-1
	STM #(DataFilout),pOUTBUF 	; Load output add mem
	LD #0,A
	MPY *pIIR_COEFF+,*pIIR_DATA,B 	; A2high*x(n-2)
	MACSU *pIIR_COEFF+,*pIIR_DATA+0%,A 	; A2low*x(n-2)
	MAC *pIIR_COEFF+,*pIIR_DATA,B 		; A1high*x(n-1)
	MACSU *pIIR_COEFF+,*pIIR_DATA+0%,A 	; A1low*x(n-1)
	MVDD *pINBUF+,*pIIR_DATA 		; load x(n) in the buffer
	MAC *pIIR_COEFF+,*pIIR_DATA,B 		; A0high*x(n)
	MACSU *pIIR_COEFF+,*pIIR_DATA+0%,A 	; A0low*x(n)
	MAC *pIIR_COEFF+,*pIIR_DATA,B 		; -B2high*y(n-2)
	MACSU *pIIR_COEFF+,*pIIR_DATA+0%,A 	; -B2low*y(n-2)
	MAC *pIIR_COEFF+,*pIIR_DATA,B 		; -B1high*y(n-1)
	MACSU *pIIR_COEFF,*pIIR_DATA+0%,A 	; -B1low*y(n-1)
	ADD A,-16,B
	MAR *+pIIR_COEFF(-9) 			; pIIR_COEFF points on A2high
	STH B,*pIIR_DATA+0% 		; Store y(n) in the buffer
	STH B,*pOUTBUF+ 		; Store y(n) in the output
IirFilterLoopEnd

	RET
	.end
