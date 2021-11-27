/*
 * File:   SPIExample.c
 * Author: bincker
 */

#include <plib.h>

// Configuration Bit settings
// SYSCLK = 48 MHz (8MHz Crystal / FPLLIDIV * FPLLMUL / FPLLODIV)
// PBCLK = 48 MHz (SYSCLK / FPBDIV)
// Primary Osc w/PLL (XT+,HS+,EC+PLL)
// WDT OFF
#pragma config FPLLMUL = MUL_24, FPLLIDIV = DIV_2, FPLLODIV = DIV_2, FWDTEN = OFF
#pragma config POSCMOD = OFF, FNOSC = FRCPLL, FPBDIV = DIV_1

#pragma config JTAGEN   = OFF           //JTAG disable

#pragma config CP       = OFF
#pragma config DEBUG    = OFF

// Period needed for timer 1 to trigger an interrupt every 0.1 second
// (48MHz PBCLK / 1 = 48000000KHz Timer 1 clock)
#define PERIOD  48000       //48000/48000000 = 0.001s = 1ms

#define SYS_FREQ (48000000L)

unsigned int led_cnt=0,led_flag=1;

//8¶ÎLEDÊýÂë¹Ü×Ö¿â£º0~9 0.~9.FSEt-yno
unsigned char Led_lib[] = {0x42, 0xf3, 0x86, 0xa2, 0x33, 0x2a, 0x0a, 0xf2, 0x02, 0x22, 0x40, 0xf1, 0x84, 0xa0, 0x31, 0x28, 0x08, 0xf0, 0x00, 0x20, 0x1e, 0x0e, 0x0f, 0xbf, 0x23, 0x9b, 0x8b}; //Ð¡LED×Ö¿â
/*-------LED¶ÎÂë·Ö²¼Í¼------
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

void SpiDoBurst(unsigned char *pBuff, unsigned char Len)
{
    if (pBuff)
    {
        unsigned int i;
        PORTClearBits(IOPORT_B, BIT_9);
        for (i = 0; i < Len; i++)
        {
            SpiChnPutC(2, pBuff[i]);
        }
        PORTSetBits(IOPORT_B, BIT_9);
    }
}

void Led()
{
    unsigned char ledBuff[4] = {0x00, 0x00, 0x00, 0x00};
    static unsigned char ledcnt[4]={0x00, 0x0A, 0x00, 0x00};
    int i;
    for (i = 0; i < 4; i++)
        ledBuff[i] = Led_lib[ledcnt[i]];
    SpiDoBurst(ledBuff, 4);
    ledcnt[2] ++;
    if(ledcnt[2] > 9)
    {
        ledcnt[2] = 0;
        ledcnt[1] ++;
        if(ledcnt[1] > 19)
        {
            ledcnt[1] = 10;
            ledcnt[0] ++;
            if(ledcnt[0] > 9)
            {
                ledcnt[0] = 0;
                ledcnt[3] ++;
                if(ledcnt[3] > 9)
                {
                    ledcnt[3] = 0;
                }
            }
        }
    }
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
}

int main(void)
{
    SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);
    INTDisableInterrupts();
    INTConfigureSystem(INT_SYSTEM_CONFIG_MULT_VECTOR);

    SpiInitDevice();
    Timer1Init();

    INTEnableInterrupts();
    while(1)
    {
        if(led_flag > 0)
        {
            led_flag = 0;
            Led();
        }
    }
    return 1;
}
