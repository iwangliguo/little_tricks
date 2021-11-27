#include "math.h"
#include "stdio.h"

void extremum(double x[],double eps,int k,int js[],void  (*f)())
{ 
	int    i,j,done=0;
	double t,h1,h2,dx,y[10],b[10],z[2];
	
	js[0]=0; h2=0.0;
	while (!done && js[0]<k)	{ 
		for (j=0; j<=7; j++){ 
			if (j<=2) t=x[0]+0.01*j;
			else      t=h2;
			(*f)(t,z);
			if (fabs(z[1])<eps)	{ 
				done=1; break;
			}
			else{ 
				h1=z[1]; h2=t;
				if (j==0) { 
					y[0]=h1; b[0]=h2;
				}
				else{ 
					y[j]=h1;
					for(i=0; i<j; i++){
						if (fabs(h2-b[i])<eps) {
							b[j]=1.0e+35; break;
						}
						b[j]=h2=(h1-y[i])/(h2-b[i]);
					}
					h2=0.0;
					for (i=j-1; i>=0; i--)
						h2=-y[i]/(b[i+1]+h2);
					h2=h2+b[0];
				}
			}
		}
		x[0]=h2;
		js[0]++;
	}
	t=x[0];
	(*f)(t,z); x[1]=z[0];
	if (fabs(x[0])<=1.0) dx=1.0e-05;
	else                 dx=fabs(x[0]*1.0e-05);
	t=x[0]-dx;
	(*f)(t,z); h1=z[0];
	t=x[0]+dx;
	(*f)(t,z); h2=z[0];
	if ((h1+h2-2.0*x[1])<=0.0) js[1]=1;
	else                       js[1]=-1;
}

void fx(double x,double y[])
{ 
	y[0]=(x-1.0)*(2.0*x+1.3);
	y[1]=4.0*x-0.7;
}

main()
{ 
	int    js[2];
	int    k=10;
	double eps=1.0e-10;
	double x[2]={1.0};

	extremum(x,eps,k,js,fx);
	printf("\njs[0]=%d",js[0]);
	if (js[1]<0) printf("\nMIN:  ");
	else         printf("\nMAX:  ");
	printf("x=%5.3lf  f(x)=%5.3lf ",x[0],x[1]);
}
