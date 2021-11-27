
; Example 4 - 11. Implementation of an IIR 32¡Á32-bit Canonical Direct Form I for the TMS320C54x DSP

; TEXAS INSTRUMENTS FRANCE
;
; AUTHOR CAVALIER Philippe
; MESSINA Nathalie
;
; (C) Copyright 1997. Texas Instruments France. All rights reserved
**********************************************************
* macro definitions *
**********************************************************
.mmregs
.include "init54x.inc"
**********************************************************
* reset/interrupt/trap vector *
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
K_NB_FILTER 	.set 5 ; Number of 2nd-order IIR filter
K_BUFFER_INDEX 	.set 2 ; Circ buff index
K_BUFFER_SIZE 	.set 2*3*(K_NB_FILTER+1)-2 ; Circ buff size
EqzCoffTable 	.sect "eqz_coff"
		.word 0000h ;A2/2 low
		.word 03fd4h ;A2/2 high
		.word 0000h ;A1/2 low
		.word 0802dh ;A1/2 high
		.word 0000h ;A0/2 low
		.word 03fffh ;A0/2 high
		.word 0000h ;-B2/2 low
		.word 0c02ah ;-B2/2 high
		.word 0000h ;-B1/2 low
		.word 07fd2h ;-B1/2 high
		.word 0000h ;A2/2 low
		.word 03ef4h ;A2/2 high
		.word 0000h ;A1/2 low
		.word 081a8h ;A1/2 high
		.word 0000h ;A0/2 low
		.word 03f80h ;A0/2 high 
		.word 0000h ;-B2/2 low
		.word 0c189h ;-B2/2 high
		.word 0000h ;-B1/2 low
		.word 07e57h ;-B1/2 high
		.word 0000h ;A2/2 low
		.word 03d54h ;A2/2 high
		.word 0000h ;A1/2 low
		.word 082b9h ;A1/2 high
		.word 0000h ;A0/2 low
		.word 04105h ;A0/2 high
		.word 0000h ;-B2/2 low
		.word 0c1a5h ;-B2/2 high
		.word 0000h ;-B1/2 low
		.word 07d46h ;-B1/2 high
		.word 0000h ;A2/2 low
		.word 039f9h ;A2/2 high
		.word 0000h ;A1/2 low
		.word 091d5h ;A1/2 high
		.word 0000h ;A0/2 low
		.word 03ef8h ;A0/2 high
		.word 0000h ;-B2/2 low
		.word 0c70dh ;-B2/2 high
		.word 0000h ;-B1/2 low
		.word 06e2ah ;-B1/2 high
		.word 0000h ;A2/2 low
		.word 032c2h ;A2/2 high
		.word 0000h ;A1/2 low
		.word 0d345h ;A1/2 high
		.word 0000h ;A0/2 low
		.word 03d01h ;A0/2 high
		.word 0000h ;-B2/2 low
		.word 0d03bh ;-B2/2 high
		.word 0000h ;-B1/2 low
		.word 02cbah ;-B1/2 high
		
		
**********************************************************
* Set up in/out buffer *
**********************************************************
DataFilin 	.usect "eqz_vars",256 ; for 32 samples
DataFilout 	.usect "eqz_vars",256 ; for 32 samples
DataInternal 	.usect "eqz_bfr",K_BUFFER_SIZE
DataTempBuff 	.usect "eqz_bfr",1


**********************************************************
* Init section *
**********************************************************
	.text
Init
	LD #0,A ; acc = >00000000.
	STLM A,SWWSR ; 0 Wait States.
	STLM A,BSCR ; Bank shift.
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
	.asg AR0,EQZ_INDEX ; Circular buffer index
	.asg AR1,EQZ_NB
	.asg AR2,pEQZ_DATA_L ; Low word of internal value
	.asg AR3,pEQZ_DATA_H ; High word of internal value
	.asg AR4,pEQZ_COFF ; Coefficients pointer
	.asg AR5,pTEMP_BUFF
	.asg AR6,pINBUF ; Input data
	.asg AR7,pOUTBUF ; Output data

	.sect "eqz_prog"

EqzInit
	STM #DataInternal,pEQZ_DATA_L
	RPTZ A,#K_BUFFER_SIZE-1 	; Clear the internal
	STL A,*pEQZ_DATA_L+ 		; value buffer
	STM #(DataTempBuff),pTEMP_BUFF
	STM #DataInternal+1,pEQZ_DATA_L
					; pEQZ_DATA_L points on the
					; first low word of the internal value
	STM #DataInternal,pEQZ_DATA_H
					; pEQZ_DATA_H points on the
					; first high word of the internal value
	STM #EqzCoffTable,pEQZ_COFF
					; pEQZ_COFF points on the first
					; coefficient
	STM #K_BUFFER_SIZE,BK 		; Load circ buff size
	RETD
	STM #K_BUFFER_INDEX,EQZ_INDEX 	; Load circ buff index

;--------------------------------------------------------------
	.sect "eqz_prog"
	.bss InputHigh,1
	.bss InputLow,1

EqzTask
	STM #(DataFilin),pINBUF 	; Load input add mem
	STM #(K_FRAME_SIZE-1),BRC 	; Load loop counter

EqzFilterBegin
	RPTBD EqzFilterEnd-1
	STM #(DataFilout),pOUTBUF 	; Load output add mem
	STM #(K_NB_FILTER-2),EQZ_NB
	DLD *pINBUF+,B
	LD B,-2,B
	DST B,*pTEMP_BUFF
	LD #0,B
	MACSU *pEQZ_COFF+,*pEQZ_DATA_H,B 	;a2/2low*x0(n-2)high
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF,B 	;a2/2high*x0(n-2)low
	MPY *pEQZ_COFF+,*pEQZ_DATA_H+0%,A 	;a2/2high*x0(n-2)high
	MACSU *pEQZ_COFF+,*pEQZ_DATA_H,B 	;a1/2low*x1(n-1)high
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF,B 	;a1/2high*x1(n-1)low
	MAC *pEQZ_COFF+,*pEQZ_DATA_H+0%,A 	;a1/2high*x1(n-1)high
	MVDD *pTEMP_BUFF+,*pEQZ_DATA_H 		;x(n)high storage
	MVDD *pTEMP_BUFF-,*pEQZ_DATA_L 		;x(n)low storage

	MACSU *pEQZ_COFF+,*pEQZ_DATA_H,B 	;a0/2low*x(n)high
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF,B 	;a0/2high*x(n)low
	MAC *pEQZ_COFF+,*pEQZ_DATA_H+0%,A 	;a0/2high*x(n)high
Loop:
	MACSU *pEQZ_COFF+,*pEQZ_DATA_H,B 	;b2/2low*y(n-2)high
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF,B 	;b2/2high*y(n-2)low
	MAC *pEQZ_COFF+,*pEQZ_DATA_H+0%,A 	;b2 /2high*y(n-2)high
	MACSU *pEQZ_COFF+,*pEQZ_DATA_H,B 	;b1/2low*y(n-1)high
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF,B 	;b1/2high*y(n-1)high
	MAC *pEQZ_COFF+,*pEQZ_DATA_H+0%,A ;	b1/2high*y(n-1)high
	ADD B,-16,A
	LD A,1,A
	STH A,*pEQZ_DATA_H-0%
	STL A,*pEQZ_DATA_L-0%
	LD #0,B
	MAR *pEQZ_DATA_H-0%
	MAR *pEQZ_DATA_L-0%
	MACSU *pEQZ_COFF+,*pEQZ_DATA_H,B 	;a2/2low*x(n-2)high next
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF,B 	;a2/2high*x(n-2)low next
	MPY *pEQZ_COFF+,*pEQZ_DATA_H+0%,A 	;a2/2high*x(n-2)high next
	MACSU *pEQZ_COFF+,*pEQZ_DATA_H,B 	;a1/2low*x(n-1)high next
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF,B 	;a1/2high*x(n-1)low next
	MAC *pEQZ_COFF+,*pEQZ_DATA_H+0%,A 	;a1/2high*x(n-1)high next
	MACSU *pEQZ_COFF+,*pEQZ_DATA_H,B 	;a0/2low*x(n)high next
	BANZD Loop,*EQZ_NBMACSU
	*pEQZ_DATA_L+0%,*pEQZ_COFF,B 		;a0/2high*x(n)low next
	MAC *pEQZ_COFF+,*pEQZ_DATA_H+0%,A 	;a0/2high*x(n)high next
EndLoop

	MACSU *pEQZ_COFF+,*pEQZ_DATA_H,B 	;b2/2low*y(n-2)high next
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF,B 	;b2/2high*y(n-2)low next
	MAC *pEQZ_COFF+,*pEQZ_DATA_H+0%,A 	;b2/2high*y(n-2)high next
	MACSU *pEQZ_COFF+,*pEQZ_DATA_H,B 	;b1/2low*y(n-1)high next
	MACSU *pEQZ_DATA_L+0%,*pEQZ_COFF,B 	;b1/2high*y(n-1)low next
	MAC *pEQZ_COFF+,*pEQZ_DATA_H+0%,A 	;b1/2high*y(n-1)high next
	ADD B,-16,A
	LD A,1,A
	STH A,*pEQZ_DATA_H+0%
	STL A,*pEQZ_DATA_L+0%
	MAR *+pEQZ_COFF(-24)
	DST A,*pOUTBUF+
EqzFilterEnd


	RET
	.end
	
	
	
	