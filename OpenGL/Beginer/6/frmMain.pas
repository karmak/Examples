{*********************************************************************}
{***                 �������� OpenGL                               ***}
{*** ����� �������, ����������� ������ ������.                     ***}
{*** ������������ ������ ��� ����������� ������������������ �����. ***}
{*********************************************************************}
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
unit frmMain;
interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, OpenGL;

type
  TfrmCube = class(TForm)
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);

  private
    DC : HDC;
    hrc : HGLRC;
    Angle : GLfloat;
    Palette : HPalette;
    wrkX, wrkY : Array [0..5] of Single;

    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMQueryNewPalette(var Msg: TWMQueryNewPalette); message WM_QUERYNEWPALETTE;
    procedure WMPaletteChanged(var Msg: TWMPaletteChanged); message WM_PALETTECHANGED;
  end;

const
  // ������ ������� ���������
  MaterialColor: Array[0..3] of GLfloat = (0.5, 0.2, 0.5, 0.0);
  // ������������� ������
  CUBE = 1;

var
  frmCube: TfrmCube;

implementation

{$R *.DFM}

{=======================================================================
��������� ��������}
procedure TfrmCube.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
  i : 0..5;
begin
  BeginPaint(Handle, ps);
  // ������� ������ ����� � ������ �������
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  // ������������
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -9.0);
  glRotatef(60.0, 1.0, 0.0, 1.0);  // ������� �� ���� X � Z
  glRotatef(Angle, 0.0, 0.0, 1.0); // ������� �� ����

  {���� ��������� ����� �������}
  For i := 0 to 5 do begin
    glPushMatrix;                  // ��������� �����

    glTranslatef(wrkX [i], wrkY [i], 0.0);
    glRotatef(-60 * i, 0.0, 0.0, 1.0); // ������� ������

    glCallList (CUBE);             // ��������� ���������� ������ - ����� ������

    glPopMatrix;                   // ��������� � �����
  end;

  SwapBuffers(DC);                 // ����� ������
  EndPaint(Handle, ps);
end;

{=======================================================================
��������� �������}
procedure TfrmCube.TimerTimer(Sender: TObject);
begin
  // ������ "���" ���������� �������� ����
  Angle := Angle + 2.0;

  If (Angle >= 60.0) then Angle := 0.0;

  InvalidateRect(Handle, nil, False); // ����������� ������� 
end;

{*** ������ ���� ������� ��� OpenGL �������� ***}
{=======================================================================
�������� ����}
procedure TfrmCube.FormCreate(Sender: TObject);
var
  i : 0..5;
begin
  Angle := 0;
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  glEnable(GL_DEPTH_TEST);// ��������� ���� �������
  glEnable(GL_LIGHTING);  // ��������� ������ � �������������
  glEnable(GL_LIGHT0);    // �������� �������� ����� 0

  For i := 0 to 5 do begin
      wrkX [i] := sin (Pi / 3 * i);
      wrkY [i] := cos (Pi / 3 * i);
  end;
  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @MaterialColor);

  // ����������� ������
  glNewList (CUBE, GL_Compile);
    glScalef (0.25, 0.25, 0.25); // �������� �������
    // ����� ������ ����
    glBegin(GL_POLYGON);
      glNormal3f(0.0, 0.0, 1.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(-1.0, -1.0, 1.0);
      glVertex3f(1.0, -1.0, 1.0);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(0.0, 0.0, -1.0);
      glVertex3f(1.0, 1.0, -1.0);
      glVertex3f(1.0, -1.0, -1.0);
      glVertex3f(-1.0, -1.0, -1.0);
      glVertex3f(-1.0, 1.0, -1.0);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(-1.0, 0.0, 0.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(-1.0, 1.0, -1.0);
      glVertex3f(-1.0, -1.0, -1.0);
      glVertex3f(-1.0, -1.0, 1.0);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(1.0, 0.0, 0.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(1.0, -1.0, 1.0);
      glVertex3f(1.0, -1.0, -1.0);
      glVertex3f(1.0, 1.0, -1.0);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(0.0, 1.0, 0.0);
      glVertex3f(-1.0, 1.0, -1.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(1.0, 1.0, -1.0);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(0.0, -1.0, 0.0);
      glVertex3f(-1.0, -1.0, -1.0);
      glVertex3f(1.0, -1.0, -1.0);
      glVertex3f(1.0, -1.0, 1.0);
      glVertex3f(-1.0, -1.0, 1.0);
    glEnd;

    glScalef (4, 4, 4);                // �������������� �������

  glEndList;                           // ����� �������� ������
  glClearColor (0.25, 0.1, 0.25, 0.0);
  Timer.Enabled := True;
end;

{=======================================================================
������������� ������ ��������}
procedure TfrmCube.SetDCPixelFormat;
var
  hHeap: THandle;
  nColors, i: Integer;
  lpPalette: PLogPalette;
  byRedMask, byGreenMask, byBlueMask: Byte;
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;

begin
  FillChar(pfd, SizeOf(pfd), 0);

  with pfd do begin
    nSize     := sizeof(pfd);
    nVersion  := 1;
    dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
    iPixelType:= PFD_TYPE_RGBA;
    cColorBits:= 24;
    cDepthBits:= 32;
    iLayerType:= PFD_MAIN_PLANE;
  end;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);

  DescribePixelFormat(DC, nPixelFormat, sizeof(TPixelFormatDescriptor), pfd);

  if ((pfd.dwFlags and PFD_NEED_PALETTE) <> 0) then begin
    nColors   := 1 shl pfd.cColorBits;
    hHeap     := GetProcessHeap;
    lpPalette := HeapAlloc(hHeap, 0, sizeof(TLogPalette) + (nColors * sizeof(TPaletteEntry)));

    // ����������� ��������� ������ ������ � ����� ��������� �������
    lpPalette^.palVersion := $300;
    lpPalette^.palNumEntries := nColors;

    byRedMask   := (1 shl pfd.cRedBits) - 1;
    byGreenMask := (1 shl pfd.cGreenBits) - 1;
    byBlueMask  := (1 shl pfd.cBlueBits) - 1;

    // ��������� ������� �������
    for i := 0 to nColors - 1 do begin
      lpPalette^.palPalEntry[i].peRed   := (((i shr pfd.cRedShift)   and byRedMask)   * 255) DIV byRedMask;
      lpPalette^.palPalEntry[i].peGreen := (((i shr pfd.cGreenShift) and byGreenMask) * 255) DIV byGreenMask;
      lpPalette^.palPalEntry[i].peBlue  := (((i shr pfd.cBlueShift)  and byBlueMask)  * 255) DIV byBlueMask;
      lpPalette^.palPalEntry[i].peFlags := 0;
    end;

    // ������� �������
    Palette := CreatePalette(lpPalette^);
    HeapFree(hHeap, 0, lpPalette);

    // ������������� ������� � ��������� ����������
    if (Palette <> 0) then begin
      SelectPalette(DC, Palette, False);
      RealizePalette(DC);
    end;
  end;

end;

{=======================================================================
��������� �������� ����}
procedure TfrmCube.FormResize(Sender: TObject);
var
  gldAspect : GLdouble;

begin
  gldAspect := Width / Height;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(18.0, gldAspect, 6.0, 10.0);
  glViewport(0, 0, Width, Height);
  glMatrixMode(GL_MODELVIEW);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
����� ������ ���������}
procedure TfrmCube.FormDestroy(Sender: TObject);
begin
  Timer.Enabled := False;
  glDeleteLists (CUBE, 1); // ������� ������ �� ������
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
end;

{=======================================================================
��������� WM_QUERYNEWPALETTE}
procedure TfrmCube.WMQueryNewPalette(var Msg : TWMQueryNewPalette);
begin
  // ��� ��������� ���������� ����, ������� ���������� ��������
  // � ����� �� ������ ����������� ���� ���������� �������, �.�.
  // ���� ������� ���� �� ���� ��������, ������ ���������
  // ����� �������� ��������� �������
  if (Palette <> 0) then begin
    Msg.Result := RealizePalette(DC);

  // ���� ������� ���������� ���� ���� ���� � ��������� �������,
  // �������������� ����
  if (Msg.Result <> GDI_ERROR) then
    InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
��������� WM_PALETTECHANGED}
procedure TfrmCube.WMPaletteChanged(var Msg : TWMPaletteChanged);
begin
  // ���� ���������� �������������� ������, ����� �����-���� ����������
  // �������� ��������� �������
  if ((Palette <> 0) and (THandle(TMessage(Msg).wParam) <> Handle))
  then begin
    if (RealizePalette(DC) <> GDI_ERROR) then
      UpdateColors(DC);

    Msg.Result := 0;
  end;
end;

end.

