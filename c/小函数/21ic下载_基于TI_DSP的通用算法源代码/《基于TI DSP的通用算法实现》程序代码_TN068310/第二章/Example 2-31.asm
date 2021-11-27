
;Example 2 - 31. Float-Point Division ASM Listing for TMS320C54x	

;/* ============================================================================*/ 
;/*          Copyright (C) 2004 YINXING TECHNOLOGY CO., LTD                     */ 
;/*                          All Rights Reserved.                               */ 
;/* ----------------------------------------------------------------------------*/ 
;/* ============================================================================*/ 



;---------------------------------------------------------------
;
;    USER Program Demo !
;    It Start At 0x1800,and interrupt vector don't changed,
;    At 200h !
;
;    Please Don't modify PMST !
;
;    Some data put in 0c00h  DP=24 and 0d00h DP=26 
;    SP may use system stack,so user needn't setup SP !       
;
;------------------------------------------------------------------


	.title  "for test user program ... "
	.mmregs
	.global mainstart,errno
	.def	fd_start

op7valh	.set 4140h	;floating point number 12.0
op7vall	.set 0000h
op8valh	.set 4080h	;floating point number 4.0
op8vall	.set 0000h
initst0	.set 1800h	;set st0 initial number
initst1	.set 2900h	;set st1 initial number

	.bss rlthm,1	;result high mantissa
	.bss rltlm,1	;result low mantissa
	.bss rltsign,1	;ressult sigh
	.bss rltexp,1	;result exponent
	.bss op7hm,1	;op7 high mantissa
	.bss op7lm,1	;op7 low mantissa
	.bss op7se,1	;op7 sigh and exp
	.bss op8se,1	;op8 sigh and exponent
	.bss op8hm,1	;op8 high mantissa
	.bss op8lm,1	;op8 low mantissa
	.bss op7_hsw,1	;op7 packed high
	.bss op7_lsw,1	;op7 packed low
	.bss op8_hsw,1	;op8 packed high
	.bss op8_lsw,1	;op8 packed low
	.bss errno,2	;
    
fd_start:
	stm	#initst0,st0
	stm	#initst1,st1
	rsbx	C16;
	ld	#op7lm,dp
	ld	#op7valh,a	;load float number
	stl	a,op7_hsw
	ld	#op7vall,a
	stl	a,op7_lsw
	ld	#op8valh,a	;load float number
	stl	a,op8_hsw
	ld	#op8vall,a
	stl	a,op8_lsw

;----------- conversion of floating point format - unpack  -------

	dld	op7_hsw,a	;load op7 to acc a
	sfta	a,8
	sfta	a,-8
	bc	op7_zero,AEQ	;if op7 is 0,jump to special case
	sth	a,-7,op7se	;store sign and exponent to stack
	stl	a,op7lm		;store low mantissa
	and	#07Fh,16,a	;mask off sign and exp to get high mantissa
	add	#080h,16,a	;add implied 1 to mantissa
	sth	a,op7hm		;store mantissa to stack
	
	dld	op8_hsw,a	;load op8 to acc a
	sfta	a,8
	sfta	a,-8
	bc	op8_zero,AEQ	;if op8 is 0,jump to special case
	sth	a,-7,op8se	;store sign and exponent to stack
	stl	a,op8lm		;store low mantissa
	and	#07Fh,16,a	;mask off sign and exp to get high mantissa
	add	#080h,16,a	;add implied 1 to mantissa
	sth	a,op8hm		;store mantissa to stack
	
	ld	op7se,a
	xor	op8se,a		;get sign of result
	and	#00100h,a	;mask to get sign
	stl	a,rltsign	;save to sign of result
	

;------ exponent summation -------

	ld	op7se,a
	and	#00FFh,a	;mask off the sign bit
	ld	op8se,b
	and	#00FFh,b	;mask off the sign bit
	add	#07fh,a
	sub	b,a		;take difference between exponents
	stl	a,rltexp
	bc	underflow,ALT	;branch to underflow handler if exp<0
	sub	#0FFh,a
	bc	overflow,AGT	;branch to overflow is exp>127

;--------- DIVISION -----------------
	

	dld	op7hm,a		;load divided to acc A
	sftl	a,6		;left shift for preparing for the divided
	dld	op8hm,b		;load divider to acc A 
	sftl	b,7		;right shift for preparing for the divided
	dst	b,op8hm		;save the divider to op8hm after shifted

	rpt	#14		;Q'HI = OP1¡¯HI/OP2¡¯HI
	subc	op8hm,a		;
	stl	a,rlthm		;Save Q'HI
	subs	rlthm,a		;Clear QHI from ACC
	rpt	#15		;Q¡¯LO = OP1¡¯LO / OP2¡¯HI
	subc	op8hm,a		;
	stl	a,rltlm		;Save Q¡¯LO
	ld	rlthm,T		;T = Q¡¯HI
	mpyu	op8lm,a		;Store Q¡¯HI * OP2¡¯LO in acc A
	sftl	a,-1		;
	rpt	#15		;Calculate Q¡¯HI * OP2¡¯LO / OP2¡¯HI
	subc	op8hm,a		;(correction factor)
	and	#0FFFFh,a	;Mask off correction factor
	neg	a		;Subtract correction factor
	adds	rltlm,a		;Add Q¡¯LO
	add	rlthm,16,a	;Add Q¡¯HI


;-------- POST AND STORAGE -----------

	ld	rltexp,b	;Load result exponent
	exp	a		;Get amount to adjust exp for normalizationNOP
	norm	a		;Normalize the result
	st	T,rltexp	;Store the exponent adjustment value
	sub	rltexp,b	;Adjust exponent (add either zero or one)
	sftl	a,-1		;Pre¨Cscale adjustment for rounding
	add	#1,b		;Adjust exponent
	add	#020h,a		;Add rounding bit
	exp	a		;Normalize after rounding
	nop
	norm	a		;
	st	T,rltexp	;Adjust exponent for normalization
	sub	rltexp,b	;
	stl	b,rltexp	;Save exponent
	bc	underflow,BLEQ	;process underflow if occurs
	sub	#0FFh,b		;adjust to check for overflow
	bc	overflow,BGEQ	;process overflow if occurs
	sftl	a,-7		;Shift right to place mantissa for splitting
	stl	a,rltlm		;Save result low mantissa
	and	#07F00h,8,a	;Eliminate implied one
	sth	a,rlthm		;Save result mantissa on stack


;-------- Conversion of Floating Point Format-Pack--------

	ld	rltsign,16,a	;load the sign
	add	rltexp,16,a	;put the exponent together
	sftl	a,7		;shift the value to right place
	dadd	rlthm,a		;add the result mantissa together


;-------- Context Restore ------------

return_value:
    nop
    nop
    nop
    nop               ; 6th breakpoint in CCS !
	b	return_value

op7_zero:
        nop;
        nop;
        nop;
	b	return_value
;--------- Underflow and Overflow Processing----------

overflow:
        st      #2,errno	;Load error no
        sat     a		;Result exponent = 0FEh
        sub     #081h,16,a	;Result high mant = 07Fh
        bd      return_value	;Branch delayed
        ld      rltsign,16,b	;Load sign of result
        or      b,7,a		;Pack sign

underflow:
        st      #1,errno	;Load error no
        bd      return_value	;Branch delayed
        sub     a,a		;For underflow result = 0
        nop;

op8_zero:
        st      #3,errno	;Load error no
        sat     a		;Result exponent = FEh, Result low mant = FFFFh
        ld      op7se,16,b	;Load sign and exponent of OP1
        and     #100h,16,b	;Mask to get sign of OP1
        or      b,7,a		;Pack sign
        bd      return_value	;Branch delayed
        sub     #081h,16,a	;Result high mant = 7Fh
        nop;
