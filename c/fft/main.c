
/* 函数说明：
p：存放初始输入的n个采样点的实部和虚部；
n：输入的点数；
k：k和n的关系满足2的k次方为n
f：输出点的实部和虚部；
l： 当l=0时执行傅里叶变换，l=1时执行逆傅里叶变换
il：当il=0时不会计算模和幅角，当il=1时会计算模值和幅角 */
#include <stdio.h>
#include <stdlib.h>
#include "math.h"

#define PI 3.1415926
typedef struct complex
{
    double rpart;
    double ipart;
}cnumber;

//fft计算离散傅里叶变换
void fft(cnumber p[],int n,int k,cnumber f[],int l,int il)
{
    int it,m,is,i,j,nv,l0;
    double t,q,s,vr,vi;
    cnumber podd;

    for(it=0;it<n;it++)
    {
        m=it;is=0;
        for(i=0;i<k;i++)
        {
            j = m/2;
            is = 2*is+(m-2*j);
            m=j;
        }
    f[it].rpart = p[is].rpart;
    f[it].ipart = p[is].ipart;
    }
    p[0].rpart = 1.0;
    p[0].ipart = 0.0;
    t = 2*PI/(1.0*n);
    p[1].rpart = cos(t);
    p[1].ipart = -sin(t);
    if(l!=0) p[1].ipart = -p[1].ipart;
    for(i = 2;i < n;i++)
    {
        t = p[i-1].rpart*p[1].rpart;
        q = p[i-1].ipart*p[1].ipart;
        s = (p[i-1].rpart+p[i-1].ipart)*(p[1].rpart+p[1].ipart);
        p[i].rpart = t - q;
        p[i].ipart = s - t - q;

    }
    for(it=0;it<n-1;it +=2)
    {
        vr=f[it].rpart;
        vi=f[it].ipart;
        f[it].rpart = vr + f[it+1].rpart;
        f[it].ipart = vi + f[it+1].ipart;
        f[it+1].rpart = vr - f[it+1].rpart;
        f[it+1].ipart = vi - f[it+1].ipart;
    }

    m = n/2; nv = 2;
    for(l0 = k-2;l0>=0;l0--)
    {
        m = m/2;
        nv = nv*2;
        for(it=0;it<=(m-1)*nv;it+=nv)
        {
            for(j=0;j<=(nv/2)-1;j++)
            {
                t = p[m*j].rpart*f[it+j+nv/2].rpart;
                q = p[m*j].ipart*f[it+j+nv/2].ipart;
                s = p[m*j].rpart+p[m*j].ipart;
                s = s*(f[it+j+nv/2].rpart+f[it+j+nv/2].ipart);
                podd.rpart = t - q;
                podd.ipart = s - t - q;
                f[it+j+nv/2].rpart = f[it+j].rpart - podd.rpart;
                f[it+j+nv/2].ipart = f[it+j].ipart - podd.ipart;
                f[it+j].rpart = f[it+j].rpart+  podd.rpart;
                f[it+j].ipart = f[it+j].ipart+  podd.ipart;
            }
        }
    }

    if(l!=0)
    {
        for(i=0;i<n;i++)
        {
            f[i].rpart /= n;
            f[i].ipart /= n ;

        }
    }

    if(il!=0)
    {
        for(i=0;i<n;i++)
        {
            p[i].rpart = sqrt(f[i].rpart*f[i].rpart+f[i].ipart*f[i].ipart);
            if(fabs(f[i].rpart)<0.000001*fabs(f[i].ipart))
            {
                if((f[i].ipart*f[i].rpart)>0)  p[i].ipart = 90.0;
                else p[i].ipart = -90.0;
            }
            else
            {
                p[i].ipart = atan(f[i].ipart/f[i].rpart)*360.0/(2*PI);
            }
        }

    }
}
int main()
{
    int i,j;
    cnumber p[64],f[64];

    for(i=0;i<64;i++)
    {
        p[i].rpart = exp(-0.1*(i+0.5));
        p[i].ipart = 0.0;

    }
    printf("\n");

    for(i=0;i<8;i++)
    {
        for(j=0;j<8;j++)
        {
            printf("%2.5lf;",p[8*i+j].rpart);
        }
        printf("\n");
    }
     printf("\n");
     fft(p,64,6,f,0,1);
//     printf("\n");
//     for(i=0;i<8;i++)
//     {
//        for(j=0;j<8;j++)
//        {
//            printf("%2.5lf;",p[8*i+j].rpart);
//        }
//        printf("\n");
//     }

    for(i=0;i<16;i++)
    {
        for(j=0;j<4;j++)
        {
            printf("%2.5lf",f[4*i+j].rpart);
            if(f[4*i+j].ipart<0)
            {
               printf("%2.5lfi;",f[4*i+j].ipart);
            }
            else
            {
               printf("+%2.5lfi;",f[4*i+j].ipart);
            }
        }
        printf("\n");
    }
    return 0;
}
