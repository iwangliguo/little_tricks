#include "stdlib.h"
#include "math.h"
#include "stdio.h"
#include "matrix.h"

int toeplitz_inv(TMP ap, RMP bp) 
{
	int i,j,k,n,size;
	double a,s,*c,*r,*p,*t,*tf,*ve;
	
	n = ap->row;  
	t = ap->tdata;
	tf= ap->ttdata;
	ve= bp->data;
	if (fabs(t[0])<0.0000001) {	
		printf("not inverse\n"); 
		return -1;
	}
	size = n*sizeof(double);
	c=malloc(size);
	r=malloc(size);
	p=malloc(size);
	a=t[0]; c[0]=tf[1]/t[0]; r[0]=t[1]/t[0];
	for (k=0; k<n-2; k++) { 
		s=0.0;	
		for (j=1; j<=k+1; j++)	
			s+=c[k+1-j]*tf[j];	
		s=(s-tf[k+2])/a;	
		for (i=0; i<=k; i++)	
			p[i]=c[i]+s*r[k-i];	
		c[k+1]=-s;	
		s=0.0;	
		for (j=1; j<=k+1; j++)	
			s+=r[k+1-j]*t[j];	
		s=(s-t[k+2])/a;	
		for (i=0; i<=k; i++) { 
			r[i]=r[i]+s*c[k-i];	
			c[k-i]=p[k-i];	
		}	
		r[k+1]=-s;	
		a=0.0;	
		for (j=1; j<=k+2; j++)	
			a+=t[j]*c[j-1];	
		a=t[0]-a;
		if (fabs(a)<0.0000001) { 
			free(c); free(r); free(p);	
			printf("not inverse\n"); 
			return -2;	
		}
	}
	ve[0]=1.0/a;
	for (i=0; i<n-1; i++)	{ 
		k=i+1; j=(i+1)*n;	
		ve[k]=-r[i]/a; ve[j]=-c[i]/a;
	}
	for (i=0; i<n-1; i++)	
		for (j=0; j<n-1; j++)	{ 
			k=(i+1)*n+j+1;	
			ve[k]=ve[i*n+j]-c[i]*ve[j+1];	
			ve[k]=ve[k]+c[n-j-2]*ve[n-i-1];	
		}
	free(c); free(r); free(p);/*释放动态分配的内存*/
	return 0;
}

void matrixmul(TMP ap,RMP bp,RMP vp)
{ 
	int i,j,k,u;
	double *t = ap->tdata;
	double *tf = ap->ttdata;
	double *b = bp->data;
	double *data = vp->data;

	vp->row = vp->col = ap->row;
	for (i=1; i<=vp->row ; i++)
		for (j=1; j<=vp->row; j++)	{ 
			u = (i-1)*vp->col + j-1;
			data[u]=0.0;	
			for (k=1; k<=j-1; k++)	
				data[u] +=  b[(i-1)*bp->col + k-1]*t[j-k];	
			data[u] += b[(i-1)*bp->col + j-1]*t[0];	
			for (k=j+1; k<=6; k++)	
				data[u] += b[(i-1)*bp->col + k-1]*tf[k-j];	
		}
}

void printrm(char *title, RMP vp) 
{
	int i, j;

	printf(title);
	for(i=0; i<vp->row; i++) {    
		for(j=0; j<vp->col; j++)
			printf("%12.6e ", vp->data[i*vp->col + j]);
		printf("\n");
	}
}

main()
{ 
	double t[6]={10.0,5.0,4.0,3.0,2.0,1.0};
	double tt[6]={0.0,-1.0,-2.0,-3.0,-4.0,-5.0};
	double b[6][6],c[6][6];
	TM     ma = { 6, (double*)t, (double*)tt };
	RM     mb = { 6, 6, (double*)b };
	RM     mc = { 6, 6, (double*)c };

	if ( 0 == toeplitz_inv(&ma, &mb) ) {
		printrm("B=inv(T):\n", &mb);

		matrixmul(&ma, &mb, &mc);
		printrm("A=T*B:\n", &mc);
	}
}

