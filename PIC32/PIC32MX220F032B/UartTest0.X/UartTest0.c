 /*
 * File:   RS232Example.c
 * Author: bincker
 */

#include <plib.h>
// 时钟配置:使用内部振荡器，禁用辅助振荡器，禁用看门狗，总线始终倍频到48MHz
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
// 关闭JTAG功能，将相关端口释放给IO口控制，禁用USBIDIO，将对应端口释放给IO控制
#pragma config JTAGEN = OFF,FUSBIDIO = OFF
// UART1宏定义
#define	GetPeripheralClock() (SYS_FREQ/(1 << OSCCONbits.PBDIV))
#define UART_MODULE_ID UART1            // 选择模块1
#define DESIRED_BAUDRATE    (1200)      // 波特率
 
 
void UARTinit();
void PutCharacter(BYTE);

 
int main(void)
{
 
    SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);
 
    INTDisableInterrupts();
    INTConfigureSystem(INT_SYSTEM_CONFIG_MULT_VECTOR);
 
    UARTinit();
   
    INTEnableInterrupts();
 
    while(1)
    {
     
    }
}

void UARTinit()
{
 
    ANSELBbits.ANSB2 = 0;       // Disable AN4
//    PORTSetPinsDigitalOut(IOPORT_B, BIT_7 );
//    PORTSetPinsDigitalIn( IOPORT_B,  BIT_2 );
    PPSInput(3,U1RX,RPB2);      // Assign RPB2 as input pin for U1RX
    PPSOutput(1,RPB7,U1TX);     // Set RPB7 pin as output for U1TX

 
    UARTConfigure(UART_MODULE_ID, UART_ENABLE_PINS_TX_RX_ONLY);
    UARTSetFifoMode(UART_MODULE_ID, UART_INTERRUPT_ON_TX_NOT_FULL | UART_INTERRUPT_ON_RX_NOT_EMPTY);
    UARTSetLineControl(UART_MODULE_ID, UART_DATA_SIZE_8_BITS | UART_PARITY_NONE | UART_STOP_BITS_1);
    UARTSetDataRate(UART_MODULE_ID, GetPeripheralClock(), DESIRED_BAUDRATE);
    UARTEnable(UART_MODULE_ID, UART_ENABLE_FLAGS(UART_PERIPHERAL | UART_RX | UART_TX));

 
    INTEnable(INT_SOURCE_UART_RX(UART_MODULE_ID), INT_ENABLED);
    INTSetVectorPriority(INT_VECTOR_UART(UART_MODULE_ID), INT_PRIORITY_LEVEL_2);
    INTSetVectorSubPriority(INT_VECTOR_UART(UART_MODULE_ID), INT_SUB_PRIORITY_LEVEL_0);
}

void PutCharacter(BYTE character)
{
        while(!UARTTransmitterIsReady(UART_MODULE_ID));
        UARTSendDataByte(UART_MODULE_ID, character);
        while(!UARTTransmissionHasCompleted(UART_MODULE_ID));
}
 
void __ISR(_UART_1_VECTOR, ipl2) IntUart1Handler(void)
{
    // Is this an RX interrupt?
    if(INTGetFlag(INT_SOURCE_UART_RX(UART_MODULE_ID)))
    {
        BYTE t;
        t = UARTGetDataByte(UART_MODULE_ID);
        
        PutCharacter('g');
        // Clear the RX interrupt Flag
        INTClearFlag(INT_SOURCE_UART_RX(UART_MODULE_ID));
    }
    // We don't care about TX interrupt
    if (INTGetFlag(INT_SOURCE_UART_TX(UART_MODULE_ID)))
    {
        INTClearFlag(INT_SOURCE_UART_TX(UART_MODULE_ID));
    }
}