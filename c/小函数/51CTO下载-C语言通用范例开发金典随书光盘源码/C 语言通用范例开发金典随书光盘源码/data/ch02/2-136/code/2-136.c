#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "ode.h"

void treanor(TODEP tp)
{ 
	int    n,j;
	double s,aa,bb,dd,g,dy,dy1,lens;
	double *d,*p,*w,*q,*r,*y;

	n=tp->n; 
	w=malloc(4*n*sizeof(double));
	q=malloc(4*n*sizeof(double));
	r=malloc(4*n*sizeof(double));
	d=malloc(n*sizeof(double));
	p=malloc(n*sizeof(double));
	lens=tp->lens; 
	y=tp->y;
	for (j=0; j<n; j++) {
		w[j]=y[j];
	}
	s=tp->t;
	(*tp->ptr)(s,y,n,d);
	for (j=0; j<n; j++)	{ 
		q[j]=d[j]; 
		y[j]=w[j]+lens*d[j]/2.0;
		w[n+j]=y[j];
	}
	s=tp->t+lens/2.0;
	(*tp->ptr)(s,y,n,d);
	for (j=0; j<n; j++)	{ 
		q[n+j]=d[j];
		y[j]=w[j]+lens*d[j]/2.0;
		w[n+n+j]=y[j];
	}
	(*tp->ptr)(s,y,n,d);
	for (j=0; j<n; j++){ 
		q[n+n+j]=d[j];
	}
	for (j=0; j<n; j++){ 
		aa=q[n+n+j]-q[n+j];
		bb=w[n+n+j]-w[n+j];
		if (-aa*bb*lens>0.0){ 
			p[j]=-aa/bb; 
			dd=-p[j]*lens;
			r[j]=exp(dd);
			r[n+j]=(r[j]-1.0)/dd;
			r[n+n+j]=(r[n+j]-1.0)/dd;
			r[3*n+j]=(r[n+n+j]-1.0)/dd;
		}
		else p[j]=0.0;
		g=p[j]<=0.0 ? q[n+n+j]:2.0*(q[n+n+j]-q[j])*r[n+n+j]+(q[j]-q[n+j])*r[n+j]+q[n+j];
		w[3*n+j]=w[j]+g*lens;
		y[j]=w[3*n+j];
	}
	s=tp->t+lens;
	(*tp->ptr)(s,y,n,d);
	for (j=0; j<n; j++){
		q[3*n+j]=d[j];
	}
	for (j=0; j<n; j++)	{ 
		if (p[j]<=0.0)	{ 
			dy=q[j]+2.0*(q[n+j]+q[2*n+j]);
			dy=(dy+q[3*n+j])*lens/6.0;
		}
		else{ 
			dy=-3.0*(q[j]+p[j]*w[j])+2.0*(q[n+j]+p[j]*w[n+j]);
			dy+=2.0*(q[2*n+j]+p[j]*w[n+n+j]);
			dy-=(q[3*n+j]+p[j]*w[n+n+n+j]);
			dy=dy*r[n+n+j]+q[j]*r[n+j];
			dy1=q[j]-q[n+j]-q[2*n+j]+q[3*n+j];
			dy1+=(w[j]-w[n+j]-w[n+n+j]+w[n+n+n+j])*p[j];
			dy=(dy+4.0*dy1*r[n+n+n+j])*lens;
		}
		y[j]=w[j]+dy;
	}
	/*释放动态分配的内存*/
	free(d); free(p); free(w); free(q); free(r);
	return;
}

void treanor_ptr(double t, double y[], int n, double d[])
{ 
	d[0]=-21.0*y[0]+19.0*y[1]-20.0*y[2];
	d[1]=19.0*y[0]-21.0*y[1]+20.0*y[2];
	d[2]=29.0*y[0]-40.0*y[1]-41.0*y[2];
	return;
}

main()
{ 
	int    i,j;
	double y[3]={1.0, 0.0, -1.0};
	TODE   ta = {3, 0.001, 0.0, y, treanor_ptr};

	printf("\n");
	printf("t=%6.3f\n",ta.t);
	for (i=0; i<3; i++)
		printf("y(%d)=%e  ",i,y[i]);
	printf("\n");
	for (i=0; i<10; i++){ 
		treanor(&ta);
		ta.t += ta.lens;
		printf("t=%6.3f\n",ta.t);
		for (j=0; j<3; j++)
			printf("y(%d)=%e  ",j,y[j]);
		printf("\n");
	}
	printf("\n");
}
