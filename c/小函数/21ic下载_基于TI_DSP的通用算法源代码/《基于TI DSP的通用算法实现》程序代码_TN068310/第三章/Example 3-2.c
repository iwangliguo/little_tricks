
;Example 3 - 2. Bit Reversion for Float-Point Complex DIT Radix-2 FFT C Listing

/***************************************************************/
/*	bitRevData --- pointer to the index of bit reversion   */
/*	revLen      --- length of FFT			       */
/***************************************************************/

void bit_rev(struct complexData * bitRevData, int revLen)
{
	struct	complexData tempRev;
	int		iRev, jRev, kRev, halfLen;
                  
	halfLen = revLen >> 1; jRev = 0;
	for (iRev=0; iRev<(revLen-1); iRev++){
		if (iRev < jRev){
			tempRev = bitRevData[jRev];
			bitRevData[jRev] = bitRevData[iRev];
			bitRevData[iRev] = tempRev;
		}                  
		kRev = halfLen;               
		while (kRev <= jRev){
			jRev = jRev - kRev;
			kRev = kRev >> 1;
		}                   
		jRev=jRev+kRev;                               
	}       
}
