 //2019.11.21

 #include <plib.h>
#include  <xc.h>
 
#define uint unsigned int
#define uchar unsigned char

//���Ŷ���
#define jidianqi  PORTAbits.RA1   //����Ϊ���
#define kongzhi   PORTAbits.RA0  //����Ϊ����

//RB7-15,����12������Ϊ���

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

void main()
{
    SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);
    PORTSetPinsDigitalOut(IOPORT_B, BIT_7|BIT_8|BIT_9|BIT_10|BIT_11|BIT_13|BIT_15|BIT_14);
     PORTSetPinsDigitalOut(IOPORT_A, BIT_1);
    PORTSetPinsDigitalIn(IOPORT_A, BIT_0);
	while(1)
	{
		if(kongzhi==1) //����⵽��ڵ�����£���������LED�� �Լ��򿪼̵��� �򿪵���
		{
            
			jidianqi=0;
			//P2=0x00;
            PORTBCLR = 0xFF80;
		}
		if(kongzhi==0)//������������£��ر�����
		{
			//P2=0xff;
            PORTBSET = 0xFF80;
			jidianqi=1;
		}
	}
}