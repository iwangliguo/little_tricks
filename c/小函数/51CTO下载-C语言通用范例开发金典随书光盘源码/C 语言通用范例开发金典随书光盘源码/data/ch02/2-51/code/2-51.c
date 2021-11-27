#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "matrix.h"

CNUM cpmul(CNUMP a, CNUMP b) /*复数乘法*/
{
   CNUM value ;
   value.rpart=a->rpart * b->rpart -a->ipart * b->ipart;
   value.ipart=a->rpart * b->ipart +a->ipart * b->rpart;
   return  value;
}

CNUM cpadd(CNUMP a,CNUMP b) /*复数加法*/
{
   CNUM value ;
   value.rpart=a->rpart + b->rpart ;
   value.ipart=a->ipart + b->ipart ;
   return  value;
}

void cpmatrixmul(CMP ap,CMP bp,CMP vp)
{ 
	int i,j,l;
	CNUM  temp;
	CNUMP data;

	if(ap->col != bp->row) {
		printf("error");
		return;
	}

	vp->row = ap->row;
	vp->col = bp->col;
	for(i=0; i<vp->row; i++)
		for(j=0; j<vp->col; j++) { 
			data = vp->data + (i * vp->col + j);
			data->rpart = 0.0, data->ipart = 0.0;
			for (l=0; l<ap->col; l++) {
				temp = cpmul(ap->data+(i*ap->col+l), 
					bp->data+(l*bp->col+j));
				*data = cpadd(data, &temp);
			}
		}
}

void printcm(char *title, CMP vp) {
	int i, j;
	CNUMP data;

	printf(title);
	for(i=0; i<vp->row; i++)
	{    
		for(j=0; j<vp->col; j++) {
			data = vp->data + i*vp->col + j;
			printf("%5.2lf",data->rpart);
			if(data->ipart>=0.0)  printf("+%5.2lfi  ",data->ipart);
			else                  printf(" %5.2lfi  ",data->ipart);
		}
		printf("\n");
	}
}

main()
{
	CNUM a[3][3]={{{7.0,-2.0},{-3.0,-1.0},{3.4,2.7}},
					{{-4.3,-1.2},{-5.0,-7.0},{9.0,-1.0}},
					{{9.0,-3.4},{5.0,-2.0},{5.2,2.7}}};
	CNUM b[3][2]={{{0.3,0.0},{0.0,-4.3}},
					{{2.4,2.7},{9.0,1.0}},
					{{4.3,-2.3},{3.4,2.6}}};
	CNUM value[3][2]; 
	CM   ma = {3, 3, (CNUMP)a};
	CM   mb = {3, 2, (CNUMP)b};
	CM   mv = {0, 0, (CNUMP)value};

	cpmatrixmul((CMP)&ma,(CMP)&mb,(CMP)&mv);

	printcm("\nThe result of matrix is:\n", &mv);
}
