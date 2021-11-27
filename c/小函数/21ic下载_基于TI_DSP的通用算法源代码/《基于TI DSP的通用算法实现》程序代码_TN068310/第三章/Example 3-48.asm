
; Example 3 - 48. Complex Float Point Radix-2 FFT ASM Listing for the TMS320C67x DSP


* ======================================================================= *
*  TEXAS INSTRUMENTS, INC.                                                *
*                                                                         *
*  NAME                                                                   *
*      DSPF_sp_cfftr2_dit -- Single Precision floating point radix-2      *
*      Decimation in Time FFT with complex input                          *
*                                                                         *
*   USAGE                                                                 *  
*           This routine is C-callable and can be called as:              *  
*                                                                         *  
*           void DSPF_sp_cfftr2_dit(float * x, float * w, short n);       *  
*                                                                         *  
*           x : Pointer to complex data input                             *  
*           w : pointer to complex twiddle factor in bit reverse order    *  
*           n : Length of FFT in complex samples, power of 2 such that    *  
*           n >= 32                                                       *  
*                                                                         *  
*   DESCRIPTION                                                           *  
*                                                                         *  
*       This routine performs the Decimation-in-Time (DIT) Radix-2 FFT    *  
*       of the input array x.                                             *  
*                                                                         *  
*       x has N complex floating point numbers arranged as successive     *  
*       real and imaginary number pairs. Input array x contains N         *  
*       complex points (N*2 elements). The coefficients for the           *  
*       FFT are passed to the function in array w which contains          *  
*       N/2 complex numbers (N elements) as successive real and           *  
*       imaginary number pairs.                                           *  
*                                                                         *  
*       The FFT Coefficients w are in N/2 bit-reversed order              *  
*       The elements of input array x are in normal order                 *  
*       The assembly routine performs 4 output samples (2 real and 2      *  
*       imaginary) for a pass through inner loop.                         *  
*                                                                         *  
*   How to Use                                                            *  
*                                                                         *  
*   void main(void)                                                       *  
*          {                                                              *  
*             gen_w_r2(w, N);         // Generate coefficient table       *  
*             bit_rev(w, N>>1);       // Bit-reverse coefficient table    *  
*             DSPF_DSPF_sp_cfftr2_dit(x, w, N);                           *  
*                                                                         *  
*                                     // input in normal order, output in *  
*                                     // order bit-reversed               *  
*                                                                         *  
*                                     // coefficient table in bit-reversed*  
*                                     // order                            *  
*          }                                                              *  
*                                                                         *  
*       Note that (bit-reversed) coefficients for higher order FFT (1024  *  
*       point) can be used unchanged as coefficients for a lower order    *  
*       FFT (512, 256, 128 ... ,2)                                        *  
*                                                                         *  
*       The routine can be used to implement Inverse-FFT by any ONE of    *  
*       the following methods:                                            *  
*                                                                         *  
*       1.Inputs (x) are replaced by their Complex-conjugate values       *  
*         Output values are divided by N                                  *  
*                                                                         *  
*       2.FFT Coefficients (w) are replaced by their Complex-conjugates   *  
*         Output values are divided by N                                  *  
*                                                                         *  
*       3.Swap Real and Imaginary values of input                         *  
*                                                                         *  
*       4.Swap Real and Imaginary values of output                        *  
*                                                                         *  
*   TECHNIQUES                                                            *  
*                                                                         *  
*       1. The inner two loops are combined into one inner loop whose     *  
*          loop count is n/2.                                             *  
*       2. The prolog has been completely merged with the epilog. But     *  
*          this gives rise to a problem which has not been overcome.      *  
*          The problem is that the minimum trip count is 32. The safe     *  
*          trip count is atleast 16 bound by the size of the epilog.      *  
*          In addition because of merging the prolog and the epilog       *  
*          a data dependency via memory is caused which forces n to be    *  
*          atleast 32.                                                    *  
*                                                                         *  
*   ASSUMPTIONS                                                           *  
*                                                                         *  
*       1. n is a integral power of 2 and >=32.                           *  
*       2. The FFT Coefficients w are in bit-reversed order               *  
*       3. The elements of input array x are in normal order              *  
*       4. The imaginary coefficients of w are negated as {cos(d*0),      *  
*          sin(d*0), cos(d*1), sin(d*1) ...} as opposed to the normal     *  
*          sequence of {cos(d*0), -sin(d*0), cos(d*1), -sin(d*1) ...}     *  
*          where d = 2*PI/n.                                              *  
*   5. x and w arrays are double word aligned.                            *  
*                                                                         *  
*   C CODE                                                                *  
*                                                                         *  
*       This is the C equivalent of the assembly code.  Note that         *  
*       the assembly code is hand optimized and restrictions may          *  
*       apply.                                                            *  
*                                                                         *  
*       void DSPF_sp_cfftr2_dit(float* x, float* w, short n)              *  
*       {                                                                 *  
*          short n2, ie, ia, i, j, k, m;                                  *  
*          float rtemp, itemp, c, s;                                      *  
*                                                                         *  
*          n2 = n;                                                        *  
*          ie = 1;                                                        *  
*                                                                         *  
*          for(k=n; k > 1; k >>= 1)                                       *  
*          {                                                              *  
*             n2 >>= 1;                                                   *  
*             ia = 0;                                                     *  
*             for(j=0; j < ie; j++)                                       *  
*             {                                                           *  
*                c = w[2*j];                                              *  
*                s = w[2*j+1];                                            *  
*                for(i=0; i < n2; i++)                                    *  
*                {                                                        *  
*                   m = ia + n2;                                          *  
*                   rtemp     = c* x[2*m]   + s * x[2*m+1];               *  
*                   itemp     = c* x[2*m+1] - s * x[2*m];                 *  
*                   x[2*m]    = x[2*ia]   - rtemp;                        *  
*                   x[2*m+1]  = x[2*ia+1] - itemp;                        *  
*                   x[2*ia]   = x[2*ia]   + rtemp;                        *  
*                   x[2*ia+1] = x[2*ia+1] + itemp;                        *  
*                   ia++;                                                 *  
*                }                                                        *  
*                ia += n2;                                                *  
*             }                                                           *  
*             ie <<= 1;                                                   *  
*          }                                                              *  
*       }                                                                 *  
*                                                                         *  
*           The follwoing C code is used to generate the coefficient table*  
*           (non-bit reversed).                                           *  
*                                                                         *  
*            #include <math.h>                                            *  
*            /* generate real and imaginary twiddle                       *  
*               table of size n/2 complex numbers*/                       *  
*                                                                         *  
*            gen_w_r2(float* w, int n)                                    *  
*            {                                                            *  
*               int i;                                                    *  
*               float pi = 4.0*atan(1.0);                                 *  
*               float e = pi*2.0/n;                                       *  
*                                                                         *  
*                for(i=0; i < ( n>>1 ); i++)                              *  
*                {                                                        *  
*                   w[2*i]   = cos(i*e);                                  *  
*                   w[2*i+1] = sin(i*e);                                  *  
*                }                                                        *  
*            }                                                            *  
*                                                                         *  
*            The follwoing C code is used to bit-reverse the coefficents. *  
*                                                                         *  
*            bit_rev(float* x, int n)                                     *  
*            {                                                            *  
*              int i, j, k;                                               *  
*              float rtemp, itemp;                                        *  
*                                                                         *  
*              j = 0;                                                     *  
*              for(i=1; i < (n-1); i++)                                   *  
*              {                                                          *  
*                 k = n >> 1;                                             *  
*                 while(k <= j)                                           *  
*                 {                                                       *  
*                    j -= k;                                              *  
*                    k >>= 1;                                             *  
*                 }                                                       *  
*                 j += k;                                                 *  
*                 if(i < j)                                               *  
*                 {                                                       *  
*                    rtemp    = x[j*2];                                   *  
*                    x[j*2]   = x[i*2];                                   *  
*                    x[i*2]   = rtemp;                                    *  
*                    itemp    = x[j*2+1];                                 *  
*                    x[j*2+1] = x[i*2+1];                                 *  
*                    x[i*2+1] = itemp;                                    *  
*                 }                                                       *  
*               }                                                         *  
*            }                                                            *  
*                                                                         *  
*                                                                         *  
*                                                                         *  
*   NOTES                                                                 *  
*                                                                         *  
*      1. The bit-reversed twiddle factor array w can be generated by     *  
*         using the tw_r2fft function provided in the dsplib\support\fft  *  
*     directory or by running tw_r2fft.exe provided in dsplib\bin.        *  
*     The twiddle factor array can also be generated by using gen_w_r2    *  
*     and bit_rev algorithms as described above.                          *  
*                                                                         *  
*      2. The function bit_rev in dsplib\support\fft can be used to       *  
*         bit-reverse the output array to convert it into normal order.   *  
*                                                                         *  
*      3. Endian: This code is LITTLE ENDIAN.                             *  
*                                                                         *  
*      4. Interruptibility: This code is interrupt-tolerant but not       *  
*         interruptible.                                                  *  
*                                                                         *  
*   CYCLES                                                                *  
*                                                                         *  
*       (2* n * log(base-2) n) + 42                                       *  
*                                                                         *  
*       For n = 64, Cycles = 810                                          *  
*                                                                         *  
*   CODESIZE                                                              *  
*                                                                         *  
*        1248 bytes                                                       *  
*                                                                         *  
* ----------------------------------------------------------------------- *
*            Copyright (c) 2003 Texas Instruments, Incorporated.          *
*                           All Rights Reserved.                          *
* ======================================================================= *

                .global _DSPF_sp_cfftr2_dit
                
                .asg B8, B_x
                .asg A5, A_w
                .asg B7, B_x2mp1
                .asg B6, B_x2m
                .asg A7, A_si
                .asg A6, A_co
                .asg B0, B_lx2mc
                .asg B4, B_8n2
                .asg B13, B_n2
                .asg A13, A_p1
                .asg B11, B_p2
                .asg B3, B_p4
                .asg A15, A_p3
                .asg B2, B_lx2iac
                .asg A3, A_x
                .asg A10, A_8n2
                .asg A12, A_rtemp
                .asg B10, B_itemp
                .asg A1, A_stcnt
                .asg A15, A_x2ias
                .asg B3, B_x2mp1s
                .asg A15, A_x2ms
                .asg B3, B_x2iap1s
                .asg A9, A_x2iap1
                .asg A8, A_x2ia
                .asg B1, B_hafn2
                .asg A2, A_nby2
                .asg A4, A_wbase
                

_DSPF_sp_cfftr2_dit:

       ; push all the registers (also CSR, IRP )
       SUBAW  .D2     B15,        16,       B15       
||     B      .S1     no_int                          
||     MVC    .S2     CSR,        B1                  
       
       MV     .S1X    B15,        A1                  
||     STW    .D2T1   A10,        *B15[0]             

       STW    .D2T2   B1,         *B15[2]       
||     STW    .D1T1   A11,        *A1[1]              

       STW    .D2T2   B11,        *B15[4]             
||     STW    .D1T1   A12,        *A1[3]              
||     AND    .L2     B1,         -2,       B1  ; disable interrupts      
||     MVC    .S2     IRP,        B2                  

       STW    .D2T2   B2,         *B15[6]             
||     STW    .D1T1   A13,        *A1[5]              
||     MVC    .S2     B1,         CSR                 

       STW    .D2T2   B13,        *B15[8]             
||     STW    .D1T1   A14,        *A1[7]              

no_int:

       STW    .D2T2   B14,        *B15[10]            
||     STW    .D1T1   A15,        *A1[9]              

       STW    .D2T2   B3,         *B15[12]            
||     MVC    .S2     B15,        IRP                 

       ADDAW  .D1     A4,         A6,       A3        ; init x[2m] ptr 
||     SHR    .S2X    A6,         1,        B_n2      ; init n2
||     MV     .L1X    B4,         A_w                 ; init w ptr
||     STW    .D2T2   B10,        *B15[13]            ; push b10

       MV     .S2X    A3,         B_x                 ; transfer x[2m] ptr
||     SHL    .S1     A6,         2,        A_8n2     ; keep 8n2 for addr incr
||     SUB    .L2     B_n2,       6,        B15       ; for inner loop cntr
||     STW    .D2T2   B12,        *B15[11]            ; push b12

* ====================== PIPED LOOP PROLOG ======================================= *

       LDDW   .D2     *B_x++,     B_x2mp1:B_x2m       ; load x[2m+1]:x[2m]
||     LDDW   .D1     *A_w++,     A_si:A_co           ; load si:co
||     MV     .S2     B_x,        B5                  ; init x[2m] store ptr

       MV     .L1     A4,         A11                 ; init x[2ia] store ptr
||     SHL    .S2X    A6,         2,        B_8n2     ; copy of 8n2 on b-side
||     MV             B_n2,       B_lx2mc             ; load cntr for x[2m] loads

 [B_lx2mc]SUB .L2     B_lx2mc,    1,        B_lx2mc   ; decr x[2m] load cntr
||     MV     .S1     A4,         A_x                 ; f xx2 = x
||     MV     .S2X    A4,         B14                 ; save base x ptr
||     MV     .D1     A4,         A0                  ; save base x ptr
||     SUB    .L1     A_w,        8,        A_wbase   ; save w base ptr

       MV     .D2     B_n2,       B_lx2iac            ; init x[2ia] load cntr
||     MV     .L1X    B_n2,       A_stcnt             ; init store cntr
||     SHR    .S2     B_n2,       1,        B_hafn2   ; init half of n2     

       LDDW   .D2     *B_x++,     B_x2mp1:B_x2m       ; load x[2m+1]:x[2m]

       MPYSP  .M1X    A_co,       B_x2m,    A_p1      ; p1=co*x[2m]
||     MPYSP  .M2X    A_co,       B_x2mp1,  B_p2      ; p2=co*x[2m+1]

 [B_lx2mc]SUB .S2     B_lx2mc,    1,        B_lx2mc   ; decr load cntr
||     MV     .L1X    B15,        A_nby2              ; init loop cntr
       
       MPYSP  .M1X    A_si,       B_x2mp1,  A_p3      ; p3=si*x[2m+1]
||     MPYSP  .M2X    A_si,       B_x2m,    B_p4      ; p4=si*x[2m]

       LDDW   .D2     *B_x++,     B_x2mp1:B_x2m       ; load x[2m+1]:x[2m]

       MPYSP  .M1X    A_co,       B_x2m,    A_p1      ; p1=co*x[2m]
||     MPYSP  .M2X    A_co,       B_x2mp1,  B_p2      ; p2=co*x[2m+1]

  [B_lx2mc]SUB.S2     B_lx2mc,    1,        B_lx2mc   ; decr load cntr

       LDDW   .D1     *A_x++,     A_x2iap1:A_x2ia     ; load x[2ia+1]:x[2ia]
||     MPYSP  .M1X    A_si,       B_x2mp1,  A_p3      ; p3=si*x[2m+1]
||     MPYSP  .M2X    A_si,       B_x2m,    B_p4      ; p4=si*x[2m]
||     ADDSP  .L1     A_p1,       A_p3,     A_rtemp   ; rtemp=p1+p3
||     SUBSP  .L2     B_p2,       B_p4,     B_itemp   ; itemp=p2-p4

       LDDW   .D2     *B_x++,     B_x2mp1:B_x2m       ; load x[2m+1]:x[2m]
||[B_lx2iac]SUB.S2     B_lx2iac,  1,        B_lx2iac  ; decr load cntr

       MPYSP  .M1X    A_co,       B_x2m,    A_p1      ; p1=co*x[2m]
||     MPYSP  .M2X    A_co,       B_x2mp1,  B_p2      ; p2=co*x[2m+1]

  [B_lx2mc]SUB.S2     B_lx2mc,    1,        B_lx2mc   ; decr load cntr

       LDDW   .D1     *A_x++,     A_x2iap1:A_x2ia     ; load x[2ia+1]:x[2ia]
||     MPYSP  .M1X    A_si,       B_x2mp1,  A_p3      ; p3=si*x[2m+1]
||     MPYSP  .M2X    A_si,       B_x2m,    B_p4      ; p4=si*x[2m]
||     ADDSP  .L1     A_p1,       A_p3,     A_rtemp   ; rtemp=p1+p3
||     SUBSP  .L2     B_p2,       B_p4,     B_itemp   ; itemp=p2-p4

       LDDW   .D2     *B_x++,     B_x2mp1:B_x2m       ; load x[2m+1]:x[2m]
||[B_lx2iac]SUB.S2    B_lx2iac,   1,        B_lx2iac  ; decr load cntr
||     ADDSP  .L1     A_x2ia,     A_rtemp,  A_x2ias   ; x[2ia]=x[2ia]+rtemp
||     SUBSP  .L2X    A_x2iap1,   B_itemp,  B_x2mp1s  ; x[2m+1]=x[2ia+1]-itemp

       MPYSP  .M1X    A_co,       B_x2m,    A_p1      ; p1=co*x[2m]
||     MPYSP  .M2X    A_co,       B_x2mp1,  B_p2      ; p2=co*x[2m+1]
||     B      .S2     loop                            

  [B_lx2mc]SUB.S2     B_lx2mc,    1,        B_lx2mc   ; decr load cntr
||     SUBSP  .L1     A_x2ia,     A_rtemp,  A_x2ms    ; x[2m]=x[2ia]-rtemp
||     ADDSP  .L2X    A_x2iap1,   B_itemp,  B_x2iap1s ; x[2ia+1]=x[2ia+1]+itemp

* ================== PIPED LOOP KERNEL ======================================== *
loop:

       LDDW   .D1     *A_x++,     A_x2iap1:A_x2ia     ; load x[2ia+1]:x[2ia]
||     MPYSP  .M1X    A_si,       B_x2mp1,  A_p3      ; p3=si*x[2m+1]
||     MPYSP  .M2X    A_si,       B_x2m,    B_p4      ; p4=si*x[2m]
||[!B_lx2mc]ADD.D2    B_x,        B_8n2,    B_x       ; incr load ptr if required
||     ADDSP  .L1     A_p1,       A_p3,     A_rtemp   ; rtemp=p1+p3
||     SUBSP  .L2     B_p2,       B_p4,     B_itemp   ; itemp=p2-p4
||[!A_stcnt]ADD.S2    B5,         B_8n2,    B5        ; incr store ptr if required
||[!A_stcnt]ADD.S1    A11,        A_8n2,    A11       ; incr store ptr if required

       LDDW   .D2     *B_x++,     B_x2mp1:B_x2m       ; load x[2m+1]:x[2m]
||[!B_lx2mc]LDDW.D1   *A_w++,     A_si:A_co           ; load si:co
||[!B_lx2mc]MPY .M2   1,          B_n2,     B_lx2mc   ; reset load cntr
||[B_lx2iac]SUB .S2   B_lx2iac,   1,        B_lx2iac  ; decr load cntr
||     ADDSP  .L1     A_x2ia,     A_rtemp,  A_x2ias   ; x[2ia]=x[2ia]+rtemp
||     SUBSP  .L2X    A_x2iap1,   B_itemp,  B_x2mp1s  ; x[2m+1]=x[2ia+1]-itemp
||[A_nby2]SUB .S1     A_nby2,     1,        A_nby2    ; decr loop cntr
||[!A_stcnt]MPY.M1X   1,          B_n2,     A_stcnt   ; reset store cntr

       MPYSP  .M1X    A_co,       B_x2m,    A_p1      ; p1=co*x[2m]
||     MPYSP  .M2X    A_co,       B_x2mp1,  B_p2      ; p2=co*x[2m+1]
||[!B_lx2iac]ADD.S1   A_x,        A_8n2,    A_x       ; incr load ptr if required
||[A_nby2]B   .S2     loop                            ; Branch loop
||     STW    .D1T1   A_x2ias,    *A11++              ; store x[2ia]
||     STW    .D2T2   B_x2mp1s,   *B5[1]              ; store x[2m+1]

  [B_lx2mc]SUB.S2     B_lx2mc,    1,        B_lx2mc   ; decr load cntr
||[!B_lx2iac]MPY.M2   1,          B_n2,     B_lx2iac  ; decr load cntr
||     SUBSP  .L1     A_x2ia,     A_rtemp,  A_x2ms    ; x[2m]=x[2ia]-rtemp
||     ADDSP  .L2X    A_x2iap1,   B_itemp,  B_x2iap1s ; x[2ia+1]=x[2ia+1]+itemp
||     STW    .D1     B_x2iap1s,  *A11++              ; store x[2ia+1]
||     STW    .D2     A_x2ms,     *B5++[2]            ; store x[2m]
||[A_stcnt]SUB.S1     A_stcnt,    1,        A_stcnt   ; decr store cntr

* ======================= END OF PIPED LOOP KERNEL ========================== *
       
       LDDW   .D1     *A_x++,     A_x2iap1:A_x2ia     ; (e) load x[2ia+1]:x[2ia]
||     MPYSP  .M1X    A_si,       B_x2mp1,  A_p3      ; (e) p3=si*x[2m+1]
||     MPYSP  .M2X    A_si,       B_x2m,    B_p4      ; (e) p4=si*x[2m]
||[!B_lx2mc]ADDAW.D2  B14,        B_n2,     B_x       ; (p) init B_x for outer loop
||     ADDSP  .L1     A_p1,       A_p3,     A_rtemp   ; (e) rtemp=p1+p3
||     SUBSP  .L2     B_p2,       B_p4,     B_itemp   ; (e) itemp=p2-p4
||[!A_stcnt]ADD.S2    B5,         B_8n2,    B5        ; (e) incr store ptr if required
||[!A_stcnt]ADD.S1    A11,        A_8n2,    A11       ; (e) incr store ptr if required

  ; loads are predicated with B_hafn2 so that the last prolog does not
  ; perform invalid loads 
  
  [B_hafn2] LDDW.D2   *B_x++,     B_x2mp1:B_x2m       ; (p) load x[2m+1]:x[2m]
||[!B_lx2mc]LDDW.D1   *A4,        A_si:A_co           ; (p) load si:co
||[!B_lx2mc]MPY .M2   1,          B_hafn2,  B_lx2mc   ; (p) reset load cntr
||[B_lx2iac]SUB .S2   B_lx2iac,   1,        B_lx2iac  ; (p) decr load cntr
||     ADDSP  .L1     A_x2ia,     A_rtemp,  A_x2ias   ; (e) x[2ia]=x[2ia]+rtemp
||     SUBSP  .L2X    A_x2iap1,   B_itemp,  B_x2mp1s  ; (e) x[2m+1]=x[2ia+1]-itemp
||     ADD    .S1     A4,         8,        A_w       ; (p) set w ptr
||[!A_stcnt]MPY.M1X   1,          B_n2,     A_stcnt   ; (p) reset store cntr

       MPYSP  .M1X    A_co,       B_x2m,    A_p1      ; (e) p1=co*x[2m]		   
||     MPYSP  .M2X    A_co,       B_x2mp1,  B_p2      ; (e) p2=co*x[2m+1]
||[!B_lx2iac]ADD.S1   A_x,        A_8n2,    A_x       ; (e) incr load ptr if required
||     MV     .S2     B5,         B12                 ; preserve store ptr
||     STW    .D1T1   A_x2ias,    *A11++              ; (e) store x[2ia]
||     STW    .D2T2   B_x2mp1s,   *B5[1]              ; (e) store x[2m+1]

  [B_lx2mc]SUB.S2     B_lx2mc,    1,        B_lx2mc   ; decr load cntr
||[!B_lx2iac]MPY.M2   1,          B_n2,     B_lx2iac  ; reset load cntr
||     SUBSP  .L1     A_x2ia,     A_rtemp,  A_x2ms    ; (e) x[2m]=x[2ia]-rtemp
||     ADDSP  .L2X    A_x2iap1,   B_itemp,  B_x2iap1s ; (e) x[2ia+1]=x[2ia+1]+itemp
||     STW    .D1     B_x2iap1s,  *A11++              ; (e) store x[2ia+1]
||     STW    .D2     A_x2ms,     *B12++[2]           ; (e) store x[2m]
||[A_stcnt] SUB.S1    A_stcnt,    1,        A_stcnt   ; (e) decr store cntr
||     MPY    .M1X    B13,       1,        A_nby2     ; is it last outer loop? 

       LDDW   .D1     *A_x++,     A_x2iap1:A_x2ia     ; (e) load x[2ia+1]:x[2ia]
||     MPYSP  .M1X    A_si,       B_x2mp1,  A_p3      ; (e) p3=si*x[2m+1]
||     MPYSP  .M2X    A_si,       B_x2m,    B_p4      ; (e) p4=si*x[2m]
||[!B_lx2mc]ADDAW.D2  B_x,        B_n2,     B_x       ; (p) incr ptr if required
||     ADDSP  .L1     A_p1,       A_p3,     A_rtemp   ; (e) rtemp=p1+p3
||     SUBSP  .L2     B_p2,       B_p4,     B_itemp   ; (e) itemp=p2-p4
||[!A_stcnt]ADD.S2    B12,        B_8n2,    B12       ; (e) incr store ptr if required
||[!A_stcnt]ADD.S1    A11,        A_8n2,    A11       ; (e) incr store ptr if required

  [B_hafn2] LDDW.D2   *B_x++,     B_x2mp1:B_x2m       ; (p) load x[2m+1]:x[2m]
||[!B_lx2mc]LDDW.D1   *A_w++,     A_si:A_co           ; (p) load si:co
||[!B_lx2mc]MPY .M2   1,          B_hafn2,  B_lx2mc   ; (p) reset load cntr
||[B_lx2iac]SUB .S2   B_lx2iac,   1,        B_lx2iac  ; (p) decr load cntr
||     ADDSP  .L1     A_x2ia,     A_rtemp,  A_x2ias   ; (e) x[2ia]=x[2ia]+rtemp
||     SUBSP  .L2X    A_x2iap1,   B_itemp,  B_x2mp1s  ; (e) x[2m+1]=x[2ia+1]-itemp
||[!A_stcnt]MPY.M1X   1,          B_n2,     A_stcnt   ; (e) reset store cntr
||[A_nby2]SUB  .S1    A_nby2,     1,        A_nby2    ; is it last outer loop?

       MPYSP  .M1X    A_co,       B_x2m,    A_p1      ; (p) p1=co*x[2m] 	   
||     MPYSP  .M2X    A_co,       B_x2mp1,  B_p2      ; (p) p2=co*x[2m+1]
||[!B_lx2iac]ADD.S1   A_x,        A_8n2,    A_x       ; (e) incr load ptr if required
||     MV     .S2     B_8n2,      B9                  ; preserve store ptr
||     STW    .D1T1   A_x2ias,    *A11++              ; (e) store x[2ia]
||     STW    .D2T2   B_x2mp1s,   *B12[1]             ; (e) store x[2m+1]

  [B_lx2mc]SUB.S2     B_lx2mc,    1,        B_lx2mc   ; decr load cntr
||[!B_lx2iac]MPY.M2   1,          B_n2,     B_lx2iac  ; reset load cntr
||     SUBSP  .L1     A_x2ia,     A_rtemp,  A_x2ms    ; (e) x[2m]=x[2ia]-rtemp
||     ADDSP  .L2X    A_x2iap1,   B_itemp,  B_x2iap1s ; (e) x[2ia+1]=x[2ia+1]+itemp
||     STW    .D1     B_x2iap1s,  *A11++              ; (e) store x[2ia+1]
||     STW    .D2     A_x2ms,     *B12++[2]           ; (e) store x[2m]
||[A_stcnt] SUB.S1    A_stcnt,    1,        A_stcnt   ; decr store cntr

       LDDW   .D1     *A_x++,     A_x2iap1:A_x2ia     ; (e) load x[2ia+1]:x[2ia]
||     MPYSP  .M1X    A_si,       B_x2mp1,  A_p3      ; (e) p3=si*x[2m+1]
||     MPYSP  .M2X    A_si,       B_x2m,    B_p4      ; (e) p4=si*x[2m]
||[!B_lx2mc]ADDAW.D2  B_x,        B_n2,     B_x       ; (p) incr ptr if required
||     ADDSP  .L1     A_p1,       A_p3,     A_rtemp   ; (e) rtemp=p1+p3
||     SUBSP  .L2     B_p2,       B_p4,     B_itemp   ; (e) itemp=p2-p4
||[!A_stcnt]ADD.S2    B12,        B9,       B12       ; (e) incr store ptr if required
||[!A_stcnt]ADD.S1    A11,        A_8n2,    A11       ; (e) incr store ptr if required

  [B_hafn2] LDDW.D2   *B_x++,     B_x2mp1:B_x2m       ; (p) load x[2m+1]:x[2m]
||[!B_lx2mc]LDDW.D1   *A_w++,     A_si:A_co           ; (p) load si:co
||[!B_lx2mc]MPY .M2   1,          B_hafn2,  B_lx2mc   ; (p) reset load cntr
||[B_lx2iac]SUB .S2   B_lx2iac,   1,        B_lx2iac  ; (p) decr load cntr
||     ADDSP  .L1     A_x2ia,     A_rtemp,  A_x2ias   ; (e) x[2ia]=x[2ia]+rtemp
||     SUBSP  .L2X    A_x2iap1,   B_itemp,  B_x2mp1s  ; (e) x[2m+1]=x[2ia+1]-itemp
||[!A_stcnt]MPY .M1X  1,          B_n2,     A_stcnt   ; (e) reset store cntr
||     MV             A11,        A14                 ; preserve store ptr

       MPYSP  .M2X    A_co,       B_x2mp1,  B_p2      ; (p) p2=co*x[2m+1]
||     MV     .S1     A0,         A_x                 ; set the x[2ia] ptr
||     SHR    .S2     B_8n2,      1,        B_8n2     ; set B_8n2 for next
||     STW    .D1T1   A_x2ias,    *A14++              ; (e) store x[2ia]
||     STW    .D2T2   B_x2mp1s,   *B12[1]             ; (e) store x[2m+1]
||     INTSP  .L2     B_hafn2,         B5             ; use L unit in a strange way
||     SUBSP  .L1     A_x2ia,     A_rtemp,  A11       ; (e) x[2m]=x[2ia]-rtemp
||     MPYSP  .M1X    A_co,       B_x2m,    A_p1      ; (p) co*x[2m]

  [B_lx2mc]SUB.S2     B_lx2mc,    1,        B_lx2mc   ; decr load cntr
||[!B_lx2iac]MPY.M2   1,          B_hafn2,  B_lx2iac  ; reset load cntr
||     ADDSP  .L2X    A_x2iap1,   B_itemp,  B_x2iap1s ; x[2ia+1]=x[2ia+1]+itemp
||     STW    .D1     B_x2iap1s,  *A14++              ; store x[2ia+1]
||     STW    .D2     A_x2ms,     *B12++[2]           ; store x[2m]
||[A_stcnt]SUB.S1     A_stcnt,    1,        A_stcnt   ; decr store cntr
       
  [B_hafn2]LDDW.D1    *A_x++,     A_x2iap1:A_x2ia     ; (e) load x[2ia+1]:x[2ia]
||     MPYSP  .M1X    A_si,       B_x2mp1,  A_p3      ; (p) p3=si*x[2m+1]
||     MPYSP  .M2X    A_si,       B_x2m,    B_p4      ; (p) p4=si*x[2m]
||[!B_lx2mc]ADDAW.D2  B_x,        B_n2,     B_x       ; (p) incr ptr if required
||     ADDSP  .L1     A_p1,       A_p3,     A_rtemp   ; (p) rtemp=p1+p3
||     SUBSP  .L2     B_p2,       B_p4,     B_itemp   ; (p) itemp=p2-p4
||[!A_stcnt]ADD.S2    B12,        B9,       B12       ; (e) incr store ptr if required
||[!A_stcnt]ADD.S1    A14,        A_8n2,    A14       ; (e) incr store ptr if required

  [B_hafn2] LDDW.D2   *B_x++,     B_x2mp1:B_x2m       ; (p) load x[2m+1]:x[2m]
||[!B_lx2mc]LDDW.D1   *A_w++,     A_si:A_co           ; (p) load si:co
||[!B_lx2mc]MPY .M2   1,          B_hafn2,  B_lx2mc   ; (p) reset load cntr
||     ADDSP  .L1     A_x2ia,     A_rtemp,  A_x2ias   ; (p) x[2ia]=x[2ia]-rtemp
||     SUBSP  .L2X    A_x2iap1,   B_itemp,  B_x2mp1s  ; (p) x[2m+1]=x[2ia+1]-itemp
||[B_lx2iac]SUB.S2    B_lx2iac,   1,        B_lx2iac  ; decr load cntr
||[!A_stcnt]SHR.S1    A_8n2,      3,        A_stcnt   ; (e) reset store cntr
||     MPY    .M1X    B_n2,       4,        A15       ; generate incrment

       MPYSP  .M1X    A_co,       B_x2m,    A_p1      ; p1=co*x[2m]
||     MPYSP  .M2X    A_co,       B_x2mp1,  B_p2      ; p2=co*x[2m+1]
||[A_nby2]B      .S1     loop                         ; Branch next outer loop
||     STW    .D1T1   A_x2ias,    *A14++              ; store x[2ia]
||     STW    .D2T2   B_x2mp1s,   *B12[1]             ; store x[2m+1]
||     SPINT  .L2     B5,         B_n2                ; get B_n2 for next iteration 
||     ADD    .S2     B14,        B_8n2,    B5        ; get store ptr 
||[A_stcnt]SUB.L1     A_stcnt,    1,        A_stcnt   ; decr store cntr

  [B_lx2mc]SUB.S2     B_lx2mc,    1,        B_lx2mc   ; decr load cntr
||[!B_lx2iac]MPY.M2   1,          B_hafn2,  B_lx2iac  ; reset load cntr
||     SUBSP  .L1     A_x2ia,     A_rtemp,  A_x2ms    ; x[2m]=x[2ia]-rtemp
||     ADDSP  .L2X    A_x2iap1,   B_itemp,  B_x2iap1s ; p itemp3 = t3_1 - itemp1
||     STW    .D1     B_x2iap1s,  *A14++              ; store x[2ia+1]
||     STW    .D2     A11,        *B12++[2]           ; store x[2m]
||[A_nby2]MPY .M1X    B15,        1,        A_nby2    ; set loop counter  
||[!B_lx2iac]ADD.S1   A_x,        A15,      A_x       ; incr load ptr

  [B_hafn2] LDDW.D1   *A_x++,     A_x2iap1:A_x2ia     ; (p) load x[2ia+1]:x[2ia]
||     MPYSP  .M1X    A_si,       B_x2mp1,  A_p3      ; (p) p3=si*x[2m+1]
||     MPYSP  .M2X    A_si,       B_x2m,    B_p4      ; (p) p4=si*x[2m]
||[!B_lx2mc]ADDAW.D2  B_x,        B_n2,     B_x       ; (p) incr ptr if required
||     ADDSP  .L1     A_p1,       A_p3,     A_rtemp   ; (p) rtemp=p1+p3
||     SUBSP  .L2     B_p2,       B_p4,     B_itemp   ; (p) itemp=p2-p4
||[!A_stcnt]ADD.S2    B12,        B9,       B12       ; (e) incr store ptr if required
||[!A_stcnt]ADD.S1    A14,        A_8n2,    A14       ; (e) incr store ptr if required

  [B_hafn2] LDDW.D2   *B_x++,     B_x2mp1:B_x2m       ; (p) load x[2m+1]:x[2m]
||[!B_lx2mc]LDDW.D1   *A_w++,     A_si:A_co           ; (p) load si:co
||[!B_lx2mc]MPY .M2   1,          B_hafn2,  B_lx2mc   ; (p) reset load cntr
||[B_lx2iac]SUB .S2   B_lx2iac,   1,        B_lx2iac  ; (p) x[2ia]=x[2ia]-rtemp
||     ADDSP  .L1     A_x2ia,     A_rtemp,  A_x2ias   ; (p) x[2m+1]=x[2ia+1]-itemp
||     SUBSP  .L2X    A_x2iap1,   B_itemp,  B_x2mp1s  ; x[2m+1]=x[2ia+1]-itemp
||     MPY    .M1X    4,          B_n2,     A_8n2     ; set A_8n2
||     MV     .S1     A0,         A11                 ; set load ptr

       MPYSP  .M1X    A_co,       B_x2m,    A_p1      ; p1=co*x[2m]
||     MPYSP  .M2X    A_co,       B_x2mp1,  B_p2      ; p2=co*x[2m+1]
||     SHR    .S2     B_hafn2,    1,        B_hafn2   ; for next outer loop
||     STW    .D1T1   A_x2ias,    *A14++              ; store x[2ia]
||     STW    .D2T2   B_x2mp1s,   *B12[1]             ; store x[2m+1]
||[A_nby2]B      .S1     loop                         ; branch

  [B_lx2mc]SUB .S2    B_lx2mc,    1,        B_lx2mc   ; decr load cntr
||[!B_lx2iac]MPY.M2   1,          B_n2,     B_lx2iac  ; reset load cntr
||     SUBSP  .L1     A_x2ia,     A_rtemp,  A_x2ms    ; x[2m]=x[2ia]-rtemp
||     ADDSP  .L2X    A_x2iap1,   B_itemp,  B_x2iap1s ; x[2ia+1]=x[2ia+1]-itemp
||     STW    .D1     B_x2iap1s,  *A14                ; store x[2ia+1]
||     STW    .D2     A_x2ms,     *B12                ; store x[2m]
||     MPY    .M1     A_stcnt,    0,        A_stcnt   ; reset store count
||[!B_lx2iac]ADD.S1   A_x,        A_8n2,    A_x       ; incr load ptr
****************************************************************************

       MVC    .S2     IRP,        B15                 
       
       MV     .S1X    B15,        A1                  
||     LDW    .D2T2   *B15[12],   B3                  
 
       LDW    .D2T1   *B15[0],    A10                 
||     LDW    .D1T2   *A1[13],    B10                 

       LDW    .D2T1   *B15[1],    A11                 
||     LDW    .D1T2   *A1[6],     B2                  

       LDW    .D2T1   *B15[3],    A12                 
||     LDW    .D1T2   *A1[2],     B1                  

       LDW    .D2T1   *B15[5],    A13                 
||     LDW    .D1T2   *A1[8],     B13                 

       LDW    .D2T1   *B15[7],    A14                 
||     LDW    .D1T2   *A1[10],    B14                 

       LDW    .D2T1   *B15[9],    A15                 
||     LDW    .D1T2   *A1[4],     B11                 
||     B      .S2     B3                              

       MVC    .S2     B2,         IRP                 
||     LDW    .D1T2   *A1[11],    B12                 

       NOP            2                               
       
       ADDAW          B15,        16,       B15       
       
       MVC    .S2     B1,         CSR                 
       
                .end

* ======================================================================== *
*  End of file: sp_cfftr2_dit.asm                                          *
* ------------------------------------------------------------------------ *
*          Copyright (C) 2003 Texas Instruments, Incorporated.             *
*                          All Rights Reserved.                            *
* ======================================================================== *