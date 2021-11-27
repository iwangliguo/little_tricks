
;Example 2 - 23. Creation of a Sine Wave ASM Listing Based on Oscillator Using TMS320C62x


	.def init
int	.equ 4
half	.equ 2

	.data
a_half	.short	32768*1975/2000
y1	.short	32768*1409/10000
y2	.short	0
	.bss	output,40*half,half
	.bss	buffer,2*half,2*half

	.text
init:
	MVK	.S1 a_half, A0
	MVKH	.S1 a_half, A0
	LDH	.D1 *A0, A2		; load coeff A_HALF
	MVK	.S1 0x0001, A0		; setup circular buf AMR=0001_0001h
	MVKLH	.S1 0x0001, A0		; setup circular buf AMR=0001_0001h
	MVC	.S2X A0, AMR		; blk size is 4 bytes, pointer is A4
	MVK	.S1 output, A3		; memory for store sine wave
	MVKH	.S1 output, A3
	MVK	.S1 0, A0
	STH	.D1 A0, *A3++		; output y(0)=0 to IOPORT
	MVK	.S1 buffer, A4
	MVKH	.S1 buffer, A4
	MVK	.S1 y1, A0
	MVKH	.S1 y1, A0
	LDH	.D1 *A0++, A1		; load y1
	NOP	 4
	STH	.D1 A1, *A4++		; y(n每1)=y1, point to y(n每2)
	STH	.D1 A1, *A3++		; output y(1)=y1 to IOPORT
	LDH	.D1 *A0, A1		; load y2
	NOP 4
	STH	.D1 A1, *A4++		; y(n每2)=y2, point to y(n每1)

main:	MVK	.S1 40, A1		; calculate 40 samples

loop:	LDH	.D1 *A4++, B1		; ld y(n每1) to B1, point to y(n每2)
	LDH	.D1 *A4, B2		; ld y(n每2) to B2, point to y(n每2)
	NOP 3				; <每每 try optimizing here
	SMPY	.M1X A2, B1, A0		; A_HALF*y(n每1)
	SUB	.L1 A1, 1, A1
 [A1]	B	.S1 loop
	SHR	.S1 A0, 16, A0		; <每每 try optimizing here
	SADD	.L1 A0, A0, A0		; A_HALF*y(n每1)*2
	SSUB	.L2X A0, B2, B0		; A_HALF*y(n每1)*2每y(n每2)
	STH	.D1 B0, *A4		; st y(n) to y(n每2) as y(n每1)
	STH	.D1 B0, *A3++		; st y(n) to Sine wave IOPORT
end:	B	.S1 $

		NOP 5
