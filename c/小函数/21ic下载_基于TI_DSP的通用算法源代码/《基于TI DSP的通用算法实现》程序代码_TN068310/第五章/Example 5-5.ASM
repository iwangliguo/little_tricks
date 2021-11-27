
; Example 5 - 5. BLK FIR Filter ASM Listing for the TMS320C55x DSP


******************************************************************************
* FILE: BFIR_MNE.ASM *
* DESCRIPTION: Mnemonic C55xx DSP program for block FIR filter. *
* AUTHOR: David M. Alter, Texas Instruments, Inc. *
* DATE: February 24, 2000 *
* RESTRICTIONS: *
* (1) N_SAMP每N_TAP+1 (the number of output values) must be even. *
* (2) Overflow is not checked. *
* (3) Data and coefficients are assumed to be signed Q15 fractions. *
* (4) The section §output_data§ must be 32每bit aligned in memory. *
******************************************************************************


	.def blockfir, rset
	
N_SAMP 	.set 199 	;# of input samples
N_TAP 	.set 16 	;# of filter taps
Q15 	.set 32768 	;Q15 fraction scale value

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

x 	.copy dualsine.dat 	;label at oldest input
				;Output array in Q15 fractional format
y 	.usect §output_data§, N_SAMP每N_TAP+1, ,1
				;label at oldest output


;********** INTERRUPT VECTORS **********
;This is an incomplete vector table for illustration purposes only
	
	.sect §vectors§
rset: 
	.ivec blockfir, USE_RETA 	;reset vector and stack mode
nmi: 
	.ivec nmi 			;trap spurious NMI＊s
int2: 	.ivec int2 			;trap spurious int2＊s


;********** FILTER INITIALIZATION **********

	.text

blockfir:

;Configure ST1: set SXMD, FRCT
	OR #0000000101000000b, mmap(@ST1_55)

;Configure ST1: clear SATD, C54CM
	AND #1111110111011111b, mmap(ST1_55)

.c54cm_off
;Configure ST2: clear ARMS. AR1, AR2, and CDP set to linear mode
	AND #0111111011111001b, mmap(ST2_55)

	.arms_off
;Pointer setup
	AMOV #a0, XCDP 					;pointer to coefficient array
	AMOV #(x + N_TAP 每 1), XAR0 			;pointer to input vector
	AMOV #(x + N_TAP), XAR1 			;2nd pointer to input vector
	AMOV #y, XAR2 					;pointer to output array

;Other setup
	MOV #((N_SAMP 每 N_TAP + 1)/2 每 1), BRC0 	;init local repeat counter
	MOV #(每(N_TAP 每 1)), T0 			;CDP rewind increment
	MOV #(N_TAP + 1), T1 				;ARx rewind increment

;********** FILTER KERNEL **********
	||RPTBLOCAL end_outer 				;start the outer loop
							;First tap is multiply only (no accumulate)
	MPY *AR0每, *CDP+, AC0
	::MPY *AR1每, *CDP+, AC1
							;Taps 2 through (N_TAPS 每 1)
	||RPT #(N_TAP每3) 				;single repeat for inner loop
	MAC *AR0每, *CDP+, AC0
	::MAC *AR1每, *CDP+, AC1
							;Last tap has different pointer increments
	MAC *(AR0+T1), *(CDP+T0), AC0
	::MAC *(AR1+T1), *(CDP+T0), AC1
end_outer:
	MOV pair(HI(AC0)), dbl(*AR2+) 			;write both results
							;end of outer loop
;********** PROGRAM TERMINATION **********
end: 	
	B end 						;trap end of program
							;End of block FIR mnemonic program
	