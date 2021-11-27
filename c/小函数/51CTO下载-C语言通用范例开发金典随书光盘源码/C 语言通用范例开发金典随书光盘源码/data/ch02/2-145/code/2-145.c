#include "math.h"
#include "stdio.h"
#include "stdlib.h"
#include "matrix.h"

int matrix_inverse(RMP ap)
{ 
	int    n = ap->row;
	double *data = ap->data;
	int    i,j,k,l,u,v;
	int    *is,*js;
	double d,p;
    
	is=malloc(n*sizeof(int));
	js=malloc(n*sizeof(int));
	for (k=0; k<n; k++)
	{ 
		d=0.0;
		for (i=k; i<n; i++)	
			for (j=k; j<n; j++)	{ 
				l=i*n+j;	
				p=fabs(data[l]);	
				if (p>d) {	
					d=p;	
					is[k]=i;	
					js[k]=j;
				}
			}
		if (d + 1.0 == 1.0)	{ 
			free(is);free(js);	
			printf("not inverse.\n");
			return -1;
		}
		if (is[k]!=k)	
			for (j=0; j<n; j++)	{ 
				u=k*n+j; 
				v=is[k]*n+j;	
				p=data[u]; 
				data[u]=data[v]; 
				data[v]=p;	
			}	
		if (js[k]!=k)	
			for (i=0; i<n; i++)	{ 
				u=i*n+k; 
				v=i*n+js[k];	
				p=data[u]; 
				data[u]=data[v]; 
				data[v]=p;	
			}
		l=k*n+k;
		data[l]=1.0/data[l];
		for (j=0; j<n; j++)	
			if (j!=k)	{ 
				u=k*n+j; 
				data[u]=data[u]*data[l];
			}
		for (i=0; i<n; i++)	
			if (i!=k)	
				for (j=0; j<n; j++)	
					if (j!=k)	{ 
						u=i*n+j;	
						data[u]=data[u]-data[i*n+k]*data[k*n+j];	
					}
		for (i=0; i<n; i++)	
			if (i!=k)	{ 
				u=i*n+k; data[u]=-data[u]*data[l];
			}
	}
	for (k=n-1; k>=0; k--)	{ 
		if (js[k]!=k)	
			for (j=0; j<n; j++)	{ 
				u=k*n+j; v=js[k]*n+j;	
				p=data[u]; data[u]=data[v]; data[v]=p;
	}
	if (is[k]!=k)	
		for (i=0; i<n; i++)	{ 
			u=i*n+k; v=i*n+is[k];	
			p=data[u]; data[u]=data[v]; data[v]=p;	
		}
	}

	free(is); free(js); /*释放动态分配的内存*/
	return 0;
}

void matrixmul(RMP ap,RMP bp,RMP vp)
{ 
	int i,j,l;
	double *data;

	if(ap->col != bp->row) {
		printf("error");
		return;
	}

	vp->row = ap->row;
	vp->col = bp->col;
	for (i=0; i<vp->row; i++)
		for (j=0; j<vp->col; j++){ 
			data = vp->data + (i * vp->col + j);
			*data = 0.0;
			for (l=0; l<ap->col; l++)
				*data += ap->data[i*ap->col + l] * bp->data[l*bp->col + j];
		}
}

int linearprogram(double a[],double b[],double c[],int m,int n,double x[])
{ 
	int    i,k,j,*js;
	double s,z,dd,y,*p,*d;
	RM     ma={m, m+n, a}, mp,md;

	js=malloc(m*sizeof(int));
	p=malloc(m*m*sizeof(double));
	d=malloc(m*(m+n)*sizeof(double));
	mp.row=mp.col=m; mp.data =p;
	md.data =d;
	for (i=0; i<m; i++)  {
		js[i]=n+i;
	}
	s=0.0;
	while (1){ 
		for (i=0; i<m; i++)
			for (j=0; j<m; j++)
				p[i*m+j]=a[i*(m+n)+js[j]];
		
		if (matrix_inverse(&mp)!=0)	{ 
			x[n]=s; 
			free(js); free(p); free(d); 
			return 0;
		}

		matrixmul(&mp, &ma, &md);
		for (i=0; i<m+n; i++) {
			x[i]=0.0;
		}
		for (i=0; i<m; i++)	{ 
			for (j=0,s=0.0; j<m; j++)
				s+=p[i*m+j]*b[j];
			x[js[i]]=s;
		}
		k=-1; dd=1.0e-35;
		for (j=0; j<m+n; j++)	{ 
			for (i=0,z=0.0; i<m; i++)
				z+=c[js[i]]*d[i*(m+n)+j];
			z-=c[j];
			if (z>dd) { dd=z; k=j;}
		}
		if (k==-1)	{ 
			for (j=0,s=0.0; j<n; j++)
				s+=c[j]*x[j];
			x[n]=s; 
			free(js); free(p); free(d); /*释放动态分配的内存*/
			return(1);
		}
		j=-1;
		dd=1.0e+20;
		for (i=0; i<m; i++)
			if (d[i*(m+n)+k]>=1.0e-20)	{ 
				y=x[js[i]]/d[i*(m+n)+k];
				if (y<dd) { dd=y; j=i;}
			}
		if (j==-1) { 
			x[n]=s; 
			free(js); free(p);	free(d); 
			return(0);
		}
		js[j]=k;
	}
}

main()
{ 
	double a[3][6]={{1.0,2.0,7.0,1.0,0.0,0.0},{1.0,4.0,13.0,0.0,1.0,0.0},{0.0,2.0,8.0,0.0,0.0,1.0}};
	double b[3]={10.0,18.0,13.0};
	double c[6]={-4.0,-9.0,-26.0,0.0,0.0,0.0};
	double x[6];
	int    i;

	if (linearprogram((double*)a,b,c,3,3,x)!=0){ 
		for (i=0; i<6; i++)
			printf("\nx[%d]=%5.2lf",i,x[i]);
	}
}

