#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "matrix.h" 

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

void printrm(char *title, RMP vp) 
{
	int i, j;

	printf(title);
	for(i=0; i<vp->row; i++) {    
		for(j=0; j<vp->col; j++)
			printf("%5.2lf ", vp->data[i*vp->col + j]);
		printf("\n");
	}
}

main()
{
	double a[2][3]={{7.4,3.9,2.8},{2.7,11.0,6.5}};
	double b[3][2]={{9.7,-1.6},{1.8,6.9},{0.8,-5.6}};
	double value[2][2];
	RM     ma = { 2, 3, (double *)a }; 
	RM     mb = { 3, 2, (double *)b };
	RM     mv = { 0, 0, (double *)value};

	matrixmul(&ma, &mb, &mv); 
	printrm("\nThe result of matrix is:\n", &mv);
}
