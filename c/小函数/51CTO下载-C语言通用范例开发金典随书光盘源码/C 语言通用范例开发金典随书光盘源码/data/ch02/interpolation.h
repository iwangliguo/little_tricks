typedef struct _inte 
{
	int       n;     /*  �ڵ���� */
	double   *x;     /*  ������n���ڵ� */ 
	double   *y;     /*  ��Ӧ��n���ڵ�ĺ���ֵ */
	double    t;     /*  ��ֵ�� */
} INTE, *INTEP;

/* Hermite */
typedef struct _hinte 
{
	int       n;     /*  �ڵ���� */
	double   *x;     /*  ������n���ڵ� */ 
	double   *y;     /*  ��Ӧ��n���ڵ�ĺ���ֵ */
	double   *dy;    /*  ��Ӧ��n���ڵ��һ�׵���ֵ */
	double    t;     /*  ��ֵ�� */
} HINTE, *HINTEP;

/* Aitken */
typedef struct _ainte 
{
	int       n;     /*  �ڵ���� */
	double   *x;     /*  ������n���ڵ� */ 
	double   *y;     /*  ��Ӧ��n���ڵ�ĺ���ֵ */
	double    t;     /*  ��ֵ�� */
	double    eps;   /*  ��ֵ���ȿ��� */
} AINTE, *AINTEP;

/* Akima */
typedef struct _akinte 
{
	int       n;     /*  �ڵ���� */
	double   *x;     /*  ������n���ڵ� */ 
	double   *y;     /*  ��Ӧ��n���ڵ�ĺ���ֵ */
	int       k;
	double    t;     /*  ��ֵ�� */
	double    s[5];
} AKINTE, *AKINTEP;

/* ��һ���������ֱ߽���������������������ֵ��΢������� */
typedef struct _csinte 
{
	int       n;     /*  �ڵ���� */
	double   *x;     /*  ������n���ڵ� */ 
	double   *y;
	double   *dy;
	double   *ddy;
	int       m;     /*  ��ֵ����� */
	double   *t;     /*  ��ֵ�� */
	double   *z;
	double   *dz;
	double   *ddz;
} CSINTE, *CSINTEP;

/* ��Ԫ����/ȫ�����ֵ */
typedef struct _pinte 
{
	int       n;   /* X ���������� */
	int       m;   /* Y ���������� */
	double   *x;   /* X �����n������ */
	double   *y;   /* Y �����m������ */
	double   *z;   /* n x m ������ֵ  */
	double    u;   /* ��ֵ�� X ����   */
	double    v;   /* ��ֵ�� Y ����   */
}  PINTE, *PINTEP;

/* ��С����������� */
typedef struct _linte 
{
	int       n;     /*  �ڵ���� */
	double   *x;     /*  ���ݵ�� X ���� */ 
	double   *y;     /*  ���ݵ�� Y ���� */ 
	int       m;     /*  ��϶���ʽ���� */
	double   *coe;   /*  ��϶���ʽϵ��*/
	double   *dt;
} LINTE, *LINTEP;

/* �б�ѩ��������� */
typedef struct _chinte 
{
	int       n;     /*  �ڵ���� */
	double   *x;     /*  ���ݵ�� X ���� */ 
	double   *y;     /*  ���ݵ�� Y ���� */ 
	int       m;     /*  ��϶���ʽ���� */
	double   *coe;   /*  ��϶���ʽϵ��*/
} CHINTE, *CHINTEP;

/* ���һ�±ƽ��������ȷ��� */
typedef struct _rinte 
{
	int       n;     /*  n-1�����һ�±ƽ�����ʽ�������������һ�±ƽ�����ʽ����ߴ�Ϊn-1��
	                     Ҫ��n��20����n��20���򱾺����Զ�ȡn=20��*/
	double   *coe;   /*  ǰn��Ԫ�ط���n-1�����һ�±ƽ�����ʽ��n��ϵ����
	                     ���һ��Ԫ��coe [n]������϶���ʽ��ƫ�����ֵ�� */ 
	double    a;     /*  ������˵�ֵ */ 
	double    b;     /*  �����Ҷ˵�ֵ */ 
	double    eps;   /*  ���ƾ���Ҫ��һ����10-10��10-35֮�䡣 */
	double  (*ptr)();/*  ����ָ�룺ָ����㺯�� */
} RINTE, *RINTEP;

/* ���������С����������Ϸ��� */
typedef struct _recinte 
{
	int       n;     /*  X������� */
	int       m;     /*  Y������� */
	double   *x;     /*  ��Ÿ������ݵ��n��X���� */
	double   *y;     /*  ��Ÿ������ݵ��m��Y���� */
	double   *z;     /*  ��ž���������n��m�������ϵĺ���ֵ */
	int       p;     /*  ��϶���ʽ��x����ߴ�����1��Ҫ��p��n��p��20��������������������������Զ�ȡp=min{n,20}�� */ 
	int       q;     /*  ��϶���ʽ��y����ߴ�����1��Ҫ��q��m��q��20��������������������������Զ�ȡq=min{m,20}�� */ 
	double   *a;     /*  �ض�Ԫ��϶���ʽ�ĸ�ϵ�� */
	double   *dt;    /*  dt[0]������϶���ʽ�����ݵ�����ƽ���ͣ�
					     dt[1]������϶���ʽ�����ݵ����ľ���ֵ֮�ͣ�
	                     dt[2]������϶���ʽ�����ݵ�������ֵ�����ֵ�� */
} RECINTE, *RECINTEP;
