
;Example 2 - 24. Creation of a Sine Wave C Listing Based on Oscillator Using TMS320C62x


short output;
main()
{
	int i;
	const short A=0x7e66;			/* A=(1.975/2 * 32768) */
	short y[3]={0,0x1209,0};		/* (y0,y1,y2), y1=(0.1409*32768) */
	for (i=0; i<40; i++) 
	{
		y[0] = (((A*y[1])>>15) + ((A*y[1])>>15)) 每 y[2];
		y[2] = y[1];				/* y2 <每每 y1 */
		y[1] = y[0];				/* y1 <每每 y0 */
		output = y[0];
	}
}
