
; Example 6 - 8. NLMS Implementation ASM Listing for the TMS320C2x DSP

  			.title	'TN25'
********************************************************
*TN25:  Adaptive Filter Using Transversal Structure
*		and Normalized LMS Algorithm ,Looped Code
*Algorithm:
*             63
*     	y(n) = SUM w(k)*x(n-k)  k=0,1,2,...,63
*             k=0
*   	e(n) = d(n) - y(n)
*		var(k)=(1.-r)*var(K-1)+r*x(n)*x(n)
*      	w(k) = w(k)+u*e(n)*x(n-k)/var(k)  k=0,1,2,..63
*      	Where we use filter order = 64 and mu = 0.01.
*      	Note: This source program is the generic version; I/0 configuration
*      	has not been set up. User has to modify the main routine for specific
*      	application.
*	Initial condition:
*		1) PM status bit should be equal to 01.
*		2) SXM states bit should be set to 1.
*		3) The current DP (data memory page pointer) should be page 0.
*		4) Data awry ONE should be 1.
*		5) Data memory U should be 327.
*		6)Data memory VAR should be initialized to 07fffh.
*				Chen, Chein-Chung February, 1989
***************************************************

*
*	DEFINE	PARAMETERS
*
ORDER:		.equ			64
SHIFT:		.equ			7
PAGE0:		.equ			0

*
*	DEFINE ADDRESSES	OF	BUFFER	AND COEFFICENTS
*

XO:		.usect		"buffer", ORDER-1
XM:		.usect		"buffer", 1
WM:		.usect		"coeffs", ORDER

*
*	RESERVE ADDRESSES FOR PARAMETERS
*

D:		.usect		"parameters",1
Y:		.usect		"parameters",1
ERR:		.usect      	"parameters",1
ONE:		.usect      	"parameters",1
U:		.usect		"parameters",1
ERRF:		.usect      	"parameters",1
VAR:		.usect      	"parameters",1

******************************************
*  PERFORM THE ADAPTIVE FILTER
******************************************
	
	.text
*
* ESTIMATE THE POWER OF SIGNAL
*			
	LARP	AR3
	LRLK	AR3,X0				;Point to input signal X
	SQRA	*				;Square input signal
	SPH	ERRF
	ZALH	VAR				;ACC=VAR(n-1)
	SUB	VAR,SHIFT			;ACC=(1-r)*VAR(n-1)
	ADD	ERRF,SHIFT			;ACC=(1-r)*VAR(n-1)+r*X(n)
*						;*X(n)
	SACH	VAR				;Store VAR(n)

*
* ESTIMATE THE SIGNAL Y
*

	CNFP                          ; Configure BO as program memory
	MPYK    0                     ; Clear the P register
     	LAC	ONE ,15		      ; Using rounding 
      	LRLK	AR3,XN      	      ; Point to the oldest buffer
FIR    	RPTK	ORDER-1               ; Repeat N time 
       	MACD    WN+0fd00h,*-          ; Estimate Y(n)
       	CNFD                          ; Configure BO as data memory
       	APAC
       	SACH   	Y                     ; Store the filter output
 
*
* COMPUTE THE ERROR
*

	NEG                  		; ACC= －Y(n)
  	ADD	D
   	SACH    ERR        		; ERR(n)= D(n) －Y (n)

*
* UPDATE THE WEIGHTS
*

	LT     	ERR            		;T=ERR(n)
	MPY   	U            		;P=U+ERR(n)
	PAC
	ADD    	ONE ,15       		;Round the result

*
* NORMALIZE CONVERGE FACTOR
*

	ABS				;Make divedend positive
	RPTK	14			;Repeat 15 times
	SUBC	VAR			;Perform U*¦ERR(n) ¦/ VAR
	BIT	ERR,0			;Check sign of  ERR(n)

        BBZ      NEXT
        NEG                      ;  ERRF = - U * ¦ ERR(n) ¦/ VAR
 NEXT   SACL     ERRF            ;  Store ERRF

*
        LARK     AR1,ORDER-1     ;  Set up counter
        LRLK     AR2,WN          ;  Point to the coefficients
        LRLK     AR3,XN +1       ;  Point to the data samples
        LT        ERRF           ;  T  register  =  U * ERR(n)
        MPY      *-,AR2          ;  P = U * ERR(n) * X(n - k)
ADAPT   ZALR     *,AR3           ;  Load  ACCH  with  A(k,n)  &  round
        MPYA     *-,AR2          ;  W(k , n+1) = W(k , n) + P
 *                               ;  P = U * ERR(n) * X(n-k)
        SACH     *+,0,AR1        ;  Store  w(k,n+1)
        BANZ     ADAPT,*-,AR2

FINISH   
	.end


