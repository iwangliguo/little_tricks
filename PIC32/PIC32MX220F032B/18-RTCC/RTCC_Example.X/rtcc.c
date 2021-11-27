/*
 * File:   rctt.c
 * 实时时钟示例：利用实时时钟模块，实现24小时实时时钟显示
 * 程序起始时间为：2013-01-01 00:00:00
 * 利用SPI驱动的4个8段数码管显示时间（仅显示分钟：秒钟）
 */

#include <plib.h>

// Configuration Bit settings
// SYSCLK = 48 MHz (8MHz Crystal / FPLLIDIV * FPLLMUL / FPLLODIV)
// PBCLK = 48 MHz (SYSCLK / FPBDIV)
// Primary Osc w/PLL (XT+,HS+,EC+PLL)
// WDT OFF
#pragma config FSOSCEN = ON
#pragma config FPLLMUL = MUL_24, FPLLIDIV = DIV_2, FPLLODIV = DIV_2, FWDTEN = OFF
#pragma config POSCMOD = HS, FNOSC = PRIPLL, FPBDIV = DIV_1
#define SYS_FREQ (48000000L)

#pragma config JTAGEN   = OFF           //JTAG disable

unsigned int led_flag=1,point=0;
rtccTime tm; // 时间结构体变量
rtccDate dt; // 日期结构体变量
//8段LED数码管字库：0~9 0.~9.FSEt-yno
unsigned char Led_lib[] = {0x42, 0xf3, 0x86, 0xa2, 0x33, 0x2a, 0x0a, 0xf2, 0x02, 0x22, 0x40, 0xf1, 0x84, 0xa0, 0x31, 0x28, 0x08, 0xf0, 0x00, 0x20, 0x1e, 0x0e, 0x0f, 0xbf, 0x23, 0x9b, 0x8b}; //小LED字库
/*-------LED段码分布图------
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
/*
 * SPI 初始化函数
 */
void SpiInitDevice() {
    // SPI标志位
    SpiOpenFlags oFlags = SPI_OPEN_MSTEN | SPI_OPEN_CKP_HIGH | SPI_OPEN_MODE8 | SPI_OPEN_ON;
    //输出锁存信号引脚
    PORTSetPinsDigitalOut(IOPORT_B, BIT_9);
    //数据输出引脚
    PPSOutput(2, RPB8, SDO2);
    //打开SPI模块
    SpiChnOpen(2, oFlags, 6);
}
/*
 * SPI输出多个字符
 */
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
/*
 * LED数码管驱动输出
 */
void Led()
{
    static unsigned char ledcnt[4]={0x00, 0x00, 0x00, 0x00};
    int fg = tm.min & 0x0f;
    if(point)                                     //0.5秒切换一次秒点翻转
        fg += 10;
    ledcnt[2] = Led_lib[tm.sec & 0x0f];           //秒：个位
    ledcnt[1] = Led_lib[(tm.sec & 0xf0)>>4];      //秒：十位
    ledcnt[0] = Led_lib[fg];                      //分：个位
    ledcnt[3] = Led_lib[(tm.min & 0xf0)>>4];      //分：十位
    SpiDoBurst(ledcnt,4);
}
/*
 * 主函数
 */
int main(void)
{
    rtccTime tAlrm; // 时间结构体变量
    rtccDate dAlrm; // 日期结构体变量
    //系统初始化
    SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);
    //SPI初始化
    SpiInitDevice();
    //初始化RTCC模块
    RtccInit();
    //等待辅助振荡器启动及RTCC时钟源稳定
    while (RtccGetClkStat() != RTCC_CLK_ON);
    //设置时间，日期
    //第一个变量为时间:用UINT32表示，由高到低的4个字节依次表示：小时，分钟，秒钟，保留
    //其中，保留值必须设置为0.下例中0x0D000000表示：12:00:00
    //第二个变量未日期:用UINT32表示，由高到低的4个字节依次表示：年，月，日，星期
    //下例中0x0D010102表示：2013-01-01,星期二
    RtccOpen(0x0D000000, 0x0D010102, 0);
    //配置中断模式
    INTConfigureSystem(INT_SYSTEM_CONFIG_MULT_VECTOR);
    //使能中断
    INTEnableInterrupts();

    //设置报警时间
    do {
        RtccGetTimeDate(&tm, &dt);
    } while ((tm.sec & 0xf) > 0x7);

    tAlrm.l = tm.l;
    dAlrm.l = dt.l;
    //允许连续报警
    RtccChimeEnable();
    //报警次数计数器清零
    RtccSetAlarmRptCount(0);
    //设置报警间隔：每个0.5s
    RtccSetAlarmRpt(RTCC_RPT_HALF_SEC);
    //设置报警时间
    RtccSetAlarmTimeDate(tAlrm.l, dAlrm.l);
    //使能报警
    RtccAlarmEnable();
    //报警已使能？
    if (RtccGetAlarmEnable())
    {
        //设置RTCC中断、使能中断
        INTSetVectorPriority(INT_RTCC_VECTOR, INT_PRIORITY_LEVEL_4); 
        INTSetVectorSubPriority(INT_RTCC_VECTOR, INT_SUB_PRIORITY_LEVEL_1);
        INTEnable(INT_RTCC, INT_ENABLED);
    }
    //主循环
    while(1)
    {
        if(led_flag > 0)
        {
            led_flag = 0;
            RtccGetTimeDate(&tm, &dt);
            Led();
        }
    }
    return 1;
}
/*
 * RTCC中断函数
 */
void __ISR(_RTCC_VECTOR, ipl4) RtccIsr(void) {
    //清中断标志
    INTClearFlag(INT_RTCC);
    //翻转秒小数点，用来指示秒钟的变化
    point=~point;
    //数码管输出计数器：每0.5秒输出一次
    led_flag = 1;
}
