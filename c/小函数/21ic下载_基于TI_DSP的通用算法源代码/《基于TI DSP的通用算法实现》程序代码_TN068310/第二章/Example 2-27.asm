
;Example 2 - 27. Data Format Transform ASM Listing for TMS320C54x


	dld	op1_hsw,  a		;��OP1װ���ۼ���A�С�
	sfta	a,  8			
	sfta	a, -8			;ͨ�������ƺ�����ʹ AG = 0
	bc	op1_zero,  AEQ		;���OP1���㣬ת�����⴦��
	sth	a,  -7,  op1se		;�����ź�ָ���洢��OP1SE��
	stl	a,  op1lm		;�洢β���ĵ�λ
	and	#07Fh,  16,  a		;����������ʽ�еķ��ź�ָ��ȥ��
					;�õ�β���ĸ�λ
	add	#080h,  16,  a		;��β������С����ǰ�ġ�1��
	sth	a,  op1hm		;�洢β���ĸ�λ��


	bitf	op1se,  #100h		��ȡ��op1����λ��ֵ��TCλ��
	bc	testop2,  NTC		�����TC = 0����ת��testop2��
	ld	#0,  a		
	dsub	op1hm,  a		��0 �C op1��β�����õ�β���Ĳ����ʾ
	dst	a,  op1hm		����β������op1hm��op1lm��

testop2:
	bitf	op2se,  #100h		��ȡ��op1����λ��ֵ��TCλ��
	bc	compexp,  NTC		�����TC = 0����ת��compexp��
	ld	#0,  a		
	dsub	op2hm,  a		��0 �C op1��β�����õ�β���Ĳ����ʾ
	dst	a,  op2hm		����β������op1hm��op1lm��

