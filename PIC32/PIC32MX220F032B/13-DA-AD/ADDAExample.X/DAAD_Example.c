/*
 * File:   DAAD_Example.c
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

#pragma config FUSBIDIO = OFF           //FUSBIDIO为端口控制
#pragma config JTAGEN   = OFF           //JTAG disable

// Period needed for timer 1 to trigger an interrupt every 0.1 second
// (48MHz PBCLK / 1 = 48000000KHz Timer 1 clock)
#define PERIOD  48000       //48000/48000000 = 0.001s = 0.2ms

#define BTN_DELAY   2 //2*1=2ms
#define SYS_FREQ (48000000L)

#define PWM_PR  0x0FFF
#define DUTYMAX 0x0AFF

UINT16 pwm1=0,pwm1_d=0,pwm_cnt=0;
unsigned int ADS_cnt=0,ADS_flag=1;
unsigned int adrst[16]={0},adptr=0;

//数码管显示数据  分别代表0~9,0.~9.FSEt-yno
unsigned char Led_lib[] = {0x42, 0xf3, 0x86, 0xa2, 0x33, 0x2a, 0x0a, 0xf2, 0x02, 0x22, 0x40, 0xf1, 0x84, 0xa0, 0x31, 0x28, 0x08, 0xf0, 0x00, 0x20, 0x1e, 0x0e, 0x0f, 0xbf, 0x23, 0x9b, 0x8b}; //小LED字库

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

void AD10init(void)
{
    ANSELAbits.ANSA0 = 1;  // PORTA.0选择为AN0模拟输入
    AD1CON1 = 0x00E0;      // 自动采样
    AD1CHS = 0x00000000;   // CH0和CH1均使用AN4通道
    AD1CSSL = 0;
    AD1CON3 = 0x0203;      // 采样时间 = 2Tad
    AD1CON2 = 0x6004;      // 选择 VREF+ 和 VREF- 作为参考
                           // 采样2次后产生中断信号
    AD1CON1bits.ADON = 1;  // 开启AD
}

UINT16 AD10Sample(void)
{
    AD1CON1bits.ASAM = 1;       // 自动采样：31个Tad后自动转换
    while (!AD1CON1bits.DONE);  // 等待转换完成
    AD1CON1bits.ASAM = 0;       // 结束本次采样/转换操作
    return ADC1BUF0;            //返回采样结果
}

void AD10DispRst(UINT16 rst)
{
    static BYTE spibuff[4];
    spibuff[2] = Led_lib[rst % 10];             //个位
    spibuff[1] = Led_lib[(rst / 10) % 10];      //十位
    spibuff[0] = Led_lib[(rst / 100) % 10];     //百位
    spibuff[3] = Led_lib[rst / 1000];           //千位
    SpiDoBurst(spibuff,4);
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
    
    ADS_cnt++;
    if(ADS_cnt > 10)    //0.01s
    {
        ADS_cnt = 0;
        ADS_flag = 1;
    }
    pwm_cnt++;
    if(pwm_cnt > 1)
    {
        pwm_cnt = 0;
        if(pwm1_d == 0)
        {
            pwm1 ++;
            if(pwm1 > DUTYMAX )
            {
                pwm1 = DUTYMAX;
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
    }
}

void PWMinit()
{
    //PWM引脚关联
    RPB7Rbits.RPB7R = 0b0101;       //PWM1
    //PWM1初始化
    OC1CON = 0x0000; // Turn off OC1 while doing setup.
    OC1RS = pwm1; // Initialize secondary Compare Register
    OC1CON = 0x0006; // Configure for PWM mode
    //定时器2周期设定+开启
    PR2 = PWM_PR; // Set period
    T2CONSET = 0x8000; // Enable Timer2
    //pwm1开启
    OC1CONSET = 0x8000; // Enable OC1
}

int main(void)
{
    int i,ads;
    SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);
    INTDisableInterrupts();
    INTConfigureSystem(INT_SYSTEM_CONFIG_MULT_VECTOR);
    SpiInitDevice();
    AD10init();
    PWMinit();
    Timer1Init();
    INTEnableInterrupts();
    while(1)
    {
        if(ADS_flag > 0)
        {
            ADS_flag = 0;
            adrst[adptr] = AD10Sample();
            adptr++;
            if(adptr > 15)
            {
                adptr = 0;
                ads = 0;
                for(i=0;i<16;i++)
                    ads += adrst[i];
                ads = ads >> 4;
                AD10DispRst(ads);
            }
        }
    }
    return 0;
}
