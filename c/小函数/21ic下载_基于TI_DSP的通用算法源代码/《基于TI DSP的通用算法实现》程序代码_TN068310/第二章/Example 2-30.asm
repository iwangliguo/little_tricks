
;Example 2 - 30. Float-Point Multiplication ASM Listing for TMS320C54x


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
	.global mainstart
	.def	fm_start
	.ref	fd_start,errno

op5valh	.set 4140h	;floating point number 12.0
op5vall	.set 0000h
op6valh	.set 4140h	;floating point number 12.0
op6vall	.set 0000h
initst0	.set 1800h	;set st0 initial number
initst1	.set 2900h	;set st1 initial number

	.bss rlthm,1	;result high mantissa
	.bss rltlm,1	;result low mantissa
	.bss rltsign,1	;ressult sigh
	.bss rltexp,1	;result exponent
	.bss op5hm,1	;op5 high mantissa
	.bss op5lm,1	;op5 low mantissa
	.bss op5se,1	;op5 sigh and exp
	.bss op6se,1	;op6 sigh and exponent
	.bss op6hm,1	;op6 high mantissa
	.bss op6lm,1	;op6 low mantissa
	.bss op5_hsw,1	;op5 packed high
	.bss op5_lsw,1	;op5 packed low
	.bss op6_hsw,1	;op6 packed high
	.bss op6_lsw,1	;op6 packed low

fm_start:
	stm	#initst0,st0
	stm	#initst1,st1
	rsbx	C16
	ld	#op5lm,dp	;load float number
	ld	#op5valh,a
	stl	a,op5_hsw
	ld	#op5vall,a
	stl	a,op5_lsw
	ld	#op6valh,a	;load float number
	stl	a,op6_hsw
	ld	#op6vall,a
	stl	a,op6_lsw

;----------- conversion of floating point format - unpack  -------

	dld	op5_hsw,a	;load op5 to acc a
	sfta	a,8
	sfta	a,-8
	bc	op_zero,AEQ	;if op5 is 0,jump to special case
	sth	a,-7,op5se	;store sign and exponent to stack
	stl	a,op5lm		;store low mantissa
	and	#07Fh,16,a	;mask off sign and exp to get high mantissa
	add	#080h,16,a	;add implied 1 to mantissa
	sth	a,op5hm		;store mantissa to stack
	dld	op6_hsw,a	;load OP6 to acc a
	sfta	a,8
	sfta	a,-8
	bc	op_zero,AEQ	;if op6 is 0,jump to special case
	sth	a,-7,op6se	;store sign and exponent to stack
	stl	a,op6lm		;store low mantissa
	and	#07Fh,16,a	;mask off sign and exp to get high mantissa
	add	#080h,16,a	;add implied 1 to mantissa
	sth	a,op6hm		;store mantissa to stack

;------ sign evaluation -----------------

	ld	op5se,a		;load op5exp
	xor	op6se,a		;load op6exp
	and	#00100h,a	;mask exp to get the sign
	stl	a,rltsign	;get the result sign

;------ exponent summation --------------

	ld	op5se,a	
	and	#00FFh,a		;mask off the sign bit
	ld	op6se,b			
	and	#00FFh,b		;mask off the sign bit
	sub	#07fh,b			;subtract offset (avoid double bias)
	add	b,a			;add op5 exponent
	stl	a,rltexp		;save result exponent on stack
	bc	underflow,ALT		;branch to underflow handler if exp < 0
	sub	#0FFh,a			;test for overflow
	bc	overflow,AGT		;branch to overflow is exp > 127

;---------- multiplication -----------

	ld	op5lm,t			;load low mant of op5 to T register
	mpyu	op6lm,a			;RS*YZ
	mpyu	op6hm,b			;RS*0X
	add	a,-16,b			;B=(RS*YZ)+(RS*0X)
	ld	op5hm,t			;load high mant of op5 to T register
	mpyu	op6lm,a			;A=0Q*YZ
	add	b,a			;A=(RS*YZ)+(RS*0X)+(0Q*YZ)
	mpyu	op6hm,b			;B=0Q*0X
	stl	b,rlthm			;get lower word of 0Q*0X
	add	rlthm,16,a		;A=final result
	
;---------- post-normalization adjustment and storage ------

	add	#40h,a			;Add rounding bit
	ssbx	sxm			;sign extend result to check if MSB is in 31
	sfta	a,8			
	sfta	a,-8			
	rsbx	sxm			;turn off sign extension for normalization
	ld	rltexp,b		;load exponent of result
	bc	normalized,AGEQ		;check if MSB is in 31
	sftl	a,-1			;Shift result so result is in bits 30:7
	add	#1,b			;increment exponent
	stl	b,rltexp		;save updated exponent normalized
	bc	underflow,BlEQ		;check for underflow
	sub	#0FFh,b			;adjust to check for overflow
	bc	overflow,BGEQ		;check for overflow

normalized
	sftl	a,-7			;shift to get 23 msb bits of mantissa result
	stl	a,rltlm			;store low mantissa result
	and	#07F00h,8,a		;remove implied one
	sth	a,rlthm			;store the mantissa result
	
;------- conversion of floating point format - pack  ----

	ld	rltsign,16,a		;load the sign
	add	rltexp,16,a		;put the exponent together
	sftl	a,7			;shift the value to right place
	dadd	rlthm,a			;add the result mantissa together
	
return_value
    nop
    nop
    nop
    nop                ; 5th breakpoint in CCS !
    b       fd_start;

op_zero	
    nop
	nop
	nop
	b return_value
	
;-------overflow processing ---------

overflow
	st	#2,errno		;Load error no
	ld	rltsign,16,b		;Load sign of result
	ld	#0FFFFh,a		;Result low mantissa = 0FFFFh
	or	b,7,a			;Add sign bit
	bd	return_value		;Branch delayed
	add	#07F7Fh,16,a		;Result exponent = 0FEh
	
underflow
	st	#1,errno		;Load error no
	bd	return_value		;Branch delayed
	sub	a,a			;For underflow result = 0
	nop;
