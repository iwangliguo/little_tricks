#include "stdio.h"
#include "math.h"
#include "interpolation.h"

double interpolation_continued(INTEP ip)
{
	int num,i,j,k,m,l;
	double pio,z,h,b[8],*x,*y;

	num=ip->n;
	pio=ip->t; z=0.0; 
	x=ip->x; y=ip->y;
	if (num<1) 
		return(z);
	if (num==1) { 
		z=y[0]; return(z);
	}
	if (num<=8) { 
		k=0; m=num;
	}
	else if (pio<x[4]) { 
		k=0; m=8;
	}
	else if (pio>x[num-5]) { 
		k=num-8; m=8;
	}
	else{ 
		k=1; j=num;
		while (j-k!=1)	{ 
			i=(k+j)/2;
			if (pio<x[i-1]) j=i;
			else k=i;
		}
		k=k-4; m=8;
	}
	b[0]=y[k];
	for (i=2;i<=m;i++){ 
		h=y[i+k-1]; l=0; j=1;
		while ((l==0)&&(j<i)){ 
			if (fabs(h-b[j-1])<0.0000001) l=1;
			else h=(x[i+k-1]-x[j+k-1])/(h-b[j-1]);
			j++;
		}
		b[i-1] = l!=0 ? 1.0e+35 : h;
	}
	z=b[m-1];
	for (i=m-1;i>0;i--) 
		z=b[i-1]+(pio-x[i+k-1])/z;
	return(z);
}

main()
{ 
	double x[10]={3.0,5.0,8.0,13.0,17.0,25.0,27.0,29.0,31.0,35.0};
	double y[10]={7.0,10.0,11.0,17.0,23.0,18.0,13.0,6.0,3.0,1.0};
	INTE   ia = {10, x, y, 14.0};
	INTE   ib = {10, x, y, 29.0};

	printf("\nx=%6.3f,   f(x)=%e",  ia.t, interpolation_continued(&ia));
	printf("\nx=%6.3f,   f(x)=%e\n",ib.t, interpolation_continued(&ib));
}
