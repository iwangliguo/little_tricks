
; Example 4 - 13. Biquad IIR Filter ASM Listing for the TMS320C55x DSP

; ����ѭ��Ѱַ��
	MOV	T0, T3				; ����2*nbiq
	SFTS	T3, #1
	MOV	@T3, BK03			; ��ʼ��AR0-3ѭ����������С��2*nbiq��
	BSET	AR3LC				; ��ʼ��AR3 = dbuffer
	ADD	#1,	AR3			; ����AR3ָ�򻺳�����ʼλ��
	MOV	@AR3, BSA23			; ��ʼ��AR2-3ָ��dbuffer(1)
	MOV	*AR5, AR3			; ��ʼ��AR3��ƫ����Ϊ��������ʼλ��
	SUB	#1, T1, T3			; ����nx-1
	MOV	T3, BRC0			; ������ѭ����������nx-1��
	MOV	XAR1, XAR7			; ���³�ʼ��ϵ��������ָ��
	SUB	#1,	TO, T3			; ������ѭ����������#biquads-1��
	MOV	T3,	 BRC1
	MOV	#SCALE, T2			; ��������

							; XAR0-x[], XAR1-h[], XAR2-r[] results, XAR3-dbuffer[], XAR7-XAR1

	RPTBLOCAL loop1-1			    	; ��ѭ��������һ���µ�����ֵ
	MOV	*AR0+<<#16, AC0				; HI(AC0) =x [n]
||	RPTBLOCAL loop2-1				; ��ѭ��������һ�����׽�
	MASM	T3=*(AR3+T0),	*AR1+	AC0		; AC0 -=a1*d[n-1]
	MASM	T3=*AR3, *AR1+	AC0			; AC0 -=a2*d[n-1]
	MASM	*AR1+, T3, AC0				; AC0 =b2*d[n-1]
||	MOV	HI(AC0<<T2), *AR3			; d[n]����d[-2]
	MACM	*(AR3+T0), *AR1+, AC0			; AC0 +=b0*d[N]
	MACM	*AR3, *AR1+,	AC0			; AC0 +=b1*d[N], ��һ���ڵ�����
loop2:
	MOV	XAR7, XAR1			; ���³�ʼ��ϵ��ָ��
	MOV	rnd(HI(AC0)), *AR2+		; ������
loop1:						; �ź����
	MOV	#0, T0
	XCC	check1, overflow(AC0)
	MOV	#1, T0
check1:
	MOV	AR3, *AR5			; ��������ֵ��dbuffer[0]

