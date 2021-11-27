#include "math.h"
#include<stdio.h>

#define  N  101    //���ݵ����
#define  M  6     //����ʽ����

typedef struct least_squares_fitting
{
    /* data */
    int n;
    int m;
    double *x;
    double *y;
    double *coe;
}INTEP;

void chebyshev_fitting(INTEP cp)
{
    int n=0,m=0,m1=0,i=0,j=0,l=0,ii=0,k=0,im=0,ix[21];
    double h[21],ha,hh,y1,y2,h1,h2,d,hm,*x,*y,*coe;

    n = cp.n;
    m = cp.m;
    x = cp.x;
    y = cp.y;
    coe = cp.coe;
    for(i=0;i<=m;i++)
    {
        coe[i] = 0.0;

    }
    if(m>=n) m = n-1;
    if(m>=20) m = 19;

    m1 = m+1;
    ha = 0.0;
    ix[0] = 0;
    ix[m] = n -1;
    l = (n-1)/m;
    j = l;
    for(i=1;i<m;i++)
    {
        ix[i] = j;
        j++;
    }
    while(1)
    {
        hh =1.0;
        for(i=0;i<=m;i++)
        {
            coe[i] = y[ix[i]];
            h[i] = -hh;
            hh = -hh;
        }
        for(j=1;j<=m;j++)
        {
            ii = m1;
            y2 = coe[ii-1];
            h2 = h[ii-1];
            for(i=j;i<=m;i++)
            {
                d = x[ix[ii-1]]-x[ix[m1-i-1]];
                y1 = coe[m-i+j-1];
                h1 = h[m-i+j-1];
                coe[ii-1] = (y2-y1)/d;
                h[ii-1] = (h2-h1)/d;
                ii = m-i+j;
                y2 = y1;
                h2 = h1;
            }
        }
    hh = -coe[m]/h[m];
    for(i=0;i<=m;i++)
    {
        coe[i] += h[i]*hh;
    }

    for(j=1;j<m;j++)
    {
        ii = m-j;
        d =x[ix[ii-1]];
        y2 = coe[ii-1];
        for(k=m1-j;k<=m;k++)
        {
            y1 = coe[k-1];
            coe[ii-1] = y2 - d*y1;
            y2 = y1;
            ii =k;
        }
    }
    hm = fabs(hh);
    if(hm<=ha)
    {
        coe[m] = -hm;
        return;
    }

    coe[m] = hm;
    ha = hm;
    im = ix[0];
    h1 = hh;
    j=0;
    for(i=0;i<n;i++)
    {
        if(i==ix[j])
        {
            if(j<m)  j++;
        }
        else
        {
            h2 = coe[m-1];
            for(k=m-2;k>=0;k--)
            {
                 h2 *=x[i];
                 h2 +=coe[k];
            }

            h2 += -y[i];
            if(fabs(h2)>hm)
            {
                hm = fabs(h2);
                h1  = h2;
                im =i;
            }

        }
    }

     if(im ==ix[0])   return;
     i=0;
     l=1;
     while(l)
     {
         l=0;
         if(im>=ix[i])
         {
             i++;
             if(i<=m)  l=1;
         }

     }

     if(i>m) i = m;

     if(i == (i/2)*2)   h2 = -hh;
     else h2 = hh;

     if(h1*h2>=0.0)  ix[i] = im;
     else{
         if(im<ix[0])
         {
             j=m;
             while(j>0)
             {
                 ix[j] = ix[j-1];
                 j--;
             }

             ix[0] = im;
         }
        else
        {
            if(im>ix[m])
            {
                j=0;
                while(j<m)
                {
                    ix[j] = ix[j+1];
                    j++;
                }

                ix[m] = im;
            }
            else
            {
                ix[i-1] = im;
            }

        }
     }
   }
}


int main()
{
    int i=0;
    double x[N],y[N],coe[M+1];

    INTEP ca = {N,M,x,y,coe};

    for(i=0;i<N;i++)
    {
        x[i] = -3+0.05*i;
        y[i] = atan(x[i]);
    }

    chebyshev_fitting(ca);
    printf("\n");
    for(i=0;i<M;i++)
    {
        printf("coe(%2d) = %e\n",i,coe[i]);
    }

    printf("\n");

    printf("MAX(p-f) = %e\n",coe[6]);

    printf("\n");

}
