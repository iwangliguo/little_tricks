
;Example 2 - 21. Creation of a Sine Wave ASM Listing Based on TLU Using TMS320C54x

************************************************************************
* Sinewave generator:
* Copyright (C) 2001, Texas Instruments, Inc. All rights reserved.
* Francis Kua, Jun , 2001
*
* Table Size : 256.000000
*
************************************************************************
	
	.sect ¡±COSINE¡±
COSOFF:

.word 06ccbh ; Cos 0.000000 (Degree) = 1.000000
.word 06cc9h ; Cos 0.703125 (Degree) = 0.999925
.word 06cc3h ; Cos 1.406250 (Degree) = 0.999699
.word 06cb9h ; Cos 2.109375 (Degree) = 0.999322
.word 06caah ; Cos 2.812500 (Degree) = 0.998795
.word 06c97h ; Cos 3.515625 (Degree) = 0.998118
.word 06c80h ; Cos 4.218750 (Degree) = 0.997290
.word 06c65h ; Cos 4.921875 (Degree) = 0.996313
.word 06c45h ; Cos 5.625000 (Degree) = 0.995185
.word 06c22h ; Cos 6.328125 (Degree) = 0.993907
.word 06bfah ; Cos 7.031250 (Degree) = 0.992480
.word 06bceh ; Cos 7.734375 (Degree) = 0.990903
.word 06b9eh ; Cos 8.437500 (Degree) = 0.989177
.word 06b6ah ; Cos 9.140625 (Degree) = 0.987301
.word 06b31h ; Cos 9.843750 (Degree) = 0.985278
.word 06af5h ; Cos 10.546875 (Degree) = 0.983105
.word 06ab4h ; Cos 11.250000 (Degree) = 0.980785
.word 06a70h ; Cos 11.953125 (Degree) = 0.978317
.word 06a27h ; Cos 12.656250 (Degree) = 0.975702
.word 069dah ; Cos 13.359375 (Degree) = 0.972940
.word 06989h ; Cos 14.062500 (Degree) = 0.970031
.word 06934h ; Cos 14.765625 (Degree) = 0.966976
.word 068dbh ; Cos 15.468750 (Degree) = 0.963776
.word 0687dh ; Cos 16.171875 (Degree) = 0.960431
.word 0681ch ; Cos 16.875000 (Degree) = 0.956940
.word 067b7h ; Cos 17.578125 (Degree) = 0.953306
.word 0674eh ; Cos 18.281250 (Degree) = 0.949528
.word 066e1h ; Cos 18.984375 (Degree) = 0.945607
.word 0666fh ; Cos 19.687500 (Degree) = 0.941544
.word 065fah ; Cos 20.390625 (Degree) = 0.937339
.word 06581h ; Cos 21.093750 (Degree) = 0.932993
.word 06504h ; Cos 21.796875 (Degree) = 0.928506
.word 06483h ; Cos 22.500000 (Degree) = 0.923880
.word 063ffh ; Cos 23.203125 (Degree) = 0.919114
.word 06376h ; Cos 23.906250 (Degree) = 0.914210
.word 062eah ; Cos 24.609375 (Degree) = 0.909168
.word 06259h ; Cos 25.312500 (Degree) = 0.903989
.word 061c5h ; Cos 26.015625 (Degree) = 0.898674
.word 0612eh ; Cos 26.718750 (Degree) = 0.893224
.word 06092h ; Cos 27.421875 (Degree) = 0.887640
.word 05ff3h ; Cos 28.125000 (Degree) = 0.881921
.word 05f50h ; Cos 28.828125 (Degree) = 0.876070
.word 05ea9h ; Cos 29.531250 (Degree) = 0.870087
.word 05dffh ; Cos 30.234375 (Degree) = 0.863973
.word 05d51h ; Cos 30.937500 (Degree) = 0.857729
.word 05c9fh ; Cos 31.640625 (Degree) = 0.851355
.word 05beah ; Cos 32.343750 (Degree) = 0.844854
.word 05b32h ; Cos 33.046875 (Degree) = 0.838225
.word 05a76h ; Cos 33.750000 (Degree) = 0.831470
.word 059b6h ; Cos 34.453125 (Degree) = 0.824589
.word 058f3h ; Cos 35.156250 (Degree) = 0.817585
.word 0582ch ; Cos 35.859375 (Degree) = 0.810457
.word 05762h ; Cos 36.562500 (Degree) = 0.803208
.word 05695h ; Cos 37.265625 (Degree) = 0.795837
.word 055c4h ; Cos 37.968750 (Degree) = 0.788346
.word 054f1h ; Cos 38.671875 (Degree) = 0.780737
.word 05419h ; Cos 39.375000 (Degree) = 0.773010
.word 0533fh ; Cos 40.078125 (Degree) = 0.765167
.word 05261h ; Cos 40.781250 (Degree) = 0.757209
.word 05180h ; Cos 41.484375 (Degree) = 0.749136
.word 0509ch ; Cos 42.187500 (Degree) = 0.740951
.word 04fb5h ; Cos 42.890625 (Degree) = 0.732654
.word 04ecbh ; Cos 43.593750 (Degree) = 0.724247
.word 04ddeh ; Cos 44.296875 (Degree) = 0.715731
.word 04ceeh ; Cos 45.000000 (Degree) = 0.707107
.word 04bfbh ; Cos 45.703125 (Degree) = 0.698376
.word 04b05h ; Cos 46.406250 (Degree) = 0.689541
.word 04a0ch ; Cos 47.109375 (Degree) = 0.680601
.word 04910h ; Cos 47.812500 (Degree) = 0.671559
.word 04811h ; Cos 48.515625 (Degree) = 0.662416
.word 04710h ; Cos 49.218750 (Degree) = 0.653173
.word 0460bh ; Cos 49.921875 (Degree) = 0.643832
.word 04505h ; Cos 50.625000 (Degree) = 0.634393
.word 043fbh ; Cos 51.328125 (Degree) = 0.624859
.word 042efh ; Cos 52.031250 (Degree) = 0.615232
.word 041e0h ; Cos 52.734375 (Degree) = 0.605511
.word 040cfh ; Cos 53.437500 (Degree) = 0.595699
.word 03fbbh ; Cos 54.140625 (Degree) = 0.585798
.word 03ea5h ; Cos 54.843750 (Degree) = 0.575808
.word 03d8ch ; Cos 55.546875 (Degree) = 0.565732
.word 03c71h ; Cos 56.250000 (Degree) = 0.555570
.word 03b54h ; Cos 56.953125 (Degree) = 0.545325
.word 03a34h ; Cos 57.656250 (Degree) = 0.534998
.word 03912h ; Cos 58.359375 (Degree) = 0.524590
.word 037eeh ; Cos 59.062500 (Degree) = 0.514103
.word 036c8h ; Cos 59.765625 (Degree) = 0.503538
.word 035a0h ; Cos 60.468750 (Degree) = 0.492898
.word 03475h ; Cos 61.171875 (Degree) = 0.482184
.word 03349h ; Cos 61.875000 (Degree) = 0.471397
.word 0321ah ; Cos 62.578125 (Degree) = 0.460539
.word 030eah ; Cos 63.281250 (Degree) = 0.449611
.word 02fb8h ; Cos 63.984375 (Degree) = 0.438616
.word 02e84h ; Cos 64.687500 (Degree) = 0.427555
.word 02d4eh ; Cos 65.390625 (Degree) = 0.416430
.word 02c16h ; Cos 66.093750 (Degree) = 0.405241
.word 02addh ; Cos 66.796875 (Degree) = 0.393992
.word 029a2h ; Cos 67.500000 (Degree) = 0.382683
.word 02865h ; Cos 68.203125 (Degree) = 0.371317
.word 02727h ; Cos 68.906250 (Degree) = 0.359895
.word 025e8h ; Cos 69.609375 (Degree) = 0.348419
.word 024a7h ; Cos 70.312500 (Degree) = 0.336890
.word 02364h ; Cos 71.015625 (Degree) = 0.325310
.word 02220h ; Cos 71.718750 (Degree) = 0.313682
.word 020dbh ; Cos 72.421875 (Degree) = 0.302006
.word 01f94h ; Cos 73.125000 (Degree) = 0.290285
.word 01e4dh ; Cos 73.828125 (Degree) = 0.278520
.word 01d04h ; Cos 74.531250 (Degree) = 0.266713
.word 01bbah ; Cos 75.234375 (Degree) = 0.254866
.word 01a6fh ; Cos 75.937500 (Degree) = 0.242980
.word 01923h ; Cos 76.640625 (Degree) = 0.231058
.word 017d6h ; Cos 77.343750 (Degree) = 0.219101
.word 01688h ; Cos 78.046875 (Degree) = 0.207111
.word 01539h ; Cos 78.750000 (Degree) = 0.195090
.word 013eah ; Cos 79.453125 (Degree) = 0.183040
.word 01299h ; Cos 80.156250 (Degree) = 0.170962
.word 01148h ; Cos 80.859375 (Degree) = 0.158858
.word 0ff6h ; Cos 81.562500 (Degree) = 0.146730
.word 0ea4h ; Cos 82.265625 (Degree) = 0.134581
.word 0d51h ; Cos 82.968750 (Degree) = 0.122411
.word 0bfdh ; Cos 83.671875 (Degree) = 0.110222
.word 0aa9h ; Cos 84.375000 (Degree) = 0.098017
.word 0955h ; Cos 85.078125 (Degree) = 0.085797
.word 0800h ; Cos 85.781250 (Degree) = 0.073565
.word 06abh ; Cos 86.484375 (Degree) = 0.061321
.word 0556h ; Cos 87.187500 (Degree) = 0.049068
.word 0401h ; Cos 87.890625 (Degree) = 0.036807
.word 02abh ; Cos 88.593750 (Degree) = 0.024541
.word 0155h ; Cos 89.296875 (Degree) = 0.012272
.word 00h ; Cos 90.000000 (Degree) = 0.000000
.word 0feabh ; Cos 90.703125 (Degree) = -0.012272
.word 0fd55h ; Cos 91.406250 (Degree) = -0.024541
.word 0fbffh ; Cos 92.109375 (Degree) = -0.036807
.word 0faaah ; Cos 92.812500 (Degree) = -0.049068
.word 0f955h ; Cos 93.515625 (Degree) = -0.061321
.word 0f800h ; Cos 94.218750 (Degree) = -0.073565
.word 0f6abh ; Cos 94.921875 (Degree) = -0.085797
.word 0f557h ; Cos 95.625000 (Degree) = -0.098017
.word 0f403h ; Cos 96.328125 (Degree) = -0.110222
.word 0f2afh ; Cos 97.031250 (Degree) = -0.122411
.word 0f15ch ; Cos 97.734375 (Degree) = -0.134581
.word 0f00ah ; Cos 98.437500 (Degree) = -0.146730
.word 0eeb8h ; Cos 99.140625 (Degree) = -0.158858
.word 0ed67h ; Cos 99.843750 (Degree) = -0.170962
.word 0ec16h ; Cos 100.546875 (Degree) = -0.183040
.word 0eac7h ; Cos 101.250000 (Degree) = -0.195090
.word 0e978h ; Cos 101.953125 (Degree) = -0.207111
.word 0e82ah ; Cos 102.656250 (Degree) = -0.219101
.word 0e6ddh ; Cos 103.359375 (Degree) = -0.231058
.word 0e591h ; Cos 104.062500 (Degree) = -0.242980
.word 0e446h ; Cos 104.765625 (Degree) = -0.254866
.word 0e2fch ; Cos 105.468750 (Degree) = -0.266713
.word 0e1b3h ; Cos 106.171875 (Degree) = -0.278520
.word 0e06ch ; Cos 106.875000 (Degree) = -0.290285
.word 0df25h ; Cos 107.578125 (Degree) = -0.302006
.word 0dde0h ; Cos 108.281250 (Degree) = -0.313682
.word 0dc9ch ; Cos 108.984375 (Degree) = -0.325310
.word 0db59h ; Cos 109.687500 (Degree) = -0.336890
.word 0da18h ; Cos 110.390625 (Degree) = -0.348419
.word 0d8d9h ; Cos 111.093750 (Degree) = -0.359895
.word 0d79bh ; Cos 111.796875 (Degree) = -0.371317
.word 0d65eh ; Cos 112.500000 (Degree) = -0.382683
.word 0d523h ; Cos 113.203125 (Degree) = -0.393992
.word 0d3eah ; Cos 113.906250 (Degree) = -0.405241
.word 0d2b2h ; Cos 114.609375 (Degree) = -0.416430
.word 0d17ch ; Cos 115.312500 (Degree) = -0.427555
.word 0d048h ; Cos 116.015625 (Degree) = -0.438616
.word 0cf16h ; Cos 116.718750 (Degree) = -0.449611
.word 0cde6h ; Cos 117.421875 (Degree) = -0.460539
.word 0ccb7h ; Cos 118.125000 (Degree) = -0.471397
.word 0cb8bh ; Cos 118.828125 (Degree) = -0.482184
.word 0ca60h ; Cos 119.531250 (Degree) = -0.492898
.word 0c938h ; Cos 120.234375 (Degree) = -0.503538
.word 0c812h ; Cos 120.937500 (Degree) = -0.514103
.word 0c6eeh ; Cos 121.640625 (Degree) = -0.524590
.word 0c5cch ; Cos 122.343750 (Degree) = -0.534998
.word 0c4ach ; Cos 123.046875 (Degree) = -0.545325
.word 0c38fh ; Cos 123.750000 (Degree) = -0.555570
.word 0c274h ; Cos 124.453125 (Degree) = -0.565732
.word 0c15bh ; Cos 125.156250 (Degree) = -0.575808
.word 0c045h ; Cos 125.859375 (Degree) = -0.585798
.word 0bf31h ; Cos 126.562500 (Degree) = -0.595699
.word 0be20h ; Cos 127.265625 (Degree) = -0.605511
.word 0bd11h ; Cos 127.968750 (Degree) = -0.615232
.word 0bc05h ; Cos 128.671875 (Degree) = -0.624859
.word 0bafbh ; Cos 129.375000 (Degree) = -0.634393
.word 0b9f5h ; Cos 130.078125 (Degree) = -0.643832
.word 0b8f0h ; Cos 130.781250 (Degree) = -0.653173
.word 0b7efh ; Cos 131.484375 (Degree) = -0.662416
.word 0b6f0h ; Cos 132.187500 (Degree) = -0.671559
.word 0b5f4h ; Cos 132.890625 (Degree) = -0.680601
.word 0b4fbh ; Cos 133.593750 (Degree) = -0.689541
.word 0b405h ; Cos 134.296875 (Degree) = -0.698376
.word 0b312h ; Cos 135.000000 (Degree) = -0.707107
.word 0b222h ; Cos 135.703125 (Degree) = -0.715731
.word 0b135h ; Cos 136.406250 (Degree) = -0.724247
.word 0b04bh ; Cos 137.109375 (Degree) = -0.732654
.word 0af64h ; Cos 137.812500 (Degree) = -0.740951
.word 0ae80h ; Cos 138.515625 (Degree) = -0.749136
.word 0ad9fh ; Cos 139.218750 (Degree) = -0.757209
.word 0acc1h ; Cos 139.921875 (Degree) = -0.765167
.word 0abe7h ; Cos 140.625000 (Degree) = -0.773010
.word 0ab0fh ; Cos 141.328125 (Degree) = -0.780737
.word 0aa3ch ; Cos 142.031250 (Degree) = -0.788346
.word 0a96bh ; Cos 142.734375 (Degree) = -0.795837
.word 0a89eh ; Cos 143.437500 (Degree) = -0.803208
.word 0a7d4h ; Cos 144.140625 (Degree) = -0.810457
.word 0a70dh ; Cos 144.843750 (Degree) = -0.817585
.word 0a64ah ; Cos 145.546875 (Degree) = -0.824589
.word 0a58ah ; Cos 146.250000 (Degree) = -0.831470
.word 0a4ceh ; Cos 146.953125 (Degree) = -0.838225
.word 0a416h ; Cos 147.656250 (Degree) = -0.844854
.word 0a361h ; Cos 148.359375 (Degree) = -0.851355
.word 0a2afh ; Cos 149.062500 (Degree) = -0.857729
.word 0a201h ; Cos 149.765625 (Degree) = -0.863973
.word 0a157h ; Cos 150.468750 (Degree) = -0.870087
.word 0a0b0h ; Cos 151.171875 (Degree) = -0.876070
.word 0a00dh ; Cos 151.875000 (Degree) = -0.881921
.word 09f6eh ; Cos 152.578125 (Degree) = -0.887640
.word 09ed2h ; Cos 153.281250 (Degree) = -0.893224
.word 09e3bh ; Cos 153.984375 (Degree) = -0.898674
.word 09da7h ; Cos 154.687500 (Degree) = -0.903989
.word 09d16h ; Cos 155.390625 (Degree) = -0.909168
.word 09c8ah ; Cos 156.093750 (Degree) = -0.914210
.word 09c01h ; Cos 156.796875 (Degree) = -0.919114
.word 09b7dh ; Cos 157.500000 (Degree) = -0.923880
.word 09afch ; Cos 158.203125 (Degree) = -0.928506
.word 09a7fh ; Cos 158.906250 (Degree) = -0.932993
.word 09a06h ; Cos 159.609375 (Degree) = -0.937339
.word 09991h ; Cos 160.312500 (Degree) = -0.941544
.word 0991fh ; Cos 161.015625 (Degree) = -0.945607
.word 098b2h ; Cos 161.718750 (Degree) = -0.949528
.word 09849h ; Cos 162.421875 (Degree) = -0.953306
.word 097e4h ; Cos 163.125000 (Degree) = -0.956940
.word 09783h ; Cos 163.828125 (Degree) = -0.960431
.word 09725h ; Cos 164.531250 (Degree) = -0.963776
.word 096cch ; Cos 165.234375 (Degree) = -0.966976
.word 09677h ; Cos 165.937500 (Degree) = -0.970031
.word 09626h ; Cos 166.640625 (Degree) = -0.972940
.word 095d9h ; Cos 167.343750 (Degree) = -0.975702
.word 09590h ; Cos 168.046875 (Degree) = -0.978317
.word 0954ch ; Cos 168.750000 (Degree) = -0.980785
.word 0950bh ; Cos 169.453125 (Degree) = -0.983105
.word 094cfh ; Cos 170.156250 (Degree) = -0.985278
.word 09496h ; Cos 170.859375 (Degree) = -0.987301
.word 09462h ; Cos 171.562500 (Degree) = -0.989177
.word 09432h ; Cos 172.265625 (Degree) = -0.990903
.word 09406h ; Cos 172.968750 (Degree) = -0.992480
.word 093deh ; Cos 173.671875 (Degree) = -0.993907
.word 093bbh ; Cos 174.375000 (Degree) = -0.995185
.word 0939bh ; Cos 175.078125 (Degree) = -0.996313
.word 09380h ; Cos 175.781250 (Degree) = -0.997290
.word 09369h ; Cos 176.484375 (Degree) = -0.998118
.word 09356h ; Cos 177.187500 (Degree) = -0.998795
.word 09347h ; Cos 177.890625 (Degree) = -0.999322
.word 0933dh ; Cos 178.593750 (Degree) = -0.999699
.word 09337h ; Cos 179.296875 (Degree) = -0.999925
.word 09335h ; Cos 180.000000 (Degree) = -1.000000


***************************************************
* SineWave Generator
***************************************************

***********************************************************
* freq = 2*Desired F/Fs *(32768)
* F = Desired Frequency
* Fs = Sampling Frequency = 44100hz in this case
*********************************************************

FREQ1000 .set 1486
FREQ1750 .set 2600
FREQ2000 .set 2972
FREQ3000 .set 4458
FRAME_SIZE .set 64

	.mmregs
	.include ¡±cos256_tbl.inc¡±
	.global COSINE_BUFFER
	.global FREQ_BUFFER

	.bss TEMP,1
	.bss FREQ_BUFFER,128
	.bss COSINE_BUFFER,257
	.bss _FREQ_STEP,1
	.bss _INIT_PHASE,1

	.def FREQ
STK 	.usect ¡±STACK¡±,100

	.mmregs

.sect ¡±CODE¡±
FREQ:	SSBX OVM
	SSBX SXM
	SSBX FRCT
	NOP
	NOP
	STM #STK+100H,SP
	STM #001EH,PMST
	ST #FREQ1000,*(_FREQ_STEP) ;
	ST #0,*(_INIT_PHASE) ;
	STM #FREQ_BUFFER,AR3 ;

	CALL COPY_COS_TBL ;
	CALL GEN_FREQ ;

LOOP: B LOOP ;

;**********************************************
; SINEWAVE GENERATOR ROUTINE
;**********************************************
GEN_FREQ:	
	STM #FRAME_SIZE-1,BRC 		;
	RPTB sine1-1
	LD *(_FREQ_STEP),A 		;
	ADD *(_INIT_PHASE),A 		; A=PRESENT PHASE
	STL A,*(_INIT_PHASE) 		; SAVE PRESENT PHASE
	SUB #4000H,A 			; SUB PI/2 FOR SINE
	ABS A 				; Acc CONTAINS THE OFFSET
	STL A,*(TEMP) 			;
					;
	LD *(TEMP),9,A 			;
	STH A,*(TEMP) 			;
	LD *(TEMP),A 			;
	ABS A 				;
	ADD #COSINE_BUFFER,A 		;
	STLM A,AR2 			;
	nop 				;
	nop 				;
	LD *AR2,A 			;
	STL A,*AR3+ 			;
					;
sine1: 	NOP 				;

	RET 				;

COPY_COS_TBL:
	STM #COSINE_BUFFER,AR2
	RPT #257-1

	MVPD #COSOFF,*AR2+
	RET