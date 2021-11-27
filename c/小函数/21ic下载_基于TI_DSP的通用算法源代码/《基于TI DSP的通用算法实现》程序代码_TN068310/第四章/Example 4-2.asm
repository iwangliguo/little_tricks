
; Example 4 - 2. Fixed Point Biquad ASM Listing for the TMS320C2x DSP


biqd:						; kth biquad computation where k=1:k
;feedback section
	LT	  *-, AR3			; AR3��ak2, TREG=dk[n-2], AR4��dk[n-1]
	MPY	  *+, AR4			; AR4��dk[n-1], PREG=dk[n-2]*ak2,AR3��ak1
	LTA	  *+, AR3			; AR3��AK1, TREG=dk[N-1], AR4��dk[n-2]
						; ACC=in+dk[n-2]*ak2
MPY	  *+, AR4			; AR4��dk[n-2], PREG=dk[n-1]*ak1,AR3��bk2
LTA	  *-, AR0			; AR4��dk[n-1], ACC=in+dk[n-2]*ak2+d1[n-1]
						; *ak1=dk[n]
LPH	  *+				; AR4��dk[n-2], PREGH=dk[n-2]
SPH	  *-, AR0			; AR0=FP, AR4��dk[n-1], dk[n-2]=dk[n-1]
SACH *, (16-QFORMAT), AR3		
						; AR3��bl2, *FP=dk[n]
;feedforward section
LACL  #0					; ACC=0
MPY   *+, AR4				; AR4��dk[n-1], PREG=dk[n-2]*bk2,AR3��bk1
LTD   *, AR3				; AR3��bk1, TREG=dk[n-1], dk[n-2]=dk[n-1]
							; AR4��dk[n-1], ACC=dn[k-2]*bk2
MPY   *+, AR0				; AR0��dk[n], PREG=dk[n-1]*bk1,AR3��bk0
LTA	   *-, AR3				; ARP��AR4, AR3��bk0, TREG=dk[n]
							; ACC=dn[k-2]*bk2+dk[n-1]*bk1
APAC						; ACC=dn[k-2]*bk2+dk[n-1]*bk1+bk0*dk[n]
MPY   #1					; PREGL=dk[n]
SPL   *-, AR5				; ARP=AR5, AR4��dk+1[n-2], dk[n-1]=dk[n]
BANZ  biqd, *-, AR4		; for next k biquad

