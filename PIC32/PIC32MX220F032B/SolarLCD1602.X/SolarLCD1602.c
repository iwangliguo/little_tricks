//2019.11.21

#include <plib.h>
#include <xc.h>

// Configuration Bit settings
// SYSCLK = 48 MHz (48MHz Crystal / FPLLIDIV * FPLLMUL / FPLLODIV)
// PBCLK = 48 MHz (SYSCLK / FPBDIV)
// Primary Osc w/PLL (XT+,HS+,EC+PLL)
// WDT OFF
#pragma config FPLLMUL = MUL_24, FPLLIDIV = DIV_2, FPLLODIV = DIV_2, FWDTEN = OFF
#pragma config POSCMOD = OFF, FNOSC = FRCPLL, FPBDIV = DIV_1

// Disable JTAG to release PORTB
#pragma config JTAGEN   = OFF           //JTAG disable

#define SYS_FREQ (48000000L)

#define ulong unsigned long
#define uint unsigned int
#define uchar unsigned char

unsigned char word1[16]={"CH = "};

#define ADCS  PORTAbits.RA0
#define ADDI  PORTAbits.RA1  //ADC0832 data in	����Ϊ���	 //оƬ��DIO����
#define ADDO  PORTAbits.RA1  //ADC0832 data out	,����Ϊ����    ADDI��ADDO���Ը���
#define ADCLK PORTAbits.RA2  //ADC0832 clock signal	//оƬ��CLK����

#define rs  PORTBbits.RB0
#define rw  PORTBbits.RB1
#define en  PORTBbits.RB2
 
unsigned char readad[2];

void  Adc0832(unsigned char channel);

float tt;

/*
 1602Һ��ר����ʱ
*/ 

 void DelayUs2x(unsigned char t)
{   
 while(--t);
}

void DelayMs(unsigned char t)
{
     
 while(t--)
 {
     //������ʱ1mS
     DelayUs2x(245);
	 DelayUs2x(245);
 }
}

void DelayNop(unsigned char n)
{
    unsigned char i;
    for(i=0;i<n;i++)
    {
        _nop();
    }
}


void shuaxin(uint shuaxint)//ˢ����ʾ����
{
while(shuaxint--);
}
//1602Һ����æ����
// uchar LCD_Check_Busy(void) 
// { 
// //PORTB |=0x00000F78; 
// PORTBbits.RB7 =   0x01;
// PORTBbits.RB8 =   0x01;
// PORTBbits.RB9 =   0x01;
// PORTBbits.RB10 =  0x01;
// PORTBbits.RB11 =  0x01;
// PORTBbits.RB13 =  0x01;
// PORTBbits.RB14 =  0x01;
// PORTBbits.RB15 =  0x01;
// rs=0; 
// rw=1; 
// en=0; 
// _nop(); 
// en=1;
// return  PORTBbits.RB15;
// }

//д�������
  void LCD_Write_Com(uchar com) 
 {  
 DelayMs(5);
 rs=0; 
 rw=0;; 
 en=1; 
  
 PORTBbits.RB7 = com & 0x01;
 PORTBbits.RB8 = (com>>1) & 0x01;
 PORTBbits.RB9 = (com>>2) & 0x01;
 PORTBbits.RB10 = (com>>3) & 0x01;
 PORTBbits.RB11 = (com>>4) & 0x01;
 PORTBbits.RB13 = (com>>5) & 0x01;
 PORTBbits.RB14 = (com>>6) & 0x01;
 PORTBbits.RB15 = (com>>7) & 0x01;
 
 //_nop(); 
 DelayNop(6);
 en=0;
 }

 //д�����ݺ���
   void LCD_Write_Data(uchar Data) 
 { 
 DelayMs(5);
 rs=1; 
 rw=0; 
 en=1; 
 PORTBbits.RB7 = Data & 0x01;
 PORTBbits.RB8 = (Data>>1) & 0x01;
 PORTBbits.RB9 = (Data>>2) & 0x01;
 PORTBbits.RB10 = (Data>>3) & 0x01;
 PORTBbits.RB11 = (Data>>4) & 0x01;
 PORTBbits.RB13 = (Data>>5) & 0x01;
 PORTBbits.RB14 = (Data>>6) & 0x01;
 PORTBbits.RB15 = (Data>>7) & 0x01;
 //_nop();
 DelayNop(6);
 en=0;
 }

 //	LCD1602��������
   void LCD_Clear(void) 
 { 
 LCD_Write_Com(0x01); 
 DelayMs(5);
 }

 //	  LCD1602д���ַ�����
  void LCD_Write_Char(unsigned char x,unsigned char y,unsigned char Data) 
 {     
 if (y == 0) 
 	{     
 	LCD_Write_Com(0x80 + x);     
 	}    
 else 
 	{     
 	LCD_Write_Com(0xC0 + x);     
 	}        
 LCD_Write_Data( Data);  
 }

 //LCD1602д���ַ�������
   void LCD_Write_String(unsigned char x,unsigned char y,unsigned char *s) //д���ַ����ĺ���
 {     
 if (y == 0) 
 	{     
	 LCD_Write_Com(0x80 + x);     //��ʾ��һ��
 	}
 else 
 	{      
 	LCD_Write_Com(0xC0 + x);      //��ʾ�ڶ���
 	}        
 while (*s) 
 	{     
 LCD_Write_Data( *s);     
 s++;     
 	}
 }

 //LCD1602��ʼ������
   void LCD_Init(void) 
 {
   LCD_Write_Com(0x38);    /*��ʾģʽ����*/ 
   DelayMs(5); 
   LCD_Write_Com(0x38); 
   DelayMs(5); 
   LCD_Write_Com(0x38); 
   DelayMs(5); 
   LCD_Write_Com(0x38);  
   LCD_Write_Com(0x08);    /*��ʾ�ر�*/ 
   LCD_Write_Com(0x01);    /*��ʾ����*/ 
   LCD_Write_Com(0x06);    /*��ʾ����ƶ�����*/ 
   DelayMs(5); 
   LCD_Write_Com(0x0C);    /*��ʾ�����������*/
   }


/************
��ADC0832����
************/

//�ɼ�������
void Adc0832(unsigned char channel)
{
 	uchar i=0;
	uchar j;
	uint dat=0;
	uchar ndat=0;

	if(channel==0)channel=2;
	if(channel==1)channel=3;
    
    TRISBCLR  =  0x00000002;    //����Ϊ���
	ADDI=1;
//	_nop();
//	_nop();
    DelayNop(12);
	ADCS=0;//����CS��
//	_nop();
//	_nop();
    DelayNop(12);
	ADCLK=1;//����CLK��
//	_nop();
//	_nop();
    DelayNop(12);
	ADCLK=0;//����CLK��,�γ��½���1
//	_nop();
//	_nop();
    DelayNop(12);
	ADCLK=1;//����CLK��
	ADDI=channel&0x1;
//	_nop();
//	_nop();
    DelayNop(12);
	ADCLK=0;//����CLK��,�γ��½���2
//	_nop();
//	_nop();
    DelayNop(12);
	ADCLK=1;//����CLK��
	ADDI=(channel>>1)&0x1;
//	_nop();
//	_nop();
    DelayNop(12);
	ADCLK=0;//����CLK��,�γ��½���3
	ADDI=1;//����������� 
//	_nop();
//	_nop();
    DelayNop(12);
	dat=0;
    TRISBSET   =  0x00000002;  //����Ϊ����
	for(i=0;i<8;i++)
	{
		dat|=ADDO;//������
		ADCLK=1;
//		_nop();
//		_nop();
        DelayNop(12);
		ADCLK=0;//�γ�һ��ʱ������
//		_nop();
//		_nop();
        DelayNop(12);
		dat<<=1;
		if(i==7)dat|=ADDO;
	}  
	for(i=0;i<8;i++)
	{
		j=0;
		j=j|ADDO;//������
		ADCLK=1;
//		_nop();
//		_nop();
        DelayNop(12);
		ADCLK=0;//�γ�һ��ʱ������
//		_nop();
//		_nop();
        DelayNop(12);
		j=j<<7;
		ndat=ndat|j;
		if(i<7)ndat>>=1;
	}
	ADCS=1;//����CS��
	ADCLK=0;//����CLK��
    TRISBCLR  =  0x00000002;    //����Ϊ���
	ADDO=1;//�������ݶ�,�ص���ʼ״̬
	readad[0]=dat;
	readad[1]=ndat;
}

void Tempprocess()
{
	tt=readad[0]/255.0*5.0;
	word1[4]=(unsigned char )(tt);
	word1[5]='.';
	word1[6]=(unsigned char )(tt*10-word1[4]*10);
	word1[7]=(unsigned char )(tt*100-word1[4]*100-word1[6]*10);
	word1[8]=(unsigned char )(tt*1000-word1[4]*1000-word1[6]*100-word1[7]*10);
	word1[9]=(unsigned char )(tt*10000-word1[4]*10000-word1[6]*1000-word1[7]*100-word1[8]*10);
	word1[4]+=48;
	word1[6]+=48;
	word1[7]+=48;
	word1[8]+=48;
	word1[9]+=48;
	word1[10]='V';
}

 void main()
 {
        SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);
        PORTSetPinsDigitalOut(IOPORT_B, BIT_0|BIT_1|BIT_2|BIT_7|BIT_8|BIT_9|BIT_10|BIT_11|BIT_13|BIT_15|BIT_14);
        PORTSetPinsDigitalOut(IOPORT_A, BIT_0|BIT_1|BIT_2 );
		LCD_Init(); 
		LCD_Clear();//����

   while(1)
   {
        
        Adc0832(0);
		Tempprocess();

		LCD_Write_String(0,0,"Dian ya shu ju:");
		LCD_Write_Char(4,1,word1[4]);
		LCD_Write_Char(5,1,'.');
		LCD_Write_Char(6,1,word1[6]);
		LCD_Write_Char(7,1,word1[7]);
		LCD_Write_Char(8,1,'V');

   }
 }

 