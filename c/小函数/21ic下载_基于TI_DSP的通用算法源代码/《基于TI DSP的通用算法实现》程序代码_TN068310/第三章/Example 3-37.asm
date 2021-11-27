
; Example 3 - 37. Complex Bit Reversion ASM Listing for the TMS320C3x DSP


£»DO THE BIT-REVERSING EXPLICITLY
		LDI		@FFTSIZ£¬RC	;    RC=FFT SIZE
		SUBI	1£¬RC       	;    RC SHOULD BE ONE LESS THAN DESIRED
		LDI		@FFTSIZ£¬IR0	;  	 IR0=FFT SIZE
		LDI		@INPUT£¬AR0
		LDI  	@INPUT£¬AR1
		RPTB 	BITBV
		CMPI 	AR1£¬AR0  		;    EXCHANGE LOCATION ONLY
		BGE  	C0NT       		;    IF AROAR1
		LDF  	*AR0£¬R0  		;
||		LDF   	*AR1£¬R1   	;    EXCHANGE REAL PARTS
		STF 	R0£¬*AR1   	;
||		STF  	R1£¬*AR0   	;
		LDF  	*+AR0£¬R0 		;
||		LDF  	*+AR1£¬R1 		;    EXCHANGE IMAGINARY PARTS
		STF  	R0£¬*+AR1 		;
||		STF 	R1£¬*+AR0 		;
		CONT	NOP   	*AR0++[2]
		BITRV	NOP  	*AR1++[IR0]B

