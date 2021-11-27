/*
 * File:   PWMExample.c
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
#pragma config POSCMOD = OFF, FNOSC = FRCPLL, FPBDIV = DIV_1, FSOSCEN = OFF

#pragma config FUSBIDIO = OFF           //FUSBIDIO为端口控制
#pragma config JTAGEN   = OFF           //JTAG disable

// Period needed for timer 1 to trigger an interrupt every 0.1 second
// (48MHz PBCLK / 1 = 48000000KHz Timer 1 clock)
#define PERIOD  9600       //48000/48000000 = 0.001s = 0.2ms

#define BTN_DELAY   2 //2*5=10ms
#define SYS_FREQ (48000000L)

#define PWM_PR  0x0FFF

UINT16 pwm1=0,pwm1_d=0;

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

    if(pwm1_d == 0)
    {
        pwm1 ++;
        if(pwm1 > PWM_PR)
        {
            pwm1 = PWM_PR;
            pwm1_d = 1;
        }
    }
    else
    {
        if(pwm1 == 0)
        {
            pwm1 = 0;
            pwm1_d = 0;
        }
        else
            pwm1 --;
    }
    OC1RS = pwm1;
    OC2RS = pwm1;
    OC3RS = pwm1;
    OC4RS = pwm1;
}

void PWMinit()
{
    //PWM引脚关联
    RPB7Rbits.RPB7R = 0b0101;       //PWM1
    RPB8Rbits.RPB8R = 0b0101;       //PWM2
    RPB9Rbits.RPB9R = 0b0101;       //PWM3
    RPB13Rbits.RPB13R = 0b0101;     //PWM4
    //PWM1初始化
    OC1CON = 0x0000; // Turn off OC1 while doing setup.
    OC1RS = pwm1; // Initialize secondary Compare Register
    OC1CON = 0x0006; // Configure for PWM mode
    //PWM2初始化
    OC2CON = 0x0000; // Turn off OC1 while doing setup.
    OC2RS = pwm1; // Initialize secondary Compare Register
    OC2CON = 0x0006; // Configure for PWM mode
    //PWM3初始化
    OC3CON = 0x0000; // Turn off OC1 while doing setup.
    OC3RS = pwm1; // Initialize secondary Compare Register
    OC3CON = 0x0006; // Configure for PWM mode
    //PWM4初始化
    OC4CON = 0x0000; // Turn off OC1 while doing setup.
    OC4RS = pwm1; // Initialize secondary Compare Register
    OC4CON = 0x0006; // Configure for PWM mode
    //定时器2周期设定+开启
    PR2 = PWM_PR; // Set period
    T2CONSET = 0x8000; // Enable Timer2
    //PWM1~5开启
    OC1CONSET = 0x8000; // Enable OC1
    OC2CONSET = 0x8000; // Enable OC2
    OC3CONSET = 0x8000; // Enable OC3
    OC4CONSET = 0x8000; // Enable OC4
}

int main(void)
{
    SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);
    INTDisableInterrupts();
    INTConfigureSystem(INT_SYSTEM_CONFIG_MULT_VECTOR);

    PWMinit();
    Timer1Init();
    INTEnableInterrupts();

    while(1)
        ;
    return 0;
}
