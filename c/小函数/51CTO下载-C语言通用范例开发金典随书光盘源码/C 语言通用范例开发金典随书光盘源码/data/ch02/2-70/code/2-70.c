#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "matrix.h"

int plu_gauss(CMP2 ap, CMP2 bp)
{ 
	int    *js,n,l,k,i,j,is,u,v;
	double p,q,s,d;
	double *ar,*ai,*br,*bi;

	n=bp->row;
	ar=ap->rdata; ai=ap->idata;
	br=bp->rdata; bi=bp->idata;
	js=malloc(n*sizeof(int));
	for (k=0;k<n-1;k++)	{ 
		d=0.0;
		for (i=k;i<n;i++)
			for (j=k;j<n;j++) { 
				u=i*n+j;
				p=ar[u]*ar[u]+ai[u]*ai[u];
				if (p>d) {d=p;js[k]=j;is=i;}
			}
		if (fabs(d)<0.0000001)	{ 
			free(js); printf("fail\n");
			return -1;
		}
		if (is!=k){ 
			for (j=k;j<n;j++){ 
				u=k*n+j; v=is*n+j;
				p=ar[u]; ar[u]=ar[v]; ar[v]=p;
				p=ai[u]; ai[u]=ai[v]; ai[v]=p;
			}
			p=br[k]; br[k]=br[is]; br[is]=p;
			p=bi[k]; bi[k]=bi[is]; bi[is]=p;
		}
		if (js[k]!=k)
			for (i=0;i<n;i++){ 
				u=i*n+k; v=i*n+js[k];
				p=ar[u]; ar[u]=ar[v]; ar[v]=p;
				p=ai[u]; ai[u]=ai[v]; ai[v]=p;
			}
		v=k*n+k;
		for (j=k+1;j<n;j++){ 
			u=k*n+j;
			p=ar[u]*ar[v]; q=-ai[u]*ai[v];
			s=(ar[v]-ai[v])*(ar[u]+ai[u]);
			ar[u]=(p-q)/d; ai[u]=(s-p-q)/d;
		}
		p=br[k]*ar[v]; q=-bi[k]*ai[v];
		s=(ar[v]-ai[v])*(br[k]+bi[k]);
		br[k]=(p-q)/d; bi[k]=(s-p-q)/d;
		for (i=k+1;i<n;i++){ 
			u=i*n+k;
			for (j=k+1;j<n;j++)	{ 
				v=k*n+j; l=i*n+j;
				p=ar[u]*ar[v]; q=ai[u]*ai[v];
				s=(ar[u]+ai[u])*(ar[v]+ai[v]);
				ar[l]-=p-q;
				ai[l]-=s-p-q;
			}
			p=ar[u]*br[k]; q=ai[u]*bi[k];
			s=(ar[u]+ai[u])*(br[k]+bi[k]);
			br[i]-=p-q; 
			bi[i]-=s-p-q;
		}
	}
	u=(n-1)*n+n-1;
	d=ar[u]*ar[u]+ai[u]*ai[u];
	if (fabs(d)<0.0000001)	{ 
		free(js); printf("fail\n");
		return -2;
	}
	p=ar[u]*br[n-1]; q=-ai[u]*bi[n-1];
	s=(ar[u]-ai[u])*(br[n-1]+bi[n-1]);
	br[n-1]=(p-q)/d; bi[n-1]=(s-p-q)/d;
	for (i=n-2;i>=0;i--)
		for (j=i+1;j<n;j++)	{ 
			u=i*n+j;
			p=ar[u]*br[j]; q=ai[u]*bi[j];
			s=(ar[u]+ai[u])*(br[j]+bi[j]);
			br[i]-=p-q;
			bi[i]-=s-p-q;
		}
	js[n-1]=n-1;
	for (k=n-1;k>=0;k--)
		if (js[k]!=k)	{ 
			p=br[k]; br[k]=br[js[k]]; br[js[k]]=p;
			p=bi[k]; bi[k]=bi[js[k]]; bi[js[k]]=p;
		}
	free(js);/*释放动态分配的内存*/
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
	double br[4]={4.0,6.0,7.0,5.0};
	double bi[4]={5.0,6.0,2.0,4.0};
	CM2 ma = {4, 4, (double*)ar, (double*)ai};
	CM2 mb = {4, 1, (double*)br, (double*)bi};

	if (plu_gauss(&ma, &mb)==0) {
		printcx(&mb);
	}
}
