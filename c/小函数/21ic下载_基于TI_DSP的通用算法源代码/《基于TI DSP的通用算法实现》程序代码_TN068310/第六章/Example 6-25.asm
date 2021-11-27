
; Example 6 - 25. SSLMS Implementation ASM Listing for the TMS320C3x DSP


******************************************************************
*
*   TSS30 ¨C Adaptive transversal filter with Sign-Sign LMS
*      algorithm using the TMS320C30
*
*    Algorithm:
*
*               63
*       y(n) = SUM w(k)*x(n-k)    k=0,1,2,¡­,63
*             k=0
*
*       e(n) = d(n) ¨C y(n)
*
*       For k = 0,1,2,¡­,63
*            w(k) = w(k) + u  if x(n-k) *e(n) >= 0.0
*            w(k) = w(k) - u  if x(n-k) *e(n) < 0.0
*
*        Where we use filter order = 64 and mu = 0.01
*
*                  Chen, Chein-Chung  March,  1989
*
**************************************************************
           
		.copy         "dadpfltr.int"

order          .set            64
mu            .set            0.01

*
*     INITIALIZE POINTERS AND ARRAYS
*
              .text
Begin         .set            
	LDI       order,BK         ; Set up circular buffer
	LDP       @xn_addr        ; Set data page
	LDI       @xn_addr,AR0    ; Set pointer for x[]
	LDI       @wn_addr,AR1    ; Set pointer for w[]
	LDF      0.0,R0                ; R0 = 0.0
	RPTS     order-1
	STF      R0,*AR0++(1)%        ; x[] = 0
||	STF      R0,*AR1++(1)%        ; w[] = 0
    	LDF      @u,R0                ; R0 = mu
    	LDF      @u,R4                ; R4 = mu
    	LDF      @u,R5                 ; R5 = mu
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
*   UPDATE WEIHTS w(n)
*

	ASH         -31,R7             ; R7 = Sign[e(n)]
	XOR3        R0,R7,R5          ; R5 = Sign[e(n)] * u
	LDF         *AR0++(1)%,R6     ; R6 = x(n)
	ASH         -31,R6             ; R6 = Sign[e(n-i)]
	XOR3        R5,R6,R4          ; R4 = Sign[e(n-i)] * Sign[e(n)] * u
	ADDF3       *AR1,R4,R3       ; R3 = wi(n) +R4

    	LDI          order-3,RC         ; Initialize repeat counter
     	RPTB        SSLMS            ; Do i = 0, N-3     
     	LDF         *AR0++(1)%,R6     ; Get next data
||	STF        R3,*AR1++(1)%     ; Update wi(n+1)
	ASH       -31,R6             ; Get the sign of data
	XOR3      R5,R6,R4           ; Decide the sign of u

SSLMS     
	ADDF3      *AR1,R4,R3         ;R3 = wi(n) + R4
	LDF         *AR0,R6           ;Get last data
||	STF        R3,*AR1++(1)%     ; Updata wN-2(n+1)
	ASH        -31,R6              ; Get the sign of data
	BD         input                ; Delay branch
	XOR3      R5,R6,R4            ; Decide the sign of u
 	ADDF3     *AR1,R4,R3          ; Compute wN-1(n+1)
	STF        R3,*AR1++(1)%      ; Store last w(n+1)

*
*     DEFINE  CONSTANTS  
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

