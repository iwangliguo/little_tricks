typedef struct _rmatrix {
	int        row;          /* ���� */
	int        col;          /* ���� */
	double    *data;         /* ������ */
}  RM, *RMP;   /* RM: ʵ�������ͣ�RMP: ʵ��������ָ��*/

typedef struct _cnumber                   
{
   double rpart;
   double ipart;
} CNUM, *CNUMP; /* CNUM:��������, CNUMP ��������ָ��*/                    

typedef struct _cmatrix {
	int        row;          /* ���� */
	int        col;          /* ���� */
	CNUMP      data;         /* ������ */
}  CM, *CMP;   /* CM: ���������ͣ�CMP: ����������ָ��*/

typedef struct _cmatrix2 {
	int        row;          /* ���� */
	int        col;          /* ���� */
	double    *rdata;        /* ʵ�������� */
	double    *idata;        /* �鲿������ */
}  CM2, *CMP2;   /* CM2: ���������ͣ�CMP2: ����������ָ��*/

typedef struct _tmatrix {
	int        row;           /* ���� */
	double    *tdata;         /* ������: T�����Ԫ�� t0, t1, ... tn  */
	double    *ttdata;        /* ������: 0, T�����Ԫ�� tt1, ... ttn */
}  TM, *TMP;    /* TM: �в����Ⱦ������ͣ�TMP: �в����Ⱦ�������ָ��*/

typedef struct _trimatrix {
	int        row;           /* ���� */
	double    *bdata;         /* ������: �Գ�����������Խ���Ԫ�� b0, b1, ... bn  */
	double    *cdata;         /* ������: �Գ�����������Խ���Ԫ�� c0, c1, ... cn-1 */
}  TRIM, *TRIMP;    /* TRIM: �Գ������������ͣ�TRIMP: �Գ�������������ָ��*/

typedef struct _tridiagonal {
	int         row;         /* ���� */
	double     *data;        /* ������: ���Խ���Ԫ�� */
} TDM, *TDMP; /* TDM: ���Խ��߾�������, TDMP: ���Խ��߾�������ָ�� */