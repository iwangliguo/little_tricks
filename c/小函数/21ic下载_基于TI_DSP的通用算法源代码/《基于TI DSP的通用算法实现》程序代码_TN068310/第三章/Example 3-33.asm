
; Example 3 - 33. Extended Precision Multiplication ASM Listing

	.global _epmpy2

_epmpy2:
	mpyhslu	.m1x B,A,AlBh 		; Al u*s Bh
|| 	mpyhslu 	.m2x A,B,AhBl 		; Ah s*u Bl
	mpyu 		.m1x A,B,AlBl 		; Al u*u Bl
|| 	mpyh 		.m2x B,A,AhBh 		; Ah s*s Bh
	shr 		.s1 AlBh,16,AlBhH 	; AlBhH = AlBh >>s 16
|| 	shr 		.s2 AhBl,16,AhBlH 	; AhBlH = AhBl >>s 16
	b 			.s2 b3 ; return
	shl 		.s1 AlBh,16,AlBhL 	; AlBhL = AlBh << 16
|| 	shl 		.s2 AhBl,16,AhBlL 	; AhBlL = AhBl << 16
|| 	add 		.l2 AhBh,AhBlH,ABH 	; ABH = AhBl + AhBlH
	add 		.l2x ABH,AlBhH,ABH 	; ABH = ABH + AlBhH
|| 	addu 		.l1x AlBl,AhBlL,ABLo:ABLe 	
										; (long)ABL = AlBl + AhBlL
	addu 		.l1 AlBhL,ABLo:ABLe,ABLo:ABLe
										; (long)ABL = AlBhL + (long)ABL
	add 		.l1x ABLo,ABH,return 	; ABH = ABLhigh + ABH
	shl 		.s1 return, 1, return

