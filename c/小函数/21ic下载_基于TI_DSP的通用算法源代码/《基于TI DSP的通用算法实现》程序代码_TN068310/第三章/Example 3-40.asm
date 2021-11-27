
; Example 3 - 40. Complex DIT Radix-2 FFT ASM Listing for the TMS320C3x DSP

* Appendix A1. Generic Program to Do a Looped-Code Radix-2 FFT Computation on the TMS320C30
* GENERIC PROGRAM TO DO A LOOPED-CODE RADIX-2 FFFT COMPUTATION ON THE TMS320C30.
* 
* THE PROGRAM IS TAKEN FROM THE BURRUS & PARKS BOOK, P. 111. THE (COMPLEX) DATA RESIDE IN INTERNAL MEMORY. THE COMPUTATION IS DONE IN-PLACE, BUT THE ADDRESSING. THE TWIDDLE FACTORS ARE SUPPLED IN A TABLE PUT IN A. DATASECTION. THIS DATAIS INCLUDED IN A SEPARATE FILE TO PRESERVE THE GENERIC LOG2(N) ARE DEFINED IN A. GLOBL DIRECTIVE AND SPECIFIED DUEING LINKING.
* 
* AUTHOR: PANOS E. PAPAMICHALIS
*          TEXAS INSTRUMENTS                 JULY 16, 1987
* 


     .GLOBL    FFT                             ; ENTRY POINT FOR EXECUTION
     .GLOBL    N                               ; FFT SIZE
     .GLOBL    M                               ; LOG2(N)
     .GLOBL    SINE                            ; ADDRESS OF SINE TABLE
INP  .USECT    ¡°IN¡±, 1024                        ; MEMORY WITH INPUT DATA
     .BSS       OUTP, 1024                       ; MEMORY WITH OUTPUT DATA

      .TEXT
* 
*    INITIALIZE
*       
	.WORD    FFT                   ; STARTING LOCATION OF THE PROGRAM

      	.SPACE     100                ; RESERVE 100 WORDS FOR VECTORS, ETC.

FFTSIZ	.WORD      N
LOGFFT	.WORD      M
SINTAB 	.WORD      SINE
INPUT  	.WORD     INP
OUTPUT 	.WORD     OUTP

FFT:       
	   LDP      FFTSIZ         ; COMMAND TO LOAD DATA PAGE POINTER

           LDI      @FFTSIZ, IR1
           LSH      -2, IR1           ; IR1=N/4, POINTER FOR SIN/COS TABLE
           LDI      0, AR6           ; AR6 HOLDS THE CURRENT STAGE NUMBER
           LDI      @FFTSIZ, IR0
           LSH      1, IR0           ; IR0=2#N1 (BECAUSE OF REAL/IMAG)
           LDI      @FFTSIZ, R7     ; R7=N2
           LDI      1, AR7         ; INITIALIZE REPEAT COUNTER OF FIRST LOOP

           LDI      1, AR5         ; INITIALIZE IE INDEX (AR5=IE)
* 
* OUTER LOOP
* 

LOOP:    NOP        #++AR6(1)                 ; CURRENT FFT STAGE
          LDI        @INPUT, AR0               ; AR0 POINTS TO X(I)
          ADDI       R7, AR0, AR2               ; AR2 POINTS TO X(L)
          LDI         AR7, RC
          SUBI        1, RC          ; RC SHOULD BE ONE LESS THAN DESXRED
*
* FIST LOOP:
* 
          RPTB       BLK1
          ADDF      #AR0, #AR2, R0              ; R0=X(I)+X(L)
          SUBF       #AR2++, #AR0++, R1         ; R1=X(I)-X(L)
          ADDF      #AR2, #AR0, R2              ; R2=Y(I)+Y(L)
          SUBF       #AR2, #AR0, R3             ; R3=Y(I)-Y(L)
          STF        R2, #AR0--                  ; Y(I)=R2  AND¡­
||        STF         R3, #AR2--                  ; Y(L)=R3
BLK1      STF         R0, #AR0++(IR0)            ; X(I)=R0  AND¡­
||        STF         R1, #AR2++(IR0)          ; X(L)=R1 AND AR0, 2=AR0, 2+2#N1

*
* IF THIS IS THE LAST STAGE, YOU ARE DONE
*

          CMPI        @LOGFFT, AR6
          BZD         END
*
* MAIN INNER LOOP
*

          LDI          2, AR1            ; INIT LOOP COUNTER FOR INNER LOOP
          LDI          @SINTAB, AR4     ; INITIALIZE IA INDEX (AR4=IA)
INLOP:    ADDI        AR5, AR4          ; IA=IA+IE; AR4 POINTS TO COSINE
          LDI           AR1, AR0
          ADDI         2, AR1            ; INCREMENT INNER LOOOP COUNTER
          ADDI         @INPUT, AR0      ; (X(I), Y(I)) POINTER
          ADDI         R7, AR0, AR2       ; (X(L), Y(L)) POINTER
          LDI           AR7, RC
          SUBI          1, RC         ; RC SHOULD BE ONE LESS THAN DESIRED
          LDF          #AR4, R6           ; R6=SIN
*
* SECOND LOOP
*
          RPTB         BLK2
          SUBF         #AR2, #AR0, R2        ; R2=X(I)-X(L)
          SUBF         #+AR2, @+AR0, R1      ; R1=Y(I)-Y(L)
          MPYF         R2, R6, R0             ; R0=R2#SIN AND¡­
||        ADDF         #+AR2, #+AR0, R3       ; R3=Y(I)+Y(L)
          MPYF         R1, #+AR4(IR1), R3      ; R3=R1#COS AND¡­
||        STF            R3, #+AR0             ; Y(I)=Y(I)+Y(L)
          SUBF          R0, R3, R4              ; R4=R1#COS-R2#SIN
          MPYF          R1, R6, R0             ; R0=R1#SIN AND¡­
||        ADDF          #AR2, #AR0, R3         ; R3=X(I)+X(L)
          MPYF          R2, #+AR4(IR1), R3      ; R3=R2#COS AND¡­
||        STF            R3, #AR0++(IR0)    ; X(I)=X(I)+X(L) AND AR0=AR0+2#N1
          ADDF          R0, R3, R5             ; R5=R2#COS+R1#SIN
BLK2      STF       R5, #AR2++(IR0)     ; X(L)=R2#COS+R1#SIN, INCR AR2 AND¡­
||        STF       R4, #+AR2                ; Y(L)=R1#COS-R2#SIN

          CMPI          R7, AR1
          BNE           INLOP               ; LOOP BACK TO THE INNER LOOP
          LSH        1, AR7       ; INCREMENT LOOP COUNTER FOR NEXT TIME

          LSH        1, AR5                  ; IE=2#IE
          LDI         R7, IR0                 ; N1=N2
          LSH         -1, R7                  ; N2=N2/2
          BR          LOOP                 ; NEXT FFT STAGE
*
* STORE RESULT OUT USING BIT-REVERSED ADDRESSING
*

END:      LDI           @FFTSIZ, RC              ; RC=N
          SUBI          1, RC        ; RC SHOULD BE ONE LESS THAN DESIRED
          LDI           @FFTSIZ, IR0           ; IR0=SIZE OF FFT=N
          LDI           2, IR1
          LDI           @INPUT, AR0
          LDI           @OUTPUT, AR1

          RPTB          BITRV
          LDF           #+AR0(1), R0
||        LDF           #AR0++(IR0)B, R1
BITRV     STF           R0, #+AR1(1)
||        STF           R1, #AR1++(IR1)

SELF      BR            SELF                ; BRANCH TO ITSELF AT THE END
         .END