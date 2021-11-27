
; Example 3 - 38. Butterfly Unit of Radix-2 FFT ASM Listing for the TMS320C3x DSP

; Butterfly unit for radix-2 FFT
		RPTB	BLK2
		SUBF	*AR2, *AR0, R2		; R2 = X(I)иCX(L)
		SUBF	*+AR2, *+AR0, R1		; R1 = Y(I)иCY(L)
		MPYF	R2, R6, R0			; R0 = R2*SIN and бн
||		ADDF	*+AR2, *+AR0, R3		; 		R3 = Y(I)+Y(L)
		MPYF	R1, *+AR4(IR1), R3	; R3 = R1*COS and бн
||		STF		R3, *+AR0				; 		Y(I) = Y(I)+Y(l)
		SUBF	R0, R3, R4			; R4 = R1*COS-R2*SIN
		MPYF	R1, R6, R0			; R0 = R1*SIN and бн
||		ADDF	*AR2, *AR0, R3		;		R3 = X(I)*X(l)
		MPYF	R2, *+AR4(IR1), R3	; R3 = R2*COS and бн
||		STF		R3, *AR0++(IR0)		; X(I) = X(I)*X(L) and AR0 = AR0+IR0
		ADDF	R0, R3, R5			; R5 = R2*COS+R1*SIN
BLK2	STF		R5, *AR2++(IR0)		; X(L)= R2*COS+F1*SIN, INCR AR2 and
||		STF		R4, *+AR2				;		Y(L) = R1*COS-R2*SIN
    
