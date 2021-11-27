
;Example 3 - 15. FFT Implementation of a 2N Real Sequence Based on Data-Packing Method for TMS320C54x	

* Appendix A Main.inc


* Filename: Main.inc
* Includes all the constants that are used in the entire application

	K_0 		.set 0 ; constant
	K_FIR_INDEX 	.set 1 ; index count
	K_FIR_BFFR 	.set 16 ; FIR buffer size
	K_neg1 		.set �C1h ; index count
	K_BIQUAD 	.set 2 ; there are 2 bi-quad sections
	K_IIR_SIZE 	.set 10 ; each bi-quad has 5 coeffs
	K_STACK_SIZE 	.set 200 ; stack size
	K_FRAME_SIZE 	.set 256 ; PING/PONG buffer size
	K_FRAME_FLAG 	.set 1 ; set after 256 collected
	H_FILT_SIZE 	.set 128 ; H(z) filter size
	ADPT_FILT_SIZE 	.set 128 ; W(z) filter size
	K_mu 		.set 0h ; initial step constant
	K_HOST_FLAG 	.set 1 ; Enable EVM_HOST interface
	K_DEFAULT_AC01 	.set 1h ; default AC01 init   
	
* This include file sets the FFT size for the ��54x Real FFT code
* Note that the Real FFT size (i.e. the number of points in the
* original real input sequence) is 2N; whereas the FFT size is
* the number of complex points formed by packing the real inputs,
* which is N. For example, for a 256-pt Real FFT, K_FFT_SIZE
* should be set to 128 and K_LOGN should be set to 7.

	K_FFT_SIZE 	.set 128 ; # of complex points (=N)
	K_LOGN 		.set 7 ; # of stages (=logN/log2)
	K_ZERO_BK 	.set 0
	K_TWID_TBL_SIZE .set 128 ; Twiddle table size
	K_DATA_IDX_1 	.set 2 ; Data index for Stage 1
	K_DATA_IDX_2 	.set 4 ; Data index for Stage 2
	K_DATA_IDX_3 	.set 8 ; Data index for Stage 3
	K_FLY_COUNT_3 	.set 4 ; Butterfly counter for Stage 3
	K_TWID_IDX_3 	.set 32 ; Twiddle index for Stage 3


; Appendix B FFT Example Code

; B.1 256-Point Real FFT Initialization

; TEXAS INSTRUMENTS INCORPORATED
; DSP Data Communication System Development / ASP
;
; Archives: PVCS
; Filename: rfft.asm
; Version: 1.0
; Status : draft ( )
; proposal (X)
; accepted ( ) dd�Cmm�Cyy/?acceptor.
;
; AUTHOR Simon Lau and Nathan Baltz
;
; Application Specific Products
; Data Communication System Development
; 12203 SW Freeway, MS 701
; Stafford, TX 77477
;{
; IPR statements description (can be collected).
;}
;(C) Copyright 1996. Texas Instruments. All rights reserved.
;
;{
; Change history:
;
; VERSION DATE / AUTHORS COMMENT
; 1.0 July�C17�C96 / Simon & Nathan original created
;
;}
;{
; 1. ABSTRACT
;
; 1.1 Function Type
; a.Core Routine
; b.Subroutine
;
; 1.2 Functional Description
; This file contains core routine:
; rfft
;
; 1.3 Specification/Design Reference (optional)
;
; 1.4 Module Test Document Reference
; Not done
;
; 1.5 Compilation Information
; Compiler: TMS320C54X ASSEMBLER
; Version: 1.02 (PC)
; Activation: asm500 �Cs rfft.asm
;
; 1.6 Notes and Special Considerations
; �C
;}
;{
; 2. VOCABULARY
;
; 2.1 Definition of Special Words, Keywords (optional)
; �C
; 2.2 Local Compiler Flags
; �C
; 2.3 Local Constants
; �C
;}
;{
; 3. EXTERNAL RESOURCES
;
; 3.1 Include Files

	.mmregs
	.include ��main.inc��
	.include ��init_54x.inc��
; 3.2 External Data
	.ref bit_rev, fft, unpack
	.ref power
	.ref sine,cosine
	.ref sine_table,cos_table
	
; 3.3 Import Functions
;}
;{
; 4. INTERNAL RESOURCES
;
; 4.1 Local Static Data
; �C
; 4.2 Global Static Data
; �C
; 4.3 Dynamic Data
; �C
; 4.4 Temporary Data
; �C
; 4.5 Export Functions
.def rfft_task
;}
; 5. SUBROUTINE CODE
; HeaderBegin
;==============================================================================
;
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
; 5.1 rfft
;
; 5.2 Functional Description
; The following code implements a Radix�C2, DIT, 2N�Cpoint Real FFT for the
; TMS320C54x. This main program makes four function calls, each
; corresponds to a different phase of the algorithm. For more details about
; how each phase is implemented, see bit_rev.asm, fft.asm, unpack.asm, and
; power.asm assembly files.
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
;
; 5.3 Activation
; Activation example:
; CALL rfft
; Reentrancy: No
; Recursive : No
; 5.4 Inputs
; NONE
; 5.5 Outputs
; NONE
;
; 5.6 Global
;
; Data structure: AR1
SPRA669
TMS320C54x Digital Filters 29
; Data Format: 16�Cbit pointer
; Modified: No
; Description: used for moving the twiddle tables from
; program to data
;
; 5.7 Special considerations for data structure
; �C
; 5.8 Entry and Exit conditions
;
; |DP|OVM|SXM|C16|FRCT|ASM|AR0|AR1|AR2|AR3|AR4|AR5|AR6|AR7|A |B |BK|BRC| T|TRN
; | | | | | | | | | | | | | | | | | | | |
;in |U | 1 | 1 |NU | 1 |NU |NU |NU |NU |NU |NU |NU |NU |NU |NU|NU|NU|NU |NU|NU
; | | | | | | | | | | | | | | | | | | | |
;out|U | 1 | 1 |NU | 1 |U |NU |UM |NU |NU |NU |NU |NU |NU |NU|NU|NU|UM |NU|NU
;
; Note : UM �C Used & Modified, U �C Used, NU �C Not Used
;
; 5.9 Execution
; Execution time: ?cycles
; Call rate: not applicable for this application
;
;==============================================================================
;HeaderEnd
; 5.10 Code
	.asg AR1,FFT_TWID_P
	.sect ��rfft_prg��
rfft_task:
	STM #sine,FFT_TWID_P
	RPT #K_FFT_SIZE�C1 		; move FIR coeffs from program
	MVPD #sine_table,*FFT_TWID_P+ 	; to data
	STM #cosine,FFT_TWID_P
	RPT #K_FFT_SIZE�C1 		; move FIR coeffs from program
	MVPD #cos_table,*FFT_TWID_P+ 	; to data
	CALL bit_rev
	CALL fft
	CALL unpack
	CALLD power
	STM #K_ST1,ST1 			; restore the original contents of
					; ST1 since ASM field has changed
	RET 				; return to main program
	.end



; B.2 Bit Reversal Routine
; TEXAS INSTRUMENTS INCORPORATED
; DSP Data Communication System Development / ASP ;
;
; Archives: PVCS
; Filename: bit_rev.asm
; Version: 1.0
; Status : draft ( )
; proposal (X)
; accepted ( ) dd�Cmm�Cyy/?acceptor.
;
; AUTHOR Simon Lau and Nathan Baltz
;
; Application Specific Products
; Data Communication System Development
; 12203 SW Freeway, MS 701
; Stafford, TX 77477
;{
; IPR statements description (can be collected).
;}
SPRA669
30 TMS320C54x Digital Filters
;(C) Copyright 1996. Texas Instruments. All rights reserved.
;
;{
; Change history:
;
; VERSION DATE / AUTHORS COMMENT
; 1.0 July�C17�C96 / Simon & Nathan original created
;
;}
;{
; 1. ABSTRACT
;
; 1.1 Function Type
; a.Core Routine
; b.Subroutine
;
; 1.2 Functional Description
; This file contains one subroutine:
; bit_rev
;
; 1.3 Specification/Design Reference (optional)
; called by rfft.asm depending upon the task thru CALA
;
; 1.4 Module Test Document Reference
; Not done
;
; 1.5 Compilation Information
; Compiler: TMS320C54X ASSEMBLER
; Version: 1.02 (PC)
; Activation: asm500 �Cs bit_rev.asm
;
; 1.6 Notes and Special Considerations
; �C
;}
;{
; 2. VOCABULARY
;
; 2.1 Definition of Special Words, Keywords (optional)
; �C
; 2.2 Local Compiler Flags
; �C
; 2.3 Local Constants
; �C
;}
;{
; 3. EXTERNAL RESOURCES
;
; 3.1 Include Files
.mmregs
.include ��main.inc��
; 3.2 External Data
.ref d_input_addr, fft_data
; 3.3 Import Functions
;}
;{
; 4. INTERNAL RESOURCES
;
; 4.1 Local Static Data
; �C
; 4.2 Global Static Data
; �C
; 4.3 Dynamic Data
; �C
; 4.4 Temporary Data
; �C
; 4.5 Export Functions
.def bit_rev
;}
; 5. SUBROUTINE CODE
; HeaderBegin
;==============================================================================
;
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
; 5.1 bit_rev
;
; 5.2 Functional Description
; This function is called from the main module of the ��C54x Real FFT code.
; It reorders the original 2N�Cpoint real input sequence by using
; bit�Creversed addressing. This new sequence is stored into the data
; processing buffer of size 2N, where FFT will be performed in�Cplace
; during Phase Two.
;
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C��
;
; 5.3 Activation
; Activation example:
; CALL bit_rev
; Reentrancy: No
; Recursive : No
;
; 5.4 Inputs
; NONE
; 5.5 Outputs
; NONE
;
; 5.6 Global
;
; Data structure: AR0
; Data Format: 16�Cbit index pointer
; Modified: No
; Description: used for bit reversed addressing
;
; Data structure: AR2
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to processed data in bit�Creversed order
;
; Data structure: AR3
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to original input data in natural order
;
; Data structure: AR7
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: starting addressing of data processing buffer
;
; 5.7 Special considerations for data structure
; �C
; 5.8 Entry and Exit conditions
;
; |DP|OVM|SXM|C16|FRCT|ASM|AR0|AR1|AR2|AR3|AR4|AR5|AR6|AR7|A |B |BK|BRC| T|TRN|
; | | | | | | | | | | | | | | | | | | | | |
;in |U | 1 | 1 |NU | 1 |NU |NU |NU |NU |NU |NU |NU |NU |NU |NU|NU|NU|NU |NU|NU |
; | | | | | | | | | | | | | | | | | | | | |
;out|U | 1 | 1 |NU | 1 |NU |UM |NU |UM |UM |NU |NU |NU |UM |NU|NU|NU|UM |NU|NU |
;
; Note : UM �C Used & Modified, U �C Used, NU �C Not Used
;
; 5.9 Execution
; Execution time: ?cycles
; Call rate: not applicable for this application
;
;==============================================================================
;HeaderEnd
; 5.10 Code
	.asg AR2,REORDERED_DATA
	.asg AR3,ORIGINAL_INPUT
	.asg AR7,DATA_PROC_BUF
	.sect ��rfft_prg��
bit_rev:
	SSBX FRCT 				; fractional mode is on
	MVDK d_input_addr,ORIGINAL_INPUT 	; AR3 �C> 1 st original input
	STM #fft_data,DATA_PROC_BUF 		; AR7 �C> data processing buffer
	MVMM DATA_PROC_BUF,REORDERED_DATA 	; AR2 �C> 1st bit�Creversed data
	STM #K_FFT_SIZE�C1,BRC
	RPTBD bit_rev_end�C1
	STM #K_FFT_SIZE,AR0 			; AR0 = 1/2 size of circ buffer
	MVDD *ORIGINAL_INPUT+,*REORDERED_DATA+
	MVDD *ORIGINAL_INPUT�C,*REORDERED_DATA+
	MAR *ORIGINAL_INPUT+0B
bit_rev_end:

	RET 					; return to Real FFT main module
	.end


; B.3 256-Point Real FFT Routine

; TEXAS INSTRUMENTS INCORPORATED
; DSP Data Communication System Development / ASP
;
; Archives: PVCS
; Filename: fft.asm
; Version: 1.0
; Status : draft ( )
; proposal (X)
; accepted ( ) dd�Cmm�Cyy/?acceptor.
;
; AUTHOR Simon Lau and Nathan Baltz
;
; Application Specific Products
; Data Communication System Development
; 12203 SW Freeway, MS 701
; Stafford, TX 77477
;{
; IPR statements description (can be collected).
;}
;(C) Copyright 1996. Texas Instruments. All rights reserved.
;
;{
; Change history:
;
; VERSION DATE / AUTHORS COMMENT
; 1.0 July�C17�C96 / Simon & Nathan original created
SPRA669
TMS320C54x Digital Filters 33
;
;}
;{
; 1. ABSTRACT
;
; 1.1 Function Type
; a.Core Routine
; b.Subroutine
;
; 1.2 Functional Description
; This file contains one subroutine:
; fft
;
; 1.3 Specification/Design Reference (optional)
; called by rfft.asm depending upon the task thru CALA
;
; 1.4 Module Test Document Reference
; Not done
;
; 1.5 Compilation Information
; Compiler: TMS320C54X ASSEMBLER
; Version: 1.02 (PC)
; Activation: asm500 �Cs fft.asm
;
; 1.6 Notes and Special Considerations
; �C
;}
;{
; 2. VOCABULARY
;
; 2.1 Definition of Special Words, Keywords (optional)
; �C
; 2.2 Local Compiler Flags
; �C
; 2.3 Local Constants
; �C
;}
;{
; 3. EXTERNAL RESOURCES
;
; 3.1 Include Files
.mmregs
.include ��main.inc��
; 3.2 External Data
.ref fft_data, d_grps_cnt, d_twid_idx, d_data_idx, sine, cosine
; 3.3 Import Functions
;}
;{
; 4. INTERNAL RESOURCES
;
; 4.1 Local Static Data
; �C
; 4.2 Global Static Data
; �C
; 4.3 Dynamic Data
; �C
; 4.4 Temporary Data
; �C
; 4.5 Export Functions
.def fft
;}
; 5. SUBROUTINE CODE
; HeaderBegin
SPRA669
34 TMS320C54x Digital Filters
;==============================================================================
;
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
; 5.1 fft
;
; 5.2 Functional Description
; PHASE TWO (LogN)�CStage Complex FFT
; This function is called from main module of the ��C54x Real FFT code.
; Here we assume that the original 2N�Cpoint real input sequence is al
; ready packed into an N�Cpoint complex sequence and stored into the
; data processing buffer in bit�Creversed order (as done in Phase One).
; Now we perform an in�Cplace, N�Cpoint complex FFT on the data proces
; sing buffer, dividing the outputs by 2 at the end of each stage to
; prevent overflow. The resulting N�Cpoint complex sequence will be un�C
; packed into a 2N�Cpoint complex sequencein Phase Three & Four.
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
;;
; 5.3 Activation
; Activation example:
; CALL fft
; Reentrancy: No
; Recursive : No
;
; 5.4 Inputs
; NONE
; 5.5 Outputs
; NONE
;
; 5.6 Global
;
; Data structure: AR0
; Data Format: 16�Cbit index pointer
; Modified: No
; Description: index to twiddle tables
;
; Data structure: AR1
; Data Format: 16�Cbit counter
; Modified: No
; Description: group counter
;
; Data structure: AR2
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to 1st butterfly data PR,PI
;
; Data structure: AR3
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to 2nd butterfly data QR,QI
;
; Data structure: AR4
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to cosine value WR
;
; Data structure: AR5
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to cosine value WI
;
; Data structure: AR6
; Data Format: 16�Cbit counter  
; Modified: Yes
; Description: butterfly counter
;
; Data structure: AR7
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: start address of data processing buffer
;;
; 5.7 Special considerations for data structure
; �C
; 5.8 Entry and Exit conditions
;
; |DP|OVM|SXM|C16|FRCT|ASM|AR0|AR1|AR2|AR3|AR4|AR5|AR6|AR7|A |B |BK|BRC| T|TRN|
; | | | | | | | | | | | | | | | | | | | | |
;in |U | 1 | 1 |NU | 1 | 0 |NU |NU |NU |NU |NU |NU |NU |NU |NU|NU|NU|NU |NU|NU |
; | | | | | | | | | | | | | | | | | | | | |
;out|U | 1 | 1 |NU | 1 |�C1 |UM |UM |UM |UM |UM |UM |UM |UM |UM|UM|UM|UM |NU|NU |
;
; Note : UM �C Used & Modified, U �C Used, NU �C Not Used
;
; 5.9 Execution
; Execution time: ?cycles
; Call rate: not applicable for this application
;
;==============================================================================
; HeaderEnd
; 5.10 Code
	.asg AR1,GROUP_COUNTER
	.asg AR2,PX
	.asg AR3,QX
	.asg AR4,WR
	.asg AR5,WI
	.asg AR6,BUTTERFLY_COUNTER
	.asg AR7,DATA_PROC_BUF 			; for Stages 1 & 2
	.asg AR7,STAGE_COUNTER 			; for the remaining stages

	.sect ��rfft_prg��
fft:
; Stage 1 �C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	STM #K_ZERO_BK,BK 		; BK=0 so that *ARn+0% == *ARn+0
	LD #�C1,ASM 			; outputs div by 2 at each stage
	MVMM DATA_PROC_BUF,PX 		; PX �C> PR
	LD *PX,A 			; A := PR
	STM #fft_data+K_DATA_IDX_1,QX 	; QX �C> QR
	STM #K_FFT_SIZE/2�C1,BRC
	RPTBD stage1end�C1
	STM #K_DATA_IDX_1+1,AR0
	SUB *QX,16,A,B 			; B := PR�CQR
	ADD *QX,16,A 			; A := PR+QR
	STH A,ASM,*PX+ 			; PR��:= (PR+QR)/2
	ST B,*QX+ 			; QR��:= (PR�CQR)/2
	||LD *PX,A 			; A := PI
	SUB *QX,16,A,B 			; B := PI�CQI
	ADD *QX,16,A 			; A := PI+QI
	STH A,ASM,*PX+0 		; PI��:= (PI+QI)/2
	ST B,*QX+0% 			; QI��:= (PI�CQI)/2
      	||LD *PX,A 			; A := next PR
stage1end:

; Stage 2 �C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C

	MVMM DATA_PROC_BUF,PX 		; PX �C> PR
	STM #fft_data+K_DATA_IDX_2,QX 	; QX �C> QR
	STM #K_FFT_SIZE/4�C1,BRC
	LD *PX,A 			; A := PR
	RPTBD stage2end�C1
	STM #K_DATA_IDX_2+1,AR0
; 1st butterfly
	SUB *QX,16,A,B 		; B := PR�CQR
	ADD *QX,16,A 		; A := PR+QR
	STH A,ASM,*PX+ 		; PR��:= (PR+QR)/2
	ST B,*QX+ 		; QR��:= (PR�CQR)/2
	||LD *PX,A 		; A := PI
	SUB *QX,16,A,B 		; B := PI�CQI
	ADD *QX,16,A 		; A := PI+QI
	STH A,ASM,*PX+ 		; PI��:= (PI+QI)/2
	STH B,ASM,*QX+ 		; QI��:= (PI�CQI)/2
; 2nd butterfly
	MAR *QX+
	ADD *PX,*QX,A 		; A := PR+QI
	SUB *PX,*QX�C,B 		; B := PR�CQI
	STH A,ASM,*PX+ 		; PR��:= (PR+QI)/2
	SUB *PX,*QX,A 		; A := PI�CQR
	ST B,*QX 		; QR��:= (PR�CQI)/2
	||LD *QX+,B		; B := QR
	ST A, *PX 		; PI��:= (PI�CQR)/2
	||ADD *PX+0%,A 		; A := PI+QR
	ST A,*QX+0% 		; QI��:= (PI+QR)/2
	||LD *PX,A 		; A := PR
stage2end:

; Stage 3 thru Stage logN�C1 �C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	STM #K_TWID_TBL_SIZE,BK 	; BK = twiddle table size always
	ST #K_TWID_IDX_3,d_twid_idx 	; init index of twiddle table
	STM #K_TWID_IDX_3,AR0 		; AR0 = index of twiddle table
	STM #cosine,WR 			; init WR pointer
	STM #sine,WI 			; init WI pointer
	STM #K_LOGN�C2�C1,STAGE_COUNTER ; init stage counter
	ST #K_FFT_SIZE/8�C1,d_grps_cnt 	; init group counter
	STM #K_FLY_COUNT_3�C1,BUTTERFLY_COUNTER ; init butterfly counter
	ST #K_DATA_IDX_3,d_data_idx 		; init index for input data
stage:
	STM #fft_data,PX 	; PX �C> PR
	LD d_data_idx, A
	ADD *(PX),A
	STLM A,QX 		; QX �C> QR
	MVDK d_grps_cnt,GROUP_COUNTER 		; AR1 contains group counter
group:
	MVMD BUTTERFLY_COUNTER,BRC 		; # of butterflies in each grp
	RPTBD butterflyend�C1
	LD *WR,T 				; T := WR
	MPY *QX+,A 				; A := QR*WR || QX�C>QI
	MACR *WI+0%,*QX�C,A 			; A := QR*WR+QI*WI
						; || QX�C>QR
	ADD *PX,16,A,B 				; B := (QR*WR+QI*WI)+PR
	ST B,*PX 				; PR��:=((QR*WR+QI*WI)+PR)/2
	||SUB *PX+,B				; B := PR�C(QR*WR+QI*WI)
	; || PX�C>PI
	ST B,*QX 				; QR��:= (PR�C(QR*WR+QI*WI))/2
	||MPY *QX+,A 				; A := QR*WI [T=WI]
						; || QX�C>QI
	MASR *QX,*WR+0%,A 			; A := QR*WI�CQI*WR
	ADD *PX,16,A,B 				; B := (QR*WI�CQI*WR)+PI
	ST B,*QX+ 				; QI��:=((QR*WI�CQI*WR)+PI)/2
						; || QX�C>QR
	||SUB *PX,B 				; B := PI�C(QR*WI�CQI*WR)
	LD *WR,T 				; T := WR
	ST B,*PX+ 				; PI��:= (PI�C(QR*WI�CQI*WR))/2
						; || PX�C>PR
	||MPY *QX+,A 				; A := QR*WR || QX�C>QI
butterflyend:
						; Update pointers for next group
	PSHM AR0 				; preserve AR0
	MVDK d_data_idx,AR0
	MAR *PX+0 			; increment PX for next group
	MAR *QX+0 			; increment QX for next group
	BANZD group,*GROUP_COUNTER�C
	POPM AR0 			; restore AR0
	MAR *QX�C
					; Update counters and indices for next stage
	LD d_data_idx,A
	SUB #1,A,B ; B = A�C1
	STLM B,BUTTERFLY_COUNTER 	; BUTTERFLY_COUNTER = #flies�C1
	STL A,1,d_data_idx 		; double the index of data
	LD d_grps_cnt,A
	STL A,ASM,d_grps_cnt 		; 1/2 the offset to next group
	LD d_twid_idx,A
	STL A,ASM,d_twid_idx 		; 1/2 the index of twiddle table
	BANZ D stage,*STAGE_COUNTER�C
	MVDK d_twid_idx,AR0 		; AR0 = index of twiddle table
fft_end:

	RET 				; return to Real FFT main module
	.end


;B.4 Unpack 256-Point Real FFT Output
; TEXAS INSTRUMENTS INCORPORATED
; DSP Data Communication System Development / ASP
; Archives: PVCS
; Filename: unpack.asm
; Version: 1.0
; Status : draft ( )
; proposal (X)
; accepted ( ) dd�Cmm�Cyy/?acceptor.
;
; AUTHOR Simon Lau and Nathan Baltz
;
; Application Specific Products
; Data Communication System Development
; 12203 SW Freeway, MS 701
; Stafford, TX 77477
;{
; IPR statements description (can be collected).
;}
; (C) Copyright 1996. Texas Instruments. All rights reserved.
;{
; Change history:
;
; VERSION DATE / AUTHORS COMMENT
; 1.0 July�C17�C96 / Simon & Nathan original created
;
;}
;{
; 1. ABSTRACT
;
; 1.1 Function Type
; a.Core Routine
; b.Subroutine
;
; 1.2 Functional Description
; This file contains one subroutine:
; unpack
;
; 1.3 Specification/Design Reference (optional)
; called by rfft.asm depending upon the task thru CALA
;
; 1.4 Module Test Document Reference
; Not done
;
; 1.5 Compilation Information
; Compiler: TMS320C54X ASSEMBLER
; Version: 1.02 (PC)
; Activation: asm500 �Cs unpack.asm
;
; 1.6 Notes and Special Considerations
; �C
;}
;{
; 2. VOCABULARY
;
; 2.1 Definition of Special Words, Keywords (optional)
; �C
; 2.2 Local Compiler Flags
; �C
; 2.3 Local Constants
; �C
;}
;{
; 3. EXTERNAL RESOURCES
;
; 3.1 Include Files
.mmregs
.include ��main.inc��
; 3.2 External Data
.ref fft_data,sine, cosine
; 3.3 Import Functions
;}
;{
; 4. INTERNAL RESOURCES
;
; 4.1 Local Static Data
; �C
; 4.2 Global Static Data
; �C
; 4.3 Dynamic Data
; �C
; 4.4 Temporary Data
; �C
; 4.5 Export Functions
.def unpack
;}
; 5. SUBROUTINE CODE
; HeaderBegin
;==============================================================================
;
; 5.1 unpack
;
; 5.2 Functional Description
;
; PHASE THREE & FOUR Unpacking to 2N Outputs
; This function is called from the main module of the ��C54x Real FFT
; code. It first computes four intermediate sequences (RP,RM, IP, IM)
; from the resulting complex sequence at the end of the previous phase.
; Next, it uses the four intermediate sequences to form the FFT of the
; original 2N�Cpoint real input. Again, the outputs are divided by 2 to
; prevent overflow
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C��
;
; 5.3 Activation
; Activation example:
; CALL unpack
;
; Reentrancy: No
; Recursive : No
;
; 5.4 Inputs
; NONE
; 5.5 Outputs
; NONE
;
; 5.6 Global
;
; 5.6.1 Phase Three Global
;
; Data structure: AR0
; Data Format: 16�Cbit index pointer
; Modified: No
; Description: index to twiddle tables
;
; Data structure: AR2
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to R[k], I[k], RP[k], IP[k]
;
; Data structure: AR3
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to R[N�Ck], I[N�Ck], RP[N�Ck], IP[N�Ck]
;
; Data structure: AR6
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to RM[k], IM[k]
;
; Data structure: AR7
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to RM[n�Ck], IM[n�Ck]
;
; 5.6.2 Phase Four Global
;
; Data structure: AR0
; Data Format: 16�Cbit index pointer
; Modified: No
; Description: index to twiddle tables
;
; Data structure: AR2
; Data Format: 16�Cbit counter
; Modified: No
; Description: pointer to RP[k], IP[k], AR[k], AI[k], AR[0]
;
; Data structure: AR3
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to RM[k], IM[k], AR[2N�Ck], AI[2N�Ck]
;
; Data structure: AR4
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to cos(k*pi/N), AI[0]
;
; Data structure: AR5
; Data Format: 16�Cbit pointer
; Modified: Yes
; Description: pointer to sin(k*pi/N), AR[N], AI[N]
;
; 5.7 Special considerations for data structure
; �C
; 5.8 Entry and Exit conditions
;
; 5.8.1 Phase Three Entry and Exit Conditions
;
; |DP|OVM|SXM|C16|FRCT|ASM|AR0|AR1|AR2|AR3|AR4|AR5|AR6|AR7|A |B |BK|BRC| T|TRN
; | | | | | | | | | | | | | | | | | | | |
;in |2 | 1 | 1 | 0 | 1 | 0 |NU |NU |NU |NU |NU |NU |NU |NU |NU|NU|0 |NU |NU|NU
; | | | | | | | | | | | | | | | | | | | |
;out|2 | 1 | 1 | 0 | 1 |�C1 |UM |NU |UM |UM |NU |NU |UM |UM |UM|UM|UM|UM |NU|NU
;
; Note : UM �C Used & Modified, U �C Used, NU �C Not Used
;
; 5.8.2 Phase Four Entry and Exit Conditions
;
; |DP|OVM|SXM|C16|FRCT|ASM|AR0|AR1|AR2|AR3|AR4|AR5|AR6|AR7|A |B |BK|BRC| T|TRN
; | | | | | | | | | | | | | | | | | | | |
;in |U | 1 | 1 | 0 | 1 |�C1 |NU |NU |NU |NU |NU |NU |NU |NU |NU|NU|NU|NU |NU|NU
; | | | | | | | | | | | | | | | | | | | |
;out|U | 1 | 1 | 0 | 1 |�C1 |UM |NU |UM |UM |UM |UM |NU |NU |UM|UM|UM|UM |NU|NU
;
; Note : UM �C Used & Modified, U �C Used, NU �C Not Used
;
; 5.9 Execution
; Execution time: ?cycles
; Call rate: not applicable for this application
;
;==============================================================================
; HeaderEnd
; 5.10 Code

	.sect ��rfft_prg��
unpack:
							; Compute intermediate values RP, RM, IP, IM
	.asg AR2,XP_k
	.asg AR3,XP_Nminusk
	.asg AR6,XM_k
	.asg AR7,XM_Nminusk
	STM #fft_data+2,XP_k 				; AR2 �C> R[k] (temp RP[k])
	STM #fft_data+2*K_FFT_SIZE�C2,XP_Nminusk 	; AR3 �C> R[N�Ck] (temp	RP[N�Ck])
	STM #fft_data+2*K_FFT_SIZE+3,XM_Nminusk 	; AR7 �C> temp RM[N�Ck]
	STM #fft_data+4*K_FFT_SIZE�C1,XM_k 		; AR6 �C> temp RM[k]
	STM #�C2+K_FFT_SIZE/2,BRC
	RPTBD phase3end�C1
	STM #3,AR0
	ADD *XP_k,*XP_Nminusk,A 			; A := R[k]+R[N�Ck] = 2*RP[k]
	SUB *XP_k,*XP_Nminusk,B 			; B := R[k]�CR[N�Ck] =2*RM[k]
	STH A,ASM,*XP_k+ 				; store RP[k] at AR[k]
	STH A,ASM,*XP_Nminusk+ 				; store RP[N�Ck]=RP[k] at AR[N�Ck]
	STH B,ASM,*XM_k�C 				; store RM[k] at AI[2N�Ck]
	NEG B 						; B := R[N�Ck]�CR[k] = 2*RM[N�Ck]
	STH B,ASM,*XM_Nminusk�C				; store RM[N�Ck] at AI[N+k]
	ADD *XP_k,*XP_Nminusk,A 			; A := I[k]+I[N�Ck] = 2*IP[k]
	SUB *XP_k,*XP_Nminusk,B 			; B := I[k]�CI[N�Ck] = 2*IM[k]
	STH A,ASM,*XP_k+ 				; store IP[k] at AI[k]
	STH A,ASM,*XP_Nminusk�C0 			; store IP[N�Ck]=IP[k] at AI[N�Ck]
	STH B,ASM,*XM_k�C 				; store IM[k] at AR[2N�Ck]
	NEG B 						; B := I[N�Ck]�CI[k] = 2*IM[N�Ck]
	STH B,ASM,*XM_Nminusk+0 			; store IM[N�Ck] at AR[N+k]
phase3end:

	ST #0,*XM_k�C 	; RM[N/2]=0
	ST #0,*XM_k 	; IM[N/2]=0
			; Compute AR[0],AI[0], AR[N], AI[N]
	.asg AR2,AX_k
	.asg AR4,IP_0
	.asg AR5,AX_N

	STM #fft_data,AX_k 			; AR2 �C> AR[0] (temp RP[0])
	STM #fft_data+1,IP_0 			; AR4 �C> AI[0] (temp IP[0])
	STM #fft_data+2*K_FFT_SIZE+1,AX_N 	; AR5 �C> AI[N]
	ADD *AX_k,*IP_0,A 			; A := RP[0]+IP[0]
	SUB *AX_k,*IP_0,B			; B := RP[0]�CIP[0]
	STH A,ASM,*AX_k+ 			; AR[0] = (RP[0]+IP[0])/2
	ST #0,*AX_k 			; AI[0] = 0
	MVDD *AX_k+,*AX_N�C 		; AI[N] = 0
	STH B,ASM,*AX_N 		; AR[N] = (RP[0]�CIP[0])/2
					; Compute final output values AR[k], AI[k]
	.asg AR3,AX_2Nminusk
	.asg AR4,COS
	.asg AR5,SIN

	STM #fft_data+4*K_FFT_SIZE�C1,AX_2Nminusk 	; AR3 �C> AI[2N�C1](temp RM[1])
	STM #cosine+K_TWID_TBL_SIZE/K_FFT_SIZE,COS 	; AR4 �C> cos(k*pi/N)
	STM #sine+K_TWID_TBL_SIZE/K_FFT_SIZE,SIN 	; AR5 �C> sin(k*pi/N)
	STM #K_FFT_SIZE�C2,BRC
	RPTBD phase4end�C1
	STM #K_TWID_TBL_SIZE/K_FFT_SIZE,AR0 		; index of twiddle tables
	LD *AX_k+,16,A 					; A := RP[k] || AR2�C>IP[k]                
	MACR *COS,*AX_k,A 				; A :=A+cos(k*pi/N)*IP[k]                     
	MASR *SIN,*AX_2Nminusk�C,A 			; A := A�Csin(k*pi/N)*RM[k]                     
							; || AR3�C>IM[k]           
	LD *AX_2Nminusk+,16,B 				; B := IM[k] ||	AR3�C>RM[k]                
	MASR *SIN+0%,*AX_k�C,B 				; B := B�Csin(k*pi/N)*IP[k]
							; || AR2�C>RP[k]
	MASR *COS+0%,*AX_2Nminusk,B			; B := B�Ccos(k*pi/N)*RM[k]
	STH A,ASM,*AX_k+ 				; AR[k] = A/2
	STH B,ASM,*AX_k+ 				; AI[k] = B/2
	NEG B 						; B := �CB
	STH B,ASM,*AX_2Nminusk�C 			; AI[2N�Ck] = �CAI[k] = B/2
	STH A,ASM,*AX_2Nminusk�C 			; AR[2N�Ck] = AR[k] = A/2
phase4end:

	RET 						; returntoRealFFTmain module
	.end
