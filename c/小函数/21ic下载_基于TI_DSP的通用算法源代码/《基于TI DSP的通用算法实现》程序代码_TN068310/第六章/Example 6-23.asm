
; Example 6 - 23. LLMS Implementation ASM Listing for the TMS320C3x DSP

*************************************************************
*
*    TL30 : Adaptive Transversal Filter with Leaky-LMS Algorithm 
*           using the TMS320C30
*
*    Algorithm:
*
*             63
*       y(n) = SUM w(k)*x(n-k)    k=0,1,2,¡­,63
*             k=0
*
*       e(n) = d(n) ¨C y(n)
*
*      w(k) = r*w(k) + u*e(n)*x(n-k)   k=0,1,2,..63
*
*        Where we use filter order = 64   r = 0.995 and mu = 0.01
*
*                     Chen,Chein-Chung   February, 1989
*
***************************************************************

           .copy  "adapfltr.int"

********************************************************
*     PERFORM ADAPTIVE FILTER
************************************************

order     	.set            64
mu_leaky   	.set            0.01005                 ;mu / leaky
leaky       	.set            0.995

*
*     INITIALIZE POINTERS AND ARRAYS
*

              .text
Begin         .set            
	LDI       order,BK         ; Set up circular buffer
	LDP       @xn_addr        ; Set data page
	LDI       @xn_addr,AR0    ; Set pointer for x[]
	LDI       @wn_addr,AR1    ; Set pointer for w[]
	LDI       @r_addr,AR2     ; Set pointer for r
	LDF      0.0,R0                ; R0 = 0.0
	RPTS     order-1
	STF      R0,*AR0++(1)%        ; x[] = 0
||	STF      R0,*AR1++(1)%        ; w[] = 0
	LDI      @in_addr,AR6          ; Set pointer for input ports
	LDI      @out_addr,AR7          ; Set pointer for output ports

Input:
	LDF      *AR6,R7              ; Input d(n)
||	LDF      *+AR6(1),R6          ; input x(n)
	STF       R6,*AR0             ; Insert x(n) to buffer

*
*   COMPUTE  FILTER  OUTPUT  y(n)
*

	LDF        0.0,R2           ;  R2 = 0.0
*
	MPYF3     *AR0++(1)%,*AR1++(1)%,R1
	RPTS       order-2
	MPYF3     *AR0++(1)%,*AR1++(1)%,R1
||	ADDF3      R1,R2,R2          ; y(n) = w[].x[]
	ADDF      R1,R2             ; Include last result

*
*   COMPUTE  ERROR  SIGNAL e(n) AND OUTPUT y(n) AND e(n) SIGNALS
*  
	SUBF      R2,R7              ; e(n) = d(n) ¨C y(n)
	STF        R2,*AR7           ; Send out y(n)
||	STF         R7,*+AR7(1)       ; Send out e(n)

*
* UPDATE WEIHTS w(n)
*

	MPYF       @u_r,R7          ; R7 = e(n)*u/r
	MPYF3      *AR0++(1)%,R7,R1 ; R1 = e(n)*u*x(n)/r
	MPYF3      *AR0++(1)%,R7,R1 ; R1 = e(n)*u*x(n-1)/r
||	ADDF3      *AR1,R1,R2       ; R2 = w0(n) + e(n) * u *x(n)/r
	LDI        order-4,RC         ; Initialize repeat counter
	RPTB       LLMS            ; Do i = 0, N-4     
	MPYF3      *AR2,R2,R0        ; R0 = r*wi(n) + e(n)*u*x(n-i)
||	ADDF3      *+AR1(1),R1,R2     ; R2 = wi+1(n) + e(n)*u*x(n-i-1)/r

LLMS 	
	MPYF3      *AR0++(1)%,R7,R1  ; R1 = e(n)*u*x(n-i-2)/r 
||	STF        R0,*AR1++(1)%     ; store wi(n+1)
	MPYF3      *AR2,R2,R0           ; R0 = r*wN-3(n) + e(n)*u*x(n-N+3)
||	ADDF3      *+AR1(1),R1,R2     ; R2 = wN-2(n) + e(n)*u*x(n-N+2)/r
	MPYF3      *AR0,R7,R1        ; R1 = e(n)*u*x(n-N+1)/r    
||	STF        R0,*AR1++(1)%       ; Store wN-3(n+1)
	BD         input                 ; Delay branch
	MPYF3     *AR2,R2,R0           ; R0 = r*wi(n) + e(n)*u*x(n-N+2)
||	ADDF3      *+AR1(1),R1,R2     ; R2 = wN-1(n) + e(n)*u*x(n-N+1)/r
	MPYF3      *+AR0,R7,R1        ; R0 = r*wi(n)+e(n)*u*x(n-N+1)  
||	STF        R0,*AR1++(1)%       ; Store wN-2(n+1)
	STF        R0,*AR1++(1)%       ; Update last w

*
* DEFINE  CONSTANTS  
*

xn        .usect     "buffer",order
wn        .usect     "coeffs",order
in_addr    .usect     "vars",1
out_addr   .usect     "vars",1
xn_addr    .usect     "vars",1
wn_addr   .usect     "vars",1
u_r       .usect     "vars",1
r         .usect     "vars",1
r_addr     .usect     "vars",1
cinit      .sect       ".cinit"
          .word      7,in_addr
          .word      0804000h
          .word      0804002h
          .word      xn
          .word      wn
          .float      mu_leaky
          .float      leaky
          .word      r
 .end
