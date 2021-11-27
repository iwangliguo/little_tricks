/*
 * Framework.c
 */
#include "GenericTypeDefs.h"
#include "HardwareProfile.h"
#include "Include\USB_HID_Example.h"
#include "Include\Framework\Framework.h"
#include  <string.h>
#include <plib.h>

#define DATA_RECORD 		0
#define END_OF_FILE_RECORD 	1
#define EXT_SEG_ADRS_RECORD 2
#define EXT_LIN_ADRS_RECORD 4

#if defined(__PIC32MX1XX_2XX__)
// PIC32MX1xx and PIC32MX2xx devices
#define FLASH_PAGE_SIZE		 		1024
#define DEV_CONFIG_REG_BASE_ADDRESS 0x9FC00BF0
#define DEV_CONFIG_REG_END_ADDRESS   0x9FC00BFF
#elif defined(__PIC32MX3XX_7XX__)
// PIC32MX3xx to PIC32MX7xx devices
#define FLASH_PAGE_SIZE		 		4096
#define DEV_CONFIG_REG_BASE_ADDRESS 0x9FC02FF0
#define DEV_CONFIG_REG_END_ADDRESS   0x9FC02FFF
#endif

typedef enum {
    LIGHT = 1,
    BUTTON 
} T_COMMANDS;

typedef struct {
    UINT Len;
    UINT8 Data[FRAMEWORK_BUFF_SIZE];

} T_FRAME;

typedef struct {
    UINT8 RecDataLen;
    DWORD_VAL Address;
    UINT8 RecType;
    UINT8* Data;
    UINT8 CheckSum;
    DWORD_VAL ExtSegAddress;
    DWORD_VAL ExtLinAddress;
} T_HEX_RECORD;


static T_FRAME RxBuff;
static T_FRAME TxBuff;
static BOOL RxFrameValid;
static BOOL TriggerBaudChange;
static DWORD_VAL NewBaud;
static BOOL RunApplication = FALSE;

void HandleCommand(void);
void BuildRxFrame(UINT8 *RxData, INT16 RxLen);
UINT GetTransmitFrame(UINT8* Buff);
BOOL BaudRateChangeRequested(void);
UINT16 CalculateCrc(UINT8 *data, UINT32 len);

/********************************************************************
 * Function: 	FrameWorkTask()
 *
 * Precondition:
 *
 * Input: 		None.
 *
 * Output:		None.
 *
 * Side Effects:	None.
 *
 * Overview: 	Process the command if there is a valid fame.
 *
 *
 * Note:		 	None.
 ********************************************************************/
void FrameWorkTask(void) {

    if (RxFrameValid) {
        // Valid frame received, process the command.
        HandleCommand();
        // Reset the flag.
        RxFrameValid = FALSE;
    }
}

/********************************************************************
 * Function: 	HandleCommand()
 *
 * Precondition:
 *
 * Input: 		None.
 *
 * Output:		None.
 *
 * Side Effects:	None.
 *
 * Overview: 	Process the received frame and take action depending on
                                the command received.
 *
 *
 * Note:		 	None.
 ********************************************************************/
void HandleCommand(void) {
    UINT8 Cmd,light,action;

    // First byte of the data field is command.
    Cmd = RxBuff.Data[0];
    // Partially build response frame. First byte in the data field carries command.
    TxBuff.Data[0] = RxBuff.Data[0];
    light = RxBuff.Data[1];
    action = RxBuff.Data[2];
    // Reset the response length to 0.
    TxBuff.Len = 0;

    // Process the command.
    switch (Cmd) {
        case LIGHT: // LIGHT pushdown once
            Light(light,action);
            break;
        default:
            break;
    }
}

/********************************************************************
 * Function: 	BuildRxFrame()
 *
 * Precondition:
 *
 * Input: 		Pointer to Rx Data and Rx byte length.
 *
 * Output:		None.
 *
 * Side Effects:	None.
 *
 * Overview: 	Builds rx frame and checks CRC.
 *
 *
 * Note:		 	None.
 ********************************************************************/
void BuildRxFrame(UINT8 *RxData, INT16 RxLen) {
    static BOOL Escape = FALSE;
    WORD_VAL crc;

    while ((RxLen > 0) && (!RxFrameValid)) // Loop till len = 0 or till frame is valid
    {
        RxLen--;

        if (RxBuff.Len >= sizeof (RxBuff.Data)) {
            RxBuff.Len = 0;
        }

        switch (*RxData) {

            case SOH: //Start of header
                if (Escape) {
                    // Received byte is not SOH, but data.
                    RxBuff.Data[RxBuff.Len++] = *RxData;
                    // Reset Escape Flag.
                    Escape = FALSE;
                } else {
                    // Received byte is indeed a SOH which indicates start of new frame.
                    RxBuff.Len = 0;
                }
                break;

            case EOT: // End of transmission
                if (Escape) {
                    // Received byte is not EOT, but data.
                    RxBuff.Data[RxBuff.Len++] = *RxData;
                    // Reset Escape Flag.
                    Escape = FALSE;
                } else {
                    // Received byte is indeed a EOT which indicates end of frame.
                    // Calculate CRC to check the validity of the frame.
                    if (RxBuff.Len > 1) {
                        crc.byte.LB = RxBuff.Data[RxBuff.Len - 2];
                        crc.byte.HB = RxBuff.Data[RxBuff.Len - 1];
                        if ((CalculateCrc(RxBuff.Data, (UINT32) (RxBuff.Len - 2)) == crc.Val) && (RxBuff.Len > 2)) {
                            // CRC matches and frame received is valid.
                            RxFrameValid = TRUE;

                        }
                    }

                }
                break;
            case DLE: // Escape character received.
                if (Escape) {
                    // Received byte is not ESC but data.
                    RxBuff.Data[RxBuff.Len++] = *RxData;
                    // Reset Escape Flag.
                    Escape = FALSE;
                } else {
                    // Received byte is an escape character. Set Escape flag to escape next byte.
                    Escape = TRUE;
                }
                break;

            default: // Data field.
                RxBuff.Data[RxBuff.Len++] = *RxData;
                // Reset Escape Flag.
                Escape = FALSE;
                break;
        }

        //Increment the pointer.
        RxData++;

    }

}

/********************************************************************
 * Function: 	GetTransmitFrame()
 *
 * Precondition:
 *
 * Input: 		Buffer pointer.
 *
 * Output:		Length of the buffer.
 *
 * Side Effects:	None.
 *
 * Overview: 	Gets the complete transmit frame into the "Buff".
 *
 *
 * Note:		 	None.
 ********************************************************************/
UINT GetTransmitFrame(UINT8* Buff) {
    INT BuffLen = 0;
    WORD_VAL crc;
    UINT8 i;

    if (TxBuff.Len) {
        //There is something to transmit.
        // Calculate CRC of the frame.
        crc.Val = CalculateCrc(TxBuff.Data, (UINT32) TxBuff.Len);
        TxBuff.Data[TxBuff.Len++] = crc.byte.LB;
        TxBuff.Data[TxBuff.Len++] = crc.byte.HB;

        // Insert SOH (Indicates beginning of the frame)
        Buff[BuffLen++] = SOH;

        // Insert Data Link Escape Character.
        for (i = 0; i < TxBuff.Len; i++) {
            if ((TxBuff.Data[i] == EOT) || (TxBuff.Data[i] == SOH)
                    || (TxBuff.Data[i] == DLE)) {
                // EOT/SOH/DLE repeated in the data field, insert DLE.
                Buff[BuffLen++] = DLE;
            }
            Buff[BuffLen++] = TxBuff.Data[i];
        }

        // Mark end of frame with EOT.
        Buff[BuffLen++] = EOT;

        TxBuff.Len = 0; // Purge this buffer, no more required.
    }

    return (BuffLen); // Return buffer length.

}
BOOL UpdateData(UINT8 data)
{
    if(TxBuff.Len)
        return FALSE;
    TxBuff.Data[0] = BUTTON;
    TxBuff.Data[1] = data;
    TxBuff.Len = 2;
    return TRUE;
}

/**
 * Static table used for the table_driven implementation.
 *****************************************************************************/
static const UINT16 crc_table[16] ={
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
    0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef
};

/********************************************************************
 * Function: 	CalculateCrc()
 *
 * Precondition:
 *
 * Input: 		Data pointer and data length
 *
 * Output:		CRC.
 *
 * Side Effects:	None.
 *
 * Overview:     Calculates CRC for the given data and len
 *
 *
 * Note:		 	None.
 ********************************************************************/
UINT16 CalculateCrc(UINT8 *data, UINT32 len) {
    UINT i;
    UINT16 crc = 0;

    while (len--) {
        i = (crc >> 12) ^ (*data >> 4);
        crc = crc_table[i & 0x0F] ^ (crc << 4);
        i = (crc >> 12) ^ (*data >> 0);
        crc = crc_table[i & 0x0F] ^ (crc << 4);
        data++;
    }

    return (crc & 0xFFFF);
}

/**************************End of file**************************************************/

