//Example 6 - 2. NLMS Implementation C Listing


	y[n] = 0;        					//��ʼ�����������Ϊ0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 		// ���ۼӵ�ʵ��
	}
	en = d[n] �C y[n];
	powerx = b1*powerx+b*xn[0]*xn[0];
										//���ʹ���
	uncn = a/(powerx+savemargin); 	//��һ����������
	uen = uncn*en;        			//����u(n)e(n)��ֵ���洢��uen��Ԫ��
	for (i = 0; i < L; i++)	{
		wn[i] += uen * xn[i];    	//��һ��LMS�㷨����
	}

