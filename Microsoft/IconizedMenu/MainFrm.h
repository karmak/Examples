
// MainFrm.h : interface of the CMainFrame class
//

#pragma once
#include "ChildView.h"

class CMainFrame : public CFrameWnd
{
public:
    CMainFrame();

protected:
    DECLARE_DYNAMIC(CMainFrame)

    // Attributes
public:
    // Operations
public:
    // Overrides
public:
    virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
    virtual BOOL OnCmdMsg(UINT nID, int nCode, void* pExtra, AFX_CMDHANDLERINFO* pHandlerInfo);

    // Implementation
public:
    virtual ~CMainFrame();
#ifdef _DEBUG
    virtual void AssertValid() const;
    virtual void Dump(CDumpContext& dc) const;
#endif

protected: // control bar embedded members
    CStatusBar m_wndStatusBar;
    CChildView m_wndView;

    // Generated message map functions
protected:
    afx_msg int  OnCreate(LPCREATESTRUCT lpCreateStruct);
    afx_msg void OnSetFocus(CWnd* pOldWnd);
    //
    afx_msg void OnDrawItem(int nIDCtl, LPDRAWITEMSTRUCT lpdis);
    afx_msg void OnInitMenuPopup(CMenu* pMenu, UINT nIndex, BOOL bSysMenu);
    afx_msg void OnMeasureItem(int nIDCtl, LPMEASUREITEMSTRUCT lpmis);
    afx_msg void OnInitMenu(CMenu* pMenu);
    HICON        GetIconForItem(UINT itemID) const;
    //
    DECLARE_MESSAGE_MAP()
public:
    afx_msg void HandleMenu(UINT id);
};
