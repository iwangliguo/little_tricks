
; Example 6 - 24. SELMS Implementation ASM Listing for the TMS320C3x DSP


******************************************************************
*
*   TSE30 每 Adaptive transversal filter with Sign-Error LMS
*      algorithm using the TMS320C30
*
*    Algorithm:
*
*               63
*       y(n) = SUM w(k)*x(n-k)    k=0,1,2,＃,63
*             k=0
*
*       e(n) = d(n) 每 y(n)
*
*       For k = 0,1,2,＃,63
*            w(k) = w(k) + u*x(n-k)  if e(n) >= 0.0
*            w(k) = w(k) - u*x(n-k)  if e(n) < 0.0
*
*        Where we use filter order = 64 and mu = 0.01
*
*                  Chen, Chein-Chung  March,  1989
*
**************************************************************

           .copy         "dadpfltr.int"

**************************************************************
*     PERFORM ADAPTIVE FILTER
****************************************************************

order          .set            64
mu            .set            0.01

*
*     INITIALIZE POINTERS AND ARRAYS
*

              .text
Begin         .set            $
	LDI       order,BK         ; Set up circular buffer
	LDP       @xn_addr        ; Set data page
	LDI       @xn_addr,AR0    ; Set pointer for x[]
	LDI       @wn_addr,AR1    ; Set pointer for w[]
	LDF      0.0,R0                ; R0 = 0.0
	RPTS     order-1
	STF      R0,*AR0++(1)%        ; x[] = 0
||	STF      R0,*AR1++(1)%        ; w[] = 0
    	LDI      @in_addr,AR6          ; Set pointer for input ports
    	LDI      @out_addr,AR7         ; Set pointer for output ports
    	LDF     @u,R4                 ; R4 = mu
    	LDF     @u,R5                 ; R5 = mu
*
Input:
	LDF      *AR6,R7              ; Input d(n)
|| 	LDF      *+AR6(1),R6          ; input x(n)
	STF       R6,*AR0             ; Insert x(n) to buffer

*
*   COMPUTE  FILTER  OUTPUT  y(n)
*

	LDF        0.0,R2           ;  R2 = 0.0
*
	MPYF3     *AR0++(1)%,*AR1++(1)%,R1
	RPTS       order-2
	MPYF3     *AR0++(1)%,*AR1++(1)%,R1
*
||	ADDF3      R1,R2,R2        ; y(n) = w[].x[]
	ADDF      R1,R2             ; Include last result
*
*   COMPUTE  ERROR  SIGNAL e(n)
*          
	SUBF      R2,R7              ; e(n) = d(n) 每 y(n)

*
*   OUTPUT  y(n)  AND  e(n)  SIGNALS
*

	STF        R2,*AR7           ; Send out y(n)
||	STF         R7,*+AR7(1)       ; Send out e(n)

*
*   UPDATE WEIHTS w(n)
*

	ASH         -31,R7             ; Get Sign[e(n)]
	XOR3        R4,R7,R5          ; R5 = S[e(n)] * u
	MPYF3       *AR0++(1)%,R5,R1  ; R1 = S[e(n)] * u * x(n)
	LDI          order-3,RC         ; Initialize repeat counter
	RPTB        SELMS            ; Do i = 0, N-3     
	MPYF3       *AR0++(1)%,R5,R1  ; R1 = S[e(n)] * u * x(n-i-1)
||	ADDF3       *AR1,R1,R2        ; R2 = wi(n) + S[e(n)] * u* x(n-i)

SELMS
	STF         R2,*AR1++(1)%     ; wi(n+1) = wi(n) + S[e(n)] * u* x(n-i)
	MPYF3      *AR0,R5,R1         ; For I = N 每 2
||	ADDF3      *AR1,R1,R2
	BD          input                ; Delay branch
	STF         R2,*AR1++(1)%      ; wi(n+1) = wi(n) + S[e(n)]* u * x(n-i)
	ADDF3      *AR1,R1,R2
	STF         R2,*AR1++(1)%      ; Update last w
*
*
*     DEFINE  CONSTANTS  AND  VARIABLES
*

xn        .usect     "buffer",order
wn        .usect     "coeffs",order
in_addr    .usect     "vars",1
out_addr   .usect     "vars",1
xn_addr    .usect     "vars",1
wn_addr   .usect     "vars",1
u         .usect     "vars",1
cinit      .sect      ".cinit"
          .word      5,in_addr
          .word      0804000h
          .word      0804002h
          .word      xn
          .word      wn
          .float      mu
          .end

