program OpenGL_min;
{**************** ����������� ��������� OpenGL     *********************}
{* ��������� ���������� ����, ��������� ������� OpenGL.                *}
{* ���������� �������� �������� �� ���������:                          *}
{* 1. OpenGL ������� ��� ������ ���� ������� ������������� ������      *}
{*    ws_OverLappedWindow or ws_ClipChildren or ws_ClipSiBlings.       *}
{* 2. OpenGL ���������� ��������� ��������� ��������������� (rendering *}
{*    context). ���������� ������ ������� �������� ��������������� �   *}
{*    ������� ��� �������.                                             *}
{* 3. ����� ��������� ��������� ���������� ��� ���� ���������� ������  *}
{*    ��������.                                                        *}
{***********************************************************************}
{*** ���������, ������������ OpenGL, ������������� ���������       ***}
{*** ��� ����� Delphi, �� ���� ��������� ����������������� ������. ***}
{*** ����� - ������� �.�.      softgl@chat.ru                      ***}
{*********************************************************************}

{(c) Copyright 1993, Silicon Graphics, Inc.

ALL RIGHTS RESERVED

Permission to use, copy, modify, and distribute this software
for any purpose and without fee is hereby granted, provided
that the above copyright notice appear in all copies and that
both the copyright notice and this permission notice appear in
supporting documentation, and that the name of Silicon
Graphics, Inc. not be used in advertising or publicity
pertaining to distribution of the software without specific,
written prior permission.

THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU
"AS-IS" AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR
OTHERWISE, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  IN NO
EVENT SHALL SILICON GRAPHICS, INC.  BE LIABLE TO YOU OR ANYONE
ELSE FOR ANY DIRECT, SPECIAL, INCIDENTAL, INDIRECT OR
CONSEQUENTIAL DAMAGES OF ANY KIND, OR ANY DAMAGES WHATSOEVER,
INCLUDING WITHOUT LIMITATION, LOSS OF PROFIT, LOSS OF USE,
SAVINGS OR REVENUE, OR THE CLAIMS OF THIRD PARTIES, WHETHER OR
NOT SILICON GRAPHICS, INC.  HAS BEEN ADVISED OF THE POSSIBILITY
OF SUCH LOSS, HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
ARISING OUT OF OR IN CONNECTION WITH THE POSSESSION, USE OR
PERFORMANCE OF THIS SOFTWARE.

US Government Users Restricted Rights

Use, duplication, or disclosure by the Government is subject to
restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
(c)(1)(ii) of the Rights in Technical Data and Computer
Software clause at DFARS 252.227-7013 and/or in similar or
successor clauses in the FAR or the DOD or NASA FAR
Supplement.  Unpublished-- rights reserved under the copyright
laws of the United States.  Contractor/manufacturer is Silicon
Graphics, Inc., 2011 N.  Shoreline Blvd., Mountain View, CA
94039-7311.

OpenGL(TM) is a trademark of Silicon Graphics, Inc.
}

uses
  Messages, Windows, OpenGL;

const
  AppName = 'OpenGL_Min';

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;            // �������� ��������������� OpenGL
  MyPaint : TPaintStruct;

// ��������� ���������� ����� ��������� PIXELFORMATDESCRIPTOR
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPixelFormatDescriptor; // ������ ������� ��������
 nPixelFormat : Integer;
Begin
 With pfd do begin
  nSize := sizeof (TPixelFormatDescriptor); // ������ ���������
  nVersion := 1;                            // ����� ������
  dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL; // ��������� ������� ������, ������������ ���������� � ���������
  iPixelType := PFD_TYPE_RGBA; // ����� ��� ����������� ������
  cColorBits := 16;            // ����� ������� ���������� � ������ ������ �����
  cRedBits := 0;               // ����� ������� ���������� �������� � ������ ������ RGBA
  cRedShift := 0;              // �������� �� ������ ����� ������� ���������� �������� � ������ ������ RGBA
  cGreenBits := 0;             // ����� ������� ���������� ������� � ������ ������ RGBA
  cGreenShift := 0;            // �������� �� ������ ����� ������� ���������� ������� � ������ ������ RGBA
  cBlueBits := 0;              // ����� ������� ���������� ������ � ������ ������ RGBA
  cBlueShift := 0;             // �������� �� ������ ����� ������� ���������� ������ � ������ ������ RGBA
  cAlphaBits := 0;             // ����� ������� ���������� ����� � ������ ������ RGBA
  cAlphaShift := 0;            // �������� �� ������ ����� ������� ���������� ����� � ������ ������ RGBA
  cAccumBits := 0;             // ����� ����� ������� ���������� � ������ ������������
  cAccumRedBits := 0;          // ����� ������� ���������� �������� � ������ ������������
  cAccumGreenBits := 0;        // ����� ������� ���������� ������� � ������ ������������
  cAccumBlueBits := 0;         // ����� ������� ���������� ������ � ������ ������������
  cAccumAlphaBits := 0;        // ����� ������� ���������� ����� � ������ ������������
  cDepthBits := 32;            // ������ ������ ������� (��� z)
  cStencilBits := 0;           // ������ ������ ���������
  cAuxBuffers := 0;            // ����� ��������������� �������
  iLayerType := PFD_MAIN_PLANE;// ��� ���������
  bReserved := 0;              // ����� ���������� ��������� � ������� �����
  dwLayerMask := 0;            // ������������
  dwVisibleMask := 0;          // ������ ��� ���� ������������ ������ ���������
  dwDamageMask := 0;           // ������������
 end;

 nPixelFormat := ChoosePixelFormat (hdc, @pfd); // ������ ������� - �������������� �� ��������� ������ ��������
 SetPixelFormat (hdc, nPixelFormat, @pfd);      // ������������� ������ �������� � ��������� ����������
End;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; stdcall;
Begin
  WindowProc := 0;
  case Message of
  wm_Create:
       begin
       dc := GetDC (Window);
       SetDCPixelFormat (dc);        // ���������� ������ ��������
       hrc := wglCreateContext (dc); // ������ �������� ��������������� OpenGL
       end;
  wm_Paint:
       begin
       BeginPaint (Window, MyPaint);
       wglMakeCurrent (dc, hrc);     // ������������� ������� �������� ���������������

{************ ����� ������������� ������� ��������� OpenGL **************}

       glClearColor (0.85, 0.75, 0.5, 1.0); // ����������� ����� ����
       glClear (GL_COLOR_BUFFER_BIT);       // ������������ ����� ����

{************************************************************************}

       wglMakeCurrent (dc, 0); // ����� ����������� ������ ����������,
                               // ����� �������� ����� �� �������������

       EndPaint (Window, MyPaint);
       end;
  wm_Destroy :
       begin
       wglDeleteContext (hrc); // �������� ��������� ���������������
       PostQuitMessage (0);
       Exit;
       end;

  end; // case
  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

Begin
  With WindowClass do
       begin
       Style := cs_HRedraw or cs_VRedraw;
       lpfnWndProc := @WindowProc;
       cbClsExtra := 0;
       cbWndExtra := 0;
       hInstance := 0;
       hCursor := LoadCursor (0, idc_Arrow);
       lpszClassName := AppName;
       end;
  RegisterClass (WindowClass);
  Window := CreateWindow (AppName, AppName,
       ws_OverLappedWindow or ws_ClipChildren
          or ws_ClipSiBlings, // ����������� ��� OpenGL
       cw_UseDefault, cw_UseDefault,
       cw_UseDefault, cw_UseDefault,
       HWND_DESKTOP, 0, HInstance, nil);
       ShowWindow (Window, CmdShow);
       UpdateWindow (Window);
  While GetMessage (Message, 0, 0, 0) do begin
       TranslateMessage (Message);
       DispatchMessage (Message);
  end;
  Halt (Message.wParam);
end.
