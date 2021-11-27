
;Example 2 - 20. Creation of a Sine Modulated PWM Signal ASM Listing Based on TLU Using TMS320F240

;*******************************************************************
; File Name: pwm1.asm
; Originator: Digital Control systems Apps group - Houston
; Target System: 'C240 Evaluation Board
;
; Description: Pulse Width Modulator - Sets up the registers
; for an asymmetric PWM output. The output is a
; square wave with a sine wave modulated duty cycle.
; PWM Period is 0.05ms => 20kHz
;
; Entering the command
; wa *FREQSTEP,,u
; Allows one to change the step size to change
; the frequency in the debugger environment
;
; Last Updated: 20 June 1997
;
;*******************************************************************

	.include f240regs.h

;-------------------------------------------------------------------
; Vector address declarations
;-------------------------------------------------------------------

	.sect ".vectors"

RSVECT		B START 	; Reset Vector
INT1 		B PHANTOM 	; Interrupt Level 1
INT2 		B SINE 		; Interrupt Level 2
INT3 		B PHANTOM 	; Interrupt Level 3
INT4 		B PHANTOM 	; Interrupt Level 4
INT5 		B PHANTOM 	; Interrupt Level 5
INT6 		B PHANTOM 	; Interrupt Level 6
RESERVED 	B PHANTOM 	; Reserved
SW_INT8 	B PHANTOM 	; User S/W Interrupt
SW_INT9 	B PHANTOM 	; User S/W Interrupt
SW_INT10 	B PHANTOM 	; User S/W Interrupt
SW_INT11 	B PHANTOM 	; User S/W Interrupt
SW_INT12 	B PHANTOM 	; User S/W Interrupt
SW_INT13 	B PHANTOM 	; User S/W Interrupt
SW_INT14 	B PHANTOM 	; User S/W Interrupt
SW_INT15 	B PHANTOM 	; User S/W Interrupt
SW_INT16 	B PHANTOM 	; User S/W Interrupt
TRAP 		B PHANTOM 	; Trap vector
NMINT 		B PHANTOM 	; Non-maskable Interrupt
EMU_TRAP 	B PHANTOM 	; Emulator Trap
SW_INT20 	B PHANTOM 	; User S/W Interrupt
SW_INT21 	B PHANTOM 	; User S/W Interrupt
SW_INT22	B PHANTOM 	; User S/W Interrupt
SW_INT23 	B PHANTOM 	; User S/W Interrupt

;===================================================================
; MAIN CODE - starts here
;===================================================================

	.text

	NOP
START: 	
	SETC INTM 		;Disable interrupts
	SPLK #0002h,IMR 	;Mask all core interrupts
				;except INT2

	LACC IFR 		;Read Interrupt flags
	SACL IFR 		;Clear all interrupt flags

	CLRC SXM 		;Clear Sign Extension Mode
	CLRC OVM 		;Reset Overflow Mode
	CLRC CNF 		;Config Block B0 to Data mem

;-----------------------------------
; Set up PLL Module
;-----------------------------------

	LDP #00E0h

;The following line is necessary if a previous program set the PLL
;to a different ;setting than the settings which the application
;uses. By disabling the PLL, the CKCR1 register can be modified so
;that the PLL can run at the new settings when it is re-enabled.

	SPLK #0000000001000001b,CKCR0 	;CLKMD=PLL Disable
					;SYSCLK=CPUCLK/2
; 		5432109876543210
	SPLK #0000000010111011b,CKCR1
					;CLKIN(OSC)=10MHz,CPUCLK=20MHz

; CKCR1 - Clock Control Register 1
; 	Bits 7-4 (1011) CKINF(3)-CKINF(0) - Crystal or Clock-In
; 				Frequency
; 				Frequency = 10MHz
; 	Bit 3 (1) PLLDIV(2) - PLL divide by 2 bit
; 				Divide PLL input by 2
;	 Bits 2-0 (011) PLLFB(2)-PLLFB(0) - PLL multiplication ratio
; 				PLL Multiplication Ration = 4

; 		5432109876543210
	SPLK #0000000011000001b,CKCR0 	;CLKMD=PLL Enable
					;SYSCLK=CPUCLK/2

;CKCR0 - Clock Control Register 0
; 	Bits 7-6 (11) CLKMD(1),CLKMD(0) - Operational mode of
; 			Clock Module
; 			PLL Enabled; Run on CLKIN on exiting low
; 			power mode
; Bits 5-4 (00) PLLOCK(1),PLLOCK(0) - PLL Status.
; 			READ ONLY
; Bits 3-2 (00) PLLPM(1),PLLPM(0) - Low Power Mode
;			 LPM0
; Bit 1 (0) ACLKENA - 1MHz ACLK Enable
; 			ACLK Disabled
; Bit 0 (1) PLLPS - System Clock Prescale Value
; 			f(sysclk)=f(cpuclk)/2

; 		5432109876543210
	SPLK #0100000011000000b,SYSCR ;CLKOUT=CPUCLK

;SYSCR - System Control Register
; Bit 15-14 (01) RESET1,RESET0 - Software Reset Bits
; 		No Action
; Bits 13-8 (000000) Reserved
; Bit 7-6 (11) CLKSRC1,CLKSRC0 - CLKOUT-Pin Source
;	 	Select
; 		CPUCLK: CPU clock output mode
; Bit 5-0 (000000)Reserved


	SPLK #006Fh, WDCR 	;Disable WD if VCCP=5V
				;(JP5 in pos. 2-3)
	KICK_DOG 		;Reset Watchdog

;-----------------------------------
; Set up Digital I/O Port
;-----------------------------------

	LDP #225 		;DP=225, Data Page to Configure OCRA
; 		5432109876543210
	SPLK #0011100000000000b,OCRA

;OCRA - Output Control Register A
; Bit 15 (0) CRA.15 - IOPB7
; Bit 14 (0) CRA.14 - IOPB6
; Bit 13 (1) CRA.13 - T3PWM/T3CMP
; Bit 12 (1) CRA.12 - T2PWM/T2CMP
; Bit 11 (1) CRA.11 - T1PWM/T1CMP
; Bit 10 (0) CRA.10 - IOPB2
; Bit 9  (0) CRA.9 - IOPB1
; Bit 8  (0) CRA.8 - IOPB0
; Bits 7-4 (0000) Reserved
; Bit 3 (0) CRA.3 - IOPA3
; Bit 2 (0) CRA.2 - IOPA2
; Bit 1 (0) CRA.1 - IOPA1
; Bit 0 (0) CRA.0 - IOPA0


;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;- Event Manager Module Reset
;*
SPRA411
16 Creating a Sine Modulated PWM Signal Using the TMS320F240 EVM
;- This section resets all of the Event Manager Module Registers.
;* This is necessary for silicon revision 1.1; however, for
;- silicon revisions 2.0 and later, this is not necessary
;*
;-
;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	LDP 	#232		;DP=232 Data Page for the Event Manager
	SPLK 	#0000h,GPTCON 	;Clear General Purpose Timer Control
	SPLK 	#0000h,T1CON 	;Clear GP Timer 1 Control
	SPLK 	#0000h,T2CON 	;Clear GP Timer 2 Control
	SPLK 	#0000h,T3CON 	;Clear GP Timer 3 Control
	SPLK 	#0000h,COMCON 	;Clear Compare Control
	SPLK 	#0000h,ACTR
			;Clear Full Compare Action Control Register
	SPLK 	#0000h,SACTR
			;Clear Simple Compare Action Control Register
	SPLK 	#0000h,DBTCON
			;Clear Dead-Band Timer Control Register

	SPLK #0000h,CAPCON 	;Clear Capture Control

	SPLK #0FFFFh,EVIFRA	;Clear Interrupt Flag Register A
	SPLK #0FFFFh,EVIFRB	;Clear Interrupt Flag Register B
	SPLK #0FFFFh,EVIFRC	;Clear Interrupt Flag Register C

	SPLK #0000h,EVIMRA 	;Clear Event Manager Mask Register A
	SPLK #0000h,EVIMRB 	;Clear Event Manager Mask Register B
	SPLK #0000h,EVIMRC 	;Clear Event Manager Mask Register C

;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;- End of RESET section for silicon revision 1.1 *
;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

;-----------------------------------
; Set up Event Manager Module
;-----------------------------------

T1COMPARE 	.set 0 		; T1Compare Initialized to 0
T1PERIOD 	.set 1000 	; T1Period Initialized to
				;1000 = 20kHz value

	.text

	LDP #232 		;DP=232, Data Page for
				;Event Manager Addresses

	SPLK #T1COMPARE,T1CMPR;T1CMPR = 0

		; 2109876543210
	SPLK #0000001010101b,GPTCON

;GPTCON - GP Timer Control Register
; Bit 15 (0) T3STAT - GP Timer 3 Status. READ ONLY
; Bit 14 (0) T2STAT - GP Timer 2 Status. READ ONLY
; Bit 13 (0) T1STAT - GP Timer 1 Status. READ ONLY
; Bits 12-11 (00) T3TOADC - ADC start by event of GP Timer 3
; 	No event starts ADC
; Bits 10-9 (00) T2TOADC - ADC start by event of GP Timer 2
; 	No event starts ADC
; Bits 8-7 (00) T1TOADC - ADC start by event of GP Timer 1
; 	No event starts ADC
; Bit 6 (1) TCOMPOE - Compare output enable
; 	Enable all three GP timer compare outputs
; Bits 5-4 (01) T3PIN - Polarity of GP Timer 3 compare
; 	output
; 	Active Low
; Bits 3-2 (01) T2PIN - Polarity of GP Timer 2 compare
; 	output
; 	Active Low
; Bits 1-0 (01) T1PIN - Polarity of GP Timer 1 compare
; 	output
; 	Active Low

	SPLK #T1PERIOD,T1PR 	; T1PR = 1000
	SPLK #0000h,T1CNT 	; Initialize Timer 1
	SPLK #0000h,T2CNT 	; Initialize Timer 2
	SPLK #0000h,T3CNT 	; Initialize Timer 3

		; 5432109876543210
	SPLK #0001000000000110b,T1CON

;T1CON - GP Timer 1 Control Register
; Bits 15-14 (00) FREE,SOFT - Emulation Control Bits
; 	Stop immediately on emulation suspend
; Bits 13-11 (010) TMODE2-TMODE0 - Count Mode Selection
; 	Continuous-Up Count Mode
; Bits 10-8 (000) TPS2-TPS0 - Input Clock Prescaler
; 	Divide by 1
; Bit 7 (0) Reserved
; Bit 6 (0) TENABLE - Timer Enable
; 	Disable timer operations
; Bits 5-4 (00) TCLKS1,TCLKS0 - Clock Source Select
; 	Internal Clock Source
; Bits 3-2 (01) TCLD1,TCLD0 - Timer Compare Register
; 	Reload Condition
; 	When counter is 0 or equals period
; 	register value
; Bit 1 (1) TECMPR - Timer compare enable
; 	Enable timer compare operation
; Bit 0 (0) Reserved
	
; 		5432109876543210
	SPLK #0000000000000000b,T2CON ;Not used

;T2CON - GP Timer 2 Control Register
; Bits 15-14 (00) FREE,SOFT - Emulation Control Bits
; 	Stop immediately on emulation suspend
; Bits 13-11 (000) TMODE2-TMODE0 - Count Mode Selection
; 	Stop/Hold
; Bits 10-8 (000) TPS2-TPS0 - Input Clock Prescaler
; 	Divide by 1
; Bit 7 (0) TSWT1 - GP Timer 1 timer enable bit
; 	Use own TENABLE bit
; Bit 6 (0) TENABLE - Timer Enable
; 	Disable timer operations
; Bits 5-4 (00) TCLKS1,TCLKS0 - Clock Source Select
; 	Internal Clock Source
; Bits 3-2 (00) TCLD1,TCLD0 - Timer Compare Register
; 	Reload Condition When counter is 0
; Bit 1 (0) TECMPR - Timer compare enable
; 	Disable timer compare operation
; Bit 0 (0) SELT1PR - Period Register select
; 	Use own period register

; 		5432109876543210
	SPLK #0000000000000000b,T3CON ;Not Used

;T3CON - GP Timer 3 Control Register
; Bits 15-14 (00) FREE,SOFT - Emulation Control Bits
; 	Stop immediately on emulation suspend
; Bits 13-11 (000) TMODE2-TMODE0 - Count Mode Selection
; 	Stop/Hold
; Bits 10-8 (000) TPS2-TPS0 - Input Clock Prescaler
; 	Divide by 1
; Bit 7 (0) TSWT1 - GP Timer 1 timer enable bit
; 	Use own TENABLE bit
; Bit 6 (0) TENABLE - Timer Enable
; 	Disable timer operations
; Bits 5-4 (00) TCLKS1,TCLKS0 - Clock Source Select
; 	Internal Clock Source
; Bits 3-2 (00) TCLD1,TCLD0 - Timer Compare Register
; 	Reload Condition When counter is 0
; Bit 1 (0) TECMPR - Timer compare enable
; 	Disable timer compare operation
; Bit 0 (0) SELT1PR - Period Register select
; 	Use own period register

	SBIT1 T1CON,B6_MSK 	;Sets Bit 6 of T1CON

;T1CON - GP Timer 1 Control Register
; Bit 6 (1) TENABLE - Timer Enable
;	 Enable Timer Operations

	SPLK #0FFFFh,EVIFRA 	;Clear all pending interrupts
	SPLK #0080h,EVIMRA 	;Enable Timer 1 Period Interrupt

;-----------------------------------
; Generate Sine Wave Modulated PWM
;-----------------------------------

	.bss TABLE,1 		;Keeps address of the pointer in
				;the SINE Table
	.bss TOPTABLE,1 	;Keeps the reset value for the
				;pointer
	.bss COMPARET1,1 	;A register to do calculations
				;since the
				;T1CMPR register is double
				;buffered
	.bss FREQSTEP,1 	;Frequency modulation of the sine
				;wave
	.bss MODREG,1 		;Rolling Modulo Register
	.bss SINEVAL,1 		;Value from look up table

NORMAL 	.set 500

	.text

	LDP 	#0 ;DP = 0
	SPLK 	#0000h,TABLE 		;Initialize Pointer to Top
	SPLK 	#STABLE,TOPTABLE 	;Initialize TOPTABLE to
					; address of sine table
	SPLK 	#4,FREQSTEP 		;Set the step size to 4
	SPLK 	#0000h,MODREG 		;Initialize the 16 bit
					; counter register
	CLRC 	INTM 			;Enable interrupts
END 	B 	END 			;End of Program

;-------------------------------------------------------------------
; Generate PWM Sine Wave ISR
;-------------------------------------------------------------------

	SINE 	LDP #0 		; DP = 0
	LACC 	MODREG 		; ACC = 16 bit Counter Register
	ADD 	FREQSTEP 	; ACC = Counter + Step
	SACL 	MODREG 		; Counter assigned new value
	LACC 	MODREG,8 	; ACC = Counter shifted to left
				; by 8
	SACH 	TABLE 		; TABLE = upper byte of
				; counter = pointer
	LACC 	TABLE 		; ACC = TABLE = Pointer
	ADD 	TOPTABLE 	; Offset Addr from top of table
	TBLR 	SINEVAL 	; Read sine value and store to
				; SINEVAL

;Normalization of the Sine value to prevent the compare value from
; being negative

	LT 	SINEVAL 	; TREG = SINEVAL (Q15)
	MPY 	#NORMAL 	; PREG = TREG * NORMAL (Q30)
				; NORMAL = T/2
	PAC 			; ACC = PREG (Q30)
	SACH 	COMPARET1,1	; COMPARET1 = PREG (Q15)
	LACC 	COMPARET1 	; ACC = COMPARET1
	ADD 	#NORMAL 	; ACC = COMPARET1 + NORMAL
	LDP 	#232 		; DP = 232
	SACL 	T1CMPR 		; T1CMPR = ACC = Normalize Sine
				; Value
				;Clear the interrupt flags of the Event Manager Module
	LACC 	EVIFRA 		; ACC = EVIFRA
	SACL 	EVIFRA 		; EVIFRA = ACC; resets the

; interrupt flag

	CLRC 	INTM 		; Enable core interrupts
	RET 			; Return to end of program

;-------------------------------------------------------------------
; Sine look-up table
; No. Entries : 256
; Angle Range : 360 deg
; Number format : Q15 with range -1 < N < +1
;-------------------------------------------------------------------

;SINVAL 		; Index Angle Sin(Angle)

STABLE 	.word 0 	; 0 0 0.0000
	.word 804 	; 1 1.41 0.0245
	.word 1608 	; 2 2.81 0.0491
	.word 2410 ; 3 4.22 0.0736
	.word 3212 ; 4 5.63 0.0980
	.word 4011 ; 5 7.03 0.1224
	.word 4808 ; 6 8.44 0.1467
	.word 5602 ; 7 9.84 0.1710
	.word 6393 ; 8 11.25 0.1951
	.word 7179 ; 9 12.66 0.2191
	.word 7962 ; 10 14.06 0.2430
	.word 8739 ; 11 15.47 0.2667
	.word 9512 ; 12 16.88 0.2903
	.word 10278 ; 13 18.28 0.3137
	.word 11039 ; 14 19.69 0.3369
	.word 11793 ; 15 21.09 0.3599
	.word 12539 ; 16 22.50 0.3827
	.word 13279 ; 17 23.91 0.4052
	.word 14010 ; 18 25.31 0.4276
	.word 14732 ; 19 26.72 0.4496
	.word 15446 ; 20 28.13 0.4714
	.word 16151 ; 21 29.53 0.4929
	.word 16846 ; 22 30.94 0.5141
	.word 17530 ; 23 32.34 0.5350
	.word 18204 ; 24 33.75 0.5556
	.word 18868 ; 25 35.16 0.5758
	.word 19519 ; 26 36.56 0.5957
	.word 20159 ; 27 37.97 0.6152
	.word 20787 ; 28 39.38 0.6344
	.word 21403 ; 29 40.78 0.6532
	.word 22005 ; 30 42.19 0.6716
	.word 22594 ; 31 43.59 0.6895
	.word 23170 ; 32 45.00 0.7071
	.word 23731 ; 33 46.41 0.7242
	.word 24279 ; 34 47.81 0.7410
	.word 24811 ; 35 49.22 0.7572
	.word 25329 ; 36 50.63 0.7730
	.word 25832 ; 37 52.03 0.7883
	.word 26319 ; 38 53.44 0.8032
	.word 26790 ; 39 54.84 0.8176
	.word 27245 ; 40 56.25 0.8315
	.word 27683 ; 41 57.66 0.8449
	.word 28105 ; 42 59.06 0.8577
	.word 28510 ; 43 60.47 0.8701
	.word 28898 ; 44 61.88 0.8819
	.word 29268 ; 45 63.28 0.8932
	.word 29621 ; 46 64.69 0.9040
	.word 29956 ; 47 66.09 0.9142
	.word 30273 ; 48 67.50 0.9239
	.word 30571 ; 49 68.91 0.9330
	.word 30852 ; 50 70.31 0.9415
	.word 31113 ; 51 71.72 0.9495
	.word 31356 ; 52 73.13 0.9569
	.word 31580 ; 53 74.53 0.9638
	.word 31785 ; 54 75.94 0.9700
	.word 31971 ; 55 77.34 0.9757
	.word 32137 ; 56 78.75 0.9808
	.word 32285 ; 57 80.16 0.9853
	.word 32412 ; 58 81.56 0.9892
	.word 32521 ; 59 82.97 0.9925
	.word 32609 ; 60 84.38 0.9952
	.word 32678 ; 61 85.78 0.9973
	.word 32728 ; 62 87.19 0.9988
	.word 32757 ; 63 88.59 0.9997
	.word 32767 ; 64 90.00 1.0000
	.word 32757 ; 65 91.41 0.9997
	.word 32728 ; 66 92.81 0.9988
	.word 32678 ; 67 94.22 0.9973
	.word 32609 ; 68 95.63 0.9952
	.word 32521 ; 69 97.03 0.9925
	.word 32412 ; 70 98.44 0.9892
	.word 32285 ; 71 99.84 0.9853
	.word 32137 ; 72 101.25 0.9808
	.word 31971 ; 73 102.66 0.9757
	.word 31785 ; 74 104.06 0.9700
	.word 31580 ; 75 105.47 0.9638
	.word 31356 ; 76 106.88 0.9569
	.word 31113 ; 77 108.28 0.9495
	.word 30852 ; 78 109.69 0.9415
	.word 30571 ; 79 111.09 0.9330
	.word 30273 ; 80 112.50 0.9239
	.word 29956 ; 81 113.91 0.9142
	.word 29621 ; 82 115.31 0.9040
	.word 29268 ; 83 116.72 0.8932
	.word 28898 ; 84 118.13 0.8819
	.word 28510 ; 85 119.53 0.8701
	.word 28105 ; 86 120.94 0.8577
	.word 27683 ; 87 122.34 0.8449
	.word 27245 ; 88 123.75 0.8315
	.word 26790 ; 89 125.16 0.8176
	.word 26319 ; 90 126.56 0.8032
	.word 25832 ; 91 127.97 0.7883
	.word 25329 ; 92 129.38 0.7730
	.word 24811 ; 93 130.78 0.7572
	.word 24279 ; 94 132.19 0.7410
	.word 23731 ; 95 133.59 0.7242
	.word 23170 ; 96 135.00 0.7071
	.word 22594 ; 97 136.41 0.6895
	.word 22005 ; 98 137.81 0.6716
	.word 21403 ; 99 139.22 0.6532
	.word 20787 ; 100 140.63 0.6344
	.word 20159 ; 101 142.03 0.6152
	.word 19519 ; 102 143.44 0.5957
	.word 18868 ; 103 144.84 0.5758
	.word 18204 ; 104 146.25 0.5556
	.word 17530 ; 105 147.66 0.5350
	.word 16846 ; 106 149.06 0.5141
	.word 16151 ; 107 150.47 0.4929
	.word 15446 ; 108 151.88 0.4714
	.word 14732 ; 109 153.28 0.4496
	.word 14010 ; 110 154.69 0.4276
	.word 13279 ; 111 156.09 0.4052
	.word 12539 ; 112 157.50 0.3827
	.word 11793 ; 113 158.91 0.3599
	.word 11039 ; 114 160.31 0.3369
	.word 10278 ; 115 161.72 0.3137
	.word 9512 ; 116 163.13 0.2903
	.word 8739 ; 117 164.53 0.2667
	.word 7962 ; 118 165.94 0.2430
	.word 7179 ; 119 167.34 0.2191
	.word 6393 ; 120 168.75 0.1951
	.word 5602 ; 121 170.16 0.1710
	.word 4808 ; 122 171.56 0.1467
	.word 4011 ; 123 172.97 0.1224
	.word 3212 ; 124 174.38 0.0980
	.word 2410 ; 125 175.78 0.0736
	.word 1608 ; 126 177.19 0.0491
	.word 804 ; 127 178.59 0.0245
	.word 0 ; 128 180.00 0.0000
	.word 64731 ; 129 181.41 -0.0245
	.word 63927 ; 130 182.81 -0.0491
	.word 63125 ; 131 184.22 -0.0736
	.word 62323 ; 132 185.63 -0.0980
	.word 61524 ; 133 187.03 -0.1224
	.word 60727 ; 134 188.44 -0.1467
	.word 59933 ; 135 189.84 -0.1710
	.word 59142 ; 136 191.25 -0.1951
	.word 58356 ; 137 192.66 -0.2191
	.word 57573 ; 138 194.06 -0.2430
	.word 56796 ; 139 195.47 -0.2667
	.word 56023 ; 140 196.88 -0.2903
	.word 55257 ; 141 198.28 -0.3137
	.word 54496 ; 142 199.69 -0.3369
	.word 53742 ; 143 201.09 -0.3599
	.word 52996 ; 144 202.50 -0.3827
	.word 52256 ; 145 203.91 -0.4052
	.word 51525 ; 146 205.31 -0.4276
	.word 50803 ; 147 206.72 -0.4496
	.word 50089 ; 148 208.13 -0.4714
	.word 49384 ; 149 209.53 -0.4929
	.word 48689 ; 150 210.94 -0.5141
	.word 48005 ; 151 212.34 -0.5350
	.word 47331 ; 152 213.75 -0.5556
	.word 46667 ; 153 215.16 -0.5758
	.word 46016 ; 154 216.56 -0.5957
	.word 45376 ; 155 217.97 -0.6152
	.word 44748 ; 156 219.38 -0.6344
	.word 44132 ; 157 220.78 -0.6532
	.word 43530 ; 158 222.19 -0.6716
	.word 42941 ; 159 223.59 -0.6895
	.word 42365 ; 160 225.00 -0.7071
	.word 41804 ; 161 226.41 -0.7242
	.word 41256 ; 162 227.81 -0.7410
	.word 40724 ; 163 229.22 -0.7572
	.word 40206 ; 164 230.63 -0.7730
	.word 39703 ; 165 232.03 -0.7883
	.word 39216 ; 166 233.44 -0.8032
	.word 38745 ; 167 234.84 -0.8176
	.word 38290 ; 168 236.25 -0.8315
	.word 37852 ; 169 237.66 -0.8449
	.word 37430 ; 170 239.06 -0.8577
	.word 37025 ; 171 240.47 -0.8701
	.word 36637 ; 172 241.88 -0.8819
	.word 36267 ; 173 243.28 -0.8932
	.word 35914 ; 174 244.69 -0.9040
	.word 35579 ; 175 246.09 -0.9142
	.word 35262 ; 176 247.50 -0.9239
	.word 34964 ; 177 248.91 -0.9330
	.word 34683 ; 178 250.31 -0.9415
	.word 34422 ; 179 251.72 -0.9495
	.word 34179 ; 180 253.13 -0.9569
	.word 33955 ; 181 254.53 -0.9638
	.word 33750 ; 182 255.94 -0.9700
	.word 33564 ; 183 257.34 -0.9757
	.word 33398 ; 184 258.75 -0.9808
	.word 33250 ; 185 260.16 -0.9853
	.word 33123 ; 186 261.56 -0.9892
	.word 33014 ; 187 262.97 -0.9925
	.word 32926 ; 188 264.38 -0.9952
	.word 32857 ; 189 265.78 -0.9973
	.word 32807 ; 190 267.19 -0.9988
	.word 32778 ; 191 268.59 -0.9997
	.word 32768 ; 192 270.00 -1.0000
	.word 32778 ; 193 271.41 -0.9997
	.word 32807 ; 194 272.81 -0.9988
	.word 32857 ; 195 274.22 -0.9973
	.word 32926 ; 196 275.63 -0.9952
	.word 33014 ; 197 277.03 -0.9925
	.word 33123 ; 198 278.44 -0.9892
	.word 33250 ; 199 279.84 -0.9853
	.word 33398 ; 200 281.25 -0.9808
	.word 33564 ; 201 282.66 -0.9757
	.word 33750 ; 202 284.06 -0.9700
	.word 33955 ; 203 285.47 -0.9638
	.word 34179 ; 204 286.88 -0.9569
	.word 34422 ; 205 288.28 -0.9495
	.word 34683 ; 206 289.69 -0.9415
	.word 34964 ; 207 291.09 -0.9330
	.word 35262 ; 208 292.50 -0.9239
	.word 35579 ; 209 293.91 -0.9142
	.word 35914 ; 210 295.31 -0.9040
	.word 36267 ; 211 296.72 -0.8932
	.word 36637 ; 212 298.13 -0.8819
	.word 37025 ; 213 299.53 -0.8701
	.word 37430 ; 214 300.94 -0.8577
	.word 37852 ; 215 302.34 -0.8449
	.word 38290 ; 216 303.75 -0.8315
	.word 38745 ; 217 305.16 -0.8176
	.word 39216 ; 218 306.56 -0.8032
	.word 39703 ; 219 307.97 -0.7883
	.word 40206 ; 220 309.38 -0.7730
	.word 40724 ; 221 310.78 -0.7572
	.word 41256 ; 222 312.19 -0.7410
	.word 41804 ; 223 313.59 -0.7242
	.word 42365 ; 224 315.00 -0.7071
	.word 42941 ; 225 316.41 -0.6895
	.word 43530 ; 226 317.81 -0.6716
	.word 44132 ; 227 319.22 -0.6532
	.word 44748 ; 228 320.63 -0.6344
	.word 45376 ; 229 322.03 -0.6152
	.word 46016 ; 230 323.44 -0.5957
	.word 46667 ; 231 324.84 -0.5758
	.word 47331 ; 232 326.25 -0.5556
	.word 48005 ; 233 327.66 -0.5350
	.word 48689 ; 234 329.06 -0.5141
	.word 49384 ; 235 330.47 -0.4929
	.word 50089 ; 236 331.88 -0.4714
	.word 50803 ; 237 333.28 -0.4496
	.word 51525 ; 238 334.69 -0.4276
	.word 52256 ; 239 336.09 -0.4052
	.word 52996 ; 240 337.50 -0.3827
	.word 53742 ; 241 338.91 -0.3599
	.word 54496 ; 242 340.31 -0.3369
	.word 55257 ; 243 341.72 -0.3137
	.word 56023 ; 244 343.13 -0.2903
	.word 56796 ; 245 344.53 -0.2667
	.word 57573 ; 246 345.94 -0.2430
	.word 58356 ; 247 347.34 -0.2191
	.word 59142 ; 248 348.75 -0.1951
	.word 59933 ; 249 350.16 -0.1710
	.word 60727 ; 250 351.56 -0.1467
	.word 61524 ; 251 352.97 -0.1224
	.word 62323 ; 252 354.38 -0.0980
	.word 63125 ; 253 355.78 -0.0736
	.word 63927 ; 254 357.19 -0.0491
	.word 64731 ; 255 358.59 -0.0245
	.word 65535 ; 256 360.00 0.0000

;===================================================================
; I S R - PHANTOM
;
; Description: Dummy ISR, used to trap spurious interrupts.
;
; Modifies: Nothing
;
; Last Update: 16 June 95
;===================================================================

	PHANTOM KICK_DOG 		;Resets WD counter
	B 	PHANTOM
