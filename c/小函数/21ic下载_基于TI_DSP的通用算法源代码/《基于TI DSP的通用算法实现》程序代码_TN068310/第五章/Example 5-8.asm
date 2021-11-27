
; Example 5 - 8. FIR Filter Implementation ASM Listing for the TMS320C62x DSP


* ========================================================================= *
*                                                                           *
*     TEXAS INSTRUMENTS, INC.                                               *
*                                                                           *
*     NAME                                                                  *
*           DSP_fir_gen                                                     *
*                                                                           *
*     REVISION DATE                                                         *
*         15-Feb-2002                                                       *
*                                                                           *
*   USAGE                                                                   *
*       This routine is C-callable and can be called as:                    *
*                                                                           *
*       void DSP_fir_gen                                                    *
*       (                                                                   *
*           const short *restrict x,                                        *
*           const short *restrict h,                                        *
*           short       *restrict r,                                        *
*           int nh,                                                         *
*           int nr                                                          *
*       )                                                                   *
*                                                                           *
*       x[nr+nh-1] : Input array                                            *
*       h[nh]      : Coefficient array. Must be in reverse order.           *
*       r[nr]      : Output array                                           *
*       nh         : Number of coefficients. Must be >= 5.                  *
*       nr         : Number of output samples                               *
*                                                                           *
*   DESCRIPTION                                                             *
*       Computes a real FIR filter (direct-form) using coefficients stored  *
*       in vector h. The coefficients have to be arranged in reverse        *
*       order. The real data input is stored in vector x. The filter        *
*       output result is stored in vector r. It operates on 16-bit data     *
*       with a 32-bit accumulate. The filter is nr output samples and nh    *
*       coefficients.                                                       *
*                                                                           *
*   C CODE                                                                  *
*       void DSP_fir_gen                                                    *
*       (                                                                   *
*           const short *restrict x,                                        *
*           const short *restrict h,                                        *
*           short       *restrict r,                                        *
*           int nh,                                                         *
*           int nr                                                          *
*       )                                                                   *
*       {                                                                   *
*           int i, j, sum;                                                  *
*                                                                           *
*           for (j = 0; j < nr; j++)                                        *
*           {                                                               *
*               sum = 0;                                                    *
*               for (i = 0; i < nh; i++)                                    *
*                   sum += x[i + j] * h[i];                                 *
*               r[j] = sum >> 15;                                           *
*           }                                                               *
*       }                                                                   *
*                                                                           *
*   TECHNIQUES                                                              *
*       The inner loop is unrolled four times, but the last three           *
*       accumulates are executed conditionally to allow for a number of     *
*       coefficients that is not a multiple of four. The outer loop is      *
*       unrolled twice, but the last store is executed conditionally to     *
*       allow for a number of output samples that is not a multiple of      *
*       two. Both the inner and outer loops are software pipelined.         *
*                                                                           *
*   ASSUMPTIONS                                                             *
*       nh must be >= 5.                                                    *
*                                                                           *
*   MEMORY NOTE                                                             *
*       No memory bank hits under any conditions.                           *
*                                                                           *
*   NOTES                                                                   *
*      This function is interrupt-tolerant but not interruptible.           *
*      This function is endian neutral.                                     *
*                                                                           *
*   CYCLES                                                                  *
*       (4 * ceil(nh/4) + 9) *  ceil(nr/2) + 18                             *
*                                                                           *
*       For nh = 13, nr = 19: 268 cycles                                    *
*                                                                           *
*   CODESIZE                                                                *
*       640 bytes                                                           *
*                                                                           *
* ------------------------------------------------------------------------- *
*             Copyright (c) 2002 Texas Instruments, Incorporated.           *
*                            All Rights Reserved.                           *
* ========================================================================= *


        .text
        .global _DSP_fir_gen
_DSP_fir_gen:

        STW     .D2T1   A14,*B15--[8]    ; push register (for c-callable func)
||      MV      .L1X    B15,A14

        STW     .D2T1   A13,*+B15[6]    ; push register (for c-callable func)
||      STW     .D1T2   B13,*-A14[4]    ; push register (for c-callable func)
||      SUB     .L2     B6,1,B6         ; used to do last h mults if necessary

        STW     .D1T1   A12,*-A14[3]    ; push register (for c-callable func)
||      STW     .D2T2   B11,*+B15[2]    ; push register (for c-callable func)
||      ADD     .S2     B6,4,B6         ; set up inner loop counter
||      AND     .L2     B6,3,B13        ; used to do last h mults if necessary
||      MVK     .S1     7,A13           ; used to do last h mults if necessary

        STW     .D2T2   B12,*+B15[3]    ; push register (for c-callable func)
||      SHR     .S2     B6,2,B12        ; set up inner loop counter
||      AND     .S1     A8,1,A12        ; used to do last r store if necessary
||      ADD     .L1     A8,1,A8         ; set up outer loop counter
||      XOR     .L2     3,B13,B13       ; used to do last h mults if necessary

        STW     .D1T2   B10,*-A14[7]    ; push register (for c-callable func)
||      ADD     .L2X    A6,2,B11        ; set up pointer to r[1]
||      SHR     .S1     A8,1,A2         ; set up outer loop counter

        LDH     .D1     *A4++,B8        ; x0 = x[j]
||      ADD     .L2X    A4,4,B1         ; set up pointer to x[j+2]
||      ADD     .L1X    B4,2,A8         ; set up pointer to h[1]
||[A2]  SUB     .S1     A2,1,A2         ; decrement outer loop counter

        LDH     .D2     *B1++[2],B0     ; x2 = x[j+i+2]
||      LDH     .D1     *A4++[2],A0     ; x1 = x[j+i+1]
||      SHR     .S2X    A13,B13,B13     ; used to do last h mults if necessary
||      XOR     .S1     A12,1,A12       ; used to do last r store if necessary

        LDH     .D1     *A8++[2],B6     ; h1 = h[i+1]
||      LDH     .D2     *B4++[2],A14    ; h0 = h[i]
||      SHL     .S1     B12,3,A3        ; used to rst x pointer each outer loop
||      SHL     .S2     B12,3,B10       ; used to rst h pointer each outer loop

        LDH     .D1     *A4++[2],A5     ; x3 = x[j+i+3]
||      LDH     .D2     *B1++[2],B5     ; x0 = x[j+i+4]
||      ADD     .L1     A3,10,A3                ; used to rst x pointer each outer loop
||      ADD     .L2     B10,8,B10       ; used to rst h pointer each outer loop
||      ADD     .S1X    B13,0,A13       ; used to do last h mults if necessary

OUTLOOP:
        LDH     .D2     *B4++[2],A7     ; h2 = h[i+2]
||      LDH     .D1     *A8++[2],B8     ; h3 = h[i+3]
||      ZERO    .L1     A9              ; zero out sum0
||      ZERO    .L2     B9              ; zero out sum1
||      B               NO_INT

        LDH     .D2     *B1++[2],B0     ;* x2 = x[j+i+2]
||      LDH     .D1     *A4++[2],A0     ;* x1 = x[j+i+1]
||      SUB     .S2     B12,2,B2        ; set up inner loop counter

        LDH     .D1     *A8++[2],B6     ;* h1 = h[i+1]
||      LDH     .D2     *B4++[2],A14    ;* h0 = h[i]

        MPY     .M1X    B8,A14,A0       ; x0 * h0
||      MPY     .M2X    A0,B6,B6        ; x1 * h1
||      LDH     .D1     *A4++[2],A5     ;* x3 = x[j+i+3]
||      LDH     .D2     *B1++[2],B5     ;* x0 = x[j+i+4]

  [B2]  B       .S1     LOOP            ; branch to loop
||      MPY     .M2     B0,B6,B7        ; x2 * h1
||      MPY     .M1     A0,A14,A14      ; x1 * h0
||      LDH     .D2     *B4++[2],A7     ;* h2 = h[i+2]
||      LDH     .D1     *A8++[2],B8     ;* h3 = h[i+3]
||[B2]  SUB     .S2     B2,1,B2         ;* decrement loop counter

        ADD     .L1     A0,A9,A9        ; sum0 += x0 * h0
||      MPY     .M2X    A5,B8,B8        ; x3 * h3
||      MPY     .M1X    B0,A7,A5        ; x2 * h2
||      LDH     .D2     *B1++[2],B0     ;** x2 = x[j+i+2]
||      LDH     .D1     *A4++[2],A0     ;** x1 = x[j+i+1]

NO_INT:
LOOP:
        ADD     .L2X    A14,B9,B9       ; sum1 += x1 * h0
||      ADD     .L1X    B6,A9,A9        ; sum0 += x1 * h1
||      MPY     .M2     B5,B8,B7        ; x0 * h3
||      MPY     .M1     A5,A7,A7        ; x3 * h2
||      LDH     .D1     *A8++[2],B6     ;** h1 = h[i+1]
||      LDH     .D2     *B4++[2],A14    ;** h0 = h[i]

        ADD     .L2     B7,B9,B9        ; sum1 += x2 * h1
||      ADD     .L1     A5,A9,A9        ; sum0 += x2 * h2
||      MPY     .M1X    B5,A14,A0       ;* x0 * h0
||      MPY     .M2X    A0,B6,B6        ;* x1 * h1
||      LDH     .D1     *A4++[2],A5     ;** x3 = x[j+i+3]
||      LDH     .D2     *B1++[2],B5     ;** x0 = x[j+i+4]

        ADD     .L2X    A7,B9,B9        ; sum1 += x3 * h2
||      ADD     .L1X    B8,A9,A9        ; sum0 += x3 * h3
||[B2]  B       .S1     LOOP            ;* branch to loop
||      MPY     .M2     B0,B6,B7        ;* x2 * h1
||      MPY     .M1     A0,A14,A14      ;* x1 * h0
||      LDH     .D2     *B4++[2],A7     ;** h2 = h[i+2]
||      LDH     .D1     *A8++[2],B8     ;** h3 = h[i+3]
||[B2]  SUB     .S2     B2,1,B2         ;** decrement loop counter

        ADD     .L2     B7,B9,B9        ; sum1 += x0 * h3
||      ADD     .L1     A0,A9,A9        ;* sum0 += x0 * h0
||      MPY     .M2X    A5,B8,B8        ;* x3 * h3
||      MPY     .M1X    B0,A7,A5        ;* x2 * h2
||      LDH     .D2     *B1++[2],B0     ;*** x2 = x[j+i+2]
||      LDH     .D1     *A4++[2],A0     ;*** x1 = x[j+i+1]
||[!B2] AND     .S1     A13,1,A1        ; nh % 4 >= 1? (for h1)
        ; inner loop branch occurs here

        ADD     .L2X    A14,B9,B9       ;e sum1 += x1 * h0
||[A1]  ADD     .L1X    B6,A9,A9        ;e sum0 += x1 * h1
||      MPY     .M2     B5,B8,B7        ;e x0 * h3
||      MPY     .M1     A5,A7,A7        ;e x3 * h2
||      SUB     .D1     A4,A3,A4        ;o reset x pointer to x[j]
||      SUB     .D2     B4,B10,B4       ;o reset h pointer to h[0]
||      AND     .S2     B13,2,B2        ;e nh % 4 >= 2? (for h2)

  [A1]  ADD     .D2     B7,B9,B9        ;e sum1 += x2 * h1
||[B2]  ADD     .L1     A5,A9,A9        ;e sum0 += x2 * h2
||      LDH     .D1     *A4++,B8        ;p x0 = x[j]
||      ADD     .L2X    A4,4,B1         ;p set up pointer to x[j+2]
||      ADD     .S1X    B4,2,A8         ;p set up pointer to h[1]
||[A2]  B       .S2     OUTLOOP         ;o branch to outer loop

        AND     .S1     A13,4,A1        ;e nh % 4 >= 3? (for h3)
||      ADD     .L2     B8,0,B0         ;e save B8
||      ADD     .L1     A7,0,A0         ;e save A0

  [B2]  ADD     .L2X    A0,B9,B9        ;e sum1 += x3 * h2
||[A1]  ADD     .L1X    B0,A9,A9        ;e sum0 += x3 * h3
||      LDH     .D2     *B1++[2],B0     ;p x2 = x[j+i+2]
||      LDH     .D1     *A4++[2],A0     ;p x1 = x[j+i+1]

  [A1]  ADD     .L2     B7,B9,B9        ;e sum1 += x0 * h3
||      SHR     .S1     A9,15,A9        ;e sum0 >> 15
||      LDH     .D1     *A8++[2],B6     ;p h1 = h[i+1]
||[A2]  LDH     .D2     *B4++[2],A14    ;p h0 = h[i]
||      OR      .L1     A12,A2,A1       ;e nr % 2 = 1? OR outer loop not done (for last nr)

        SHR     .S2     B9,15,B9        ;e sum1 >> 15
||      LDH     .D1     *A4++[2],A5     ;p x3 = x[j+i+3]
||      LDH     .D2     *B1++[2],B5     ;p x0 = x[j+i+4]
||[A2]  SUB     .S1     A2,1,A2         ;o decrement outer loop counter

        STH     .D1     A9,*A6++[2]     ;e r[j] = sum0 >> 15
||[A1]  STH     .D2     B9,*B11++[2]    ;e r[j+1] = sum1 >> 15
        ; outer loop branch occurs here

        LDW     .D2T2   *+B15[1],B10      ; pop register (for c-callable func)
||      MV      .L1X    B15,A14

        LDW     .D2T2   *+B15[3],B12      ; pop register (for c-callable func)
||      LDW     .D1T1   *+A14[6],A13      ; pop register (for c-callable func)

        LDW     .D2T2   *+B15[4],B13      ; pop register (for c-callable func)
||      LDW     .D1T1   *+A14[5],A12      ; pop register (for c-callable func)
||      B       .S2     B3                ; return

        LDW     .D2T1   *++B15[8],A14     ; pop register (for c-callable func)
||      LDW     .D1T2   *+A14[2],B11      ; pop register (for c-callable func)

        NOP     4

* ========================================================================= *
*   End of file:  dsp_fir_gen.asm                                           *
* ------------------------------------------------------------------------- *
*             Copyright (c) 2002 Texas Instruments, Incorporated.           *
*                            All Rights Reserved.                           *
* ========================================================================= *