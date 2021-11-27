
; Example 5 - 6. Single-Sample FIR Filter ASM Listing for the TMS320C55x DSP


******************************************************************************
* FILE: SSFIR_MNE.ASM *
* DESCRIPTION: Mnemonic C55xx DSP program for single每sample FIR *
* filter. *
* AUTHOR: David M. Alter, Texas Instruments, Inc. *
* DATE: February 24, 2000 *
* RESTRICTIONS: *
* (1) N_TAP (the number of taps) must be even. *
* (2) N_TAP (the number of taps) must be a minimum of 6. *
* (3) Overflow is not checked. *
* (4) Data and coefficients are assumed to be signed Q15 fractions. *
* (5) The section §delay_chain§ must be 32每bit aligned in memory. *
* COMMENTS: *
* (1) A dummy main routine is used to call the FIR function in *
* order to simulate A每to每D and D每to每A conversion hardware. *
******************************************************************************

	.def ssfir, rset
N_SAMP 	.set 199 ;# of input samples
N_TAP 	.set 16 ;# of filter taps
Q15 	.set 32768 ;Q15 fraction scale value


;********** INTERRUPT VECTORS **********
;This is an incomplete vector table for illustration purposes only
	
	.sect §vectors§
rset: 	.ivec start, USE_RETA 		;reset vector and stack mode
nmi: 	.ivec nmi 			;trap spurious NMI＊s
int2: 	.ivec ssfir 			;vector to ssfir ISR


******************************************************************************
******************************** MAIN ROUTINE ********************************
******************************************************************************
;Coefficients in Q15 fractional format
	.sect §coefficients§
a0 	.int Q15*1/32768 ;a0
	.int Q15*15/32768 ;a1
	.int Q15*105/32768 ;a2
	.int Q15*455/32768 ;a3
	.int Q15*1365/32768 ;a4
	.int Q15*3003/32768 ;a5
	.int Q15*5005/32768 ;a6
	.int Q15*6435/32768 ;a7
	.int Q15*6435/32768 ;a8
	.int Q15*5005/32768 ;a9
	.int Q15*3003/32768 ;a10
	.int Q15*1365/32768 ;a11
	.int Q15*455/32768 ;a12
	.int Q15*105/32768 ;a13
	.int Q15*15/32768 ;a14
	.int Q15*1/32768 ;a15
					;Input data in Q15 fractional format
	
	.sect §input_data§

x 	.copy DUALSINE.DAT 		;label at oldest input
					;Output array in Q15 fractional format
y .usect §output_data§, N_SAMP 	;label at oldest output
					;Simulate A/D and D/A converters using memory
	.bss ADC,1 			;simulated A/D converter
	.bss DAC,1 			;simulated D/A converter


;Filter delay chain has the following structure:
; word 0 = PRECALC[31:16]
; word 1 = PRECALC[15:0]
; word 2 = PRECALC[39:32]
; word 3 = CDPSAVE
; word 4 = start of delay chain
; ...
; word N_TAP+3 = end of delay chain
	
dchain 	.usect §delay_chain§, N_TAP+4, 1 	;delay chain structure
d0 	.set dchain+4 				;label at chain start
	
;********** DSP INITIALIZATION **********
	.text

start:
	BCLR C54CM 				;C54x compatibility off
	.c54cm_off

	BCLR ARMS ;compiler mode off
	.arms_off
						;Setup the stack
SP_stack_len 	.set 100
SSP_stack_len 	.set 100
SP_stack 	.usect §stack§, SP_stack_len
SSP_stack	.usect §stack§, SSP_stack_len
	
	AMOV #( SP_stack + SP_stack_len ), XSP
	MOV #( SSP_stack + SSP_stack_len ), SSP
						;Initialize the filter delay chain to zero
	AMOV #dchain, XAR0 			;pointer to delay chain
	MOV #0, AC0 				;clear AC0
	||RPT #((N_TAP+4)/2 每 1) 		;repeat single
	MOV AC0, dbl(*AR0+) 			;clear the delay chain
						;Pointer setup
	AMOV #x, XAR3				;pointer to input array
	AMOV #y, XAR4 				;pointer to output array
						;Start the main routine loop
	MOV #N_SAMP, T0				;initialize loop counter
loop:
	SUB #1, T0, T0 				;decrement the loop counter
	MOV *AR3+, AC0 				;read new input value
	MOV AC0, *(#ADC) 			;put new value into ADC
	INTR #2 				;simulate an ADC interrupt
	MOV *(#DAC), AC0 			;read FIR output from DAC
	MOV AC0, *AR4+ 				;write it to the output array
	BCC loop, T0 > #0 			;loop test
end: B end 					;trap the end of the program


;*****************************************************************************
;*********************** SINGLE每SAMPLE FIR FILTER ISR ************************
;*****************************************************************************

	.text
ssfir:
;********** CONTEXT SAVE **********
						;ST1, ST0 (except DP fields), RETA and CFCT registers are saved automatically.
	PSH mmap(@RPTC) 			;save RPTC
	PSH mmap(@BKC) 				;save BKC
	PSH mmap(@BSAC) 			;save BSAC
	PSH mmap(@ST2_55) 			;save ST2
						;Setup ST1 and ST2 early to avoid pipeline conflicts later
						;Set FRCT=1, SXMD=1, all other bits cleared
	MOV #0000000101000000b, mmap(@ST1_55)
						;Set CDP to circular mode, all other ARx＊s in linear mode
	MOV #0000000100000000b, mmap(@ST2_55)
						;Resume context saving
	PSH T0 			;save T0
	PSHBOTH XAR0 		;save XAR0
	PSHBOTH XAR1 		;save XAR1
	PSHBOTH XCDP 		;save XCDP
	PSH dbl(mmap(@AC0L)) 	;save AC0L and AC0H
	PSH dbl(mmap(@AC0G)) 	;save AC0G and AC1L
	PSH dbl(mmap(@AC1H)) 	;save AC1H and AC1G


;********** FILTER INITIALIZATION **********
	MOV #2, T0 		;T0 is pointer index
	AMOV #dchain, XAR0 	;AR0 points to PRECALC[31:16]
	MOV dbl(*AR0+), AC0 	;AC0 = PRECALC[31:0]
	MOV *AR0+, AC1 		;AC1 = PRECALC[39:32]
	MOV AC1, mmap(@AC0G) 	;AC0 = PRECALC[39:0]
	MOV XAR0, XCDP 		;setup CDPH
	MOV *AR0, CDP 		;CDP = CDPSAVE
	MOV #(N_TAP), BKC 	;delay chain length
	MOV #d0, BSAC 		;delay chain start address
	AMOV #a0, XAR0 		;AR0 points to a0
	AMOV #(a0 + 1), XAR1 	;AR1 points to a1

	MOV *(#ADC), AC1 	;read new input from ADC
	MOV AC1, *CDP 		;put it into the delay chain

;********** FILTER KERNEL **********
						;First dual每MAC is MAC||MPY
	MAC *(AR0+T0), *(CDP+T0), AC0
	::MPY *(AR1+T0), *(CDP+T0), AC1
	||RPT #(N_TAP/2 每 3)
						;Middle dual每MACs are all MAC||MAC
	MAC *(AR0+T0), *(CDP+T0), AC0
	::MAC *(AR1+T0), *(CDP+T0), AC1
						;Final dual每MAC has different pointer adjustments
	MAC *AR0, *CDP+, AC0
	::MAC *AR1, *CDP+, AC1

;********** FILTER TERMINATION **********
	AMOV #dchain, XAR0 			;AR1 points to CDPSAVE
	MOV AC1, dbl(*AR0+) 			;save PRECALC[31:0]
	MOV HI(AC1<<#(每16)), *AR0+ 		;save PRECALC[39:32]
	MOV CDP, *AR0 				;save CDP
	MOV HI(AC0), *(#DAC) 			;send result to the DAC

;********** CONTEXT RESTORE **********
	POP dbl(mmap(@AC1H)) 	;restore AC1G and AC1H
	POP dbl(mmap(@AC0G)) 	;restore AC1L and AC0G
	POP dbl(mmap(@AC0L)) 	;restore AC0H and AC0L
	POPBOTH XCDP 		;restore XCDP
	POPBOTH XAR1 		;restore XAR1
	POPBOTH XAR0 		;restore XAR0
	POP T0 			;restore T0
	POP mmap(@ST2_55) 		;restore ST2
	POP mmap(@BSAC) 		;restore BSAC
	POP mmap(@BKC) 			;restore BKC
	POP mmap(@RPTC) 		;restore RPTC
	RETI 				;return from interrupt
					;End of single每sample FIR mnemonic program
	
	
	