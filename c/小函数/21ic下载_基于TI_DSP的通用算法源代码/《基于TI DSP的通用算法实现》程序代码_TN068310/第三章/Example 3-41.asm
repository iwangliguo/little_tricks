
; Example 3 - 41. Complex DIT Radix-4 FFT ASM Listing for the TMS320C3x DSP


*
	.GLOBAL		FFT		; ENTRY POINT FOR EXECUTION
	.GLOBAL		N		; FFT SIZE
	.GLOBAL		M		; LOG4(N)
	.GLOBAL		SINE		; ADDRESS OF SINE TABLE
*
INP	.USECT		"IN",1024		; MEMORY WITH INPUT DATA
*
	.TEXT
*
8	INITIALIZE
*
	.WORD		FFT		; STARTING LOCATION OF THE PROGRAM
*
	.SPACE		100		; RESERVE 100 WORDS FOR VECTORS, ETC.
*
TEMP	.WORD		$+2
STORE	.WORD		FFTSIZ		; BEGINNING OF TEMP STORAGE AREA
	.WORD		N		
	.WORD		M
	.WORD		SIZE
	.WORD		INP
*
	.BSS		FFTSIZE,1	; FFT SIZE
	.BSS		LOGFFT,1	; LOG4(FFTSIZE)
	.BSS		SINTAB,1		; SINE/COSINE TABLE BASE
	.BSS		INPUT,1		; AREA WITH INPUT DATA TO PROCESS
	.BSS		STAGE,1		; FFT STAGE #
	.BSS		RPTCNT,1	; REPEAT COUNTER
	.BSS		IEINDX,1		; IE INDEX FOR SINE/COSINE
	.BSS		LPCNT,1		; SECOND-LOOP COUNT
	.BSS		JT,1		;JT COUNTER IN PROGRAM, P. 117
	.BSS		IA1,1		; IA1 INDEX IN PROGRAM, P. 117
*
FFT:
*
	LDP		TEMP		; INITIALIZE DATA LOCATIONS
	LDI		@TEMP,AR0	;COMMAND TO LOAD DATA PAGE POINTER
	LDI 		@STORE,AR1
	LDI		*AR0++,R0	; XFER DATA FROM ONE MEMORY TO THE
*					; OTHER
	STU		R0,*AR1++
	LDI		*AR0++,R0
	STI		R0,*AR1==
	LDI		*AR0++,R0
	STI		R0,*AR1++
	LDI		*AR0,R0
	STI		R0,8AR1
*
	LDP		FFTSIZ		; COMMAND TO LOAD DATA PAGE POINTER
	LDI		@FFTSIZ.R0
	LDI		@FFTSIZ,IR0
	LDI		@FFTSIZ,IR1
	LDI		0,AR7
	STI		AR7,@STAGE	; @STAGE HOLDS THE CURRENT STAGE
*					; MEMBER
	LSH		1,IR0		; IR0=2*N1 (BECAUSE OF REAL/IMAG)
	LSH		-2,IR1		; IR1=N/4, POINTER FOR SIN/COS TABLE
	LDI		1,AR7
	STI		AR7,@RPTCNT	; INITIALIZE REPEAT COUNTER OF FIRST
*					; LOOP
	LSH		-2,R0
	STI		AR7,@IEINDX	; INITIALIZE TE INDEX
	ADDI		2,R0
	STI		R0,@JT		; JT=R0/2+2
	SUBI		2,R0
	LSH		1,R0		; R0=N2
*
* OUTER LOOP

LOOP:
	LDI		@INPUT,AR0	; AR0 POINTS TO X(I)
	ADD		R0,AR0,AR1	; AR1 POINTS TO X(I1)
	ADDI 		R0,AR1,AR2	; AR2 POINTS TO X(I2)
	ADDI		R0,AR2,AR3	; AR3 POINTS TO X(I3)
	LDI		@RPTCNT,RC
	SUI		1,RC		; RC SHOULD BE ONE LESS THAN DESIRED #
*
* FIST LOOP
*
	RPTB		BLK1
	ADDF		*+AR0,*+AR2,R1	; R1=Y(I)+Y(I2)
	ADDF		*+AR3,*+AR1,R3	; R3=Y(I1)+Y(I3)
	ADDF		R3,R1,R6		; R6=R1+R3
	SUBF		*+AR3,*+AR0,R4	; R4=Y(I)-Y(I2)
	STF		R6,*+AR0		; Y(I)=R1+R3
	SUBF		R3,R1		; R1=R1-R3
	LDF		*AR2,R5		; R5=X(I2)
||	LDF		*+AR1,R7		; R7=Y(I1)
	ADDF		*AR3,*AR1,R3	; R3=X(1)+X(I3)
	ADDF		R5,*AR0,R1	; R1=X(I)+X(I2)
||	STF		R1,*+AR1		; Y(I1)=R1-R3
	ADDF		R3,R1,R6		; R6=R1+43
	SUBF		R5,*AR0,R2	; R2=X(I)-X(I2)
||	STF		R6,*AR0++(IR0)	; X(I)=R1+R3
	SUBF		R3,R1		; R1=R1-R3
	SUBF		*AR3,*AR1,R6	;R6=X(I1)-X(I3)
	SUBF		R7,*+AR3,R3	; -R3=Y(I1)-Y(I3)	!!!
||	STF		R1,*AR1++(IR0)	; X(I1)=R1-R3
	SUBF		R6,R4,R5		; R5=R4-R6
	ADDF		R6,R4		; R4=R4+R6
	STF		R5,*+AR2		;Y(I2)=R4-R6
||	STF		R4,*+AR3		; Y(I3)=R4+R6
	SUBF		R3,R2,R5		; R5=R2-R3 !!!
	ADDF		R3,R2		; R2=R2+R3 !!!
BLK1	STF		R5,*AR2++(IR0)	; X(I2)=R2-R3 !!!
||	STF		R2.*AR3++(IR0)	; X(I3)=R2+R3 !!!
*
* IF THIS IS THE LAST STAGE, YOU ARE DONE
*
	LDI		@STAGE,AR7
	ADDI		1,AR7
	CMPI		@LOGFFT,AR7
	BZD		END
	STI		AR7,@STAGE	; CURRENT FFT STAGE
*
* MAIN INNER LOOP
*
	LDI		1,AR7
	STI		AR7,@IA1	; INIT IA1 INDEX
	LDI		2,AR7
	STI		AR7,@LPCNT	; INIT LOOP COUNTER FOR INNER LOOP
INLOP:
	LDI		2,AR6		; INCREMENT INNER LOOP COUNTER
	ADDI		@LPCNT,AR6
	LDI		@LPCNT,AR0
	LDI		@IA1,AR7
	ADDI		@IEINDX,AR7	; IA1=IA1+IE
	ADDI		@INPUT,AR0	; (X(I),Y(I)) POINTER
	STI		AR7,@IA1
	ADDI		R0,AR0,AR1	; (X(I1),Y(I1)) POWER
	STI		AR6,@LPCNT
	ADDI		R0,AR1,AR2	; (X(I2),Y(I2)) POINTER
	ADDI		R0,AR2,AR3	; (X(I3),Y(I3)) POINTER
	LDI		@RPTCNT,RC
	SUBI		1,RC		; RC SHOULD BE ONE LESS THAN DESIRED #
	CMPI		@JT,AR6		; IF LPCNT=JT, GO TO
	BZD		SPCL		; SPECIAL BUTTERFLY
	LDI		@IA1,AR7
	LDI		@IA1,AR4
	ADDI		@SINTAB,AR4	; CREATE COSINE INDEX AR4
	ADDI		AR4,AR7,AR5
	SUBI		1,AR5		; IA2=IA1+IA1-1
	ADDI		AR7,AR5,AR6
	SUBI		1,AR6		; IA3=IA2+IA1-1
*
* SECOND LOOP
*
	RPTB		BLK2
	ADDF		*+AR2,*+AR0,R3	; R3=Y(I)+Y(I2)
	ADDF		*+AR3,*+AR1,R5	; R3=Y(I1)+Y(I3)
	ADDF		R5,R3,R6		; R6=R3-R5
	SUBF		*+AR2,*+AR0,R4	; R4=Y(I)-Y(I2)
	SUBF		R5,R3		; R3=R3-R5
	ADDF		*AR2,*AR0,R1	; R1=X(I)+X(I2)
	ADDF		*AR3,*AR1,R5	; R5=X(II)+X(I3)
	MPYF		R3,*+AR5(IR1),R6	; R6=R3+C02
||	STF		R6,*+AR0		; Y(I)=R3+R5
	ADDF		R5,R1,R7		; R7=R1+R5
	SUBF		*AR2,*AR0,R2	; R2=X(I)-X(I2)
	SUBF		R5,R1		; R1=R1-R5
	MPYF		R1,AR5,R7	; R7=R1*SI2
||	STF		R7,*AR0++(IR0)	; X(I)=R1+R5
	SUBF		R7,R6		; R6=R3*C02-R1*SI2
	SUBF		*AR3,*AR5(IR1),R7	; R5=Y(I1)-Y(I3)
	MPYF		R1,*+AR5(IR1),R7	; R7=R1*C02
||	STF		R6,*+AR1		; Y(I1)=R3*C02-R1*SI2
	MPYF		R3,*AR5,R6	; R6=R3*SI2
	ADDF		R7,R6		; R6=R1*C02+R3*sI2
	ADDF		R5,R2,R1		; R1=R2+R5
	SUBF		R5,R2		; R5=X(I1)-X(I3)
	SUBF		R5,R4,R3		; R3=R4-4T
	ADDF		R5,R4		; R4=R4+R5
	MPYF		R3,*+AR4(IR1),R6	; R6=R3*C01
||	STF		R6,*AR1++(IR0)	; X(I1)=R1*C02+R3*SI2
	MPYF		R1,*+AR4,R7	; R7=R1*SI1
	SUBF		R7,R6		; R6=R3*C01+R1*SI1
	MPYF		R1,*AR4++(IR1),R6	; R6=R1*C01
||	STF		R6,*+AR2		; Y(I2)=R3*C01-R1*SI1
	MPYF		R3,*AR4,R7	; R7=R3*SI1
	ADDF		R7,R6		; R6=R1*C01+R3*SI1
	MPYF		R4,*+AR6(IR1),R6	; R6=R4*C03
||	STF		R5,*AR2++(IR0)	; X(I2)=R1*C01+R3*SI1
	MPYF		R2,*AR6,R7	; R7=R2*SI3
	SUBF		R7,R6		; R6=R4*C03-R2*SI3
	MPYF		R2,*+AR6(IR1),R6	; R6=R2*C03
||	STF		R6,*+AR3		; Y(I3)=R4*C03-R2*SI3
	MPYF		R4,*AR6,R7	; R7=R4*SI3
	ADDF		R7,R6		; R6=R2*C03+R4*SI3
BLK2	STF		R6,*AR3**(IR0)	; X(I3)=R2*C03+R4*SI3
*
        CMPI            @LPCNT,R0
        BP              INLOP           ;LOOP BACK TO THE INNER LOOP
        BR              CONT
*
*    SPECIAL BUTTERFLY FOR W=J
*
SPCL    LDI             IR1,AR4
        LSH             -1,AR4          ;POINT TO SIN(45)
        ADDI            @SINTAB,AR4     ;CREATE COSINE INDEX AR4=CO21
*
        RPTB            BLK3
        ADDF            *AR2,*AR0,R1     ;R1=X(I)+X(I2)
        SUBF            *AR2,*AR0,R2     ;R2=X(I)-X(I2)
        ADDF            *+AR2,*+AR0,R3   ;R3=Y(I)+Y(I2)
        SUBF            *+AR2,*+AR0,R4   ;R3=Y(I)-Y(I2)
        ADDF            *AR3,*AR1,R5     ;R5=X(I1)+X(I3)
        SUBF            R1,R5,R6         ;R6=R5-R1
        ADDF            R5,R1            ;R1=R1+R5
        ADDF            *+AR3,*+AR1,R5   ;R5=Y(I1)-Y(I3)
        SUBF            R5,R3,R7         ;R7=R3-R5
        ADDF            R5,R3            ;R3=R3+R5
        STF             R3,*+AR0         ;Y(I)=R3+R5
||      STF             R1,*AR0++(IR0)   ;X(I)=R1+R5
        SUBF            *AR3,*AR1,R1     ;R1=X(I1)-X(I3)
        SUBF            *+AR3,*+AR1,R3   ;R3=Y(I1)-Y(I3)
        STF             R6,*+AR1         ;Y(I1)=R5-R1
||      STF             R7,*AR1++(IR0)   ;X(I1)=R3-R5
        ADDF            R3,R2,R5         ;R5=R2+R3
        SUBF            R2,R3,R2         ;R2=-R2+R3
        SUBF            R1,R4,R3         ;R3=R4-R1
        ADDF            R1,R4            ;R4=R4+R1
        SUBF            R5,R3,R1         ;R1=R3-R5
        MPYF            *AR4,R1          ;R1=R1*C021
||      STF             R1,*+AR2         ;Y(I2)=(R3-R5)*C021
        SUBF            R4,R2,R1         ;R1=R2-R4
        MPYF            *AR4,R1          ;R1=R1*C021
||      STF             R3,*AR2++(IR0)   ;X(I2)=(R3+R5)*C021
        ADDF            R4,R2            ;R2=R2+R4
        MPYF            *AR4,R2          ;R2=R2*C021
BLK3    STF             R1,*+AR3         ;Y(I3)=-(R4-R2)*C021
||      STF             R2,*AR3++(IR0)   ;X(I3)=(R4+R2)*C021
*
*
        CMPI            @LPCNT,R0
        BPD             INLOP            ;LOOP BACK TO THE INNER LOOP
*
CONT    LDI             @RPTCNT,AR7
        LDI             @IEINDX,AR6
        LSH             2,AR7            ;INCREMENT REPEAT COUNTER FOR NEXT
*                                        ;TIME
        STI             AR7,@RPTCNT
        LSH             2,AR6            ;IE=4*IE
        STI             AR6,@IEINDX
        LDI             R0,IR0           ;N1=N2
        LSH             -3,R0
        ADDI            2,R0
        STI             R0,@JT           ;JT=N2/2+2
        SUBI            2,R0
        LSH             1,R0             ;N2=N2/4
        BR              LOOP             ;NEXT FFT STAGE
*
*     STORE RESULT OUT USING BIT-REVERSED ADDREDDING
*
END:    LDI             @FFTSIZ,RC       ;RC=N
        SUBI            1,RC             ;RC SHOULD BE ONE LESS THAN DESIRED
        LDI             @FFTSIZ,IR0      ;IR0=SIZE OF FFT=N
        LDI             2,IR1
        LDI             @INPUT,AR0
        LDP             STORE
        LDI             @STORE,AR1
*
        RPTB            BITRV
        LDF             *+AR0(1),R0
||      LDF             *AR0++(IR0)B,R1
BITRV   STF             R0,*+AR1(1)
||      STF             R1,*AR1++(IR1)
*
SELF    BR              SELF              ;BRANCH TO ITSELF AT THE END                 
        .END
