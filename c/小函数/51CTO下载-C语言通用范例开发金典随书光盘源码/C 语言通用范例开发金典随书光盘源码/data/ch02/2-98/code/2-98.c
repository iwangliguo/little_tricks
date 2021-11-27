#include "stdio.h"
#include "interpolation.h"

double interpolation_hermite(HINTEP hp)
{
	int num,i,j;
	double *x,*y,*dy,pio,z,p,q,s;

	num=hp->n;
	x=hp->x; y=hp->y; 
	dy=hp->dy;
	pio=hp->t; z=0.0;
	for (i=1;i<=num;i++)	{ 
		s=1.0;	
		for (j=1;j<=num;j++)	
			if (j!=i) s*=(pio-x[j-1])/(x[i-1]-x[j-1]);	
		s=s*s;	
		p=0.0;	
		for (j=1;j<=num;j++)	
			if (j!=i) p+=1.0/(x[i-1]-x[j-1]);	
		q=y[i-1]+(pio-x[i-1])*(dy[i-1]-2.0*y[i-1]*p);	
		z+=q*s;
	}
	return(z);
}

main()
{ 
	double x[10]={3.0,5.0,8.0,13.0,17.0,25.0,27.0,29.0,31.0,35.0};
	double y[10]={7.0,10.0,11.0,17.0,23.0,18.0,13.0,6.0,3.0,1.0};
	double dy[10];
	int    i;
	HINTE  ha = {10, x, y, dy, 19.0};

	for (i=0;i<=9;i++) {
		dy[i]=-y[i];
	}
	printf("\npio=%6.3f,   z=%e\n\n", ha.t, interpolation_hermite(&ha));
}
