
//Example 6 - 6. SSLMS Implementation C Listing


	y[n] = 0;        					// ��ʼ�����������Ϊ0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 		// ���ۼӵ�ʵ��
	}
	en = d[n] �C y[n];
	for (i = 0; i < L; i++){
		if (en >= 0.0) {				// e[n]Ϊ��
			if (xn[i] >= 0.0)			// x[n]Ϊ��
				wn[i] += mu;
			else							// x[n]Ϊ��
				wn[i] += -mu;
			}
		else {							// e[n]Ϊ��
			if (xn[i]>=0.0)				// x[n]Ϊ��
				wn[i]+=-mu;
			else							// x[n]Ϊ��
				wn[i]+=mu;
			}
	}

