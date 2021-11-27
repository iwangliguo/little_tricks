
// Example 6 - 3. LLMS Implementation C Listing

	y[n] = 0;        					//初始化输出缓冲区为0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 		// 乘累加的实现
	}
	en = d[n] – y[n];
	uen = mu*en;       //计算ue(n)
	for (i = 0; i < L; i++) {
		n[i] = leaky*wn[i]+uen*xn[i];  //算法迭代
	} 
