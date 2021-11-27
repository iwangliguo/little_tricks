
; Example 4 - 13. Biquad IIR Filter ASM Listing for the TMS320C55x DSP

; 设置循环寻址区
	MOV	T0, T3				; 计算2*nbiq
	SFTS	T3, #1
	MOV	@T3, BK03			; 初始化AR0-3循环缓冲区大小（2*nbiq）
	BSET	AR3LC				; 初始化AR3 = dbuffer
	ADD	#1,	AR3			; 调整AR3指向缓冲区起始位置
	MOV	@AR3, BSA23			; 初始化AR2-3指向dbuffer(1)
	MOV	*AR5, AR3			; 初始化AR3的偏移量为缓存区起始位置
	SUB	#1, T1, T3			; 计算nx-1
	MOV	T3, BRC0			; 设置外循环计数器（nx-1）
	MOV	XAR1, XAR7			; 重新初始化系数缓冲区指针
	SUB	#1,	TO, T3			; 设置内循环计数器（#biquads-1）
	MOV	T3,	 BRC1
	MOV	#SCALE, T2			; 缩放因子

							; XAR0-x[], XAR1-h[], XAR2-r[] results, XAR3-dbuffer[], XAR7-XAR1

	RPTBLOCAL loop1-1			    	; 外循环，处理一个新的输入值
	MOV	*AR0+<<#16, AC0				; HI(AC0) =x [n]
||	RPTBLOCAL loop2-1				; 内循环，处理一个二阶节
	MASM	T3=*(AR3+T0),	*AR1+	AC0		; AC0 -=a1*d[n-1]
	MASM	T3=*AR3, *AR1+	AC0			; AC0 -=a2*d[n-1]
	MASM	*AR1+, T3, AC0				; AC0 =b2*d[n-1]
||	MOV	HI(AC0<<T2), *AR3			; d[n]代替d[-2]
	MACM	*(AR3+T0), *AR1+, AC0			; AC0 +=b0*d[N]
	MACM	*AR3, *AR1+,	AC0			; AC0 +=b1*d[N], 下一个节的输入
loop2:
	MOV	XAR7, XAR1			; 重新初始化系数指针
	MOV	rnd(HI(AC0)), *AR2+		; 储存结果
loop1:						; 信号溢出
	MOV	#0, T0
	XCC	check1, overflow(AC0)
	MOV	#1, T0
check1:
	MOV	AR3, *AR5			; 储存索引值到dbuffer[0]

