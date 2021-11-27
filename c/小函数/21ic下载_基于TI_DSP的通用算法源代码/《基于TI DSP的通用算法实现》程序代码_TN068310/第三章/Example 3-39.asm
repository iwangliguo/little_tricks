
; Example 3 - 39. Real DIT Radix-2 FFT ASM Listing for the TMS320C3x DSP


* APPENDIX C1.  
*
* Generic Program to Do a Radix-2 Real FFT Computation on the TMS320C30
*
* THE PROGRAM IS TAKEN FROM THE PAPER BY SORENSEN ET AL., JUNE 1987 ISSUE
* OF THE TRANSACTIONS ON ASSP .

* THE (REAL) DATA RESIDE IN INTERNAL MEMORY . THE COMPURATION IS DONE 
* IN-PLACE . THE BIT REVERSAL IS DONE AT THE BEGINNING OF THE PROGRAM .
*
* THE TWIDDLE FACTORS ARE SUOOLIDE IN A TABLE PUT IN A . DATA SECTION . THIS
* DATA IS INCLUED IN A SEPARATE FILE TO PRESERVE THE GENERIC NATURE OF THE 
* PROGRAM . FOR THE SAME PUPPOSE , THE SIZE OF THE FFT N AND LOG2(N) ARE 
* DEFINED IN A .GLOBL DIRECTIVE AND SPECIFIED DURING LINKING . 
* THE LENGTH OF THE TABLE IS N/4 + N/4 = N/2 .

* AUTHOR : PANOS E . PAPAMICHAL IS
*           TEXAS INSTRUMENTS                  SEPTEMBER 8 , 1987
*


    .GLOBL  FFT                       	; ENTRY POINT FOR EXECUTION
    .GLOBL  N                         	; FFT SIZE
    .GLOBL  M 				; OGZ(N)
    .GLOBL  SIZE			; ADDRESS OF SIZE TABLE
    
INP	.USECT  ¡°IN¡±,1024 		; MEMORY WITH INPUT DATA
    	.BSS     OUTP,1024            	; MEMORY WITH OUPUT DATA



   .TEXT
* 
* INITIALIZE
* 
	.WORD  FFT                  	; STARTING LOCATION OF THE PROGRAM

    	.SPACE  100                 	; RESERVE 100 WORDS FOR VECTORS,ETC.

FFTSIZ 	.WORD  N 
LOGFFT	.WORD  N
SINTAB  .WORD  SINE
INPUT  	.WORD  INP
OUTPUT	.WORD  OUTP

FFT:    
	LDP  FFTSIZ                	;COMMAND TO LOAD DATA POINTER
*
* DO THE BIT-REVERSING AT THE BEGINNING
*
    	LDI  FFTSIZ , RC                   ; RC=N
    	SUBI  1 , RC                       ; RC SHOULD BE ONE LESS THAN DESIRED
    	LDI  FFTSIZ , IRO
    	LSH  -1 , IRO                      ; IRO = HALF THE SIZE OF FFT = N/2
    	LDI  INPUT . ARO
    	LDI  INPUT , AR1

        RPTB  BITRV

        CNPI  AR1 , AR0            	;XCHANGE LOCATIONS ONLY
        BGE  CONT                  	; IF AR0<AR1
        LDF  AR0 , R0
||      LDF  AR1 , R1
        STF  R0 , AR1
||      STF  R1 , AR0

CONT    NOP  AR0++
BITRV   NOP  AR1++(IRO)B
*
* LENGTH-TWO BUTTERFLIES
*
        LDI  INPUT , AR0               ; AR0 POINTS TO X(I)
        LDI  IR0, RC                   ; REPEAT N/2 TIMES
        SUBI  1 , RC                   ; RC SHOULD BE ONE LESS THAN DESIRED
 
        RPTB  BLK1
        ADDF  #+AR0 , #AR0++ , R0      ;R0=X(I)+X(I+1)
        SUBF  #AR0 , #-AR0 , R1        ; R1=X(I)-X(I-1)
BLK1    STF  R0 , #-AR0                ; X(I)= X(I)+X(I+1)
||      STF  R0 , #AR0++               ; X(I+1)= X(I)-X(I+1)

*
* FIRST PASS OF THE DO-20 LOOP (STAGE K=2 IN DO-10 LOOP)
*
        LDI  INPUT , AR0               ; AR0 POINTS TO X(I)
        LDI  2 , IR0                   ; IR0=2=N/2
        LDI  FFTSIZE , RC
        LSH  1, RC                     ; RRPEAT N/4 TIMES
        SUBI  1, RC                    ; RC SHOULD BE ONE LESS THAN DESIRED 
    
        RPTB  BLK2
        ADDF  #+AR0(IR0),#AR0++(IR0),R0  ;R0= X(I)+X(I+2)
        SUBF  #AR0 , #-AR0(IR0),R1     ;R1= X(I)-X(I+2)
        NEGF  #+AR0 , R0            ; R0=-X(I+3)
||      STF   R0,#-AR0(IR0)          ; X(I)= X(I)+X(I+2)
BLK     STF  R1,#AR0++(IR0)         ; X(I+2)= X(I)-X(I+2)
||      STF  R0,#+AR0              ; X(I+3)= -X(I+3)

*
* MAIN  LOOP (FFT STAGES)
*
        LDI  FFTSIZ IR0
        LSH  -2 , IR0                 ; IR0=INDEX FOR E
        LDI  3 , R5                   ; R5 HOLDS THE CURRENT STAGE NUMBER
        LDI  1 , R4                   ; R4=N4
        LDI  2 , R3                  ; R3=N2
LOOP    LSH  -1 , IR0                ; E=E/2
        LSH  1 , R4                  ; N4=2#N4
        LSH  1 , R3                  ; N2=2#N2

*
* INNER LOOP (DO-20 LOOP IN THE PROGRAM)
*

        LDI  INPUT , AP5            ; AR5 POINTS TO X(I)
INLOP   LDI  IR0 , AR0
        ADDI  SINTAB , AR0         ; AR0 POINTS TO SIN/COS TABLE
        LDI  R4 , IR1                ; IR1=N4

        LDI  AR5 , AR1
        ADDI  1 , AR1                ;AR1 POINTS TO X(I1)=X(I+J)
        LDI  AR1 M AR3        
        ADDI  R3 , AR3              ; AR3 POINTS TO X(I3)=X(I+J+N2)
        LDI  AR3 , AR2
        SUBI  2 , AR2                ; AR2 POINTS TO X(I2)=X(I-J+N2)
        ADDI  R3,AR2,AR4           ; AR4 POINTS TO X(I4)=X(I-J+N1)

        LDF  #AR5++(IR1),R0         ; R0=X(I)
        ADDF  #+AR5(IR1),R0,R1      ; R1=X(I)+X(I+N2)
        SUBF  R0,#++AR5(IR1),R0     ; R0= X(I)+X(I+N2)
||      STF  R1,#-AR5(IR1)           ;X(I)= X(I)+X(I+N2)
        NEGF   R0                  ; R0= X(I)-X(I+N2)
        NEGF  #++AR5(IR1),R1       ; R1= -X(I+N4+N2)
||      STF  R0,#AR5               ; X(I+N2)= X(I)-X(I+N2)
        STF  R1,#AR5               ; X(I+N4+N2)= -X(I+N4+N2)

*
* INNERMOST  LOOP
*
        LDI  FFTSIZ,IR1
        LSH  -2,IR1                 ; IR1=SEPARATION BETWEEN SIN/COS TBLS
        LDI  R4,RC
        SUBI  2,RC                    ;REPEAT N4-1 TIMES

        RPTB  BLK3
        NPYF  #AR3,#+AR0(IR1),R0     ; R0=X(I3)#COS
        NPYF  #AR4,#AR0,R1           ; R1=X(I4)#SIN
        NPYF  #AR4,#+AR0(IR1),R1      ; R1=X(I4)#COS
||      ADDF  R0,R1,R2                ; R2=X(I3)#COS+X(I4)#SIN
        NPYF  #AR3,#AR0++(IR0),R0     ; R0=X(I3)#SIN
        SUBF  R0,R1,R0                 ; R0= -X(I3)#SIN+X(I4)#COS
        SUBF  #AR2,R0,R1              ; R1= -X(I2)+R0
        ADDF  #AR2,R0,R1              ; R1=X(I2)+R0
||      STF  R1,#AR3++                ; X(I3)= -X(I2)+R0
        ADDF  #AR1,R2,R1              ; R1=X(I1)+R2
||      STF  R1,#AR4--                 ; X(I4)=X(I2)+R0
        SUBF  R2,#AR1,R1              ; R1= X(I1)-R2
||      STF  R1,#AR1++                ; X(I1)=X(I1)+R2
BLK3    STF  R1,#AR2--                 ; X(I2)=X(I1)-R2

        SUBI1  INPUT , AR5
        ADDI  R4,AR5                  ; AR5=I+N1
        CNPI  FFTSIZ , AR5
        BLTD  INLOP                   ; LOOP BACK TO THE INNER LOOP
        ADDI  INPUT ,AR5
        NOP
        NOP

        ADDI  1, R5
        CNPI  LOGFFT , R5
        BLE  LOOP
        NOP
        NOP
        NOP
        NOP

END    BR       END               ;BRANCH TO ITSELF AT THE END
       .END