
;Example 3 - 5. Butterfly Unit ASM Listing for TMS320F240


;****************************************************************
; MACRO: 'BFLY' general butterfly radix 2 for 320C2xx/5x			
; 
; version 1.00 from Manfred Christ update: 02. July 90 
; 
; THE MACRO 'BFLY' REQUIRES 18 WORDS AND 18 INSTRUCTIONS 
; 
; Definition: ARP -> AR2 (input) ARP -> AR2 (output) 
; 
; Definition: AR1 -> QR (input) AR1 -> QR+1 (output) 
; Definition: AR2 -> PR (input) AR2 -> PR+1 (output) 
; Definition: AR3 -> Cxxx (input) AR3 -> Cxxx+1 (output) --> WR=cosine
; Definition: AR4 -> Sxxx (input) AR4 -> Sxxx+1 (output) --> WI=sine
; Definition: AR5 -> temporary variable (unchanged) 
; 
; uses index register 
; 
; PR' = (PR+(QR*WR+QI*WI))/2 WR=COS(W) WI=SIN(W) 
; PI' = (PI+(QI*WR-QR*WI))/2 
; QR' = (PR-(QR*WR+QI*WI))/2 
; QI' = (PI-(QI*WR-QR*WI))/2 
; 
; Note: AR0 determines Twiddle Pointers (AR3 & AR4) step increments 
;****************************************************************

BFLY .macro p
									; (contents of register after exec.)
									; TREG	AR1	AR2	AR3	AR4	ARP
; 									--- --- --- 
	LT		*+, AR3 	;TREG:=QR             		   QR	PR  	QI   	C    	S   	3
	MPY		*, AR2 		;PREG:=QR*WR/2       		   QR   PR  	QI   	C    	S   	2
	LTP		*-, AR4 	;ACC:=QR*WR/2			   QI   PR  	QR   	C   	S   	4
	MPY		*, AR3 		;PREG:=QI*WI/2			   QI   PR	QR	C	S	3
	MPYA		*0+, AR2 	;ACC:=(QR*WR+QI*WI)/2 		   QR   PR  	QR  	C+n   	S   	2								;PREG:=QI*WR
	LT		*, AR5		;TREG=QR      			   QR   PR 	QR  	C+n   	S   	5
	SACH		*, 1, AR1 	;TEMP:=(QR*WR+QI*WI) 		   QR   PR  	QR  	C+n   	S   	1
	ADD		*, 15 		;ACC:=(PR+(QR*WR+QI*WI))/2	   QR   PR  	QR  	C+n   	S   	1
	SACH		*+, 0, AR5 	;PR:=(PR+(QR*WR+QI*WI))/2 	   QR   PI  	QR  	C+n   	S   	5
	SUB		*, 16, AR2 	;ACC:=(PR-(QR*WR+QI*WI))/2	   QR   PI  	QR  	C+n   	S   	2
	SACH		*+, 0, AR1 	;QR:=(PR-(QR*WR+QI*WI))/2	   QR   PI  	QI  	C+n   	S   	1
	LAC		*, 15, AR4 	ACC:=PI/PREG=QI*WR 		   QI   PI  	QI  	C+n   	S   	4
	MPYS 		*0+, AR2 	;PREG:=QR*WI/2 			   QI   PI  	QI  	C+n  	S+n  	2
 					; ACC := (PI-QI*WR)/2
	APAC 				;ACC:=(PI-(QI*WR-QR*WI))/2	   QI   PI  	QI 	C+n  	S+n  	2
	SACH		*+, 0, AR1 	;QI:=(PI-(QI*WR-QR*WI))/2	   QI   PI 	QR+1 	C+n 	S+n  	1
	NEG 				;ACC:=(-PI+(QI*WR-QR*WI))/2 	   QI   PI 	QR+1 	C+n 	S+n  	1
	ADD 		*, 16 		;ACC:=(PI+(QI*WR-QR*WI))/2	   QI   PI 	QR+1 	C+n 	S+n  	1
	SACH 		*+, 0, AR:p: 	;PI:=(PI+(QI*WR-QR*WI))/2	   QI 	PR+1 	QR+1 	C+n 	S+n  	2
.endm
