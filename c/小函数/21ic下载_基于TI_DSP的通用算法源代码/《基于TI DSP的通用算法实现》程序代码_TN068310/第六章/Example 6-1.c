
// Example 6 - 1. LMS Implementation C Listing



	y[n] = 0;        				//初始化输出缓冲区为0
	for (i = 0; i < L; i++) {        
		y[n] += wn[i] * xn[i]; 	// 乘累加的实现
	}
	en = d[n] – y[n];
	uen = mu*en;           		//计算ue(n)的值并存储在uen单元中
	for (i = 0; i < L; i++) {       
		wn[i] += uen * xn[i]; 	// LMS算法的迭代
	}
