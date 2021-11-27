
; Example 3 - 43. FHT ASM Listing for the TMS320C3x DSP

* GENERIC PROGRAM TO DO A RADIX-2 HARTLEY TRANSFORM ON THE TMS320C30
* THE PROGRAM IS TAKEN FORM THE PAPER BY SOREMSEM ET AL., OCT 1985 ISSUE
* OF THE TRANSACTIONS ON ASSP.
*
* THE (REAL) DATA RESIDE IN INTERNAL MEMORY. THE COMPUTATION IS DONE IN-PLACE. THE BIT-REVERSAL IS DONE AT THE * * BEGINNING OF THE PROGRAM.
*
* THE TWIDDLE FACTORS ARE SUPPLIED IN A TABLE PUT IN A .DATA SECTION. THIS
* DATA IS INCLUDED IN A SEPARATE FILE TO PRESERVE THE GENERIC NATURE OF THE 
* PROGRAM. FOR THE SAME PURPOSE, THE SIZE OF THE FHT N AND LOG2(N) ARE 
* DEFINED IN A .GLOBL DIRECTIVE AND SPECIFIED DURING LINKING. THE LENGTH OF 
* THE TABLE IS N/4 + N/4 = N/2.
*                                       
* AUTHOR: PANOS PAPAMICHALIS               DECEMBER 14, 1988
*         TEXAS INSTRUMENTS
*
             .GLOBL          FHT           ; ENTRY POINT FOR EXECUTION
             .GLOBL          N             ; FHT SIZE
             .GLOBL          M             ; LOG2(N)
             .GLOBL          SINE          ; ADDRESS OF SINE TABLE
*
             .BSS            INP, 1024     ; MEMORY WITH INPUT DATA
*
             .TEXT
*
*      INITIALIZE
*
             .WORD           FHT           ; STARTING LOCATION OF THE PROGRAM
*
             .SPACE          100           ; RESERVE 100 WORDS FOR VECTORS, ETC.
*
FHTSIZ       .WORD           N
LOGFHT       .WORD           M
SINTAB       .WORD           SINE
INPUT        .WORD           INP
*
FHT:         LDP             FHTSIZ        ; COMMAND TO LOAD DATA PAGE POINTER
*
*       DO THE BIT REVERSING AT THE BEGINNING
*
             LDI             @FHTSIZ, RC   ; RC=N
             SUBI            1, RC         ; RC SHOULD BE ONE LESS THAN DESIRED
             LDI             @FHTSIZ, IR0
             LSH             -1, IRO       ; IRO=HALF THE SIZE OF FHT=N/2
             LDI             @INPUT, AR0
             LDI             @INPUT, AR1
*
             RPTB            BITRV
             CMPI            AR1, AR0      ; XCHANGE LOCATIONS ONLY
             BGE             CONT          ; IF AR0<AR1
             LDF             *AR0, R0
||           LDF             *AR1, R1
             STF             R0, *AR1
||           STF             R1, *AR0
CONT         NOP             *AR0++
BITRV        NOP             *AR1++(IR0)B
*
*     LENGTH-TWO BUTTERFILES
*
             LDI             @INPUT, AR0   ; AR0 POINTS TO X(I)
             LDI             IR0, RC       ; REPEAT N/2 TIMES
             SUBI            1, RC         ; RC SHOULD BE ONE LESS THAN DESIRED
*
             RPTB            BLK1
             ADDF            *+AR0,*AR0++,R0; R0=X(I)+X(I+1)
             SUBF            *AR0,*-AR0,R1 ;  R1=X(I)-X(I+1)
BLK1         STF             R0,*-AR0      ;  X(I)=X(I)+X(I+1)
||           STF             R1, *AR0++    ;  X(I+1)=X(I)-X(I+1)
*
*   FIRST PASS OF THE DO-30 LOOP (STAGE K=2 IN DO-20 LOOP)
*
             LDI             @INPUT, AR0   ;  AR0 POINTS TO X(J)
             LDI             2, IR0        ;  IR0=2=N2
             LDI             @FHTSIZ, RC 
             LSH             -2, RC        ;  REPEAT N/4 TIMES
             SUBI            1, RC         ;  RC SHOULD BE ONE LESS THAN DESIRED
*
             RPTB            BLK2
             ADDF            *+AR0(IR0),*AR0++(IR0),R0   ;  R0=X(J)+X(L2)
             SUBF            *AR0,*-AR0(IR0),R1          ;  R1=X(J)-X(L2)
             STF             R0,*-AR0(IR0)               ;  X(J)=X(J)+X(L2)
||           LDF             *+AR0,R0                    ;  R0=X(L4)
             ADDF            R0,*-AR0,R1                 ;  R1=X(L3)+X(L4)
||           STF             R1,*AR0++                   ;  X(L2)=X(J)-X(L2)
             SUBF            R0,*-AR0(IR0),R1            ;  R1=X(L3)-X(L4)
||           STF             R1,*-AR0(IR0)               ;  X(L3)=X(L3)+X(L4)
BLK2         STF             R1,*AR0++                   ;  X(L4)=X(L3)-X(L4)
*
*    MAIN LOOP (FHT STAGES)
*
             LDI             @FHTSIZ,IR0
             LSH             -2,IR0        ; IR0=INDEX FOR E
             LDI             3,R5          ; R5 HOLDS THE CURRENT STAGE NUMBER
             LDI             1,R4          ; R4=N4
             LDI             2,R3          ; R3=R2
LOOP         LSH             -1,IR0        ; E=E/2
             LSH             1,R4          ; N4=2*N4
             LSH             1,R3          ; N2=2*N2
*
*    INNER LOOP (DO-30 LOOP IN THE PROGRAM)
*
             LDI             @INPUT,AR5    ; AR5 POINTS TO X(J)
INLOP        LDI             IR0,AR0
             ADDI            @SINTAB,AR0   ; AR0 POINTS TO SIN/COS TABLE
             LDI             R4,IR1        ; IR1=N4
*
             LDI             AR5,AR1
             ADDI            1,AR1         ; AR1 POINTS TO X(L1)=X(J+I-1)
             LDI             AR1,AR3
             ADDI            R3,AR3        ; AR3 POINTS TO X(L3)=X(L1+N2)
             LDI             AR3,AR2
             SUBI            2,AR2         ; AR2 POINTS TO X(L2)=X(J-I+1+N2)
             ADDI            R3,AR2,AR4    ; AR4 POINTS TO X(L4)=X(L2+N2)
*
             LDF             *AR5++(IR1),R0       ; R0=X(J)
             ADDF            *+AR5(IR1),R0,R1     ; R1=X(J)+X(L2)
             SUBF            R0,*++AR5(IR1),R0    ; R0=-X(J)+X(L2)
||           STF             R1,*-AR5(IR1)        ; X(J)=X(J)+X(L2)
             NEGF            R0                   ; R0=X(J)-X(L2)
             STF             R0,*AR5              ; X(L2)=X(J)-X(L2)
||           LDF             *+AR5(IR1),R0        ; R0=X(L4)
             ADDF            R0,*-AR5(IR1),R1     ; R1=X(L3)+X(L4)
             SUBF            R0,*-AR5(IR1),R1     ; R1=X(L3)-X(L4)
||           STF             R1,*-AR5(IR1)        ; X(L3)=X(L3)+X(L4)
             STF             R1,*+AR5(IR1)        ; X(L4)=X(L3)-X(L4)
*
*         INNERMOST LOOP
*
             LDI             @FHTSIZ,IR1
             LSH             -2,IR1               ; IR1=SEPARATION BETWEEN SIN/COS TBLS
             LDI             R4,RC
             SUBI            2,RC                 ; REPEAT N4-1 TIMES
*
             RPTB            BLK3
             MPYF            *AR3,*+AR0(IR1),R0   ; R0=X(L3)*COS
             MPYF            *AR4,*+AR0,R1        ; R1=X(L4)*SIN
             MPYF            *AR4,*+AR0(IR1),R1   ; R1=X(L4)*COS
||           ADDF            R0,R1,R2             ; R2=X(L3)*COS+X(L4)*SIN=T1
             MPYF            *AR3,*AR0++(IR0),R0  ; R0=X(L3)*SIN
             SUBF            R1,R0,R0             ; R0=X(L3)*SIN-X(I4)*COS=T2
             SUBF            R0,*AR2,R1           ; R1=X(L2)-T2
             ADDF            *AR2,R0,R1           ; R1=X(L2)+T2
||           STF             R1,*AR4--            ; X(L4)=X(L2)-T2
             ADDF            *AR1,R2,R1           ; R1=X(L1)+T1
||           STF             R1,*AR2--            ; X(L2)=X(L2)+T2
             SUBF            R2,*AR1,R1           ; R1=X(L1)-T1
||           STF             R1,*AR1++            ; X(L1)=X(L1)+T1
BLK3         STF             R1,*AR3++            ; X(L3)=X(L1)-T1
*
             SUBI            @INPUT,AR5
             ADDI            R3,AR5               ; AR5=I+N1
             CMPI            @FHTSIZ,AR5
             BLTD            INLOP                ; LOOP BACK TO THE INNER LOOP
             ADDI            @INPUT,AR5
             NOP
             NOP
*
             ADDI            1,R5
             CMPI            @LOGFHT,R5
             BLE             LOOP
*
END          BR              END                  ; BRANCH TO ITSELF AT THE END
             .END
          