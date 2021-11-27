
;Example 3 - 20. Complex Bit Reversion Implementation ASM Listing for TMS320C62x


* ========================================================================= *
*   TEXAS INSTRUMENTS, INC.                                                 *
*                                                                           *
*   NAME                                                                    *
*       DSP_bitrev_cplx                                                     *
*                                                                           *
*   REVISION DATE                                                           *
*       18-Sep-2001                                                         *
*                                                                           *
*   USAGE                                                                   *
*       This routine is C Callable and can be called as:                    *
*                                                                           *
*       void DSP_bitrev_cplx(int *x, short *index, int nx)                  *
*                                                                           *
*       x[nx]  : Input array to be bit-reversed.                            *
*       index[]: Array of size ~sqrt(nx) created by the routine             *
*                bitrev_index to allow the fast implementation of the       *
*                bit-reversal.                                              *
*       nx     : Number of points in array x[]. Must be power of 2.         *
*                                                                           *
*   DESCRIPTION                                                             *
*       This routine performs the bit-reversal of the input array x[].      *
*       where x[] is an array of length nx 16-bit complex pairs of data.    *
*       This requires the index array provided by the program below.  This  *
*       index should be generated at compile time not by the DSP. The code  *
*       is given below.                                                     *
*                                                                           *
*       TI retains all rights, title and interest in this code and only     *
*       authorizes the use of the bit-reversal code and related table       *
*       generation code with TMS320-family DSPs manufactured by TI.         *
*                                                                           *
*       // ----------------------------------------------------------- //   *
*       //  This routine calculates the index for bit reversal of      //   *
*       //  an array of length n.  The length of the index table is    //   *
*       //  2^(2*ceil(k/2)) where n = 2^k.                             //   *
*       //                                                             //   *
*       //  In other words, the length of the index table is:          //   *
*       //                                                             //   *
*       //                 Even power      Odd Power                   //   *
*       //                  of radix        of radix                   //   *
*       //                  sqrt(n)        sqrt(2*n)                   //   *
*       //                                                             //   *
*       // ----------------------------------------------------------- //   *
*       void bitrev_index(short *index, int n)                              *
*       {                                                                   *
*           int   i, j, k, radix = 2;                                       *
*           short nbits, nbot, ntop, ndiff, n2, raddiv2;                    *
*                                                                           *
*           nbits = 0;                                                      *
*           i = n;                                                          *
*           while (i > 1)                                                   *
*           {                                                               *
*               i = i >> 1;                                                 *
*               nbits++;                                                    *
*           }                                                               *
*                                                                           *
*           raddiv2 = radix >> 1;                                           *
*           nbot    = nbits >> raddiv2;                                     *
*           nbot    = nbot << raddiv2 - 1;                                  *
*           ndiff   = nbits & raddiv2;                                      *
*           ntop    = nbot + ndiff;                                         *
*           n2      = 1 << ntop;                                            *
*                                                                           *
*           index[0] = 0;                                                   *
*           for ( i = 1, j = n2/radix + 1; i < n2 - 1; i++)                 *
*           {                                                               *
*               index[i] = j - 1;                                           *
*                                                                           *
*               for (k = n2/radix; k*(radix-1) < j; k /= radix)             *
*                   j -= k*(radix-1);                                       *
*                                                                           *
*               j += k;                                                     *
*           }                                                               *
*           index[n2 - 1] = n2 - 1;                                         *
*       }                                                                   *
*                                                                           *
*     C CODE                                                                *
*         void bitrev(int *x, short *index, int nx)                         *
*         {                                                                 *
*             int     i;                                                    *
*             short       i0, i1, i2, i3;                                   *
*             short       j0, j1, j2, j3;                                   *
*             int     xi0, xi1, xi2, xi3;                                   *
*             int     xj0, xj1, xj2, xj3;                                   *
*             short       t;                                                *
*             int     a, b, ia, ib, ibs;                                    *
*             int     mask;                                                 *
*             int     nbits, nbot, ntop, ndiff, n2, halfn;                  *
*             short   *xs = (short *) x;                                    *
*                                                                           *
*             nbits = 0;                                                    *
*             i = nx;                                                       *
*             while (i > 1)                                                 *
*             {                                                             *
*                 i = i >> 1;                                               *
*                 nbits++;                                                  *
*             }                                                             *
*                                                                           *
*             nbot    = nbits >> 1;                                         *
*             ndiff   = nbits & 1;                                          *
*             ntop    = nbot + ndiff;                                       *
*             n2      = 1 << ntop;                                          *
*             mask    = n2 - 1;                                             *
*             halfn   = nx >> 1;                                            *
*                                                                           *
*             for (i0 = 0; i0 < halfn; i0 += 2)                             *
*             {                                                             *
*                 b   = i0 & mask;                                          *
*                 a   = i0 >> nbot;                                         *
*                 if (!b) ia  = index[a];                                   *
*                 ib  = index[b];                                           *
*                 ibs = ib << nbot;                                         *
*                                                                           *
*                 j0  = ibs + ia;                                           *
*                 t   = i0 < j0;                                            *
*                 xi0 = x[i0];                                              *
*                 xj0 = x[j0];                                              *
*                                                                           *
*                 if (t){x[i0] = xj0;                                       *
*                 x[j0] = xi0;}                                             *
*                                                                           *
*                 i1  = i0 + 1;                                             *
*                 j1  = j0 + halfn;                                         *
*                 xi1 = x[i1];                                              *
*                 xj1 = x[j1];                                              *
*                 x[i1] = xj1;                                              *
*                 x[j1] = xi1;                                              *
*                                                                           *
*                 i3  = i1 + halfn;                                         *
*                 j3  = j1 + 1;                                             *
*                 xi3 = x[i3];                                              *
*                 xj3 = x[j3];                                              *
*                 if (t){x[i3] = xj3;                                       *
*                 x[j3] = xi3;}                                             *
*             }                                                             *
*         }                                                                 *
*                                                                           *
*   ASSUMPTIONS                                                             *
*       nx must be a power of 2.                                            *
*       The table from bitrev_index is already created.                     *
*       LITTLE ENDIAN configuration used.                                   *
*                                                                           *
*   NOTES                                                                   *
*       If N <= 4K one can use the char (8-bit) data type for               *
*       the "index" variable. This would require changing the LDH when      *
*       loading index values in the assembly routine to LDB. This would     *
*       further reduce the size of the Index Table by half its size.        *
*                                                                           *
*       This code is interrupt tolerant, but not interruptible.             *
*                                                                           *
*   CYCLES                                                                  *
*       (N/4 + 2) * 7 + 18                                                  *
*                                                                           *
*       e.g. N = 256, cycles = 480                                          *
*                                                                           *
*   CODESIZE                                                                *
*       352 bytes                                                           *
*                                                                           *
* ------------------------------------------------------------------------- *
*             Copyright (c) 2002 Texas Instruments, Incorporated.           *
*                            All Rights Reserved.                           *
* ========================================================================= *
        .text
        .global _DSP_bitrev_cplx
_DSP_bitrev_cplx:

;-
                LMBD.L1     1,  A6, A1      ; leftzeros = lmbd(1, nx)
    ||          MVK .S2     31, B0          ; constant 31
    ||          STW .D2     A15,*B15--[8]   ; push A15
    ||          MV  .S1X    B15,A15         ; copy stack pointer

                SUB .L1X    B0, A1, A8      ; nbits = 31 - leftzeros
    ||          SHR .S2X    A6, 1,  B6      ; halfn = nx >> 1
    ||          STW .D1     A10,*-A15[1]    ; push A10  B15[7]
    ||          STW .D2     B10,*+B15[6]    ; push B10  B15[6]
;-
                SHR .S1     A8, 1,  A0      ; nbot = nbits >> 1
    ||          AND .L1     A8, 1,  A11     ; ndiff = nbits & 1
    ||          SHR .S2     B6, 1,  B5      ; loop nx/4 +2 times
    ||          STW .D1     A11,*-A15[3]    ; push A11  B15[5]
    ||          STW .D2     B11,*+B15[4]    ; push B11  B15[4]
    ||          MV  .L2X    A4, B8          ; copy x
    ||          MPY .M2     B0, 0, B0
    ||          MPY .M1     A3, 0, A3       ; i0 = 0
;-
                ADD .D1     A0, A11,A11     ; ntop = nbot + ndiff
    ||          MVK .S1     1,  A2,         ; constant 1
    ||          ADD .L2     2,  B5, B2      ; loop nx/4 +2
    ||          MVK .S2     1,  B1          ; setup priming count
    ||          MV  .L1X    B4, A5          ; copy index

                SHL .S1     A2, A11,A1      ; n2 = 1 << ntop
    ||          STW .D1     A12,*-A15[5]    ; push A12  B15[3]
    ||          STW .D2     B12,*+B15[2]    ; push B12  B15[2]
;-
                SUB .L2X    A1, 1,  B13     ; mask = n2 - 1
    ||          ZERO.L1     A1              ; prevent stores on first iter
    ||          STW .D2     B13,*+B15[1]    ; push B13  B15[1]
    ||          ZERO.S1     A10             ; zero A10

                ZERO        A11
    ||          B   .S2     NO_INT_1

                LDH .D2     *B4[0],B0       ;** ib = index[b]
    ||          ADD .L2X    A3, 1,  B5      ;** i1 = i0 + 1
;-
                ADD         B5, B6, B7      ;** i3 = i1 + halfn

                LDW .D2     *B8[B7],B9      ;** xi3 = x[i3]
    ||          ZERO.D1     A12             ; zero A12
LOOP:
        [A1]    STW .D2     B9, *B8[B0]     ; if (t) x[j3] = xi3
    ||  [B2]    SUB         B2, 1,  B2      ; decrement loop counter
    ||          MPY .M1     A1, 1,  A2      ; copy t
    ||          LDW .D1     *A4[A3],A11     ;* xi0 = x[i0]
;-
        [A1]    STW .D1     A11,*A4[A10]    ; if (t) x[j0] = xi0
    ||  [B2]    B   .S2     LOOP            ; for loop
    ||          SHL .S1X    B0, A0, A10     ;* ibs = ib << nbot
    ||          ADD         A3, 2,  A3      ;* ai0 += 2
    ||          MPY .M2     B5, 1,  B10     ;* copy ai1
    ||          LDW .D2     *B8[B5],B11     ;* xi1 = x[i1]
    ||          MPY .M1     A3, 1,  A9      ;* copy ai0
;-
NO_INT_1:
        [!B1]   STW .D2     A11,*B8[B10]    ; x[i1] = xj1
    ||  [!B1]   STW .D1     B11,*A4[A6]     ; x[j1] = xi1
    ||          ADD         A10,A12,A10     ;* j0 = ibs + ia
    ||          SHR .S1     A3, A0, A11     ;** a = i0 >> nbot
    ||          AND .L2X    A3,B13, B0      ;** b = i0 & mask
;-
                ADD .L1X    A10,B6, A6      ;* j1 = j0 + halfn
    ||          MPY .M2     B7, 1,  B12     ;* copy ai3
    ||  [B1]    SUB .S2     B1, 1,  B1      ; decrement priming counter
    ||          LDH .D2     *B4[B0],B0      ;** ib = index[b]
    ||          ADD .L2X    A3, 1,  B5      ;** i1 = i1 + 1
    ||  [!B0]   LDH .D1     *A5[A11],A12    ;** if (!b) ia = index[a]
    ||  [B2]    B   .S1     NO_INT_1
;-
        [A1]    STW .D2     B0, *B8[B12]    ; if (t) x[i3] = xj3
    ||          ADD .L2X    A6, 1,  B0      ;* j3 = j0 + 1
    ||  [!B1]   CMPLT.L1    A9, A10,A1      ;* t = i0 < j0
    ||          LDW .D1     *A4[A6],A11     ;* xj1 = x[j1]
    ||  [B1]    MPY .M1     A4, 0,  A1      ; prime conditional store
    ||          ADD         B5, B6, B7      ;** i3 = i1 + halfn

                LDW .D1     *A4[A10],A7     ;* xj0 = x[j0]
    ||          LDW .D2     *B8[B7],B9      ;** xi3 = x[i3]
;-
        [A2]    STW .D1     A7, *A4[A8]     ; if (t) x[i0] = xj0
    ||          LDW .D2     *B8[B0],B0      ;* xj3 = x[j3]
    ||          MPY .M1     A9, 1,  A8      ;* copy ai0 again
END_LOOP:
                LDW .D1     *-A15[1],A10    ; pop A10  B15[7]
    ||          LDW .D2     *+B15[6],B10    ; pop B10  B15[6]

                LDW .D1     *-A15[3],A11    ; pop A11  B15[5]
    ||          LDW .D2     *+B15[4],B11    ; pop B11  B15[4]
;-
                LDW .D1     *-A15[5],A12    ; pop A12  B15[3]
    ||          LDW .D2     *+B15[2],B12    ; pop B12  B15[2]
    ||          B   .S2     B3              ; return

                LDW .D1     *-A15[7],B13    ; pop B13  B15[1]
    ||          LDW .D2     *++B15[8],A15   ; pop A15

                NOP 4
;-
* ========================================================================= *
*   End of file:  dsp_bitrev_cplx.asm                                       *
* ------------------------------------------------------------------------- *
*             Copyright (c) 2002 Texas Instruments, Incorporated.           *
*                            All Rights Reserved.                           *
* ========================================================================= *
	
