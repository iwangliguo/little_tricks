
/* Example 2 - 2. Unsigned Fixed-Point Division C Subroutine for C6x */


/********************************************************************/
/*    num --- numerator����������,   den --- denominator��������    */
/********************************************************************/

unsigned int udiv(unsigned int num, unsigned int den)
{
    int i, shift;

    if (den > num) return (0);
    if (num == 0)  return (0);
    if (den == 0)  return (�C1);
    shift = _lmbd(1, den) �C _lmbd(1, num);
    den <<= shift; 				/* �����ĸ */
    for (i=0; i<=shift; i++)
        num = _subc(num, den);
    return (num << (32�C(shift+1))) >> (32�C(shift+1));
                                   		/* �洢�� */
}
