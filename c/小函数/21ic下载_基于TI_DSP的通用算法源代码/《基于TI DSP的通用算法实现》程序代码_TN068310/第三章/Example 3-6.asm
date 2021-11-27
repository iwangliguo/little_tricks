
;Example 3 - 6. Combined Stage1 and Stage2 ASM Listing for TMS320F240

;****************************************************************
; *
; MACRO 'COMBO' 
; 
; R1 := [(R1+R2)+(R3+R4)]/4 INPUT                 OUTPUT 
; R2 := [(R1-R2)+(I3-I4)]/4 ------------------ ------------------ 
; R3 := [(R1+R2)-(R3+R4)]/4 AR0 = 7 
; R4 := [(R1-R2)-(I3-I4)]/4 AR1 -> R1,		    I1 AR1 - > R5,I5 
; I1 := [(I1+I2)+(I3+I4)]/4 AR2 -> R2,		    I2 AR2 - > R6,I6 
; I2 := [(I1-I2)-(R3-R4)]/4 ARP -> AR3 -> R3,I3 ARP - > AR3 - > R7,I7 
; I3 := [(I1+I2)-(I3+I4)]/4 AR4 -> R4,I4        AR4 - > R8,I8 
; I4 := [(I1-I2)+(R3-R4)]/4 ; 
; *
;****************************************************************

; 									ARP	AR1	AR2	AR3	AR4	AR5
COMBO .macro 							; --- --- --- --- --- ---
	LACC	*,14,AR4 		; ACC := (R3)/4 		4    	R1  	R2   	R3  	R4  	T1
	SUB	*,14,AR5 		; ACC := (R3+R4)/ 4     	5    	R1  	R2   	R3  	R4  	T1
	SACH	*+,1,AR4 		; T1 = (R3-R4)/2		4 	R1  	R2   	I3  	R4  	T2
	ADD	*+,15,AR5 		; ACC := (R3+R4)/4 		5    	R1  	R2   	R3  	I4  	T2
	SACH 	*,1,AR2 		; T2 = (R3+R4)/2       		2    	R1  	R2   	R3  	I4  	T2
	ADD 	*,14,AR1 		; ACC := (R2+R3+R4)/4  		1    	R1  	R2   	R3  	I4  	T2
	ADD 	*,14 			; ACC:=(R1+R2+R3+R4)/4 		1    	R1  	R2   	R3  	I4  	T2
	SACH 	*+,0,AR5 		; R1:=(R1+R2+R3+R4)/4 		5    	I1  	R2   	R3  	I4  	T2
	SUB 	*,16,AR3 		;ACC:=(R1+R2-(R3+R4))/4		3    	I1  	R2   	R3  	I4  	T2
	SACH 	*+,0,AR5 		; R3:=(R1+R2-(R3+R4))/4 	5    	I1  	R2   	R3  	I4  	T2
	ADD 	*,15,AR2 		; ACC := (R1+R2)/4    		2    	I1  	R2   	I3  	I4  	T2
	SUB 	*,15,AR3 		; ACC := (R1-R2)/4 		3    	I1  	R2   	I3  	I4  	T2
	ADD 	*,14,AR4 		;ACC:=((R1-R2)+(I3))/4 		4    	I1  	R2   	I3  	I4  	T2
	SUB 	*,14,AR2		; 				2    	I1  	R2   	I3  	I4  	T2
					;ACC:=((R1-R2)+(I3-I4))/4		
	SACH 	*+,0,AR4		;R2:=((R1-R2)+(I3-I4))/4 	4    	I1  	I2   	I3  	I4  	T2
	ADD 	*-,15,AR3 		; 				3    	I1  	I2   	I3  	R4  	T2
					;ACC:=((R1-R2)+ I3+I4 )/4
	SUB 	*,15,AR4  ; 						4    	I1  	I2   	I3  	R4  	T2
					;ACC:=((R1-R2)-(I3-I4))/4 	
	SACH 	*+,0,AR1 		; 				1    	I1  	I2   	I3  	I4  	T2
					; R4 := ((R1-R2)-(I3-I4))/4 
	LACC 	*,14,AR2 		; ACC := (I1)/4 		2    	I1  	I2   	I3  	I4  	T2
	SUB 	*,14,AR5 		; ACC := (I1-I2)/4 		5    	I1  	I2   	I3  	I4  	T2
	SACH 	*,1,AR2 		; T2 := (I1-I2)/2 		2    	I1  	I2   	I3  	I4  	T2
	ADD 	*,15,AR3 		; ACC := ((I1+I2))/4 		4    	I1  	I2   	I3  	I4  	T2
	ADD 	*,14,AR4 		; 				4    	I1  	I2   	I3  	I4  	T2
					; ACC := ((I1+I2)+(I3))/4 
	ADD 	*,14,AR1 		; 				1    	I1  	I2   	I3  	I4  	T2
					; ACC := ((I1+I2)+(I3+I4))/4 
	SACH 	*0+,0,AR3 		; 				3    	R5  	I2   	I3  	I4  	T2
					; I1 := ((I1+I2)+(I3+I4))/4 
	SUB 	*,15,AR4 		; 				4 	R5  	I2   	I3 	I4  	T2
					; ACC := ((I1+I2)-(I3+I4))/4 
	SUB 	*,15,AR3 		;				3    	R5  	I2   	I3  	I4  	T2
					; ACC := ((I1+I2)-(I3+I4))/4 
	SACH 	*0+,0,AR5 		; 				5    	R5  	I2   	R7  	I4  	T2
					; I3 := ((I1+I2)-(I3+I4))/4 
	LACC 	*-,15 			; ACC := (I1-I2)/4 		5    	R5  	I2   	R7  	I4  	T1
	SUB 	*,15,AR2 		;				2    	R5  	I2   	R7  	I4  	T1
					; ACC := ((I1-I2)-(R3-R4))/4 	
	SACH 	*0+,0,AR5 		; 				5 	R5  	R6  	R7  	I4  	T1
					; I2 := ((I1-I2)-(R3-R4))/4 
	ADD 	*,16,AR4 		; 				4    	R5  	R6   	R7  	I4  	T1
					; ACC := ((I1-I2)+(R3-R4))/4 
	SACH 	*0+,0,AR7		; 				7    	R5  	R6   	R7  	R8  	T1
					; I4 := ((I1-I2)+(R3-R4))/4 
.endm

