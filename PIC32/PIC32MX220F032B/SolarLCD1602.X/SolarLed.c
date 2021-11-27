 //2019.11.21

 #include <plib.h>
#include  <xc.h>
 
#define uint unsigned int
#define uchar unsigned char

//引脚定义
#define jidianqi  PORTAbits.RA1   //配置为输出
#define kongzhi   PORTAbits.RA0  //配置为输入

//RB7-15,除了12都定义为输出

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
		if(kongzhi==1) //当检测到天黑的情况下，打开整个的LED灯 以及打开继电器 打开灯泡
		{
            
			jidianqi=0;
			//P2=0x00;
            PORTBCLR = 0xFF80;
		}
		if(kongzhi==0)//当天亮的情况下，关闭所有
		{
			//P2=0xff;
            PORTBSET = 0xFF80;
			jidianqi=1;
		}
	}
}