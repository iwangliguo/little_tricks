
; Example 4 - 9. Implementation of an IIR 32¡Á32-bit Direct Form I for the TMS320C54x DSP


; TEXAS INSTRUMENTS FRANCE
;
; AUTHOR MESSINA Nathalie
; CAVALIER Philippe
;
; (C) Copyright 1997. Texas Instruments France. All rights reserved
;---------------------------------------------------------------
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
	.global start
	.sect "vecs"
start
	BD init ; Branch to MainLine.
	NOP
	NOP
	
	
**********************************************************
* Set up constant and filter coeff *
**********************************************************
K_FRAME_SIZE 	.set 128 ; Number of samples
K_BUFFER_INDEX 	.set 2 ; Circ buff index
K_BUFFER_SIZE 	.set 2*(3*2-1) ; Circ buff size
iir_coff_table 	.sect "iir_coff"
		.word 0100Ah 	;A2 high
		.word 0h 	;A2 low
		.word 02014h 	;A1 high
		.word 0h 	;A1 low
		.word 0100Ah 	;A0 high
		.word 0h 	;A0 low
		.word 0DC01h 	;-B2 high
		.word 0h 	;-B2 low
		.word 063D6h 	;-B1 high
		.word 0h 	;-B1 low
		
		
**********************************************************
* Set up in/out buffer *
**********************************************************
d_filin 	.usect "iir_vars",256 			; for 32 samples
d_filout 	.usect "iir_vars",256 			; for 32 samples
d_internal 	.usect "iir_bfr",K_BUFFER_SIZE      
d_temp_buff 	.usect "iir_bfr",1


**********************************************************
* Init section *
**********************************************************
	.text
init
	LD #0,A 		; acc = >00000000.
	STLM A,SWWSR 		; 0 Wait States.
	STLM A,BSCR 		; Bank shift.
	TM #K_ST0,ST0
	STM #K_ST1,ST1
	STM #K_PMST,PMST
	
	
****************************************************************
* *
* Main program *
* *
****************************************************************
Main
	CALL IirFilterInit
Continue
	NOP
	NOP
	CALL IirFilterTask
	NOP
	NOP
	B Continue
	
	
****************************************************************
* *
* Sub routines *
* *
****************************************************************
	.asg AR0,IIR_INDEX 		; Circ buff index
	.asg AR2,pIIR_DATA_L 		; Low word of internal value
	.asg AR3,pIIR_DATA_H 		; High word of internal value
	.asg AR4,pIIR_COFF_L 		; Low Part Coefficient pointer
	.asg AR5,pIIR_COFF_H 		; High Part Coefficient pointer
	.asg AR6,pINBUF 		; Input data
	.asg AR7,pOUTBUF 		; Output data

	.sect "iir_prog"

IirFilterInit
	STM #d_internal,pIIR_DATA_L
	RPTZ A,#K_BUFFER_SIZE-1 	; Clear the internal
	STL A,*pIIR_DATA_L+ 		; value buffer
	STM #d_internal+1,pIIR_DATA_L
					; IIR_DATA_P_L points on the first low
					; word of the internal value
	STM #d_internal,pIIR_DATA_H
					; IIR_DATA_P_H points on the first
					; high word of the internal value
	STM #iir_coff_table,pIIR_COFF_H
					; IIR_COFF_P_H points on the high part
					; of the first coefficient
	STM #iir_coff_table+1,pIIR_COFF_L
					; IIR_COFF_P_L points on the low part
					; of the first coefficient
	STM #K_BUFFER_SIZE,BK 		; Load circ buff size
	RETD
	STM #K_BUFFER_INDEX,IIR_INDEX 	; Load circ buff index


;--------------------------------------------------------------
	.sect "iir_prog"
IirFilterTask

	STM #(d_filin),pINBUF 			; Load input add mem
	STM #K_FRAME_SIZE-1,BRC
	RPTBD IirFilterLoopEnd-1
	STM #(d_filout),pOUTBUF 		; Load output add mem

IirFilterBegin
	DLD *pINBUF+,A 				; Load in B the new Q31
	LD #0,B
	MACSU *pIIR_COFF_L+0%,*pIIR_DATA_H+0%,B ;a2low*x(n-2)high
	MACSU *pIIR_DATA_L+0%,*pIIR_COFF_H+0%,B ;a2high*x(n-2)low
	MACSU *pIIR_COFF_L+0%,*pIIR_DATA_H+0%,B ;a1low*x(n-1)high
	MACSU *pIIR_DATA_L+0%,*pIIR_COFF_H+0%,B ;a1high*x(n-1)low
	DST A,*pIIR_DATA_H ;store x(n)
	MACSU *pIIR_COFF_L+0%,*pIIR_DATA_H+0%,B ;a0low*x(n)high
	MACSU *pIIR_DATA_L+0%,*pIIR_COFF_H+0%,B ;a0high*x(n)low
	MACSU *pIIR_COFF_L+0%,*pIIR_DATA_H+0%,B ;-b2low*y(n-2)high
	MACSU *pIIR_DATA_L+0%,*pIIR_COFF_H+0%,B ;-b2high*y(n-2)low
	MACSU *pIIR_COFF_L+0%,*pIIR_DATA_H+0%,B ;-b1low*y(n-1)high
	MACSU *pIIR_DATA_L+0%,*pIIR_COFF_H+0%,B ;-b1high*y(n-1)low
	MPY *pIIR_COFF_H+0%,*pIIR_DATA_H+0%,A 	;a2high*x(n-2)high
	MAC *pIIR_COFF_H+0%,*pIIR_DATA_H+0%,A 	;a1high*x(n-1)high
	MAC *pIIR_COFF_H+0%,*pIIR_DATA_H+0%,A 	;a0high*x(n)high
	MAC *pIIR_COFF_H+0%,*pIIR_DATA_H+0%,A 	;-b2high*y(n-2)high
	MAC *pIIR_COFF_H+0%,*pIIR_DATA_H+0%,A 	;-b1high*x(n-1)high
	ADD B,-16,A ; y(n)
	STH A,*pIIR_DATA_H+0%
	STL A,*pIIR_DATA_L+0%
	DST A,*pOUTBUF+
IirFilterLoopEnd

	RET
	.end