
//对输入数组进行线性拟合
//input:x[],y[],数组元素个数
//output:结构体变量 包含线性度，斜率和截距

#include <stdio.h>
#include <stdlib.h>
#include "math.h"


struct linearRegression{
    float slope;
    float Intercept;
    float linearity;
};

struct linearRegression line1;

float x[5]= {35.25,38.292,41.684,44.589,46.823};
float y[5]= {11,13,15,17,19};
int   N = 5;

void linearRgression(float x[],float y[],int N,struct linearRegression *line);

int main()
{
    linearRgression(x,y,N,&line1);
    printf("Hello world!\n");
    printf("slope:%f \nintercept:%f \nlinearity:%f",line1.slope,line1.Intercept,line1.linearity);
    return 0;
}

void linearRgression(float x[],float y[],int N,struct linearRegression *line)
{
    unsigned int i = 0;
    float xy_sum=0,x_sum=0,y_sum=0,x_2_sum=0;
    float x_avg=0,y_avg=0;

    for(i = 0; i < N; i++){
             xy_sum += x[i]*y[i];
             x_sum  += x[i];
             y_sum  += y[i];
             x_2_sum += x[i]*x[i];
    }

    x_avg = x_sum/N;
    y_avg = y_sum/N;

    //计算斜率和截距
    line->slope = (N * xy_sum -  x_sum * y_sum) / ( N *  x_2_sum -  x_sum * x_sum);
    line->Intercept =  y_avg -  line->slope *  x_avg;

    //计算线性度
    unsigned int j = 0;
    float temp1=0,temp2=0 ;
    for(j=0;j<N;j++)
    {
        temp1 +=(line->slope*x[j]+line->Intercept - y_avg)*(line->slope*x[j]+line->Intercept - y_avg);
        temp2 += (y[j]-y_avg)*(y[j]-y_avg);
    }
        line->linearity = temp1/temp2;
}
