
// Example 6 - 1. LMS Implementation C Listing



	y[n] = 0;        				//��ʼ�����������Ϊ0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 	// ���ۼӵ�ʵ��
	}
	en = d[n] �C y[n];
	uen = mu*en;           		//����ue(n)��ֵ���洢��uen��Ԫ��
	for (i = 0; i < L; i++) {       
		wn[i] += uen * xn[i]; 	// LMS�㷨�ĵ���
	}
