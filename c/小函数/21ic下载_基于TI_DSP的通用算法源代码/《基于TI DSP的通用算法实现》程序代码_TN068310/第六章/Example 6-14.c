
//Example 6 - 14. LMS Implementation C Listing Using Intrinsics for the TMS320C62x DSP


	for (i = 0; i < L; i++)
		yout += ((_mpy(x[i],w[i]))<<1);   	//���ۼӣ������˲��������
	err = d-(int)(yout>>16);             		//��������ź�err
	mu_err=(int)((_mpy(mu,err))>>15);  		//����ue(n-1)
	for (i = L-1; i >= 0; i--) {
		w[i] += ((_mpy(mu_err,x[i]))>>15);  	//�����˲�����ϵ��
		x[i] = x[i-1];                     		//ʵ�����ݵ��ƶ�
	}

