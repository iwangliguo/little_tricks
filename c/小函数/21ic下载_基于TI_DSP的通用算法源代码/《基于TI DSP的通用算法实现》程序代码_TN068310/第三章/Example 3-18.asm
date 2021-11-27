
;Example 3 - 18. Integer Scaling BFP Based DIT Radix-2 FFT Implementation ASM Listing for TMS320C55x

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


;***********************************************************
; Version 2.20.02                                           
;***********************************************************
; Processor:   C55xx
; Description: Radix-2 DIT complex FFT using normal input data
;    and bit-reversed twiddle table (length N/2, cosine/sine format)
;    All stages are in radix-2.
; Usage:    void cfft_bfp(DATA *xy, ushort nx);
; Copyright Texas instruments Inc, 2000
; History:
; 	- 07/18/2002	Sira fixed the bug in the kernal.
;   - 06/19/2003    David Elam - modified to perform BFP FFT 
;					and support 8-point FFT. 
;****************************************************************

;-----------------------------------------------------------------------
; Arguments passed to _fft
;
; ar0       ->    fftdata pointer
; t0        ->    fft size
;
;-------------------------------------------------------------------------



;//-----------------------------------------------------------------------------
;// Array declarations
;//-----------------------------------------------------------------------------


	.ref	twiddle  ; include twiddle table	
	         


        .def _cfft_bfp     ; make function visible to other fnct
        .cpl_on
        .arms_off     ; enable assembler for arms mode
        .mmregs
        .noremark    5579, 5573, 5549
  
; Stack frame
; -----------
RET_ADDR_SZ       .set 1            ;return address
REG_SAVE_SZ       .set 0            ;save-on-entry registers saved
FRAME_SZ          .set 4            ;local variables
ARG_BLK_SZ        .set 0            ;argument block

PARAM_OFFSET      .set ARG_BLK_SZ + FRAME_SZ + REG_SAVE_SZ + RET_ADDR_SZ


; Local variables
; --------------      
	   .asg	   0, ret_exp      
       .asg    1, data_ptr
       .asg    2, data_sz
       .asg    3, bit_buf

;//-----------------------------------------------------------------------------
;// Temp data
;//-----------------------------------------------------------------------------

		.bss tempmem, 2, , 2
		.bss tempmem1, 2, , 2 

;//-----------------------------------------------------------------------------
;// Register aliases
;//-----------------------------------------------------------------------------
		.asg	T3,groups		; number of butterfly groups
		.asg	T1,index		; addess adjustment
		.asg	AR7,bflies		; number of butterflies/group
		.asg	AR4,k			; outer loop counter
		.asg	AR2,a			; top butterfly pointer
		.asg	AR3,b			; bottom butterfly pointer
		.asg	AR5,temp		; temp register	
		

      
        .text           


_cfft_bfp



;
; Save any save-on-entry registers that are used
;----------------------------------------------------------------
;

      PSH	mmap(ST0_55)
      PSH	mmap(ST1_55)
      PSH	mmap(ST2_55)  

      PSH T2
      PSH T3
	PSHBOTH XAR5
	PSHBOTH XAR6
	PSHBOTH XAR7
	
;
; Allocate the local frame and argument block
;----------------------------------------------------------------
	AADD	#-(ARG_BLK_SZ + FRAME_SZ + REG_SAVE_SZ), SP
	

;
; Save entry values for later
;----------------------------------------------------------------

	MOV AR0, *sp(data_ptr) ; put starting address on stack
    MOV T0, *sp(data_sz)   ; put size on stack
    MOV #0, *sp(ret_exp)   ; initialize stack space for BFP exponent
	MOV #1, *sp(bit_buf)   ; put bit growth buffer on stack for first
						   ; two stages - will be 2 for all following stages

;-----------------------------------------------------------------------
; FFT implementation
;
; The FFT is implemented in 5 different steps:
;
;  1) - a radix-2 stage without any multiplications.
;  2) - a radix-2 stage with two groups, only the 2nd group has
;       multiplications with 0x7FFFFFFH and 0x00000000
;  3) - a group of log2(FFT_SIZE)-3 radix-2 stages
;  4) - a radix-2 stage without scaling.
;  5) - on in-place bit-reversal

;-----------------------------------------------------------------------
; Modification of status registers
;-----------------------------------------------------------------------
	  
        BSET	FRCT
        BSET	SATD
        BSET	SXMD          
        BCLR #ARMS, ST2_55          
	  	BCLR #C54CM, ST1_55 
	  	
	

;***********************************************************************
	CALL scale_exp	; find maximum absolute value from previous stage
						; scale by 2^(exponent of max value - 2)
;***********************************************************************
	
; radix-2 stage 1
;
; 
  
		 MOV T0, T1
		 ADD T0, T1
		 ADD T1, AR0
         MOV #2, T1
         MOV XAR0, XAR2
         MOV XAR0, XAR4
         MOV *sp(data_ptr), AR2		; ar2 = #fftdata  
         MOV AR2, AR4               ; ar4 = #fftdata  
         MOV AR2, AR0
         AADD T0, AR0               ; ar0 = fftdata + fft_size
         MOV XAR0, XAR5				; ar5 = fftdata + fft_size
         MOV T0, T2
         SFTS T2, #-1               ; T2 = fft_size/2 
         MOV T2, AR7
         SUB #2, AR7
         MOV AR7, BRC0
        
        
        
                 ; ac2=Qr[0]:Qi[0] 
        MOV dbl(*(ar0+t1)), ac2      
                
                ; ac0 = Pr[0]+Qr[0]:Pi[0]+Qi[0]
                ;     = Pr'[0]:Pr'[0]
           
       ADD	dual(*AR2), AC2, AC0 
   

        
                ; ac1 = Pr[0]-Qr[0]:Pi[0]-Qi[0]
                ;     = Qr'[0]:Qi'[0]
                ; store P'[0]
       SUB	AC2, dual(*(AR2+T1)), AC1    
      || MOV ac0, dbl(*(ar4+t1))               
                                       
                 
        RPTBLOCAL r2_loop00 -1          


        MOV dbl(*(ar0+t1)), ac2         	; load Q            
        || MOV ac1, dbl(*(ar5+t1))     ; store new Q   
        
           
         ADD	dual(*AR2), AC2, AC0        ; new P   
            
          SUB	AC2, dual(*(AR2+T1)), AC1   ; new Q 
      || MOV ac0, dbl(*(ar4+t1))       ; store new P  

r2_loop00:	
		 
                    
         MOV ac1, dbl(*(ar5+t1))     ; store new Q   

;***********************************************************************
	CALL scale_exp	; find maximum absolute value from previous stage
						; scale by 2^(exponent of max value - 2)
;***********************************************************************

; radix-2 stage 2
;
; groupe #1 twiddle = #1  


         MOV *sp(data_ptr), AR2		; ar2 = #fftdata  
         MOV AR2, AR4               ; ar4 = #fftdata  
         MOV AR2, AR0
         ADD T2, AR0                ; ar0 = fftdata + fft_size/2
         MOV AR0, AR5				; ar5 = fftdata + fft_size/2  
         MOV T2, T3                 ; T3= fft_size/2
         SFTS T2, #-1               ; T2 = fft_size/4 
         SUB #2, T2
         MOV T2, BRC0               ; BRC0 = fft_size/4 - 2
       
                                	
 
                   ; ac2=Qr[0]:Qi[0] 
        MOV dbl(*(ar0+t1)), ac2       
                
                ; ac0 = Pr[0]+Qr[0]:Pi[0]+Qi[0]
                ;     = Pr'[0]:Pr'[0]
                ; cdp = #twiddle
       ADD	dual(*AR2), AC2, AC0 
   

        
                ; ac1 = Pr[0]-Qr[0]:Pi[0]-Qi[0]
                ;     = Qr'[0]:Qi'[0]
                ; store P'[0]
       SUB	AC2, dual(*(AR2+T1)), AC1    
      || MOV ac0, dbl(*(ar4+t1))               
                                       
                 
        RPTBLOCAL r2_loop01 -1          


        MOV dbl(*(ar0+t1)), ac2         	; load Q            
        || MOV ac1, dbl(*(ar5+t1))     ; store new Q   
        
           
         ADD	dual(*AR2), AC2, AC0        ; new P   
 
       SUB	AC2, dual(*(AR2+T1)), AC1   ; new Q 
      || MOV ac0, dbl(*(ar4+t1))       ; store new P  

r2_loop01:	
		 
                    
         MOV ac1, dbl(*(ar5+t1))     ; store new Q    
                 
 
; radix-2 stage 2
;
; groupe #2 twiddle = #-1    


         MOV *sp(data_ptr), AR2		; ar2 = #fftdata  
         ADD T0, AR2				; ar2 = #fftdata + fft_size
         MOV AR2, AR4               ; ar4 = #fftdata + fft_size  
         MOV AR2, AR0
         ADD T3,  AR0               ; ar0 = #fftdata + 3/2*fft_size 
         MOV AR0, AR1
         ADD #1, AR1
         MOV AR0, AR5				; ar5 = #fftdata + 3/2*fft_size
         MOV T2, BRC0               ; ; BRC0 = fft_size/4 - 2                           	
         AMOV #twiddle, xar3		; 
         ADD #2, AR3    			; 
         MOV XAR3, XCDP				; 

                      
                    ; ac2=Qr[n]*Wr                                    
                    ; ac3=Qi[n]*Wr
          MPY	*AR0, *CDP+, AC2               
        ::MPY	*AR1, *CDP+, AC3  
       
                   ; ac3=Qi[n]*Wr+Qr[n]*Wi
                    ; ac2=Qr[n]*Wr-Qi[n]*Wi

         
          MASR	*(AR0+T1), *CDP-, AC3
         ::MACR	*(AR1+T1), *CDP-, AC2 
        
                    ; ac2=(Qr[n]*Wr-Qi[n]*Wi):(Qi[n]*Wr+Qr[n]*Wi)

         
         OR AC3 << #-16, AC2
         
                    ; hi(ac0)=Pr[n]+(Qr[n]*Wr-Qi[n]*Wi)=Pr'[n]
                    ; lo(ac0)=Pi[n]+(Qr[n]*Wi+Qi[n]*Wr)=Pi'[n]
                             
         	   ADD	dual(*AR2), AC2, AC0            
   
                       ; hi(ac1)=Pr[n]-(Qr[n]*Wr-Qi[n]*Wi)=Qr'[n] 
                    ; lo(ac1)=Pi[n]-(Qr[n]*Wi+Qi[n]*Wr)=Qi'[n]
                    ; store Pr'[n]:Pi'[n]

    	SUB	AC2, dual(*(AR2+T1)), AC1
		|| MOV ac0, dbl(*(ar4+t1)) 
   
                                                          
        
          RPTBLOCAL r2_loop02          


                    ; ac2=Qr[n]*Wr                                    
                    ; ac3=Qi[n]*Wr
          MPY	*AR0, *CDP+, AC2               
        ::MPY	*AR1, *CDP+, AC3                           
                
        
                    ; ac3=Qi[n]*Wr+Qr[n]*Wi
                    ; ac2=Qr[n]*Wr-Qi[n]*Wi  --correct commenting!

          
        MASR	*(AR0+T1), *CDP-, AC3   
        :: MACR	*(AR1+T1), *CDP-, AC2  
            
                    ; ac2=(Qr[n]*Wr-Qi[n]*Wi):(Qi[n]*Wr+Qr[n]*Wi)

         
          OR AC3 << #-16, AC2     
                    ; hi(ac0)=Pr[n]+(Qr[n]*Wr-Qi[n]*Wi)=Pr'[n]
                    ; lo(ac0)=Pi[n]+(Qr[n]*Wi+Qi[n]*Wr)=Pi'[n]
                    ; store Qr'[n-1]:Qi'[n-1]

	   ADD	dual(*AR2), AC2, AC0
	   ||  MOV ac1, dbl(*(ar5+t1)) 
    
    
                    ; hi(ac1)=Pr[n]-(Qr[n]*Wr-Qi[n]*Wi)=Qr'[n] 
                    ; lo(ac1)=Pi[n]-(Qr[n]*Wi+Qi[n]*Wr)=Qi'[n]
                    ; store Pr'[n]:Pi'[n]

r2_loop02:	SUB	AC2, dual(*(AR2+T1)), AC1
		|| MOV ac0, dbl(*(ar4+t1)) 
        
                                   ; end of butterfly loop
                              
          MOV ac1, dbl(*(ar5+t1))  
            
          MOV *sp(data_sz), T0		  
		  SUB #8, T0		  
		  BCC final_stage, T0==#0  	; branch to final stage for 8-point fft

 
;-----------------------------------------------------------------------
; radix-2 stages (stages 3->log2(FFT_SIZE) )
        


        ; main initialization
        ; --------------------
       ADD #1, *sp(bit_buf)			; define next stage bit-growth
        
       MOV *sp(data_ptr), AR0		; ar0 = #fftdata
       ;MOV  #twiddle, AR3 
            ; 1 - circular buffer initializations

        
            ; modify ST2 to select linear or circular addressing modes
       OR	#0x57 , mmap(ST2_55)  ; circular ar0, ar1, ar2, ar4 and ar6
         

            ; circular buffer starting addresses
        ADD #2, ar0,ar1
        MOV mmap(@ar0),bsa23       ; P  leg
        MOV mmap(@ar0),bsa45       ; P' leg    (in-place butterflies)
        MOV mmap(@ar1),bsa01       ; Q  leg
        MOV mmap(@ar1),bsa67       ; Q' leg    (in-place butterflies)
                            
            ; circular buffer sizes 
	  MOV *sp(data_sz), T0
        MOV T0, T1		; T1 =  #FFT_SIZE
	  SFTS T0, #1        
        SUB #2, T0
    
        MOV mmap(@T0_L), bk03          	; bk03 = (2*FFT_SIZE-2), 
        MOV mmap(@T0_L), bk47   ; bk47 = (2*FFT_SIZE-2), 

            ; 2 - register initializations
        
       MOV *sp(data_sz), T0
       SFTS T0, #-1
       SFTS T0, #-1
        
        MOV T0, ar5   ; 2*number of groups for stage 3    
        MOV #2, ar7          ; 1/2 * number of butterflies per group for stage 3
       

        ;AMOV #twiddle, xar3        ; not modified during iteration of the stages
        MOV xar0,xar1            ; data page = data page of indata
        MOV xar0,xar2            ; data page = data page of indata
        MOV xar0,xar4   ; data page = data page of indata (in-place butterflies)
        MOV xar0,xar6   ; data page = data page of indata (in-place butterflies)
        MOV xar3,xcdp      ; data page = data page of twiddles
        
        
stage:    ; begining of a new stage

        ; stage initialization
        ; --------------------
              
;***********************************************************************
	CALL scale_exp	; find maximum absolute value from previous stage
						; scale by 2^(exponent of max value - 2)
;***********************************************************************

            ; 1 - loop counter updates
        
            ; butterfly counter update
       SFTS ar7, #1
    ||    MOV #0, ar4 
        SUB #2,ar7,ar0
        MOV ar0, brc1        ;1 butterflies executed out of the loop

            ; group counter update
        SFTS ar5, #-1
        SUB  #1,ar5,ar0     
        MOV ar0, brc0         

            ; stage "counter" update (t0=0 <=> last stage)
         AMOV ar0, t0

            ; 2 - pointer modifier update
                            
            ; t1 is the pointer modifier                    
    ||   SFTS  t1,#-1        

            ; 3 - index updates                  
            ; ar0 -> Qr[0]
            ; ar1 -> Qi[0]
            ; ar2 -> Pr[0]
            ; ar4 -> Pr'[0]  (performed above to use parallelism)
            ; ar6 -> Qr'[0]

 
        SFTS ar0, #1
        ADD #1, ar0,ar1
        MOV #0, ar2
    ||  MOV ar0, ar6 
        
        
        
group:  ; begining of a new group
        

        ; note:
        ; - circular buffers are used for data pointers so that no
        ;   initialization of data pointers is required before a new
        ;   iteration of a group
        ; - twiddle pointer (cdp) is updated inside the loop
        
                
        RPTBLOCAL r2_loop1

        
                ; ac2=Qr[0]:Qi[0] 
        MOV dbl(*(ar0+t1)), ac2
    ||  ADD  t1,ar1       
                
                ; ac0 = Pr[0]+Qr[0]:Pi[0]+Qi[0]
                ;     = Pr'[0]:Pr'[0]
                ; cdp = #twiddle
       ADD	dual(*AR2), AC2, AC0 
      ||    MOV ar3, cdp

        
                ; ac1 = Pr[0]-Qr[0]:Pi[0]-Qi[0]
                ;     = Qr'[0]:Qi'[0]
                ; store P'[0]
       SUB	AC2, dual(*(AR2+T1)), AC1    
      || MOV ac0, dbl(*(ar4+t1))               
                                                          
        ; --------------------------------------------------------------        
        ; DIT radix-2 butterfly
        ;
        ; Register usage:
        ; 
        ;     address registers
        ; ar0 = Qr
        ; ar1 = Qi
        ; ar2 = Pr:Pi
        ; ar4 = Pr':Pi'
        ; ar6 = Qr':Qi'
        ; cdp = Wr:Wi
        ;
        ;     temporary registers
        ; t1 pointer modifier (jump between two consecutive legs)
        ; t2, t3 - both modified
        ;
        ;     accu registers
        ; ac0, ac1, ac2, ac3 are all modified
        ; 
        ;
        ; Comments:
        ;
        ; This butterfly supports both in-place and out-if-place
        ; implementations.
        ;
        ; input data assumed to be in order (bit-reversion after fft)
        ;
        ; twiddle table
        ;   - assumed to be in bit-reversed order
        ;     - the twiddle factors stored in the tables are the pairs
        ;      {cos(2*pi*k/N) , sin(2*pi*k/N)} = {Wr[k] , -Wi[k]}
        ;   - first twiddle pair {1,0} is suppressed (since the first
        ;       butterfly is computed out of the inner loop)
        ;   - second twiddle pair {0,1} replaced by {0,-1} (-1 can be
        ;     represented with full precision but not 1)
        ;   - when inner loop starts, cdp should point to the
        ;     third twiddle pair {1/sqrt(2),1/sqrt(2)}
        ;
        ; pointer registers
        ;   ar0 -> Qr[]
        ;   ar1 -> Qi[]
        ;   ar2 -> Pr[]
        ;   ar4 -> Pr'[]
        ;   ar6 -> Qr'[]
        ;   cdp -> W[] (bit-reversed twiddle table)
        ;
        ; --------------------------------------------------------------        
        
        
          RPTBLOCAL r2_loop2          


                    ; ac2=Qr[n]*Wr                                    
                    ; ac3=Qi[n]*Wr
          MPY	*AR0, *CDP+, AC2               
        ::MPY	*AR1, *CDP+, AC3                           
                
        
                    ; ac3=Qi[n]*Wr+Qr[n]*Wi
                    ; ac2=Qr[n]*Wr-Qi[n]*Wi

          
         MASR	*(AR0+T1), *CDP+, AC3   
         ::MACR	*(AR1+T1), *CDP+, AC2   
            
                    ; ac2=(Qr[n]*Wr-Qi[n]*Wi):(Qi[n]*Wr+Qr[n]*Wi)

         
          OR AC3 << #-16, AC2       
                    ; hi(ac0)=Pr[n]+(Qr[n]*Wr-Qi[n]*Wi)=Pr'[n]
                    ; lo(ac0)=Pi[n]+(Qr[n]*Wi+Qi[n]*Wr)=Pi'[n]
                    ; store Qr'[n-1]:Qi'[n-1]

	   ADD	dual(*AR2), AC2, AC0
	   ||  MOV ac1, dbl(*(ar6+t1)) 
    
    
                    ; hi(ac1)=Pr[n]-(Qr[n]*Wr-Qi[n]*Wi)=Qr'[n] 
                    ; lo(ac1)=Pi[n]-(Qr[n]*Wi+Qi[n]*Wr)=Qi'[n]
                    ; store Pr'[n]:Pi'[n]

r2_loop2:	SUB	AC2, dual(*(AR2+T1)), AC1
		|| MOV ac0, dbl(*(ar4+t1)) 
        
                                   ; end of butterfly loop
        
r2_loop1:        MOV AC1, dbl(*(ar6+t1))      ; store last Qr':Qi'
        
                                   ; end of group loop

        SUB #1, T0
        
        BCC stage,t0!=#0       ; end of stage loop 
   	   
;***********************************************************************
	CALL scale_exp	; find maximum absolute value from previous stage
						; scale by 2^(exponent of max value - 2)
;***********************************************************************

; last r2 stage
; no scaling performed
;
; modify ST2 to select linear or circular addressing modes
final_stage:   AND	#0xF000 , mmap(ST2_55)  ; circular ar0, ar1, ar2, ar4 and ar6
      
         MOV #2, T1  
         MOV *sp(data_sz), T0       ; t0 = #fftsize
         MOV *sp(data_ptr), AR2		; ar2 = #fftdata  
         MOV AR2, AR4               ; ar4 = #fftdata  
         MOV AR2, AR0
         AADD T1, AR0               ; ar0 = fftdata + 2 
         MOV #7, AR1
         ADD AR2, AR1               ; 
         MOV AR0, AR5				; ar5 = fftdata + 2 
         SFTS T0, #-1  
         SUB #2, T0
         MOV T0, BRC0               ; brc0 = fftsize/2-2 
         MOV #4, T1
         MOV ar3, cdp             
                      
              ; ac2=Qr[0]:Qi[0] 
        MOV dbl(*(ar0+t1)), ac2
       
                
                ; ac0 = Pr[0]+Qr[0]:Pi[0]+Qi[0]
                ;     = Pr'[0]:Pr'[0]
                ; cdp = #twiddle
       ADD	dual(*AR2), AC2, AC0 

        
                ; ac1 = Pr[0]-Qr[0]:Pi[0]-Qi[0]
                ;     = Qr'[0]:Qi'[0]
                ; store P'[0]
       SUB	AC2, dual(*(AR2+T1)), AC1    
      || MOV ac0, dbl(*(ar4+t1))               
                                                          
        
          RPTBLOCAL r2_loop3          


                    ; ac2=Qr[n]*Wr                                    
                    ; ac3=Qi[n]*Wr
          MPY	*AR0, *CDP+, AC2               
        ::MPY	*AR1, *CDP+, AC3                           
                
        
                    ; ac3=Qi[n]*Wr+Qr[n]*Wi
                    ; ac2=Qr[n]*Wr-Qi[n]*Wi

        MASR	*(AR0+T1), *CDP+, AC3  
        ::MACR	*(AR1+T1), *CDP+, AC2   
            
            
                    ; ac2=(Qr[n]*Wr-Qi[n]*Wi):(Qi[n]*Wr+Qr[n]*Wi)

        
          OR AC3 << #-16, AC2      
                    ; hi(ac0)=Pr[n]+(Qr[n]*Wr-Qi[n]*Wi)=Pr'[n]
                    ; lo(ac0)=Pi[n]+(Qr[n]*Wi+Qi[n]*Wr)=Pi'[n]
                    ; store Qr'[n-1]:Qi'[n-1]

	   ADD	dual(*AR2), AC2, AC0
	   ||  MOV ac1, dbl(*(ar5+t1)) 
    
    
                    ; hi(ac1)=Pr[n]-(Qr[n]*Wr-Qi[n]*Wi)=Qr'[n] 
                    ; lo(ac1)=Pi[n]-(Qr[n]*Wi+Qi[n]*Wr)=Qi'[n]
                    ; store Pr'[n]:Pi'[n]

r2_loop3:	SUB	AC2, dual(*(AR2+T1)), AC1
		|| MOV ac0, dbl(*(ar4+t1)) 
        
                                   ; end of butterfly loop
                              
                      
        MOV AC1, dbl(*(ar5+t1))
      
              
end_benchmark:

	MOV *sp(ret_exp), T0		; return total number of shifts in AC0
;
; Allocate the local frame and argument block
;----------------------------------------------------------------
	AADD	#(ARG_BLK_SZ + FRAME_SZ + REG_SAVE_SZ), SP


;Context restore 



	POPBOTH XAR7
	POPBOTH XAR6
	POPBOTH XAR5
      POP T3
      POP T2 

      POP	mmap(ST2_55)
      POP	mmap(ST1_55)
      POP	mmap(ST0_55)

	RET 
	
;*******************************************************************************
; scale_exp:   Find maximum absolute value in array specified by 
; 		   	   address AR3 and length T0. Pre-scale the input to next
;			   radix-2 stage by 2^(exponent of the maximum absolute 
;			   value - 1) for first two stages and by 2^(exponent of 
;			   the maximum absolute value - 2) for all following stages
;*******************************************************************************
scale_exp:
	PSH dbl(AC0)				; save registers to be modified	(stack size += 12)
	PSH dbl(AC1)
	PSH dbl(AC2)
	PSH dbl(AC3)
	PSH AR3				
	PSH T0
	PSH T1

; find maximum absolute value (real and imaginary)
;-------------------------------------------------------------------------------
	MOV *sp(data_ptr + 12), AR3	; load array size into AR3 (sp offset computed from 
	MOV *sp(data_sz + 12), T0	; above pushed registers and the return address

	SUB #2, T0
    || MOV dbl(*AR3+), AC0		; AC0_H = x_Re[0],  AC0_L = x_Im[1]

    MOV T0, BRC0				; BRC0 = NX - 2
    || MOV dbl(*AR3), AC1 		; AC1_H = x_Re[2],  AC1_L = x_Im[3]

	MOV dbl(*AR3+), AC2			; AC2_H = x_Re[2],  AC1_L = x_Im[3]		
    || RPTBLOCAL find_max  
	
	MAXDIFF AC0, AC1, AC1, AC3	; AC1_H/L contain max's

find_max: MOV dbl(*AR3+), AC0	; AC0_H = x_Re[n],  AC0_L = x_Imn+1]
    || MINDIFF AC0, AC2, AC2, AC3; AC2_H/L contain min's
	
	MOV HI(AC1), AR3			; AR3 = even max value
	MOV AC1, T0					; T0  = odd  max value	   				
	MAX AR3, T0					
	
	MOV HI(AC2), T1				; T1  = odd  min value
	MOV AC2, AR3				; AR3 = even min value
	MIN AR3, T1
	ABS T1
	
	MAX T0, T1
	MOV T1, HI(AC0)				; put maximum absolute value in high part of AC0			
	
; scale array according to maximum asbolute value
;----------------------------------------------------------------------------	
	EXP AC0, T1					; determine exponent from maximum absolute value
	MOV *sp(bit_buf + 12), AR3	; AR3 contains expected bit growth
	SUB AR3, T1					; subtract 1 or 2 from the exponent to compensate 
								; for the maximum possible bit growth (factor of 
								; 2 or 4) in the next radix-2 stage	
	
	BCC no_scale, T1 == #0		; branch if no scaling needed
	ADD *sp(ret_exp + 12), T1, AC0	; sum current with previous exponent
	MOV *sp(data_sz + 12), T0   ; put nx in T0 for next loop
	MOV AC0, *sp(ret_exp + 12)	; put exponent back on stack
    || SUB #1, T0		

	MOV *sp(data_ptr + 12), AR3
    || MOV T0, BRC0				; initialize loop counter (BRC0 = nx - 1)
				
						
	RPTBLOCAL scale	 
	MOV dbl(*AR3), pair(LO(AC0))			
	MOV AC0<<T1, *AR3+			; scale by 2^(exponent of the maximum absolute 
scale: MOV AC1<<T1, *AR3+		; value - 2)

no_scale:	POP T1				; restore registers
	POP T0
	POP AR3
	POP dbl(AC3)
	POP dbl(AC2)
	POP dbl(AC1)
	POP dbl(AC0)
	
	RET		
;-------------------------------------------------------------------------------


	.end         
        
        