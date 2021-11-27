#include "stdio.h"
#include "stdlib.h"
#include "matrix.h"

int multi_matrix_inverse(CMP2 ma)  
{ 
	int    *is,*js,i,j,k,l,u,v,w;    
	double p,q,s,t,d,b;
	int    n = ma->row;
	double *ar = ma->rdata;
	double *ai = ma->idata;

    is=malloc(n*sizeof(int));
    js=malloc(n*sizeof(int));
	for (k=0; k<n; k++) { 
		d=0.0;
		for (i=k; i<n; i++)
			for (j=k; j<n; j++)	{ 
				u=i*n+j;	
				p=ar[u]*ar[u]+ai[u]*ai[u];	
				if (p>d) { d=p; is[k]=i; js[k]=j;}
			}	
			if (d+1.0==1.0)	{		
				free(is), free(js); 
				printf("not inverse.\n");	
				return -1;
			}
		if (is[k]!=k)
			for (j=0; j<n; j++)	{ 
				u=k*n+j; v=is[k]*n+j;	
				t=ar[u]; ar[u]=ar[v]; ar[v]=t;	
				t=ai[u]; ai[u]=ai[v]; ai[v]=t;	
			}	
		if (js[k]!=k)	
			for (i=0; i<n; i++)	{ 
				u=i*n+k; v=i*n+js[k];	
				t=ar[u]; ar[u]=ar[v]; ar[v]=t;	
				t=ai[u]; ai[u]=ai[v]; ai[v]=t;	
			}	
		l=k*n+k;	
		ar[l]=ar[l]/d; ai[l]=-ai[l]/d;	
		for (j=0; j<n; j++)	
			if (j!=k)	{ 
				u=k*n+j;	
				p=ar[u]*ar[l]; q=ai[u]*ai[l];	
				s=(ar[u]+ai[u])*(ar[l]+ai[l]);	
				ar[u]=p-q; ai[u]=s-p-q;	
			}	
		for (i=0; i<n; i++)	
			if (i!=k)	{ 
				v=i*n+k;	
				for (j=0; j<n; j++)	
					if (j!=k) { u=k*n+j;  w=i*n+j;	
					p=ar[u]*ar[v]; q=ai[u]*ai[v];	
					s=(ar[u]+ai[u])*(ar[v]+ai[v]);	
					t=p-q; b=s-p-q;	
					ar[w]=ar[w]-t;	
					ai[w]=ai[w]-b;	
				}	
			}
		for (i=0; i<n; i++)	
			if (i!=k)	{ 
				u=i*n+k;	
				p=ar[u]*ar[l]; q=ai[u]*ai[l];	
				s=(ar[u]+ai[u])*(ar[l]+ai[l]);	
				ar[u]=q-p; ai[u]=p+q-s;	
			}
	}
	for (k=n-1; k>=0; k--)	{ 
		if (js[k]!=k)	
			for (j=0; j<n; j++)	{ 
				u=k*n+j; v=js[k]*n+j;	
				t=ar[u]; ar[u]=ar[v]; ar[v]=t;	
				t=ai[u]; ai[u]=ai[v]; ai[v]=t;	
			}	
			if (is[k]!=k)	
				for (i=0; i<n; i++)	{ 
					u=i*n+k; v=i*n+is[k];	
					t=ar[u]; ar[u]=ar[v]; ar[v]=t;	
					t=ai[u]; ai[u]=ai[v]; ai[v]=t;	
				}	
	}
	free(is); free(js);/*释放动态分配的内存*/
	return 0;
}

void cmatrixmul2(CMP2 ap,CMP2 bp,CMP2 vp)
{ 
	int i,j,l,m,n,u;
	double ar,ai,br,bi,*rdata, *idata;

	vp->row = ap->row;
	vp->col = bp->col;
	for(i=0; i<vp->row; i++)
		for(j=0; j<vp->col; j++) { 
			u = i * vp->col + j;
			rdata = vp->rdata + u;
			idata = vp->idata + u;
			*rdata = 0.0; *idata = 0.0;
			for (l=0; l<ap->col; l++) {
				m = i*ap->col+l;
				n = l*bp->col+j;
				ar = ap->rdata[m]; ai = ap->idata[m];
				br = bp->rdata[n]; bi = bp->idata[n];
				*rdata += ar * br - ai * bi;
				*idata += ar * bi + ai * br;
			}
		}
}

void printcm2r(char *title, CMP2 vp) {
	int i, j;

	printf(title);
	for(i=0; i<vp->row; i++) {    
		for(j=0; j<vp->col; j++)
			printf("%13.7e ", vp->rdata[i*vp->col + j]);
		printf("\n");
	}
}

void printcm2i(char *title, CMP2 vp) {
	int i, j;

	printf(title);
	for(i=0; i<vp->row; i++) {    
		for(j=0; j<vp->col; j++)
			printf("%13.7e ", vp->idata[i*vp->col + j]);
		printf("\n");
	}
}

void cmatrixcpy2(CMP2 s,CMP2 t)
{
	int i, j, u;

	t->row = s->row;
	t->col = s->col;
	for(i=0; i<t->row; i++)
		for(j=0; j<t->col; j++) {
			u = i * t->col + j;
			t->rdata[u] = s->rdata[u];
			t->idata[u] = s->idata[u];
		}
}

main()
{
	double ar[4][4] = { {0.2368,0.2471,0.2568,1.2671},
						{1.1161,0.1254,0.1397,0.1490},
						{0.1582,1.1675,0.1768,0.1871},
						{0.1968,0.2071,1.2168,0.2271}};
	double ai[4][4] = { {0.1345,0.1678,0.1875,1.1161},
						{1.2671,0.2017,0.7024,0.2721},
						{-0.2836,-1.1967,0.3558,-0.2078},
						{0.3576,-1.2345,2.1185,0.4773}};
	double br[4][4],bi[4][4],cr[4][4],ci[4][4];
	
	CM2 ma = { 4, 4, (double*)ar, (double*)ai};
	CM2 mb = { 4, 4, (double*)br, (double*)bi};
	CM2 mc = { 4, 4, (double*)cr, (double*)ci};

	cmatrixcpy2(&ma, &mb);/* ma 复制到 mb */
	printcm2r("\nMatrix AR Is:\n", &ma);
	printcm2i("\nMatrix AI Is:\n", &ma);

	if( 0 == multi_matrix_inverse(&mb) ) {
		printcm2r("\nMatrix AR- Is:\n", &mb);
		printcm2i("\nMatrix AI- Is:\n", &mb);

		cmatrixmul2(&ma,&mb,&mc);
		printcm2r("\nMatrix CR=AA- Is:\n", &mc);
		printcm2i("\nMatrix CI=AA- Is:\n", &mc);
	}
}
