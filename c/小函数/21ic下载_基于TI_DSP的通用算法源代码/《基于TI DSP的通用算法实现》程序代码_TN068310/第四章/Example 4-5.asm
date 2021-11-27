
;Example 4 - 5. Modified Direct-I IIR Filter ASM Listing for the TMS320C54x DSP

;***************************************************************
; New IIR Low pass filter design
; Language : C54x
; Filter type : Elliptic Filter
; Filter order : 4 order (cascade: 1 order + 2nd order + 1 order)
; canonical direct from I
; cut freq. of pass band : 200 Hz
; cut freq. of stop band : 500 Hz
; Designer : Mandy Tsai
; Date : Feb,20,1996
; ***************************************************************

	.mmregs
	.def begin, N
N 	.set 2 		; length of IIR filter
Q_FACT 	.set 32768
	.bss d,3*2
	.bss X,1
	.bss Y,1
	.data

* Q31 format

table
;*
;* SECOND�CORDER SECTION # 01
;*
	.word 19381 	;B2
	.word �C23184 	;B1
	.word 19381 	;B0
	.word �C26778 	;A2
	.word 29529 	;A1/2
;*
;* SECOND-ORDER SECTION # 02
;*
	.word 11363 	;B2
	.word �C20735 	;B1
	.word 11363 	;B0
	.word �C30497 	;A2
	.word 31131 	;A1/2

	.sect ��vectors�� ;define a reset vector

	B begin

begin .text ;the start of the program
	STM #1111111110100000b,PMST ;initial PMST
	STM #0010001100000000b,ST1 ;initial ST1
	STM #0,SWWSR ;zero wait state
	SSBX OVM
	SSBX FRCT ;FRCT=1 : output of multiply will left shift 1 bit automatically

	SSBX	SXM
	STM 	#d,AR3 			;AR3:d(n),d(n�C1),d(n�C2)
	RPTZ 	A,#7 				;initial d(n),d(n�C1),d(n�C2)=0
	STL 	A,*AR3+
	STM 	#2,AR0
INLOOP:
	STM 	#d+7,AR3 			;AR1:d(n),d(n�C1),d(n�C2)
	STM 	#table,AR4 		;AR2:coeff of IIR filter �Ca2,�Ca1,b2,b1,b0
	MPY 	*AR4+,*AR3�C,A 	;A=d(n�C2)*b2
	MAC 	*AR4+,*AR3,A 		;A=A+d(n�C1)*b1
	DELAY 	*AR3�C
	MAC 	*AR4+,*AR3,A 		;A=A+d(n)*b0
	DELAY 	*AR3
	PORTR	100H,*AR3
	LD 		*AR3,B
	STH 	B,11,*AR3�C 		;left shift by 5 to scale the input
	STM 	#N�C2,BRC
	RPTB 	ELOOP�C1
LOOP:
; feedback_path
	MAC 	*AR4+,*AR3�C,A 	;A = A+d(n�C2)*(�Ca2)
	MAC 	*AR4,*AR3,A 		;A = A+d(n�C1)*(�Ca1)
	MAC 	*AR4+,*AR3�C,A
	STH 	A,*AR3+0 			;save d(n)
; forward_path
	MPY 	*AR4+,*AR3�C,A 	;A=d(n�C2)*b2
	MAC 	*AR4+,*AR3,A 		;A=A+d(n�C1)*b1
	DELAY 	*AR3�C
	MAC 	*AR4+,*AR3,A 		;A=A+d(n)*b0
	DELAY 	*AR3�C
ELOOP:
	MAC 	*AR4+,*AR3�C,A
	MAC 	*AR4,*AR3,A
	MAC 	*AR4+,*AR3,A
	DELAY 	*AR3
	STH 	A, *AR3
	PORTW 	*AR3, 200h 		;write the result to a file
	B 	INLOOP

