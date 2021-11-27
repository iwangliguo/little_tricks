
; Example 4 - 10. Implementation of an IIR 32¡Á32-bit Direct Form II for the TMS320C54x DSP

; TEXAS INSTRUMENTS FRANCE
; Audio DSP Development
; ASM Code Module of the iir32x32.asm
; AUTHOR CAVALIER Philippe
; MESSINA Nathalie
;
; (C) Copyright 1997. Texas Instruments France. All rights reserved
;
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
K_IIR_INDEX 	.set 2 ; Circ buff index
K_IIR_BFFR 	.set 6 ; Circ buff size
iir_coff_table 	.sect "iir_coff"
		.word 00000h ;-B2 low
		.word 0DC01h ;-B2 high
		.word 00000h ;-B1 low
		.word 063D6h ;-B1 high
		.word 00000h ;A2 low
		.word 0100Ah ;A2 high
		.word 00000h ;A1 low
		.word 02014h ;A1 high
		.word 00000h ;A0 low
		.word 0100Ah ;A0 high
		
		
**********************************************************
* Set up in/out buffer *
**********************************************************    
d_filin 	.usect "iir_vars",256 	; for 128 samples
d_filout 	.usect "iir_vars",256 	; for 128 samples
d_iir_dn 	.usect "iir_bfr",6 	; to store d(n),d(n-1),d(n-2)
d_iir_y 	.usect "iir_bfr",1 


**********************************************************
* Init section *
**********************************************************
	.text
init
	LD #0,A 				; acc = >00000000.
	STLM A,SWWSR 				; 0 Wait States.
	STLM A,BSCR 				; Bank shift.
	STM #K_ST0,ST0
	STM #K_ST1,ST1
	STM #K_PMST,PMST
	
	
****************************************************************
* *
* Main program *
* *
****************************************************************
Main
	CALL iir_init
Continue
	NOP
	NOP
	CALL iir_task
	NOP
	NOP
	B Continue
	
	
****************************************************************
* *
* Sub routines *
* *
****************************************************************
	.asg AR0,pIIR_INDEX 		; Circ buff index
	.asg AR2,pIIR_DATA_L 		; Low word of internal value
	.asg AR3,pIIR_DATA_H 		; High word of internal value
	.asg AR4,pIIR_COFF 		; Coefficient pointer
	.asg AR6,pINBUF 		; Input data
	.asg AR7,pOUTBUF 		; Output data

	.sect "iir_prog"
iir_init

	STM #d_iir_dn,pIIR_DATA_L
	RPTZ A,#K_IIR_BFFR-1 		; Clear the internal
	STL A,*pIIR_DATA_L+ 		; value buffer
	STM #d_iir_dn+1,pIIR_DATA_L
					; pIIR_DATA_L points on the first low
					; word of the internal value
	STM #d_iir_dn,pIIR_DATA_H
					; pIIR_DATA_H points on the first high
					; word of the internal value
	STM #iir_coff_table,pIIR_COFF
					; pIIR_COFF points on the low word of
					; the first coefficient A2
	STM #K_IIR_BFFR,BK 		; Load circ buff size
	RETD
	STM #K_IIR_INDEX,pIIR_INDEX 	; Load circ buff index
	
	
;--------------------------------------------------------------
	.sect "iir_prog"   

iir_task
	STM #(d_filin),pINBUF 		; Load input add mem
	STM #K_FRAME_SIZE-1,BRC
	RPTBD iir_filter_loop_end-1
	STM #(d_filout),pOUTBUF 	; Load output add mem
	DLD *pINBUF+,A 			; Load in A the new Q31
	LD A,-2,A 			; sample that will be treated

iir_filter

;feedback_path
	LD #0,B
	MACSU *pIIR_COFF+,*pIIR_DATA_H,B 	; B=b2Low*d(n-2)High
	MACSU *pIIR_DATA_L+0%,*pIIR_COFF,B 	; B=B+b2High*d(n-2)Low
	MAC *pIIR_COFF+,*pIIR_DATA_H+0%,A 	; A=A+b2High*d(n-2)High
	MACSU *pIIR_COFF+,*pIIR_DATA_H,B 	; B=b1Low*d(n-1)High
	MACSU *pIIR_DATA_L+0%,*pIIR_COFF,B 	; B=B+b1High*d(n-1)Low
	MAC *pIIR_COFF+,*pIIR_DATA_H+0%,A 	; A=A+b1High*d(n-1)High
	ADD B,-16,A 				; 16 Right shift \ add
	STL A,*pIIR_DATA_L+0% 			; Store d(n) the result
	STH A,*pIIR_DATA_H+0% 			; of the add and mult.

; forward_path
	LD #0,B
	MACSU *pIIR_COFF+,*pIIR_DATA_H,B 	; B=a2Low*d(n-2)High
	MACSU *pIIR_DATA_L+0%,*pIIR_COFF,B 	; B=B+a2High*d(n-)Low
	MPY *pIIR_COFF+,*pIIR_DATA_H+0%,A 	; A=A+a2High*d(n-2)High
	MACSU *pIIR_COFF+,*pIIR_DATA_H,B 	; B=a1Low*d(n-1)High
	MACSU *pIIR_DATA_L+0%,*pIIR_COFF,B 	; B=a1Low*d(n-1)High
	MAC *pIIR_COFF+,*pIIR_DATA_H+0%,A 	; A=A+a1High*d(n-1)High
	MACSU *pIIR_COFF+,*pIIR_DATA_H,B 	; B=a0Low*d(n)High
	MACSU *pIIR_DATA_L+0%,*pIIR_COFF,B 	; B=a0Low*d(n)High
	MAC *pIIR_COFF,*pIIR_DATA_H+0%,A 	; A=A+a0High*d(n)High
	ADD B,-16,A
	MAR *pIIR_DATA_L+0% 			; Update the circular
	MAR *pIIR_DATA_H+0% 			; buffer d(n-2)=d(n-1)
						; and d(n-1)=d(n)
	MAR *+pIIR_COFF(-9)
	LD A,2,A
	STH A,*pOUTBUF+ 			; Store the low and high
	STL A,*pOUTBUF+ 			; part of the Q31 result
iir_filter_loop_end

	RET
	.end

	