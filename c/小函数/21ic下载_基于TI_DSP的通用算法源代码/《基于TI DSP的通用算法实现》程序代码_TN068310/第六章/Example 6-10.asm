
; Example 6 - 10. SELMS Implementation ASM Listing for the TMS320C2x DSP


               .title	'TSE25'

*************************************************************
*
*    TSE25 : Adaptive Filter Using Transversal Structure
*           and Sign-Error LMS Algorithm, Looped Code
*
*    Algorithm:
*
*             63
*       y(n) = SUM w(k)*x(n-k)    k=0,1,2,бн,63
*             k=0
*
*       e(n) = d(n) иC y(n)
*
*       For k = 0,1,2,бн,63
*            w(k) = w(k) + u*x(n-k)  if e(n) >= 0
*            w(k) = w(k) - u*x(n-k)  if e(n) < 0
*
*        Where we use filter order = 64 and mu = 0.01
*
*   Note: This source program is the generic version; I/O configuration has
*        not been set up. User has to modify the main routine for specific
*        application
*
*     Initial condition:
*        1) PM status bit should be equal to 01.
*        2) SXM status bit should be set to 1.
*        3) The current DP (data memory page pointer) should be page 0.
*        4) Data memory ONE should be 1.
*        5) Data memory U should be 327.
*        6) Data memory NEGMU should be -327.
*
*                     Chen,Chein-Chung   February, 1989
*
***************************************************************

*
*     DEFINE PARAMETERS
*

ORDER:      .equ     64
PAGEO:      .equ      0

*
*     DEFINE ADDRESSES OF BUFFER AND COEFFICIENTS
*

X0:           .usect          "buffer", ORDER-1
XN:           .usect          "buffer", 1
WN:           .usect          "coeffs", ORDER

*
*    RESERVE  ADDRESSES  FOR  PARAMETERS
*

D:            .usect            "parameters", 1
Y:            .usect            "parameters", 1
ERR:          .usect            "parameters", 1
ONE:          .usect            "parameters", 1
U:            .usect            "parameters", 1
ERRF:         .usect            "parameters", 1
NEGMU:        .usect            "parameters", 1

*******************************************************
*       PERFORM  THE  ADAPTIVE  FILTER
*******************************************************

                 .text
*
*    ESTIMATE  THE  SIGNAL  Y
*

       	    LARP         AR3  
            CNFP                             ; Configure B0 as program memory
            MPYK         0                  ; Clear the P register
            LAC          ONE,15             ; Using rounding
            LRLK         AR3,XN             ; Point to the oldest sample 
FIR         RPTK         ORDER-1           ; Repeat N times
            MACD         WN+0fd00h,*-        ; Estimate Y(n)
            CNFD                            ; Configure B0 as data memory
            APAC                            
            SACH         Y                  ; Store the filter output

*
*   CHECK THE SIGN OF ERROR
*

            LT           U                 ; T register = U
            NEG                            ; ACC = - Y(n)
            ADDH         D                 ; ACC = D(n) иC Y(n)
            BGEZ         NEXT
            LT           NEGMU             ; T register = -U

*
*    UPDATE  THE  WEIGHTS
*

NEXT       LARK         AR1,ORDER-1      ; Set up counter
           LRLK         AR2,WN           ; Point to the coefficients
           LRLK         AR3,XN+1         ; Point to the data sample
           MPY          *-,AR2           ; P = U * X(n-k)
ADAPT      ZALR         *,AR3            ; Load ACCH with W(k,n) & round
           MPYA         *-,AR2           ;W(k,n+1) = W(k,n) + P

*                                        ; P = U * X(n-k)

           SACH         *+,0,AR1         ; Store W(k,n+1)
           BANZ         ADAPT,*-,AR2
*

FINISH     .end

