 #include "math.h"
#include "stdio.h"
#include "stdlib.h"

#define  N  10
void smoothness(double *sourse,int n,double  *result)
{
    int i=0;
    double t=0;
    if(n<5)
    {
        for(i=0;i<n;i++)
        {
            result[i]=sourse[i];   //要求n大于5
            return;
        }
    }
        //开始进行平滑计算
        result[0] = (69.0*sourse[0]+4.0*sourse[1]-6.0*sourse[2]+4.0*sourse[3]-sourse[4])/70.0;
        t =  2.0*sourse[0] + 27.0*sourse[1] + 12.0*sourse[2] - 8.0*sourse[3];
        result[1] = (t+2.0*sourse[4])/35.0;
        for(i = 2 ;i< n-2;i++)
        {
            t = -3.0*sourse[i-2] + 12.0*sourse[i-1] + 17.0*sourse[i];
            result[i] = (t+12.0*sourse[i+1]-3.0*sourse[i+2])/35.0;
        }
        t = 2.0*sourse[n-5] - 8.0*sourse[n-4]+12.0*sourse[n-3];
        result[n-2] = (t+27.0*sourse[n-2]+2.0*sourse[n-1])/35.0;
        t = -sourse[n-5] + 4.0*sourse[n-4]-6.0*sourse[n-3];
        result[n-1] = (t+4.0*sourse[n-2]+69.0*sourse[n-1])/70.0;
        return;

}
int main(void)
{
    int i,j,n=N ;
    double source[N],result[N];
    for(i=0;i<n;i++)
    {
        source[i] = rand()%10;
    }
    printf("\n");
    for(i=0;i<=n/3;i++)
    {
        for(j=0;(j<=3)&&(i*4+j<n);j++)
        {
            printf("%5.2lf;",source[4*i+j]);
        }
        printf("\n");
    }
    smoothness(source,n,result);

    for(i=0;i<=n/3;i++)
    {
        for(j=0;(j<=3)&&(4*i+j<n);j++)
        {
            printf("%5.2lf;",result[i]);
        }
        printf("\n");
    }

}
