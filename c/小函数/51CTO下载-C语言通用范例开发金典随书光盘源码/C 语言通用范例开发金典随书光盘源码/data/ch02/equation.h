#ifndef __FUNCTION_H__
#define __FUNCTION_H__

/* ����ʽ */
typedef struct _nlf 
{
	int      n; /* ���̴��� */
	double  *c; /* ϵ��: a0, a1 ... an   */
}  NLF, *NLFP;

typedef struct _cnlf 
{
	int      n;  /* ���̴��� */
	double  *cr; /* ϵ��ʵ�� */
	double  *ci; /* ϵ���鲿 */
}  CNLF, *CNLFP;

typedef struct _dic 
{
	double    left;  /* ���������˵� */
	double    right; /* ��������Ҷ˵� */
	double    step;  /* �������� */
	double    eps;   /* ���ƾ��� */
	int       m;     /* �����ڸ�����Ԥ��ֵ */
	int       n;     /* ʵ�ʻ�ø����� */
	double   *x;     /* �������� */
}  DIC, *DICP;

typedef struct _ite 
{
	int       iter;  /* ���������� */
	double    eps;   /* ���ƾ��� */
	double    x;     /* ������ֵ������ʱ��Ϊ������ֵ */
}  ITE, *ITEP;

typedef struct _root
{
	int       n;     /* ������ */
	double   *rr;    /* ��ʵ�������� */
	double   *ri;    /* ���鲿������ */
}  ROOT, *ROOTP;

/* �����Է����飺�ݶȷ� */
typedef struct _gctl 
{
	int           n;      /* ���̸��� */
	double       *x;      /* ������ֵ������ʱ��Ϊ������ֵ */
	double        eps;    /* ���ƾ��� */
	int           iter;   /* ���������� */
	double      (*fuc)(); /* ����Ŀ�꺯��ֵ��ƫ����ֵ�ú��� */
} GCTL, *GCTLP;

/* �����Է����飺��ţ�ٷ� */
typedef struct _qnctl 
{
	int           n;      /* ���̸��� */
	double       *x;      /* ������ֵ������ʱ��Ϊ������ֵ */
	double        eps;    /* ���ƾ��� */
	int           iter;   /* ���������� */
	double        t;      /* ����h��С�ı���, 0<t<1 */
	double        h;      /* ������ֵ */
	void        (*fuc)(); /* ���㷽������˺���ֵ */
} QNCTL, *QNCTLP;

/* �����Է��̣����ؿ��巨 */
typedef struct _mctl 
{
	int           n;      /* ���̸���,Ҳ��δ֪������ */
	double        *x,*y;  /* x:ʵ�� y:�鲿. ��ֵ,����ʱ��Ϊ���̸�����ֵ��*/ 
	double        b;      /* ���ȷֲ��������ֵ */
	int           m;      /* ����b��С�ı��� */
	double        eps;    /* ���ƾ��� */
	double      (*fuc)(); /* ����(��)��˺��� */
} MCTL, *MCTLP;

/* ���ض���ʽ����ֵf(x) */
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

/* y[0] ���ض���ʽ����ֵf(x); y[0] ���ض���ʽһ�׵�������ֵf'(x); */
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