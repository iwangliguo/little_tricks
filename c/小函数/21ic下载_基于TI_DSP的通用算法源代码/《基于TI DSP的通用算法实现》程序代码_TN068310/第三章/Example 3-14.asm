
;Example 3 - 14. Data Unpacking ASM Listng for the TMS320C54x DSP

	.sect §rfft_prg§
unpack:
							; Compute intermediate values RP, RM, IP, IM
	.asg AR2,XP_k
	.asg AR3,XP_Nminusk
	.asg AR6,XM_k
	.asg AR7,XM_Nminusk

	STM #fft_data+2,XP_k 				; AR2 每> R[k] (temp RP[k])
	STM #fft_data+2*K_FFT_SIZE每2,XP_Nminusk 
							;AR3每>R[N每k](temp RP[N每k])
	STM #fft_data+2*K_FFT_SIZE+3,XM_Nminusk		; AR7 每> temp RM[N每k]
	STM #fft_data+4*K_FFT_SIZE每1,XM_k 		; AR6 每> temp RM[k]
	STM #每2+K_FFT_SIZE/2,BRC
	RPTBD phase3end每1
	STM #3,AR0
	ADD *XP_k,*XP_Nminusk,A 				; A := R[k]+R[N每k] = 2*RP[k]
	SUB *XP_k,*XP_Nminusk,B 				; B := R[k]每R[N每k] = 2*RM[k]
	STH A,ASM,*XP_k+ 					; store RP[k] at AR[k]
	STH A,ASM,*XP_Nminusk+ 				   	; store RP[N每k]=RP[k] at AR[N每k]
	STH B,ASM,*XM_k每 					; store RM[k] at AI[2N每k]
	NEG B 							; B := R[N每k]每R[k] = 2*RM[N每k]
	STH B,ASM,*XM_Nminusk每 				; store RM[N每k] at AI[N+k]
	ADD *XP_k,*XP_Nminusk,A 				; A := I[k]+I[N每k] = 2*IP[k]
	SUB *XP_k,*XP_Nminusk,B 				; B := I[k]每I[N每k] = 2*IM[k]
	STH A,ASM,*XP_k+ 					; store IP[k] at AI[k]
	STH A,ASM,*XP_Nminusk每0 				; store IP[N每k]=IP[k] at AI[N每k]
	STH B,ASM,*XM_k每 					; store IM[k] at AR[2N每k]
	NEG B 							; B := I[N每k]每I[k] = 2*IM[N每k]
	STH B,ASM,*XM_Nminusk+0 				; store IM[N每k] at AR[N+k]
phase3end:

	ST #0,*XM_k每 ; RM[N/2]=0
	ST #0,*XM_k ; IM[N/2]=0
								; Compute AR[0],AI[0], AR[N], AI[N]
	.asg AR2,AX_k
	.asg AR4,IP_0
	.asg AR5,AX_N

	STM #fft_data,AX_k 					; AR2 每> AR[0] (temp RP[0])
	STM #fft_data+1,IP_0 					; AR4 每> AI[0] (tempIP[0])
	STM #fft_data+2*K_FFT_SIZE+1,AX_N 			; AR5 每> AI[N]
	ADD *AX_k,*IP_0,A 					; A := RP[0]+IP[0]
	SUB *AX_k,*IP_0,B 					; B := RP[0]每IP[0]
	STH A,ASM,*AX_k+ 					; AR[0] = (RP[0]+IP[0])/2
	ST #0,*AX_k 						; AI[0] = 0
	MVDD *AX_k+,*AX_N每 					; AI[N] = 0
	STH B,ASM,*AX_N 					; AR[N] = (RP[0]每IP[0])/2
								; Compute final output values AR[k], AI[k]
	.asg AR3,AX_2Nminusk
	.asg AR4,COS
	.asg AR5,SIN

	STM #fft_data+4*K_FFT_SIZE每1,AX_2Nminusk 
								; AR3 每> AI[2N每1](temp RM[1])
	STM #cosine+K_TWID_TBL_SIZE/K_FFT_SIZE,COS		; AR4 每> cos(k*pi/N)
	STM #sine+K_TWID_TBL_SIZE/K_FFT_SIZE,SIN		; AR5 每> sin(k*pi/N)
	STM #K_FFT_SIZE每2,BRC
	RPTBD phase4end每1
	STM #K_TWID_TBL_SIZE/K_FFT_SIZE,AR0			; index of twiddle tables
	LD *AX_k+,16,A 						; A := RP[k] ||	AR2每>IP[k]
	MACR *COS,*AX_k,A 					; A :=A+cos(k*pi/N)*IP[k]
	MASR *SIN,*AX_2Nminusk每,A 				; A := A每sin(k*pi/N)*RM[k]
								; || AR3每>IM[k]
	LD *AX_2Nminusk+,16,B 					; B := IM[k] ||	AR3每>RM[k]
	MASR *SIN+0%,*AX_k每,B 					; B := B每sin(k*pi/N)*IP[k]
								; || AR2每>RP[k]
	MASR *COS+0%,*AX_2Nminusk,B 				; B := B每cos(k*pi/N)*RM[k]
	STH A,ASM,*AX_k+ 					; AR[k] = A/2
	STH B,ASM,*AX_k+ 					; AI[k] = B/2
	NEG B 							; B := 每B
	STH B,ASM,*AX_2Nminusk每 				; AI[2N每k] = 每AI[k]= B/2
	STH A,ASM,*AX_2Nminusk每 				; AR[2N每k] = AR[k] = A/2
phase4end:

	RET 
							; returntoRealFFTmain module
	.end

