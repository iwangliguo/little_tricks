
//Example 6 - 4. SELMS Implementation C Listing

	y[n] = 0;        					// ��ʼ�����������Ϊ0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 		// ���ۼӵ�ʵ��
	}
	en = d[n] �C y[n];
	temp = mu;   						// e(n)����ֵ
	if (en < 0.0){
		temp = -mu;  					// e(n)�Ǹ�ֵ
	}
  	for(i=0;i<L;i++){
		wn[i] += temp*xn[i];  		// SELMS�㷨����
	}
