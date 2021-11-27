#include "math.h"
#include "stdio.h"
#include "interpolation.h"

double interpolation_total(PINTEP pp)
{ 
	int    n,m,ip,ipp,i,j,l,iq,iqq,k;
	double u,v,*x,*y,*z,h,w,b[10];

	n=pp->n; m=pp->m;
	u=pp->u; v=pp->v; 
	x=pp->x; y=pp->y; z=pp->z;
	if (u<=x[0]) { 
		ip=1; ipp=4;
	}
	else if (u>=x[n-1]) { 
		ip=n-3; ipp=n;
	}
	else { 
		i=1; j=n;
		while (((i-j)!=1)&&((i-j)!=-1))	{ 
			l=(i+j)/2;
			if (u<x[l-1]) j=l;
			else i=l;
		}
		ip=i-3; ipp=i+4;
	}
	if (ip<1) ip=1;
	if (ipp>n) ipp=n;
	if (v<=y[0]) { iq=1; iqq=4;}
	else if (v>=y[m-1]) { iq=m-3; iqq=m;}
	else{ 
		i=1; j=m;
		while (((i-j)!=1)&&((i-j)!=-1))	{ 
			l=(i+j)/2;
			if (v<y[l-1]) j=l;
			else i=l;
		}
		iq=i-3; iqq=i+4;
	}
	if (iq<1) iq=1;
	if (iqq>m) iqq=m;
	for (i=ip-1;i<ipp;i++) { 
		b[i-ip+1]=0.0;
		for (j=iq-1;j<iqq;j++) { 
			h=z[m*i+j];	
			for (k=iq-1;k<iqq;k++)
				if (k!=j) h=h*(v-y[k])/(y[j]-y[k]);
			b[i-ip+1]+=h;
		}
	}
	w=0.0;
	for (i=ip-1;i<ipp;i++){ 
		h=b[i-ip+1];
		for (j=ip-1;j<ipp;j++)
			if (j!=i) h*=(u-x[j])/(x[i]-x[j]);
		w+=h;
	}
	return(w);
}

main()
{ 
	int i,j;
	double x[11],y[11],z[11][11];
	PINTE  pa = {11, 11, (double*)x, (double*)y, (double*)z, 7.0, 13.0};
	PINTE  pb = {11, 11, (double*)x, (double*)y, (double*)z, 15.0,23.0};
	for (i=0;i<11;i++)	{ 
		x[i]=3.0*i; y[i]=5.0*i;
	}
	for (i=0;i<11;i++)
		for (j=0;j<11;j++)
			z[i][j]=exp(-(0.7*x[i]-0.11*y[j]));
	printf("\n");
	printf("x=%7.3f,  y=%7.3f,    z(x,y)=%e\n",pa.u,pa.v,interpolation_total(&pa));
	printf("x=%7.3f,  y=%7.3f,    z(x,y)=%e\n",pb.u,pb.v,interpolation_total(&pb));
	printf("\n");
}
