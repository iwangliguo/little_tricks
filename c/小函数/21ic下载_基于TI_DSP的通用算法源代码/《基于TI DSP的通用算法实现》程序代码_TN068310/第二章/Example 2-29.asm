
;Example 2 - 29. Float-Point Subtraction ASM Listing for TMS320C54x

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
	.def	fs_start
	.ref	fm_start,errno

op3valh .set 4150h     ;floating point number 13.0
op3vall	.set 0000h
op4valh .set 4140h     ;floating point number 12.0
op4vall	.set 0000h
initst0	.set 1800h	;set st0 initial number
initst1	.set 2900h	;set st1 initial number

	.bss rlthm,1	;result high mantissa
	.bss rltlm,1	;result low mantissa
	.bss rltsign,1	;ressult sigh
	.bss rltexp,1	;result exponent
	.bss op3hm,1	;op3 high mantissa
	.bss op3lm,1	;op3 low mantissa
	.bss op3se,1	;op3 sigh and exp
	.bss op4se,1	;op4 sigh and exponent
	.bss op4hm,1	;op4 high mantissa
	.bss op4lm,1	;op4 low mantissa
	.bss op3_hsw,1	;op3 packed high
	.bss op3_lsw,1	;op3 packed low
	.bss op4_hsw,1	;op4 packed high
	.bss op4_lsw,1	;op4 packed low

fs_start
	stm	#initst0,st0	;initialize st0 and st1
	stm	#initst1,st1
	rsbx	C16		;insure long address for later
	ld	#op3lm,dp
	ld	#op3valh,a	;load floating
	stl	a,op3_hsw
	ld	#op3vall,a
	stl	a,op3_lsw
	ld	#op4valh,a	;load floating
	stl	a,op4_hsw
	ld	#op4vall,a
	stl	a,op4_lsw

;----------- conversion of floating point format - unpack  -------

	dld	op3_hsw,a	;load op3 to acc a
	sfta	a,8
	sfta	a,-8
	bc	op3_zero,AEQ	;if op3 is 0,jump to special case
	sth	a,-7,op3se	;store sign and exponent to stack
	stl	a,op3lm		;store low mantissa
	and	#07Fh,16,a	;mask off sign and exp to get high mantissa
	add	#080h,16,a	;add implied 1 to mantissa
	sth	a,op3hm		;store mantissa to stack
	dld	op4_hsw,a	;load op4 to acc a
	sfta	a,8
	sfta	a,-8
	bc	op4_zero,AEQ	;if op4 is 0,jump to special case
	sth	a,-7,op4se	;store sign and exponent to stack
	stl	a,op4lm		;store low mantissa
	and	#07Fh,16,a	;mask off sign and exp to get high mantissa
	add	#080h,16,a	;add implied 1 to mantissa
	sth	a,op4hm		;store mantissa to stack


;---------- judge the sign----------------
	bitf	op3se,#100h	;test the sign bit 
	bc	testop4,NTC	;if is not negative jump to testop4
	ld	#0,a		;change the experssion to 
	dsub	op3hm,a	
	dst	a,op3hm		;store changed op3
testop4:	
	bitf	op4se,#100h	;test the sign bit 
	bc	compexp,NTC	;if is not negative jump to compexp
	ld	#0,a		;change the expression to 
	dsub	op4hm,a	
	dst	a,op4hm		;store changed op4
		

;--------- Exponent Comparison ------------
compexp:
	ld	op3se,a	
	and	#00ffh,a	;mask off the sign bit	
	ld	op4se,b	
	and	#00ffh,a	;mask off the sign bit
	sub	a,b		;exp op4-exp op3 -> b
	bc	op3_gt_op4,BLT	;process op3 > op4
	bc	op4_gt_op3,BGT	;process op4 > op3

a_eq_b
	dld	op3hm,a  
	dsub	op4hm,a		;sub mantissa
	ld	op3se,b		;load exponent in preparation for normalizing

normalize
	sth	a,rltsign	;save signed mantissa on stack
	abs	a		;create magnitude value of mantissa
	sftl	a,6
	nop
	exp	a		;get amount to adjust exp for normalization
	nop
	norm	a
	st	t,rltexp	;store exp adjustment value
	add	#1,b		;increment exp to account for normalization
	sub	rltexp,b	;adjust exponent to account for normalization

normalized
	stl	b,rltexp	;save result exp
	bc	underflow,BLEQ	;process underflow if occurs
	sub	#0ffh,b		
	bc	overflow,BGEQ	;process overflow if occurs
	sftl	a,-7		;shift right to place mantissa for splitting
	stl	a,rltlm		;store low mantissa
	and	#07f00h,8,a	;eliminate impiled one
	sth	a,rlthm		;save high mantissa

;-----------  Conversion of Floating Point Format- Pack ---------

	ld	rltsign,9,a	;put result sign to acc a
	and	#100h,16,a
	add	rltexp,16,a	;put result exp together ;
	sftl	a,7
	dadd	rlthm,a		;add mantissa together

return_value         
    nop
    nop            
    nop
    nop             ; 4th breakpoint in CCS !
	b	fm_start

op3_gt_op4
	abs	b		;if exp op3>=exp op4 + 24 then return op3
	sub	#24,b
	bc	return_op3,BGEQ
	add	#23,b		;restore exponent difference value
	stl	b,rltsign	;store exponent difference to be use as RPC
	dld	op4hm,a
	rpt	rltsign		;normalize op4 to match op3
	sfta	a,-1
	bd	normalize	;delayed branch to normalize result
	ld	op3se,b		;load exponent to prep for normalization
	dsub	op3hm,a

op4_gt_op3
	sub	#24,b		;if exp op4>=exp op3 + 24 then return op4
	bc	return_op4,BGEQ
	add	#23,b		;restore exponent difference value
	stl	b,rltsign	;store exponent difference to be use as RPC
	dld	op3hm,a
	rpt	rltsign		;normalize op3 to match op4
	sfta	a,-1
	bd	normalize	;delayed branch to normalize result
	ld	op4se,b		;load exponent to prep for normalization
	dsub	op4hm,a

return_op4

op3_zero
	bd	return_value
	dld	op4_hsw,a		;put op4 as result		

op4_zero

return_op3
	dld	op3hm,a			;load signed high mantissa of op3
	bc	op3_pos,AGT		;if mantissa is negative
	neg	a
	addm	#100h,op3se		;place the sign value back into op3se

op3_pos

	sub	#80h,16,a		;eliminate implied one from mantissa
	ld	op3se,16,b		;put op3 back together in acc as a result
	bd	return_value
	sftl	b,7
	add	b,a

overflow
	st	#2,errno		;load error no
	ld	rltsign,16,a		;pack sign of result
	and	#8000,16,a
	or	#0ffffh,a		;result low mantissa
	bd	return_value
	add	#07f7fh,16,a		;result exponent

underflow
	st	#1,errno		;load error no
	b	return_value

res_zero
	bd	return_value
	sub	a,a
	nop
