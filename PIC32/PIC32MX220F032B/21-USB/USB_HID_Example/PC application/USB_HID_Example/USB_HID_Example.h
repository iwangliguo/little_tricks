#pragma once

// Notify message IDs
#define WM_USER_USBHIDExample_RESP_OK WM_USER+1
#define WM_USER_USBHIDExample_NO_RESP WM_USER+2
#define WM_USER_USBHIDExample_BTNSTA WM_USER+3

// Trasnmission states
#define FIRST_TRY 0
#define RE_TRY 1

// Commands
typedef enum
{
    LIGHT = 1,
    BUTTON
	
}T_COMMANDS;	

// Main USBHIDExample class
class CUSBHIDExample
{

private:
	CWinThread *BtlThread;
	HWND m_hWnd;
	char TxPacket[1000];
	unsigned short TxPacketLen;
	char RxData[255];
	unsigned short RxDataLen;
	unsigned short RetryCount;

	bool RxFrameValid;
	unsigned char LastSentCommand;
	bool NoResponseFromDevice;
	unsigned int TxState;
	unsigned short MaxRetry;
	unsigned short TxRetryDelay;
	bool ResetHexFilePtr;
	void WritePort(char *buffer, int bufflen);
	unsigned short ReadPort(char *buffer, int bufflen);
	

public:
	bool ExitThread;
	bool ThreadKilled; 
	CUsbHid  UsbHid;
	BYTE ButtonStatus1;
	BYTE BS_Old1;
	bool bUpdate;
	bool bTransmitResp;
	// Constructor
	CUSBHIDExample()
	{
		BtlThread = NULL;
		// Initialization of some flags and variables
		RxFrameValid = false;
		NoResponseFromDevice = false;
		TxState = FIRST_TRY;
		RxDataLen = 0;
		ResetHexFilePtr = true;
	}

	// Destructor
	~CUSBHIDExample()
	{
		ShutdownThread( );
	}

	void ShutdownThread( );
	void CreateRxTxThread(HWND);
	void TransmitTask(void);
	void ReceiveTask(void);	
	bool SendCommand(char cmd, unsigned short Retries, unsigned short DelayInMs,unsigned char light,unsigned char action);	
	void BuildRxFrame(unsigned char*, unsigned short);
	void HandleResponse(void);	
	void StopTxRetries(void);
	void NotifyEvent(unsigned int lEvent);
	void GetRxData(char *buff);
	void HandleNoResponse(void);
	void OpenPort(UINT vid, UINT pid,HWND hwnd);
	BOOL GetPortOpenStatus();
	void ClosePort();
	BOOL NotifyDeviceChange( char *devPath); 
	bool GetUpdateStatus(unsigned char *data);
};

extern unsigned short CalculateCrc(char *data, unsigned int len);



