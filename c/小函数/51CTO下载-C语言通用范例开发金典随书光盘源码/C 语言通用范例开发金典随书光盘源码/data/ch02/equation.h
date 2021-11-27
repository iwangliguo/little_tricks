#ifndef __FUNCTION_H__
#define __FUNCTION_H__

/* 多项式 */
typedef struct _nlf 
{
	int      n; /* 方程次数 */
	double  *c; /* 系数: a0, a1 ... an   */
}  NLF, *NLFP;

typedef struct _cnlf 
{
	int      n;  /* 方程次数 */
	double  *cr; /* 系数实部 */
	double  *ci; /* 系数虚部 */
}  CNLF, *CNLFP;

typedef struct _dic 
{
	double    left;  /* 求根区间左端点 */
	double    right; /* 求根区间右端点 */
	double    step;  /* 搜索步长 */
	double    eps;   /* 控制精度 */
	int       m;     /* 区间内根个数预估值 */
	int       n;     /* 实际或得根个数 */
	double   *x;     /* 根数据区 */
}  DIC, *DICP;

typedef struct _ite 
{
	int       iter;  /* 最大迭代次数 */
	double    eps;   /* 控制精度 */
	double    x;     /* 迭代初值。返回时，为迭代终值 */
}  ITE, *ITEP;

typedef struct _root
{
	int       n;     /* 根个数 */
	double   *rr;    /* 根实部数据区 */
	double   *ri;    /* 根虚部数据区 */
}  ROOT, *ROOTP;

/* 非线性方程组：梯度法 */
typedef struct _gctl 
{
	int           n;      /* 方程个数 */
	double       *x;      /* 迭代初值。返回时，为迭代终值 */
	double        eps;    /* 控制精度 */
	int           iter;   /* 最大迭代次数 */
	double      (*fuc)(); /* 计算目标函数值和偏导数值得函数 */
} GCTL, *GCTLP;

/* 非线性方程组：拟牛顿法 */
typedef struct _qnctl 
{
	int           n;      /* 方程个数 */
	double       *x;      /* 迭代初值。返回时，为迭代终值 */
	double        eps;    /* 控制精度 */
	int           iter;   /* 最大迭代次数 */
	double        t;      /* 控制h大小的变量, 0<t<1 */
	double        h;      /* 增量初值 */
	void        (*fuc)(); /* 计算方程组左端函数值 */
} QNCTL, *QNCTLP;

/* 非线性方程：蒙特卡洛法 */
typedef struct _mctl 
{
	int           n;      /* 方程个数,也是未知数个数 */
	double        *x,*y;  /* x:实部 y:虚部. 初值,返回时，为方程根的终值。*/ 
	double        b;      /* 均匀分布随机数初值 */
	int           m;      /* 控制b大小的变量 */
	double        eps;    /* 控制精度 */
	double      (*fuc)(); /* 方程(组)左端函数 */
} MCTL, *MCTLP;

/* 返回多项式函数值f(x) */
double nlf(NLFP fp, double x) {
	double s, t;
	int    i;

	s = fp->c[0];
	t = 1.0;
	for(i=1; i<=fp->n; i++) {
		t *= x;
		s += fp->c[i] * t;
	}
	return s;
}

/* y[0] 返回多项式函数值f(x); y[0] 返回多项式一阶倒数函数值f'(x); */
void nlf2(NLFP fp, double x, double y[]) {
	double s, t;
	int    i;

	y[0] = nlf(fp, x);

	s = fp->c[1];
	t = 1.0;
	for(i=2; i<=fp->n; i++) {
		t *= x;
		s += i * fp->c[i] * t;
	}
	y[1] = s;
}

#endif