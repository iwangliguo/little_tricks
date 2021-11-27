
//Example 6 - 5. SDLMS Implementation C Listing


	y[n] = 0;        					// 初始化输出缓冲区为0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 		// 乘累加的实现
	}
	en = d[n] – y[n];
	uen = mu*en;       				//计算ue(n)
	for (i = 0; i < L; i++){
		if( xn[i] >= 00.0)     		//符号数据LMS算法迭代
			wn[i] += uen;
		else 
			wn[i] +=  uen; 
	}
