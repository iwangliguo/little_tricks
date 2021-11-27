#include "stdio.h"
#include "math.h"
#include "interpolation.h"

void interpolation_akima(AKINTEP ap)  { 
	int    num,k,kk,m,l;
    double pio,*mtr,*x,*y,u[5],p,q;

	num=ap->n; k=ap->k;
	pio=ap->t; mtr=ap->s; 
	x=ap->x; y=ap->y;
    if (num<1) {
		return;
	}
    else if (num==1) { 
		mtr[0]=mtr[4]=y[0]; 
		return;
	}
    else if (num==2) { 
		mtr[0]=y[0]; 
		mtr[1]=(y[1]-y[0])/(x[1]-x[0]);
        if (k<0)     
			mtr[4]=(y[0]*(pio-x[1])-y[1]*(pio-x[0]))/(x[0]-x[1]);
        return;      
	}
    
	if (k<0) { 
		if (pio<=x[1]) kk=0;
        else if (pio>=x[num-1]) kk=num-2;
        else { 
			kk=1; m=num;
            while (((kk-m)!=1)&&((kk-m)!=-1)) { 
				l=(kk+m)/2;
                if (pio<x[l-1]) m=l;
                else kk=l;
			} 
			kk--;
		}      
	}
    else kk=k;
    
	if (kk>=num-1) kk=num-2;
    u[2]=(y[kk+1]-y[kk])/(x[kk+1]-x[kk]);
    if (num==3) { 
		if (kk==0) { 
			u[3]=(y[2]-y[1])/(x[2]-x[1]);
            u[4]=2.0*u[3]-u[2];
            u[1]=2.0*u[2]-u[3];
            u[0]=2.0*u[1]-u[2];   
		} 
		else { 
			u[1]=(y[1]-y[0])/(x[1]-x[0]);
            u[0]=2.0*u[1]-u[2];
            u[3]=2.0*u[2]-u[1];
            u[4]=2.0*u[3]-u[2];
		}      
	}
    else { 
		if (kk<=1){ 
			u[3]=(y[kk+2]-y[kk+1])/(x[kk+2]-x[kk+1]);            
			if (kk==1) {
				u[1]=(y[1]-y[0])/(x[1]-x[0]);
                u[0]=2.0*u[1]-u[2];
                if (num==4) u[4]=2.0*u[3]-u[2];
                else u[4]=(y[4]-y[3])/(x[4]-x[3]);              
			}
            else { 
				u[1]=2.0*u[2]-u[3];
                u[0]=2.0*u[1]-u[2];
                u[4]=(y[3]-y[2])/(x[3]-x[2]); 
			}
		}
		else if (kk>=(num-3)) { 
			u[1]=(y[kk]-y[kk-1])/(x[kk]-x[kk-1]);
            if (kk==(num-3)) { 
				u[3]=(y[num-1]-y[num-2])/(x[num-1]-x[num-2]);
                u[4]=2.0*u[3]-u[2];
                if (num==4) u[0]=2.0*u[1]-u[2];
                else u[0]=(y[kk-1]-y[kk-2])/(x[kk-1]-x[kk-2]);  
			}
            else { 
				u[3]=2.0*u[2]-u[1];
                u[4]=2.0*u[3]-u[2];
                u[0]=(y[kk-1]-y[kk-2])/(x[kk-1]-x[kk-2]);  
			} 
		}
        else { 
			u[1]=(y[kk]-y[kk-1])/(x[kk]-x[kk-1]);
            u[0]=(y[kk-1]-y[kk-2])/(x[kk-1]-x[kk-2]);
            u[3]=(y[kk+2]-y[kk+1])/(x[kk+2]-x[kk+1]);
            u[4]=(y[kk+3]-y[kk+2])/(x[kk+3]-x[kk+2]); 
		}    
	}
    mtr[0]=fabs(u[3]-u[2]);
    mtr[1]=fabs(u[0]-u[1]);
    if ((fabs(mtr[0])<0.0000001)&&(fabs(mtr[1])<0.0000001))
         p=(u[1]+u[2])/2.0;
    else p=(mtr[0]*u[1]+mtr[1]*u[2])/(mtr[0]+mtr[1]);
    mtr[0]=fabs(u[3]-u[4]);
    mtr[1]=fabs(u[2]-u[1]);
    if ((fabs(mtr[0])<0.0000001)&&(fabs(mtr[1])<0.0000001))
         q=(u[2]+u[3])/2.0;
    else q=(mtr[0]*u[2]+mtr[1]*u[3])/(mtr[0]+mtr[1]);
    mtr[0]=y[kk];
    mtr[1]=p;
    mtr[3]=x[kk+1]-x[kk];
    mtr[2]=(3.0*u[2]-2.0*p-q)/mtr[3];
    mtr[3]=(q+p-2.0*u[2])/(mtr[3]*mtr[3]);
    if (k<0) { 
		p=pio-x[kk];
        mtr[4]=mtr[0]+mtr[1]*p+mtr[2]*p*p+mtr[3]*p*p*p;      
	
	}
    return;
}

main()
{
	double x[11]={3.0,5.0,8.0,13.0,17.0,25.0,27.0,29.0,31.0,35.0,39.0};
	double y[11]={7.0,10.0,11.0,17.0,23.0,18.0,13.0,6.0,3.0,1.0,0.0};
	AKINTE aa= {11, x, y, -1, 14.0, {0}};
	AKINTE ab= {11, x, y, -1, 28.0, {0}};


	printf("\n");
	interpolation_akima(&aa);
	printf("x=%6.3f,   f(x)=%e\n",aa.t, aa.s[4]);
	printf("mtr0=%e, mtr1=%e, mtr2=%e, mtr3=%e\n",aa.s[0],aa.s[1],aa.s[2],aa.s[3]);
	printf("\n");
	interpolation_akima(&ab);
	printf("x=%6.3f,   f(x)=%e\n",ab.t, ab.s[4]);
	printf("mtr0=%e, mtr1=%e, mtr2=%e, mtr3=%e\n",ab.s[0],ab.s[1],ab.s[2],ab.s[3]);
	printf("\n");
}
