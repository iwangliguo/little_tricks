
; Example 5 - 11. FIR Filter Implementation ASM Listing for the TMS320C3x DSP

	LDI	@ADDXN, AR1				; AR1points to x[n-L+1]
	LDI	@ADDBI, AR0				; AR0 points to b[L-1]
	LDI	L, BK						; circular buffer size=L
	LDI	L-2	, RC					; L-2¡úrepeat counter
	LDF	@XN	, R2					; x[n]¡úR2
	STF	R2, AR1++(1)%				; store x[n] in buffer and
									; update pointer AR1
	STL	AR1, @ADDXN				; save new address of x[n-L+1]
	CALL	FIR_filter				; call FIR_filter routine to compute y[n]

FIR_filter£º
	MPYF3	*AR0++(1)%, *AR1++(1)%, R1		; b[0]*x[0]
	NOP
	LDF	0.0, R2
	RPTS	RC					; repeat next parallel instructions L-1 times
	MOY3	*AR0++(1)%, *AR1++(1)%, R1		; b[i]*x[n-i]
||	ADDF3	R1, R2, R2					; sum of products b[i]*x[n-i]
	ADDF3	R1, R2, R2					; sum the last product
	RETS
