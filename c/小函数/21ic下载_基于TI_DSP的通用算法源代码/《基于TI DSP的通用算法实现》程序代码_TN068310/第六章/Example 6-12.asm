
; Example 6 - 12. DLMS Implementation ASM Listing for the TMS320C54x DSP

; TEXAS INSTRUMENTS INCORPORATED
; DSP Data Communication System Development / ASP
;;
; Archives: PVCS
; Filename: adapt.asm
; Version: 1.0
; Status : draft ( )
; proposal (X)
; accepted ( ) dd每mm每yy/?acceptor.
;
; AUTHOR Padma P. Mallela
;
; Application Specific Products
; Data Communication System Development
; 12203 SW Freeway, MS 701
; Stafford, TX 77477
;
;{
; IPR statements description (can be collected).
;}
;(C) Copyright 1996. Texas Instruments. All rights reserved.
;
;{
; Change history:
;
; VERSION DATE / AUTHORS COMMENT
; 1.0 July每24每96 / P.Mallela original created
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
; This file contains two subroutines:
; 1) adapt_init
; 2) adapt_task
; 1.3 Specification/Design Reference (optional)
; called by task.asm depending upon the task
;
; 1.4 Module Test Document Reference
; Not done
;
; 1.5 Compilation Information
; Compiler: TMS320C54X ASSEMBLER
; Version: 1.02 (PC)
; Activation: asm500 每s adapt.asm
;
; 1.6 Notes and Special Considerations
; 每
;}
;{
; 2. VOCABULARY
;
; 2.1 Definition of Special Words, Keywords (optional)
; 每
SPRA673
64 TMS320C54x Application Code Examples
Example 16. Adaptive Filtering Using LMS Instruction (Continued)
; 2.2 Local Compiler Flags
; 每
; 2.3 Local Constants
; 每
;}
;{
; 3. EXTERNAL RESOURCES
;
; 3.1 Include Files
	.mmregs
	.include §main.inc§
	
; 3.2 External Data
; .ref ADAPT_DP
	.ref d_mu,d_error,d_primary,d_output,d_mu,d_mu_e,d_new_x
	.ref scoff,hcoff,wcoff
	.ref xh,xw,d_adapt_count
	
	
	
; 3.3 Import Functions
;}
;{
; 4. INTERNAL RESOURCES
;
; 4.1 Local Static Data
; 每
; 4.2 Global Static Data
; 每
; 4.3 Dynamic Data
; 每
; 4.4 Temporary Data
; 每
; 4.5 Export Functions
.def adapt_init,adapt_task
;}
; 5. SUBROUTINE CODE
; HeaderBegin
;==============================================================================
;
; 每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每〞
; 5.1 adapt_init
;
; 5.1.1 Functional Description
;
; This subroutine moves filter coeffcients from program to data space.
; Initializes the adaptive coefficients, buffers,vars,and sets the circular
; buffer address for processing.
;每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每
;
; 5.1.2 Activation
; Activation example:
; CALL adapt_init
; Reentrancy: No
; Recursive : No
;
; 5.1.3 Inputs
; NONE
;
; 5.1.4 Outputs
; NONE
;
; 5.1.5 Global
; Data structure: AR0
; Data Format: 16每bit index pointer
; Modified: No
; Description: uses in circular addressing mode for indexing
;
; Data structure: AR1
; Data Format: 16每bit pointer
; Modified: Yes
; Description: used in initializing buffers and vars
;
; Data structure: AR3
; Data Format: 16每bit x(n) data buffer pointer for H(z)
; Modified: Yes
; Description: initializes the pointer
;
; Data structure: AR5
; Data Format: 16每bit x(n) data buffer pointer for W(z)
; Modified: Yes
; Description: initializes the pointer
;
; 5.1.6 Special considerations for data structure
; 每
; 5.1.7 Entry and Exit conditions
;
; |DP|OVM|SXM|C16|FRCT|ASM|AR0|AR1|AR2|AR3|AR4|AR5|AR6|AR7|A |B |BK|BRC| T|TRN|
; | | | | | | | | | | | | | | | | | | | | |
;in |U | 1 | 1 |NU | 1 |NU |NU |NU |NU |NU |NU |NU |NU |NU |UM|NU|NU|NU |NU|NU |
; | | | | | | | | | | | | | | | | | | | | |
;out|U | 1 | 1 |NU | 1 |NU |UM |UM |NU |UM |NU |UM |NU |NU |UM|UM|NU|NU |NU|NU |
; Note : UM 每 Used & Modified, U 每 Used, NU 每 Not Used
;
; 5.1.8 Execution
; Execution time: ?cycles
; Call rate: not applicable for this application
;
;==============================================================================
;HeaderEnd
; 5.1.9 Code
	.asg AR0,INDEX_P
	.asg AR1,INIT_P 		; initialize buffer pointer
	.asg AR3,XH_DATA_P 		; data coeff buffer pointer
	.asg AR5,XW_DATA_P 		; data coeff buffer pointer
					; for cal.y output
	.sect §filter§

adapt_init:
					; initialize input data location, input to hybrid, with Zero.
	STM #xh,INIT_P
	RPTZ A,#H_FILT_SIZE每1
	STL A,*INIT_P+
					; initialize input data location, input to adaptive filter, with Zero.
	STM #xw,INIT_P
	RPTZ A,#ADPT_FILT_SIZE每1
	STL A,*INIT_P+
					; initialize adaptive coefficient with Zero.
	STM #wcoff,INIT_P
	RPTZ A,#ADPT_FILT_SIZE每1
	STL A,*INIT_P+
					; initialize temporary storage loacations with zero
	STM #d_primary,INIT_P
	RPTZ A,#6
	STL A,*INIT_P+
					; copy system coefficient into RAM location, Rverse order
	STM #hcoff,INIT_P
	RPT #H_FILT_SIZE每1
	MVPD #scoff,*INIT_P+
					; LD #ADAPT_DP,DP ;set DP now and not worry about it
	ST #K_mu,d_mu
	STM #1,INDEX_P 			; increment value to be used by
					; dual address
					; associate auxilary registers for circular computation
	STM #xh+H_FILT_SIZE每1,XH_DATA_P 	; last input of hybrid buffer
	RETD
	STM #xw+ADPT_FILT_SIZE每1,XW_DATA_P 	;last element of input buffer
						; 5. SUBROUTINE CODE
						; HeaderBegin




;==============================================================================
;
;每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每
; 5.2 adapt_task
;
; 5.2.1 Functional Description
;
; This subroutine performs the adaptive filtering.The newest sample is
; stored in a seperate location since filtering and adaptation are performed
; at the same time. Otherwise the oldest sample is over written before
; up dating the w(N每1) coefficient.
;
; d_primary = xh *hcoff
; d_output = xw *wcoff
; LMS algorithm:
; w(i+1) = w(i)+d*mu_error*xw(n每i) for i = 0,1,...127 and n = 0,1,.....
; This program can run in two steps
; 1. Initial stepsize, d_mu = 0x0. At this point, the system is not
; identified since the coefficients are not adapted and the error
; signal e (n) is d (n). This is the default mode
; 2. At the EVM debugger command window change the step size
; d_mu 每 0x000, with the command e * d_mu = 0x1000
; This changes the stepsize. The error signal e(n) in this case
; is approximately 0 (theoretically) and the system is identified.
;每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每每〞;
; 5.2.2 Activation
; Activation example:
; CALL adapt_task
; Reentrancy: No
; Recursive : No
;
; 5.2.3 Inputs
;
; Data structure: AR3
; Data Format: 16每bit x(n) data buffer pointer for H(Z)
; Modified: Yes
; Description: uses circular buffer addressing mode of size 128
;
; Data structure: AR5
; Data Format: 16每bit x(n) data buffer pointer for W(z)
; Modified: Yes
; Description: uses circular buffer addressing mode of size 128
;
; Data structure: AR6
; Data Format: 16每bit input buffer pointer
; Modified: Yes
; Description: either point to PING/PONG buffer
;
; 5.2.4 Outputs
;
; Data structure: AR7
; Data Format: 16每bit output buffer pointer
; Modified: Yes
; Description: either point to PING/PONG buffer
;
; 5.2.5 Global
;
; Data structure: AR2
; Data Format: 16每bit H(z) coeff buffer pointer
; Modified: Yes
; Description: uses circular buffer addressing mode of size 128
;
; Data structure: AR4
; Data Format: 16每bit W(z) coeff buffer pointer
; Modified: Yes
; Description: uses circular buffer addressing mode of size 128
;
; Data structure: d_adapt_count
; Data Format: 16每bit variable
; Modified: Yes
; Description: counter to check for processing 256 samples
;
; Data structure: d_new_x
; Data Format: 16每bit variable
; Modified: Yes
; Description: holds the newest sample
;
; Data structure: d_primary
; Data Format: 16每bit variable
; Modified: Yes
; Description: d_primary = xh * hcoeff
;
; Data structure: d_output
; Data Format: 16每bit variable
; Modified: Yes
; Description: d_output = xw * wcoff
;
; Data structure: d_error
; Data Format: 16每bit variable
; Modified: Yes
; Description: d_error = d_primary每d_output
;
; Data structure: d_mu_e
; Data Format: 16每bit variable
; Modified: Yes
; Description: d_mu_e = mu*d_error
;
; 5.2.6 Special considerations for data structure
; 每
; 5.2.7 Entry and Exit conditions
;       
; | | | | | | | | | | | | | | | | | | | | |
;in |U | 1 | 1 |NU | 1 |NU |U |NU |NU |U |NU | U |U | U |UM|NU|NU|NU |NU|NU |
; | | | | | | | | | | | | | | | | | | | | |
;out|U | 1 | 1 |NU | 1 |NU |U |NU |UM |UM |UM |UM |UM |UM |UM|UM|UM|UM |UM|NU |
; Note : UM 每 Used & Modified, U 每 Used, NU 每 Not Used
;
; 5.2.8 Execution
; Execution time: ?cycles
; Call rate: not applicable for this application
;
;==============================================================================
; HeaderEnd
; 5.2.9 Code
	.asg AR2,H_COFF_P 	; H(Z) coeff buffer pointer
	.asg AR3,XH_DATA_P 	; data coeff buffer pointer
	.asg AR6,INBUF_P 	; input buffer address pointer
	.asg AR7,OUTBUF_P 	; output buffer address pointer
				; for cal. primary input
	.asg AR4,W_COFF_P 	; W(z) coeff buffer pointer
	.asg AR5,XW_DATA_P 	; data coeff buffer pointer
	
	.sect §filter§

adapt_task:
	STM #H_FILT_SIZE,BK 	; first circular buffer size
	STM #hcoff,H_COFF_P 	; H_COFF_P 每每> last of sys coeff
	ADDM #1,d_adapt_count
	LD *INBUF_P+, A 	; load the input sample
	STM #wcoff,W_COFF_P 	; reset coeff buffer
	STL A,d_new_x 		; read in new data
	LD d_new_x,A 		;
	STL A,*XH_DATA_P+0% 	; store in the buffer
	RPTZ A,#H_FILT_SIZE每1 	; Repeat 128 times
	MAC *H_COFF_P+0%,*XH_DATA_P+0%,A 
				; mult & acc:a = a + (h * x)
	STH A,d_primary 	; primary signal
				; start simultaneous filtering and updating the adaptive filter here.
	LD d_mu_e,T 		; T = step_size*error
	SUB B,B 				; zero acc B
	STM #(ADPT_FILT_SIZE每2),BRC 		; set block repeat counter
	RPTBD lms_end每1
	MPY *XW_DATA_P+0%, A 		; error * oldest sample
	LMS *W_COFF_P, *XW_DATA_P 	; B = filtered output (y)
					; Update filter coeff
	ST A, *W_COFF_P+ 		; save updated filter coeff
	|| MPY*XW_DATA_P+0%,A 		; error *x[n每(N每1)]
	LMS *W_COFF_P, *XW_DATA_P 	; B = accum filtered output y
					; Update filter coeff
lms_end

	STH A, *W_COFF_P 		; final coeff
	MPY *XW_DATA_P,A 		; x(0)*h(0)
	MVKD #d_new_x,*XW_DATA_P 	; store the newest sample
	LMS *W_COFF_P,*XW_DATA_P+0%
	STH B, d_output 		; store the fitlered output
	LD d_primary,A
	SUB d_output,A
	STL A, d_error 			; store the residual error signal
	LD d_mu,T
	MPY d_error,A 			; A=u*e
	STH A,d_mu_e 			; save the error *step_size
	LD d_error,A 			; residual error signal
	STL A, *OUTBUF_P+   
	LD #K_FRAME_SIZE,A 		; check if a frame of samples
	SUB d_adapt_count,A 		; have been processed
	BC adapt_task,AGT
	RETD
	ST #K_0,d_adapt_count 		; restore the count
	.end


* This is an input file used by the adaptive filter program.
* The transfer function is the system to be identifued by the adaptive filter
.word 0FFFDh
.word 24h
.word 6h
.word 0FFFDh
.word 3h
.word 3h
.word 0FFE9h
.word 7h
.word 12h
.word 1Ch
.word 0FFF3h
.word 0FFE8h
.word 0Ch
.word 3h
.word 1Eh
.word 1Ah
.word 22h
.word 0FFF5h
.word 0FFE5h
.word 0FFF1h
.word 0FFC5h
.word 0Ch
.word 0FFE8h
.word 37h
.word 0FFE4h
.word 0FFCAh
.word 1Ch
.word 0FFFDh
.word 21h
.word 0FFF7h
.word 2Eh
.word 28h
.word 0FFC6h
.word 53h
.word 0FFB0h
.word 55h
.word 0FF36h
.word 5h
.word 0FFCFh
.word 0FF99h
.word 64h
.word 41h
.word 0FFF1h
.word 0FFDFh
.word 0D1h
.word 6Ch
.word 57h
.word 36h
.word 0A0h
.word 0FEE3h
.word 6h
.word 0FEC5h
.word 0ABh
.word 185h
.word 0FFF6h
.word 93h
.word 1Fh
.word 10Eh
.word 59h
.word 0FEF0h
.word 96h
.word 0FFBFh
.word 0FF47h
.word 0FF76h
.word 0FF0Bh
.word 0FFAFh
.word 14Bh
.word 0FF3Bh
.word 132h
.word 289h
.word 8Dh
.word 0FE1Dh
.word 0FE1Bh
.word 0D4h
.word 0FF69h
.word 14Fh
.word 2AAh
.word 0FD43h
.word 0F98Fh
.word 451h
.word 13Ch
.word 0FEF7h
.word 0FE36h
.word 80h
.word 0FFBBh
.word 0FC8Eh
.word 10Eh
.word 37Dh
.word 6FAh
.word 1h
.word 0FD89h
.word 198h
.word 0FE4Ch
.word 0FE78h
.word 0F215h
.word 479h
.word 749h
.word 289h
.word 0F667h
.word 304h
.word 5F8h
.word 34Fh
.word 47Bh
.word 0FF7Fh
.word 85Bh
.word 0F837h
.word 0F77Eh
.word 0FF80h
.word 0B9Bh
.word 0F03Ah
.word 0EE66h
.word 0FE28h
.word 0FAD0h
.word 8C3h
.word 0F5D6h
.word 14DCh
.word 0F3A7h
.word 0E542h
.word 10F2h
.word 566h
.word 26AAh
.word 15Ah
.word 2853h
.word 0EE95h
.word 93Dh
.word 20Dh
.word 1230h
.word 238Ah
