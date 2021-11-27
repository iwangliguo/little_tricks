
; Example 3 - 31. Extended Precision Multiplication C Listing Shifting before Addition

int epmpy(int A, int B)
{
	short AH, BH;
	unsigned short AL, BL;
	int ahbl, albh, ahbh;
	AH = A>>16; AL = A & 0xFFFF;
	BH = B>>16; BL = B & 0xFFFF;
	ahbh = (AB*BH)<<1;
	albh = (AL*BH)>>15;
	ahbl = (AH*BL)>>15;
	return ahbh+(albh+ahbl);
}

