#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define SAMPLE_NODES 5

float testtable[5]= {1,2,3,4,5};
typedef int uint16_t;
unsigned short GetMaxValueIndex(float *output)
{
    uint16_t i;
    uint16_t index = 0;
    float temp = output[0];
    for(i=0;i<SAMPLE_NODES;i++)
    {
       if(output[i] >= temp)
       {
           temp = output[i];
           index = i;
       }
    }
    return index;
}

int sin_tab[91]=
{
0 ,1745  , 3489 ,  5233,  6975,  8715,  10452  , 12186 ,13917 ,15643 ,17364,
19080 ,20791 ,22495 ,24192 ,25881 ,27563 ,29237 ,30901 ,32556 ,34202,
35836 ,37460 ,39073 ,40673 ,42261 ,43837 ,45399 ,46947 ,48480 ,50000,
51503 ,52991 ,54463 ,55919 ,57357 ,58778 ,60181 ,61566 ,62932 ,64278,
65605 ,66913 ,68199 ,69465 ,70710 ,71933 ,73135 ,74314 ,75470 ,76604,
77714 ,78801 ,79863 ,80901 ,81915 ,82903 ,83867 ,84804 ,85716 ,86602,
87461 ,88294 ,89100 ,89879 ,90630 ,91354 ,92050 ,92718 ,93358 ,93969,
94551 ,95105 ,95630 ,96126 ,96592 ,97029 ,97437 ,97814 ,98162 ,98480,
98768 ,99026 ,99254 ,99452 ,99619 ,99756 ,99862 ,99939 ,99984 ,100000
} ;
  //91点正弦数据，前1/4个周期，放大100000；


int main()
{

    float sintable[91];
    float vsqr_sum = 0;
    float vrms = 0;
    for(int i =0 ;i<91;i++)
    {
        sintable[i] = sin_tab[i]/100000.0;
        vsqr_sum    = vsqr_sum +  sintable[i]*sintable[i];
    }
    vrms  = sqrt(vsqr_sum)/sqrt(91);
    printf("%f\n",vrms);
}
