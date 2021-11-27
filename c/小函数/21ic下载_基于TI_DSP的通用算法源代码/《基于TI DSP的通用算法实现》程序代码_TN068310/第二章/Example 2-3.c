
/* Example 2 - 3. Signed Fixed-Point Division C Subroutine for C6x */

/********************************************************************/
/*    num --- numerator����������,   den --- denominator��������    */
/********************************************************************/

int sdiv(int num, int den)
{
    int i, shift, sign;

    sign = (num>>31) ^ (den>>31);	/* ȷ������ķ��� */
    num = _abs(num);
    den = _abs(den);
    if (den > num) return (0);
    if (num == 0)  return (0);
    if (den == 0)  return (�C1);
    shift = _lmbd(1, den) �C _lmbd(1, num);
    den <<= shift;					/* �����ĸ */
    for (i=0; i<=shift; i++)
        num = _subc(num, den);
    num = _extu(num, (32�C(shift+1)), ((32�C(shift+1)));
											/* �޷��ų����Ľ�� */
    if (sign) return (�Cnum);		/* �����̵ķ��� */
    else return (num);
}
