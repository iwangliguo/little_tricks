
; Example 5 - 2. FIR ASM Listing for the TMS320C2x DSP

;========================================================================
;
; File Name     :fir10a.asm
; 
; Originator    :Digital Control Systems Group 
;                Texas Instruments 
; 
; Description   :This file contain source code for 10th order (Fixed Order) Filter
;               
; Date          : 13/1/2001
;======================================================================
; 
; 
; Routine Name  : Generic Function      
; Routine Type  : C callable 
; 
; Description   :
; void FIRFILT_ORD10_calc(FIRFILT_ORD10_handle) 
; void FIRFILT_ORD10_calc(FIRFILT_ORD10S_handle)
;
; This routine implements the non-recursive difference equation of an 
; all-zero filter(FIR), of order 10. All the coefficients of all-zero 
; filter are assumed to be less than 1 in magnitude.

;======================================================================
;
; Difference Equation :
;
;       y(n)=H(0)*x(n)+H(1)*x(n-1)+H(2)*x(n-2)+....+H(10)*x(n-10)
;
;      where
;              y(n)=output sample of the filter at index n 
;              x(n)=input sample of the filter at index n 
;
; Transfer Function :
;                                  
;              Y(z)                -1        -2             -9         -10
;             ----- = h(0) + h(1) z  + h(2) z  + ... +h(9) z   + h(10) z    
;              X(z)
;
;     Network Diagram  : 

;     dbuffer[0]          dbuffer[1]    dbuffer[2]    dbuffer[10}
;     Input           -1  x(n-1)  -1    x(n-2)        x(n-10)
;   x(n) >------o----z---->-o----z---->-o---  - ->- - o
;               |           |           |             |
;               |           |           |             |
;               |           |           |             |
;               v H(0)      v H(1)      v H(2)        v H(10)  
;               |           |           |             |  
;               |           |           |             |        output
;               |---->-----(+)---->----(+)-- - -> -  (+)-----> y(n)    
;
;       Symbols Used :
;             H(0),H(1),H(2),...,H(10) : filter coefficients
;            x(n-1),x(n-2),...,x(n-10) : filter states
;                                x(n) : filter input 
;                                y(n) : filter output
;==============================================================================         
;  Function Input: This function accepts the handle of the below structure
;
;  typedef struct 
;     {int *coeff_ptr;          /* Pointer to Filter co-efficient array */
;      int *dbuffer_ptr;        /* Delay buffer pointer                 */
;      int order;               /* Order of the filter                  */
;      int input;               /* Input data                           */
;      int output;              /* Output data                          */ 
;      int dbuffer[11];         /* Delay buffer                         */
;      int coeff[11];           /* Coefficient Buffer                   */
;      void (*init)(void *)     /* Pointer to init fun                  */  
;      void (*calc)(void *);    /* Pointer to the calculation function  */
;     }FIRFILT_ORD10;    
;       
;  Filter input (x) :   
;    x(n) = | s.fff ffff | ffff ffff |
;     
;  Filter coefficients(h[]):
;    h(k) for k=0,1,2,...,10  
;       = | s.fff ffff | ffff ffff |  are stored as shown below.  
;                                                               LOWER MEMORY ADDRESS
;                                                                        |
;                      |----------|                                      |
;                      |  H(0)    |                                      |
;                      |----------|        |----------|                  |
;                      |  H(1)    |        | x(n-1)   | dbuffer[0]       |
;                      |----------|        |----------|                  |
;                      |  H(2)    |        | x(n-2)   | dbuffer[1]       |
;                      |----------|        |----------|                  |
;                      |    .     |        |    .     |                  |
;                      |    .     |        |    .     |                  |
;                      |----------|        |----------|                  V
;                      |  H(8)    |        |  x(n-8)  |                  |
;                      |----------|        |----------|                  |
;                      |  H(9)    |        |  x(n-9)  | dbuffer[8]       V
;                      |----------|        |----------|                  
;             AR3----->|  H(10)   |        |  x(n-10) | dbuffer[9] <--- AR4         
;                      |----------|        |----------|        
;                filter coefficients       filter states 
;                                                              HIGHER MEMORY ADDRESS
; Implicit inputs(dbuffer[]):
;    To compute the present output y(n), inputs x(n-i) for i=1,2,...10
;    are needed. These are stored in the filter states buffer, as shown 
;    above.
;              
; Filter order(n):
;    This member of the structure holds the order of the filter
;
; Filter output(y):
;    y(n)= | s.fff ffff | ffff ffff |  Q15 Format
;====================================================================
; Function Local Frame
;====================================================================
;   |_______|
;   |_______|<- Stack Pointer                           (FP+1) <---AR1
;   |_______|<- Register to Register Tfr & Computation  (FP)   
;   |_______|<- Old FP                                  (FP-1)
;   |_______|<- Return Address of the Caller            (FP-2) 
;   |_______|<- Formal parameter FIRFILT_GEN_handle     (FP-3) 
;======================================================================

; Symbolic Constant 

ORDER           .set    10

; Module definition for external referance
                .def    FIRFILT_ORD10_calc  


__fir_calc_frs  .set    00001h          ; Local frame size for this routine 
          
          
FIRFILT_ORD10_calc:     
            POPD    *+              ; Store the Return Address in stack
            SAR     AR0,*+          ; Store the Caller's Frame Pointer
            SAR     AR1,* 
            LAR     AR2,*+,AR2      ; ARP=AR2, AR2=FP, AR1=FP+1
            
            SETC    SXM         
            SETC    OVM  
            SPM     #0
            SBRK    #3              ; ARP=AR2, AR2=FP-3 points to the input argument
            LAR     AR2,*           ; ARP=AR2, AR2=FIRFILT_GEN_handle->coeff_ptr 
            
            LAR     AR3,*+          ; ARP=AR2, AR2->dbuffer_ptr, AR3=coeff_ptr->coeff[N] 
            LAR     AR4,*+          ; ARP=AR2, AR2->order, AR4=dbuffer_ptr->dbuffer[N-1]
            MAR     *+,AR4          ; ARP=AR4, AR4=dbuffer_ptr->dbuffer[N-1], AR2->input
            
            LACL    #0              ; Clear ACC
            LT      *-,AR3          ; ARP=AR3, TREG=dbuffer[N-1], AR4->dbuffer[N-2]
            
            .loop   (ORDER-1)
            MPY     *-,AR4          ; Filter Tap execution from oldest sample                
            LTD     *-,AR3          ; 
            .endloop
            
            MPY     *-,AR2          ; ARP=AR2, AR2->input
            LTA     *+,AR3          ; ARP=AR3, AR2->output
            MPY     *,AR2           ;
            APAC                    ;
            
            SACH    *               ; 32 bit of ACC is added with itself to get Q31 result
            ADDH    *               
            SACL    *
            ADDS    *               ; ARP=AR2, AR2->output
            ADD     #1,15           ; Round the result
            SACH    *-              ; ARP=AR2, AR2->input, Store ACCH in Q15 format
            LACL    *,AR4
            MAR     *+
            SACL    *,0,AR1         ; Store the latest sample in the delay buffer
            
            CLRC    OVM
            SBRK    #(__fir_calc_frs+1)     ; Clear the local frame
            LAR     AR0,*-          ; Retrive Caller's frame pointer
            PSHD    *               ; Push the return address to TOS
            RET                     ; Return to the caller
            
            
                           