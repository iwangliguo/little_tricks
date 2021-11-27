
;Example 4 - 4. Biquad IIR Filter ASM Listing for the TMS320C54x DSP
	

	.sect ��iir��
iir_task:
	STM	  #K_FRAME_SIZE�C1, BRC 		; Perform filtering for xx samples
	RPTB iir_filter_loop�C1
	LD	  *INBUF_P+, 8, A 			; load the input value
iir_filter:
	STM   #d_iir_d+5, IIR_DATA_P 	;AR5 -> d(n),d(n�C1),d(n�C2)
	STM   #iir_coff_table, IIR_COFF_P 
							;AR4 -> coeff of IIR filter A2,A1,B2,B1,B0
	STM   #K_BIQUAD�C1, IIR_INDEX_P
feedback_path:
	MAC   *IIR_COFF_P+, *IIR_DATA_P�C,A ;input+d(n�C2)*A2
	MAC   *IIR_COFF_P, *IIR_DATA_P,A 	;input+d(n�C2)*A2+d(n�C1)*A1/2
	MAC   *IIR_COFF_P+, *IIR_DATA_P�C,A ; A = A+d(n�C1)*A1/2
	STH   A, *IIR_DATA_P+ 			;d(n) = input+d(n�C2)*A2+d(n�C1)*A1
	MAR   *IIR_DATA_P+
forward_path:
	MPY	  *IIR_COFF_P+,*IIR_DATA_P�C,A 	;d(n�C2)*B2
	MAC	  *IIR_COFF_P+,*IIR_DATA_P,A 	;d(n�C2)*B2+d(n�C1)*B1
	DELAY *IIR_DATA_P�C 					;d(n�C2)=d(n�C1)
eloop:
	BANZD feedback_path, *IIR_INDEX_P�C
	MAC	  *IIR_COFF_P+, *IIR_DATA_P,A 	;d(n�C2)*B2+d(n�C1)*B1+d(n)*B0
	DELAY *IIR_DATA_P�C 					;d(n�C1)=d(n)
	STH	  A, d_iir_y 				;output=d(n�C2)*B2+d(n�C1)*B1+d(n)*B0
	LD	  d_iir_y, 2, A 					; scale the output
	STL	  A, *OUTBUF_P+ 					; replace the oldest bffr value
iir_filter_loop
	.end


