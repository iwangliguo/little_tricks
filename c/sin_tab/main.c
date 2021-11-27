//利用50点可以随时生成200点的正弦表，只占用50点的空间
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

//void arrReverse();
float sin_tab[50]=
{
 0.5157  ,  0.5314  ,  0.5471  ,  0.5627  , 0.5782  ,
 0.593   ,  0.6091  ,  0.6243  ,  0.6395  , 0.6545  ,
 0.6694  ,  0.6841  ,  0.6986  ,  0.7129  , 0.7270  ,
 0.7409  ,  0.7545  ,  0.7679  ,  0.7810  , 0.7939  ,
 0.8065  ,  0.8187  ,  0.8307  ,  0.8423  , 0.8536  ,
 0.8645  ,  0.8751  ,  0.8853  ,  0.8951  , 0.9045  ,
 0.9135  ,  0.9222  ,  0.9304  ,  0.9382  , 0.9455  ,
 0.9524  ,  0.9589  ,  0.9649  ,  0.9704  , 0.9755  ,
 0.9801  ,  0.9843  ,  0.9880  ,  0.9911  , 0.9938  ,
 0.9961  ,  0.9978  ,  0.9990  ,  0.9998  , 1.0000
} ;

int main(void)
{
    //第一次循环:将正弦表倒序排放；
    int i = 0,N = 0;
    float temp = 0.0;
    N = sizeof(sin_tab)/sizeof(sin_tab[0]);
    for(i=0;i<N/2;i++)
    {
        temp = sin_tab[N-i-1] ;
        sin_tab[N-1-i] = sin_tab[i];
        sin_tab[i]  = temp;
    }

    //第二次循环，中心对称反转数据，重新填入数组

    for(i=0;i<N/2;i++)
    {
        temp = sin_tab[N-1-i];
        sin_tab[N-1-i] = -sin_tab[i];
        sin_tab[i] = -temp;
    }

    //第三次循环，轴对称反转
    for(i=0;i<N/2;i++)
    {
        temp = sin_tab[N-i-1] ;
        sin_tab[N-1-i] = sin_tab[i];
        sin_tab[i]  = temp;
    }

    for(i=0;i<N;i++)
    {
        printf("%f\n",sin_tab[i]);
    }
    return 0;
}



