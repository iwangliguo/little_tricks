
;Example 3 - 8. Bit Reversion ASM Listing for TMS320C54x

bit_rev:
	SSBX	FRCT					; ��С��ģʽ
    STM		#d_input_addr, AR3  	; ��AR3�з��������ַ
    STM		#fft_data, AR7		; ��AR7�з��봦�������ĵ�ַ
    MVMM	AR7, AR2				; AR2��װ���һ��λ��������ָ��
    STM		#K_FFT_SIZE-1, BRC
    STM 	#K_FFT_SIZE, AR0 	; AR0��ֵ������������Ŀ��һ��N/2
    RPTB	bit_rev_end
    MVDD	*AR3, *AR2+	 		; ��ԭʼ���뻺���е����ݷ��뵽λ���򻺳���
    MAR		*AR3+0B				; ��λ����Ѱַ��ʽ�޸�AR3
bit_rev_end

