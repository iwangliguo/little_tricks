
//Example 6 - 5. SDLMS Implementation C Listing


	y[n] = 0;        					// ��ʼ�����������Ϊ0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 		// ���ۼӵ�ʵ��
	}
	en = d[n] �C y[n];
	uen = mu*en;       				//����ue(n)
	for (i = 0; i < L; i++){
		if( xn[i] >= 00.0)     		//��������LMS�㷨����
			wn[i] += uen;
		else 
			wn[i] +=  uen; 
	}
