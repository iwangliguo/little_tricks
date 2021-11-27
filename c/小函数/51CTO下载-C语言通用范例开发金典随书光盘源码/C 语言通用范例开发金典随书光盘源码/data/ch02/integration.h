typedef struct _integ
{
	double            a;         /* �������� */
	double            b;         /* �������ޣ�Ҫ��b��a */
	double            eps;       /* ���־���Ҫ�� */
	double          (*ptr)();    /* ����ָ��:ָ��������� */
} INTEG, *INTEGP;

/* �䲽������������� */
typedef struct _sinteg
{
	double            a;         /* �������� */
	double            b;         /* �������ޣ�Ҫ��b��a */
	double            eps;       /* ���־���Ҫ�� */
	double            step;      /* �Ի���������зָ����С��������������Ŀ��С��dʱ��
	                                ��ʹû�����㾫��Ҫ��Ҳ�������½��зָ*/
	double          (*ptr)();    /* ����ָ��:ָ��������� */
} SINTEG, *SINTEGP;

/* ���񵴺�������� */
typedef struct _hinteg
{
	double            a;         /* �������� */
	double            b;         /* �������ޣ�Ҫ��b��a */
	int               m;         /* �����������񵴺����Ľ�Ƶ�� */
	int               n;         /* ���������������˵��� �ĵ�����߽��� + 1 */
	double           *fa;        /* ����ڻ�������˵�a����0 - n-1 �׵���ֵ */
	double           *fb;        /* ����ڻ�������˵�b����0 - n-1 �׵���ֵ */
	double            s[2];
/*	double          (*ptr)();    ����ָ��:ָ��������� */
} HINTEG, *HINTEGP;

/* һά���ֵ����ؿ��巨 */
typedef struct _minteg
{
	double            a;         /* �������� */
	double            b;         /* �������ޣ�Ҫ��b��a */
	int               m;         /* ������г��� */
	double          (*ptr)();    /* ����ָ��:ָ��������� */
} MINTEG, *MINTEGP;

/* ���ػ��ַ� */
typedef struct _integ2
{
	double            a;         /* �������� */
	double            b;         /* �������ޣ�Ҫ��b��a */
	double            eps;       /* ���־���Ҫ�� */
	void            (*ud)();     /* ָ����������޵ĺ�����*/
	double          (*ptr)();    /* ����ָ��:ָ��������� */
} INTEG2, *INTEG2P;

/* ��˹���ػ��ַ� */
typedef struct _ginteg
{
	int               n;         /* �������� */
	int              *js;        /* js[k]��ʾ��k��������������ֵ���������� */
	void            (*ud)();     /* ָ����������޵ĺ�����*/
	double          (*ptr)();    /* ����ָ��:ָ��������� */
} GINTEG, *GINTEGP;

/* ���ػ��ֵ����ؿ��巨 */
typedef struct _minteg2
{
	int               n;         /* �������� */
	int               m;         /* ������г��� */
	double           *a;         /* ��Ÿ�����ֵ�����ֵ */
	double           *b;         /* ��Ÿ�����ֵ�����ֵ */
	double          (*ptr)();    /* ����ָ��:ָ��������� */
} MINTEG2, *MINTEG2P;

