/*
 * USB_HID_Example.c
 */
#include "Include\GenericTypeDefs.h"
#include "Include\HardwareProfile\HardwareProfile.h"
#include "Include\USB_HID_Example.h"
#include "Include\FrameWork\Framework.h"
#include <stdlib.h>
#include <plib.h>


// Configuring the Device Configuration Registers
// 40Mhz Core/Periph, Pri Osc w/PLL, Write protect Boot Flash
#if defined(TRANSPORT_LAYER_USB) || defined(TRANSPORT_LAYER_USB_HOST)
#pragma config UPLLEN   = ON        // USB PLL Enabled
#pragma config UPLLIDIV = DIV_2     // USB PLL Input Divider = Divide by 2
#endif

#pragma config DEBUG    = OFF           // Background Debugger disabled
#pragma config FPLLMUL = MUL_20         // PLL Multiplier: Multiply by 20
#pragma config FPLLIDIV = DIV_2         // PLL Input Divider:  Divide by 2

#pragma config FPLLODIV = DIV_2         // PLL Output Divider: Divide by 2

#pragma config FWDTEN = OFF             // WD timer: OFF
#pragma config POSCMOD = HS             // Primary Oscillator Mode: High Speed xtal
#pragma config FNOSC = PRIPLL           // Oscillator Selection: Primary oscillator  w/ PLL
#pragma config FPBDIV = DIV_1           // Peripheral Bus Clock: Divide by 1
#pragma config BWP = OFF                // Boot write protect: OFF

#pragma config ICESEL = ICS_PGx1        // ICE pins configured on PGx1 (PGx2 is multiplexed with USB D+ and D- pins).
#pragma config JTAGEN   = OFF           //JTAG disable

#define PERIOD  40000       //40000/40000000 = 0.001s = 1ms
#define BTN_DELAY   5       //2*1=2ms
#define BTN_PUSH    200     //200ms
#define SWITCH_PRESSED 0

unsigned int btn_cnt=0,btn_flag=0,update_flag=1,counter=0;
UINT8 Btn_Status = 0;

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
    btn_cnt++;
    if(btn_cnt > 5)     //5ms
    {
        btn_cnt = 0;
        btn_flag = 1;
        counter++;
    }
}
void BtnInit()
{
    ANSELAbits.ANSA0 = 0; //Button
}
void ButtonScan(void) {
    static int btn1=0;
    if(PORTAbits.RA0 == 0)
    {
        btn1 ++;
        if(btn1 == BTN_DELAY) //Button1 Pressed
        {
            ButtonPress(1,TRUE);
        }
    }
    else if(btn1 > 0)
    {
        btn1 = 0;
        ButtonPress(1,FALSE);
    }
}
void ButtonPress(int button,BOOL press)
{
    UINT8 set=0,clear=0xff;
    switch(button)
    {
        case 1:
            set = 0x01;
            clear = 0xfe;
            break;
        default:
            break;
    }
    if(press)
        Btn_Status |= set;
    else
        Btn_Status &= clear;
    update_flag = 1;
}
void Light(int light,BOOL on)
{
    if(on)
        PORTClearBits(IOPORT_B,BIT_7);
    else
        PORTSetBits(IOPORT_B,BIT_7);
}
INT main(void) {
    UINT pbClk;
    int task=0;
    // Setup configuration
    pbClk = SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);

    InitLED();

    INTDisableInterrupts();
    INTConfigureSystem(INT_SYSTEM_CONFIG_MULT_VECTOR);

    BtnInit();
    Timer1Init();
    TRANS_LAYER_Init(pbClk);
    
    INTEnableInterrupts();
    // Enter firmware upgrade mode if there is a trigger or if the application is not valid

    while (1)
    {
        switch(task)
        {
            case 0:
                TRANS_LAYER_Task();
                FRAMEWORK_FrameWorkTask();
                BlinkLED();
                break;
            case 1:
                if(btn_flag > 0)
                {
                    btn_flag = 0;
                    ButtonScan();
                }
                break;
            case 2:
                if(update_flag > 0)
                {
                    update_flag = 0;
                    UpdateData(Btn_Status);
                }
                break;
            default:
                break;
        }
        task ++;
        if(task > 2) task = 0;
    }

    return 0;
}
