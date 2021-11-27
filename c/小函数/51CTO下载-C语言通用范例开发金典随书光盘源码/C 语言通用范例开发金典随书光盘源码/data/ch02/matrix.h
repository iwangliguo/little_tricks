typedef struct _rmatrix {
	int        row;          /* 行数 */
	int        col;          /* 列数 */
	double    *data;         /* 数据区 */
}  RM, *RMP;   /* RM: 实矩阵类型，RMP: 实矩阵类型指针*/

typedef struct _cnumber                   
{
   double rpart;
   double ipart;
} CNUM, *CNUMP; /* CNUM:复数类型, CNUMP 复数类型指针*/                    

typedef struct _cmatrix {
	int        row;          /* 行数 */
	int        col;          /* 列数 */
	CNUMP      data;         /* 数据区 */
}  CM, *CMP;   /* CM: 复矩阵类型，CMP: 复矩阵类型指针*/

typedef struct _cmatrix2 {
	int        row;          /* 行数 */
	int        col;          /* 列数 */
	double    *rdata;        /* 实部数据区 */
	double    *idata;        /* 虚部数据区 */
}  CM2, *CMP2;   /* CM2: 复矩阵类型，CMP2: 复矩阵类型指针*/

typedef struct _tmatrix {
	int        row;           /* 阶数 */
	double    *tdata;         /* 数据区: T型阵的元素 t0, t1, ... tn  */
	double    *ttdata;        /* 数据区: 0, T型阵的元素 tt1, ... ttn */
}  TM, *TMP;    /* TM: 托伯利兹矩阵类型，TMP: 托伯利兹矩阵类型指针*/

typedef struct _trimatrix {
	int        row;           /* 阶数 */
	double    *bdata;         /* 数据区: 对称三角阵的主对角线元素 b0, b1, ... bn  */
	double    *cdata;         /* 数据区: 对称三角阵的主对角线元素 c0, c1, ... cn-1 */
}  TRIM, *TRIMP;    /* TRIM: 对称三角阵阵类型，TRIMP: 对称三角阵阵类型指针*/

typedef struct _tridiagonal {
	int         row;         /* 阶数 */
	double     *data;        /* 数据区: 三对角线元素 */
} TDM, *TDMP; /* TDM: 三对角线矩阵类型, TDMP: 三对角线矩阵类型指针 */