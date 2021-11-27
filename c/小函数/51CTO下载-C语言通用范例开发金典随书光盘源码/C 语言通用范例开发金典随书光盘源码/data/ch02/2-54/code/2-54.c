#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "matrix.h"
  
int symmetric_positive_definite_matrix(RMP ap)
{ 
	int      i,j,k,m;
    double   w,g,*b;
	int      n = ap->row;
	double  *data = ap->data;

	b=malloc(n*sizeof(double));
	for (k=0; k<n; k++) { 
		w=data[0];
		if (fabs(w)<0.0000001) { 
			free(b); 
			printf("fail\n"); 
			return -1;
		}
		m=n-k-1;
		for (i=1; i<n; i++) { 
			g=data[i*n]; b[i]=g/w;
			if (i<=m) b[i]=-b[i];
			for (j=1; j<=i; j++)
				data[(i-1)*n+j-1]=data[i*n+j]+g*b[j];
		}
        data[n*n-1]=1.0/w;
        for (i=1; i<n; i++)
			data[(n-1)*n+i-1]=b[i];
	}
	for (i=0; i<n-1; i++)    
		for (j=i+1; j<n; j++)
			data[i*n+j]=data[j*n+i];
    free(b);/*释放动态分配的内存*/
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
			printf("%12.6e ", vp->data[i*vp->col + j]);
		printf("\n");
	}
}

main()
{ 
    double a[3][3] = {  {2.0,2.0,-2.0}, 
						{2.0,5.0,-4.0},	
						{-2.0,-4.0,5.0} };
    double b[3][3],c[3][3];
	RM     ma = {3, 3, (double *)a};
	RM     mb = {0, 0, (double *)b};
	RM     mc = {0, 0, (double *)c};

	printrm("Matrix A Is:\n", &ma);

	matrixcpy(&ma, &mb);
	if(0 == symmetric_positive_definite_matrix(&mb)) {
		printrm("\nMatrix A- Is:\n", &mb);

		matrixmul(&ma,&mb, &mc);
		printrm("\nMatrix AA- Is:\n", &mc);
	}
}
