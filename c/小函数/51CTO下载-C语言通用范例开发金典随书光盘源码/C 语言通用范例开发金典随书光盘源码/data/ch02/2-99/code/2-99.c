#include "stdio.h"
#include "math.h"
#include "interpolation.h"

double interpolation_aitken(AINTEP ap)
{ 
	int num,i,j,k,m,l;
    double pio, eps, *x, *y, z,xx[10],yy[10];

    num=ap->n;
	pio=ap->t; eps=ap->eps;
	x=ap->x; y=ap->y;
	z=0.0;
    if (num<1) return(z);
    if (num==1) { 
		z=y[0]; return(z);
	}
    m=10; /* m: 指定选取最靠近插值点t的m个结点 m<=n */
    if (m>num) m=num;
    if (pio<=x[0]){
		k=1;
	}
    else if (pio>=x[num-1]) {
		k=num;
	}
    else { 
		k=1; j=num;
        while ((k-j!=1)&&(k-j!=-1)) { 
			l=(k+j)/2;
            if (pio<x[l-1]) j=l;
            else k=l;
		}
        if (fabs(pio-x[l-1])>fabs(pio-x[j-1])) k=j;    
	}
    j=1; l=0;
    for (i=1;i<=m;i++) { 
		k+=j*l;
        if ((k<1)||(k>num)) { 
			l++; j=-j; k+=j*l;
		}
        xx[i-1]=x[k-1]; 
		yy[i-1]=y[k-1];
        l++; j=-j;      
	}
    i=0;
    do { 
		i++; z=yy[i];
        for (j=0;j<i;j++)
			z=yy[j]+(pio-xx[j])*(yy[j]-z)/(xx[j]-xx[i]);
        yy[i]=z;
	}
    while ((i!=m-1)&&(fabs(yy[i]-yy[i-1])>eps));
    return(z);
}

main()
{ 
	double x[11]={3.0,5.0,8.0,13.0,17.0,25.0,27.0,29.0,31.0,35.0,39.0};
    double y[11]={7.0,10.0,11.0,17.0,23.0,18.0,13.0,6.0,3.0,1.0,0.0};
	AINTE  aa = {11, x, y, 28.0, 1.0e-6 };
	AINTE  ab = {11, x, y, 34.0, 1.0e-6 };

    printf("\n");
    printf("pio=%6.3f,   z=%e\n", aa.t, interpolation_aitken(&aa));
    printf("pio=%6.3f,   z=%e\n", ab.t, interpolation_aitken(&ab));
    printf("\n");
}
