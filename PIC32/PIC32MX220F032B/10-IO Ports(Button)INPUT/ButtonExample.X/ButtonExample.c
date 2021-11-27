/*
 * File:   main.c
 * Author: bincker
 */

#include <plib.h>

// Configuration Bit settings
// SYSCLK = 48 MHz (8MHz Crystal / FPLLIDIV * FPLLMUL / FPLLODIV)
// PBCLK = 48 MHz (SYSCLK / FPBDIV)
// Primary Osc w/PLL (XT+,HS+,EC+PLL)
// WDT OFF
#pragma config FPLLMUL = MUL_24, FPLLIDIV = DIV_2, FPLLODIV = DIV_2, FWDTEN = OFF
#pragma config POSCMOD = OFF, FNOSC = FRCPLL, FPBDIV = DIV_1,FSOSCEN = OFF

#pragma config FUSBIDIO = OFF           //FUSBIDIO为端口控制
#pragma config FVBUSONIO = OFF
#pragma config JTAGEN   = OFF           //JTAG disable

#pragma config CP       = OFF
#pragma config DEBUG    = ON

// Period needed for timer 1 to trigger an interrupt every 0.1 second
// (48MHz PBCLK / 1 = 48000000KHz Timer 1 clock)
#define PERIOD  48000       //48000/48000000 = 0.001s = 1ms

#define BTN_DELAY   5 //2*1=2ms
#define SYS_FREQ (48000000L)

unsigned int led_cnt=0,btn_cnt=0,led_flag=1,BtnCnt[]={0,0,0},btn_flag=0;

//数码管显示数据  分别代表0~9,0.~9.FSEt-yno
unsigned char Led_lib[] = {0x42, 0xf3, 0x86, 0xa2, 0x33, 0x2a, 0x0a, 0xf2, 0x02, 0x22, 0x40, 0xf1, 0x84, 0xa0, 0x31, 0x28, 0x08, 0xf0, 0x00, 0x20, 0x1e, 0x0e, 0x0f, 0xbf, 0x23, 0x9b, 0x8b}; //小LED字库
/*-------小LED段码分布图------
          ---0---
         |       |
         7       3
         |       |
          ---6---
         |       |
         5       2
         |       |
          ---4---  1
----------------------------*/

void SpiInitDevice() {
    // 8 bits/char, input data sampled at end of data output time
    SpiOpenFlags oFlags = SPI_OPEN_MSTEN | SPI_OPEN_CKP_HIGH | SPI_OPEN_MODE8 | SPI_OPEN_ON;
    PORTSetPinsDigitalOut(IOPORT_B, BIT_9);
    PPSOutput(2, RPB8, SDO2); // Set RB8 pin as output for SDO2

    // Open SPI module, use SPI channel 2, use flags set above, Divide Fpb by 6
    SpiChnOpen(2, oFlags, 6);
}

void SpiDoBurst(unsigned char *pBuff, unsigned char Len) {
    if (pBuff) {
        unsigned int i;
        PORTClearBits(IOPORT_B, BIT_9);
        for (i = 0; i < Len; i++) {
            SpiChnPutC(2, pBuff[i]);
        }
        PORTSetBits(IOPORT_B, BIT_9);
    }
}

void Led()
{
    static unsigned char ledBuff[4] = {0x00, 0x00, 0x00, 0x00};
    static int led = 0,ledt=0;
    int i;
    SpiDoBurst(ledBuff, 4);
    ledt ++;
    if(ledt > 9)
    {
        ledt = 0;
        led++;
        if (led > 9) led = 0;
    }
    for (i = 0; i < 3; i++)
        ledBuff[i] = Led_lib[BtnCnt[i]];
    ledBuff[3] = Led_lib[led];
}

void Timer1Init()
{
    // Timer1@1ms
    OpenTimer1(T1_ON | T1_SOURCE_INT | T1_PS_1_1, PERIOD);

    // Set up the timer interrupt with a priority of 2
    INTEnable(INT_T1, INT_ENABLED);
    INTSetVectorPriority(INT_TIMER_1_VECTOR, INT_PRIORITY_LEVEL_2);
    INTSetVectorSubPriority(INT_TIMER_1_VECTOR, INT_SUB_PRIORITY_LEVEL_0);
}

void __ISR(_TIMER_1_VECTOR, ipl2) Timer1Handler(void)
{
    // Clear the interrupt flag
    INTClearFlag(INT_T1);
    led_cnt++;
    if(led_cnt > 100)    //0.1s
    {
        led_cnt = 0;
        led_flag = 1;
    }
    btn_cnt++;
    if(btn_cnt > 5)     //5ms
    {
        btn_cnt = 0;
        btn_flag = 1;
    }
}

void BtnInit()
{
    ANSELAbits.ANSA0 = 0;
    ANSELBbits.ANSB3 = 0;
}

void Button(void) {
    static int btn1=0,btn2=0,btn3=0;
    if(PORTAbits.RA0 == 0)
    {
        btn1 ++;
        if(btn1 == BTN_DELAY)
        {
            BtnCnt[0]++;
            if (BtnCnt[0] > 9)
                BtnCnt[0] = 0;
        }
    }
    else
        btn1 = 0;
    if(PORTBbits.RB3 == 0)
    {
        btn2++;
        if(btn2 == BTN_DELAY)
        {
            BtnCnt[1]++;
            if (BtnCnt[1] > 9)
                BtnCnt[1] = 0;
        }
    }
    else
        btn2 = 0;
}

int main(void)
{
    int task=0;
    unsigned char i;
    SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);
    INTDisableInterrupts();
    INTConfigureSystem(INT_SYSTEM_CONFIG_MULT_VECTOR);

    SpiInitDevice();
    BtnInit();
    Timer1Init();

    INTEnableInterrupts();
    while(1)
    {
        switch(task)
        {
            case 0:
                if(led_flag > 0)
                {
                    led_flag = 0;
                    Led();
                }
                break;
            case 1:
                if(btn_flag > 0)
                {
                    btn_flag = 0;
                    Button();
                }
            default:
                break;
        }
        task ++;
        if(task > 1) task = 0;
    }
    return 1;
}
