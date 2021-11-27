#include "stdio.h"
#include "stdlib.h"
#include "interpolation.h"

double cubic_spline_first(CSINTEP cp)
{ 
	int    n,m,i,j;
	double *x,*y,*dy,*ddy,*t,*z,*dz,*ddz;
	double h0,h1,alpha,beta,g,*s;

	n=cp->n; m=cp->m;
	x=cp->x; y=cp->y; dy=cp->dy; ddy=cp->ddy;
	t=cp->t; z=cp->z; dz=cp->dz; ddz=cp->ddz;
	s=malloc(n*sizeof(double));
	s[0]=dy[0]; dy[0]=0.0;
	h0=x[1]-x[0];
	for (j=1;j<n-1;j++){ 
		h1=x[j+1]-x[j];
		alpha=h0/(h0+h1);
		beta=(1.0-alpha)*(y[j]-y[j-1])/h0;
		beta=3.0*(beta+alpha*(y[j+1]-y[j])/h1);
		dy[j]=-alpha/(2.0+(1.0-alpha)*dy[j-1]);
		s[j]=(beta-(1.0-alpha)*s[j-1]);
		s[j]=s[j]/(2.0+(1.0-alpha)*dy[j-1]);
		h0=h1;
	}
	for (j=n-2;j>=0;j--){
		dy[j]*=dy[j+1];	dy[j]+=s[j];
	}
	for (j=0;j<n-1;j++) 
		s[j]=x[j+1]-x[j];
	for (j=0;j<n-1;j++){ 
		h1=s[j]*s[j];
		ddy[j]=6.0*(y[j+1]-y[j])/h1-2.0*(2.0*dy[j]+dy[j+1])/s[j];
	}
	h1=s[n-2]*s[n-2];
	ddy[n-1]=6.*(y[n-2]-y[n-1])/h1+2.*(2.*dy[n-1]+dy[n-2])/s[n-2];
	g=0.0;
	for (i=0;i<n-1;i++){ 
		h1=0.5*s[i]*(y[i]+y[i+1]);
		h1=h1-s[i]*s[i]*s[i]*(ddy[i]+ddy[i+1])/24.0;
		g+=h1;
	}
	for (j=0;j<m;j++){ 
		if (t[j]>=x[n-1]) i=n-2;
		else{ 
			i=0;
			while (t[j]>x[i+1]) i++;
		}
		h1=(x[i+1]-t[j])/s[i];
		h0=h1*h1;
		z[j]=(3.0*h0-2.0*h0*h1)*y[i];
		z[j]=z[j]+s[i]*(h0-h0*h1)*dy[i];
		dz[j]=6.0*(h0-h1)*y[i]/s[i];
		dz[j]=dz[j]+(3.0*h0-2.0*h1)*dy[i];
		ddz[j]=(6.0-12.0*h1)*y[i]/(s[i]*s[i]);
		ddz[j]=ddz[j]+(2.0-6.0*h1)*dy[i]/s[i];
		h1=(t[j]-x[i])/s[i];
		h0=h1*h1;
		z[j]=z[j]+(3.0*h0-2.0*h0*h1)*y[i+1];
		z[j]=z[j]-s[i]*(h0-h0*h1)*dy[i+1];
		dz[j]=dz[j]-6.0*(h0-h1)*y[i+1]/s[i];
		dz[j]=dz[j]+(3.0*h0-2.0*h1)*dy[i+1];
		ddz[j]=ddz[j]+(6.0-12.0*h1)*y[i+1]/(s[i]*s[i]);
		ddz[j]=ddz[j]-(2.0-6.0*h1)*dy[i+1]/s[i];
	}
	free(s);/*释放动态分配的内存*/
	return(g);
}

main()
{ 
	double x[12]={3.0,5.0,8.0,13.0,17.0,25.0,27.0,29.0,31.0,35.0,39.0,54.0};
	double y[12]={7.0,10.0,11.0,17.0,23.0,18.0,13.0,6.0,3.0,1.0,0.0,-11.0};
	double dy[12]={4.53245,0,0,0,0,0,0,0,0,0,0,-1.26589};
	double ddy[12]={0};
	double t[8]={4.0,7.0,15.0,21.0,26.0,28.0,34.0,45.0};
	double z[8]={0}, dz[8]={0},ddz[8]={0};
	CSINTE ca = {12, x, y, dy, ddy,8, t, z, dz, ddz}; 
	int    i;
	double s;

	s=cubic_spline_first(&ca);
	printf("\n");
	printf("      x(i)          y(i)          dy(i)         ddy(i)\n");
	for (i=0;i<ca.n;i++)   
		printf("%14.6e%14.6e%14.6e%14.6e\n",x[i],y[i],dy[i],ddy[i]);
	printf("\n");
	printf("s=%e\n",s);
	printf("\n");
	printf("      t(i)          z(i)          dz(i)         ddz(i)\n");
	for (i=0;i<ca.m;i++)   
		printf("%14.6e%14.6e%14.6e%14.6e\n",t[i],z[i],dz[i],ddz[i]);
	printf("\n");
}
