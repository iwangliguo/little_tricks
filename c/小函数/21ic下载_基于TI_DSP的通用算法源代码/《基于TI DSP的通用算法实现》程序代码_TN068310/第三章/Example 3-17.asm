
;Example 3 - 17. Scaling for BFP Based FFT Implementation ASM Listing for TMS320C55x

;****************************************************************
; scale_exp:   Find maximum absolute value in array specified by 
; 		   	   address AR3 and length T0. Pre-scale the input to next
;			   radix-2 stage by 2^(exponent of the maximum absolute 
;			   value - 1) for first two stages and by 2^(exponent of 
;			   the maximum absolute value - 2) for all following stages
;****************************************************************
scale_exp:
	PSH dbl(AC0)		; save registers to be modified(stack size += 12)
	PSH dbl(AC1)
	PSH dbl(AC2)
	PSH dbl(AC3)
	PSH AR3
	PSH T0
	PSH T1

; --------find maximum absolute value (real and imaginary)-------
	MOV *sp(data_ptr + 12), AR3	; load array size into AR3 (sp 
					; offset computed from 
	MOV *sp(data_sz + 12), T0	; above pushed registers and the 
					; return address
	SUB #2, T0
|| 	MOV dbl(*AR3+), AC0				; AC0_H = x_Re[0],  AC0_L = x_Im[1]

	MOV T0, BRC0					; BRC0 = NX - 2
|| 	MOV dbl(*AR3), AC1 				; AC1_H = x_Re[2],  AC1_L = x_Im[3]

	MOV dbl(*AR3+), AC2				; AC2_H = x_Re[2],  AC1_L = x_Im[3]
|| 	RPTBLOCAL find_max  
	
	MAXDIFF AC0, AC1, AC1, AC3			; AC1_H/L contain max's

find_max: 
	MOV dbl(*AR3+), AC0				; AC0_H = x_Re[n], AC0_L = x_Imn+1]
|| 	MINDIFF AC0, AC2, AC2, AC3			; AC2_H/L contain min's
	
	MOV HI(AC1), AR3					; AR3 = even max value
	MOV AC1, T0						; T0  = odd  max value	   		
	MAX AR3, T0					
	MOV HI(AC2), T1						; T1  = odd  min value
	MOV AC2, AR3						; AR3 = even min value
	MIN AR3, T1
	ABS T1
	MAX T0, T1
	MOV T1, HI(AC0)					; put maximum absolute value in high part of AC0
	

; -------scale array according to maximum asbolute value---------
	EXP AC0, T1					; determine exponent from maximum absolute value
	MOV *sp(bit_buf + 12), AR3			; AR3 contains expected bit growth
	SUB AR3, T1					; subtract 1 or 2 from the exponent to compensate 
							; for the maximum possible bit growth (factor of 
							; 2 or 4) in the next radix-2 stage	
	BCC no_scale, T1 == #0				; branch if no scaling needed
	ADD *sp(ret_exp + 12), T1, AC0	;		 sum current with previous exp.
	MOV *sp(data_sz + 12), T0   			; put nx in T0 for next loop
	MOV AC0, *sp(ret_exp + 12)			; put exponent back on stack
|| 	SUB #1, T0		

	MOV *sp(data_ptr + 12), AR3
|| 	MOV T0, BRC0					; initialize loop counter (BRC0 = nx - 1)
						
	RPTBLOCAL scale	 
	MOV dbl(*AR3), pair(LO(AC0))			
	MOV AC0<<T1, *AR3+				; scale by 2^(exp. of the max absolute val-2)

scale: 
	MOV AC1<<T1, *AR3+		
no_scale:	
	POP T1				; restore registers
	POP T0
	POP AR3
	POP dbl(AC3)
	POP dbl(AC2)
	POP dbl(AC1)
	POP dbl(AC0)

	RET	
