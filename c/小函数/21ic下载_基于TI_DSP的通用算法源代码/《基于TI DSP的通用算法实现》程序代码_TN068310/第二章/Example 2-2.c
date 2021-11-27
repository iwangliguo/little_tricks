
/* Example 2 - 2. Unsigned Fixed-Point Division C Subroutine for C6x */


/********************************************************************/
/*    num --- numerator（被除数）,   den --- denominator（除数）    */
/********************************************************************/

unsigned int udiv(unsigned int num, unsigned int den)
{
    int i, shift;

    if (den > num) return (0);
    if (num == 0)  return (0);
    if (den == 0)  return (–1);
    shift = _lmbd(1, den) – _lmbd(1, num);
    den <<= shift; 				/* 对齐分母 */
    for (i=0; i<=shift; i++)
        num = _subc(num, den);
    return (num << (32–(shift+1))) >> (32–(shift+1));
                                   		/* 存储商 */
}
