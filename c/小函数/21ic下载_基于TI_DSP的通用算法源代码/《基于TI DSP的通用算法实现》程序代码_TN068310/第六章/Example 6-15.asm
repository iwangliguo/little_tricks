

; Example 6 - 15. DLMS Implementation ASM Listing for the TMS320C62x DSP

;* ======================================================================== *;
;*  TEXAS INSTRUMENTS, INC.                                                 *;
;*                                                                          *;
;*  DSPLIB  DSP Signal Processing Library                                   *;
;*                                                                          *;
;*      Release:        Version 1.02                                        *;
;*      CVS Revision:   1.4     Sun Mar 10 00:53:44 2002 (UTC)              *;
;*      Snapshot date:  18-Apr-2002                                         *;
;*                                                                          *;
;*  This library contains proprietary intellectual property of Texas        *;
;*  Instruments, Inc.  The library and its source code are protected by     *;
;*  various copyrights, and portions may also be protected by patents or    *;
;*  other legal protections.                                                *;
;*                                                                          *;
;*  This software is licensed for use with Texas Instruments TMS320         *;
;*  family DSPs.  This license was provided to you prior to installing      *;
;*  the software.  You may review this license by consulting the file       *;
;*  TI_license.PDF which accompanies the files in this library.             *;
;* ------------------------------------------------------------------------ *;
;*          Copyright (C) 2002 Texas Instruments, Incorporated.             *;
;*                          All Rights Reserved.                            *;
;* ======================================================================== *;


* ========================================================================= *
*                                                                           *
*   TEXAS INSTRUMENTS, INC.                                                 *
*                                                                           *
*   NAME                                                                    *
*       DSP_firlms2                                                         *
*                                                                           *
*   REVISION DATE                                                           *
*       06-Mar-2002                                                         *
*                                                                           *
*   USAGE                                                                   *
*       This routine is C-callable and can be called as:                    *
*                                                                           *
*       long DSP_firlms2                                                    *
*       (                                                                   *
*           short       *restrict h,    // Coefficient Array           //   *
*           const short *restrict x,    // Input Array                 //   *
*           short b,                    // Error of from previous FIR  //   *
*           int   nh                    // Number of coefficients      //   *
*       );                                                                  *
*                                                                           *
*   DESCRIPTION                                                             *
*       This is an Least Mean Squared Adaptive FIR Filter.  Given the       *
*       error from the previous sample and pointer to the next sample       *
*       it computes an update of the coefficents and then performs          *
*       the FIR for the given input. Coefficents h[], input x[] and error   *
*       b are in Q.15 format. The output sample is returned as Q.30.        *
*                                                                           *
*       long DSP_firlms2                                                    *
*       (                                                                   *
*           short       *restrict h,                                        *
*           const short *restrict x,                                        *
*           short b,                                                        *
*           int   nh                                                        *
*       )                                                                   *
*       {                                                                   *
*           int  i;                                                         *
*           long r = 0;                                                     *
*                                                                           *
*           for (i = 0; i < nh; i++)                                        *
*           {                                                               *
*               h[i] += (x[i    ] * b) >> 15;                               *
*               r    +=  x[i + 1] * h[i];                                   *
*           }                                                               *
*                                                                           *
*           return r;                                                       *
*       }                                                                   *
*                                                                           *
*                                                                           *
*   TECHNIQUES                                                              *
*       The loop is unrolled once.                                          *
*                                                                           *
*   ASSUMPTIONS                                                             *
*       The number of coefficients nh must be a multiple of 2.              *
*                                                                           *
*   MEMORY NOTE                                                             *
*       This routine has no memory hits.                                    *
*                                                                           *
*   NOTES                                                                   *
*       This routine is interupt-tolerant but not interruptible.            *
*       This code is ENDIAN NEUTRAL.                                        *
*                                                                           *
*   CYCLES                                                                  *
*       3 * nh/2 + 26                                                       *
*       For nh = 24: 62 cycles                                              *
*       For nh = 16: 50 cycles                                              *
*                                                                           *
*   CODESIZE                                                                *
*       256 bytes.                                                          *
*                                                                           *
* ------------------------------------------------------------------------- *
*             Copyright (c) 2002 Texas Instruments, Incorporated.           *
*                            All Rights Reserved.                           *
* ========================================================================= *

        .text
        .global _DSP_firlms2
_DSP_firlms2:

                STW     .D2     B10,    *B15--[6]       ; push B10 on the stack
||              MV      .L1X    B15,    A8              ; copy stack pointer

                STW     .D2     A10,    *B15[4]         ; push A10 on the stack
||              STW     .D1     B11,    *-A8[3]         ; push B11 on the stack
||              MV      .L1X    B3,     A1              ; move return address
||              MV      .L2X    A6,     B5              ; copy b

                B       .S1     LOOP                    ; for i
||              MVK     .S2     4,      B1              ; setup priming
||              ADD     .L1X    2,      B4,     A3      ; copy x
||              LDH     .D2     *B4++[2],       A0      ;**** x0  = *x++, j=1

                ADD     .L2X    A4,     2,      B3      ; copy h
||              SHR     .S2     B6,     1,      B0      ; nh / 2
||              STW     .D2     A11,    *B15[2]         ;push A11 on the stack
||              STW     .D1     B12,    *-A8[5]         ; push B12 on the stack

                ADD     .S2     1,      B0,     B0      ; nh/2 + 1
||              ZERO    .L1     A11:A10                 ; y = 0
||              ZERO    .L2     B9:B8                   ; y = 0
||              LDH     .D1     *A3++[2],       B2      ;**** x0  = *x++, j=0
||              LDH     .D2     *B4++[2],       A0      ;**** x0  = *x++, j=1
LOOP:
        [B0]    B       .S1     LOOP                    ;* for i
||              MV      .L1X    B2,     A5              ;* copy x0, j=0
||              MPY     .M2X    1,      A0,     B6      ;* copy x0, j=1
||              SHR     .S2     B10,    15,     B10     ;* e  = f >> 15, j=1
||              MPY     .M1     A0,     A6,     A9      ;** f  = x0 * b, j=0
||              LDH     .D1     *A4++[2],       A2      ;*** h0  = *h++, j=0
||              LDH     .D2     *B3++[2],       B12     ;*** h0  = *h++, j=1
||      [B1]    SUB     .L2     B1,     1,      B1      ;* priming count

        [!B1]   STH     .D1     A7,     *-A4[8]         ; h[-1] = h1, j=0
||      [!B1]   STH     .D2     B7,     *-B3[8]         ; h[-1] = h1, j=1
||              ADD     .S1     A9,     A2,     A7      ;* h1  = h0 + e, j=0
||              ADD     .S2     B10,    B12,    B7      ;* h1  = h0 + e, j=1
||              MPY     .M2     B2,     B5,     B10     ;** f  = x0 * b, j=1

        [B0]    SUB     .S2     B0,     1,      B0      ; i++
||      [!B1]   ADD     .L1     A8,     A11:A10,A11:A10 ; y += p, j=0
||      [!B1]   ADD     .L2     B11,    B9:B8,  B9:B8   ; y += p, j=1
||              MPY     .M1     A5,     A7,     A8      ;* p  = x0 * h1, j=0
||              MPY     .M2     B6,     B7,     B11     ;* p  = x0 * h1, j=1
||              SHR     .S1     A9,     15,     A9      ;** e  = f >> 15, j=0
||              LDH     .D1     *A3++[2],       B2      ;**** x0  = *x++, j=0
||              LDH     .D2     *B4++[2],       A0      ;**** x0  = *x++, j=1
; end of LOOP

                LDW     .D2     *+ B15[4],      A10     ; pop A10 off stack
||              MV      .L2X    A1,     B3              ; move return address
||              MV      .L1X    B8,     A4              ;

                LDW     .D2     *+ B15[3],      B11     ; pop B11 off stack
||              ADD     .L1X    A11,    B9,     A5      ; sum sums

                LDW     .D2     *+ B15[2],      A11     ; pop A11 off stack
||              ADDU    .L1     A10,    A5:A4,  A5:A4   ; sum sums

                LDW     .D2     *+ B15[1],      B12     ; pop B12 off stack
||              B       .S2     B3

                LDW     .D2     *++B15[6],      B10     ; pop B10 off stack

                NOP     4

* ========================================================================= *
*   End of file:  dsp_firlms2.asm                                           *
* ------------------------------------------------------------------------- *
*             Copyright (c) 2002 Texas Instruments, Incorporated.           *
*                            All Rights Reserved.                           *
* ========================================================================= *