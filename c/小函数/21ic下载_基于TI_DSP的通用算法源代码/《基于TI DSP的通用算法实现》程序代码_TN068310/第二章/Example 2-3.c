
/* Example 2 - 3. Signed Fixed-Point Division C Subroutine for C6x */

/********************************************************************/
/*    num --- numerator（被除数）,   den --- denominator（除数）    */
/********************************************************************/

int sdiv(int num, int den)
{
    int i, shift, sign;

    sign = (num>>31) ^ (den>>31);	/* 确定结果的符号 */
    num = _abs(num);
    den = _abs(den);
    if (den > num) return (0);
    if (num == 0)  return (0);
    if (den == 0)  return (–1);
    shift = _lmbd(1, den) – _lmbd(1, num);
    den <<= shift;					/* 对齐分母 */
    for (i=0; i<=shift; i++)
        num = _subc(num, den);
    num = _extu(num, (32–(shift+1)), ((32–(shift+1)));
											/* 无符号除法的结果 */
    if (sign) return (–num);		/* 修正商的符号 */
    else return (num);
}
