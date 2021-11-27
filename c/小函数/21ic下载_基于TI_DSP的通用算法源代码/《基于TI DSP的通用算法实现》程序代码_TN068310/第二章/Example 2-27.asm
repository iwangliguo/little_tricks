
;Example 2 - 27. Data Format Transform ASM Listing for TMS320C54x


	dld	op1_hsw,  a		;将OP1装入累加器A中。
	sfta	a,  8			
	sfta	a, -8			;通过先左移后右移使 AG = 0
	bc	op1_zero,  AEQ		;如果OP1是零，转入特殊处理
	sth	a,  -7,  op1se		;将符号和指数存储到OP1SE中
	stl	a,  op1lm		;存储尾数的低位
	and	#07Fh,  16,  a		;将浮点数格式中的符号和指数去掉
					;得到尾数的高位
	add	#080h,  16,  a		;给尾数加上小数点前的“1”
	sth	a,  op1hm		;存储尾数的高位。


	bitf	op1se,  #100h		；取出op1符号位的值于TC位中
	bc	testop2,  NTC		；如果TC = 0则跳转到testop2处
	ld	#0,  a		
	dsub	op1hm,  a		；0 – op1的尾数，得到尾数的补码表示
	dst	a,  op1hm		；将尾数存入op1hm和op1lm中

testop2:
	bitf	op2se,  #100h		；取出op1符号位的值于TC位中
	bc	compexp,  NTC		；如果TC = 0则跳转到compexp处
	ld	#0,  a		
	dsub	op2hm,  a		；0 – op1的尾数，得到尾数的补码表示
	dst	a,  op2hm		；将尾数存入op1hm和op1lm中

