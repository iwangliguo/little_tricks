#include "stdio.h"
#include "math.h"
#include "matrix.h"

void trans_hessenbreg(RMP ap)
{ 
	int    i,j,k,n,u,v;
    double d,t,*a;
	n = ap->row;
	a = ap->data;
    for (k=1; k<n-1; k++)
      { d=0.0;
        for (j=k; j<n; j++)
          { u=j*n+k-1; t=a[u];
            if (fabs(t)>fabs(d))
              { d=t; i=j;}
          }
        if (fabs(d)>0.0000001)
          { if (i!=k)
              { for (j=k-1; j<n; j++)
                  { u=i*n+j; v=k*n+j;
                    t=a[u]; a[u]=a[v]; a[v]=t;
                  }
                for (j=0; j<n; j++)
                  { u=j*n+i; v=j*n+k;
                    t=a[u]; a[u]=a[v]; a[v]=t;
                  }
              }
            for (i=k+1; i<n; i++)
              { u=i*n+k-1; t=a[u]/d; a[u]=0.0;
                for (j=k; j<n; j++)
                  { v=i*n+j;
                    a[v] -= t*a[k*n+j];
                  }
                for (j=0; j<n; j++)
                  { v=j*n+k;
                    a[v] += t*a[j*n+i];
                  }
              }
          }
      }
}

void printrm(char *title, RMP vp) 
{
	int i, j;

	printf(title);
	for(i=0; i<vp->row; i++) {    
		for(j=0; j<vp->col; j++)
			printf("%13.7e ", vp->data[i*vp->col + j]);
		printf("\n");
	}
}

main()
{
	double a[5][5]={{1.0,7.0,4.0,3.0,5.0},
					{2.0,9.0,6.0,23.0,8.0},
					{11.0,13.0,2.0,12.0,7.0},
					{6.0,8.0,19.0,11.0,2.0},
					{15.0,21.0,6.0,9.0,17.0}};
	RM ma = {5, 5, (double*)a};
	trans_hessenbreg(&ma);
	printrm("Matrix A Is:\n", &ma);
}
