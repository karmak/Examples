{*********************************************************************}
{***        ������������� ������ ������                            ***}
{*** � ���� ������� ��������, ��� �������� ������� �� ��������     ***}
{*** ������������. ��� ������ �� �����-���� ������� �� ������ ����.***}
{*** ������ ������ �������� �� �������� API.                       ***}
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
program Select;

uses
  Messages,  Windows,  OpenGL;

const
  AppName = 'Gl_Select';
  MAXOBJS = 20;                       // ������������ ����� ��������
  MAXSELECT = 4;                      // ����������� ��������� ����� ��������

{--- ������ ��� �������� �������� ---}
type
  GLObject = record                   // ������ - �����������
     {������� ������������}
     v1 : Array [0..1] of GLFloat;
     v2 : Array [0..1] of GLFloat;
     v3 : Array [0..1] of GLFloat;
     color : Array [0..2] of GLFloat; // ���� �������
  end;

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  windW, windH : GLint;
  dc : HDC;
  hrc : HGLRC;
  ps : TPAINTSTRUCT;
  objects : Array [0..MAXOBJS - 1] of GLObject;  // ������ ��������
  vp : Array [0..3] of GLint;
  selectBuf : Array [0..MAXSELECT - 1] of GLuint;// ����� ������
  hit : GLint;
  mouseX, mouseY : Integer;

{$I SetDC}

{=======================================================================
������������� ��������}
procedure InitObjects;
var
  i : GLint ;
  x, y : GLfloat ;
begin
  For i := 0 to MAXOBJS - 1 do begin
    x := random(300) - 150;
    y := random(300) - 150;
    // ������� ������������ - ��������
    objects[i].v1[0] := x + random(50) - 25;
    objects[i].v2[0] := x + random(50) - 25;
    objects[i].v3[0] := x + random(50) - 25;
    objects[i].v1[1] := y + random(50) - 25;
    objects[i].v2[1] := y + random(50) - 25;
    objects[i].v3[1] := y + random(50) - 25;
    // ����� ���������� ����������
    objects[i].color[0] := (random(100) + 50) / 150.0;
    objects[i].color[1] := (random(100) + 50) / 150.0;
    objects[i].color[2] := (random(100) + 50) / 150.0;
  end;
end;

{=======================================================================
��������� ������� ��������}
procedure Render (mode : GLenum); // �������� - ����� (������/���������)
var
  i : GLuint;
begin
  For i := 0 to MAXOBJS - 1 do begin
    If mode = GL_SELECT then glLoadName(i); // �������� ���������� �����
    glColor3fv(@objects[i].color);          // ���� ��� ���������� �������
    glBegin(GL_POLYGON);                    // ������ �����������
        glVertex2fv(@objects[i].v1);
        glVertex2fv(@objects[i].v2);
        glVertex2fv(@objects[i].v3);
    glEnd;
  end;
end;

{=======================================================================
����� ������� � �����}
function DoSelect(x : GLint; y : GLint) : GLint;
var
  hits : GLint;
begin
  glSelectBuffer(MAXSELECT, @selectBuf); // �������� ������ ������
  glRenderMode(GL_SELECT); // ����� ������
  // ����� ������ ����� ��� ������ ��������� ������
  glInitNames;             // ������������� ����� ����
  glPushName(0);           // ��������� ����� � ���� ����

  glGetIntegerv(GL_VIEWPORT, @vp);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPickMatrix(x, windH-y, 4, 4, @vp);
  gluOrtho2D(-175, 175, -175, 175);
  glMatrixMode(GL_MODELVIEW);

  glClear(GL_COLOR_BUFFER_BIT);

  Render(GL_SELECT); // ������ ������ �������� � �������

  hits := glRenderMode(GL_RENDER);

  if hits <= 0
     then DoSelect := -1
     else DoSelect := selectBuf[(hits-1)*4+3];
end;

{=======================================================================
��������� ����� ������� ����� h}
procedure RecolorTri (h : GLint);
begin
  objects[h].color[0] := (random(100) + 50) / 150.0;
  objects[h].color[1] := (random(100) + 50) / 150.0;
  objects[h].color[2] := (random(100) + 50) / 150.0;
end;

{=======================================================================
�������� ��������� ��������� ��������}
procedure DrawScene;
begin
  glPushMatrix;

  glGetIntegerv(GL_VIEWPORT, @vp);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluOrtho2D(-175, 175, -175, 175);
  glMatrixMode(GL_MODELVIEW);

  glClear(GL_COLOR_BUFFER_BIT);

  Render(GL_RENDER); // ������ ������ �������� ��� ������

  glPopMatrix;

  glFlush;
end;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; export; stdcall;
Begin
  WindowProc := 0;
  case Message of
  wm_Destroy : begin
               wglDeleteContext (hrc);
               PostQuitMessage (0);
               Exit;
               end;
  WM_CREATE:   begin
               Randomize;
               dc := GetDC (Window);
               SetDCPixelFormat (dc);
               hrc := wglCreateContext (dc);
               wglMakeCurrent (dc, hrc);
               InitObjects;
               end;
  WM_SIZE:     begin
               windW := LOWORD (lParam);
               windH := HIWORD (lParam);
               glViewport(0, 0, windW, windH);
               end;
  WM_PAINT:    begin
               BeginPaint (Window, ps);
               DrawScene;
               EndPaint (Window, ps);
               end;
  WM_LBUTTONDOWN: {--- ������� �� ������ ���� ---}
               begin
               mouseX := LoWord (lParam);
               mouseY := HiWord (lParam);
               hit := DoSelect(mouseX, mouseY);    // ����� ������� ��� ��������
               If hit <> -1 then RecolorTri(hit);  // ������������� ������
               InvalidateRect(Window, nil, False); // ��������� ��������
               end;
  end; // case

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

Begin
   With WindowClass do begin
     Style := cs_HRedraw or cs_VRedraw;
     lpfnWndProc := @WindowProc;
     hCursor := LoadCursor (0, idc_Arrow);
     lpszClassName := AppName;
   end;
   RegisterClass (WindowClass);
   Window := CreateWindow (AppName, AppName,
   ws_OverlappedWindow or ws_ClipChildren or ws_Clipsiblings,
   cw_UseDefault, cw_UseDefault,  cw_UseDefault, cw_UseDefault,
   HWND_DESKTOP, 0, HInstance, nil);
   ShowWindow (Window, CmdShow);
   While GetMessage (Message, 0, 0, 0) do begin
     TranslateMessage (Message);
     DispatchMessage (Message);
   end;
End.

