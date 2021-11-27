#include "stdlib.h"
#include "math.h"
#include "stdio.h"
#include "matrix.h"

int matrix_inverse(RMP ap)
{ 
	int    n = ap->row;
	int    i,j,k,m,l;
	int    *is,*js;
	double *data = ap->data;
	double d,p;

	is=malloc(n*sizeof(int));
	js=malloc(n*sizeof(int));
	for (k=0; k<n; k++)	{ 
		for (i=k,d=0.0; i<n; i++)	
			for (j=k; j<n; j++)	{ 
				if ((p=fabs(data[i*n+j]))>d) {	
					d=p; is[k]=i; js[k]=j;
				}
				if (d == 0.0)	{ 
					free(is);free(js);	
					printf("not inverse.\n");
					return -1;
				}
			}
		if (is[k]!=k)	
			for (j=0; j<n; j++)	{ 
				m=k*n+j; l=is[k]*n+j;	
				p=data[m]; data[m]=data[l]; data[l]=p;	
			}	
		if (js[k]!=k)	
			for (i=0; i<n; i++)	{ 
				m=i*n+k; l=i*n+js[k];	
				p=data[m]; data[m]=data[l]; data[l]=p;	
			}
		l=k*n+k;
		data[l]=1.0/data[l];
		for (j=0; j<n; j++)	
			if (j!=k)	{ 
				m=k*n+j; 
				data[m]*=data[l];
			}
		for (i=0; i<n; i++)	
			if (i!=k)	
				for (j=0; j<n; j++)	
					if (j!=k)	{ 
						data[i*n+j]-=data[i*n+k]*data[k*n+j];	
					}
		for (i=0; i<n; i++)	
			if (i!=k)	{ 
				data[i*n+k]*=-data[l];
			}
	}
	for (k=n-1; k>=0; k--)	{ 
		if (js[k]!=k)	
			for (j=0; j<n; j++)	{ 
				m=k*n+j; l=js[k]*n+j;	
				p=data[m]; data[m]=data[l]; data[l]=p;
			}
		if (is[k]!=k)	
			for (i=0; i<n; i++)	{ 
				m=i*n+k; l=i*n+is[k];	
				p=data[m]; data[m]=data[l]; data[l]=p;	
			}
	}

	free(is); free(js); /*释放动态分配的内存*/
	return 0;
}

void matrixmul(RMP ap,RMP bp,RMP vp)
{ 
	int i,j,l;
	double *data;

	if(ap->col != bp->row) {
		printf("error");
		return;
	}

	vp->row = ap->row;
	vp->col = bp->col;
	for (i=0; i<vp->row; i++)
		for (j=0; j<vp->col; j++){ 
			data = vp->data + (i * vp->col + j);
			*data = 0.0;
			for (l=0; l<ap->col; l++)
				*data += ap->data[i*ap->col + l] * bp->data[l*bp->col + j];
		}
}

void matrixcpy(RMP s,RMP t)
{
	int i, j, u;

	t->row = s->row;
	t->col = s->col;
	for(i=0; i<t->row; i++)
		for(j=0; j<t->col; j++) {
			u = i * t->col + j;
			t->data[u] = s->data[u];
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
	double a[4][4]={{1,2,3,4},
					{2,3,1,2},
					{1,1,1,-1},
					{1,0,-2,-6}};
	double b[4][4],c[4][4];
	RM     ma = {4, 4, (double *)a};
	RM     mb = {0, 0, (double *)b};
	RM     mc = {0, 0, (double *)c};
	
	printrm("Matrix A Is:\n", &ma);

	matrixcpy(&ma, &mb); /* ma 复制到 mb */
	if(0 == matrix_inverse(&mb)) {
		printrm("\nMatrix A- Is:\n", &mb);

		matrixmul(&ma,&mb,&mc);
		printrm("\nMatrix AA- Is:\n", &mc);
	}
}
