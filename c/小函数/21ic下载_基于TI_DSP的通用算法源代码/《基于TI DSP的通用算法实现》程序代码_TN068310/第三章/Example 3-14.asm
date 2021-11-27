
;Example 3 - 14. Data Unpacking ASM Listng for the TMS320C54x DSP

	.sect ��rfft_prg��
unpack:
							; Compute intermediate values RP, RM, IP, IM
	.asg AR2,XP_k
	.asg AR3,XP_Nminusk
	.asg AR6,XM_k
	.asg AR7,XM_Nminusk

	STM #fft_data+2,XP_k 				; AR2 �C> R[k] (temp RP[k])
	STM #fft_data+2*K_FFT_SIZE�C2,XP_Nminusk 
							;AR3�C>R[N�Ck](temp RP[N�Ck])
	STM #fft_data+2*K_FFT_SIZE+3,XM_Nminusk		; AR7 �C> temp RM[N�Ck]
	STM #fft_data+4*K_FFT_SIZE�C1,XM_k 		; AR6 �C> temp RM[k]
	STM #�C2+K_FFT_SIZE/2,BRC
	RPTBD phase3end�C1
	STM #3,AR0
	ADD *XP_k,*XP_Nminusk,A 				; A := R[k]+R[N�Ck] = 2*RP[k]
	SUB *XP_k,*XP_Nminusk,B 				; B := R[k]�CR[N�Ck] = 2*RM[k]
	STH A,ASM,*XP_k+ 					; store RP[k] at AR[k]
	STH A,ASM,*XP_Nminusk+ 				   	; store RP[N�Ck]=RP[k] at AR[N�Ck]
	STH B,ASM,*XM_k�C 					; store RM[k] at AI[2N�Ck]
	NEG B 							; B := R[N�Ck]�CR[k] = 2*RM[N�Ck]
	STH B,ASM,*XM_Nminusk�C 				; store RM[N�Ck] at AI[N+k]
	ADD *XP_k,*XP_Nminusk,A 				; A := I[k]+I[N�Ck] = 2*IP[k]
	SUB *XP_k,*XP_Nminusk,B 				; B := I[k]�CI[N�Ck] = 2*IM[k]
	STH A,ASM,*XP_k+ 					; store IP[k] at AI[k]
	STH A,ASM,*XP_Nminusk�C0 				; store IP[N�Ck]=IP[k] at AI[N�Ck]
	STH B,ASM,*XM_k�C 					; store IM[k] at AR[2N�Ck]
	NEG B 							; B := I[N�Ck]�CI[k] = 2*IM[N�Ck]
	STH B,ASM,*XM_Nminusk+0 				; store IM[N�Ck] at AR[N+k]
phase3end:

	ST #0,*XM_k�C ; RM[N/2]=0
	ST #0,*XM_k ; IM[N/2]=0
								; Compute AR[0],AI[0], AR[N], AI[N]
	.asg AR2,AX_k
	.asg AR4,IP_0
	.asg AR5,AX_N

	STM #fft_data,AX_k 					; AR2 �C> AR[0] (temp RP[0])
	STM #fft_data+1,IP_0 					; AR4 �C> AI[0] (tempIP[0])
	STM #fft_data+2*K_FFT_SIZE+1,AX_N 			; AR5 �C> AI[N]
	ADD *AX_k,*IP_0,A 					; A := RP[0]+IP[0]
	SUB *AX_k,*IP_0,B 					; B := RP[0]�CIP[0]
	STH A,ASM,*AX_k+ 					; AR[0] = (RP[0]+IP[0])/2
	ST #0,*AX_k 						; AI[0] = 0
	MVDD *AX_k+,*AX_N�C 					; AI[N] = 0
	STH B,ASM,*AX_N 					; AR[N] = (RP[0]�CIP[0])/2
								; Compute final output values AR[k], AI[k]
	.asg AR3,AX_2Nminusk
	.asg AR4,COS
	.asg AR5,SIN

	STM #fft_data+4*K_FFT_SIZE�C1,AX_2Nminusk 
								; AR3 �C> AI[2N�C1](temp RM[1])
	STM #cosine+K_TWID_TBL_SIZE/K_FFT_SIZE,COS		; AR4 �C> cos(k*pi/N)
	STM #sine+K_TWID_TBL_SIZE/K_FFT_SIZE,SIN		; AR5 �C> sin(k*pi/N)
	STM #K_FFT_SIZE�C2,BRC
	RPTBD phase4end�C1
	STM #K_TWID_TBL_SIZE/K_FFT_SIZE,AR0			; index of twiddle tables
	LD *AX_k+,16,A 						; A := RP[k] ||	AR2�C>IP[k]
	MACR *COS,*AX_k,A 					; A :=A+cos(k*pi/N)*IP[k]
	MASR *SIN,*AX_2Nminusk�C,A 				; A := A�Csin(k*pi/N)*RM[k]
								; || AR3�C>IM[k]
	LD *AX_2Nminusk+,16,B 					; B := IM[k] ||	AR3�C>RM[k]
	MASR *SIN+0%,*AX_k�C,B 					; B := B�Csin(k*pi/N)*IP[k]
								; || AR2�C>RP[k]
	MASR *COS+0%,*AX_2Nminusk,B 				; B := B�Ccos(k*pi/N)*RM[k]
	STH A,ASM,*AX_k+ 					; AR[k] = A/2
	STH B,ASM,*AX_k+ 					; AI[k] = B/2
	NEG B 							; B := �CB
	STH B,ASM,*AX_2Nminusk�C 				; AI[2N�Ck] = �CAI[k]= B/2
	STH A,ASM,*AX_2Nminusk�C 				; AR[2N�Ck] = AR[k] = A/2
phase4end:

	RET 
							; returntoRealFFTmain module
	.end

