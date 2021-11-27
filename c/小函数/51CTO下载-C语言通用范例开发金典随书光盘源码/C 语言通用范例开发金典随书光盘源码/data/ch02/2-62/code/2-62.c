#include "stdio.h"
#include "math.h"
#include "matrix.h"

void Householder_method(RMP ap, TRIMP tp, RMP qp)
{ 
	int    i,j,k,n,u;
    double h,f,g,h2;
	double *a,*b,*c,*q;
	n=ap->row;
	a=ap->data;
	tp->row=n;
	b=tp->bdata;
	c=tp->cdata;
	qp->row=qp->col=n;
	q=qp->data;

	for (i=0; i<n; i++)
		for (j=0; j<n; j++)	{ 
			u=i*n+j; q[u]=a[u];
		}
	for (i=n-1; i>0; i--)	{ 
		h=0.0;
		if (i>1)
			for (k=0; k<i; k++)	{ 
				u=i*n+k; h+=q[u]*q[u];
			}
		if (fabs(h)<0.0000001)	{ 
			c[i]=0.0;
			if (i==1) c[i]=q[i*n+i-1];
			b[i]=0.0;
		}
		else { 
			c[i]=sqrt(h);
			u=i*n+i-1;
			if (q[u]>0.0) c[i]=-c[i];
			h-=q[u]*c[i];
			q[u]-=c[i];
			f=0.0;
			for (j=0; j<i; j++) 	{ 
				q[j*n+i]=q[i*n+j]/h;
				g=0.0;
				for (k=0; k<=j; k++)
					g+=q[j*n+k]*q[i*n+k];
				if (j<i-1)
					for (k=j+1; k<i; k++)
						g+=q[k*n+j]*q[i*n+k];
				c[j]=g/h;
				f+=g*q[j*n+i];
			}
			h2=f/(h+h);
			for (j=0; j<=i-1; j++)	{ 
				f=q[i*n+j];
				g=c[j]-h2*f;
				c[j]=g;
				for (k=0; k<=j; k++) { 
					u=j*n+k;
					q[u]-=(f*c[k]+g*q[i*n+k]);
				}
			}
			b[i]=h;
		}
	}
	for (i=0; i<n-1; i++) 
		c[i]=c[i+1];
	c[n-1]=0.0;
	b[0]=0.0;
	for (i=0; i<n; i++)	{ 
		if ((b[i]!=0.0)&&(i>0))
		for (j=0; j<i; j++)	{ 
			g=0.0;
			for (k=0; k<i; k++)
				g+=q[i*n+k]*q[k*n+j];
			for (k=0; k<i; k++)	{ 
				u=k*n+j;
				q[u]-=g*q[k*n+i];
			}
		}
		u=i*n+i;
		b[i]=q[u]; q[u]=1.0;
		if (i>0)
			for (j=0; j<i; j++)	{ 
				q[i*n+j]=0.0; q[j*n+i]=0.0;
			}
	}
	return;
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
	double a[5][5]={{1.0,2.0,3.0,4.0,5.0},
					{2.0,6.0,7.0,8.0,9.0},	
					{3.0,7.0,10.0,11.0,12.0},
					{4.0,8.0,11.0,13.0,14.0},
					{5.0,9.0,12.0,14.0,15.0}};
	double b[5],c[5],q[5][5];
	RM ma = { 5, 5, (double*)a };
	RM mq = { 0, 0, (double*)q };
	TRIM  mt = { 0, (double*)b, (double*)c};  
	int i;

	Householder_method(&ma,&mt,&mq);
	printrm("Matrix A Is:\n", &ma);

	printrm("\nMatrix Q Is:\n", &mq);

	printf("\nMatrix B Is:\n");
	for (i=0; i<mt.row; i++)
		printf("%13.7e ",mt.bdata[i]);
	printf("\n\n");

	printf("Matrix C Is:\n");
	for (i=0; i<mt.row; i++)
		printf("%13.7e ",mt.cdata[i]);
	printf("\n\n");

}
