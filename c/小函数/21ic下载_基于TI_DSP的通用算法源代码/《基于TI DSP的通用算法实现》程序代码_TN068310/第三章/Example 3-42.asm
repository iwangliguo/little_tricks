
; Example 3 - 42. Butterfly Unit of FHT ASM Listing for the TMS320C3x DSP

		LDI		@FHTSIZ, IR1
		LSH		-2, IR1			; IR1 = SEPARATION BETWEEN SIN/COS TBLS
		LDI		R4, RC
		SUBI	2, RC				; REPEAT RC-1 TIMES
	
		RPTB	BLK
		MPYF	*AR3, *+AR0(IR1), R0	; R0 = X(L3)*COS
		MPYF	*AR4, *AR0, R1			; R1 = X(L4)*SIN
		MPYF	*AR4, *+AR0(IR1), R1	; R1 = X(L4)*COS
||		ADDF	R0, R1, R2				; R2 = X(L3)*COS+X(L4)*SIN = T1
		MPYF	*AR3, *AR0++(IR0), R0	; R0 = X(L3)*SIN
		SUBF	R1, R0, R0				; R0 = X(L3)*SIN-X(L4)*COS = T2
		SUBF	R0, *AR2, R1				; R1 = X(L2)¨CT2
		ADDF	#AR2, R0, R1				; R1 = x(L2)+T2
||		STF		R1, *AR4--				; X(L4) = X(L2)-T2
		ADDF	#AR1, R2, R1				; R1 = X(L1)+T1
||		STF		R1, *AR2--				; X(L2) = X(L2)+T2
		SUBF	R2, *AR1, R1				; R1 = X(L1)-T1
||		STF		R1, *AR1++				; X(L1) = X(L1)+T1
BLK		STF		R1, *AR3++				; X(L3) = X(L1)-T1

