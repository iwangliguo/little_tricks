// USBHIDEXPDlg.cpp : implementation file
//

#include "stdafx.h"
#include "USB_HID.h"
#include "USB_HID_Example.h"
#include "USBHIDEXP.h"
#include "USBHIDEXPDlg.h"
#include ".\USBHIDEXPdlg.h"
#include <windows.h>
#include <wtypes.h>
#include <dbt.h>


#ifdef _DEBUG
#define new DEBUG_NEW
#endif

#define USBHIDExample_ROUTINE_TIMER 1
#define USBHIDExample_GUI_UPDATE_TIMER 2
#define SWAP(x)   ( ((x<<24)&(0xFF000000)) | ((x<<8)&(0x00FF0000))  | ((x>>24)&(0x000000FF)) | ((x>>8)&(0x0000FF00)) )

#define SAVE 1
#define RESTORE 2

#define SaveButtonStatus() ButtonStatus(SAVE)
#define RestoreButtonStatus() ButtonStatus(RESTORE)

// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Implementation
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
END_MESSAGE_MAP()


// CUSBHIDEXPDlg dialog



CUSBHIDEXPDlg::CUSBHIDEXPDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CUSBHIDEXPDlg::IDD, pParent)
	, cstringEditConsole(_T(""))
	, uLongEditBoxVID(0)
	, uLongEditBoxPID(0)
	, stringEditBoxUSBVID(_T(""))
	, stringEditBoxUSBPID(_T(""))
	, m_bChkLight1(FALSE)
	, m_bBtnSta1(FALSE)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CUSBHIDEXPDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_EDIT_CONSOLE, ctrlEditConsole);
	DDX_Text(pDX, IDC_EDIT_CONSOLE, cstringEditConsole);
	DDX_Control(pDX, IDC_BUTTON_CONNECT, ctrlButtonConnectDevice);
	DDX_Control(pDX, IDC_EDIT_USB_VID, ctrlEditBoxUSBVID);
	DDX_Control(pDX, IDC_EDIT_USB_PID, ctrlEditBoxUSBPID);
	DDX_Text(pDX, IDC_EDIT_USB_VID, stringEditBoxUSBVID);
	DDX_Text(pDX, IDC_EDIT_USB_PID, stringEditBoxUSBPID);
	DDX_Check(pDX, IDC_LIGHT1, m_bChkLight1);
	DDX_Control(pDX, IDC_BTNSTA1, m_ctrlBtnSta1);
	DDX_Control(pDX, IDC_LIGHT1, m_ctrlLight1);
	DDX_Check(pDX, IDC_BTNSTA1, m_bBtnSta1);
}

BEGIN_MESSAGE_MAP(CUSBHIDEXPDlg, CDialog)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
	ON_BN_CLICKED(IDCANCEL, OnBnClickedCancel)
	ON_BN_CLICKED(IDC_BUTTON_CONNECT, OnBnClickedButtonConnect)
	ON_MESSAGE(WM_USER_USBHIDExample_RESP_OK, OnReceiveResponse)
	ON_MESSAGE(WM_USER_USBHIDExample_NO_RESP, OnTransmitFailure)
	ON_MESSAGE(WM_USER_USBHIDExample_BTNSTA, OnReceiveBtnSta)

	ON_WM_DEVICECHANGE()
	ON_WM_DEVMODECHANGE()
	ON_BN_CLICKED(IDC_LIGHT1, &CUSBHIDEXPDlg::OnBnClickedLight1)
	ON_BN_CLICKED(IDC_BUTTON_CLEARLIST, &CUSBHIDEXPDlg::OnBnClickedButtonClearlist)
END_MESSAGE_MAP()


// CUSBHIDEXPDlg message handlers

BOOL CUSBHIDEXPDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// TODO: Add extra initialization here
	ExtraInitialization();


	
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CUSBHIDEXPDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CUSBHIDEXPDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CUSBHIDEXPDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

/****************************************************************************
 * Invoked just before dialog is closed
 *
 *  
 *****************************************************************************/
void CUSBHIDEXPDlg::OnBnClickedCancel()
{
	int confirm;
	// TODO: Add your control notification handler code here
	confirm = MessageBox("Confirm Exit?", "Exit", MB_YESNO|MB_ICONQUESTION);
	if(confirm == 6)
	{
		// Exit confirmed
		OnCancel();
	}
}






//extern HDEVINFO SetupDiGetClassDevs(CONST GUID*, PCTSTR, HWND, DWORD);

/****************************************************************************
 * Invoked when connect button is clicked
 *
 *  
 *****************************************************************************/

void CUSBHIDEXPDlg::OnBnClickedButtonConnect()
{
	CString string;
	UINT vid;
	UINT pid;
	UpdateData(TRUE);
	
	if(ConnectionEstablished)
	{
		// Already connected. Disconnect now.
		ConnectionEstablished = false;

		// Shut down the rx-tx thread, if already opened.
			mUSBHIDExample.ShutdownThread();
		
		if(mUSBHIDExample.GetPortOpenStatus())
		{
			// com port already opened. close com port
			mUSBHIDExample.ClosePort();			
		}

		// Print console.
		PrintKonsole("Device disconnected");

		ctrlButtonConnectDevice.SetWindowText("Connect");
		ctrlButtonConnectDevice.EnableWindow(TRUE);
		ctrlEditBoxUSBVID.EnableWindow(TRUE);
		ctrlEditBoxUSBPID.EnableWindow(TRUE);
		m_ctrlLight1.EnableWindow(FALSE);
	}
	else
	{
		// Establish new connection.

		sscanf(stringEditBoxUSBVID, "%X", &vid);
		sscanf(stringEditBoxUSBPID, "%X", &pid);
		// Update the screen with what VID and PID we have read.
		stringEditBoxUSBVID.FormatMessage("0x%1!X!",vid);
		stringEditBoxUSBPID.FormatMessage("0x%1!X!",pid);

		UpdateData(FALSE);
		
		if(mUSBHIDExample.GetPortOpenStatus())
		{
			// com port already opened. close com port
			mUSBHIDExample.ClosePort();			
		}
		// Open Communication port freshly.
		mUSBHIDExample.OpenPort(vid, pid, GetSafeHwnd());

		
		if(mUSBHIDExample.GetPortOpenStatus())
		{	// COM port opened.
			// Shut down the rx-tx thread, if already opened.
			mUSBHIDExample.ShutdownThread();
			// Create a new thread to do Rx Tx in the back ground.			
			mUSBHIDExample.CreateRxTxThread(GetSafeHwnd()); // Create Rx Tx thread.

			ctrlEditBoxUSBVID.EnableWindow(FALSE);
			ctrlEditBoxUSBPID.EnableWindow(FALSE);
			m_ctrlLight1.EnableWindow(TRUE);
			// Print a message to user/
			PrintKonsole("Device Connected.");
			ctrlButtonConnectDevice.SetWindowText("Disconnect");
			ConnectionEstablished = TRUE;
			// Save button status.
			SaveButtonStatus();
		}

	}
}

/****************************************************************************
 * Invoked just after dialog is created. Do some extra initialization
 * like enabling and disabling buttons and so on.
 *  
 *****************************************************************************/
void CUSBHIDEXPDlg::ExtraInitialization()
{

	// Mask all buttons, except for "Connect Device"
	ctrlButtonConnectDevice.EnableWindow(true);

	// Mark this flag as false.
	ConnectionEstablished = false;

	// Display default VID and PID in edit box. This is default value for Microchip device to work.
	stringEditBoxUSBVID = "0x4D8";
	stringEditBoxUSBPID = "0x03C";
	// Enable USB VID and PID edit boxes.
	ctrlEditBoxUSBVID.EnableWindow(TRUE);
	ctrlEditBoxUSBPID.EnableWindow(TRUE);
	m_ctrlLight1.EnableWindow(FALSE);
	UpdateData(FALSE);
}

void CUSBHIDEXPDlg::UpdateBtnStatus(unsigned char s1)
{
	m_bBtnSta1 = s1 > 0;
	UpdateData(FALSE);
}
/****************************************************************************
 * This function is invoked when there is a response from the device.
 Process the response based on the command.
 * 
 *  
 *****************************************************************************/
LRESULT CUSBHIDEXPDlg::OnReceiveResponse(WPARAM cmd, LPARAM RxDataPtrAdrs)
{
	char data;// = RxData[3];
	char *RxData;
	CString string;

	RxData = (char *)RxDataPtrAdrs;
	data = RxData[0];

	switch(cmd)
	{
	case BUTTON:
		if(ConnectionEstablished == false)
		{
			// New connection.
			ClearKonsole();
			string.FormatMessage("Device connected"); 
			PrintKonsole(string);
		}
		string.FormatMessage("Received an Button Status command,data= 0x%1!x!", data);
		m_bBtnSta1 = 0;
		switch(data)
		{
		case 1:
			m_bBtnSta1 = 1;
			break;
		default:
			break;
		}
		PrintKonsole(string);		
		// Change the connect button to disconnect.
		ConnectionEstablished = true;
		ctrlButtonConnectDevice.SetWindowText("Disconnect");
		// Disable USB VID and PID boxes.
		ctrlEditBoxUSBVID.EnableWindow(false);
		ctrlEditBoxUSBPID.EnableWindow(false);
		break;
	default:
		break;
	}
	return 1;
}


/****************************************************************************
 *  This function is invoked when there is no resonse from the device, even after
	retries.
 *  
 *****************************************************************************/
LRESULT CUSBHIDEXPDlg::OnTransmitFailure(WPARAM cmd, LPARAM)
{
	CString string;
	
	EraseProgVer = false;
	switch(cmd)
	{
	case LIGHT:		
		PrintKonsole("No Response from the device. Operation failed");
		RestoreButtonStatus();
		break;
	}
	return 1;
}
LRESULT CUSBHIDEXPDlg::OnReceiveBtnSta(WPARAM cmd, LPARAM data_l)
{
	unsigned char* s1,*s2,*s3;
	CString str;
	
	s1 = (unsigned char *)data_l;
	s2 = s1+1;
	s3 = s2 +1;
	str.FormatMessage("Button status updates,cmd=0x%1!x!,s1=0x%2!x!",cmd,*s1);

	switch(cmd)
	{
	case BUTTON:		
		UpdateBtnStatus(*s1);
		PrintKonsole(str);
		break;
	}
	return 1;
}
/****************************************************************************
 * Print Konsole
 * 
 *  
 *****************************************************************************/
void CUSBHIDEXPDlg::PrintKonsole(CString string)
{

	cstringEditConsole += string;
	string.FormatMessage("\n");
	cstringEditConsole += string;
	UpdateData(false);
	// Set the console window vertical scroll to the end.
	ctrlEditConsole.SetSel(32767, 32767);
}

/****************************************************************************
 * Clears konsole
 * 
 *  
 *****************************************************************************/
void CUSBHIDEXPDlg::ClearKonsole(void)
{

	cstringEditConsole = "";
	
	UpdateData(false);
	// Set the console window vertical scroll to the end.
	ctrlEditConsole.SetSel(32767, 32767);
}


/****************************************************************************
 * Saves the current status of the button and restores the button
 * 
 *  
 *****************************************************************************/
void CUSBHIDEXPDlg::ButtonStatus(unsigned int oprn)
{
	static unsigned int status;
	

	if(oprn == SAVE)
	{
		(ctrlButtonConnectDevice.IsWindowEnabled())? status |= 0x20: status &= ~0x20;
	}
	else
	{
		// Restore
		(status & 0x20)? ctrlButtonConnectDevice.EnableWindow(true): ctrlButtonConnectDevice.EnableWindow(false);
	}

}

void CUSBHIDEXPDlg::OnBnClickedLight1()
{
	UpdateData(TRUE);
	mUSBHIDExample.SendCommand(LIGHT,2,50,1,(unsigned char)m_bChkLight1);
}


void CUSBHIDEXPDlg::OnBnClickedButtonClearlist()
{
	ClearKonsole();
}
