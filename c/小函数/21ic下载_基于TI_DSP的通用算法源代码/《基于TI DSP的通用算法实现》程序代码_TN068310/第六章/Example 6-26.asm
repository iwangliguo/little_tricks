
; Example 6 - 26. LMS Implementation ASM Listing for the TMS320C67x DSP

* ====================================================================== *
*  TEXAS INSTRUMENTS, INC.                                               * 
*                                                                        * 
*  NAME                                                                  * 
*      DSPF_sp_lms - Floating point LMS adaptive algorithm               * 
*                                                                        * 
*  USAGE                                                                 *  
*                                                                        *  
*      This routine is C callable, and has the following C prototype:    *  
*  float DSPF_sp_lms (float *x,                                          *  
*         float *h,                                                      *  
*         float *desired,                                                *  
*         float *r,                                                      *  
*         float adaptrate,                                               *  
*         float error,                                                   *  
*         int nh,                                                        *  
*         int nr                                                         *  
*         )                                                              *  
*                                                                        *  
*       x        :  Pointer to input samples                             *  
*       h        :  Pointer to the coefficient array                     *  
*       desired  :  Pointer to the desired output array                  *  
*       r        :  Pointer to filtered output array                     *  
*       adaptrate:  Adaptation rate                                      *  
*       error    :  Initial error                                        *  
*       nh        :  Number of coefficients                              *  
*       nr        :  Number of output samples                            *  
*                                                                        *  
*  DESCRIPTION                                                           *  
*                                                                        *  
*      The DSPF_sp_lms implements an LMS adaptive filter.                *
*      Given an actual input signal and a desired input signal, the      *
*      filter produces an output signal, the final coefficient values    *
*      and returns the final output error signal.                        *  
*                                                                        *  
*                                                                        *  
*    C CODE                                                              *  
*                                                                        *  
*    This is the C equivalent of the Assembly Code without               *  
*    restrictions.                                                       *  
*                                                                        *  
*    Note that the assembly code is hand optimized and restrictions      *  
*    may apply.                                                          *  
*                                                                        *  
*    float DSPF_sp_lms(float *x,float *h,float *y,int nh,float *d,       *
*                      float ar,short nr, float error)                   *  
*    {                                                                   *  
*        int i,j;                                                        *  
*        float sum;                                                      *  
*                                                                        *  
*        for (i = 0; i < nr; i++)                                        *  
*        {                                                               *  
*        for (j = 0; j < nh; j++)                                        *  
*        {                                                               *  
*            h[j] = h[j] + (ar*error*x[i+j-1]);                          *  
*        }                                                               *  
*                                                                        *  
*        sum = 0.0f;                                                     *  
*        for (j = 0; j < nh; j++)                                        *  
*        {                                                               *  
*            sum += h[j] * x[i+j];                                       *  
*        }                                                               *  
*        y[i] = sum;                                                     *  
*        error = d[i] - sum;                                             *  
*       }                                                                *  
*       return error;                                                    *  
*     }                                                                  *  
*                                                                        *  
*  TECHNIQUES                                                            *  
*                                                                        *  
*    1. The inner loop is unrolled four times to allow update of         *  
*       four coefficients in the kernel.                                 *  
*    2. LDDW instruction is used to load in the coefficients.            *  
*                                                                        *  
*                                                                        *  
*    ASSUMPTIONS                                                         *  
*                                                                        *  
*    1. The h array must be double word aligned.                         *  
*    2. The coefficient array is assumed to be in reverse order,         *  
*       i.e. h(nh-1) to h(0) hold coeffs. h0,h1,h2 etc.                  *  
*                                                                        *  
* ---------------------------------------------------------------------- *
*             Copyright (c) 2003 Texas Instruments, Incorporated.        *
*                            All Rights Reserved.                        *
* ====================================================================== *

            .global	_DSPF_sp_lms
            
_DSPF_sp_lms:  .cproc  x_ptr, h_ptr, desired, r, ar, error, nh, nr
             
             .reg       h1:h0, h3:h2
             .reg       x0,    x1,   x2,   x3
             .reg       ae    
             .reg       temp
             .reg       d
             .reg       sh, nhcopy
             .reg       j
             .reg       s0,    s1,   s2,   s3
             .reg       p

;========================================================================                  

            ZERO       x3                      ; init overlapping input
            MV         nh,         nhcopy      ; make a copy of 'nh'
oloop:

            ZERO  .1     s0                      ; init the sums
            ZERO  .2     s1
            ZERO  .1     s2
            ZERO  .2     s3
            
            MV         nh,         j           ; init inner loop ctr
            MPYSP      ar,         error,   ae ; get the ar*er product    
            
iloop:                                                
            MPYSP      ae,         x3,      temp; calc error in h0 
            
            LDW        *x_ptr++,   x0           ; load the input values
            LDW        *x_ptr++,   x1
            LDW        *x_ptr++,   x2
            LDW        *x_ptr++,   x3     
            LDDW       *h_ptr,     h1:h0        ; get the first pair of h's
                        
            ADDSP      h0,         temp,    sh  ; calc the new h0
            STW        sh,         *h_ptr++     ; store new h0
            MPYSP      sh,         x0,      p   ; 
            ADDSP      p,          s0,      s0  ; multiply with x0 and add 
            
            
                        
            MPYSP      ae,         x0,      temp; calc error in h1
            ADDSP      h1,         temp,    sh  ; calc the new h1
            STW        sh,         *h_ptr++     ; store the new h1
            MPYSP      sh,         x1,      p   ; 
            ADDSP      p,          s1,      s1  ; multiply with x1 and add
            
            
            
            LDDW       *h_ptr,     h1:h0        ; get the second pair of h's
                                                ; h1:h0 now has h3:h2 
            MPYSP      ae,         x1,      temp; calc error in h2
            ADDSP      h0,         temp,    sh  ; calc new h2
            STW        sh,        *h_ptr++      ; store new h2
            MPYSP      sh,        x2,       p   ; 
            ADDSP      p,         s2,       s2  ; multiply with x2 and add        
            
            
            
            MPYSP      ae,         x2,      temp; calc error in h3
            ADDSP      h1,         temp,    sh  ; calc new h3
            STW        sh,        *h_ptr++      ; store new h3     
            MPYSP      sh,        x3,       p   ; 
            ADDSP      p,         s3,       s3  ; multiply with x3 and add                                 
            
            
                        
            SUB        j,          4,       j   ; decrement inner loop ctr
        [j] B          iloop                    ; branch to top of inner loop
        
            ADDSP      s0,         s1,      s0  ; accumulate the 4 split sums
            ADDSP      s2,         s3,      s2  
            ADDSP      s0,         s2,      s0
            
            STW        s0,         *r++         ; store the sum into o/p array
            LDW        *desired++, d            ; load the desired o/p
            SUBSP      d,          s0,      error ; find the error
            SUBAW      x_ptr,      nh,      x_ptr ; reset the x_ptr value
            LDW        *x_ptr,     x3             ; load x3 for next outer loop
            ADDAW      x_ptr,      1,       x_ptr ; adv x_ptr for next outer loop
            SUBAW      h_ptr,      nhcopy,  h_ptr ; reset the h_ptr value           
            
            SUB        nr,         1,       nr    ; decrement the outer loop ctr
        [nr]B          oloop                      ; branch to top of outer loop
           
            .return error
            .endproc

* ======================================================================== * 
*   End of file:  sp_lms.sa                                                *
* ------------------------------------------------------------------------ *
*             Copyright (c) 2003 Texas Instruments, Incorporated.          *
*                            All Rights Reserved.                          *
* ======================================================================== *