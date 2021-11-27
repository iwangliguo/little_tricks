
;Example 3 - 13. Complex Butterfly Unit ASM Listng for the TMS320C54x DSP

	.asg AR1,GROUP_COUNTER
	.asg AR2,PX
	.asg AR3,QX
	.asg AR4,WR
	.asg AR5,WI
	.asg AR6,BUTTERFLY_COUNTER
	.asg AR7,DATA_PROC_BUF ; for Stages 1 & 2
	.asg AR7,STAGE_COUNTER ; for the remaining stages

	.sect ��rfft_prg��
fft:
	; Stage 1
	;... ...
	; Stage 2
	;... ...
	; Stage 3 thru Stage logN�C1
	STM	#K_TWID_TBL_SIZE,BK 			; BK = twiddle table size
	ST 	#K_TWID_IDX_3,d_twid_idx 		; init index of twiddle table
	STM 	#K_TWID_IDX_3,AR0 			; AR0 = index of twiddle table
	STM 	#cosine,WR 				; init WR pointer
	STM 	#sine,WI 				; init WI pointer
	STM 	#K_LOGN�C2�C1,STAGE_COUNTER 		; init stage counter
	ST 	#K_FFT_SIZE/8�C1,d_grps_cnt		; init group counter
	STM 	#K_FLY_COUNT_3�C1,BUTTERFLY_COUNTER 
							; init butterfly counter
	ST 	#K_DATA_IDX_3,d_data_idx 		; init index for input data
stage:
	STM 	#fft_data,PX 				; PX �C> PR
	LD 	d_data_idx, A
	ADD 	*(PX),A
	STLM 	A,QX ; QX �C> QR
	MVDK 	d_grps_cnt,GROUP_COUNTER 		; AR1 contains group counter
group:
	MVMD 	BUTTERFLY_COUNTER,BRC 			; # of butterflies in each grp
	RPTBD 	butterflyend�C1
	LD 	*WR,T 					; T := WR
	MPY 	*QX+,A					; A := QR*WR || QX�C>QI
	MACR 	*WI+0%,*QX�C,A 				; A := QR*WR+QI*WI|| QX�C>QR
	ADD 	*PX,16,A,B 				; B := (QR*WR+QI*WI)+PR
	ST 	B,*PX 					; PR��:=((QR*WR+QI*WI)+PR)/2
	||	SUB 	*PX+,B 				; B := PR�C(QR*WR+QI*WI)|| PX�C>PI
	ST 	B,*QX 					; QR��:= (PR�C(QR*WR+QI*WI))/2
	||	MPY 	*QX+,A 				; A := QR*WI [T=WI]|| QX�C>QI
	MASR 	*QX,*WR+0%,A 				; A := QR*WI�CQI*WR
	ADD 	*PX,16,A,B 				; B := (QR*WI�CQI*WR)+PI
	ST 	B,*QX+ 					; QI��:=((QR*WI�CQI*WR)+PI)/2 || QX�C>QR
	||	SUB *PX,B 				; B := PI�C(QR*WI�CQI*WR)
	LD 	*WR,T 					; T := WR
	ST 	B,*PX+ 					; PI��:= (PI�C(QR*WI�CQI*WR))/2 || PX�C>PR
	||	MPY 	*QX+,A 				; A := QR*WR || QX�C>QI
butterflyend:
						; Update pointers for next group
	PSHM 	AR0 ; preserve AR0
	MVDK 	d_data_idx,AR0
	MAR 	*PX+0 				; increment PX for next group
	MAR 	*QX+0 				; increment QX for next group
	BANZD 	group,*GROUP_COUNTER�C
	POPM 	AR0 				; restore AR0
	MAR 	*QX�C
						; Update counters and indices for next stage
	LD	d_data_idx,A
	SUB 	#1,A,B 				; B = A�C1
	STLM 	B,BUTTERFLY_COUNTER 		; BUTTERFLY_COUNTER = #flies�C1
	STL 	A,1,d_data_idx 			; double the index of data
	LD 	d_grps_cnt,A
	STL 	A,ASM,d_grps_cnt 		; 1/2 the offset to next group
	LD 	d_twid_idx,A
	STL 	A,ASM,d_twid_idx 		; 1/2 the index of twiddle table
	BANZ 	D stage,*STAGE_COUNTER�C
	MVDK 	d_twid_idx,AR0 			; AR0 = index of twiddle table
fft_end:
	RET
	
	