
; Example 4 - 8. Implementation of an IIR 32¡Á16-bit Canonical Direct Form I for the TMS320C54x DSP

; TEXAS INSTRUMENTS FRANCE
; Audio DSP Development
; ASM Code Module of the eqz32x16.asm
; AUTHOR CAVALIER Philippe
; MESSINA Nathalie
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
	BD Init 		; Branch to MainLine.
	NOP
	NOP
	
	
	
**********************************************************
* Set up constant and filter coeff *
**********************************************************
K_FRAME_SIZE 	.set 128 ; Number of samples
K_NB_FILTER 	.set 5 ; Number of 2nd-order IIR filter
K_BUFFER_INDEX 	.set 2 ; Circ buff index
K_BUFFER_SIZE 	.set 2*3*(K_NB_FILTER+1)-2 ; Circ buff size
EqzCoffTable 	.sect "eqz_coff"
		.word 03fd4h ; A2/2 first IIR filter
		.word 0802dh ; A1/2
		.word 03fffh ; A0/2 (0dB/100hz)
		.word 0c02ah ; -B2/2
		.word 07fd2h ; -B1/2
		.word 03ef4h ; A2/2
		.word 081a8h ; A1/2
		.word 03f80h ; A0/2 (-9dB/330hz)
		.word 0c189h ; -B2/2
		.word 07e57h ; -B1/2
		.word 03d54h ; A2/2
		.word 082b9h ; A1/2
		.word 04105h ; A0/2 (7dB/1khz)
		.word 0c1a5h ; -B2/2
		.word 07d46h ; -B1/2		
		.word 039f9h ; A2/2
		.word 091d5h ; A1/2
		.word 03ef8h ; A0/2 (-3dB/3k3hz)
		.word 0c70dh ; -B2/2
		.word 06e2ah ; -B1/2
		.word 032c2h ; A2/2 Last IIR filter
		.word 0d345h ; A1/2
		.word 03d01h ; A0/2 (-4dB/10khz)
		.word 0d03bh ; -B2/2
		.word 02cbah ; -B1/2
**********************************************************
* Set up in/out buffer *
**********************************************************


DataFilin 	.usect "eqz_vars",256 			; for 32 samples
DataFilout 	.usect "eqz_vars",256 			; for 32 samples
DataInternal 	.usect "eqz_bfr",K_BUFFER_SIZE		; to store d(n),d(n-1),d(n-2)
DataTempBuff 	.usect "eqz_bfr",1


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
	
	
****************************************************************
* *
* Main program *
* *
****************************************************************
Main
	CALL EqzInit
Continue
	NOP
	NOP
	CALL EqzTask
	NOP
	NOP
	B Continue
	
	
****************************************************************
* *
* Sub routines *
* *
****************************************************************
	.asg AR0,EQZ_INDEX 	; Circ buff index
	.asg AR1,EQZ_NB 	; Number of filters
	.asg AR2,pEQZ_DATA_L 	; Low word of data buffer
	.asg AR3,pEQZ_DATA_H 	; High word of data buffer 
	.asg AR4,pEQZ_COFF_1 	; Coefficient pointer 1
	.asg AR5,pEQZ_COFF_2 	; Coefficient pointer 2
	.asg AR6,pINBUF 	; Input data
	.asg AR7,pOUTBUF 	; Output data

	.sect "eqz_prog"

EqzInit
	STM #DataInternal,pEQZ_DATA_L
	RPTZ A,#(K_BUFFER_SIZE-1) 	; Clear the data
	STL A,*pEQZ_DATA_L+ 		; buffer
	STM #DataInternal+1,pEQZ_DATA_L
					; pEQZ_DATA_L points on the
					; first low word of the data buffer
	STM #DataInternal,pEQZ_DATA_H
					; pEQZ_DATA_H points on the
					; first high word of the data buffer
	STM #K_BUFFER_SIZE,BK 		; Load circ buff size
	STM #K_BUFFER_INDEX,EQZ_INDEX 	; Load circ buff index
	STM #EqzCoffTable,pEQZ_COFF_1 	; pEQZ_COFF_1 points on the
					; first coefficient
	RETD
	STM #EqzCoffTable,pEQZ_COFF_2
					; pEQZ_COFF_2 points also on


; the first coefficient
;--------------------------------------------------------------

EqzTask
	STM #(DataFilin),pINBUF 	; Load input add mem
	STM #(K_FRAME_SIZE-1),BRC 	; Load loop counter
EqzFilterBegin
	RPTBD EqzFilterEnd-1
	STM #(DataFilout),pOUTBUF 	; Load output add mem
	STM #(K_NB_FILTER-2),EQZ_NB
	DLD *pINBUF+,B
	LD B,-2,B
	LD #0,A
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF_1+,A 		;a2/2*x0low(n-2)
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF_1+,A 		;a1/2*x0low(n-1)
	STL B,*pEQZ_DATA_L-% 				;storage x0high(n)
	STH B,*pEQZ_DATA_L+% 				;storage x0low(n)
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF_1+,A 		;a0/2*x0low(n)
	MPY *pEQZ_DATA_H+0%,*pEQZ_COFF_2+,B 		;a2/2*x0high(n-2)
	MAC *pEQZ_DATA_H+0%,*pEQZ_COFF_2+,B 		;a1/2*x0high(n-1)
	MAC *pEQZ_DATA_H+0%,*pEQZ_COFF_2+,B 		;a0/2*x0high(n)
Loop:
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF_1+,A 		;-b2/2*ylow(n-2)
	MACSU *pEQZ_DATA_L,*pEQZ_COFF_1+,A 		;-b1/2*ylow(n-1)
	ADD A,-16,B
	MAC *pEQZ_DATA_H+0%,*pEQZ_COFF_2+,B 		;-b2/2*yhigh(n-2)
	MAC *pEQZ_DATA_H,*pEQZ_COFF_2+,B 		;-b1/2*yhigh(n-1)
	MAR *pEQZ_DATA_L-0%
	MAR *pEQZ_DATA_H-0%
	MPY *pEQZ_DATA_H+0%,*pEQZ_COFF_2+,A 		;a2/2*xhigh(n-2)next
	MAC *pEQZ_DATA_H+0%,*pEQZ_COFF_2+,A 		;a1/2*xhigh(n-1)next
	LD B,1,B
	DST B,*pEQZ_DATA_H
	MAC *pEQZ_DATA_H+0%,*pEQZ_COFF_2+,A 		;a0/2*xhigh(n)next
	LD A,B
	LD #0,A
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF_1+,A 		;a2/2*xlow(n-2)next
	BANZD Loop,*EQZ_NBMACSU
	*pEQZ_DATA_L+0%,*pEQZ_COFF_1+,A 		;a1/2*xlow(n-1)next
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF_1+,A 		;a0/2*xlow(n)next
EndLoop
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF_1+,A 		;-b2/2*ylow(n-2)
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF_1,A 		;-b1/2*ylow(n-2)
	ADD A,-16,B
	MAC *pEQZ_DATA_H+0%,*pEQZ_COFF_2+,B 		;-b2/2*yhigh(n-2)
	MAC *pEQZ_DATA_H+0%,*pEQZ_COFF_2,B 		;-b1/2*yhigh(n-1)
	LD B,1,B
	STH B,*pEQZ_DATA_H+0%
	STL B,*pEQZ_DATA_L+0%
	MAR *+pEQZ_COFF_1(-24)
	MAR *+pEQZ_COFF_2(-24)
	DST B,*pOUTBUF+
EqzFilterEnd

	RET
	.end
	
	
	
	





























