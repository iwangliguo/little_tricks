
////��Ҫ�޸Ĵ������Ϊ437��������936(gbk),���������������
//#include<stdio.h>
//#include <windows.h>
//int main()
//{
//    int i,j;
//    SetConsoleOutputCP(437);
//    for(i=0;i<8;i++)
//    {
//        for(j=0;j<8;j++)
//            if((i+j)%2==0)
//                printf("%c",219);
//            else printf("  ");
//        printf("\n");
//    }
//    return 0;
//}

//#include<stdio.h>
//#include <windows.h>
//int main()
//{
//    SetConsoleOutputCP(437);
//    int i,j;
//    printf("\1 \1\n"); /*�������Ц��*/
//    for(i=1;i<11;i++)
//    {
//        for(j=1;j<=i;j++)
//            printf("%c%c",219,219);
//        printf("\n");
//    }
//    return 0;
//}

#include<stdio.h>
#include <math.h>

int main()
{
    int i = 2, m, sq;
    printf("������������");
    scanf("%d", &m);
    sq = sqrt(m);  //������Բο���������ɸѡ��ʽ
    while (i <= sq)
    {
        if (m % i == 0)
        {
            printf("%d", i);
            m /= i;
            if (m != 1)
                printf("*");
        }
        else
            i++;
    }
    if (m != 1)
        printf("%d", m);
    while (getchar() != EOF)//ctrl z �ٻس�
    {
    }
}
