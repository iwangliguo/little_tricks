#include "stdio.h"

static double ga[11]={ 0.0000677106, -0.0003442342, 0.0015397681,
	-0.0024467480, 0.0109736958, -0.0002109075, 0.0742379071,
	0.0815782188, 0.4118402518, 0.4227843370, 1.0};

double gamma(double x)
{ 
	double y,t,s,u;
	int    i;
	if (x<=0.0)	{ 
		printf("the parameter x<=0!\n");
		return(-1.0);
	}
	y=x;
	if (y<=1.0) { 
		t=1.0/(y*(y+1.0)); y+=2.0;
	}
	else if (y<=2.0) { 
		t=1.0/y; y+=1.0;
	}
	else if (y<=3.0) {
		t=1.0;
	}
	else { 
		t=1.0;
		do  { 
			y-=1.0; t=t*y;
		} while (y>3.0);
	}
	s=ga[0]; u=y-2.0;
	for (i=1; i<11; i++)
		s=s*u+ga[i];
	return(s*t);
}


main()
{ 
	int    i;
	double x;

	for (i=1; i<5; i++){ 
		x=0.5*i; 
		printf("\n gamma(%4.2f)=%2.5f",x, gamma(x));
	}

}
