/*
 * File:   RS232Example.c
 * Author: bincker
 */

#include <plib.h>
// ʱ������:ʹ���ڲ����������ø������������ÿ��Ź�������ʼ�ձ�Ƶ��48MHz
// SYSCLK = 48 MHz (8MHz Crystal / FPLLIDIV * FPLLMUL / FPLLODIV)
// PBCLK = 48 MHz (SYSCLK / FPBDIV)
// Primary Osc w/PLL (XT+,HS+,EC+PLL)
// WDT OFF
// Disable SOSC
#pragma config FPLLMUL = MUL_24, FPLLIDIV = DIV_2, FPLLODIV = DIV_2, FWDTEN = OFF
#pragma config POSCMOD = OFF, FNOSC = FRCPLL, FPBDIV = DIV_1, FSOSCEN = OFF
#define SYS_FREQ (48000000L)
// Period needed for timer 1 to trigger an interrupt every 0.1 second
// (48MHz PBCLK / 1 = 48000000KHz Timer 1 clock)
#define PERIOD  48000                           //48000/48000000 = 0.001s = 1ms
// �ر�JTAG���ܣ�����ض˿��ͷŸ�IO�ڿ��ƣ�����USBIDIO������Ӧ�˿��ͷŸ�IO����
#pragma config JTAGEN = OFF,FUSBIDIO = OFF
// UART1�궨��
#define	GetPeripheralClock() (SYS_FREQ/(1 << OSCCONbits.PBDIV))
#define UART_MODULE_ID UART1            // ѡ��ģ��1
#define DESIRED_BAUDRATE    (1200)      // ������
//��ťɨ����ʱ����ť״̬����BTN_DELAY����ʱ���ڣ��򴥷�һ�ΰ�ť����
#define BTN_DELAY   2 //2*1=2ms
//ȫ�ֱ�������
unsigned int led_cnt=0,led_flag=1;
unsigned int btn_cnt=0,BtnCnt_t[]={0,0,0},btn_flag=0;
//������ֿ⣺0~9,0.~9. FSEt-yno
unsigned char Led_lib[] = {0x42, 0xf3, 0x86, 0xa2, 0x33, 0x2a, 0x0a, 0xf2, 0x02, 0x22, 0x40, 0xf1, 0x84, 0xa0, 0x31, 0x28, 0x08, 0xf0, 0x00, 0x20, 0x1e, 0x0e, 0x0f, 0xbf, 0x23, 0x9b, 0x8b}; //СLED�ֿ�
void PutCharacter(const char);
/*********************************
 * SPI��ʼ��
 *********************************/
void SpiInitDevice() {
    // 8 bits/char, input data sampled at end of data output time
    SpiOpenFlags oFlags = SPI_OPEN_MSTEN | SPI_OPEN_CKP_HIGH | SPI_OPEN_MODE8 | SPI_OPEN_ON;
    PORTSetPinsDigitalOut(IOPORT_B, BIT_9);
    PPSOutput(2, RPB8, SDO2); // Set RB8 pin as output for SDO2
    // Open SPI module, use SPI channel 2, use flags set above, Divide Fpb by 6
    SpiChnOpen(2, oFlags, 6);
}
/*********************************
 * SPI�������ַ�
 *********************************/
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
/*********************************
 * LED�������ʾ����װ�غ����
 *********************************/
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
        ledBuff[i] = Led_lib[BtnCnt_t[i]];
    ledBuff[3] = Led_lib[led];
}
/*********************************
 * Timer1��ʼ��
 *********************************/
void Timer1Init()
{
    // Timer1@1ms
    OpenTimer1(T1_ON | T1_SOURCE_INT | T1_PS_1_1, PERIOD);
    // Set up the timer interrupt with a priority of 2
    INTEnable(INT_T1, INT_ENABLED);
    INTSetVectorPriority(INT_TIMER_1_VECTOR, INT_PRIORITY_LEVEL_2);
    INTSetVectorSubPriority(INT_TIMER_1_VECTOR, INT_SUB_PRIORITY_LEVEL_0);
}
/*********************************
 * Timer1�жϳ���
 *********************************/
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
/*********************************
 * ��ť�˿ڳ�ʼ��
 *********************************/
void BtnInit()
{
    ANSELAbits.ANSA0 = 0;
    ANSELAbits.ANSA1 = 0;
    ANSELBbits.ANSB14 = 0;
}
/*********************************
 * ��ťɨ����򣺰�ť����ʱ
 * ��UART���һ��ָ���ַ�
 *********************************/
void Button(void) {
    static int btn1=0,btn2=0,btn3=0;
    if(PORTAbits.RA0 == 0)
    {
        btn1 ++;
        if(btn1 == BTN_DELAY)
        {
            PutCharacter(0xA0);
        }
    }
    else
        btn1 = 0;
    if(PORTAbits.RA1 == 0)
    {
        btn2++;
        if(btn2 == BTN_DELAY)
        {
            PutCharacter(0xA1);
        }
    }
    else
        btn2 = 0;
    if(PORTBbits.RB14 == 0)
    {
        btn3 ++;
        if(btn3 == BTN_DELAY)
        {
            PutCharacter(0xA2);
        }
    }
    else
        btn3 = 0;
}
/*********************************
 * UART���һ���ַ�
 *********************************/
void PutCharacter(const char character)
{
        while(!UARTTransmitterIsReady(UART_MODULE_ID))
            ;
        UARTSendDataByte(UART_MODULE_ID, character);
        while(!UARTTransmissionHasCompleted(UART_MODULE_ID))
            ;
}
/*********************************
 * UART1�жϷ������
 *********************************/
void __ISR(_UART_1_VECTOR, ipl2) IntUart1Handler(void)
{
    // Is this an RX interrupt?
    if(INTGetFlag(INT_SOURCE_UART_RX(UART_MODULE_ID)))
    {
        int i;
        BYTE t;
        t = UARTGetDataByte(UART_MODULE_ID);
        switch(t)
        {
            case 0xA0:
                i=0;
                break;
            case 0xA1:
                i=1;
                break;
            case 0xA2:
                i=2;
                break;
            default:
                i=0xff;
                break;
        }
        if(i < 0xff)
        {
            BtnCnt_t[i]++;
            if(BtnCnt_t[i] > 9)
                BtnCnt_t[i] = 0;
        }
        // Clear the RX interrupt Flag
        INTClearFlag(INT_SOURCE_UART_RX(UART_MODULE_ID));
    }
    // We don't care about TX interrupt
    if (INTGetFlag(INT_SOURCE_UART_TX(UART_MODULE_ID)))
    {
        INTClearFlag(INT_SOURCE_UART_TX(UART_MODULE_ID));
    }
}
/*********************************
 * UART��ʼ��
 *********************************/
void UARTinit()
{
    //��������
    ANSELBbits.ANSB2 = 0;       // Disable AN4
    PPSInput(3,U1RX,RPB2);      // Assign RPB2 as input pin for U1RX
    PPSOutput(1,RPB7,U1TX);     // Set RPB7 pin as output for U1TX

    //UART1ģ���ʼ��������Ϊ����ͨ�š�8λ���ݡ�1λֹͣ����У�顢����TX��RX����...��
    UARTConfigure(UART_MODULE_ID, UART_ENABLE_PINS_TX_RX_ONLY);
    UARTSetFifoMode(UART_MODULE_ID, UART_INTERRUPT_ON_TX_NOT_FULL | UART_INTERRUPT_ON_RX_NOT_EMPTY);
    UARTSetLineControl(UART_MODULE_ID, UART_DATA_SIZE_8_BITS | UART_PARITY_NONE | UART_STOP_BITS_1);
    UARTSetDataRate(UART_MODULE_ID, GetPeripheralClock(), DESIRED_BAUDRATE);
    UARTEnable(UART_MODULE_ID, UART_ENABLE_FLAGS(UART_PERIPHERAL | UART_RX | UART_TX));

    //UART1�ж�����
    INTEnable(INT_SOURCE_UART_RX(UART_MODULE_ID), INT_ENABLED);
    INTSetVectorPriority(INT_VECTOR_UART(UART_MODULE_ID), INT_PRIORITY_LEVEL_2);
    INTSetVectorSubPriority(INT_VECTOR_UART(UART_MODULE_ID), INT_SUB_PRIORITY_LEVEL_0);
}
/*********************************
 * ������
 *********************************/
int main(void)
{
    int task=0;
    //ϵͳʱ�ӳ�ʼ��
    SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);
    //��ֹ�жϡ������ж�ģʽ
    INTDisableInterrupts();
    INTConfigureSystem(INT_SYSTEM_CONFIG_MULT_VECTOR);
    //��ʼ������ģ��
    UARTinit();
    SpiInitDevice();
    BtnInit();
    Timer1Init();
    //�����ж�
    INTEnableInterrupts();
    //��ѭ��
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
}
