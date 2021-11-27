#include "stdafx.h"
#include "USB_HID.h"
#include "USB_HID_Example.h"
#include "USBHIDEXP.h"
#include "USBHIDEXPDlg.h"
#include ".\USBHIDEXPdlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

#define SOH 01
#define EOT 04
#define DLE 16


/**
 * Static table used for the table_driven implementation.
 *****************************************************************************/
static const unsigned short crc_table[16] = 
{
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
    0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef
};

/****************************************************************************
 * Update the crc value with new data.
 *
 * \param crc      The current crc value.
 * \param data     Pointer to a buffer of \a data_len bytes.
 * \param len		Number of bytes in the \a data buffer.
 * \return         The updated crc value.
 *****************************************************************************/
unsigned short CalculateCrc(char *data, unsigned int len)
{
    unsigned int i;
    unsigned short crc = 0;
    
    while(len--)
    {
        i = (crc >> 12) ^ (*data >> 4);
	    crc = crc_table[i & 0x0F] ^ (crc << 4);
	    i = (crc >> 12) ^ (*data >> 0);
	    crc = crc_table[i & 0x0F] ^ (crc << 4);
	    data++;
	} 

    return (crc & 0xFFFF);
}

/****************************************************************************
 *  This thread calls receive and transmit tasks
 *
 * \param lpParam  this Pointer
 

 * \return  0 on exit.
 *****************************************************************************/
UINT RxTxThread(LPVOID lpParam)
{
	CUSBHIDExample *USBHIDExamplePtr = (CUSBHIDExample *)lpParam;

	while(USBHIDExamplePtr->ExitThread == FALSE)
	{
		
		USBHIDExamplePtr->ReceiveTask();
		USBHIDExamplePtr->TransmitTask();
		Sleep(1);
	}
	USBHIDExamplePtr->ThreadKilled = TRUE;

	return 0;
}




/****************************************************************************
 * Shut down the Receive transmit thread.
 *
 * \param       
 * \param      
 * \param 		
 * \return         
 *****************************************************************************/
void CUSBHIDExample::ShutdownThread( )
{
   HRESULT hr = S_OK;
  
   if(BtlThread)
   {
	   // Set a flag to exit the thread
	   ExitThread = TRUE;
	   ThreadKilled = FALSE;
	   Sleep(1000); // Sleep for 1 second.
	   if(ThreadKilled == FALSE)
	   {
		   // Thread was not killed. Kill thread by force.
			::TerminateThread( BtlThread, -1000 );
			// Close the handle and NULL it out
			::CloseHandle( BtlThread );
	   }

	   

	   // Set the thread handle to NULL
	   BtlThread = NULL;
   }
}

/****************************************************************************
 * Create	Thread
 *
 * \param   hWnd  Main Window Handle 
 * \param      
 * \param 		
 * \return         
 *****************************************************************************/
void CUSBHIDExample::CreateRxTxThread(HWND hWnd)
{
	m_hWnd = hWnd; // required for posting messages
	if(BtlThread)
	{
		return; // Thread is already running.
		
	}
	ExitThread = false;
	BtlThread = ::AfxBeginThread(RxTxThread, this, THREAD_PRIORITY_NORMAL, 0, 0, 0);
	
}


/****************************************************************************
 *  Receive Task
 *
 * \param   
 * \param      
 * \param 		
 * \return         
 *****************************************************************************/
void CUSBHIDExample::ReceiveTask(void)
{
	unsigned short BuffLen;
	char Buff[255];
	
	BuffLen = ReadPort((char*)Buff, (sizeof(Buff) - 10));
	BuildRxFrame((unsigned char*)Buff, BuffLen);
	if(RxFrameValid)
	{
		// Valid frame is received.
		// Disable further retries.
		StopTxRetries();
		RxFrameValid = false;
		// Handle Response
		HandleResponse();
	}
	else
	{
		// Retries exceeded. There is no reponse from the device.
		if(NoResponseFromDevice)
		{
			// Reset flags
			NoResponseFromDevice = false;
            RxFrameValid = false;		
			// Handle no response situation.
			HandleNoResponse();
		}
	}
}


/****************************************************************************
 *  Handle no response situation
 *
 * \param   
 * \param      
 * \param 		
 * \return         
 *****************************************************************************/
void CUSBHIDExample::HandleNoResponse(void)
{
	// Handle no response situation depending on the last sent command.
	switch(LastSentCommand)
	{
		case LIGHT:
			// Notify main window that there was no reponse.
			::PostMessage(m_hWnd, WM_USER_USBHIDExample_NO_RESP, (WPARAM)LastSentCommand, 0 );
			break;

	}
}

/****************************************************************************
 *  Handle Response situation
 *
 * \param   
 * \param      
 * \param 		
 * \return         
 *****************************************************************************/
void CUSBHIDExample::HandleResponse(void)
{
	unsigned char cmd = RxData[0];
	unsigned char data = RxData[1];
	CString string;

	switch(cmd)
	{
	case LIGHT:
		// Notify main window that command received successfully.
		::PostMessage(m_hWnd, WM_USER_USBHIDExample_RESP_OK, (WPARAM)cmd, (LPARAM)&RxData[1] );
		break;

	case BUTTON:
		if(bTransmitResp)
		{
			bTransmitResp = false;
			break;
		}
		BS_Old1 = ButtonStatus1;
		ButtonStatus1 = RxData[1];
		bUpdate = (BS_Old1 != ButtonStatus1);
		::PostMessage(m_hWnd, WM_USER_USBHIDExample_BTNSTA, (WPARAM)cmd, (LPARAM)&RxData[1] );
		break;
	}
}

bool CUSBHIDExample::GetUpdateStatus(unsigned char *data)
{
	if(bUpdate)
	{
		if(data)
		{
			data[0] = ButtonStatus1;
			BS_Old1 = ButtonStatus1;
		}
		bUpdate = FALSE;
		return TRUE;
	}
	return FALSE;
}

/****************************************************************************
 *  Builds the response frame
 *
 * \param  buff: Pointer to the data buffer 
 * \param  buffLen: Buffer length    
 * \param 		
 * \return         
 *****************************************************************************/
void CUSBHIDExample::BuildRxFrame(unsigned char *buff, unsigned short buffLen)
{

	static bool Escape = false;
	unsigned short crc;
	
	
	while((buffLen > 0) && (RxFrameValid == false))
	{
		buffLen --;

		if(RxDataLen >= (sizeof(RxData)-2))
		{
			RxDataLen = 0;			
		}

		switch(*buff)
		{
			
			
			case SOH: //Start of header
				if(Escape)
				{
					// Received byte is not SOH, but data.
					RxData[RxDataLen++] = *buff;
					// Reset Escape Flag.
					Escape = FALSE;
				}
				else
				{
					// Received byte is indeed a SOH which indicates start of new frame.
					RxDataLen = 0;					
				}		
				break;
				
			case EOT: // End of transmission
				if(Escape)
				{
					// Received byte is not EOT, but data.
					RxData[RxDataLen++] = *buff;
					// Reset Escape Flag.
					Escape = FALSE;
				}
				else
				{
					// Received byte is indeed a EOT which indicates end of frame.
					// Calculate CRC to check the validity of the frame.
					if(RxDataLen > 1)
					{
						crc = (RxData[RxDataLen-2]) & 0x00ff;
						crc = crc | ((RxData[RxDataLen-1] << 8) & 0xFF00);
						if((CalculateCrc(RxData, (RxDataLen-2)) == crc) && (RxDataLen > 2))
						{
							// CRC matches and frame received is valid.
							RxFrameValid = TRUE;						
						}
					}
				}							
				break;
				
				
		    case DLE: // Escape character received.
				if(Escape)
				{
					// Received byte is not ESC but data.
					RxData[RxDataLen++] = *buff;
					// Reset Escape Flag.
					Escape = FALSE;					
				}
				else
				{
					// Received byte is an escape character. Set Escape flag to escape next byte.
					Escape = TRUE;	
				}	
				break;
			
			default: // Data field.
			    RxData[RxDataLen++] = *buff;
			    // Reset Escape Flag.
			    Escape = FALSE;
				break;	
			
		}	
		// Increment the pointer.
		buff++;	
		
	}	
}


/****************************************************************************
 *  Transmit task: Transmits frame if there is a frame to send.
 *
 * \param   
 * \param   
 * \param 		
 * \return         
 *****************************************************************************/
void CUSBHIDExample::TransmitTask(void)
{
	static unsigned long NextRetryTimeInMs;

	switch(TxState)
	{

	case FIRST_TRY:
		if(RetryCount)
		{
			// There is something to send.
			WritePort(TxPacket, TxPacketLen);
			RetryCount--;
			// If there is no response to "first try", the command will be retried.
			TxState = RE_TRY;
			// Next retry should be attempted only after a delay.
			NextRetryTimeInMs = GetTickCount() + TxRetryDelay;
		}
		break;

	case RE_TRY:
		if(RetryCount)
		{			
			if(NextRetryTimeInMs < GetTickCount())
			{
				// Delay elapsed. Its time to retry.
				NextRetryTimeInMs = GetTickCount() + TxRetryDelay;
				WritePort(TxPacket, TxPacketLen);
				// Decrement retry count.
				RetryCount--;
				
			}
		}
		else
		{	
			// Retries Exceeded
			NoResponseFromDevice = true;
			// Reset the state
			TxState = FIRST_TRY;
		}
		break;
	}
}


/****************************************************************************
 *  Stops transmission retries
 *
 * \param   
 * \param   
 * \param 		
 * \return         
 *****************************************************************************/
void CUSBHIDExample::StopTxRetries(void)
{
	// Reset state.
	TxState = FIRST_TRY;
	RetryCount = 0;
}


/****************************************************************************
 *  Send Command
 *
 * \param		cmd:  Command  
 * \param		data: Pointer to data buffer if any
 * \param 		dataLen: Data length
 * \param		retries: Number of retries allowed
 * \param		retryDelayInMs: Delay between retries in milisecond
 * \return         
 *****************************************************************************/
char Buff[1000];

bool CUSBHIDExample::SendCommand(char cmd, unsigned short Retries, unsigned short DelayInMs,unsigned char light,unsigned char action)
{
	unsigned short crc;

	unsigned short BuffLen = 0;
	UINT totalRecords = 10;
	TxPacketLen = 0;

	// Store for later use.
	LastSentCommand = cmd;

	switch((unsigned char)cmd)
	{
	case LIGHT:
		Buff[BuffLen++] = cmd;
		Buff[BuffLen++] = light;
		Buff[BuffLen++] = action;
		MaxRetry = RetryCount = Retries;	
		TxRetryDelay = DelayInMs; // in ms
		bTransmitResp = true;
		break;
	default:
		return false;
		break;

	}

	// Calculate CRC for the frame.
	crc = CalculateCrc(Buff, BuffLen);
	Buff[BuffLen++] = (char)crc;
	Buff[BuffLen++] = (char)(crc >> 8);

	// SOH: Start of header
	TxPacket[TxPacketLen++] = SOH;

	// Form TxPacket. Insert DLE in the data field whereever SOH and EOT are present.
	for(int i = 0; i < BuffLen; i++)
	{
		if((Buff[i] == EOT) || (Buff[i] == SOH)
				|| (Buff[i] == DLE))
		{
			TxPacket[TxPacketLen++] = DLE;			
		}
		TxPacket[TxPacketLen++] = Buff[i];
	}

	// EOT: End of transmission
	TxPacket[TxPacketLen++] = EOT;
	
	return true;
	
}

/****************************************************************************
 *  Open communication port (USB)
 * \param   vid
 * \param   pid
 * \return       
 *****************************************************************************/
void CUSBHIDExample::OpenPort(UINT vid, UINT pid,HWND hwnd)
{
	(VOID)UsbHid.OpenUSBDevice(vid, pid, hwnd);
	ButtonStatus1 = 0;
	BS_Old1 = 255;
	bUpdate = true;
	bTransmitResp = false;
}

/****************************************************************************
 *  Get communication port status.
 *
 * \param 
 * \return true: Port opened.
		   false: Port closed.
 *****************************************************************************/
BOOL CUSBHIDExample::GetPortOpenStatus()
{
	return UsbHid.GetPortOpenStatus();
}

/****************************************************************************
 *  Closes the communication port (USB)
 *
 * \param 
 * \return 
 *****************************************************************************/
void CUSBHIDExample::ClosePort()
{
	UsbHid.ClosePort();
}


/****************************************************************************
 *  Write communication port (USB)
 *
 * \param Buffer, Len
 * \return 
 *****************************************************************************/
void CUSBHIDExample::WritePort(char *buffer, int bufflen)
{
	UsbHid.WriteUSBDevice(buffer, bufflen);
}


/****************************************************************************
 *  Read communication port (USB)
 *
 * \param Buffer, Len
 * \return 
 *****************************************************************************/
unsigned short CUSBHIDExample::ReadPort(char *buffer, int bufflen)
{
	unsigned short bytesRead;
	bytesRead = UsbHid.ReadUSBDevice(buffer, bufflen);
	return bytesRead;
}


BOOL CUSBHIDExample::NotifyDeviceChange(char *devPath)
{
	return(UsbHid.OnDeviceChange(devPath));
}



/*******************End of file**********************************************/