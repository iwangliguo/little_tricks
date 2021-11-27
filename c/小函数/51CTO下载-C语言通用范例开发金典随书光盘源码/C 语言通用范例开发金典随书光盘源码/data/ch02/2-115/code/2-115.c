#include "stdio.h"
#include "math.h"
#include "integration.h"

void higher_oscillatory_integration(HINTEGP ap)
{ 
	int    mm,k,j;
	double sa[4],sb[4],ca[4],cb[4],sina,sinb,cosa,cosb;

	sina=sin(ap->m*ap->a); sinb=sin(ap->m*ap->b);
	cosa=cos(ap->m*ap->a); cosb=cos(ap->m*ap->b);
	sa[0]=sina; sa[1]=cosa; sa[2]=-sina; sa[3]=-cosa;
	sb[0]=sinb; sb[1]=cosb; sb[2]=-sinb; sb[3]=-cosb;
	ca[0]=cosa; ca[1]=-sina; ca[2]=-cosa; ca[3]=sina;
	cb[0]=cosb; cb[1]=-sinb; cb[2]=-cosb; cb[3]=sinb;
	ap->s[0]=0.0; 
	ap->s[1]=0.0;
	mm=1;k=0;
	while(k<ap->n){ 
		j=k;
		while (j>=4) j-=4;
		mm*=ap->m;
		ap->s[0]+=(ap->fb[k]*sb[j]-ap->fa[k]*sa[j])/(1.0*mm);
		ap->s[1]+=(ap->fb[k]*cb[j]-ap->fa[k]*ca[j])/(1.0*mm);
		k++;
	}
	ap->s[1]=-ap->s[1];
	return;
}

main()
{ 
	double fa[4]={0.0,1.0,0.0,-3.0};
	double fb[4]={6.2831852,1.0,-6.2831852,-3.0};
	HINTEG ha = {0.0, 6.2831852, 60, 4, fa, fb, {0}};

	higher_oscillatory_integration(&ha);
	printf("\n");
	printf("s(0)=%e ,   s(1)=%e\n",ha.s[0], ha.s[1]);
	printf("\n");
}
