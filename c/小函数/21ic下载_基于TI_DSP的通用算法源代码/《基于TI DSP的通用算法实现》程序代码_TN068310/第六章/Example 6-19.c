

// Example 6 - 19. LMS Implementation C Listing Using Intrinsics for the TMS320C64x DSP

	for (i = 0; i < L/2; i++)
		yout += _dotp2(x[i],w[i]); 		// ���ۼӣ��������ڲ�����_dotp2��
								// ѭ������������һ��
	err = d-(int)(yout>>16);    			// ��������ź�err
	mu_err = _mpy(mu, err);    		// ����ue(n-1)
    	for (i = L-1; i >= 0; i--){
		temp = ((_smpy2(mu_err_v,x[i])))	;	//ue(n-1)x[i], ue(n-1)x[i-1]
		temp_hi = _hi(temp);           // ���ݽ��
		temp_lo = _lo(temp);
		temp_com = _spack2(temp_hi, temp_lo);  
		w[i] = _add2(temp_com, w[i]);    // ����ϵ��
	}
