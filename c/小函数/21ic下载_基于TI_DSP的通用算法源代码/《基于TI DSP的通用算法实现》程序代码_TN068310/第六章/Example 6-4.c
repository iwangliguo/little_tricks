
//Example 6 - 4. SELMS Implementation C Listing

	y[n] = 0;        					// 初始化输出缓冲区为0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 		// 乘累加的实现
	}
	en = d[n] – y[n];
	temp = mu;   						// e(n)是正值
	if (en < 0.0){
		temp = -mu;  					// e(n)是负值
	}
  	for(i=0;i<L;i++){
		wn[i] += temp*xn[i];  		// SELMS算法迭代
	}
