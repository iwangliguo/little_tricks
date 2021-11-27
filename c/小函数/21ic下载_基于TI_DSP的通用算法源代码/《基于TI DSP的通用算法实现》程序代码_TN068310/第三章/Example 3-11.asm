
;Example 3 - 11. Float-Point Complex FFT Implementation Based on BFP Method for TMS320C54x

;*********************************************************************
; Function: cfft64
; Version : 1.00
; Description: complex FFT
;
; Copyright Texas instruments Inc, 1998
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
; Revision History:
;
; 0.00 M. Christ. Original code
;
; 0.01 M. Chishtie.12/96.
;�C Improved radix�C2 bfly code form 9 cycles to 8.
;�C Combined bit�Creversal in to COMBO5XX macro to save cycles.
;�C Improved STAGE3 macro to 31 cycles
;
; 1.00Beta R. Piedra, 8/31/98.
;�C C�Ccallable version.
;�C Removed bit�Creversing and made it a separate optional function
; that also support in�Cplace bit�Creversing. In this way the FFT can
; be computed 100% in�Cplace (memory savings)
;�C Modifed STAGE3 macro to correct functional problem
;�C Modified order of xmem, ymem operands in butterfly code
; to reduce number of cycles
;
; 1.00 A. Aboagye 10/15/98
; �C added scale option as a parameter
;
; 1.00BFP A. Chhabra 11/09/99
;�C incorporated Block Floating Point concept
;�C adjustable scaling factor dictated by ��cmprval_2��
;
;*********************************************************************



	N .set 64 ; NUMBER OF POINTS FOR FFT


	.include ��macros.asm��
	.include ��sintab.q15��
	.mmregs
		; Far�Cmode adjustment
		; �C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	.if __far_mode
		offset .set 1 ; far mode uses one extra location for ret addr ll
	.else
		offset .set 0
	.endif

	.asg (0), DATA
	.asg (1), SIN45
	.asg (2), save_ar7 	; stack description
	.asg (3), save_ar6 	; stack description
	.asg (4), save_ar1
	.asg (5), ret_addr
	.asg (6+offset), scale
				; x in A
;*********************************************************************
;Setting the bit growth test value.
;Depending on the bit growth quantity desired for implementation,
;include an appropriate ��cmprval_2�� value.
;*********************************************************************
;cmprval_2: .equ 32768*5/10 ; 0.5 decimal
cmprval_2: .equ 32768*8284/10000 ; 0.8284 decimal
;*********************************************************************

	.ref InvYeTable
	.def _cfft64

	.text
_cfft64
		; Preserve registers
		; �C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	pshm ar1
	pshm ar6
	pshm ar7
		; Preserve local variables
		; �C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	frame �C2
	nop

		; Get Arguments
		; �C�C�C�C�C�C�C�C�C�C�C�C�C
	stl a,*sp(DATA) ; DATA = *SP(DATA)

   .if N>4 ; ??? no need
	st #5a82h,*sp(SIN45)
   .endif

		; Set modes
		; �C�C�C�C�C�C�C�C�C
	stm #0100010101011110b,ST1 	; ASM=�C2 , FRACT=1, sbx=1;CPL=1(compiler)
	stm #0, *ar5 			; initialize the contents of AR5

		; Execute
		; �C�C�C�C�C�C�C

********* Modifications by AC 03/25/99 **********
	mvdk *sp(DATA), ar1 		; Transfer first value of input buffer �C which
					; currently
					; contain the inputs to the first stage butterflies
					; �C into AR1.
					; Further manipulation of input set can be done
					; by addressing AR1
	call max_abs
	exp a 				; determine the scale up shift quantity
	stm #127, brc 			; scale for whole input array
	stm #0800h, ar1 		; Reset pointer to beginning of input array
	rptb end_upscale�C1 		; begin loop
	ld *ar1, a
	norm a 				; Scale up all input values
	sth a, *ar1+ 			; Put rescaled value back into memory;
					; increment counter to shift next value
end_upscale:
	nop
	combo5xx 			; FFT CODE for STAGES 1 and 2
	stm #0800h, ar1 		; Reset pointer to beginning of input array
	call max_abs
	ld #cmprval_2, b 		; load threshold 0.4167 into Acc B	
	max a 				; Acc A will contain the larger of the earlier
					; MaxAbs value and the current threshold value
					; of 0.4167
	sub #cmprval_2,a,b 		; If diff > 0, thenAcc A = maxabs value
					; GOTO scaling_2
					; If diff = 0, then Acc A = threshold value
					; all values in input array are less than this...
					; GOTO performing regular next stage of bfly
   .if cmprval_2 = (32768*8284/10000)
	cc scaling_2, bgt 		; perform scaling if MaxAbs > cmprval_2
   .else

	stm #127, brc 			; scale for whole input array
	stm #0800h, ar1 		; Reset pointer to beginning of input array

	bc loop1, beq 			; execute next 1 instruction if diff>0.
	rptb loop1�C1 			; begin loop
	ld *ar1, a
	sfta a, �C1 			; shift down by factor 2
	stl a, *ar1+ 			; restore new value into ar1
loop1: .endif

stage3 					; MACRO WITH CODE FOR STAGE 3
	stm #0800h, ar1 		; Reset pointer to beginning of input array
	call max_abs
	ld #cmprval_2, b 		; load threshold cmprval_2 into Acc B
	max a 				; Acc A will contain the larger of the earlier
					; MaxAbs value and the current threshold value
					; of cmprval_2
	sub #cmprval_2,a,b 		; If diff > 0, then Acc A = maxabs value
					; GOTO scaling_2
					; If diff = 0, then Acc A = threshold value
					; GOTO performing regular next stage of bfly
    .if cmprval_2 = (32768*8284/10000)
	cc scaling_2, bgt 		; perform scaling if MaxAbs > cmprval_2
   .else

	stm #127, brc 			; scale for whole input array
	stm #0800h, ar1 		; Reset pointer to beginning of input array
	bc loop2, beq 			; execute next 1 instruction if diff>0.
	rptb loop2�C1 			; begin loop
	ld *ar1, a
	sfta a, �C1 			; shift down by factor 2
	stl a, *ar1+ 			; restore new value into ar1
loop2: .endif

	stdmacro 4,4,8,16,sin4,cos4 	; stage,outloopcnter,loopcnter,index
	stm #0800h, ar1 		; Reset pointer to beginning of input array
	call max_abs
	ld #cmprval_2, b 		; load threshold cmprval_2 into Acc B
	max a 				; Acc A will contain the larger of the earlier
					; MaxAbs value and the current threshold value
					; of cmprval_2
	sub #cmprval_2,a,b 		; If diff > 0, then Acc A = maxabs value
					; GOTO scaling_2
					; If diff = 0, then Acc A = threshold value
					; GOTO performing regular next stage of bfly
   .if cmprval_2 = (32768*8284/10000)
	cc scaling_2, bgt ; perform scaling if MaxAbs > cmprval_2
   .else

	stm #127, brc 			; scale for whole input array
	stm #0800h, ar1 		; Reset pointer to beginning of input array
	bc loop3, beq 			; execute next 1 instruction if diff>0.
	rptb loop3�C1 			; begin loop
	ld *ar1, a
	sfta a, �C1 			; shift down by factor 2
	stl a, *ar1+ 			; restore new value into ar1
loop3: .endif

	stdmacro 5,2,16,32,sin5,cos5 	; stage,outloopcnter,loopcnter,index
	stm #0800h, ar1 		; Reset pointer to beginning of input array
	call max_abs
	ld #cmprval_2, b 		; load threshold cmprval_2 into Acc B
	max a 				; Acc A will contain the larger of the earlier
					; MaxAbs value and the current threshold value
					; of cmprval_2
	sub #cmprval_2,a,b 		; If diff > 0, then Acc A = maxabs value
					; GOTO scaling_2
					; If diff = 0, then Acc A = threshold value
					; GOTO performing regular next stage of bfly
   .if cmprval_2 = (32768*8284/10000)
	cc scaling_2, bgt ; perform scaling if MaxAbs > cmprval_2
   .else

	stm #127, brc 			; scale for whole input array
	stm #0800h, ar1 		; Reset pointer to beginning of input array
	bc loop4, beq 			; execute next 1 instruction if diff>0.
	rptb loop4�C1 			; begin loop
	ld *ar1, a
	sfta a, �C1 			; shift down by factor 2
	stl a, *ar1+ 			; restore new value into ar1
loop4: .endif

	laststag 6,sin6,cos6 		; MACRO WITH CODE FOR STAGE 7
	bd end_lab
	nop
	nop


*********************************************************************
;MAX_ABS
;=======
;
;Perform comparison of consecutive values in order to obtain maximum
;absolute value in the array of inputs. Steps to do this:
;
;(i) Place consecutive values in acc A and B respectively
;(ii) Compute their absolute values
;(iii) Find the MAX of these two accumulators values
;(iv) Monitor the Carry bit and determine which acc contains MAX value.
;(v) Store the max value in acc A
;(vi) Take in the next value in the input array and load into acc B.
; Compute its absolute.
;(vii) Go back to step (ii)
;
;*** Steps (iv) and (v) above are performed in combination
; as a result of the C54x ��MAX�� instruction.
**********************************************************************

max_abs:
					; Set breakpoint to verify that AR1 does point to correct address
	ld *ar1+, a
	ld *ar1+, b
	absa 				; setup absolute value for max comparison
	absb
	stm #126, brc 			; 126 values remain to be read of the 128 value
					; input array. The loop executes 127 times.
	rptb find_max�C1
	max a
	ld *ar1+, b 			; enter the next value in the input array into acc B
	abs b 				; setup next value for absolute max comparison
find_max
	ret 				; returns the maximum absolute value in the
; Acc A
************************ END of ��MAX_ABS�� routine ********************



**********************************************************************
;
;SCALING
;=======
;
;This routine performs the following in order:
;
;(i) Now, since reaching this routine implies that bit growth is
; likely at the output of this stage, scale the mantissa values.
; Scaling factor is determined by the reciprocal of the expected
; bit growth.
; Expected bit growth = 2.4
; Reciprocal = 0.4167
; If maximum of input block to a stage is > 0.4167, then scale
; down once by shifting right.
; If maximum of input block is twice > 0.4167, then scale down
; by shifting right twice.
; Else ignore scaling and proceed as normal.
;
;Arriving at this routine implies that Acc A already contains
;the maximum absolute value of the input array.
;
**********************************************************************

scaling_2: 				; Acc A contains the MaxAbs value
	pshm ar1
	pshm ar2
	ssbx SXM
	rsbx FRCT
					;rsbx TC ; this is ID for div�Cby�C1.207 selection
					; in the reciprocal routine
	call reciprocal 		; Acc A contains MaxAbs
					; COMPUTE SCALING FACTOR = (1/(MaxAbs*2.41421356))
					; now, remember that the original DSPLIB FFT code contains
					; automatic scaling down within each radix�C2 stage
					; by a factor of 2, i.e. one bit place.
					; As a result, what we manually need to tweak with for
					; scaling is a value = (2.41421356/2) = 1.207
					; => Scaling factor needed here = (1/(MaxAbs * 1.207))
	ld a, b 			; temporarily store Acc A into B
	add *ar5, a 			; add scaling factor to Acc A
	stl a, *ar5 			; save the scaling factor into AR5
	stm #0800h, ar1 		; re�Calign to the beginning of the array
	stl a, *ar2
	ld *ar2, t
	stm #127, brc
	rptb end_scale2�C1
	mpy *ar1, a
	sth a, *ar1+
end_scale2:

	popm ar2
	popm ar1
	ret
*************************End of ��SCALING�� routine ********************


**********************************************************************
;
;RECIPROCAL
;==========
;
;This routine will perform the following:
;
; 1) Take the value in Acc A and compute its reciprocal
;2) The result is available in two portions, r and rexp.
;3) MPY r and rexp. however this may lead to a value greater
; than 32768.
;4) Now MPY (3) by reciprocal of 4, i.e. by 0.25. This is also
; equivalent to right shifting by 2 bit locations.
;5) Since (3) will likely lead to a value greater than 32768, it
; is probably better to perform (4) on value ��r�� from (2).
; This way the value is decreased by a factor of 4.
; Now, we can mutiply by rexp without exceeding 32768.
;
;NOTE: On entering this routine, the Acc A contains the MaxAbs value
; on which reciprocal computation has to be performed.
;
**********************************************************************

reciprocal:
		;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
		; Set offsets to local function variables defined on stack
		;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	.asg 0, SP_INVYETABLE
	.asg 1, SP_XNORM
	.asg 2, SP_TEMP
	.asg 3, FRAME_SZ
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
; Assign registers to local variables
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	.asg ar0, AR_X
	.asg ar1, AR_Z
		;.asg brc, AR_N
	.asg ar3, AR_ZEXP
	.asg ar4, AR_TABLE
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
; Process command�Cline arguments
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
		; stl a,*(AR_X) ; Acc A contains MaxAbs value
	pshm ar0
	pshm ar1
	pshm ar3
	pshm ar4
	pshm ar5
		;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
		; Initialize constants
		;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	st #InvYeTable,*sp(SP_INVYETABLE)
	ssbx OVM 			; 1 cycle, MUST turn overflow mode on.
	stm #0040h, AR_X
	stl a, *AR_X
	ld *AR_X,16,a
					;Acc A contains the MaxAbs value...so just start performing operation
	exp a 				; 1 cycle, delay �C slot
	nop 				; 1 cycle
	nop 				; 1 cycle
	norm a 				; 1 cycle
	st t,*sp(SP_TEMP) 		; store exponent computed by EXP instruction earlier
	ld #InvYeTable,b 		; 2 cycles
	add *sp(SP_TEMP),b 		; 1 cycle
	stl b,*(AR_TABLE) 		; 1 cycle
	sth a,*sp(SP_XNORM) 		; 1 cycle, AR2 points to appropriate Ye value in table.
	sfta a,�C1			; 1 cycle, Estimate the first Ym value.
	xor #01FFFh,16,a 		; 2 cycles
	sth a,*AR_Z 			; store result in auxiliary register
		;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
		; First two iterations:
		;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
   .loop 2
	ld *AR_Z,15,a 			; 2 cycles, Calculate Ym = 2*Ym �C Ym^2*X
	ld *AR_Z,t 			; 1 cycle
	mpy *sp(SP_XNORM),b 		; 1 cycle
	sth b,1,*AR_Z 			; 2 cycles
	mpy *AR_Z,b 			; 1 cycle
	sub b,1,a 			; 1 cycle
	sth a,2,*AR_Z 			; 2 cycles
   .endloop

		;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
		; Final iteration: �C this code is same as above loop, except
		; last instruction omitted
		;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	ld *AR_Z,15,a 			; 2 cycles, Calculate Ym = 2*Ym �C Ym^2*X
	ld *AR_Z,t 			; 1 cycle
	mpy *sp(SP_XNORM),b 		; 1 cycle
	sth b,1,*AR_Z 			; 2 cycles
	mpy *AR_Z,b 			; 1 cycle
	sub b,1,a 			; 1 cycle
	st #07000h,*AR_Z 		; 2 cycles, Make sure that 8000h <= Ym < 7FFFh
	add *AR_Z,16,a 			; 1 cycle
	sub *AR_Z,16,a 			; 1 cycle
	sub *AR_Z,16,a 			; 1 cycle
	add *AR_Z,16,a 			; 1 cycle
	sth a,3,*AR_Z 			; 2 cycles
	ld *AR_TABLE, t 		; setup for MPY
	bc div1207, ntc 		; if TC=0, then divide by 1.207

div4:
	ld *AR_Z, a 			; store the value of r into Acc A
	sfta a, �C2 			; divide by 4 = r/4
	stl a, *AR_Z 			; r available at *AR_Z again
bmultiply
					;ld *AR_TABLE,a ; 1 cycle, Read exponent value from table.
					;stl a,*AR_ZEXP ; 1 cycle
div1207:
	stm #0500h, ar5
	st #cmprval_2, *ar5
	ld *ar5, t 			; load 0.8284 into Treg
	mpy *AR_Z, a 			; r * 0.8284
	ld *AR_TABLE, t 		; re�Center exponent
	stl a, *AR_Z			 ; restore magnitude (r * 0.8284) to AR_Z
	nop
multiply:
	MPY *AR_Z, a 			; = {(r/4)*rexp} OR {(r * 0.8284)*rexp}
	rsbx ovm
	rsbx frct
	rsbx tc
	popm ar5
	popm ar4
	popm ar3
	popm ar2
	popm ar1
end_reciprocal:
	ret
********************* End of ��RECIPROCAL�� routine ********************
 
					; Return
					;�C�C�C�C�C�C�C�C
	end_lab				;	
	frame +2
	popm ar7
	popm ar6
	popm ar1
   .if __far_mode
	fretd
   .else
	retd
   .endif

	rsbx frct
	rsbx ovm
	.def InvYeTable
	.data
InvYeTable:
	.word 0002h ; Ye = 2^1
	.word 0004h ; Ye = 2^2
	.word 0008h Ye = 2^3
	.word 0010h ; Ye = 2^4
	.word 0020h ; Ye = 2^5
	.word 0040h ; Ye = 2^6
	.word 0080h ; Ye = 2^7
	.word 0100h ; Ye = 2^8
	.word 0200h ; Ye = 2^9
	.word 0400h ; Ye = 2^10
	.word 0800h ; Ye = 2^11
	.word 1000h ; Ye = 2^12
	.word 2000h ; Ye = 2^13
	.word 4000h ; Ye = 2^14
	.word 8000h ; Ye = 2^15
	;end of file. please do not remove. it is left here to ensure that no lines of code are removed by any editor


A.2 Cbrev.asm
;*********************************************************************
; Function: cbrev
; Description: complex bit�Creverse routine (C54x)
; Version: 1.00
;
; Copyright Texas instruments Inc, 1998
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
; Revision History:
; 1.00 R. Piedra, 8/31/98. Original release.
;*********************************************************************

	.mmregs
   .if __far_mode
	offset .set 1
   .else
	offset .set 0
   .endif
					; stack description
	.asg (0), ret_addr
					; x in A
	.asg (1+ offset), arg_y
	.asg (2+ offset), arg_n
					; register usage
					; ar0 : bit reversing idx
	.asg ar2,ar_dst
	.asg ar3,ar_src
	.global _cbrev

	.text

_cbrev
	ssbx frct 			; fractional mode is on (1)
	ssbx sxm 			; (1)
					; Get arguments
					; �C�C�C�C�C�C�C�C�C�C�C�C�C
	stlm a, ar_src 			; pointer to src (1)
	mvdk *sp(arg_y), *(ar_dst) 	; pointer to dst (temporary) (2)
	ld *sp(arg_n), a 		; a = n (1)
	stlm a, AR0 			; AR0 = n = 1/2 size of circ buffer (1)
	sub #3,a 			; a = n�C3(by pass 1st and last elem)(2)
					; Select in�Cplace or off�Cplace bit�Creversing
					; �C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	ldm ar_src,b 			; b = src_addr (1)
	sub *sp(arg_y),b 		; b = src_addr �C dst_addr (1)
	bcd in_place, beq 		; if (ar_src==ar_dst)then in_place (2)
	stlm a, brc 			; brc = n�C3 (1)
	nop 				; (1)	
					; Off�Cplace bit�Creversing
					; �C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
off_place:
_start1:
					; unroll to fill delayed slots
	rptbd off_place_end�C1 		; (2)
	mvdd *ar_src+,*ar_dst+ 		; move real component (1)
	mvdd *ar_src�C,*ar_dst+ 	; move Im component (1)
	mar *ar_src+0B 			; (1)
	mvdd *ar_src+,*ar_dst+ 		; move real component (1)
	mvdd *ar_src�C,*ar_dst+ 	; move Im component (1)
off_place_end:
	mar *ar_src+0B 			; (1)
	bd end ; (2)
	mvdd *ar_src,*ar_dst+ 		; move real component (1)
	mvdd *ar_srcC,*ar_dst+ 		; move Im component (1)
					; In�Cplace it�Creversing
					; �C�C�C�C�CC�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
in_place:   
	mar *ar_src+B 			; bypass first and last element (1)
	mar *+ar_dst2) 			; (1)
_start2:    
	rptbd in_plae_end�C1 		; (2)
	ldm ar_src,a			; b = src_addr (1)
	ldm ar_dst,  			; a = dst_addr (1)
	sub b,a 			; a = src_addr �C dst_addr (1)
					; if >=0 bypass move just increment
	bcd bypass, ageq 		; if (src_addr>=dst_addr) then skip(2)
	ld *ar_dst+, a 			; a = Re dst element (preserve) (1)
	ld *ar_dst�C, b 		; b = Im dst element (preserve) (1)
	mvdd *ar_src+, *ar_dst+ 	; Re dst = Re src (1)
	mvdd *ar_src , *ar_dst�C 	; Im dst = Im src;point to Re (1)
	stl b, *ar_src�C 		; Im src = b = Im dst;point to Re (1)
	stl a, *ar_src 			; Re src = a = Re dst (1)
bypass
	mar *ar_src+0B 			; (1)
	mar *+ar_dst(2) 		; (1)
	ldm ar_src,a 			; b = src_addr (1)
	ldm ar_dst, b 			; a = dst_addr (1)

in_place_end
					; Return
					; �C�C�C�C�C�C
_end:
	end
   .if __far_mode
	fretd
   .else
	retd
   .endif

	rsbx frct
	rsbx ovm
	;end of file. please do not remove. it is left here to ensure that no lines of code are removed by any editor


A.3 Macros.asm
;*********************************************************************
; Filename: macros.asm
; Version : 1.00
; Description: collections of macros for cfft
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
; Description: Contains the following macros
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
; Revision History:
;
; 0.00 M. Christ/M. Chishtie. Original code
; 1.00 R./ Piedra, 8/31/98
; �C Modifed stage3 macro to correct functional problem
; �C Modified order of xmem, ymem operands in butterfly code
; to reduce number of cycles from 10 to 8
;
;*********************************************************************
;
;Variation from macros.asm in fft_approach2.mak. Here the
;auto scaling has been disabled in:
; stage3, stdmacro and laststag
;
;*********************************************************************
.mmregs
;*********************************************************************
; macro : combo5xx
;
; COMBO5xx macro implements a bit reversal stage and the first two FFT
; stages (radix�C4 implementation). Bit reversal is now done in the same
; loop
; thereby saving cycles. Circular addressing is used to access INPUT
; buffer and
; bit�Creversed addressing is used to implement the DATA buffer.
; Therefore INPUT
; buffer must now be aligned at 4*N and DATA buffer at 2*N boundary.
; (MCHI)
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C

combo5xx .macro ; REPEAT MACRO ��combo5xx��: N/4 times
	; .global STAGE1,COMBO1,COMBO2,end1,end2,end?
	*
	* R1 := [(R1+R2)+(R3+R4)]/4 INPUT OUTPUT
	*
	* R2 := [(R1�CR2)+(I3�CI4)]/4 �C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C �C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C
	*
	* R3 := [(R1+R2)�C(R3+R4)]/4 AR0 = 7
	*
	* R4 := [(R1�CR2)�C(I3�CI4)]/4 AR1 �C> R1,I1 AR1 �C > R5,I5
	*
	* I1 := [(I1+I2)+(I3+I4)]/4 AR2 �C> R2,I2 AR2 �C > R6,I6
	*
	* I2 := [(I1�CI2)�C(R3�CR4)]/4 ARP�C> AR3 �C> R3,I3 ARP �C > AR3 �C > R7,I7
	*


	* I3 := [(I1+I2)�C(I3+I4)]/4 AR4 �C> R4,I4 AR4 �C > R8,I8
	*
	* I4 := [(I1�CI2)+(R3�CR4)]/4
	*
	;
STAGE1:
	mvdk *sp(DATA),ar2			; (RMP) pointer to DATA r1,i1
	mvdk *sp(DATA),ar3
	mvmm ar3,ar4
	mvmm ar3,ar5
	mar *+ar3(2) 				; pointer to DATA + 2 r2,i2
	mar *+ar4(4) 				; pointer to DATA + 4 r3,i3
	mar *+ar5(6) 				; pointer to DATA + 6 r4,i4
	ld *sp(scale), a
	bcd COMBO2, AEQ
	ld #0,ASM 				; ASM=0
	nop
	ld #�C2, ASM
   .if N>4
	stm #7,ar0 				; index
	stm #0,BK 				; blocksize to zero!
	stm #N/4�C1,BRC				; execute N/4�C1 times ��combo5xx��
	rptb end1
   .endif
						; AR2 AR3 AR4 AR5
						; ; �C�C�C �C�C�C �C�C�C �C�C�C
COMBO1 	sub *ar2,*ar3,B 			; B := (R1�CR2) R1 R2 R3 R4
	add *ar2,*ar3,A 			; A := (R1+R2) R1 R2 R3 R4
	sth B,ASM,*ar3 				; R2��:= (R1�CR2)/4 R1 R2 R3 R4
	add *ar4,*ar5,B 			; B := (R3+R4) R1 R2 R3 R4
	add B,A 				; A := (R1+R2) + (R3+R4)
						; R1 R2 R3 R4
	sth A,ASM,*ar2+ 			; R1��:=((R1+R2) + (R3+R4))/4
						; I1 R2 R3 R4
	sub B,1,A 				; B :=((R1+R2) �C (R3+R4))
						; I1 R2 R3 R4
	sub *ar4,*ar5,B 			; B := (R3�CR4)
						; I1 R2 R3 R4
	st A,*ar4+ ;ASM 			; R3��:=((R1+R2) �C (R3+R4))/4
						; I1 R2 I3 R4
	|| ld *ar3,A ; 16 			; A := (R1�CR2)/4 I1 R2 I3 R4
	sth B,ASM,*ar5+ 			; R4��:= (R3�CR4)/4 I1 R2 I3 I4
	sub *ar4,*ar5�C,B 			; B := (I3�CI4) I1 R2 I3 R4
	add B,ASM,A 				; A := (R1�CR2) + (I3 �CI4)/4
						; I1 R2 I3 R4
	sth A,*ar3+ 				; R2��:= (R1�CR2) + (I3 �CI4)/4
						; I1 I2 I3 R4
	sub B,�C1,A 				; A :=((R1�CR2) �C (I3�CI4))
						; I1 I2 I3 R4
	
	
	ld *ar5,16,B 				; B=R3�CR4
	sth A,*ar5+ 				; R4��:=((R1�CR2) �C (I3�CI4))/4
						; I1 I2 I3 I4
	add *ar4,*ar5,A 			; A := (I3+I4) I1 I2 I3 I4
	sth A,ASM,*ar4 				; I3��:= (I3+I4)/4 I1 I2 I3 I4
	sub *ar2,*ar3,A 			; A := (I1�CI2) I1 I2 I3 I4
	add B,2,A				; A := (I1�CI2)+ (r3�Cr4)
						; I1 I2 I3 I4
	sth A,ASM,*ar5+0 			; I4��:= (I1�CI2)+ (r3�Cr4)/4
						; I1 I2 I3 R4��
	sub B,3,A 				; A := (I1�CI2)�C (r3�Cr4)
						; I1 I2 I3 R4��
	add *ar2,*ar3,B 			; B := (I1+I2) I1 I2 I3 R4��
	st A,*ar3+0% 				;asm; I2��:= (I1�CI2)�C(R3�CR4)/4
						; I1 R2�� I3 R4��
	|| ld *ar4,A 				;16 ; A := (I3+I4)/4 I1 R2�� I3 R4��
	add A,2,B 				; B := (I1+I2)+(I3+I4)
						; I1 R2�� I3 R4��
	sth B,ASM,*ar2+0 			; I1��:= (I1+I2)+(I3+I4)/4
						; R1�� R2�� I3 R4��
	sub A,3,B 				; B := (I1+I2)�C(I3+I4)/4
						; R1�� R2�� I3 R4��
end1 	sth B,ASM,*ar4+0 			; I3��:= (I1+I2)�C(I3+I4)/4
						; R1�� R2�� R3�� R4��
bend?

COMBO2
   .if N>4
	stm #7,ar0 				; index
	stm #0,BK 				; blocksize to zero!
	stm #N/4�C1,BRC 				; execute N/4�C1 times ��combo5xx��
	rptb end2 ;
   .endif
						; AR2 AR3 AR4 AR5
						; ; �C�C�C �C�C�C �C�C�C �C�C�C
	sub *ar2,*ar3,B 			; B := (R1�CR2) R1 R2 R3 R4
	add *ar2,*ar3,A 			; A := (R1+R2) R1 R2 R3 R4
	sth B,ASM,*ar3 				; R2��:= (R1�CR2) R1 R2 R3 R4
	add *ar4,*ar5,B 			; B := (R3+R4) R1 R2 R3 R4
	add B,A 				; A := (R1+R2) + (R3+R4)
						; R1 R2 R3 R4
	sth A,ASM,*ar2+ 			; R1��:= (R1+R2) + (R3+R4)
						; I1 R2 R3 R4
	sub B,1,A 				; A := (R1+R2) �C (R3+R4)
						; I1 R2 R3 R4
	sub *ar4,*ar5,B 			; B := (R3�CR4) I1 R2 R3 R4
	st A,*ar4+ ;ASM 			; R3��:= (R1+R2) �C (R3+R4)
						; I1 R2 I3 R4
	|| ld *ar3,A 				; 16 ; A := (R1�CR2) I1 R2 I3 R4
	sth B,ASM,*ar5+ 			; R4��:= (R3�CR4) I1 R2 I3 I4
	sub *ar4,*ar5�C,B 			; B := (I3�CI4) I1 R2 I3 R4
	add B,ASM,A 				; A := (R1�CR2) + (I3�CI4)
						; I1 R2 I3 R4
	sth A,*ar3+ 				; R2��:= (R1�CR2) + (I3�CI4)
						;I1 I2 I3 R4
	sub B,1,A 				; A := (R1�CR2) �C (I3�CI4)
						; I1 I2 I3 R4
	ld *ar5,16,B 				; B=R3�CR4
	sth A,*ar5+ 				; R4��:= (R1�CR2) �C (I3�CI4)
						; I1 I2 I3 I4
	add *ar4,*ar5,A 			; A := (I3+I4) I1 I2 I3 I4
	sth A,ASM,*ar4 				; I3��:= (I3+I4) I1 I2 I3 I4
	sub *ar2,*ar3,A 			; A := (I1�CI2) I1 I2 I3 I4
	add B,A					; A := (I1�CI2)+ (r3�Cr4)
						; I1 I2 I3 I4
	sth A,ASM,*ar5+0			; I4��:= (I1�CI2)+ (r3�Cr4)
						; I1 I2 I3 R4��
	sub B,1,A 				; A := (I1�CI2)�C (r3�Cr4)
						; I1 I2 I3 R4��
	add *ar2,*ar3,B 			; B := (I1+I2) I1 I2 I3 R4��
	st A,*ar3+0% 				;asm; I2��:= (I1�CI2)�C(R3�CR4)
						; I1 R2�� I3 R4��
	|| ld *ar4,A ;16 			; A := (I3+I4) I1 R2�� I3 R4��
	add A,B 				; B := (I1+I2)+(I3+I4)
						;I1 R2�� I3 R4��
	sth B,ASM,*ar2+0 			; I1��:= (I1+I2)+(I3+I4)
						; R1�� R2�� I3 R4��
	sub A,1,B 				; B := (I1+I2)�C(I3+I4)
						; R1�� R2�� I3 R4��
end2 	sth B,ASM,*ar4+0 			; I3��:= (I1+I2)�C(I3+I4)
	; R1�� R2�� R3�� R4��
end? .endm
	
;*********************************************************************
; macro: stage3
;
; STAGE3 macro is improved such that it now takes only 31 cycles per
;iteration.
; It uses two additional auxiliary registers(AR1,AR4) to support
;indexing.(MCHI)
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C

stage3 .macro
				; .global STAGE3,MCR3,end?
	.asg AR2,P
	.asg AR3,Q
STAGE3:
	ld #0, ASM 		; Introduced by AC 06/06/99 to bypass autoscaling
				; and scale only when required within the file
				; cfft64_2.asm
	ld *sp(DATA),a 		; a = DATA
	stlm a, P 		; pointer to DATA pr,pi
	add #8,a 		; a = DATA + #8
	stlm a, Q 		; pointer to DATA + 8 qr,qi
	ld *sp(scale),a


	STM #9,AR1
	STM #2,AR4
	xc 1,ANEQ
	ld #�C1,ASM
   .if N>8
	STM #N/8�C1,BRC 		; execute N/8�C1 times ��4 macros��
	RPTBD end? 		;
   .endif 			;
	LD *sp(SIN45),T 	; load to sin(45)
	nop
	
**********************************************************************
*
*
* MACRO requires number of words/number of cycles: 6.5
*
* PR��=(PR+QR)/2 PI��=(PI+QI)/2
*
* QR��=(PR�CQR)/2 QI��=(PI�CQI)/2
*
* version 0.99 from Manfred Christ update: 2. May. 94
*
**********************************************************************
				; (contents of register after exec.)
				; AR2 AR3
				; �C�C�C �C�C�C
	MCR3 LD *P,16,A 	; A := PR PR QR
	SUB *Q,16,A,B		; B : PR�CQR PR QR
	ST B,*Q 		; QR:= (1/2)(PR�CQR)
	|| ADD *Q+,B 		; B := (PR+QR) PR QI
	ST B,*P+ 		; PR:= (1/2)(PR+QR)
	|| LD *Q,A 		; A := QI PI QI
	ST A,*Q 		; Dummy write
	|| SUB *P,B 		; B := (PI�CQI) PI QI
	ST B,*Q+ 		; QI:= (1/2)(PI�CQI) PI QR+1
	|| ADD *P,B 		; B := (PI+QI)
	ST B,*P+ 		; PI:= (1/2)(PI+QI) PR+1 QR+1
	
**********************************************************************
*
* MACRO requires number of words/number of cycles: 9
*
* T=SIN(45)=COS(45)=W45
*
* PR��= PR + (W*QI + W*QR) = PR + W * QI + W * QR (<�C AR2)
*
* QR��= PR �C (W*QI + W*QR) = PR �C W * QI �C W * QR (<�C AR3)
*
* PI��= PI + (W*QI �C W*QR) = PI + W * QI �C W * QR (<�C AR2+1)
*
* QI��= PI �C (W*QI �C W*QR) = PI �C W * QI + W * QR (<�C AR3+2)
*


*
*
* PR��= PR + W * (QI + QR) (<�C AR2)
*
* QR��= PR �C W * (QI + QR) (<�C AR3)
*
* PI��= PI + W * (QI �C QR) (<�C AR2+1)
*
* QI��= PI �C W * (QI �C QR) (<�C AR3+1)
*
* version 0.99 from Manfred Christ update: 2. May. 94
*
*
**********************************************************************

	|| MPY *Q+,A 			;A = QR*W PR QI
	MVMM AR4,AR0 			;Index = 2
	MAC *Q�C,A 			;A := (QR*W +QI*W) PR QR
	ADD *P,16,A,B 			;B := (PR+(QR*W +QI*W )) PR QR
	ST B,*P 			;<<ASM;PR��:= (PR+(QR*W +QI*W ))/2 PI QR
	|| SUB *P+,B 			;B := (PR�C(QR*W +QI*W )) PI QR
	ST B,*Q 			;<<ASM;QR��:= (PR�C(QR*W +QI*W ))/2
	|| MPY *Q+,A 			;A := QR*W PI QI
	MAS *Q,A 			;A := ( (QR*W �CQI*W )) PI QI
	ADD *P,16,A,B 			;B := (PI+(QR*W �CQI*W )) PI QI
	ST B,*Q+0% 			;QI��:= (PI+(QR*W �CQI*W ))/2 PI QI+1
	|| SUB *P,B 			;B := (PI�C(QR*W �CQI*W )) PI QI+1
	ST B,*P+ 			;PI��:= (PI�C(QR*W �CQI*W ))/2 PR+1 QI+1
	
**********************************************************************
*
*
* MACRO ��PBY2I�� number of words/number of cycles: 6
*
* PR��=(PR+QI)/2 PI��=(PI�CQR)/2
*
* QR��=(PR�CQI)/2 QI��=(PI+QR)/2
*
* version 0.99 from Manfred Christ update: 2. May. 94
*
**********************************************************************

					; (contents of register after exec.)
					; AR2 AR3
					; �C�C�C �C�C�C
	|| LD *Q�C,A 			; A := QI PR QR
					; rmp ADD *P,A,B ; B := (PR+QI) PR QR
					; rmp: 8/31/98 corrected following ADD instruction
	ADD *P,16,A,B 			; B := (PR+QI) PR QR
	ST B,*P 			; PR�� := (PR+QI)/2
	|| SUB *P+,B 			; B := (PR�CQI) PI QR
	ST B,*Q 			; QR�� := (PR�CQI)/2
	|| LD *Q+,A 			; A := QR PI QI
					; rmp ADD *P,A,B ; B := (PI+QR) PI QI
					; rmp 8/31/98 corrected following ADD instruction
	ADD *P,16,A,B 			; B := (PI+QR) PI QI
	ST B,*Q+ 			; QI�� := (PI+QR)/2 PI QR+1
	|| SUB *P,B 			; B := (PI�CQR)
	ST B,*P+ 			; PI�� := (PI�CQR)/2 PR+1 QR+1
	
**********************************************************************
*
* MACRO requires number of words/number of cycles: 9.5
*
* version 0.99 from: Manfred Christ update: 2. May. 94
*
* ENTRANCE IN THE MACRO: AR2�C>PR,PI
*
* AR3�C>QR,QI
*
* TREG=W=COS(45)=SIN(45)
*
* EXIT OF THE MACRO: AR2�C>PR+1,PI+1
*
* AR3�C>QR+1,QI+1
*
* PR��= PR + (W*QI �C W*QR) = PR + W * QI �C W * QR (<�C AR1)
*
* QR��= PR �C (W*QI �C W*QR) = PR �C W * QI + W * QR (<�C AR2)
*
* PI��= PI �C (W*QI + W*QR) = PI �C W * QI �C W * QR (<�C AR1+1)
*
* QI��= PI + (W*QI + W*QR) = PI + W * QI + W * QR (<�C AR1+2)
*
* PR��= PR + W*(QI �C QR) = PR �C W *(QR �CQI) (<�C AR2)
*
* QR��= PR �C W*(QI �C QR) = PR �C W *(QR �CQI) (<�C AR3)
*
* PI��= PI �C W*(QI + QR) (<�C AR2+1)
*
* QI��= PI + W*(QI + QR) (<�C AR3+1)
*
* BK==0 !!!!!
*
**********************************************************************    

					; AR2 AR3
					; �C�C�C �C�C�C
	|| MPY *Q+,A 			;A := QR*W PR QI
	MVMM AR1,AR0 			;Index = 9
	MAS *Q�C,A 			;A := (QR*W �CQI*W ) PR QR
	ADD *P,16,A,B 			;B := (PR+(QR*W �CQI*W )) PR QR
	ST B,*Q+ 			;<<ASM;QR��:= (PR+(QR*W �CQI*W ))/2 PR QI
	|| SUB *P,B 			;B := (PR�C(QR*W �CQI*W ))
	ST B,*P+ 			;<<ASM;PR��:= (PR�C(QR*W �CQI*W ))/2
	|| MAC *Q,A 			;A := QR*W PI QI
	MAC *Q,A 			;A := ( (QR*W +QI*W )) PI QI
	ADD *P,16,A,B 			;B := (PI+(QR*W +QI*W )) PI QI
	
	
	ST B,*Q+0% 			;<ASM;QI��:= (PI+(QR*W +QI*W ))/2 PI QR+1
	|| SUB *P,B 			;B := (PI�C(QR*W +QI*W ))
	STH B,ASM,*P+0% 		;PI��:= (PI�C(QR*W +QI*W ))/2 PR+1QR+1
end? 	.set $�C1
	STM #�C2,AR0 			;Index used in stdmacro macro
   .endm
   
;*********************************************************************
; macro : laststag
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C

laststag .macro stage,sin,cos
					; .global STAGE:stage:,end?
STAGE:
stage: 	.set $
	ld #0, ASM 			; Introduced by AC 06/06/99 to bypass autoscaling
					; and scale only when required within the file
					; cfft64_2.asm
	ld *sp(DATA),a
	stlm a, ar2 			; ar2 �C> DATA
	add #N,a
	stlm a, ar3 			; ar3 �C> DATA+(offset=N)
	stm #cos,ar4 			; start of cosine in stage ��stg��
	stm #sin,ar5 			; start of sine in stage ��stg��
	buttfly N/2			 ; execute N/2 butterflies
.endm

;*********************************************************************
; macro : stdmacro
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C

stdmacro .macro stage,l1,l2,idx,sin,cos
					; .global STAGE:stage:,end?
STAGE:
stage: 	.set $
	ld #0, ASM 			; Introduced by AC 06/06/99 to bypass autoscaling
					; and scale only when required within the file
					; cfft64_2.asm
	ld *sp(DATA),a
	stl a,ar2 			; ar2 �C> DATA
	add #idx,a 			; ar3 �C> DATA+(offset=idx)
	stlm a,ar3
	stm #l1�C1,ar1 			; outer loop counter
	stm #cos,ar6 			; start of cosine in stage ��stg��
	stm #sin,ar7 			; start of sine in stage ��stg��
	loop? mvmm ar6,ar4 		; start of cosine in stage ��stg��
	mvmm ar7,ar5 			; start of sine in stage ��stg��
	buttfly l2 			; execute l2 butterflies
	mar *+ar2(idx)
	banzd loop?,*ar1�C
	
	
	mar *+ar3(idx)
.endm    

;*********************************************************************
; macro: buttfly
;
; Improved radix�C2 butterfly code from 9 to 8 cycles per iteration. The
; new butterfly uses AR0 for indexing and the loop is unrolled such
; that one butterfly is implemented outside the loop.
;�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C�C

buttfly .macro num 			; (contents of register after exec.)
	.asg AR2, P
	.asg AR3, Q
	.asg AR4,WR
	.asg AR5,WI
	
	ld #0, ASM 			; Introduced by AC 06/06/99 to bypass autoscaling
					; and scale only when required within the file
					; cfft64_2.asm
					; it should already be disabled by this point, since
					; this has already been invoked in stdmacro and
					; laststag.
					;X STM #�C2,AR0 ; index = �C2
	STM #:num:�C3,BRC 		; execute startup + num�C3 times general	BUTTFLY
					; AR2 AR3 AR4 AR5
					; takes 17 words�C/cycles (including RPTB) �C�C�C �C�C�C �C�C�C �C�C�C
	LD *P,16,A 			;A := PR PR QR WR WI
	SUB *Q,16,A,B 			;B : PR�CQR PR QR WR WI
	ST B,*Q 			;<<ASM;QR��:= (PR�CQR)/2
	|| ADD *Q+,B 			;B := (PR+QR) PR QI WR WI
	ST B,*P+ 			;<<ASM;PR��:= (PR+QR)/2
	|| LD *Q,A 			;<<16 ;A := QI PI QI WR WI
	ADD *P,16,A,B 			;B := (PI+QI) PI QI WR WI
	ST B,*P 			;<<ASM;PI��:= (PI+QI)/2
	|| SUB *P+,B 			;B := (PI�CQI) PR+1 QR WR WI
	STH B,ASM,*Q+ 			;QI��:= (PI�CQI)/2 PR+1 QR+1 WR WI
	MPY *WR,*Q+,A 			;A := QR*WR PR+1 QI+1 WR WI
	MAC *WI+,*Q�C,A 			;A := (QR*WR+QI*WI) || T=WI
					; PR+1 QR+1 WR WI+1
	ADD *P,16,A,B 			;B := (PR+(QR*WR+QI*WI)) PR+1 QR+1 WR WI+1
	ST B,*P 			;<<ASM;PR��:= (PR+(QR*WR+QI*WI))/2
	|| SUB *P+,B 			;B := (PR�C(QR*WR+QI*WI)) PI+1 QR+1 WR WI+1
	ST B,*Q 			;<<ASM;QR��:= (PR�C(QR*WR+QI*WI))/2
	|| MPY *Q+,A 			;A := QR*WI [t=WI] PI+1 QI+1 WR WI+1
	MAS *WR+,*Q,A 			;A := ( (QR*WI�CQI*WR)) PI+1 QI+1 WR+1 WI+1
	RPTBD end?�C1 			;delayed block repeat
	ST A,*Q+ 			;dummy write
	|| SUB *P,B 			;B := (PI�C(QR*WI�CQI*WR)) PI+1 QR+2 WR+1 WI+1
	ST B,*P 			;<<ASM;PI��:= (PI�C(QR*WI�CQI*WR))/2


	
	|| ADD *P+,B 			;B := (PI+(QR*WI�CQI*WR)) PR+2 QR+2 WR+1 WI+1
					;
					; Butterfly kernal with 8 instructions / 8 cycles
					;
					; rmp MPY *WR,*Q+,A ;A := QR*WR PR+2 QI+2 WR+1 WI+1
					; rmp reversed order in following MPY instruction
	MPY *Q+,*WR,A 			;A := QR*WR PR+2 QI+2 WR+1 WI+1
	MAC *WI+,*Q+0%,A 		;A := (QR*WR+QI*WI) || T=WI
					; PR+2 QI+1 WR+1 WI+2
	ST B,*Q+ 			;<<ASM	;QI��:= (PI+(QR*WI�CQI*WR))/2
	|| ADD *P,B 			;B := (PR+(QR*WR+QI*WI))
					; PR+2 QR+2 WR+1 WI+2
	ST B,*P 			;<<ASM;PR��:= (PR+(QR*WR+QI*WI))/2
	|| SUB *P+,B 			;B := (PR�C(QR*WR+QI*WI))
					; PI+2 QR+2 WR+1 WI+2
	ST B,*Q 			;<<ASM;QR��:= (PR�C(QR*WR+QI*WI))/2
	|| MPY *Q+,A 			;A := QR*WI [t=WI]
					; PI+2 QI+2 WR+1 WI+2
					; rmp MAS *WR+,*Q,A ;A := ( (QR*WI�CQI*WR))
					; PI+2 QI+2 WR+2 WI+2
					; rmp reversed order in following MPY instruction
	MAS *Q,*WR+,A 			;A := ( (QR*WI�CQI*WR))
					; PI+2 QI+2 WR+2 WI+2
	ST A,*Q+ 			;dummy write
	|| SUB *P,B 			;B := (PI�C(QR*WI�CQI*WR))
					; PI+2 QR+3 WR+2 WI+2
	ST B,*P 			;<<ASM;PI��:= (PI�C(QR*WI�CQI*WR))/2
	|| ADD *P+,B 			;B := (PI+(QR*WI�CQI*WR))
					; PR+3 QR+3 WR+2 WI+2
end?
	MAR *Q�C
	STH B,ASM,*Q+ 			;QI��:= (PI+(QR*WI�CQI*WR))/2
					; PR+3 QR+3 WR+2 WI+2
.endm
	;end of file. please do not remove. it is left here to ensure that no lines of code are removed by any editor
	
	
	
	
	
	
	