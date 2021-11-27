/*
 * File:   ioports.c
 * Author: bincker
 *
 * Created on 2013年7月15日, 上午10:39
 */

#include <plib.h>

// Configuration Bit settings
// SYSCLK = 48 MHz (8MHz Crystal / FPLLIDIV * FPLLMUL / FPLLODIV)
// PBCLK = 48 MHz (SYSCLK / FPBDIV)
// Primary Osc w/PLL (XT+,HS+,EC+PLL)
// WDT OFF
#pragma config FPLLMUL = MUL_24, FPLLIDIV = DIV_2, FPLLODIV = DIV_2, FWDTEN = OFF
#pragma config POSCMOD = OFF, FNOSC = FRCPLL, FPBDIV = DIV_1

// Disable JTAG to release PORTB
#pragma config JTAGEN   = OFF           //JTAG disable

// Period needed for timer 1 to trigger an interrupt every 0.1 second
// (48MHz PBCLK / 1 = 48000000KHz Timer 1 clock)
#define PERIOD  48000       //48000/48000000 = 0.001s = 1ms

#define SYS_FREQ (48000000L)

unsigned int light_cnt=0,light_flag=1;

void LightInit() {
    PORTSetPinsDigitalOut(IOPORT_B, BIT_7 | BIT_8 | BIT_9 | BIT_13 );
}

void Light() {
    static int light = 0;
    PORTSetBits(IOPORT_B, BIT_7 | BIT_8 | BIT_9 | BIT_13);
    switch (light) {
            //light跑马灯
        case 0:
            PORTClearBits(IOPORT_B, BIT_9);
            break;
        case 1:
            PORTClearBits(IOPORT_B, BIT_8);
            break;
        case 2:
            PORTClearBits(IOPORT_B, BIT_7);
            break;
        case 3:
            PORTClearBits(IOPORT_B, BIT_13);
            break;
        case 4:
            PORTClearBits(IOPORT_B, BIT_7);
            break;
        case 5:
            PORTClearBits(IOPORT_B, BIT_8);
            break;
        default:
            break;
    }
    light++;
    if (light > 5) light = 0;
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

    light_cnt++;
    if(light_cnt > 100)  //0.1s
    {
        light_cnt = 0;
        light_flag = 1;
    }
}

int main(void)
{
    int task=0;
    SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);
    INTDisableInterrupts();
    INTConfigureSystem(INT_SYSTEM_CONFIG_MULT_VECTOR);

    LightInit();
    Timer1Init();

    INTEnableInterrupts();
    while(1)
    {
        switch(task)
        {
            case 0:
                if(light_flag > 0)
                {
                    light_flag = 0;
                    Light();
                }
                break;
            default:
                break;
        }
        task ++;
        if(task > 0) task = 0;
    }
    return 1;
}
