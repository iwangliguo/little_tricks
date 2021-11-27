typedef struct _inte 
{
	int       n;     /*  节点个数 */
	double   *x;     /*  给定的n个节点 */ 
	double   *y;     /*  对应于n个节点的函数值 */
	double    t;     /*  插值点 */
} INTE, *INTEP;

/* Hermite */
typedef struct _hinte 
{
	int       n;     /*  节点个数 */
	double   *x;     /*  给定的n个节点 */ 
	double   *y;     /*  对应于n个节点的函数值 */
	double   *dy;    /*  对应于n个节点的一阶倒数值 */
	double    t;     /*  插值点 */
} HINTE, *HINTEP;

/* Aitken */
typedef struct _ainte 
{
	int       n;     /*  节点个数 */
	double   *x;     /*  给定的n个节点 */ 
	double   *y;     /*  对应于n个节点的函数值 */
	double    t;     /*  插值点 */
	double    eps;   /*  插值精度控制 */
} AINTE, *AINTEP;

/* Akima */
typedef struct _akinte 
{
	int       n;     /*  节点个数 */
	double   *x;     /*  给定的n个节点 */ 
	double   *y;     /*  对应于n个节点的函数值 */
	int       k;
	double    t;     /*  插值点 */
	double    s[5];
} AKINTE, *AKINTEP;

/* 第一、二、三种边界条件的三次样条函数插值、微商与积分 */
typedef struct _csinte 
{
	int       n;     /*  节点个数 */
	double   *x;     /*  给定的n个节点 */ 
	double   *y;
	double   *dy;
	double   *ddy;
	int       m;     /*  插值点个数 */
	double   *t;     /*  插值点 */
	double   *z;
	double   *dz;
	double   *ddz;
} CSINTE, *CSINTEP;

/* 二元三点/全区间插值 */
typedef struct _pinte 
{
	int       n;   /* X 方向坐标数 */
	int       m;   /* Y 方向坐标数 */
	double   *x;   /* X 方向的n个坐标 */
	double   *y;   /* Y 方向的m个坐标 */
	double   *z;   /* n x m 个函数值  */
	double    u;   /* 插值点 X 坐标   */
	double    v;   /* 插值点 Y 坐标   */
}  PINTE, *PINTEP;

/* 最小二乘曲线拟合 */
typedef struct _linte 
{
	int       n;     /*  节点个数 */
	double   *x;     /*  数据点的 X 坐标 */ 
	double   *y;     /*  数据点的 Y 坐标 */ 
	int       m;     /*  拟合多项式项数 */
	double   *coe;   /*  拟合多项式系数*/
	double   *dt;
} LINTE, *LINTEP;

/* 切比雪夫曲线拟合 */
typedef struct _chinte 
{
	int       n;     /*  节点个数 */
	double   *x;     /*  数据点的 X 坐标 */ 
	double   *y;     /*  数据点的 Y 坐标 */ 
	int       m;     /*  拟合多项式项数 */
	double   *coe;   /*  拟合多项式系数*/
} CHINTE, *CHINTEP;

/* 最佳一致逼近的里米兹方法 */
typedef struct _rinte 
{
	int       n;     /*  n-1次最佳一致逼近多项式的项数，即最佳一致逼近多项式的最高次为n-1。
	                     要求n≤20。若n＞20，则本函数自动取n=20。*/
	double   *coe;   /*  前n个元素返回n-1次最佳一致逼近多项式的n个系数；
	                     最后一个元素coe [n]返回拟合多项式的偏差绝对值。 */ 
	double    a;     /*  区间左端点值 */ 
	double    b;     /*  区间右端点值 */ 
	double    eps;   /*  控制精度要求。一般在10-10～10-35之间。 */
	double  (*ptr)();/*  函数指针：指向计算函数 */
} RINTE, *RINTEP;

/* 矩形域的最小二乘曲面拟合方法 */
typedef struct _recinte 
{
	int       n;     /*  X坐标个数 */
	int       m;     /*  Y坐标个数 */
	double   *x;     /*  存放给定数据点的n个X坐标 */
	double   *y;     /*  存放给定数据点的m个Y坐标 */
	double   *z;     /*  存放矩形区域内n×m个网点上的函数值 */
	int       p;     /*  拟合多项式中x的最高次数加1。要求p≤n且p≤20，若不满足这个条件，本函数自动取p=min{n,20}。 */ 
	int       q;     /*  拟合多项式中y的最高次数加1。要求q≤m且q≤20，若不满足这个条件，本函数自动取q=min{m,20}。 */ 
	double   *a;     /*  回二元拟合多项式的各系数 */
	double   *dt;    /*  dt[0]返回拟合多项式与数据点误差的平方和；
					     dt[1]返回拟合多项式与数据点误差的绝对值之和；
	                     dt[2]返回拟合多项式与数据点误差绝对值的最大值。 */
} RECINTE, *RECINTEP;
