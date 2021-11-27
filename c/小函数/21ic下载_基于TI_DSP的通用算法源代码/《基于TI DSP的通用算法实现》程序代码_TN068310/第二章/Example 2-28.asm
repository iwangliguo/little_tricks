
;Example 2 - 28. Float-Point Addition ASM Listing for TMS320C54x

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
;    Some data put in 080h  DP=1 
;    SP may use system stack,so user needn't setup SP !       
;
;------------------------------------------------------------------

	.title  "for test user program ... "
	.mmregs
	.global _c_int00
	.ref	fs_start,errno

op1valh .set 4140h	;floating point number 12.0
op1vall	.set 0000h
op2valh .set 4140h	;floating point number 12.0
op2vall	.set 0000h
initst0	.set 1800h	;set st0 initial number
initst1	.set 2900h	;set st1 initial number

	.bss rlthm,1	;result high mantissa,address is 80h
	.bss rltlm,1	;result low mantissa,address is 81h
	.bss rltsign,1	;ressult sigh,address is 82h
	.bss rltexp,1	;result exponent,address is 83h
	.bss op1hm,1	;op1 high mantissa,address is 84h
	.bss op1lm,1	;op1 low mantissa,address is 85h
	.bss op1se,1	;op1 sigh and exp,address is 86h
	.bss op2se,1	;op2 sigh and exponent,address is 87h
	.bss op2hm,1	;op2 high mantissa,address is 88h
	.bss op2lm,1	;op2 low mantissa,address is 89h
	.bss op1_hsw,1	;op1 packed high,address is 8ah
	.bss op1_lsw,1	;op1 packed low,address is 8bh
	.bss op2_hsw,1	;op2 packed high,address is 8ch
	.bss op2_lsw,1	;op2 packed low,address is 8dh

_c_int00:
	stm	#initst0,st0
	stm	#initst1,st1
	rsbx	C16
	ld	#op1lm,dp
	ld	#op1valh,a	;load float number
	stl	a,op1_hsw
	ld	#op1vall,a
	stl	a,op1_lsw
	ld	#op2valh,a	;load float number
	stl	a,op2_hsw
	ld	#op2vall,a
	stl	a,op2_lsw
   	nop
    	nop
    	nop             	;1st breakpoint in CCS!



;----------- conversion of floating point format - unpack  -------

	dld	op1_hsw,a	;load OP1 to acc a
	sfta	a,8
	sfta	a,-8
	bc	op1_zero,AEQ	;if op1 is 0,jump to special case
	sth	a,-7,op1se	;store sign and exponent to stack
	stl	a,op1lm		;store low mantissa
	and	#07Fh,16,a	;mask off sign and exp to get high mantissa
	add	#080h,16,a	;add implied 1 to mantissa
	sth	a,op1hm		;store mantissa to stack
	dld	op2_hsw,a	;load OP2 to acc a
	sfta	a,8
	sfta	a,-8
	bc	op2_zero,AEQ	;if op2 is 0,jump to special case
	sth	a,-7,op2se	;store sign and exponent to stack
	stl	a,op2lm		;store low mantissa
	and	#07Fh,16,a	;mask off sign and exp to get high mantissa
	add	#080h,16,a	;add implied 1 to mantissa
	sth	a,op2hm		;store mantissa to stack
    	nop
    	nop
    	nop             	;2nd breakpoint in CCS !



;---------- judge the sign----------------
	bitf	op1se,#100h	;test the sign bit 
	bc	testop2,NTC	;if is not negative jump to testop2
	ld	#0,a		;change the experssion to 
	dsub	op1hm,a	
	dst	a,op1hm		;store changed op1
testop2:
	bitf	op2se,#100h	;test the sign bit 
	bc	compexp,NTC	;if is not negative jump to compexp
	ld	#0,a		;change the expression to 
	dsub	op2hm,a
	dst	a,op2hm		;store changed op2


;--------- Exponent Comparison ------------
compexp:
	ld	op1se,a
	and	#00ffh,a	;mask off the sign bit
	ld	op2se,b
	and	#00ffh,b	;mask off the sign bit
	sub	a,b		;exp op2-exp op1 -> b
	bc	op1_gt_op2,BLT	;process op1 > op2
	bc	op2_gt_op1,BGT	;process op2 > op1

a_eq_b
	dld	op1hm,a 
	dadd	op2hm,a		;add mantissa
	bc	res_zero,AEQ	;if result is zero process special case
	ld	op1se,b		;load exponent in preparation for normalizing

normalize
	sth	a,rltsign	;Save signed mantissa on stack
	abs	a		;Create magnitude value of mantissa
	sftl	a,6		;Pre¨Cnormalize adjustment of mantissa
	exp	a		;Get amount to adjust exp for normalization
	
	norm	a		;Normalize the result
	st	t,rltexp	;Store exp adjustment value
	add	#1,b		;Increment exp to account for implied carry
	sub	rltexp,b	;Adjust exponent to account for normalization

normalized
	stl	b,rltexp	;Save result exponent on stack
	bc	underflow,BLEQ	;process underflow if occurs
	sub	#0ffh,b		;adjust to check for overflow
	bc	overflow,BGEQ	;process overflow if occurs
	sftl	a,-7		;Shift right to place mantissa for splitting
	stl	a,rltlm		;Store low mantissa
	and	#07f00h,8,a	;Eliminate implied one
	sth	a,rlthm		;Save result mantissa on stack

;-----------  Conversion of Floating Point Format- Pack ---------

	ld	rltsign,9,a
	and	#100h,16,a	;Get the sign value
	add	rltexp,16,a	;Add the result exponent together
	sftl	a,7		;shift the value to right place
	dadd	rlthm,a		;Add the result mantissa together

return_value   
    nop
    nop 
    nop
    nop             ; 3th breakpoint in CCS !
	b	fs_start

op1_gt_op2
	abs	b			;if exp OP1 >= exp OP2 + 24 then return OP1
	sub	#24,b
	bc	return_op1,BGEQ
	add	#23,b			;restore exponent difference value
	stl	b,rltsign		;store exponent difference to be used as RPC
	dld	op2hm,a			;load OP2 mantissa
	rpt	rltsign			;normalize OP2 to match OP1
	sfta	a,-1
	bd	normalize		;delayed branch to normalize result
	ld	op1se,b			;load exponentvalue to prep for normalization
	dadd	op1hm,a			;add OP1 to OP2

op2_gt_op1
	sub	#24,b			;if exp OP2 >= exp OP1 + 24 then return OP1
	bc	return_op2,BGEQ	
	add	#23,b			;Restore exponent difference value
	stl	b,rltsign		;Store exponent difference to be used as RPC
	dld	op1hm,a			;Load OP1 mantissa
	rpt	rltsign			;Normalize OP1 to match OP2
	sfta	a,-1			
	bd	normalize		;Delayed branch to normalize result
	ld	op2se,b			;Load exponent value to prep for normalization
	dadd	op2hm,a			;Add OP2 to OP1



op1_zero:

return_op2:
	bd	return_value
	dld	op2_hsw,a		;Put OP2 as result into A

op2_zero:

return_op1:
	dld	op1hm,a			;Load signed high mantissa of OP1
	bc	op1_pos,AGT		;If mantissa is negative .
	neg	a			;Negate it to make it a positive value
	addm	#100h,op1se		;Place the sign value back into op1_se

op1_pos

	sub	#80h,16,a		;Eliminate implied one from mantissa
	ld	op1se,16,b		;Put OP1 back together in acc A as a result
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
