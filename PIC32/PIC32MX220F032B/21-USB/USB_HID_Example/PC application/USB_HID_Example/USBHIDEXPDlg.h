// USBHIDEXPDlg.h : header file
//

#pragma once
#include "afxwin.h"
#include "afxcmn.h"


// CUSBHIDEXPDlg dialog
class CUSBHIDEXPDlg : public CDialog
{
// Construction
public:
	CUSBHIDEXPDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_USBHIDEXP_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;
	CUSBHIDExample mUSBHIDExample;
	bool EraseProgVer;
	bool ConnectionEstablished;
	void PrintKonsole(CString string);
	void ClearKonsole(void);
	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()

public:
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedButtonConnect();

// USBHIDExample functions.
	void ExtraInitialization(void);
	void StartSendReceiveTimers(void);
	void ButtonStatus(unsigned int oprn);
	void UpdateBtnStatus(unsigned char s1);

	afx_msg LRESULT OnReceiveResponse(WPARAM, LPARAM);
	afx_msg LRESULT OnTransmitFailure(WPARAM, LPARAM);
	afx_msg LRESULT OnReceiveBtnSta(WPARAM, LPARAM);

	char TxCommand;
	char TxData[255];

	CEdit ctrlEditConsole;
	CString cstringEditConsole;
	CButton ctrlButtonConnectDevice;
	afx_msg void OnBnClickedButtonDisconnect();
	unsigned long uLongEditBoxVID;
	unsigned long uLongEditBoxPID;
	CEdit ctrlEditBoxUSBVID;
	CEdit ctrlEditBoxUSBPID;
	CString stringEditBoxUSBVID;
	CString stringEditBoxUSBPID;
	afx_msg void OnBnClickedLight1();
	BOOL m_bChkLight1;
	CButton m_ctrlBtnSta1;
	CButton m_ctrlLight1;
	BOOL m_bBtnSta1;
	afx_msg void OnBnClickedButtonClearlist();
};
