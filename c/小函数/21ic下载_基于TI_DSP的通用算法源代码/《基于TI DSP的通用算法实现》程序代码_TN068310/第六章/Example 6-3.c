
// Example 6 - 3. LLMS Implementation C Listing

	y[n] = 0;        					//��ʼ�����������Ϊ0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 		// ���ۼӵ�ʵ��
	}
	en = d[n] �C y[n];
	uen = mu*en;       //����ue(n)
	for (i = 0; i < L; i++) {
		n[i] = leaky*wn[i]+uen*xn[i];  //�㷨����
	} 
