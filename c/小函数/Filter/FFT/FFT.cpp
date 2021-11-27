/*
*作者：handspeaker
*时间：2013.4.9
*多项式相乘FFT算法，包括
*FFT函数
*IFFT函数
*等
*/
#include<stdio.h>
#include<string.h>
#include<math.h>
#define MAX_SIZE 65536
#define PI	     (acos((double)-1))
//复数
struct Complex{
	double real;
	double image;
};
Complex a1[MAX_SIZE],a2[MAX_SIZE],result[MAX_SIZE],w[MAX_SIZE];
//复数相乘计算
Complex operator*(Complex a,Complex b){
	Complex r;
	r.real=a.real*b.real-a.image*b.image;
	r.image=a.real*b.image+a.image*b.real;
	return r;
}
//复数相加计算
Complex operator+(Complex a,Complex b){
	Complex r;
	r.real=a.real+b.real;
	r.image=a.image+b.image;
	return r;
}
//复数相减计算
Complex operator-(Complex a,Complex b){
	Complex r;
	r.real=a.real-b.real;
	r.image=a.image-b.image;
	return r;
}
//复数除法计算
Complex operator/(Complex a,double b){
	Complex r;
	r.real=a.real/b;
	r.image=a.image/b;
	return r;
}
//复数虚部取负计算
Complex operator~(Complex a){
	Complex r;
	r.real=a.real;
	r.image=0-a.image;
	return r;
}
//重新排列
void Reverse(int* id,int size,int m){
	for(int i=0;i<size;i++){
		for(int j=0;j<m;j++){
			int exp=(i>>j)&1;
			id[i]+=exp*(int)pow((double)2,(double)(m-j-1));
		}
	}
};
//计算并存储需要乘的w值
void Compute_W(Complex w[],int size){
	for(int i=0;i<size/2;i++){
		w[i].real=cos(2*PI*i/size);
		w[i].image=sin(2*PI*i/size);
		w[i+size/2].real=0-w[i].real;
		w[i+size/2].image=0-w[i].image;
	}
};
//快速傅里叶
void FFT(Complex in[],int size){
	int* id=new int[size];
	memset(id,0,sizeof(int)*size);
	int m=log((double)size)/log((double)2);
	Reverse(id,size,m);	//将输入重新排列，符合输出
	Complex *resort= new Complex[size];
	memset(resort,0,sizeof(Complex)*size);
	int i,j,k,s;
	for(i=0;i<size;i++)
		resort[i]=in[id[i]];
	for(i=1;i<=m;i++){
		s=(int)pow((double)2,(double)i);
		for(j=0;j<size/s;j++){
			for(k=j*s;k<j*s+s/2;k++){		
				Complex k1=   resort[k]+w[size/s*(k-j*s)]*resort[k+s/2];
				resort[k+s/2]=resort[k]-w[size/s*(k-j*s)]*resort[k+s/2];
				resort[k]=k1;
			}
		}
	}
	for(i=0;i<size;i++)
		in[i]=resort[i];
	delete[] id;
	delete[] resort;
};
//快速逆傅里叶
void IFFT(Complex in[],int size){
	int* id=new int[size];
	memset(id,0,sizeof(int)*size);
	int m=log((double)size)/log((double)2);
	Reverse(id,size,m);	//将输入重新排列，符合输出
	Complex *resort= new Complex[size];
	memset(resort,0,sizeof(Complex)*size);
	int i,j,k,s;
	for(i=0;i<size;i++)
		resort[i]=in[id[i]];
	for(i=1;i<=m;i++){
		s=(int)pow((double)2,(double)i);
		for(j=0;j<size/s;j++){
			for(k=j*s;k<j*s+s/2;k++){
				Complex k1=(resort[k]+(~w[size/s*(k-j*s)])*resort[k+s/2]);
				resort[k+s/2]=(resort[k]-(~w[size/s*(k-j*s)])*resort[k+s/2]);
				resort[k]=k1;
			}
		}
	}
	for(i=0;i<size;i++)
		in[i]=resort[i]/size;
	delete[] id;
	delete[] resort;
};
int main(){
	//输入两个多项式数列
	int size,size1,size2,i;
	memset(a1,0,sizeof(a1));
	memset(a2,0,sizeof(a2));
	memset(w,0,sizeof(w));
	memset(result,0,sizeof(result));
	scanf("%d%d",&size1,&size2);
	for(i=0;i<size1;i++)
		scanf("%lf",&a1[i].real);
	for(i=0;i<size2;i++)
		scanf("%lf",&a2[i].real);
	size=size1>size2?size1*2:size2*2;
	Compute_W(w,size);
	FFT(a1,size);
	FFT(a2,size);
	for(i=0;i<size;i++)
		result[i]=a1[i]*a2[i];
	IFFT(result,size);
	for(i=0;i<size1+size2-1;i++)
		printf("%.2lf ",result[i].real);
	printf("\n");
	return 0;
}