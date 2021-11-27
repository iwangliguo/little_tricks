
; Example 4 - 6. Implementation of an IIR 32¡Á16-bit Direct Form I for the TMS320C54x DSP

; TEXAS INSTRUMENTS FRANCE
;
; AUTHOR MESSINA Nathalie
; CAVALIER Philippe
;
; (C) Copyright 1997. Texas Instruments France. All rights reserved
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
	K_FRAME_SIZE 	.set 128 ; Number of samples
	K_NB_FILTER 	.set 1 ; Number of 2nd-order IIR filter
	K_BUFFER_INDEX 	.set 1 ; Circ buff index
	K_BUFFER_SIZE 	.set (6*(K_NB_FILTER+1)-2) ; Circ buff size
	
BPFilterCoffTable 
	.sect"iir_coff"
	.word 0100Ah ; A2
	.word 02014h ; A1
	.word 0100Ah ; A0
	.word 0DC01h ; -B2
	.word 063D6h ; -B1
	
**********************************************************
* Set up in/out buffer *
**********************************************************
	DataFilin 	.usect "iir_vars",256 ; for 128 samples
	DataFilout 	.usect "iir_vars",256 ; for 128 samples
	DataInternal 	.usect "iir_bfr",K_BUFFER_SIZE
	DataTempBuff 	.usect "iir_bfr",1
	


**********************************************************
* Init section *
**********************************************************
	.text
Init
	LD #0,A 	; acc = >00000000.
	STLM A,SWWSR 	; 0 Wait States.
	STLM A,BSCR 	; Bank shift.
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
	.asg AR0,IIR_INDEX 	; Circ buff index AR0=1
	.asg AR2,pIIR_DATA 	; data circular buffer pointer
	.asg AR3,pIIR_COEFF 	; Coefficient pointer
	.asg AR4,pINBUF 	; Input data
	.asg AR5,pOUTBUF 	; Output data
	.sect "iir_prog"
IirFilterInit
	STM #DataInternal,pIIR_DATA
	RPTZ A,#(K_BUFFER_SIZE-1) 	; Clear the internal data
	STL A,*pIIR_DATA+ 		; data buffer
	STM #DataInternal,pIIR_DATA 	; pIIR_DATA points on the
					; first high word of the
					; data buffer
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
	STM #(DataFilout),pOUTBUF 		; Load output add mem
	LD #0,A
	MPY *pIIR_DATA+0%,*pIIR_COEFF,B 	; A2*x(n-2)high
	MACSU *pIIR_DATA+0%,*pIIR_COEFF+,A 	; A2*x(n-2)low
	MAC *pIIR_DATA+0%,*pIIR_COEFF,B 	; A1*x(n-1)high
	MACSU *pIIR_DATA+0%,*pIIR_COEFF+,A 	; A1*x(n-1)low
	MVDD *pINBUF+,*pIIR_DATA+ 		; Load x(n) (32 bits)
	MVDD *pINBUF+,*pIIR_DATA- 		; in the buffer
	MAC *pIIR_DATA+0%,*pIIR_COEFF,B 	; A0*x(n)high
	MACSU *pIIR_DATA+0%,*pIIR_COEFF+,A 	; A0*x(n)low
	MAC *pIIR_DATA+0%,*pIIR_COEFF,B 	; -B2*y(n-2)high
	MACSU *pIIR_DATA+0%,*pIIR_COEFF+,A 	; -B2*y(n-2)low
	MAC *pIIR_DATA+0%,*pIIR_COEFF,B 	; -B1*y(n-1)high
	MACSU *pIIR_DATA+0%,*pIIR_COEFF,A 	; -B1*y(n-1)low
	ADD A,-16,B
	MAR *+pIIR_COEFF(-4) 			; pIIR_COEFF points on A2
	STH B,*pIIR_DATA+0% 			; Store y(n) in the buffer
	STL B,*pIIR_DATA+0%
	DST B,*pOUTBUF+ 			; Store y(n) in the output
IirFilterLoopEnd

	RET
	.end