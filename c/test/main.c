#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void float2char(float slope,char *buffer ,int n) ;

const char SampleChannel[20] = "skflks";
int main()
{
    float sampleVoltage  = 123;
   // printf("Hello world!\n");
    char voltageString[10] = "456";
    float2char(sampleVoltage,voltageString,7);
    strcat(voltageString,SampleChannel);
    printf(voltageString);
    return 0;
}

void float2char(float slope,char *buffer ,int n)  //�����������洢���ַ����飬�ַ�����ĳ���
{
    int temp,i,j;
    //char* buffer = "nflshglshdg";
    if(slope>=0)//�ж��Ƿ����0
        buffer[0] = '+';
    else
    {
        buffer[0] = '-';
        slope = -slope;
    }
    temp = (int)slope;//ȡ��������

    if(temp == 0)
    {
        i = 1;
    }
    else
    {
        for(i=0;temp!=0;i++)//�����������ֵ�λ��
            {
                    temp /=10;
            }
    }
    temp =(int)slope;
    for(j=i;j>0;j--)//����������ת�����ַ�����
    {
        buffer[j] = temp%10+'0';
        temp /=10;
    }
    buffer[i+1] = '.';
    slope -=(int)slope;
    for(i=i+2;i<n-1;i++)//��С������ת�����ַ�����
    {
        slope*=10;
        buffer[i]=(int)slope+'0';
        slope-=(int)slope;
    }
   // buffer[n-2] = '\r';
    buffer[n-1] = '\0';

       // return buffer;
}






