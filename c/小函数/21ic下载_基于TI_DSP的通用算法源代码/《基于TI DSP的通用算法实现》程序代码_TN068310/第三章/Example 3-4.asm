
;Example 3 - 4. Bit Reversion ASM Listing for TMS320F240

;================================================================
; Fetch 128 Data sample points from I/O port 0
;================================================================

FTCH_DATA 
	LAR		AR0, #128			; AR0 = 128
							; # of Samples for Bit Reversed Addressing
	LAR 	AR1, #B0_SADR	
							; AR1 = Start Address of B0; Data Buffer
	LAR 	AR2, #ADCFIFO1				; AR2 = Value Converted from ADC
	LAR 	AR3, #(B1_SADR+128) 
							; AR3 = B1_SADR + 128
	LAR 	AR7, #127 				; AR7 = 128 - 1
	MAR		*, AR2 				; ARP = AR2
	LDP 	#224 					; Set Bit 0 of ADCTRL1
	SBIT1 	ADCTRL1,B0_MSK 				; Starts ADC converting
	LDP 	#232 					; Set Bit 6 of T1CON
	SBIT1 	T1CON,B6_MSK 				; Starts the GP Timer 1
	CLR		CSXM 				; Disable sign extension mode
							; while reading in data from ADC
FTCH_LP 
	EVIFR	A,BIT7 					; Polling routine to wait for
	BCND	FTCH_LP,NTC 				; T1PINT Flag to be Set
	LDP 	#224
	SBIT1 	ADCTRL1,B0_MSK 				; Restart the ADC
	LACC 	*, 15, AR3 				; ACC = ADCFIFO1; ARP = AR3
	SACH	*+, 0, AR1 				; Value at location pointed by AR3
							; = Value pointed to by AR2; ARP = AR1
	SACH	*BR0+, 0, AR7 				; Store sample into data buffer of B0 using
							; bit reversed addressing; ARP = AR7
	LDP 	#232
	LACC	EVIFRA 					; ACC = Event Manager Interrupt Flag Register
	SACL	EVIFRA 					; Clear the flag register
	BANZ	FTCH_LP,*-,AR2 				; Wait for next flag of T1PINT, or if 128
							; samples have been collected, perform FFT
							; ARP = AR2
	SBIT0 	T1CON,B6_MSK 				; Stop GP timer 1 - for FFT
	SPLK	#0000h,T1CNT 				; Clear GP timer 1 counter
	SET		CSXM 				; Enable sign extension mode

