
// MainFrm.cpp : implementation of the CMainFrame class
//

#include "stdafx.h"
#include "IconizedMenu.h"

#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

// CMainFrame

IMPLEMENT_DYNAMIC(CMainFrame, CFrameWnd)

BEGIN_MESSAGE_MAP(CMainFrame, CFrameWnd)
ON_WM_CREATE()
ON_WM_SETFOCUS()
ON_COMMAND_RANGE(IDI_ICON1, IDI_ICON3, HandleMenu)
ON_WM_DRAWITEM()
ON_WM_MEASUREITEM()
ON_WM_INITMENUPOPUP()
END_MESSAGE_MAP()

static UINT indicators[] =
  {
    ID_SEPARATOR, // status line indicator
    ID_INDICATOR_CAPS,
    ID_INDICATOR_NUM,
    ID_INDICATOR_SCRL,
};

// CMainFrame construction/destruction

CMainFrame::CMainFrame()
{
    // TODO: add member initialization code here
}

CMainFrame::~CMainFrame()
{
}

int CMainFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
    if (CFrameWnd::OnCreate(lpCreateStruct) == -1)
        return -1;

    OnInitMenu(GetMenu());

    // create a view to occupy the client area of the frame
    if (!m_wndView.Create(NULL, NULL, AFX_WS_DEFAULT_VIEW, CRect(0, 0, 0, 0), this, AFX_IDW_PANE_FIRST, NULL))
    {
        TRACE0("Failed to create view window\n");
        return -1;
    }

    if (!m_wndStatusBar.Create(this))
    {
        TRACE0("Failed to create status bar\n");
        return -1; // fail to create
    }
    m_wndStatusBar.SetIndicators(indicators, sizeof(indicators) / sizeof(UINT));

    return 0;
}

void CMainFrame::HandleMenu(UINT id)
{
    // Just a placeholder for MFC to enable the menus
}

void CMainFrame::OnInitMenu(CMenu* pMenu)
{
#if _MFC_VER < 0x0800
#undef __FUNCTION__
#define __FUNCTION__ "OnInitMenu()"
#endif // _MFC_VER < 0x0800
    AfxTrace(_T(__FUNCTION__) _T(": %#0x\n"), pMenu->GetSafeHmenu());

    MENUITEMINFO minfo;
    minfo.cbSize = sizeof(minfo);

    for (int pos = 0; pos < pMenu->GetMenuItemCount(); pos++)
    {
        minfo.fMask = MIIM_FTYPE | MIIM_ID;
        pMenu->GetMenuItemInfo(pos, &minfo, TRUE);

        HICON hIcon = GetIconForItem(minfo.wID);

        if (hIcon && !(minfo.fType & MFT_OWNERDRAW))
        {
            AfxTrace(_T("replace for id=%#0x\n"), minfo.wID);

            minfo.fMask    = MIIM_FTYPE | MIIM_BITMAP;
            minfo.hbmpItem = HBMMENU_CALLBACK;
            minfo.fType    = MFT_STRING;

            ::SetMenuItemInfo(pMenu->GetSafeHmenu(), pos, TRUE, &minfo);
        }
        else
            AfxTrace(_T("keep for id=%#0x\n"), minfo.wID);
        //      ::DestroyIcon(hIcon); // we use LR_SHARED instead
    }
}

void CMainFrame::OnInitMenuPopup(CMenu* pMenu, UINT nIndex, BOOL bSysMenu)
{
#if _MFC_VER < 0x0800
#undef __FUNCTION__
#define __FUNCTION__ _T("OnInitMenuPopup()")
#endif // _MFC_VER < 0x0800

    AfxTrace(_T(__FUNCTION__) _T(": %#0x\n"), pMenu->GetSafeHmenu());
    CFrameWnd::OnInitMenuPopup(pMenu, nIndex, bSysMenu);

    if (bSysMenu)
    {
        pMenu = GetSystemMenu(FALSE);
    }
    MENUINFO mnfo;
    mnfo.cbSize  = sizeof(mnfo);
    mnfo.fMask   = MIM_STYLE;
    mnfo.dwStyle = MNS_CHECKORBMP | MNS_AUTODISMISS;
    ::SetMenuInfo(pMenu->GetSafeHmenu(), &mnfo);

    MENUITEMINFO minfo;
    minfo.cbSize = sizeof(minfo);

    for (int pos = 0; pos < pMenu->GetMenuItemCount(); pos++)
    {
        minfo.fMask = MIIM_FTYPE | MIIM_ID;
        pMenu->GetMenuItemInfo(pos, &minfo, TRUE);

        HICON hIcon = GetIconForItem(minfo.wID);

        if (hIcon && !(minfo.fType & MFT_OWNERDRAW))
        {
            AfxTrace(_T("replace for id=%#0x\n"), minfo.wID);

            minfo.fMask    = MIIM_FTYPE | MIIM_BITMAP;
            minfo.hbmpItem = HBMMENU_CALLBACK;
            minfo.fType    = MFT_STRING;

            ::SetMenuItemInfo(pMenu->GetSafeHmenu(), pos, TRUE, &minfo);
            //            pMenu->SetMenuItemInfo(pos, &minfo, TRUE);
        }
        else
            AfxTrace(_T("keep for id=%#0x\n"), minfo.wID);
        //      ::DestroyIcon(hIcon); // we use LR_SHARED instead
    }
}

void CMainFrame::OnMeasureItem(int nIDCtl, LPMEASUREITEMSTRUCT lpmis)
{
#if _MFC_VER < 0x0800
#undef __FUNCTION__
#define __FUNCTION__ "OnMeasureItem()"
#endif // _MFC_VER < 0x0800
    if ((lpmis == NULL) || (lpmis->CtlType != ODT_MENU))
    {
        CFrameWnd::OnMeasureItem(nIDCtl, lpmis); //not for a menu
        return;
    }

    lpmis->itemWidth  = 16;
    lpmis->itemHeight = 16;

    HICON hIcon = GetIconForItem(lpmis->itemID);

    if (hIcon)
    {
        ICONINFO iconinfo;
        ::GetIconInfo(hIcon, &iconinfo);

        BITMAP bitmap;
        ::GetObject(iconinfo.hbmColor, sizeof(bitmap), &bitmap);

        ::DeleteObject(iconinfo.hbmColor);
        ::DeleteObject(iconinfo.hbmMask);

        lpmis->itemWidth  = bitmap.bmWidth;
        lpmis->itemHeight = bitmap.bmHeight;

        AfxTrace(_T(__FUNCTION__) _T(": %#0x %dx%d ==> %dx%d\n"), lpmis->itemID, bitmap.bmWidth, bitmap.bmHeight, lpmis->itemWidth, lpmis->itemHeight);
    }
}

HICON CMainFrame::GetIconForItem(UINT itemID) const
{
#if _MFC_VER < 0x0800
#undef __FUNCTION__
#define __FUNCTION__ "GetIconForItem()"
#endif // _MFC_VER < 0x0800

    HICON hIcon = NULL;

    if (HIWORD(itemID) == 0)
        hIcon = (HICON)::LoadImage(::AfxGetResourceHandle(), MAKEINTRESOURCE(itemID), IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR | LR_SHARED);

    if (!hIcon)
    {
        CString sItem; // look for a named item in resources

        GetMenu()->GetMenuString(itemID, sItem, MF_BYCOMMAND);
        sItem.Replace(_T(' '), _T('_')); // cannot have resource items with space in name

        if (!sItem.IsEmpty())
            hIcon = (HICON)::LoadImage(::AfxGetResourceHandle(), sItem, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR | LR_SHARED);

        if (hIcon)
            AfxTrace(_T(__FUNCTION__) _T(": %#0x is \"%s\"\n"), itemID, (LPCTSTR)sItem);
    }
    return hIcon;
}

void CMainFrame::OnDrawItem(int nIDCtl, LPDRAWITEMSTRUCT lpdis)
{
#if _MFC_VER < 0x0800
#undef __FUNCTION__
#define __FUNCTION__ "OnDrawItem()"
#endif // _MFC_VER < 0x0800
    if ((lpdis == NULL) || (lpdis->CtlType != ODT_MENU))
    {
        CFrameWnd::OnDrawItem(nIDCtl, lpdis);
        return; //not for a menu
    }

    if (lpdis->rcItem.left != 2)
    {
        lpdis->rcItem.left -= (lpdis->rcItem.left - 2);
        lpdis->rcItem.right -= 60;
        if (lpdis->itemState & ODS_SELECTED)
        {
            lpdis->rcItem.left++;
            lpdis->rcItem.right++;
        }
    }

    AfxTrace(_T(__FUNCTION__) _T(": %#0x %s in (%d,%d,%d,%d)\n"), lpdis->itemID, (lpdis->itemState & ODS_SELECTED) ? _T("selected") : _T(""), lpdis->rcItem.left, lpdis->rcItem.top, lpdis->rcItem.right, lpdis->rcItem.bottom);

    HICON hIcon = GetIconForItem(lpdis->itemID);
    if (hIcon)
    {
        ICONINFO iconinfo;
        ::GetIconInfo(hIcon, &iconinfo);

        BITMAP bitmap;
        ::GetObject(iconinfo.hbmColor, sizeof(bitmap), &bitmap);

        ::DeleteObject(iconinfo.hbmColor);
        ::DeleteObject(iconinfo.hbmMask);

        ::DrawIconEx(lpdis->hDC, lpdis->rcItem.left, lpdis->rcItem.top, hIcon, bitmap.bmWidth, bitmap.bmHeight, 0, NULL, DI_NORMAL);
        //      ::DestroyIcon(hIcon); // we use LR_SHARED instead
    }
}

BOOL CMainFrame::PreCreateWindow(CREATESTRUCT& cs)
{
    if (!CFrameWnd::PreCreateWindow(cs))
        return FALSE;
    // TODO: Modify the Window class or styles here by modifying
    //  the CREATESTRUCT cs

    cs.dwExStyle &= ~WS_EX_CLIENTEDGE;
    cs.lpszClass = AfxRegisterWndClass(0);
    return TRUE;
}

// CMainFrame diagnostics

#ifdef _DEBUG
void CMainFrame::AssertValid() const
{
    CFrameWnd::AssertValid();
}

void CMainFrame::Dump(CDumpContext& dc) const
{
    CFrameWnd::Dump(dc);
}
#endif //_DEBUG

// CMainFrame message handlers

void CMainFrame::OnSetFocus(CWnd* /*pOldWnd*/)
{
    // forward focus to the view window
    m_wndView.SetFocus();
}

BOOL CMainFrame::OnCmdMsg(UINT nID, int nCode, void* pExtra, AFX_CMDHANDLERINFO* pHandlerInfo)
{
    // let the view have first crack at the command
    if (m_wndView.OnCmdMsg(nID, nCode, pExtra, pHandlerInfo))
        return TRUE;

    // otherwise, do default handling
    return CFrameWnd::OnCmdMsg(nID, nCode, pExtra, pHandlerInfo);
}
