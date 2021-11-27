#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "matrix.h"

int plu_gauss_jordan(CMP2 ap, CMP2 bp)
{ 
	int    *js,n,m,l,k,i,j,is,u,v;
	double p,q,s,d;
	double *ar,*ai,*br,*bi;

	n=bp->row; m=bp->col;
	ar=ap->rdata; ai=ap->idata;
	br=bp->rdata; bi=bp->idata;
	js=malloc(n*sizeof(int));
	for (k=0;k<n;k++) { 
		d=0.0;
		for (i=k;i<n;i++)
			for (j=k;j<n;j++)          { 
				u=i*n+j;
				p=ar[u]*ar[u]+ai[u]*ai[u];
				if (p>d) {
					d=p;js[k]=j;is=i;
				}
			}
		if (fabs(d)<0.0000001)	{ 
			free(js); printf("fail\n");
			return -1;
		}
		if (is!=k)	{ 
			for (j=k;j<n;j++){ 
				u=k*n+j; v=is*n+j;
				p=ar[u]; ar[u]=ar[v]; ar[v]=p;
				p=ai[u]; ai[u]=ai[v]; ai[v]=p;
			}
			for (j=0;j<m;j++){
				u=k*m+j; v=is*m+j;
				p=br[u]; br[u]=br[v]; br[v]=p;
				p=bi[u]; bi[u]=bi[v]; bi[v]=p;
			}
		}
		if (js[k]!=k)
			for (i=0;i<n;i++){ 
				u=i*n+k; v=i*n+js[k];
				p=ar[u]; ar[u]=ar[v]; ar[v]=p;
				p=ai[u]; ai[u]=ai[v]; ai[v]=p;
			}
		v=k*n+k;
		for (j=k+1;j<n;j++)	{ 
			u=k*n+j;
			p=ar[u]*ar[v]; q=-ai[u]*ai[v];
			s=(ar[v]-ai[v])*(ar[u]+ai[u]);
			ar[u]=(p-q)/d; ai[u]=(s-p-q)/d;
		}
		for (j=0;j<m;j++){ 
			u=k*m+j;
			p=br[u]*ar[v]; q=-bi[u]*ai[v];
			s=(ar[v]-ai[v])*(br[u]+bi[u]);
			br[u]=(p-q)/d; bi[u]=(s-p-q)/d;
		}
		for (i=0;i<n;i++)
			if (i!=k){ 
				u=i*n+k;
				for (j=k+1;j<n;j++){ 
					v=k*n+j; l=i*n+j;
					p=ar[u]*ar[v]; q=ai[u]*ai[v];
					s=(ar[u]+ai[u])*(ar[v]+ai[v]);
					ar[l]-=p-q;
					ai[l]-=s-p-q;
				}
				for (j=0;j<m;j++){ 
					l=i*m+j; v=k*m+j;
					p=ar[u]*br[v]; q=ai[u]*bi[v];
					s=(ar[u]+ai[u])*(br[v]+bi[v]);
					br[l]-=p-q; bi[l]-=s-p-q;
				}
			}
	}
	for (k=n-1;k>=0;k--)
		if (js[k]!=k)
		for (j=0;j<m;j++){ 
			u=k*m+j;v=js[k]*m+j;
			p=br[u]; br[u]=br[v]; br[v]=p;
			p=bi[u]; bi[u]=bi[v]; bi[v]=p;
		}
	free(js);
	return 0;
}

void printcx(CMP2 bp) {
	int i,j,u;
	for(i=0; i<bp->row; i++) {
		printf("x(%d)=", i);
		for(j=0; j<bp->col; j++) {
			u = i * bp->col + j;
			printf("%13.7e  +j %13.7e", bp->rdata[u], bp->idata[u]);
			if(j<bp->col-1) printf(",  ");
		}
		printf("\n");
	}
}

main()
{
	double ar[4][4]={   {2.0,5.0,1.0,9.0},
						{6.0,3.0,4.0,5.0},
						{2.0,14.0,7.0,6.0},
						{7.0,8.0,13.0,19.0}};
	double ai[4][4]={   {5.0,8.0,9.0,7.0},
						{2.0,5.0,7.0,8.0},
						{4.0,13.0,11.0,12.0},
						{6.0,8.0,9.0,15.0}};
	double br[4][2]={	{4.0,2.0},
						{6.0,3.0},
						{7.0,2.0},
						{5.0,1.0}};
	double bi[4][2]={	{5.0,3.0},
						{6.0,7.0},
						{2.0,9.0},
						{4.0,2.0}};
	CM2 ma = {4, 4, (double*)ar, (double*)ai};
	CM2 mb = {4, 2, (double*)br, (double*)bi};

	if (plu_gauss_jordan(&ma, &mb)==0) {
		printcx(&mb);
	}
}
