/*
 * File:   rctt.c
 * ʵʱʱ��ʾ��������ʵʱʱ��ģ�飬ʵ��24Сʱʵʱʱ����ʾ
 * ������ʼʱ��Ϊ��2013-01-01 00:00:00
 * ����SPI������4��8���������ʾʱ�䣨����ʾ���ӣ����ӣ�
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
rtccTime tm; // ʱ��ṹ�����
rtccDate dt; // ���ڽṹ�����
//8��LED������ֿ⣺0~9 0.~9.FSEt-yno
unsigned char Led_lib[] = {0x42, 0xf3, 0x86, 0xa2, 0x33, 0x2a, 0x0a, 0xf2, 0x02, 0x22, 0x40, 0xf1, 0x84, 0xa0, 0x31, 0x28, 0x08, 0xf0, 0x00, 0x20, 0x1e, 0x0e, 0x0f, 0xbf, 0x23, 0x9b, 0x8b}; //СLED�ֿ�
/*-------LED����ֲ�ͼ------
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
 * SPI ��ʼ������
 */
void SpiInitDevice() {
    // SPI��־λ
    SpiOpenFlags oFlags = SPI_OPEN_MSTEN | SPI_OPEN_CKP_HIGH | SPI_OPEN_MODE8 | SPI_OPEN_ON;
    //��������ź�����
    PORTSetPinsDigitalOut(IOPORT_B, BIT_9);
    //�����������
    PPSOutput(2, RPB8, SDO2);
    //��SPIģ��
    SpiChnOpen(2, oFlags, 6);
}
/*
 * SPI�������ַ�
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
 * LED������������
 */
void Led()
{
    static unsigned char ledcnt[4]={0x00, 0x00, 0x00, 0x00};
    int fg = tm.min & 0x0f;
    if(point)                                     //0.5���л�һ����㷭ת
        fg += 10;
    ledcnt[2] = Led_lib[tm.sec & 0x0f];           //�룺��λ
    ledcnt[1] = Led_lib[(tm.sec & 0xf0)>>4];      //�룺ʮλ
    ledcnt[0] = Led_lib[fg];                      //�֣���λ
    ledcnt[3] = Led_lib[(tm.min & 0xf0)>>4];      //�֣�ʮλ
    SpiDoBurst(ledcnt,4);
}
/*
 * ������
 */
int main(void)
{
    rtccTime tAlrm; // ʱ��ṹ�����
    rtccDate dAlrm; // ���ڽṹ�����
    //ϵͳ��ʼ��
    SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);
    //SPI��ʼ��
    SpiInitDevice();
    //��ʼ��RTCCģ��
    RtccInit();
    //�ȴ���������������RTCCʱ��Դ�ȶ�
    while (RtccGetClkStat() != RTCC_CLK_ON);
    //����ʱ�䣬����
    //��һ������Ϊʱ��:��UINT32��ʾ���ɸߵ��͵�4���ֽ����α�ʾ��Сʱ�����ӣ����ӣ�����
    //���У�����ֵ��������Ϊ0.������0x0D000000��ʾ��12:00:00
    //�ڶ�������δ����:��UINT32��ʾ���ɸߵ��͵�4���ֽ����α�ʾ���꣬�£��գ�����
    //������0x0D010102��ʾ��2013-01-01,���ڶ�
    RtccOpen(0x0D000000, 0x0D010102, 0);
    //�����ж�ģʽ
    INTConfigureSystem(INT_SYSTEM_CONFIG_MULT_VECTOR);
    //ʹ���ж�
    INTEnableInterrupts();

    //���ñ���ʱ��
    do {
        RtccGetTimeDate(&tm, &dt);
    } while ((tm.sec & 0xf) > 0x7);

    tAlrm.l = tm.l;
    dAlrm.l = dt.l;
    //������������
    RtccChimeEnable();
    //������������������
    RtccSetAlarmRptCount(0);
    //���ñ��������ÿ��0.5s
    RtccSetAlarmRpt(RTCC_RPT_HALF_SEC);
    //���ñ���ʱ��
    RtccSetAlarmTimeDate(tAlrm.l, dAlrm.l);
    //ʹ�ܱ���
    RtccAlarmEnable();
    //������ʹ�ܣ�
    if (RtccGetAlarmEnable())
    {
        //����RTCC�жϡ�ʹ���ж�
        INTSetVectorPriority(INT_RTCC_VECTOR, INT_PRIORITY_LEVEL_4); 
        INTSetVectorSubPriority(INT_RTCC_VECTOR, INT_SUB_PRIORITY_LEVEL_1);
        INTEnable(INT_RTCC, INT_ENABLED);
    }
    //��ѭ��
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
 * RTCC�жϺ���
 */
void __ISR(_RTCC_VECTOR, ipl4) RtccIsr(void) {
    //���жϱ�־
    INTClearFlag(INT_RTCC);
    //��ת��С���㣬����ָʾ���ӵı仯
    point=~point;
    //����������������ÿ0.5�����һ��
    led_flag = 1;
}
