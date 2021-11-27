#include "stdio.h"
#include "math.h"
#include "interpolation.h"

double interpolation_point(PINTEP pp)
{ 
	int n,m,nn,mm,ip,iq,i,j,k,l;
	double u,v,*x,*y,*z,b[3],h,w;

	n=pp->n; m=pp->m; nn=3;
	u=pp->u; v=pp->v; 
	x=pp->x; y=pp->y; z=pp->z;
	if (n<4) { 
		ip=0;  nn=n;
	}
	else if (u<=x[1]) ip=0;
	else if (u>=x[n-2]) ip=n-3;
	else{ 
		i=1; j=n;
		while (((i-j)!=1)&&((i-j)!=-1))	{ 
			l=(i+j)/2;
			if (u<x[l-1]) j=l;
			else i=l;
		}
		if (fabs(u-x[i-1])<fabs(u-x[j-1])) ip=i-2;
		else ip=i-1;
	}
	mm=3;
	if (m<=3) { 
		iq=0; mm=m;
	}
	else if (v<=y[1]) iq=0;
	else if (v>=y[m-2]) iq=m-3;
	else{ 
		i=1; j=m;
		while (((i-j)!=1)&&((i-j)!=-1))	{ 
			l=(i+j)/2;
			if (v<y[l-1]) j=l;
			else i=l;
		}
		if (fabs(v-y[i-1])<fabs(v-y[j-1])) iq=i-2;
		else iq=i-1;
	}
	for (i=0;i<nn;i++){ 
		b[i]=0.0;
		for (j=0;j<mm;j++){ 
			k=m*(ip+i)+(iq+j);
			h=z[k];	
			for (k=0;k<mm;k++)
				if (k!=j)
					h*=(v-y[iq+k])/(y[iq+j]-y[iq+k]);
			b[i]+=h;
		}
	}
	w=0.0;
	for (i=0;i<nn;i++){ 
		h=b[i];
		for (j=0;j<nn;j++)
			if (j!=i)
				h*=(u-x[ip+j])/(x[ip+i]-x[ip+j]);
		w+=h;
	}
	return(w);
}
  
main()
{ 
	double x[6]={0},y[5]={0},z[6][5]={0};
	PINTE  pa = {6, 5, (double*)x, (double*)y, (double*)z, 0.9, 0.8};
	PINTE  pb = {6, 5, (double*)x, (double*)y, (double*)z, 0.3, 0.9};
	int i,j;
	for (i=0;i<6;i++) 	x[i]=3.0*i;
	for (j=0;j<5;j++) 	y[j]=5.0*j;
	for (i=0;i<6;i++)      
		for (j=0;j<5;j++)        
			z[i][j]=exp(-(x[i]-y[j]));
	printf("\n");
	printf("x=%7.3f,   y=%7.3f,    z(x,y)=%e\n", pa.u, pa.v, interpolation_point(&pa));
	printf("x=%7.3f,   y=%7.3f,    z(x,y)=%e\n", pb.u, pb.v, interpolation_point(&pb));
	printf("\n");
}
