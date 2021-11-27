
;Example 2 - 22. Creation of a Sine Wave ASM Listing Based on Oscillator Using TMS320C54x

;================================================================ 
; Copyright (C) 2004 YINXING TECHNOLOGY CO., LTD                     
; All Rights Reserved. 
;================================================================ 

     .mmregs
     .global _c_int00,_tint,vector 

OFF_INTIMER	.set		04Ch	
							; vector of INTtimer at VECTOR+OFF_INTIMER
INIT_A		.set		079BCh			; A/2=0.9510498
INIT_B		.set		0C000h			; B/2=-0.5
INIT_C 		.set		013C7h			; C/2=0.1545105

		.bss	y0, 1
		.bss	y1, 1
		.bss	y2, 1
		.bss	temp, 1
		.bss	AA, 1
		.bss	BB, 1
		.bss	CC, 1
          
		.text  
          
_c_int00:
		ld		#0,dp
		ssbx		intm 				; disable all interrupt !
		st		#1fffh,sp
		ld		#vector, a			; get vector table address !
		and		#0FF80h, a
		andm		#007Fh, pmst
		or		pmst, a
		stlm		a, pmst				; ÉèÖÃIPTR
		stm		#10h, TCR 			; init TIMER
		stm		#2499, PRD			; f=100M/(2499+1)=40kHz
		stm		#20h, TCR			; reset TIMER
		ldm		IMR, a				; read back IMR
		or		#08h, a 			; enable TIMER interrupt
		stlm		a, IMR				; set IMR     
		ld		#temp, dp			; set DP                
		ssbx		FRCT				; prepare for fraction mpy
		st		#INIT_A, AA			; init AA,BB,CC
		st		#INIT_B, BB			; 
		st		#INIT_C, CC			;
		pshd		CC
		popd		y2				; init y2,y2=CC
		ld		AA, T				; T=AA
		mpy		y2, a				; y2*AA -> a
		sth		a, y1				; y2*AA -> y1
		stm		#0h, TCR			; enable TIMER
		nop
		rsbx intm					; enable all int !
again:
     		nop
     		b    again    
        	nop
        	nop
        	nop
        	nop
        	nop
        	nop

; ================================================================
;  interrupt for INT_TIMER !
; ================================================================

_tint:
		ld		#BB, DP
		ld		BB, T				; T=BB
		mpy		y2, a				; a=y2*BB
		ltd		y1					; T=y1,y2=y1
		mac		AA, a				; a=a+y1*AA
		sth		a, 1, y1			; new cos data -> y1
		sth		a, 1, y0			; new cos data -> y0
		nop
		rete
	.end
