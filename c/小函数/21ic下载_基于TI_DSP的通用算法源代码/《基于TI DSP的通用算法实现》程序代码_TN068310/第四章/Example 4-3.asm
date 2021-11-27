
; Example 4 - 3. IIR Filter Implementation Using Cacade Biquad Structure ASM Listing for the TMS320C24x DSP

;========================================================================
;
; File Name     : iir16a.asm
; 
; Originator    : Digital Control Systems Group 
;                 Texas Instruments 
; 
; Description   : This file contain source code for 16 bit IIR implementation
;               
; Date          : 7/2/2001
;======================================================================
; 
; 
; Routine Name  : Generic Function      
; Routine Type  : C Callable
; 
; Description   :
; void IIR5BIQ16_calc(IIR5BIQ16_handle) 
;
; This routine implements the IIR filter using cacade biquad structure
;======================================================================
;typedef struct {   
;   int *coeff_ptr;         /* Pointer to Filter coefficient */
;   int *dbuffer_ptr;       /* Delay buffer ptr              */
;   int nbiq;               /* No of biquad                  */
;   int input;              /* Latest Input sample           */
;   int isf;                /* Input Scale Factor            */ 
;   int qfmat;              /* Coefficients Q Format         */
;   int output;             /* Filter Output                 */
;   void (*init)(void *);   /* Ptr to Init funtion           */
;   void (*calc)(void *);   /* Ptr to calc fn                */
;        }IIR5BIQ16;     
;=====================================================================

;====================================================================
; Function Local Frame
;====================================================================
;   |_______|
;   |_______|<- Stack Pointer                           (FP+1) <---AR1
;   |_______|<- Register to Register Tfr & Computation  (FP)   <---AR0 
;   |_______|<- Old FP                                  (FP-1)
;   |_______|<- Return Address of the Caller            (FP-2) 
;   |_______|<- Formal parameter IIR5BIQ16_handle       (FP-3) 
;======================================================================

; Module definition for external referance
                .def    IIR5BIQ16_calc  
QFORMAT         .set     0     
FIXSFT          .set     0
DARAM_DB        .set     0          

__iir16_calc_frs    .set    00001h          ; Local frame size for this routine 
          
          
IIR5BIQ16_calc:     
            POPD    *+              ; Store the Return Address in stack
            SAR     AR0,*+          ; Store the Caller's Frame Pointer
            SAR     AR1,*
            LAR     AR0,#__iir16_calc_frs       
            LAR     AR0,*0+,AR2     ; Create Local frame
            
            LAR     AR2,#0FFFDh     ; ARP=AR2, AR2=-3
            MAR     *0+             ; ARP=AR2, AR2=FP-3 points to the input argument 

            SETC    SXM         
            SETC    OVM             
            SPM     #0
            LAR     AR2,*           ; ARP=AR2, AR2=IIR5BIQ16_handle->coeff_ptr->a21
            LAR     AR3,*+          ; ARP=AR2, AR2->dbuffer_ptr, AR3=coeff_ptr->a21
            LAR     AR4,*+          ; ARP=AR2, AR2->nbiq, AR4=dbuffer_ptr->d1(n-2)
            LAR     AR5,*+          ; ARP=AR2, AR2->input, AR5=nbiq  
            LT      *+              ; ARP=AR2, AR2->isf, TREG=input
            MPY     *+,AR5          ; ARP=AR5, AR5->nbiq, AR2->qfmat, PREG=input*isf
            MAR     *-,AR4          ; ARP=AR4, AR4=dbuffer_ptr->d1(n-2), AR5=nbiq-1
            PAC                     ; ACC=input*isf @ in            
                                    
biqd:                               ; kth Biquad Computation   where k=1:nbiq
            LT      *-,AR3          ; ARP=AR3, AR3->a2k, TREG=dk(n-2), AR4->dk(n-1)             
            MPY     *+,AR4          ; ARP=AR4, AR4->dk(n-1),PREG=dk(n-2)*a2k, AR3->a1k            
            
            LTA     *+,AR3          ; ARP=AR3, AR3->a1k, TREG=dk(n-1),AR4->dk(n-2) 
                                    ; ACC=in+dk(n-2)*a2k
            MPY     *+,AR4          ; ARP=AR4, AR4->dk(n-2), PREG=dk(n-1)*a1k,AR3->b2k
;====================================================================================
;Dynamic Shifting vs. Fixed Shifting 
;Delay buffer in DARAM vs. Not in DARAM
;====================================================================================


    .if FIXSFT  
       
            .if     DARAM_DB    
            LTA     *-,AR0          ; ARP=AR0, AR0=FP, TREG=d(n-2), AR4->dk(n-1)
                                    ; ACC=in+dk(n-2)*a2k+d1(n-1)*a1k=dk(n) 
            .else                                                                                                
            LTA     *-              ; ARP=AR4, AR4->d(n-1), TREG=d(n-2),
                                    ; ACC=in+dk(n-2)*a2k+d1(n-1)*a1k=dk(n)
            LPH     *+              ; ARP=AR4, AR4->d(n-2),PREGH=dk(n-2)
            SPH     *-,AR0          ; ARP=AR0, AR0=FP, AR4->d(n-1), dk(n-2)=dk(n-1)
            .endif
            
            SACH    *,(16-QFORMAT),AR3  ; ARP=AR3, AR3->b2k, *FP=dk(n)  
            
     .else
     
            .if     DARAM_DB    
            LTA     *-,AR2          ; ARP=AR2, AR2->qfmat, TREG=d(n-2), AR4->dk(n-1)
                                    ; ACC=in+dk(n-2)*a2k+d1(n-1)*a1k=dk(n) 
            .else                                                                                                
            LTA     *-              ; ARP=AR4, AR4->d(n-1), TREG=d(n-2),
                                    ; ACC=in+dk(n-2)*a2k+d1(n-1)*a1k=dk(n)
            LPH     *+              ; ARP=AR4, AR4->d(n-2),PREGH=dk(n-2)
            SPH     *-,AR2          ; ARP=AR2, AR2->qfmat, AR4->d(n-1), dk(n-2)=dk(n-1)
            .endif
            RPT     *               
            SFL
            MAR     *,AR0           ; ARP=AR0, AR0=FP       
            SACH    *,0,AR3         ; ARP=AR3, AR3->b2k, *FP=dk(n) 
    .endif
    
     
            LACL    #0              ; ACC=0, Zeros computation
            MPY     *+,AR4          ; ARP=AR4, AR4->dk(n-1), PREG=dn(k-2)*b2k, AR3->b1k
            
            .if     DARAM_DB
            LTD     *,AR3           ; ARP=AR3, AR3->b1k, TREG=dk(n-1), dk(n-2)=dk(n-1),AR4->dk(n-1)  
                                    ; ACC=dn(k-2)*b2k  
            .else
            LTA     *,AR3           ; ARP=AR3, AR3->b1k, TREG=dk(n-1),AR4->dk(n-1)  
                                    ; ACC=dn(k-2)*b2k  
            .endif
                                    
            MPY     *+,AR0          ; ARP=AR0, AR0->dk(n), PREG=dk(n-1)*b1k, AR3->b0k                               
            LTA     *,AR3           ; ARP=AR3, AR3->b0k, TREG=dk(n)
                                    ; ACC=dn(k-2)*b2k+dk(n-1)*b1k
            MPY     *+,AR4          ; ARP=AR4, AR4->dk(n-1), PREG=b0k*dk(n), AR3->a2k+1
            APAC                    ; ACC=dn(k-2)*b2k+dk(n-1)*b1k+b0k*dk(n)
            MPY     #1              ; PREGL=dk(n)
            SPL     *-,AR5          ; ARP=AR5,AR4->dk+1(n-2),dk(n-1)=dk(n)
            BANZ    biqd,*-,AR4      

            .if FIXSFT
            MAR     *,AR2           ; ARP=AR2, AR2->qfmat
            ADRK    #1              ; ARP=AR2, AR2->output
            SACH    *,(15-QFORMAT),AR1
            .else   
            MAR     *,AR2           ;ARP=AR2, AR2->qfmat
            RPT     *               
            SFL 
            ROR
            MAR     *+              ; ARP=AR2, AR2->output
            SACH    *,0,AR1         ; output=Filtered Output in Q14 format      
            .endif                  ; !!!Do not shift it left to store in Q15 format
                                    ; If you do so, and if the output is >1, then it will
                                    ; become negative..instead of the most desirable Saturation
            
            
            CLRC    OVM
            SBRK    #(__iir16_calc_frs+1)   ; Clear the local frame
            LAR     AR0,*-          ; Retrive Caller's frame pointer
            PSHD    *               ; Push the return address to TOS
            RET                     ; Return to the caller
            
            
                           
