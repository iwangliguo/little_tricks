
//Example 6 - 14. LMS Implementation C Listing Using Intrinsics for the TMS320C62x DSP


	for (i = 0; i < L; i++)
		yout += ((_mpy(x[i],w[i]))<<1);   	//乘累加，计算滤波器的输出
	err = d-(int)(yout>>16);             		//计算误差信号err
	mu_err=(int)((_mpy(mu,err))>>15);  		//计算ue(n-1)
	for (i = L-1; i >= 0; i--) {
		w[i] += ((_mpy(mu_err,x[i]))>>15);  	//更新滤波器的系数
		x[i] = x[i-1];                     		//实现数据的移动
	}

