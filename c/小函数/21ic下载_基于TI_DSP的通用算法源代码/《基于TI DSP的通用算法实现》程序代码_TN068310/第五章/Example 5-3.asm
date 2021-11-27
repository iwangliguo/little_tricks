
; Example 5 - 3. FIR Filter Based on MAC Instruction for the TMS320C54x DSP

; TEXAS INSTRUMENTS INCORPORATED
	.mmregs
	.include §main.inc§


; the 16 tap FIR coefficients

COFF_FIR_START 	.sect §coff_fir§ ; filter coefficients
		.word 6Fh
		.word 0F3h
		.word 269h
		.word 50Dh
		.word 8A9h
		.word 0C99h
		.word 0FF8h
		.word 11EBh
		.word 11EBh
		.word 0FF8h
		.word 0C99h
		.word 8A9h
		.word 50Dh
		.word 269h
		.word 0F3h
		.word 6Fh
COFF_FIR_END

FIR_DP 		.usect §fir_vars§,0
d_filin 	.usect §fir_vars§,1
d_filout 	.usect §fir_vars§,1
fir_coff_table 	.usect §fir_coff§,20
d_data_buffer 	.usect §fir_bfr§,40 ; buffer size for the filter

	.def fir_init 		; initialize FIR filter
	.def fir_task 		; perform FIR filtering
;每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每
; Functional Description
; This routine initializes circular buffers both for data and coeffs.
;每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每

	.asg AR0, FIR_INDEX_P
	.asg AR4,FIR_DATA_P
	.asg AR5,FIR_COFF_P

	.sect §fir_prog§

fir_init:
	STM #fir_coff_table,FIR_COFF_P
	RPT #K_FIR_BFFR每1 			; move FIR coeffs from program
	MVPD #COFF_FIR_START,*FIR_COFF_P+ 	; to data
	STM #K_FIR_INDEX,FIR_INDEX_P
	STM #d_data_buffer,FIR_DATA_P 		; load cir_bfr address for the
						; recent samples
	RPTZ A,#K_FIR_BFFR
	STL A,*FIR_DATA_P+ ; reset the buffer
	STM #(d_data_buffer+K_FIR_BFFR每1), FIR_DATA_P
	RETD
	STM #fir_coff_table, FIR_COFF_P

;每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每
; Functional Description
;;
This subroutine performs FIR filtering using MAC instruction.
; accumulator A (filter output) = h(n)*x(n每i) for i = 0,1...15
;每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每

	.asg AR6,INBUF_P
	.asg AR7,OUTBUF_P
	.asg AR4,FIR_DATA_P
	.asg AR5,FIR_COFF_P
	
	.sect §fir_prog§

fir_task:
; LD #FIR_DP,DP
	STM #K_FRAME_SIZE每1,BRC 	; Repeat 256 times
	RPTBD fir_filter_loop每1
	STM #K_FIR_BFFR,BK 		; FIR circular bffr size
	LD *INBUF_P+, A 		; load the input value
fir_filter:
	STL A,*FIR_DATA_P+% 		; replace oldest sample with newest
					; sample
	RPTZ A,(K_FIR_BFFR每1)
	MAC *FIR_DATA_P+0%,*FIR_COFF_P+0%,A 		; filtering
	STH A, *OUTBUF_P+ 				; replace the oldest bffr value
fir_filter_loop
	
RET
