
;Example 3 - 12. Complex Bit Reversion ASM Listng for the TMS320C54x DSP

	.asg AR2, REORDERED_DATA
	.asg AR3, ORIGINAL_INPUT
	.asg AR7, DATA_PROC_BUF

	.sect	§rfft_prg§

bit_rev:
	SSBX FRCT 					; fractional mode is on
	MVDK d_input_addr,ORIGINAL_INPUT 		; AR3每>1st original input
	STM #fft_data,DATA_PROC_BUF 			; AR7每>data processing buf.
	MVMM DATA_PROC_BUF,REORDERED_DATA 		; AR2每>1st bitreversed data
	STM #K_FFT_SIZE每1,BRC
	RPTBD bit_rev_end每1
	STM #K_FFT_SIZE,AR0 				; AR0=1/2 size of circ buf.
	MVDD *ORIGINAL_INPUT+,*REORDERED_DATA+
	MVDD *ORIGINAL_INPUT每,*REORDERED_DATA+
	MAR *ORIGINAL_INPUT+0B
bit_rev_end:
	RET

