
////需要修改代码编码为437，而不是936(gbk),否则输出中文乱码
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
//    printf("\1 \1\n"); /*输出两个笑脸*/
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
    printf("请输入整数：");
    scanf("%d", &m);
    sq = sqrt(m);  //这个可以参考下质数的筛选方式
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
    while (getchar() != EOF)//ctrl z 再回车
    {
    }
}
