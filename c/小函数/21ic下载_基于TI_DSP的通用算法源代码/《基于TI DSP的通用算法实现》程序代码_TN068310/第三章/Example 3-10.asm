
;Example 3 - 10. DIT Radix-2 FFT ASM Listing for TMS320C54x

;/* ============================================================================*/ 
;/*          Copyright (C) 2004 YINXING TECHNOLOGY CO., LTD                     */ 
;/*                          All Rights Reserved.                               */ 
;/* ----------------------------------------------------------------------------*/ 
;/* ============================================================================*/ 





INSTR_B       .set   0f073h
ADDR_INTR_3   .set   020Ch
fft_data      .set   2200h
d_input_addr  .set   2300h
d_output_addr .set   2200h
initst0	      .set   1800h	;set st0 initial number
initst1	      .set   2a40h	;set st1 initial number


;_DEBUG        .set   0208h      ; breakpoint srv enter address !
K_ST1	      .set   2a40h	; st1 reset value
K_FFT_SIZE    .set   128	; 128 point complex fft
K_LOGN	      .set   7          ; # of stages (=logN/log2)
K_ZERO_BK     .set   0
K_DATA_IDX_1  .set   2  	; Data index for Stage 1
K_DATA_IDX_2  .set   4  	; Data index for Stage 2
K_DATA_IDX_3  .set   8  	; Data index for Stage 3
K_TWID_TBL_SIZE .set 128 	; Twiddle table size
K_FLY_COUNT_3 .set   4    	; Butterfly counter for Stage 3
K_TWID_IDX_3  .set   32    	; Twiddle index for Stage 3


             
             .data                                                                                                                                                                                      
sine_table   .word   0h
             .word   324h
             .word   647h
             .word   96ah
             .word   0c8bh
             .word   0fabh
             .word   12c7h
             .word   15e1h
             .word   18f8h
             .word   1c0bh
             .word   1f19h
             .word   2223h
             .word   2527h
             .word   2826h
             .word   2b1eh
             .word   2e10h
             .word   30fbh
             .word   33deh
             .word   36b9h
             .word   398ch
             .word   3c56h
             .word   3f16h
             .word   41cdh
             .word   447ah
             .word   471ch
             .word   49b3h
             .word   4c3fh
             .word   4ebfh
             .word   5133h
             .word   539ah
             .word   55f4h
             .word   5842h
             .word   5a81h
             .word   5cb3h
             .word   5ed6h
             .word   60ebh
             .word   62f1h
             .word   64e7h
             .word   66ceh
             .word   68a5h
             .word   6a6ch
             .word   6c23h
             .word   6dc9h
             .word   6f5eh
             .word   70e1h
             .word   7254h
             .word   73b5h
             .word   7503h
             .word   7640h
             .word   776bh
             .word   7883h
             .word   7989h
             .word   7a7ch
             .word   7b5ch
             .word   7c29h
             .word   7ce2h
             .word   7d89h
             .word   7e1ch
             .word   7e9ch
             .word   7f08h
             .word   7f61h
             .word   7fa6h
             .word   7fd7h
             .word   7ff5h
             .word   7fffh
             .word   7ff5h
             .word   7fd7h
             .word   7fa6h
             .word   7f61h
             .word   7f08h
             .word   7e9ch
             .word   7e1ch
             .word   7d89h
             .word   7ce2h
             .word   7c29h
             .word   7b5ch
             .word   7a7ch
             .word   7989h
             .word   7883h
             .word   776bh
             .word   7640h
             .word   7503h
             .word   73b5h
             .word   7254h
             .word   70e1h
             .word   6f5eh
             .word   6dc9h
             .word   6c23h
             .word   6a6ch
             .word   68a5h
             .word   66ceh
             .word   64e7h
             .word   62f1h
             .word   60ebh
             .word   5ed6h
             .word   5cb3h
             .word   5a81h
             .word   5842h
             .word   55f4h
             .word   539ah
             .word   5133h
             .word   4ebfh
             .word   4c3fh
             .word   49b3h
             .word   471ch
             .word   447ah
             .word   41cdh
             .word   3f16h
             .word   3c56h
             .word   398ch
             .word   36b9h
             .word   33deh
             .word   30fbh
             .word   2e10h
             .word   2b1eh
             .word   2826h
             .word   2527h
             .word   2223h
             .word   1f19h
             .word   1c0bh
             .word   18f8h
             .word   15e1h
             .word   12c7h
             .word   0fabh
             .word   0c8bh
             .word   96ah
             .word   647h
             .word   324h
             .word   0h
             .word   0fcdch
             .word   0f9b9h
             .word   0f696h
             .word   0f375h
             .word   0f055h
             .word   0ed39h
             .word   0ea1fh
             .word   0e708h
             .word   0e3f5h
             .word   0e0e7h
             .word   0ddddh
             .word   0dad9h
             .word   0d7dah
             .word   0d4e2h
             .word   0d1f0h
             .word   0cf05h
             .word   0cc22h
             .word   0c947h
             .word   0c674h
             .word   0c3aah
             .word   0c0eah
             .word   0be33h
             .word   0bb86h
             .word   0b8e4h
             .word   0b64dh
             .word   0b3c1h
             .word   0b141h
             .word   0aecdh
             .word   0ac66h
             .word   0aa0ch
             .word   0a7beh
             .word   0a57fh
             .word   0a34dh
             .word   0a12ah
             .word   9f15h
             .word   9d0fh
             .word   9b19h
             .word   9932h
             .word   975bh
             .word   9594h
             .word   93ddh
             .word   9237h
             .word   90a2h
             .word   8f1fh
             .word   8dach
             .word   8c4bh
             .word   8afdh
             .word   89c0h
             .word   8895h
             .word   877dh
             .word   8677h
             .word   8584h
             .word   84a4h
             .word   83d7h
             .word   831eh
             .word   8277h
             .word   81e4h
             .word   8164h
             .word   80f8h
             .word   809fh
             .word   805ah
             .word   8029h
             .word   800bh
             .word   8002h
             .word   800bh
             .word   8029h
             .word   805ah
             .word   809fh
             .word   80f8h
             .word   8164h
             .word   81e4h
             .word   8277h
             .word   831eh
             .word   83d7h
             .word   84a4h
             .word   8584h
             .word   8677h
             .word   877dh
             .word   8895h
             .word   89c0h
             .word   8afdh
             .word   8c4bh
             .word   8dach
             .word   8f1fh
             .word   90a2h
             .word   9237h
             .word   93ddh
             .word   9594h
             .word   975bh
             .word   9932h
             .word   9b19h
             .word   9d0fh
             .word   9f15h
             .word   0a12ah
             .word   0a34dh
             .word   0a57fh
             .word   0a7beh
             .word   0aa0ch
             .word   0ac66h
             .word   0aecdh
             .word   0b141h
             .word   0b3c1h
             .word   0b64dh
             .word   0b8e4h
             .word   0bb86h
             .word   0be33h
             .word   0c0eah
             .word   0c3aah
             .word   0c674h
             .word   0c947h
             .word   0cc22h
             .word   0cf05h
             .word   0d1f0h
             .word   0d4e2h
             .word   0d7dah
             .word   0dad9h
             .word   0ddddh
             .word   0e0e7h
             .word   0e3f5h
             .word   0e708h
             .word   0ea1fh
             .word   0ed39h
             .word   0f055h
             .word   0f375h
             .word   0f696h
             .word   0f9b9h
             .word   0fcdch

             .data
cos_table    .word   7fffh
             .word   7ff5h
             .word   7fd7h
             .word   7fa6h
             .word   7f61h
             .word   7f08h
             .word   7e9ch
             .word   7e1ch
             .word   7d89h
             .word   7ce2h
             .word   7c29h
             .word   7b5ch
             .word   7a7ch
             .word   7989h
             .word   7883h
             .word   776bh
             .word   7640h
             .word   7503h
             .word   73b5h
             .word   7254h
             .word   70e1h
             .word   6f5eh
             .word   6dc9h
             .word   6c23h
             .word   6a6ch
             .word   68a5h
             .word   66ceh
             .word   64e7h
             .word   62f1h
             .word   60ebh
             .word   5ed6h
             .word   5cb3h
             .word   5a81h
             .word   5842h
             .word   55f4h
             .word   539ah
             .word   5133h
             .word   4ebfh
             .word   4c3fh
             .word   49b3h
             .word   471ch
             .word   447ah
             .word   41cdh
             .word   3f16h
             .word   3c56h
             .word   398ch
             .word   36b9h
             .word   33deh
             .word   30fbh
             .word   2e10h
             .word   2b1eh
             .word   2826h
             .word   2527h
             .word   2223h
             .word   1f19h
             .word   1c0bh
             .word   18f8h
             .word   15e1h
             .word   12c7h
             .word   0fabh
             .word   0c8bh
             .word   96ah
             .word   647h
             .word   324h
             .word   0h
             .word   0fcdch
             .word   0f9b9h
             .word   0f696h
             .word   0f375h
             .word   0f055h
             .word   0ed39h
             .word   0ea1fh
             .word   0e708h
             .word   0e3f5h
             .word   0e0e7h
             .word   0ddddh
             .word   0dad9h
             .word   0d7dah
             .word   0d4e2h
             .word   0d1f0h
             .word   0cf05h
             .word   0cc22h
             .word   0c947h
             .word   0c674h
             .word   0c3aah
             .word   0c0eah
             .word   0be33h
             .word   0bb86h
             .word   0b8e4h
             .word   0b64dh
             .word   0b3c1h
             .word   0b141h
             .word   0aecdh
             .word   0ac66h
             .word   0aa0ch
             .word   0a7beh
             .word   0a57fh
             .word   0a34dh
             .word   0a12ah
             .word   09f15h
             .word   09d0fh
             .word   9b19h
             .word   9932h
             .word   975bh
             .word   9594h
             .word   93ddh
             .word   9237h
             .word   90a2h
             .word   8f1fh
             .word   8dach
             .word   8c4bh
             .word   8afdh
             .word   89c0h
             .word   8895h
             .word   877dh
             .word   8677h
             .word   8584h
             .word   84a4h
             .word   83d7h
             .word   831eh
             .word   8277h
             .word   81e4h
             .word   8164h
             .word   80f8h
             .word   809fh
             .word   805ah
             .word   8029h
             .word   800bh
             .word   8002h
             .word   800bh
             .word   8029h
             .word   805ah
             .word   809fh
             .word   80f8h
             .word   8164h
             .word   81e4h
             .word   8277h
             .word   831eh
             .word   83d7h
             .word   84a4h
             .word   8584h
             .word   8677h
             .word   877dh
             .word   8895h
             .word   89c0h
             .word   8afdh
             .word   8c4bh
             .word   8dach
             .word   8f1fh
             .word   90a2h
             .word   9237h
             .word   93ddh
             .word   9594h
             .word   975bh
             .word   9932h
             .word   9b19h
             .word   9d0fh
             .word   9f15h
             .word   0a12ah
             .word   0a34dh
             .word   0a57fh
             .word   0a7beh
             .word   0aa0ch
             .word   0ac66h
             .word   0aecdh
             .word   0b141h
             .word   0b3c1h
             .word   0b64dh
             .word   0b8e4h
             .word   0bb86h
             .word   0be33h
             .word   0c0eah
             .word   0c3aah
             .word   0c674h
             .word   0c947h
             .word   0cc22h
             .word   0cf05h
             .word   0d1f0h
             .word   0d4e2h
             .word   0d7dah
             .word   0dad9h
             .word   0ddddh
             .word   0e0e7h
             .word   0e3f5h
             .word   0e708h
             .word   0ea1fh
             .word   0ed39h
             .word   0f055h
             .word   0f375h
             .word   0f696h
             .word   0f9b9h
             .word   0fcdch
             .word   0h
             .word   324h
             .word   647h
             .word   96ah
             .word   0c8bh
             .word   0fabh
             .word   12c7h
             .word   15e1h
             .word   18f8h
             .word   1c0bh
             .word   1f19h
             .word   2223h
             .word   2527h
             .word   2826h
             .word   2b1eh
             .word   2e10h
             .word   30fbh
             .word   33deh
             .word   36b9h
             .word   398ch
             .word   3c56h
             .word   3f16h
             .word   41cdh
             .word   447ah
             .word   471ch
             .word   49b3h
             .word   4c3fh
             .word   4ebfh
             .word   5133h
             .word   539ah
             .word   55f4h
             .word   5842h
             .word   5a81h
             .word   5cb3h
             .word   5ed6h
             .word   60ebh
             .word   62f1h
             .word   64e7h
             .word   66ceh
             .word   68a5h
             .word   6a6ch
             .word   6c23h
             .word   6dc9h
             .word   6f5eh
             .word   70e1h
             .word   7254h
             .word   73b5h
             .word   7503h
             .word   7640h
             .word   776bh
             .word   7883h
             .word   7989h
             .word   7a7ch
             .word   7b5ch
             .word   7c29h
             .word   7ce2h
             .word   7d89h
             .word   7e1ch
             .word   7e9ch
             .word   7f08h
             .word   7f61h
             .word   7fa6h
             .word   7fd7h
             .word   7ff5h
 
  	     .bss temp_flag,1
 	     .bss test_val,1
 	     .bss temp_ar5,1
             .bss temp_ar3,1                                
             .bss input_cnt,1                           ;input counter   
             .bss output_cnt,1                           ;output counter   
             .bss d_grps_cnt,1                          ;group counter
             .bss d_twid_idx,1                          ;index of twiddle table
             .bss d_data_idx,1                          ;index of input data

         .bss stack_buffer,100h
     
      .mmregs
      .global _c_int00

      .asg AR1,FFT_TWID_P
      .asg AR2,REORDERED_DATA                  ;pointer to processed data in bit_reversed order
      .asg AR3,ORIGINAL_INPUT                  ;pointer to original input data in natural order
      .asg ar4,d_input_backup
      .asg ar5,OUTPUT_BUF
      .asg AR7,DATA_PROC_BUF                   ;starting addressing of data processing buffer



      .text

_c_int00: 

      stm #initst0,st0					;initialize st0
      stm #initst1,st1					;initialize st1
      stm #stack_buffer+100h,sp
      ld #temp_flag,dp 
   
      ld #0,a
      st #0,input_cnt
      st #d_input_addr,temp_ar3	  	; store 1 st original input

wait_input:
    ;rsbx intm                       ;enable all int
	nop
	call get_input                  ; set toggle point in CCS !
                                    ; read FFT source data to 0x2300 (256 words)!
	nop                             ; set breakpoint in CCS !
    
process:                 
      ssbx intm	
      CALL bit_rev
      CALL fft
      CALL unpack
      CALLD power
      STM #K_ST1,ST1 
      stm #d_output_addr,OUTPUT_BUF

      b _c_int00         ; return to begin
      nop
      nop
      nop

get_input:
	nop                   ;a->AD data input to 0x2300:256
	ret
 
bit_rev:

      pshm st0
      pshm ar0
      pshm bk

      SSBX FRCT                                ;fractional mode is on;                       
      SSBX INTM
      STM #d_input_addr,ORIGINAL_INPUT         ;AR3->1 st original input
      STM #fft_data,DATA_PROC_BUF              ;AR7-> data processing buffer
      MVMM DATA_PROC_BUF,REORDERED_DATA        ;AR2->1st bit_reversed data
      STM #K_FFT_SIZE-1,BRC
      STM #K_FFT_SIZE,AR0                      ;AR0 = 1/2 size of circ buffer
      RPTB bit_rev_end-4
      MVDD *ORIGINAL_INPUT+,*REORDERED_DATA+
      MVDD *ORIGINAL_INPUT-,*REORDERED_DATA+
      MAR *ORIGINAL_INPUT+0B
      

      popm bk
      popm ar0
      popm st0
bit_rev_end:

       RET


fft:

;--------- stage1 ------------------------
      .asg AR1,GROUP_COUNTER
      .asg AR2,PX
      .asg AR3,QX
      .asg AR4,WR
      .asg AR5,WI
      .asg AR6,BUTTERFLY_COUNTER
      .asg AR7,DATA_PROC_BUF                    ; for Stages 1 & 2
      .asg AR7,STAGE_COUNTER                    ; for the remaining stages

      pshm st0
      pshm ar0
      pshm bk

      SSBX SXM

      STM #K_ZERO_BK,BK                         ;BK=0 so that *ARn+0% == *ARn+0
      LD #-1,ASM                                ;outputs div by 2 at each stage
      MVMM DATA_PROC_BUF,PX                     ;PX->PR
      LD *PX,16,A                                  ;A := PR
      STM #fft_data+K_DATA_IDX_1,QX             ;QX->QR
      STM #K_FFT_SIZE/2-1,BRC
      RPTBD stage1end-1
      STM #K_DATA_IDX_1+1,AR0			; two byte instruction
      SUB *QX,16,A,B                            ; B := PR-QR
      ADD *QX,16,A                              ; A := PR+QR
      STH A,ASM,*PX+                            ; PR':= (PR+QR)/2
      ST B,*QX+                                 ; QR':= (PR-QR)/2
      ||LD *PX,A                                ; A := PI
      SUB *QX,16,A,B                            ; B := PI-QI
      ADD *QX,16,A                              ; A := PI+QI
      STH A,ASM,*PX+0%                           ; PI':= (PI+QI)/2
      ST B,*QX+0%                               ; QI':= (PI-QI)/2
      ||LD *PX,A                                ; A := next PR

stage1end:


; Stage 2 
      MVMM DATA_PROC_BUF,PX                     ; PX ? PR
      STM #fft_data+K_DATA_IDX_2,QX             ; QX ? QR
      STM #K_FFT_SIZE/4-1,BRC
      LD *PX,16,A                                  ; A := PR
      RPTBD stage2end-1
      STM #K_DATA_IDX_2+1,AR0
; 1st butterfly
      SUB *QX,16,A,B                            ; B := PR-QR
      ADD *QX,16,A                              ; A := PR+QR
      STH A,ASM,*PX+                            ; PR':= (PR+QR)/2
      ST B,*QX+                                 ; QR':= (PR-QR)/2
      ||LD *PX,A                                ; A := PI
      SUB *QX,16,A,B                            ; B := PI-QI
      ADD *QX,16,A                              ; A := PI+QI
      STH A,ASM,*PX+                            ; PI':= (PI+QI)/2
      STH B,ASM,*QX+                            ; QI':= (PI-QI)/2
; 2nd butterfly
      MAR *QX+
      ADD *PX,*QX,A                             ; A := PR+QI
      SUB *PX,*QX-,B                            ; B := PR-QI
      STH A,ASM,*PX+                            ; PR':= (PR+QI)/2
      SUB *PX,*QX,A                             ; A := PI-QR
      ST B,*QX                                  ; QR':= (PR-QI)/2
      ||LD *QX+,B                               ; B := QR
      ST A, *PX                                 ; PI':= (PI-QR)/2
      ||ADD *PX+0%,A                            ; A := PI+QR
      ST A,*QX+0%                               ; QI':= (PI+QR)/2
      ||LD *PX,A                                ; A := PR
stage2end:


; Stage 3 thru Stage logN-1
      STM #K_TWID_TBL_SIZE,BK                   ; BK = twiddle table size always
      ST #K_TWID_IDX_3,d_twid_idx               ; init index of twiddle table
      STM #K_TWID_IDX_3,AR0                     ; AR0 = index of twiddle table
      STM #cos_table,WR                      ; init WR pointer
      STM #sine_table,WI                        ; init WI pointer
      STM #K_LOGN-2-1,STAGE_COUNTER             ; init stage counter
      ST #K_FFT_SIZE/8-1,d_grps_cnt             ; init group counter
      STM #K_FLY_COUNT_3-1,BUTTERFLY_COUNTER    ; init butterfly counter
      ST #K_DATA_IDX_3,d_data_idx               ; init index for input data
stage:
      STM #fft_data,PX 				; PX->PR
      LD d_data_idx, A
      ADD *(PX),A
      STLM A,QX                                 ; QX ? QR
      MVDK d_grps_cnt,GROUP_COUNTER             ; AR1 contains group countergroup:
group:
      MVMD BUTTERFLY_COUNTER,BRC                ; # of butterflies in each grpTER,BRC
      RPTBD butterflyend-1
      LD *WR,T
      MPY *QX+,A                                ; A := QR*WR || QX?QI
      MAC *WI+0%,*QX-,A                         ; A := QR*WR+QI*WI
      ADD *PX,16,A,B                            ; B := (QR*WR+QI*WI)+PR                                                
						; || QX?QR

      ST B,*PX                                  ; PR':=((QR*WR+QI*WI)+PR)/2
      ||SUB *PX+,B                              ; B := PR-(QR*WR+QI*WI)
      ST B,*QX                                  ; QR':= (PR-(QR*WR+QI*WI))/2
      ||MPY *QX+,A                              ; A := QR*WI [T=WI]
                                                ; || QX?QI
      MAS *QX,*WR+0%,A                         ; A := QR*WI-QI*WR
      ADD *PX,16,A,B                            ; B := (QR*WI-QI*WR)+PI

      ST B,*QX+                                 ; QI':=((QR*WI-QI*WR)+PI)/2
                                                ; || QX?QR
      ||SUB *PX,B                               ; B := PI-(QR*WI-QI*WR)
      LD *WR,T                                  ; T := WR
      ST B,*PX+                                 ; PI':= (PI-(QR*WI-QI*WR))/2
                                                ; || PX?PR
      ||MPY *QX+,A                              ; A := QR*WR || QX?QI
butterflyend:

; Update pointers for next group
        PSHM AR0                                ; preserve AR0
        MVDK d_data_idx,AR0
        MAR *PX+0                               ; increment PX for next group
        MAR *QX+0                               ; increment QX for next group
        BANZD group,*GROUP_COUNTER-  
        POPM AR0                                ; restore AR0
        MAR *QX-
;	trap 2
; Update counters and indices for next stage
        LD d_data_idx,A
        SUB #1,A,B                              ; B = A-1
        STLM B,BUTTERFLY_COUNTER                ; BUTTERFLY_COUNTER = #flies-1
        STL A,1,d_data_idx                      ; double the index of data
        LD d_grps_cnt,A
        STL A,-1,d_grps_cnt                    ; 1/2 the offset to next group
        LD d_twid_idx,A
        STL A,-1,d_twid_idx                    ; 1/2 the index of twiddle table
        BANZD stage,*STAGE_COUNTER-
        MVDK d_twid_idx,AR0                     ; AR0 = index of twiddle table

        popm bk       
        popm ar0
        popm st0
fft_end:
        RET 





unpack
        .asg AR2,XP_k
        .asg AR3,XP_Nminusk
        .asg AR6,XM_k
        .asg AR7,XM_Nminusk 
         
        pshm st0
        pshm ar0
        pshm bk

    	SSBX INTM
     	SSBX FRCT
      	SSBX SXM
	LD #-1,ASM

        STM #fft_data+2,XP_k                    ; AR2 -> R[k] (temp RP[k])
        STM #fft_data+2*K_FFT_SIZE-2,XP_Nminusk ; AR3 -> R[N-K] (temp RP[N-K])
        STM #fft_data+2*K_FFT_SIZE+3,XM_Nminusk ; AR7 -> temp RM[N-K]
        STM #fft_data+4*K_FFT_SIZE-1,XM_k       ; AR6 -> temp RM[K]
        STM #-2+K_FFT_SIZE/2,BRC

        RPTBD phase3end-1
        STM #3,AR0
        ADD *XP_k,*XP_Nminusk,A                 ; A := R[k]+R[N-K] = 2*RP[k]
        SUB *XP_k,*XP_Nminusk,B                 ; B := R[k]-R[N-K]= 2*RM[k]
        STH A,ASM,*XP_k+                        ; store RP[k] at AR[k]
        STH A,ASM,*XP_Nminusk+                  ; store RP[N-K]=RP[k] at AR[N-K]
        STH B,ASM,*XM_k-                        ; store RM[k] at AI[2N-K]
        NEG B                                   ; B := R[N-K]-R[k] =2*RM[N-K]
        STH B,ASM,*XM_Nminusk-                  ; store RM[N-K] at AI[N+k]
        ADD *XP_k,*XP_Nminusk,A                 ; A := I[k]+I[N-K] = 2*IP[k]
        SUB *XP_k,*XP_Nminusk,B                 ; B := I[k]-I[N-K] =2*IM[k]
        STH A,ASM,*XP_k+                        ; store IP[k] at AI[k]
        STH A,ASM,*XP_Nminusk-0                 ; store IP[N-K]=IP[k] at AI[N-K]
        STH B,ASM,*XM_k-                        ; store IM[k] at AR[2N-K]
        NEG B                                   ; B := I[N-K]-I[k] =2*IM[N-K]
        STH B,ASM,*XM_Nminusk+0                 ; store IM[N-K] at AR[N+k]
phase3end:


        ST #0,*XM_k-                            ; RM[N/2]=0
        ST #0,*XM_k                             ; IM[N/2]=0

; Compute AR[0],AI[0], AR[N], AI[N]
       .asg AR2,AX_k
       .asg AR4,IP_0
       .asg AR5,AX_N
       STM #fft_data,AX_k                       ; AR2 -> AR[0] (temp RP[0])
       STM #fft_data+1,IP_0                     ; AR4 -> AI[0] (temp IP[0])
       STM #fft_data+2*K_FFT_SIZE+1,AX_N        ; AR5 -> AI[N]
       ADD *AX_k,*IP_0,A                        ; A := RP[0]+IP[0]
       SUB *AX_k,*IP_0,B                        ; B := RP[0]-IP[0]
       STH A,ASM,*AX_k+                         ; AR[0] = (RP[0]+IP[0])/2
       ST #0,*AX_k                              ; AI[0] = 0
       MVDD *AX_k+,*AX_N-                       ; AI[N] = 0
       STH B,ASM,*AX_N                          ; AR[N] = (RP[0]-IP[0])/2

; Compute final output values AR[k], AI[k]
        .asg AR3,AX_2Nminusk
        .asg AR4,COS
        .asg AR5,SIN
        STM #fft_data+4*K_FFT_SIZE-1,AX_2Nminusk 	; AR3 -> AI[2N-1](temp RM[1])
        STM #cos_table+K_TWID_TBL_SIZE/K_FFT_SIZE,COS 	; AR4 -> cos(k*pi/N)
        STM #sine_table+K_TWID_TBL_SIZE/K_FFT_SIZE,SIN	; AR5 ->  sin(k*pi/N)
        STM #K_FFT_SIZE-2,BRC
        RPTBD phase4end-4
        STM #K_TWID_TBL_SIZE/K_FFT_SIZE,AR0      ; index of twiddle tables
        LD *AX_k+,16,A                           ; A := RP[k] || AR2->IP[k]
        MACR *COS,*AX_k,A                        ; A :=A+cos(k*pi/N)*IP[k]
        MASR *SIN,*AX_2Nminusk-,A                ; A := A-sin(k*pi/N)*RM[k] || AR3->IM[k]
        LD *AX_2Nminusk+,16,B                    ; B := IM[k] ||AR3->RM[k]
        MASR *SIN+0%,*AX_k-,B                    ; B := B-sin(k*pi/N)*IP[k] || AR2->RP[k]
        MASR *COS+0%,*AX_2Nminusk,B              ; B := B-cos(k*pi/N)*RM[k]
        STH A,ASM,*AX_k+                         ; AR[k] = A/2
        STH B,ASM,*AX_k+                         ; AI[k] = B/2
        NEG B                                    ; B := -B
        STH B,ASM,*AX_2Nminusk-                  ; AI[2N-K] = -AI[k]= B/2
        STH A,ASM,*AX_2Nminusk-                  ; AR[2N-K] = AR
                                                 ; [k] = A/2
        popm bk                                        
        popm ar0
        popm st0
phase4end:

;	intr 2

        RET 

power:
        .asg AR2,AX
        .asg AR3,OUTPUT_BUF

        pshm st0
        pshm ar0
        pshm bk
;	trap 2
	SSBX INTM
	SSBX FRCT
        SSBX SXM


        STM #d_output_addr,OUTPUT_BUF              ; AR3 points to output buffer
        STM #K_FFT_SIZE*2-1,BRC
        RPTBD power_end-4
        STM #fft_data,AX                           ; AR2 points to AR[0]
        SQUR *AX+,A                                ; A := AR^2
        SQURA *AX+,A                               ; A := AR^2 + AI^2
;        trap 2

        STH A,7,*OUTPUT_BUF
        ANDM #7FFFH,*OUTPUT_BUF+

;        intr 2
          
        popm bk
        popm ar0
        popm st0                                               
power_end:
       RET                                      ; return to main program
	
