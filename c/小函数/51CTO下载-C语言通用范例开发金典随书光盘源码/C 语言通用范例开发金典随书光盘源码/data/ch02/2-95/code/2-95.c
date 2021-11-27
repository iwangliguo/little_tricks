#include "stdio.h"
//#include "interpolation.h"

typedef struct 
{
	/* data */
	int n;
	double *x;
	double *y;
	double t;
}INTEP;

double interpolation_total(INTEP  ip )
{ 
	int num,i,j,k,m;
	double pio,z,s,*x,*y;

	num=ip.n; 
	pio=ip.t; z=0.0; 
	x=ip.x; y=ip.y;
	if (num<1) {
		return(z);
	}
	else if (num==1) { 
		z=y[0];return(z);
	}
	else if (num==2)	{ 
		z=(y[0]*(pio-x[1])-y[1]*(pio-x[0]))/(x[0]-x[1]);
	return(z);
	}

	i=0;
	while ((x[i]<pio)&&(i<num))  {
		i++;
	}
	k=i-4;
	if (k<0) k=0;
	m=i+3;
	if (m>num-1) m=num-1;
	for (i=k;i<=m;i++)	{ 
		s=1.0;
		for (j=k;j<=m;j++)	
			if (j!=i) s*=(pio-x[j])/(x[i]-x[j]);
		z+=s*y[i];
	}
	return(z);
}
  
int main()
{ 
    double x[10]={0.30,0.40,0.45,0.55,0.60,0.70,0.75,0.85,0.95,1.00};
    double y[10]={0.90,0.85,0.75,0.65,0.60,0.55,0.50,0.40,0.35,0.30};
	INTEP  ia = {10, x, y, 0.65};

    printf("\npio=%6.3lf,   z=%e\n\n", ia.t, interpolation_total(ia));
}

