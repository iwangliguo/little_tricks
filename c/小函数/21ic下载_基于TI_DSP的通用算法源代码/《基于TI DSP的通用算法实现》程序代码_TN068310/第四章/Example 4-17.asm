
; Example 4 - 17. Biquad IIR Filter ASM Listing Functions for the TMS320C3x DSP

	.global	IIR
IIR1	
	MPYF3		*AR0, *AR1, R0				; ak2*dk[n-2] -> R0
	MPYF3		*++AR0(1), *AR1-(1)%, R1		; bk2*dk[n-2] -> R1
	MPYF3		*++AR0(1), *AR1, R0			; ak1*dk[n-1] -> R0
||	ADDF3		R0, R2, R2					; ak2*dk[n-2]+x[n] -> R2
	MPYF3		*++AR0(1), *AR1-(1)%, R0   	; abk2*dk[n-1] -> R0
||	ADDF3		R0, R2, R2			; ak1*dk[n-1]+ak2*dk[n-2]+x[n] ->R2
	MPYF3		*++AR0(1), R2, R2     		; bk2*dk[n] -> R2
||	STF		R2, *AR1++(1)%				; 储存dk[n]并指向dk[n-1]
	ADDF		R0, R2				; bk1*dk[n-1]+bk0*dk[n] -> R2
	ADDF		R1, R2, R0			; bk2*dk[n-2]+bk1*dk[n-1] +bk0*dk[n] ->R0
	RETS						; 返回
	.end

