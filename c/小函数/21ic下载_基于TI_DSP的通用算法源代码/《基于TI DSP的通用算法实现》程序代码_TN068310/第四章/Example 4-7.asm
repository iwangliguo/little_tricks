
; Example 4 - 7. Implementation of an IIR 32¡Á16-bit Direct Form II for the TMS320C54x DSP

; TEXAS INSTRUMENTS FRANCE
; AUTHORS CAVALIER Philippe
; ERCOLE Damien
;
; (C) Copyright 1997. Texas Instruments France. All rights reserved
;
;
****************************************************************
* Macro definitions *
****************************************************************
.mmregs
.include "init54x.inc"
****************************************************************
* Reset/interrupt/trap vectors *
****************************************************************
*
* Always start from Reset.
*

	.global start
	.sect "vecs"
start
	BD init ; Branch to MainLine.
	NOP
	NOP
	
	
****************************************************************
* Set up constant and filter coeff *
****************************************************************

K_FRAME_SIZE 	.set 128 	; Number of samples
K_IIR_INDEX 	.set 2 		; Circ buff index
K_IIR_BFFR 	.set 6 		; Circ buff size
iir_coff_table 
		.sect "iir_coff"
		.word 0DC01h 	; -B2
		.word 063D6h 	; -B1
		.word 0100Ah 	; A2
		.word 02014h 	; A1
		.word 0100Ah 	; A0
	
	
****************************************************************
* Set up in/out buffer *
****************************************************************

d_filin 	.usect "iir_vars",256 	; for 32 samples
d_filout 	.usect "iir_vars",256 	; for 32 samples
d_iir_dn 	.usect "iir_bfr",6 	; to store d(n),d(n-1),d(n-2)

****************************************************************
* Init section *
****************************************************************

	.text
init

	LD #0,A 	; acc = >00000000.
	STLM A,SWWSR 	; 0 Wait States.
	STLM A,BSCR 	; Bank shift.
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

	.asg AR0,IIR_INDEX 	; Circ buff index
	.asg AR2,IIR_DATA_P_L 	; Low word of internal value
	.asg AR3,IIR_DATA_P_H 	; High word of internal value
	.asg AR4,IIR_COFF_P_1 	; Coefficient pointer 1
	.asg AR5,IIR_COFF_P_2 	; Coefficient pointer 2
	.asg AR6,INBUF_P 	; Input data
	.asg AR7,OUTBUF_P 	; Output data

	.sect "iir_prog"

iir_init
	STM #d_iir_dn,IIR_DATA_P_L
	RPTZ A,#(K_IIR_BFFR-1) 		; Clear the internal
	STL A,*IIR_DATA_P_L+ 		; value buffer
	STM #d_iir_dn+1,IIR_DATA_P_L
					; IIR_DATA_P_L points on the
					; first low word of the internal value
	STM #d_iir_dn,IIR_DATA_P_H
					; IIR_DATA_P_H points on the
					; first high word of the internal value
	STM #iir_coff_table,IIR_COFF_P_1
					; IIR_COFF_P_1 points on the
					; first coefficient -B2
	STM #iir_coff_table,IIR_COFF_P_2
					; IIR_COFF_P_2 points on the
					; first coefficient -B2
	STM #K_IIR_BFFR,BK 		; Load circ buff size

	RETD
	STM #K_IIR_INDEX,IIR_INDEX 	; Load circ buff index
;--------------------------------------------------------------


iir_task
	STM #(d_filin),INBUF_P 		; Load input add mem
	STM #K_FRAME_SIZE-1,BRC
	RPTBD iir_filter_loop_end-1
	STM #(d_filout),OUTBUF_P 	; Load output address memory
	DLD *INBUF_P+,A 		; Load in A the new Q31 sample
	LD A,-2,A 			; pre scaling

; feedback_path
	LD #0,B
	MACSU *IIR_DATA_P_L+0%,*IIR_COFF_P_1+,B 	; -b2*d(n-2)low
	MACSU *IIR_DATA_P_L+0%,*IIR_COFF_P_1+,B 	; -b1*d(n-1)low
	ADD B,-16,A 					;x(n)+(-b2*d(n-2)low-b1*d(n-1)low)>>16
	MAC *IIR_COFF_P_2+,*IIR_DATA_P_H+0%,A 		;-b2*d(n-2)high
	MAC *IIR_COFF_P_2+,*IIR_DATA_P_H+0%,A 		;-b1*d(n-1)high
	STL A,*IIR_DATA_P_L+0% 				; Store the 32-bit result d(n)
	STH A,*IIR_DATA_P_H+0%

;forward_path
	LD #0,B
	MACSU *IIR_DATA_P_L+0%,*IIR_COFF_P_1+,B 	;a2*d(n-2)low
	MACSU *IIR_DATA_P_L+0%,*IIR_COFF_P_1+,B 	;a1*d(n-1)low
	MACSU *IIR_DATA_P_L+0%,*IIR_COFF_P_1+0%,B 	;a0*d(n)low
	LD B,-16,B 					;a0*d(n)low+a1*d(n-1)low+a2*d(n-2)low>>16

	MAC *IIR_COFF_P_2+,*IIR_DATA_P_H+0%,B 		;a2*d(n-2)high
	MAC *IIR_COFF_P_2+,*IIR_DATA_P_H+0%,B 		;a1*d(n-1)high
	MAC *IIR_COFF_P_2+0%,*IIR_DATA_P_H+0%,B 	;a0*d(n)high

	MAR *IIR_DATA_P_L+0% 				; Update d(n-2)=d(n-1)
	MAR *IIR_DATA_P_H+0% 				; Update d(n-1)=d(n)
	LD B,2,B 					; post scaling
	STH B,*OUTBUF_P+ 				; Store the low and high
	STL B,*OUTBUF_P+ 				; part of the Q31 result
iir_filter_loop_end
	RET
	.end