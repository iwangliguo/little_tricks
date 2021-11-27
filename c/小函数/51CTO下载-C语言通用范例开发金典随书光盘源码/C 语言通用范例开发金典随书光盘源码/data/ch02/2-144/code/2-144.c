#include "math.h"
#include "stdio.h"

void nextremum(double x[],int n,double eps,int k,int js[],double  (*ff)())
{ 
	double y[10],b[10],z,t,h1,h2,f,dx;
	int    i,j,m,l;
	int    done=0;
	
	js[0]=0; h2=0.0;	
	while (!done && js[0]<k)	{ 
		t=0.0; 
		for (i=1; i<=n; i++){ 
			f=(*ff)(x,i);
			t=t+fabs(f);
		}
		if (t<eps) done=1;
		else{ 
			for (i=0; i<n; i++){ 
				m=0;
				while (m++<5){ 
					j=0; t=x[i];
					while (j<=7){ 
						if (j<=2) z=t+j*0.01;
						else z=h2;
						x[i]=z;
						f=(*ff)(x,i+1);
						if (fabs(f)< eps){ 
							m=5; break;
						}
						else { 
							h1=f; h2=z;
							if (j==0){ 
								y[0]=h1; b[0]=h2;
							}
							else { 
								y[j]=h1; 
								for(l=0; l<j; l++){
									if (fabs(h2-b[l])<eps) {
										b[j]=1.0e+35; break;
									}
									b[j]=h2=(h1-y[l])/(h2-b[l]);
								}
								h2=0.0;
								for (l=j-1; l>=0; l--)
									h2=-y[l]/(b[l+1]+h2);
								h2=h2+b[0];
							}
							j=j+1;
						}
					}
					x[i]=h2; 
				}
				x[i]=z;
			}
			js[0]++;
		}
	}
	
	f=(*ff)(x,0); x[n]=f;
	dx=0.00001; t=x[0];
	x[0]=t+dx; h1=(*ff)(x,0);
	x[0]=t-dx; h2=(*ff)(x,0);
	x[0]=t;
	t=h1+h2-2.0*f;
	if (t>0.0) js[1]=-1;
	else       js[1]=1;
	j=1;
	do {
		j++;
		dx=0.00001;
		t=x[j-1];
		x[j-1]=t+dx; h2=(*ff)(x,0);
		x[j-1]=t-dx; h1=(*ff)(x,0);
		x[j-1]=t; t=h1+h2-2.0*f;
	} while((t*js[1]<0.0)&&(j<n));
	if (t*js[1]>0.0) js[1]=0;
}

double nfx(double x[],int j)
{ 
	switch(j)
	{ 
		case 0: return (x[0]-1.0)*(x[0]-10.0)+(x[1]+2.0)*(x[1]+2.0)+2.0;
		case 1: return 2.0*(x[0]-1.0); 
		case 2: return 2.0*(x[1]+2.0); 
	}
}

main()
{ 
	int     js[2];
	double  eps=0.000001, x[3]={0.0};

	nextremum(x,2,eps,10,js,nfx);
	
	printf("\njs[0]=%d",js[0]);
	printf("\nx[0]=%5.4lf",x[0]);
	printf("\nx[1]=%5.4lf",x[1]);
	if (js[1]<0.0) printf("\nMIN:  ");
	if (js[1]>0.0) printf("\nMAX:  ");
	printf("z=%5.4lf",x[2]);
	printf("\n");
}
