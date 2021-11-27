
//Example 6 - 6. SSLMS Implementation C Listing


	y[n] = 0;        					// 初始化输出缓冲区为0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 		// 乘累加的实现
	}
	en = d[n] – y[n];
	for (i = 0; i < L; i++){
		if (en >= 0.0) {				// e[n]为正
			if (xn[i] >= 0.0)			// x[n]为正
				wn[i] += mu;
			else							// x[n]为负
				wn[i] += -mu;
			}
		else {							// e[n]为正
			if (xn[i]>=0.0)				// x[n]为正
				wn[i]+=-mu;
			else							// x[n]为负
				wn[i]+=mu;
			}
	}

