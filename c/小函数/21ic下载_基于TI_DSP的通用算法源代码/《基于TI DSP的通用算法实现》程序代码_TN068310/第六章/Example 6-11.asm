

; Example 6 - 11. SSLMS Implementation ASM Listing for the TMS320C2x DSP

               .title     'TSE25'

*************************************************************
*
*    TSE25 : Adaptive Filter Using Transversal Structure
*           and Sign-Sign LMS Algorithm, Looped Code
*
*    Algorithm:
*
*             63
*       y(n) = SUM w(k)*x(n-k)    k=0,1,2,¡­,63
*             k=0
*
*       e(n) = d(n) ¨C y(n)
*
*       For k = 0,1,2,¡­,63
*            w(k) = w(k) + u  if e(n)*x(n-k) >= 0
*            w(k) = w(k) - u  if e(n)*x(n-k) < 0
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

D:             .usect            "parameters",1
Y:             .usect            "parameters",1
ERR:           .usect            "parameters",1
ONE:           .usect            "parameters",1
U:             .usect            "parameters",1
ERRF:          .usect            "parameters",1

*******************************************************
*       PERFORM  THE  ADAPTIVE  FILTER
*******************************************************

                 .text
*
*    ESTIMATE  THE  SIGNAL  Y
*

	   LARP          AR3  
           CNFP                            ; Configure B0 as program memory
           MPYK         0                  ; Clear the P register
           LAC          ONE,15             ; Using rounding
           LRLK         AR3,XN             ; Point to the oldest sample 
FIR        RPTK         ORDER-1            ; Repeat N times
           MACD        WN+0fd00h,*-        ; Estimate Y(n)
           CNFD                            ; Configure B0 as data memory
           APAC                            
           SACH         Y                  ; Store the filter output

*
*   SET  UP  THE  POINTERS
*

           LARK      AR1,ORDER-1           ; Set up counter
           LRLK      AR2,WN                ; Point to the coefficients
           LRLK      AR2,XN+1              ; Point to the data sample

*
*   CHECK THE SIGN OF ERROR
*
            NEG                            
            ADDH     D                     ; ACC = D(n) ¨C Y(n)
            SACH     ERR

*
*    UPDATE  THE  WEIGHTS
*

ADAPT      LAC          *-,0,AR2      ; ACC = X(n-k)
           XOR          ERR           ; Get the sign of ERR(n) * X(n-k)
           SACL         ERRF          ; Store the sign
           LAC          ERRF          ; Get the sign with its sign extension
           XORK         MU,15         ; Get the convergent factor MU or ¨CMU
           ADD          *,15          ; Update W(k)
           SACH         *+,1,AR1
           BANZ         ADAPT,*-,AR3
* 
FINISH      .end



