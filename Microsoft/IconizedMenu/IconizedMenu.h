
// IconizedMenu.h : main header file for the IconizedMenu application
//
#pragma once

#ifndef __AFXWIN_H__
#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h" // main symbols

// CIconizedMenuApp:
// See IconizedMenu.cpp for the implementation of this class
//

class CIconizedMenuApp : public CWinApp
{
public:
    CIconizedMenuApp();

    // Overrides
public:
    virtual BOOL InitInstance();
    virtual int  ExitInstance();

    // Implementation

public:
    afx_msg void OnAppAbout();
    DECLARE_MESSAGE_MAP()
};

extern CIconizedMenuApp theApp;
