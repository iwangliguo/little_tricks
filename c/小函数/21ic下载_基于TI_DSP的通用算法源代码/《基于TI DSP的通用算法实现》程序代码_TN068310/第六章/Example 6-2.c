//Example 6 - 2. NLMS Implementation C Listing


	y[n] = 0;        					//初始化输出缓冲区为0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 		// 乘累加的实现
	}
	en = d[n] – y[n];
	powerx = b1*powerx+b*xn[0]*xn[0];
										//功率估计
	uncn = a/(powerx+savemargin); 	//归一化步长因子
	uen = uncn*en;        			//计算u(n)e(n)的值并存储在uen单元中
	for (i = 0; i < L; i++)	{
		wn[i] += uen * xn[i];    	//归一化LMS算法迭代
	}

