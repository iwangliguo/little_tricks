//线性插值算法
//对于起点与终点，采用邻近的两点作出线段进行拟合
//对于普通样本点，采用邻近两点线性拟合
//输入：样本点数组与样本点数目
#include <stdio.h>
#include <stdlib.h>

float x[5]={1,3,5,7,9};
float y[5]={3,7,11,15,19};

float LinearInterpolation(float a[],float b[],int N,float input);
int main()
{
    float output = 0;
    output = LinearInterpolation(x,y,5,3.1);
    printf("y = %f",output);
    return 0;
}

float LinearInterpolation(float a[],float b[],int N ,float input)
{

    int i=0;
    float output = 0;
    for(i=0;i<N;i++)
    {
        if(input<=a[0])
        {
            output = b[0]+(input - a[0])*(b[1]-b[0])/(a[1]-a[0]);
        }
        else if(input>=a[N-1])
        {
            output = b[N-1]+(input - a[N-1])*(b[N-1]-b[N-2])/(a[N-1]-a[N-2]);
        }
        else if(input>=a[i] && input<=a[i+1])
        {
            output = b[i] +(input - a[i])*(b[i+1]-b[i])/(a[i+1]-a[i]);
        }
    }
    return output;
}
