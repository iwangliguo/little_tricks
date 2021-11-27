
; Example 3 - 34. Extended Precision DIT Radix-2 FFT Implementation ASM Listing for the TMS320C62x DSP
	
; THIS PROGRAM IS PROVIDED "AS IS". TI MAKES NO WARRANTIES OR
; REPRESENTATIONS, EITHER EXPRESS, IMPLIED OR STATUTORY, 
; INCLUDING ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS 
; FOR A PARTICULAR PURPOSE, LACK OF VIRUSES, ACCURACY OR 
; COMPLETENESS OF RESPONSES, RESULTS AND LACK OF NEGLIGENCE. 
; TI DISCLAIMS ANY WARRANTY OF TITLE, QUIET ENJOYMENT, QUIET 
; POSSESSION, AND NON-INFRINGEMENT OF ANY THIRD PARTY 
; INTELLECTUAL PROPERTY RIGHTS WITH REGARD TO THE PROGRAM OR 
; YOUR USE OF THE PROGRAM.
;
; IN NO EVENT SHALL TI BE LIABLE FOR ANY SPECIAL, INCIDENTAL, 
; CONSEQUENTIAL OR INDIRECT DAMAGES, HOWEVER CAUSED, ON ANY 
; THEORY OF LIABILITY AND WHETHER OR NOT TI HAS BEEN ADVISED 
; OF THE POSSIBILITY OF SUCH DAMAGES, ARISING IN ANY WAY OUT 
; OF THIS AGREEMENT, THE PROGRAM, OR YOUR USE OF THE PROGRAM. 
; EXCLUDED DAMAGES INCLUDE, BUT ARE NOT LIMITED TO, COST OF 
; REMOVAL OR REINSTALLATION, COMPUTER TIME, LABOR COSTS, LOSS 
; OF GOODWILL, LOSS OF PROFITS, LOSS OF SAVINGS, OR LOSS OF 
; USE OR INTERRUPTION OF BUSINESS. IN NO EVENT WILL TI'S 
; AGGREGATE LIABILITY UNDER THIS AGREEMENT OR ARISING OUT OF 
; YOUR USE OF THE PROGRAM EXCEED FIVE HUNDRED DOLLARS 
; (U.S.$500).
;
; Unless otherwise stated, the Program written and copyrighted 
; by Texas Instruments is distributed as "freeware".  You may, 
; only under TI's copyright in the Program, use and modify the 
; Program without any charge or restriction.  You may 
; distribute to third parties, provided that you transfer a 
; copy of this license to the third party and the third party 
; agrees to these terms by its first use of the Program. You 
; must reproduce the copyright notice and any other legend of 
; ownership on each copy or partial copy, of the Program.
;
; You acknowledge and agree that the Program contains 
; copyrighted material, trade secrets and other TI proprietary 
; information and is protected by copyright laws, 
; international copyright treaties, and trade secret laws, as 
; well as other intellectual property laws.  To protect TI's 
; rights in the Program, you agree not to decompile, reverse 
; engineer, disassemble or otherwise translate any object code 
; versions of the Program to a human-readable form.  You agree 
; that in no event will you alter, remove or destroy any 
; copyright notice included in the Program.  TI reserves all 
; rights not specifically granted under this license. Except 
; as specifically provided herein, nothing in this agreement 
; shall be construed as conferring by implication, estoppel, 
; or otherwise, upon you, any license or other right under any 
; TI patents, copyrights or trade secrets.
;
; You may not use the Program in non-TI devices.
*******************************************************************************
*                                                                             *
*   TEXAS INSTRUMENTS INC.                                                    *
*                                                                             *
*   COMPLEX 32-BIT FFT (RADIX-2)                                              *
*                                                                             *
*   USAGE                                                                     *
*                                                                             *
*       This routine is C callable and can be called as                       *
*                                                                             *
*       void r2fft32(int x[], int n, int w[])                                 *
*                                                                             *
*       x[]  --- input and output sequences (dim-2*n)   (input/output)        *
*       n    --- FFT size                   (power of 2)(input)               *
*       w[]  --- FFT coefficients           (dim-n)     (input)               *
*                                                                             *
*   REVISION HISTORY                                                          *
*       7/25/2000    Written     /Mattias Ahnoff                              *
*       2/26/2001    Problems when running from far memory fixed /M. A.       *                   *  
*                                                                             *
*   C CODE                                                                    *
*       This is the C equivalent of the Assembly Code without the             *
*       assumptions listed below. Note that the assembly code is hand         *
*       optimized and assumptions may apply.                                  *
*                                                                             *
*                                                                             *
* void r2fft32C( int x[], int n, int w[])                                     *
* {                                                                           *
*         int n1,n2,ie,ia,i,j,k,l;                                            *
*         int xt,yt,c,s;                                                      *
*         int *wptr;                                                          *
*         int wcounter;                                                       *
*         int *xy_i_ptr_ld, *xy_i_ptr_st;                                     *
*         int *xy_iN2_ptr_ld, *xy_iN2_ptr_st;                                 *
*         int reset_offset;                                                   *
*                                                                             *
*         n2 = n;                                                             *
*         ie = 1;                                                             *
*                                                                             *
*         reset_offset = 2*(n-1);                                             *
*                                                                             *
*         for (k=n; k > 1; k = (k >> 1) ) {                                   *
*           n1 = n2;                                                          *
*           n2 = n2>>1;                                                       *
*           wptr = w;                                                         *
*                                                                             *
*                                                                             *
*             xy_i_ptr_ld   = x;                                              *
*             xy_i_ptr_st   = x;                                              *
*             xy_iN2_ptr_ld = x+n1;                                           *
*             xy_iN2_ptr_st = x+n1;                                           *
*             wcounter = ie;                                                  *
*             c = *wptr++;                                                    *
*             s = *wptr--;                                                    *
*             wptr += 2*ie;                                                   *
*                                                                             *
*            for (j=0; j<(n/2); j++){                                         *
*             if(!wcounter)                                                   *
*             {                                                               *
*             wcounter = ie;                                                  *
*             c = *wptr++;                                                    *
*             s = *wptr--;                                                    *
*             wptr += 2*ie;                                                   *
*                                                                             *
*             xy_i_ptr_ld  -= reset_offset;                                   *
*             xy_i_ptr_st  -= reset_offset;                                   *
*             xy_iN2_ptr_ld-= reset_offset;                                   *
*             xy_iN2_ptr_st-= reset_offset;                                   *
*             }                                                               *
*             if(wcounter)                                                    *
*          	   wcounter--;                                                *
*                                                                             *
*               xt      = *xy_iN2_ptr_ld - *xy_i_ptr_ld;                      *
*               *xy_i_ptr_st++   = *xy_i_ptr_ld++ + *xy_iN2_ptr_ld++;         *
*               yt      = *xy_iN2_ptr_ld - *xy_i_ptr_ld;                      *
*               *xy_i_ptr_st--   = *xy_i_ptr_ld-- + *xy_iN2_ptr_ld--;         *
*                                                                             *
*                                                                             *
*               *xy_iN2_ptr_st++ = _smpyh(c,xt) +                             *
*                     (_mpyluhs(c,xt)>>15) + (_mpyhslu(c,xt)>>15)+            *
*                     _smpyh(s,yt)+                                           *
*                     (_mpyluhs(s,yt)>>15) + (_mpyhslu(s,yt)>>15);            *
*                                                                             *
*               *xy_iN2_ptr_st-- = _smpyh(c,yt) +                             *
*                     (_mpyluhs(c,yt)>>15) + (_mpyhslu(c,yt)>>15)-            *
*                     _smpyh(s,xt)-                                           *
*                     (_mpyluhs(s,xt)>>15) - (_mpyhslu(s,xt)>>15);            *
*           	    xy_i_ptr_ld  += 2*n1;                                     *
*             	xy_i_ptr_st  += 2*n1;                                         *
*             	xy_iN2_ptr_ld+= 2*n1;                                         *
*             	xy_iN2_ptr_st+= 2*n1;                                         *
*             }                                                               *
*           ie = ie<<1;                                                       *
*         }                                                                   *
*       }                                                                     *
*                                                                             *
*   DESCRIPTION                                                               *
*       This routine is used to compute an "in place" FFT of a complex        *
*       sequence of size n, a power of 2, with "decimation-in-frequency"      *
*       decomposition method. The output is in bit-reversed order.            *
*       Each complex value is with interleaved 32-bit real and                *
*       imaginary parts.                                                      *
*                                                                             *
*   DEFINITIONS                                                               *
*       This implementation uses the following definition of the              *
*       FFT:                                                                  *
*       [X(1), X(2), ..., X(N-1)] = fft([x(0), x(1), ...,x(N-1)])             *
*       with                                                                  *
*       X(n) = SUM(k=0,N-1)[x(k)*exp(2*pi*n*k/N)], n=0...N-1                  *
*                                                                             *
*   TECHNIQUES                                                                *
*       Last iteration of the outer loop is lifted out to avoid some          *
*       unnesessary multiplications with trivial twiddle factors.             *
*       32-bit multiplies a*b are performed using three 16-bit multiplies.    *
*       Note that the smallest term ((a & 0xffff)*(b & 0xffff))>>31           *
*       is disregarded.                                                       *
*                                                                             *
*   SCALING                                                                   *
*       Input must be in Q(31-log2(N)-1) format (or equivalently in           *
*       [-1/(2N), 1/(2N)] in Q31 format) to prevent overflow.                 *
*                                                                             *
*   INVERSE TRANSFORM                                                         *
*       This routine could be used for calculation of the inverse transform   *
*       (IFFT) as well by simply conjugating the coefficients.                *
*       The result will be N*IFFT(x), since the IFFT is (most often)          *
*       defined with a weight factor of 1/N.                                  *
*                                                                             *
*   ASSUMPTIONS                                                               *
*       4 <= n                                                                *
*       x data is stored in the order real[0], image[0], real[1], ...         *
*       w coef is stored in the order -k*cos[0*delta], -k*sin[0*delta],       *
*       -k*cos[1*delta], ...  where delta = 2*PI/N, k = 2147483647            *
*                                                                             *
*   MEMORY                                                                    *
*       624 words                                                             *
*                                                                             *
*   CYCLES                                                                    *
*       LOG2(N) * (7 * N/2 + 22) - 3 * N/4 - 8   (=6952 for N=256)            *
*                                                                             *
*******************************************************************************
*=============================================================================*
*      Copyright (C) 2000 Texas Instruments Incorporated.                     *
*                            All Rights Reserved                              *
*=============================================================================*


                .sect    ".data:copyright_h"
_Copyright:     .string  "Copyright (C) 2000 Texas Instruments Incorporated. "
                .string  "All Rights Reserved."
                .sect    ".text:hand"
                .global _r2fft32
                .bss    stack,104,4          ; reserve space for stack
                .bss    csr_stack,4,4       ; reserve space to store csr
                .sect   ".text:hand"

_r2fft32:

        MVC     .S2     CSR, B9
        MVKL    .S2     csr_stack, B0
        MVKH    .S2     csr_stack, B0
        STW     .D2     B9, *B0
||      AND     .S2     B9, -2, B9          ;DISABLE GIE bit
        MVC     .S2     B9,  CSR            ;DISABLE Interupts

        MVKL    .S1     stack,  A0          ;new stack pointer in A0
        MVKH    .S1     stack,  A0          ;new stack pointer in A0

* SAVE C RUNTIME ENVIRONMENT **********

        STW     .D1     A15, *A0++[1]       ;**push A15 onto stack

        STW     .D1     B15, *A0++[1]       ;**push B15 onto stack

        ADD     .S2X    A0, 4, B15

        STW     .D2     B14, *B15++[2]      ;**push B14 onto stack
||      STW     .D1     A14, *A0++[2]       ;**push A14 onto stack
                                             
        STW     .D2     B13, *B15++[2]      ;**push B13 onto stack
||      STW     .D1     A13, *A0++[2]       ;**push A13 onto stack

        STW     .D2     B12, *B15++[2]      ;**push B12 onto stack
||      STW     .D1     A12, *A0++[2]       ;**push A12 onto stack

        STW     .D2     B11, *B15++[2]      ;**push B11 onto stack
||      STW     .D1     A11, *A0++[2]       ;**push A11 onto stack

        STW     .D2     B10, *B15++[1]      ;**push B10 onto stack
||      STW     .D1     A10, *A0++[2]       ;**push A10 onto stack

        STW     .D2     B3, *B15++[1]       ;**push B3 onto stack

*** BEGIN Benchmark Timing ***
B_START:

        MVK     .S1     1, A5               ;ie = 1
||      MV      .L1X    B4, A14             ;n2 = n

        SUB     .D1     A14, 1,A10          ;ro = n2 - 1
||      SHR     .S1     A14, 1, A13         ;ictr = n2>>1
        
        LMBD    .L1X    1, b4, A2           ;k = 31-log2(n)
||      MVK     .S1     31-1, A12           ;last stage hard coded

        SUB     .D1     A12, A2, A2         ;k = log2(n)-1
||      SHL     .S1     A10,3,A10           ;ro >>= 3


K_LOOP:
        MV      .S1     A5, A1              ;wctr = ie
||      ADD     .S2X    A6, 4, B0           ;wptr_s = &w[1]


        SHL     .S2X    A5, 1, B2           ;ie2b = ie<<1
||      LDW     .D2     *B0--, A8           ;s = w[1]

        ADD     .L2     B2, 1, B2           ;ie2b += 1
||      SUB     .S2X    A13, 2, B1          ;compensate for prolog

        MV      .S1     A4, A3              ;load_re = &x[0]
||      ADD     .S2X    A4, 4, B8           ;load_im = &x[1]

        MV      .L1     A14, A7             ;n1a = n2
||      MV      .L2X    A14, B5             ;n1b = n2
||      SHR     .S1     A14,1,A14           ;n2 >>= 1
||      LDW     .D2     *B0++[B2], B6       ;c = w[0]

        STW     .D2     A14, *B15++[1]      ;**push n2 onto stack

  [!A1] SUB     .S1     A3, A10, A3         ;load_re -= ro
||[!A1] SUB     .S2X    B8, A10, B8         ;load_im -= ro     
||      STW     .D2     A4, *B15++[1]       ;**push &x onto stack

        LDW     .D1     *A3++[A7], A9       ;xt1
||      LDW     .D2     *B8++[B5], B3       ;yt1

        LDW     .D1     *A3++[A7], A0       ;xt2
||      LDW     .D2     *B8++[B5], B12      ;yt2
            
        STW     .D2     A6, *B15++[1]       ;**push &w onto stack

  [!A1] LDW     .D2     *B0--, A8           ;update s

  [!A1] MV      .S1     A5, A1              ;wctr = ie
||[!A1] LDW     .D2     *B0++[B2], B6       ;update c

        SUB     .S1     A1, 1, A1           ;wctr--
||      STW     .D2     A13, *B15++[1]      ;**push ictr onto stack

  [!A1] SUB     .S1     A3, A10, A3         ;load_re -= ro
||[!A1] SUB     .S2X    B8, A10, B8         ;load_im -= ro
||      SUBAW   .D1     A3, A7, A6          ;copy
||      ADD     .L2     B12, B3, B9         ;yt3=yt1+yt2
||      STW     .D2     A2, *B15++[1]       ;**push k onto stack

        SUB     .S1     A0, A9, A2          ;xt=xt2-xt1
||      SUB     .S2     B12, B3, B10        ;yt=yt2-yt1
||      LDW     .D1     *A3++[A7], A9       ;xt1
||      LDW     .D2     *B8++[B5], B3       ;yt1
                                            
        ADD     .S1     A0, A9, A0          ;xt3=xt1+xt2
||      MV      .S2X    A8, B11             ;copy of s
||      LDW     .D1     *A3++[A7], A0       ;xt2
||      LDW     .D2     *B8++[B5], B12      ;yt2

        MPYHSLU .M1X    B6, A2, A12         ;t3a=hi(c)*lo(xt)
||      MPYHSLU .M2     B6, B10, B13        ;t3b=hi(c)*lo(yt)
||      STW     .D1     A0, *--A6[A7]       ;store x[2i]
                                            
        MPYLUHS .M1X    B6, A2, A13         ;t4a=lo(c)*hi(xt)
||      MPYLUHS .M2     B6, B10, B14        ;t4b=lo(c)*hi(xt)
||      STW     .D1     B9, *+A6[1]         ;store x[2i+1]
||[!A1] LDW     .D2     *B0--, A8           ;update s

        SHR     .S1     A12, 15, A12        ;t3a >>= 15
||      SHR     .S2     B13, 15, B13        ;t3b >>= 15
||      MPYHSLU .M1X    A8, B10, A14        ;t6a=hi(s)*lo(yt)
||      MPYHSLU .M2X    B11, A2, B4         ;t6b=hi(s)*lo(xt)
||[!A1] MV      .D1     A5, A1              ;wctr = ie
||[!A1] LDW     .D2     *B0++[B2], B6       ;update c

        SUB     .L1     A1, 1, A1           ;wctr--
||[B1]  SUB     .L2     B1, 1, B1           ;i--
||      SHR     .S1     A13, 15, A13        ;t4a >>= 15
||      SHR     .S2     B14, 15, B14        ;t4b >>= 15
||      MPYLUHS .M1X    A8, B10, A15        ;t7a=lo(s)*yt(hi)
||      MPYLUHS .M2X    B11, A2, B7         ;t7b=lo(s)*hi(xt)
 
;----INNER LOOP KERNEL STARTS HERE-------------------------
I_LOOP
  [!A1] SUB     .S1     A3, A10, A3         ;load_re -= ro
||[!A1] SUB     .L2X    B8, A10, B8         ;load_im -= ro
||      SUBAW   .D1     A3, A7, A6          ;reset load_re
||      SHR     .S2     B4, 15, B4          ;t6b >>= 15
||      SMPYH   .M1X    B6, A2, A11         ;t1a=hi(c)*hi(xt)
||      SMPYH   .M2     B6, B10, B3         ;t1b=hi(c)*yt(hi)
||      MV      .L1     A6,  A4             ;split long life of store_re
||      ADD     .D2     B12, B3, B9         ;yt3 = yt1+yt2

        SUB     .L1     A0, A9, A2          ;xt = xt2-xt1 
||      SUB     .L2     B12, B3, B10        ;yt = yt2-yt1
||      SHR     .S1     A14, 15, A14        ;t6a >>=15
||[B1]  B       .S2     I_LOOP              ;branch to loop start
||      SMPYH   .M1X    A8, B10, A9         ;t2a=hi(s)*yt(hi)
||      SMPYH   .M2X    B11, A2, B12        ;t2b=hi(s)*hi(xt)
||      LDW     .D1     *A3++[A7], A9       ;load xt1
||      LDW     .D2     *B8++[B5], B3       ;load yt1

        ADD     .L1     A0, A9, A0          ;xt3 = xt1+xt2
||      MV      .L2X    A8, B11             ;copy s to B-side
||      SHR     .S1     A15, 15, A15        ;t7a >>= 15
||      SHR     .S2     B7, 15, B7          ;t7b >>= 15
||      LDW     .D1     *A3++[A7], A0       ;load xt2
||      LDW     .D2     *B8++[B5], B12      ;load yt2

        ADD     .L1     A14, A15, A13       ;t8a = t6a+t7a
||      ADD     .D2     B4, B7, B14         ;t8b = t6b+t7b
||      ADD     .S1     A12, A13, A12       ;t5a = t3a+t4a
||      ADD     .L2     B13, B14, B13       ;t5b = t3b+t4b
||      MPYHSLU .M1X    B6, A2, A12         ;t3a = hi(c)*lo(xt)
||      MPYHSLU .M2     B6, B10, B13        ;t3b = hi(c)*lo(yt)
||      STW     .D1     A0, *--A6[A7]       ;store x[2i]
||      ADD     .S2X    A4, 4, B7           ;initialize store_im

        ADD     .S1     A11, A9, A0         ;t9a = t1a+t2a
||      SUB     .S2     B3, B12, B9         ;t9b = t1b-t2b
||      ADD     .L1     A12, A13, A14       ;t10a = t5a+t8a
||      SUB     .L2     B13, B14, B14       ;t10b = t5b-t8b
||      MPYLUHS .M1X    B6, A2, A13         ;t4a = lo(c)*hi(xt)
||      MPYLUHS .M2     B6, B10, B14        ;t4b = lo(c)*hi(yt)
||      STW     .D1     B9, *+A6[1]         ;store x[2i+1]
||[!A1] LDW     .D2     *B0--, A8           ;update s

        ADD     .L1     A0, A14, A15        ;t11a = t9a+t10a
||      ADD     .L2     B9, B14, B12        ;t11b = t9b+t10b
||      SHR     .S1     A12, 15, A12        ;t3a >>= 15
||      SHR     .S2     B13, 15, B13        ;t3b >>= 15
||      MPYHSLU .M1X    A8, B10, A14        ;t4a = hi(s)*lo(yt)
||      MPYHSLU .M2X    B11, A2, B4         ;t4b = hi(s)*lo(xt)
||[!A1] MV      .D1     A5, A1              ;reset wctr
||[!A1] LDW     .D2     *B0++[B2], B6       ;load c

        SUB     .L1     A1, 1, A1           ;wctr--
||[B1]  SUB     .L2     B1, 1, B1           ;i--
||      SHR     .S1     A13, 15, A13        ;t4a >>= 15
||      SHR     .S2     B14, 15, B14        ;t4b >>= 15
||      MPYLUHS .M1X    A8, B10, A15        ;t6a = lo(s)*hi(yt)
||      MPYLUHS .M2X    B11, A2, B7         ;t6b = hi(s)*lo(xt)
||      STW     .D1     A15, *++A4[A7]      ;store x[2(i+n2)]
||      STW     .D2     B12, *++B7[B5]      ;store x[2(i+n2)+1]
;----INNER LOOP KERNEL ENDS HERE---------------------------------

        SUBAW   .D1     A3, A7, A6          ;reset load_re
||      SHR     .S2     B4, 15, B4          ;t6b >>= 15
||      SMPYH   .M1X    B6, A2, A11         ;t1a=hi(c)*hi(xt)
||      SMPYH   .M2     B6, B10, B3         ;t1b=hi(c)*yt(hi)
||      MV      .S1     A6,  A4             ;split long life of store_re
||      ADD     .D2     B12, B3, B9         ;yt3 = yt1+yt2

        SUB     .L1     A0, A9, A2          ;xt = xt2-xt1 
||      SUB     .L2     B12, B3, B10        ;yt = yt2-yt1
||      SHR     .S1     A14, 15, A14        ;t6a >>=15
||      SMPYH   .M1X    A8, B10, A9         ;t2a=hi(s)*yt(hi)
||      SMPYH   .M2X    B11, A2, B12        ;t2b=hi(s)*hi(xt)

        ADD     .L1     A0, A9, A0          ;xt3 = xt1+xt2
||      MV      .L2X    A8, B11             ;copy s to B-side
||      SHR     .S1     A15, 15, A15        ;t7a >>= 15
||      SHR     .S2     B7, 15, B7          ;t7b >>= 15

        ADD     .L1     A14, A15, A13       ;t8a = t6a+t7a
||      ADD     .L2     B4, B7, B14         ;t8b = t6b+t7b
||      ADD     .S1     A12, A13, A12       ;t5a = t3a+t4a
||      ADD     .D2     B13, B14, B13       ;t5b = t3b+t4b
||      MPYHSLU .M1X    B6, A2, A12         ;t3a = hi(c)*lo(xt)
||      MPYHSLU .M2     B6, B10, B13        ;t3b = hi(c)*lo(yt)
||      STW     .D1     A0, *--A6[A7]       ;store x[2i]
||      ADD     .S2X    A4, 4, B7           ;initialize store_im

        ADD     .S1     A11, A9, A0         ;t9a = t1a+t2a
||      SUB     .S2     B3, B12, B9         ;t9b = t1b+t2b
||      ADD     .L1     A12, A13, A14       ;t10a = t5a+t8a
||      SUB     .L2     B13, B14, B14       ;t10b = t5b-t8b
||      MPYLUHS .M1X    B6, A2, A13         ;t4a = lo(c)*hi(xt)
||      MPYLUHS .M2     B6, B10, B14        ;t4b = lo(c)*hi(yt)
||      STW     .D1     B9, *+A6[1]         ;store x[2i+1]
||      LDW     .D2     *--B15[1], A2       ;**pop k from stack


        ADD     .D1     A0, A14, A15        ;t11a = t9a+t10a
||      ADD     .D2     B9, B14, B12        ;t11b = t9b+t10b
||      SHR     .S1     A12, 15, A12        ;t3a >>= 15
||      SHR     .S2     B13, 15, B13        ;t3b >>= 15
||      MPYHSLU .M1X    A8, B10, A14        ;t4a = hi(s)*lo(yt)
||      MPYHSLU .M2X    B11, A2, B4         ;t4b = hi(s)*lo(xt)

        SHR     .S1     A13, 15, A13        ;t4a >>= 15
||      SHR     .S2     B14, 15, B14        ;t4b >>= 15
||      MPYLUHS .M1X    A8, B10, A15        ;t6a = lo(s)*hi(yt)
||      MPYLUHS .M2X    B11, A2, B7         ;t4b = hi(s)*lo(xt)
||      STW     .D1     A15, *++A4[A7]      ;store x[2(i+n2)]
||      STW     .D2     B12, *++B7[B5]      ;store x[2(i+n2)+1]

        SHR     .S2     B4, 15, B4          ;t6b >>= 15
||      SMPYH   .M1X    B6, A2, A11         ;t1a=hi(c)*hi(xt)
||      SMPYH   .M2     B6, B10, B3         ;t1a=hi(c)*yt(hi)
||      MV      .D1     A6,  A4             ;split long life of store_re
||      SHL     .S1     A5, 1, A5           ;yt3 = yt1+yt2
||      LDW     .D2     *--B15[1], A13      ;**pop ict from stack

        SHR     .S1     A14, 15, A14        ;t6a >>=15
||      SMPYH   .M1X    A8, B10, A9         ;t2a=hi(s)*yt(hi)
||      SMPYH   .M2X    B11, A2, B12        ;t2b=hi(s)*hi(xt)

        SHR     .S1     A15, 15, A15        ;t7a >>= 15
||      SHR     .S2     B7, 15, B7          ;t7b >>= 15
||[A2]  SUB     .D1     A2, 1, A2           ;k--
||      LDW     .D2     *--B15[1], A6       ; pop &w from stack

        ADD     .D1     A14, A15, A13       ;t8a = t6a+t7a
||      ADD     .D2     B4, B7, B14         ;t8b = t6b+t7b
||      ADD     .L1     A12, A13, A12       ;t5a = t3a+t4a
||      ADD     .L2     B13, B14, B13       ;t5b = t3b+t4b
||      ADD     .S2X    A4, 4, B7           ;initialize store_im
||[A2]  B       .S1     K_LOOP              ;branch to K_LOOP

        ADD     .S1     A11, A9, A0         ;t9a = t1a+t2a
||      SUB     .S2     B3, B12, B9         ;t9b = t1b+t2b
||      ADD     .D1     A12, A13, A14       ;t10a = t5a+t8a
||      SUB     .D2     B13, B14, B14       ;t10b = t5b-t8b

        ADD     .S1     A0, A14, A15        ;t11a = t9a+t10a
||      ADD     .S2     B9, B14, B12        ;t11b = t9b+t10b

        STW     .D1     A15, *++A4[A7]      ;store x[2(i+n)]
||      STW     .D2     B12, *++B7[B5]      ;store x[2(i+n)+1]

        LDW     .D2     *--B15[1], A4       ;**pop &x from stack

        LDW     .D2     *--B15[1], A14      ;**pop n2 from stack

END_K_LOOP:

;---- LAST ITERATION OF k loop-------- 
        NOP 2                               ;need to wait for &x
      
        SUB     .S2X    A13, 2, B1          ;compensate for prolog

        MV      .S1     A4, A3              ;load_re = &x[0]
||      ADD     .S2X    A4, 4, B8           ;load_im = &x[1]
 
        MV      .S1     A4, A4              ;store_re = &x[0]
||      ADD     .S2X    A4, 4, B7           ;store_im = &x[1]
              
        LDW     .D1     *A3++[2], A9        ;load xt1
||      LDW     .D2     *B8++[2], B3        ;load yt1
     
        LDW     .D1     *A3++[2], A0        ;load xt2
||      LDW     .D2     *B8++[2], B12       ;load yt2

        LDW     .D1     *A3++[2], A9        ;load xt1
||      LDW     .D2     *B8++[2], B3        ;load yt1

  [B1]  SUB     .S2     B1, 1, B1           ;decrement inner loop counter

  [B1]  B       .S2     I_LAST              ;branch to I_LAST
        LDW     .D1     *A3++[2], A0        ;load xt2
||      LDW     .D2     *B8++[2], B12       ;load yt2

;----I_LAST KERNEL STARTS HERE--------------------------------
I_LAST:
        ADD     .L1     A9, A0, A1          ;xt3 = xt1+xt2
||      ADD     .L2     B3, B12, B9         ;yt3 = yt1+yt2
||      SUB     .S1     A9, A0, A2          ;xt = xt1-xt2 
||      SUB     .S2     B3, B12, B10        ;yt = yt1-yt2
||      LDW     .D1     *A3++[2], A9        ;load xt1
||      LDW     .D2     *B8++[2], B3        ;load yt1
    
  [B1]  SUB     .S2     B1, 1, B1           ;decrement inner loop counter
||      STW     .D1     A1, *A4++[2]        ;store x[2i]
||      STW     .D2     B9, *B7++[2]        ;store x[2i+1]

  [B1]  B       .S2     I_LAST              ;branch to I_LAST
||      STW     .D1     A2, *A4++[2]        ;store x[2(i+n2)]
||      STW     .D2     B10, *B7++[2]       ;store x[2(i+n2+1)]

        LDW     .D1     *A3++[2], A0        ;load xt2
||      LDW     .D2     *B8++[2], B12       ;load yt2
;----I_LAST KERNEL ENDS HERE--------------------------------

        ADD     .S1     A9, A0, A1          ;xt3 = xt1+xt2
||      ADD     .S2     B3, B12, B9         ;yt3 = yt1+yt2
||      SUB     .D1     A9, A0, A2          ;xt = xt1-xt2  
||      SUB     .D2     B3, B12, B10        ;yt = yt1-yt2
    
        STW     .D1     A1, *A4++[2]        ;store x[2i]
||      STW     .D2     B9, *B7++[2]        ;store x[2i+1]

        STW     .D1     A2, *A4++[2]        ;store x[2(i+n2)]

        STW     .D2     B10, *B7++[2]       ;store x[2(i+n2)+1]

        ADD     .L1     A9, A0, A1          ;xt3 = xt1+xt2
||      ADD     .L2     B3, B12, B9         ;yt3 = yt1+yt2
||      SUB     .S1     A9, A0, A2          ;xt = xt1-xt2
||      SUB     .S2     B3, B12, B10        ;yt = yt1-yt2
    
        STW     .D1     A1, *A4++[2]        ;store x[2i]
||      STW     .D2     B9, *B7++[2]        ;store x[2i+1]

        STW     .D1     A2, *A4++[2]        ;store x[2(i+n2)]
||      STW     .D2     B10, *B7++[2]       ;store x[2(i+n2)+1]


B_END:

******  END Benchmark Timing ***

;RESTORE C RUNTIME ENVIRONMENT

        LDW     .D2     *--B15[1], B3       ;**pop B3 from stack
||      SUB     .S1X    B15, 4, A0          ;copy SP to A-side

        LDW     .D2     *--B15[1], B10      ;**pop B10 from stack
||      LDW     .D1     *--A0[2], A10       ;**pop A10 from stack

        LDW     .D2     *--B15[2], B11      ;**pop B11 from stack
||      LDW     .D1     *--A0[2], A11       ;**pop A11 from stack

        LDW     .D2     *--B15[2], B12      ;**pop B12 from stack
||      LDW     .D1     *--A0[2], A12       ;**pop A12 from stack

        LDW     .D2     *--B15[2], B13      ;**pop B13 from stack
||      LDW     .D1     *--A0[2], A13       ;**pop A13 from stack

        LDW     .D2     *--B15[2], B14      ;**pop B14 from stack
||      LDW     .D1     *--A0[2], A14       ;**pop A14 from stack

        LDW     .D2     *--B15[2], B15      ;**pop B15 from stack
||      LDW     .D1     *--A0[2], A15       ;**pop A15 from stack

        MVKL    .S2     csr_stack,  B1
        MVKH    .S2     csr_stack,  B1

;Re-enable interupts

        LDW     .D2     *B1, B9
        B       .S2     B3             ;return to calling function
        NOP  3
        MVC     .S2     B9, CSR        ; restore interrupts

*******************************************************************************
*      END OF r2fft32                                                         *
*******************************************************************************

