#include <stdio.h>
#include <stdlib.h>


void printfFloatBit(float f)
{
	int i,j;
	unsigned int byte=0;
	char ch,*p;
	p=(char *)(&f);
	printf(" %-.7f: ",f);
	for(i=sizeof(float)-1;i>=0;i--)
	{
		ch=*(p+i);
		byte=ch;
		for(j=1;j <=8;j++)
			 {
				  if(byte>=128) printf("1");
				  else printf("0");
				  byte <<=1;
				  byte&=255;    //取低8位
			 }
	}
 printf("\n");
}

int  main()
{
	float f1=178.125f;
	float f2=-0.15625f;
	float f3=1.0f;
	system("cls");
	system("time /t") ;// 显示时间
	printfFloatBit(f1);
	printfFloatBit(f2);
	printfFloatBit(f3);
	system("pause");
}
