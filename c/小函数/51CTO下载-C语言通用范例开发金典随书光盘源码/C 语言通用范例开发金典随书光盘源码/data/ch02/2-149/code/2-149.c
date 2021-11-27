#include "math.h"
#include "stdio.h"

void  smoothness(double source[],int n,double  result[])
{
	int    i;
	double t;

	if (n<5){ 
		for (i=0; i<n; i++) result[i]=source[i];
		return;
	}

	result[0]=(69.0*source[0]+4.0*source[1]-6.0*source[2]+4.0*source[3]-source[4])/70.0;
	t=2.0*source[0]+27.0*source[1]+12.0*source[2]-8.0*source[3];
	result[1]=(t+2.0*source[4])/35.0;
	for (i=2; i<n-2; i++){
		t=-3.0*source[i-2]+12.0*source[i-1]+17.0*source[i];
		result[i]=(t+12.0*source[i+1]-3.0*source[i+2])/35.0;
	}
	t=2.0*source[n-5]-8.0*source[n-4]+12.0*source[n-3];
	result[n-2]=(t+27.0*source[n-2]+2.0*source[n-1])/35.0;
	t=-source[n-5]+4.0*source[n-4]-6.0*source[n-3];
	result[n-1]=(t+4.0*source[n-2]+69.0*source[n-1])/70.0;
	return;
}

main()
{
	int    i,j,n=9;
	double source[9],result[9];

	for(i=0;i<n;i++)
		source[i]=rand()%10;

	printf("\n");
	for (i=0; i<=n/3; i++){  
		for(j=0;j<=3&&i*4+j<n;j++)
			printf("%5.2lf;",source[i*4+j]);
	printf("\n");
	}
	smoothness(source,n,result);
	for (i=0; i<=n/3; i++){  
		for(j=0;j<=3&&i*4+j<n;j++)
			printf("%5.2lf;",result[i]);
	printf("\n");
	}
}
