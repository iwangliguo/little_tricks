#include <stdio.h>
#include <stdlib.h>
#include <math.h>
float GetRmsValue(float *table,int size);

#define SamplePoint  16
int FunIndex = 2;
float Vtotal = 0;
float fftTable[SamplePoint]= {0.0,0.0,4.0,0.0,2.0,0.0,1.0,0.0,0.0,1.0,0.0,2.0,0.0,4.0,0.0,0.0};

int main()
{

    float *p ;
    int size  = ((SamplePoint/2)-1)/FunIndex;
    p = (float *)malloc(sizeof(float)*size);

    int i = 0;
    for(i =0;i<size;i++)
    {
        p[i] = fftTable[(i+1)*FunIndex];

    }

    Vtotal = GetRmsValue(p,size);

    printf("%f\n",Vtotal);
    return 0;
}


float GetRmsValue(float *table,int size)
{
    float vsqr_sum = 0;
    float vrms = 0;
    int i ;
    for( i =0 ;i < size;i++)
    {
        vsqr_sum    = vsqr_sum +  table[i]*table[i];
    }
    vrms  = sqrt(vsqr_sum)/sqrt(size);
    return vrms;
}

