
; Example 5 - 4. Symmetric FIR Implementation Using FIRS Instruction for the TMS320C54x DSP

; TEXAS INSTRUMENTS INCORPORATED
	.mmregs
	.include ��main.inc��

FIR_COFF 
	.sect ��sym_fir�� ; filter coefficients
	.word 6Fh
	.word 0F3h
	.word 269h
	.word 50Dh
	.word 8A9h
	.word 0C99h
	.word 0FF8h
	.word 11EBh

d_datax_buffer 
	.usect ��cir_bfr��,20
d_datay_buffer 
	.usect ��cir_bfr1��,20

	.def sym_fir_init ; initialize symmetric FIR
	.def sym_fir_task


;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
; Functional Description
; This routine initializes circular buffers both for data and coeffs.
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C

	.asg AR0,SYMFIR_INDEX_P
	.asg AR4,SYMFIR_DATX_P
	.asg AR5,SYMFIR_DATY_P

	.sect ��sym_fir��

sym_fir_init:
	STM #d_datax_buffer,SYMFIR_DATX_P 	; load cir_bfr address
						; for the 8 most
						; recent samples STM #d_datay_buffer+K_FIR_BFFR/2�C1,SYMFIR_DATY_P
						; load cir_bfr1 address
						; for the 8 old samples
	STM #K_neg1,SYMFIR_INDEX_P 		; index offset �C
						; whenever the pointer
						; hits the top of the bffr,
						; it automatically hits
						; bottom address of
						; buffer and decrements
						; the counter
	RPTZ A,#K_FIR_BFFR
	STL A,* SYMFIR_DATX_P+
	STM #d_datax_buffer, SYMFIR_DATX_P
	RPTZ A,#K_FIR_BFFR
	STL A,* SYMFIR_DATY_P�C
	RETD
	STM #d_datay_buffer+K_FIR_BFFR/2�C1, SYMFIR_DATY_P


;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
; Functional Description
;This program uses the FIRS instruction to implement symmetric FIR filter
;Circular addressing is used for data buffers. The input scheme for the data;
;samples is divided into two circular buffers. The first buffer contains
;samples from X(�CN/2) to X(�C1) and the second buffer contains samples from
;X(�CN) to X(�CN/2�C1).
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	.asg AR6,INBUF_P
	.asg AR7,OUTBUF_P
	.asg AR4,SYMFIR_DATX_P
	.asg AR5,SYMFIR_DATY_P

	.sect ��sym_fir��
sym_fir_task:
	STM #K_FRAME_SIZE�C1,BRC
	RPTBD sym_fir_filter_loop�C1
	STM #K_FIR_BFFR/2,BK
	LD *INBUF_P+, B
symmetric_fir:
	MVDD *SYMFIR_DATX_P,*SYMFIR_DATY_P+0% 		; move X(�CN/2) to X(�CN)
	STL B,*SYMFIR_DATX_P 				; replace oldest sample with newest
							; sample
	ADD *SYMFIR_DATX_P+0%,*SYMFIR_DATY_P+0%,A 	; add X(0)+X(�CN/2�C1)
	RPTZ B,#(K_FIR_BFFR/2�C1)
	FIRS *SYMFIR_DATX_P+0%,*SYMFIR_DATY_P+0%,FIR_COFF
	MAR *+SYMFIR_DATX_P(2)% 			; to load the next newest sample
	MAR *SYMFIR_DATY_P+% 				; position for the X(�CN/2) sample
	STH B, *OUTBUF_P+
sym_fir_filter_loop
	
	RET
	.end
