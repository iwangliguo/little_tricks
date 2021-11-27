
; Example 6 - 22. NLMS Implementation ASM Listing for the TMS320C3x DSP

*******************************************************************************
*
* TM30 – Adaptive transversal filter with Normalized LMS algorithm 
*       using the TMS320C30
*
*   Algorithm:
*
*             63
*      y(n) = SUM w(k)*x(n-k)  k=0,1,2…,63
*            k=0
*
*      var(n) = r*var(n-1) + (1-r)*x(n)*x(n)
*
*      e(n) = d(n) – y(n)
*
*      w(k) = w(k) + u*e(n)*x(n-k)/var(n)   k=0,1,2…63
*
*      Where we use filter order = 64 and mu = 0.01
*
*                Chen, Cheim-Chumg   March, 1989
*
*****************************************************

            .copy    "adapfltr.int"

*****************************************************
*    PERFORM  ADAPTIVE  FILTER
*******************************************************

order       .set	64               ;  Filter order
mu          .set     	0.01             ;  Step size
power       .set      	1.0              ;  Input  signal  power
alpha       .set       	0.996  
alphal      .set      	0.004            ;   1.0 – alpha

*
* INITIALIZE  POINTERS  AND  ARRAYS
*

            .text

Begin       .set        $
	LDI	order,BK         	; Set up circular buffer
	LDP	@xn_addr        	; Set data page
	LDI 	@xn_addr,AR0    	; Set pointer for x[]
	LDI   	@wn_addr,AR1    	; Set pointer for w[]
	LDF      0.0,R0                	; R0 = 0.0
	RPTS     order-1
	STF      R0,*AR0++(1)%        	; x[] = 0
||  	STF      R0,*AR1++(1)%        	; w[] = 0
    	LDI      @in_addr,AR6          	; Set pointer for input ports
    	LDI      @out_addr,AR7         	; Set pointer for output ports

Input:
	LDF      *AR6,R7              ; Input d(n)
|| 	LDF      *+AR6(1),R6          ; input x(n)
        STF      R6,*AR0             ; Insert x(n) to buffer

*
*  ESTIMATE  THE  POWER  OF  THE  INPUT  SIGNAL
*

	MPYF   	R6,R6             	;  R6 = x2
	MPYF   	@r_1,R6           	;  R6 = (1-r) * x2
	LDF    	@r, R3 
	MPYF   	@var,R3           	;  R3 = r * var(n-1)

*
* COMPUTE  FILTER  OUTPUT  y(n)
*

     	LDF        0.0,R2           		;  R2 = 0.0
*
        MPYF3      *AR0++(1)%,*AR1++(1)%,R1
||	ADDF       R6,R3
        STF        R3,@var           		;  Restere var(n)
        RPTS       order-2
*
	MPYF3      *AR0++(1)%,*AR1++(1)%,R1
||	ADDF3      R1,R2,R2          		; y(n) = w[].x[]
	ADDF       R1,R2        		; Include last result

*
* COMPUTE  ERROR  SIGNAL e(n)
*   
     
	SUBF  	R2,R7              		; e(n) = d(n) – y(n)

*
* OUTPUT  y(n)  AND  e(n)  SIGNALS
*

	STF  	R2,*AR7           		; Send out y(n)
||	STF 	R7,*+AR7(1)       		; Send out e(n)

*
* UPDATE  WEIGHTS  w(n)
*

	PUSHF      R3                ; Compute 1/var(n)
	POP        R2                ; var(n) = a * 2e
	ASH        -24,R2
	NEGI       R2
 	SUBI        1,R2              ; Now we have 2-e-1
	ASH         24,R2
    	PUSH        R2
      	POPF        R2               ; Now R2 =x[0] = 1.0 * 2-e-1.
*
     	MPYF       R2,R3,R0          ; R0 = v * x[0]
      	SUBRF      2.0,r0             ; R0 = 2.0 – v * x[0]
       	MPYF       R0,R2            ; R2 = X[1] = X[0] * (2.0 – v * X[0])
*
        MPYF      R2,R3,R0          ; R0 = v * x[1]
        SUBRF     2.0,R0             ; R0 = 2.0 – v * x[1]
        MPYF      R0,R2             ; R2 = x[2] = x[1] * (2.0 – v * x[1])
*
        MPYF      R2,R3,R0          ; R0 = v * x[2]
        SUBRF     2.0,R0             ; R0 = 2.0 – v * x[2]
        MPYF      R0,R2             ; R2 = x[3] = x[2] * (2.0 – v * x[2])
*
        MPYF      R2,R3,R0          ; R0 = v * x[3]
        SUBRF      2.0,R0                ;  R0 = 2.0 – v * x[3]
        MPYF       R0,R2                 ;  R2 = x[4] = x[3] * (2.0 – v * x[3])
        RND        R2                    ;  This minimizes error in the LSBs.
*
        MPYF       R2,R3,R0              ; R0 = v * x[4] = 1.0..01..=> 1
        SUBRF      1.0,R0                 ; R0 = 1.0 – v *x[4] =
                                             ; 0.0..01… => 0

        MPYF       R2,R0                  ; R0 = x[4] * (1.0 – v * x[4])
        ADDF       R0,R2                  ; x[5] = (x[4]*(1.0-(v*x[4])))*x[4]
        RND        R2,R0                  ; Round since this is followed
                                          ; by a MPYF.

        MPYF       @u.R7                  ; R7 = e(n) * u
	MPYF       R0,R7                  ; R7 = e(n) * u / var(n)
	MPYF3      *AR0++(1)%,R7,R1       ; R1 = e(n) * u * x(n) / var(n)
	LDI         order-3,R0            ; Initialize repeat counter
	RPTB       LMS                    ; Do i = 0, N-3
	MPYF3      *AR0++(1)%,R7,R1       ; R1 = e(n) * u * x(n-i-1) / var(n)
||	ADDF3      *AR1,R1,R2             ; R2 = wi(n) + R1


LMS     
	STF         R2,*AR1++(1)%         ; Store  wi(n+1)
        MPYF3      *AR0,R7,R1             ; For i = N – 2
||	ADDF3      *AR1,R1,R2 
        BD          Input                 ; Delay branch
        STF         R2,*AR1++(1)%         ; Store wi(n+1)
        ADDF3      *AR1,R1,R2       
        STF         R2,*AR1++(1)%         ; Update last w

*
* DEFINE  CONSTANTS  AND  VARIABLES
*

xn	.usect     "buffer", order
wn	.usect     "coeffs", order
in_addr .usect     "vars", 1
out_addr   .usect  "vars", 1
xn_addr	.usect     "vars", 1
wn_addr	.usect     "vars", 1
u      	.usect     "vars", 1
var    	.usect     "vars", 1
r      	.usect     "vars", 1
r_1    	.usect     "vars", 1
cinit 	.sect      ".cinit"
     	.word      8,in_addr
     	.word      0804000h
      	.word      0804002h
