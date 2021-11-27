
;Example 3 - 8. Bit Reversion ASM Listing for TMS320C54x

bit_rev:
	SSBX	FRCT					; 打开小数模式
    STM		#d_input_addr, AR3  	; 在AR3中放入输入地址
    STM		#fft_data, AR7		; 在AR7中放入处理后输出的地址
    MVMM	AR7, AR2				; AR2中装入第一个位倒序数据指针
    STM		#K_FFT_SIZE-1, BRC
    STM 	#K_FFT_SIZE, AR0 	; AR0的值是输入数据数目的一半N/2
    RPTB	bit_rev_end
    MVDD	*AR3, *AR2+	 		; 将原始输入缓冲中的数据放入到位倒序缓冲中
    MAR		*AR3+0B				; 按位倒序寻址方式修改AR3
bit_rev_end

