#include "stdio.h"
#include "math.h"
#include "interpolation.h"

double interpolation_three(INTEP ip)
{ 
	int num,i,j,k,m;
	double pio,z,s,*x,*y;

	num=ip->n;
	pio=ip->t; z=0.0; 
	x=ip->x; y=ip->y;
	if (num<1) {
		return(z);
	}
	else if (num==1) { 
		z=y[0]; return(z);
	}
	else if (num==2)	{
		z=(y[0]*(pio-x[1])-y[1]*(pio-x[0]))/(x[0]-x[1]);
		return(z);
	}
	if (pio<=x[1]) { 
		k=0; m=2;
	}
	else if (pio>=x[num-2]) { 
		k=num-3; m=num-1;
	}
	else{ 
		k=1; m=num;
		while (m-k!=1)	{ 
			i=(k+m)/2;	
			if (pio<x[i-1]) m=i;
			else            k=i;
		}
		k--; m--;
		if (fabs(pio-x[k])<fabs(pio-x[m])) k--;
		else m--;
	}
	z=0.0;
	for (i=k;i<=m;i++)	{ 
		s=1.0;	
		for (j=k;j<=m;j++)	
			if (j!=i) s*=(pio-x[j])/(x[i]-x[j]);
		z+=s*y[i];
	}
	return(z);
}

main()
{ 
	double x[5]={13.0,16.0,23.0,28.0,35.0};
	double y[5]={7.0,9.0,13.0,16.0,23.0};
	INTE   ia = {5, x, y, 14.0};
	INTE   ib = {5, x, y, 29.0};

	printf("\nx=%6.3f,   f(x)=%13.7e",  ia.t, interpolation_three(&ia));
	printf("\nx=%6.3f,   f(x)=%13.7e\n",ib.t, interpolation_three(&ib));
}
