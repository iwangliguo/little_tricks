
; Example 3 - 36. DIT Radix-2 FFT Implementation ASM Listing for the TMS320C64x DSP


* ========================================================================= *
*                                                                           *
*   TEXAS INSTRUMENTS, INC.                                                 *
*                                                                           *
*   NAME                                                                    *
*       DSP_radix2 -- In-place Radix-2 FFT (Little Endian)                  *
*                                                                           *
*   REVISION DATE                                                           *
*       09-Dec-2002                                                         *
*                                                                           *
*   USAGE                                                                   *
*       This routine is C-callable and can be called as:                    *
*                                                                           *
*       void DSP_radix2(int n, short *restrict xy,                          *
*                   const short *restrict w);                               *
*                                                                           *
*       n    -- FFT size                            (input)                 *
*       xy[] -- input and output sequences (dim-n)  (input/output)          *
*       w[]  -- FFT coefficients (dim-n/2)          (input)                 *
*                                                                           *
*   DESCRIPTION                                                             *
*       This routine is used to compute FFT of a complex sequece of size    *
*       n, a power of 2, with "decimation-in-frequency decomposition"       *
*       method, ie, the output is in bit-reversed order. Each complex       *
*       value is with interleaved 16-bit real and imaginary parts. To       *
*       prevent overflow, input samples may have to be scaled by 1/n.       *
*                                                                           *
*       void DSP_radix2(int n, short *restrict xy,                          *
*                   const short *restrict w)                                *
*       {                                                                   *
*           short n1,n2,ie,ia,i,j,k,l;                                      *
*           short xt,yt,c,s;                                                *
*                                                                           *
*           n2 = n;                                                         *
*           ie = 1;                                                         *
*           for (k=n; k > 1; k = (k >> 1) )                                 *
*           {                                                               *
*               n1 = n2;                                                    *
*               n2 = n2>>1;                                                 *
*               ia = 0;                                                     *
*               for (j=0; j < n2; j++)                                      *
*               {                                                           *
*                   c = w[2*ia];                                            *
*                   s = w[2*ia+1];                                          *
*                   ia = ia + ie;                                           *
*                   for (i=j; i < n; i += n1)                               *
*                   {                                                       *
*                       l = i + n2;                                         *
*                       xt      = xy[2*l] - xy[2*i];                        *
*                       xy[2*i] = xy[2*i] + xy[2*l];                        *
*                       yt      = xy[2*l+1] - xy[2*i+1];                    *
*                       xy[2*i+1] = xy[2*i+1] + xy[2*l+1];                  *
*                       xy[2*l]   = (c*xt + s*yt)>>15;                      *
*                       xy[2*l+1] = (c*yt - s*xt)>>15;                      *
*                   }                                                       *
*               }                                                           *
*               ie = ie<<1;                                                 *
*           }                                                               *
*       }                                                                   *
*                                                                           *
*   ASSUMPTIONS                                                             *
*       16 <= n <= 32768                                                    *
*       Both input xy and coefficient w must be aligned on word boundary.   *
*       w coef stored ordered is k*(-cos[0*delta]), k*(-sin[0*delta]),      *
*       k*(-cos[1*delta]), ...  where delta = 2*PI/N, k = 32767             *
*       Assembly code is written for processor in Little Endian mode        *
*       Input xy and coefficients w are 16 bit data.                        *
*                                                                           *
*   MEMORY NOTE                                                             *
*       Align xy and w on different word boundaries to minimize             *
*       memory bank hits.                                                   *
*                                                                           *
*   TECHNIQUES                                                              *
*       1. Loading input xy as well as coefficient w in word.               *
*       2. Both loops j and i shown in the C code are placed in the         *
*          INNERLOOP of the assembly code.                                  *
*                                                                           *
*   CYCLES                                                                  *
*       cycles = log2(N) * (4*N/2+7) + 34 + N/4.                            *
*                                                                           *
*       (The N/4 term is due to bank conflicts that occur when xy and w     *
*       are aligned as suggested above, under "MEMORY NOTE.")               *
*                                                                           *
*       For N = 256, cycles = 4250.                                         *
*                                                                           *
*   CODESIZE                                                                *
*       800 bytes                                                           *
*                                                                           *
* ------------------------------------------------------------------------- *
*             Copyright (c) 2003 Texas Instruments, Incorporated.           *
*                            All Rights Reserved.                           *
* ========================================================================= *

        .sect ".text:_radix2"
        .global _DSP_radix2
_DSP_radix2:
        STW     .D2T1   A15, *B15--[12] ; push A15 to SP[12]
||      SUB     .L1X    B15, 4, A15

        STW     .D1T1   A10, *A15--[10] ; push A10 to SP[11]
||      STW     .D2T2   B10, *+B15[10]  ; push B10 to SP[10]
||      MVC     .S2     CSR, B0

        STW     .D1T1   A11, *+A15[8]   ; push A11 to SP[ 9]
||      STW     .D2T2   B11, *+B15[8]   ; push B11 to SP[ 8]
||      AND     .S2     B0, -2, B1
;-
        STW     .D1T1   A12, *+A15[6]   ; push A12 to SP[ 7]
||      STW     .D2T2   B12, *+B15[6]   ; push B12 to SP[ 6]
||      MVC     .S2     B1,  CSR
        ;== Interrupts disabled here ===

        STW     .D1T1   A13, *+A15[4]   ; push A13 to SP[ 5]
||      STW     .D2T2   B13, *+B15[4]   ; push B13 to SP[ 4]

        STW     .D1T1   A14, *+A15[2]   ; push A14 to SP[ 3]
||      STW     .D2T2   B14, *+B15[2]   ; push B14 to SP[ 2]
||      MV      .L1X    B4,A9           ; &XY
;-
        LMBD    .L1     1,A4,A1         ; outer loop count calculation
||      MV      .L2X    A4,B13          ; &N
||      STW     .D1T2   B0,  *+A15[0]   ; push CSR to SP[ 1]

        MVK     .S1     1,A2            ; IE = 1
||      MV      .D2     B13,B10         ; XY index setup
||      MV      .L1     A4,A7           ; XY index setup
||      SHL     .S2     B13,2,B14       ; calculating reset offset
||      MV      .L2X    A6,B12          ; permanent ptr for W[0]
;-
        SHR     .S2     B13,1,B13       ; used for loop count
||      SUB     .D2     B14,4,B14       ; calculating reset offset
||      SUB     .L1X    B14,4,A8        ; calculating reset offset

        ADDAH   .D1     A9,A7,A3        ; setup ptr for X[i+N2] & Y[i+N2]
||      MV      .L2X    A9,B9           ; setup ptr for X[i] & Y[i]
||      SUB     .D2     B13,4,B13       ; inner loop count
||      MVK     .S2     31,B7           ; outer loop count calculation
;-
        MV      .S2     B9,B4           ; setup store ptr for X[i] & Y[i]
||      MV      .L2     B9,B11          ; permanent ptr for X[0] & Y[0]
||      SUB     .L1X    B7,A1,A1        ; outer loop conter

        LDW     .D2     *B9++[B10],B7   ; X[i] & Y[i]
||      MV      .L2X    A2,B2           ; reset twiddle factor counter
||      LDW     .D1     *A6++[A2],A5    ; CS = W[IA] & W[IA+1]
||      SHL     .S1     A7,1,A0         ; calculating reset offset
;-
  [ B2] SUB             B2,1,B2         ; decrement twiddle factor counter
||      LDW     .D1     *A3++[A7],A13   ; X[i+N2] & Y[i+N2]

  [!B2] SUB             B9,B14,B9       ; reset load X[i] & Y[i] ptrs

  [!B2] SUB             A3,A8,A3        ; reset load X[i+N2] & Y[i+N2] ptrs

OUTLOOP:
        LDW     .D2     *B9++[B10],B7   ;* X[i] & Y[i]
||[!B2] MV      .L2X    A2,B2           ;* reset twiddle factor counter
||[!B2] LDW     .D1     *A6++[A2],A5    ;* CS = W[IA] & W[IA+1]
||      MPY     .M2     B2,1,B0         ; move to next iteration
;-
  [ B2] SUB             B2,1,B2         ;* decrement twiddle factor counter
||      LDW     .D1     *A3++[A7],A13   ;* X[i+N2] & Y[i+N2]

        SUB2    .S1X    A13,B7,A9       ; XYT = X[i]-X[i+N2] & Y[i]-Y[i+N2]
||      MV              A5,A10          ; move to other file
||      ADD2    .S2X    B7,A13,B7       ; X[i]+X[i+N2] & Y[i]+Y[i+N2]
||[!B2] SUB             B9,B14,B9       ;* reset load X[i] & Y[i] ptrs

        MPYHL   .M1     A9,A5,A14       ; (C)*(YT)
||      STW     .D2     B7,*B4++[B10]   ; XY[i] = X[i]+X[i+N2] & Y[i]+Y[i+N2]
;-
        MPYLH   .M1     A9,A5,A15       ; (S)*XT
||      LDW     .D2     *B9++[B10],B7   ;** X[i] & Y[i]
||[!B2] MV      .L2X    A2,B2           ;** reset twiddle factor counter
||[!B2] LDW     .D1     *A6++[A2],A5    ;** CS = W[IA] & W[IA+1]
||      SUB     .L1X    B4,A0,A4        ; set store X[i+N2] ptr
||      MPY     .M2     B2,1,B0         ;* move to next iteration
||[!B2] SUB             A3,A8,A3        ;* reset load X[i+N2] & Y[i+N2] ptrs
;-
        MPY     .M1     A9,A10,A13      ; (C)*XT
||[!B0] SUB             B4,B14,B4       ; reset store X[i] & Y[i] ptrs
||[ B2] SUB             B2,1,B2         ;** decrement twiddle factor counter
||      LDW     .D1     *A3++[A7],A13   ;** X[i+N2] & Y[i+N2]

        MPYH    .M1     A9,A10,A14      ; (S)*(YT)
||      SUB2    .S1X    A13,B7,A9       ;* XYT = X[i]-X[i+N2] & Y[i]-Y[i+N2]
||      ADD2    .S2X    B7,A13,B7       ;* X[i]+X[i+N2] & Y[i]+Y[i+N2]
||[!B2] SUB             B9,B14,B9       ;** reset load X[i] & Y[i] ptrs
;-
        SUB     .S1     A14,A15,A15     ; Y[i+N2] = C*YT - S*XT
||      MPYHL   .M1     A9,A5,A14       ;* (C)*(YT)
||      STW     .D2     B7,*B4++[B10]   ;* XY[i] = X[i]+X[i+N2] & Y[i]+Y[i+N2]
||[!B2] SUB     .D1     A3,A8,A3        ;** reset load X[i+N2] & Y[i+N2] ptrs
||      MV      .L2X    A4,B6           ; set store X[i+N2] ptr
||      MV      .S2     B13,B1          ; set inner loop counter
||      MV      .L1     A5,A10          ;* move to other file

        B       .S2     LOOP            ; for (i=j; i < N; i += N1)
||      ADD     .S1     A14,A13,A13     ; X[i+N2] = C*XT + S*YT
||      MPYLH   .M1     A9,A5,A15       ;* (S)*XT
||      LDW     .D2     *B9++[B10],B7   ;*** X[i] & Y[i]
||[!B2] MV      .L2X    A2,B2           ;*** reset twiddle factor counter
||[!B2] LDW     .D1     *A6++[A2],A5    ;*** CS = W[IA] & W[IA+1]
||      SUB     .L1X    B4,A0,A4        ;* set store X[i+N2] ptr
||      MPY     .M2     B2,1,B0         ;** move to next iteration

        SHR     .S2X    A13,15,B5       ; scale X[i+N2]
||      SHR     .S1     A15,15,A11      ; scale Y[i+N2]
||      MPY     .M1     A9,A10,A13      ;* (C)*XT
||[!B0] SUB     .L2     B4,B14,B4       ;* reset store X[i] & Y[i] ptrs
||[ B2] SUB     .D2     B2,1,B2         ;*** decrement twiddle factor counter
||      LDW     .D1     *A3++[A7],A13   ;*** X[i+N2] & Y[i+N2]
||      ADD     .L1X    B6,2,A12        ; set store Y[i+N2] ptr

LOOP:
        STH     .D2     B5,*B6          ; X[i+N2] = C*YT + S*XT
||      MPYH    .M1     A9,A10,A14      ;* (S)*(YT)
||      SUB2    .S1X    A13,B7,A9       ;** XYT = X[i]-X[i+N2] & Y[i]-Y[i+N2]
||      MV      .L1     A5,A10          ;** move to other file
||      ADD2    .S2X    B7,A13,B7       ;** X[i]+X[i+N2] & Y[i]+Y[i+N2]
||[!B2] SUB     .L2     B9,B14,B9       ;*** reset load X[i] & Y[i] ptrs

        SUB     .L1     A14,A15,A15     ;* Y[i+N2] = C*YT - S*XT
||      MV      .L2X    A4,B6           ;* set store X[i+N2] ptr
||[ B1] SUB     .S2     B1,1,B1         ;** dec i lp cntr
||      MPYHL   .M1     A9,A5,A14       ;** (C)*(YT)
||      STW     .D2     B7,*B4++[B10]   ;** XY[i] = X[i]+X[i+N2] & Y[i]+Y[i+N2]
||      STH     .D1     A11,*A12        ; Y[i+N2] = C*YT - S*XT
||[!B2] SUB     .S1     A3,A8,A3        ;*** reset load X[i+N2] & Y[i+N2] ptrs

  [ B1] B       .S2     LOOP            ;* for (i=j; i < N; i += N1)
||      ADD     .S1     A13,A14,A13     ;* X[i+N2] = C*XT + S*YT
||      MPYLH   .M1     A9,A5,A15       ;** (S)*XT
||      SUB     .L1X    B4,A0,A4        ;** set store X[i+N2] ptr
||      LDW     .D2     *B9++[B10],B7   ;**** X[i] & Y[i]
||[!B2] MV      .L2X    A2,B2           ;**** reset twiddle factor counter
||[!B2] LDW     .D1     *A6++[A2],A5    ;**** CS = W[IA] & W[IA+1]
||      MPY     .M2     B2,1,B0         ;*** move to next iteration

        SHR     .S2X    A13,15,B5       ;* scale X[i+N2]
||      SHR     .S1     A15,15,A11      ;* scale Y[i+N2]
||      ADD     .L1X    B6,2,A12        ;* set store Y[i+N2] ptr
||[!B0] SUB     .L2     B4,B14,B4       ;** reset store X[i] & Y[i] ptrs
||      MPY     .M1     A9,A10,A13      ;** (C)*XT
||[ B2] SUB     .D2     B2,1,B2         ;**** decrement twiddle factor counter
||      LDW     .D1     *A3++[A7],A13   ;**** X[i+N2] & Y[i+N2]
; - - - - - - - - - - - - - - - - - - - ; LOOP ENDS HERE
;-
        STH     .D2     B5,*B6          ; X[i+N2] = C*YT + S*XT
||      STH     .D1     A11,*A12        ; Y[i+N2] = C*YT - S*XT
||      MPYH    .M1     A9,A10,A14      ;* (S)*(YT)
||      SUB2    .S1X    A13,B7,A9       ;** XYT = X[i]-X[i+N2] & Y[i]-Y[i+N2]
||      MV      .L1     A5,A10          ;** move to other file
||      ADD2    .S2X    B7,A13,B7       ;** X[i]+X[i+N2] & Y[i]+Y[i+N2]
||      MV      .L2     B11,B9          ; set up load ptr to X[0] & Y[0]
;-
        SUB     .D1     A14,A15,A15     ;* Y[i+N2] = C*YT - S*XT
||      MV      .L2X    A4,B6           ;* set store X[i+N2] ptr
||      MPYHL   .M1     A9,A5,A14       ;** (C)*(YT)
||      STW     .D2     B7,*B4++[B10]   ;** XY[i] = X[i]+X[i+N2] & Y[i]+Y[i+N2]
||      SHL     .S1     A2,1,A2         ; IE << 1
||      SUB     .L1     A1,1,A1         ; decrement outer loop counter
;-
        ADD     .D1     A14,A13,A13     ;* X[i+N2] = C*XT + S*YT
||      MPYLH   .M1     A9,A5,A15       ;** (S)*XT
||      SUB     .L1X    B4,A0,A4        ;** set store X[i+N2] ptr
||      SHR     .S1     A15,15,A11      ;* scale Y[i+N2]

        SHR     .S2X    A13,15,B5       ;* scale X[i+N2]
||      ADD     .L1X    B6,2,A12        ;* set store Y[i+N2] ptr
||      MPY     .M1     A9,A10,A13      ;** (C)*XT
||[ A1] B       .S1     OUTLOOP         ; branch to next stage
;-
        STH     .D2     B5,*B6          ; X[i+N2] = C*YT + S*XT
||      STH     .D1     A11,*A12        ; Y[i+N2] = C*YT - S*XT
||      MPYH    .M1     A9,A10,A10      ;* (S)*(YT)
||      SHR     .S2     B10,1,B10       ; load index >> 1
||      SHR     .S1     A0,1,A0         ; N2 >> 1
||      MV      .L1X    B12,A6          ; reset W ptr
||      MV      .L2X    A2,B2           ; reset twiddle factor counter
;-
        MV      .L2X    A4,B6           ;* set store X[i+N2] ptr
||      LDW     .D2     *B9++[B10],B7   ; X[i] & Y[i]
||      ADD     .L1X    A7,B9,A3        ; set up load ptr to X[N2] & Y[N2]
||      LDW     .D1     *A6++[A2],A5    ; CS = W[IA] & W[IA+1]
||      SHR     .S1     A7,1,A7         ; load index >> 1
||[B2]  SUB     .S2     B2,1,B2         ; decrement twiddle factor counter
;-
        ADD     .L1     A10,A13,A13     ;* X[i+N2] = C*XT + S*YT
||      SUB     .S1     A14,A15,A15     ;* Y[i+N2] = C*YT - S*XT
||[ A1] LDW     .D1     *A3++[A7],A13   ; X[i+N2] & Y[i+N2]
||[!B2] SUB     .L2     B9,B14,B9       ; reset load X[i] & Y[i] ptrs

        SHR     .S2X    A13,15,B5       ;* scale X[i+N2]
||      SHR     .S1     A15,15,A11      ;* scale Y[i+N2]
||      ADD     .L1X    B6,2,A12        ;* set store Y[i+N2] ptr
||[!B2] SUB             A3,A8,A3        ; reset load X[i+N2] & Y[i+N2] ptrs
;-
        STH     .D2     B5,*B6          ; X[i+N2] = C*YT + S*XT
||      STH     .D1     A11,*A12        ; Y[i+N2] = C*YT - S*XT
||      SHL     .S1     A7,1,A0         ; calculating reset offset
||      MV      .S2     B11,B4          ; set up store ptr to X[0] & Y[0]
; - - - - - - - - - - - - - - - - - - - ; OUTLOOP ENDS HERE

        LDW     .D2T2   *+B15[1],  B0   ; pop CSR from SP[ 1]
||      MV              B15, A15

        LDW     .D1T1   *+A15[11], A10  ; pop A10 from SP[11]
||      LDW     .D2T2   *+B15[10], B10  ; pop B10 from SP[10]
;-
        LDW     .D1T1   *+A15[9],  A11  ; pop A11 from SP[ 9]
||      LDW     .D2T2   *+B15[8],  B11  ; pop B11 from SP[ 8]

        LDW     .D1T1   *+A15[7],  A12  ; pop A12 from SP[ 7]
||      LDW     .D2T2   *+B15[6],  B12  ; pop B12 from SP[ 6]

        LDW     .D1T1   *+A15[5],  A13  ; pop A13 from SP[ 5]
||      LDW     .D2T2   *+B15[4],  B13  ; pop B13 from SP[ 4]
;-
        LDW     .D2T2   *+B15[2],  B14  ; pop B14 from SP[ 2]
||      LDW     .D1T1   *+A15[3],  A14  ; pop A14 from SP[ 3]
||      RET             B3

        LDW     .D2T1   *++B15[12],A15  ; pop A15 from SP[12]

        MVC             B0, CSR

        NOP             3
;-

* ========================================================================= *
*    End of file: dsp_radix2.asm                                            *
* ------------------------------------------------------------------------- *
*             Copyright (c) 2003 Texas Instruments, Incorporated.           *
*                            All Rights Reserved.                           *
* ========================================================================= *
