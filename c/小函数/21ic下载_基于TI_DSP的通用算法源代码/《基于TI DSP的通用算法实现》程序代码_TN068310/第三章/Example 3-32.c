
; Example 3 - 32. Extended Precision Multiplication C Listing

int epmpy2(int A, int B)
{
	int AhBh, AhBl, AlBh, AlBhH, AhBlH;
	unsigned int AlBl, AhBlL, AlBhL, ABLl;
	short Ah, Bh;
	unsigned short Al, Bl;
	long ABL;
	int ABLov, ABH; 
	Ah = A>>16; Al = A & 0x0000FFFF;
	Bh = B>>16; Bl = B & 0x0000FFFF;
	AhBh = Ah * Bh;
	AlBl = Al * Bl;
	AlBh = Al * Bh;
	AhBl = Ah * Bl;
	AhBlH = AhBl >> 16; AhBlL = AhBl << 16;
	AlBhH = AlBh >> 16; AlBhL = AlBh << 16;
	ABL = AlBl + AlBhL + AhBlL;
	ABLov = (int)(ABL >> 32);
	ABLl = (unsigned int)(ABL & 0xffffffff);
	ABH = AhBh + AhBlH + AlBhH + ABLov;
	return(ABH<<1);
}
