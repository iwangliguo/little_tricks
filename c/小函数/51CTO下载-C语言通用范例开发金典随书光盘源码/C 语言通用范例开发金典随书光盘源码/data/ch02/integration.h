typedef struct _integ
{
	double            a;         /* 积分下限 */
	double            b;         /* 积分上限，要求b＞a */
	double            eps;       /* 积分精度要求 */
	double          (*ptr)();    /* 函数指针:指向积函函数 */
} INTEG, *INTEGP;

/* 变步长辛卜生求积法 */
typedef struct _sinteg
{
	double            a;         /* 积分下限 */
	double            b;         /* 积分上限，要求b＞a */
	double            eps;       /* 积分精度要求 */
	double            step;      /* 对积分区间进行分割的最小步长，当子区间的宽度小于d时，
	                                即使没有满足精度要求，也不再往下进行分割。*/
	double          (*ptr)();    /* 函数指针:指向积函函数 */
} SINTEG, *SINTEGP;

/* 高振荡函数求积法 */
typedef struct _hinteg
{
	double            a;         /* 积分下限 */
	double            b;         /* 积分上限，要求b＞a */
	int               m;         /* 被积函数中振荡函数的角频率 */
	int               n;         /* 给定积分区间两端点上 的导数最高阶数 + 1 */
	double           *fa;        /* 存放在积分区间端点a处的0 - n-1 阶导数值 */
	double           *fb;        /* 存放在积分区间端点b处的0 - n-1 阶导数值 */
	double            s[2];
/*	double          (*ptr)();    函数指针:指向积函函数 */
} HINTEG, *HINTEGP;

/* 一维积分的蒙特卡洛法 */
typedef struct _minteg
{
	double            a;         /* 积分下限 */
	double            b;         /* 积分上限，要求b＞a */
	int               m;         /* 随机序列长度 */
	double          (*ptr)();    /* 函数指针:指向积函函数 */
} MINTEG, *MINTEGP;

/* 二重积分法 */
typedef struct _integ2
{
	double            a;         /* 积分下限 */
	double            b;         /* 积分上限，要求b＞a */
	double            eps;       /* 积分精度要求 */
	void            (*ud)();     /* 指向计算上下限的函数名*/
	double          (*ptr)();    /* 函数指针:指向积函函数 */
} INTEG2, *INTEG2P;

/* 高斯多重积分法 */
typedef struct _ginteg
{
	int               n;         /* 积分重数 */
	int              *js;        /* js[k]表示第k层积分区间所划分的子区间个数 */
	void            (*ud)();     /* 指向计算上下限的函数名*/
	double          (*ptr)();    /* 函数指针:指向积函函数 */
} GINTEG, *GINTEGP;

/* 多重积分的蒙特卡洛法 */
typedef struct _minteg2
{
	int               n;         /* 积分重数 */
	int               m;         /* 随机序列长度 */
	double           *a;         /* 存放各层积分的下限值 */
	double           *b;         /* 存放各层积分的上限值 */
	double          (*ptr)();    /* 函数指针:指向积函函数 */
} MINTEG2, *MINTEG2P;

