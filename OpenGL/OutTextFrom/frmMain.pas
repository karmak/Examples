{*********************************************************************}
{***               ВЫВОД ПРОИЗВОЛЬНОГО ТЕКСТА                      ***}
{*** Вывод текста вынесен в отдельную процедуру.                   ***}
{*********************************************************************}
{*** Программы, использующие OpenGL, рекомендуется запускать       ***}
{*** вне среды Delphi, то есть запускать откомпилированные модули. ***}
{*** Автор - Краснов М.В.      softgl@chat.ru                      ***}
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

const
  GLF_START_LIST = 1000;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);

  private
    DC : HDC;
    hrc : HGLRC;
    Angle : GLfloat;
    uTimerId : uint;
    // массив свойств материала
    MaterialColor: Array[0..3] of GLfloat;

    procedure InitializeRC;
    procedure SetDCPixelFormat;
    procedure PreOutText;
  end;

var
  Form1: TForm1;

implementation

uses mmSystem;

{$R *.DFM}

{=======================================================================
Подготовка к выводу текста}
procedure TForm1.PreOutText;
var
  hOldFont : HFont;
  agmf : Array [0..255] of TGLYPHMETRICSFLOAT;
  // Для Delphi 4:
  {agmf : Array [0..255] of GLYPHMETRICSFLOAT;}
begin
  hOldFont := SelectObject(DC, Form1.Font.Handle);
  wglUseFontOutlines(DC, 0, 255, GLF_START_LIST, 0.0, 0.15,
               WGL_FONT_POLYGONS, @agmf);
  DeleteObject(SelectObject(DC, hOldFont));
end;

{=======================================================================
Вывод текста}
procedure OutText (Litera : PChar);
begin
  glListBase(GLF_START_LIST);
  glCallLists(Length (Litera), GL_UNSIGNED_BYTE, Litera);
end;

// Дальше идут обычные для OpenGL действия
{=======================================================================
Процедура инициализации источника цвета}
procedure TForm1.InitializeRC;
begin
  glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
  glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);   // включаем источник света 0
end;

{=======================================================================
Рисование картинки}
procedure TForm1.FormPaint(Sender: TObject);
begin
 // очистка буфера цвета и буфера глубины
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 // трехмерность
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -8.0);
 glRotatef(30.0, 1.0, 0.0, 0.0);
 glRotatef(Angle, 0.0, 1.0, 0.0); // поворот на угол
 glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @MaterialColor);
 // вывод текста
 OutText ('Проба');

 // конец работы
 SwapBuffers(DC);
end;

{=======================================================================
Обработка таймера}
procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  With Form1 do begin
    Angle := Angle + 0.2;
    If (Angle >= 720.0) then Angle := 0.0;
    MaterialColor [0] := (720.0 - Angle) / 720.0;
    MaterialColor [1] := Angle / 720.0;
    MaterialColor [2] := Angle / 720.0;
  end;
  InvalidateRect(Form1.Handle, nil, False); // перерисовка региона
end;

{=======================================================================
Установка формата пикселей}
procedure TForm1.SetDCPixelFormat;
var
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

end;

{=======================================================================
Создание окна}
procedure TForm1.FormCreate(Sender: TObject);
begin
  Angle := 0;
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  PreOutText;
  InitializeRC;
  uTimerID := timeSetEvent (1, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
end;

{=======================================================================
Изменение размеров окна}
procedure TForm1.FormResize(Sender: TObject);
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(40.0, Width / Height, 1.0, 20.0);
  glViewport(0, 0, Width, Height);
  glMatrixMode(GL_MODELVIEW);
end;

{=======================================================================
Конец работы приложения}
procedure TForm1.FormDestroy(Sender: TObject);
begin
  timeKillEvent(uTimerID);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  glDeleteLists (GLF_START_LIST, 256);
end;

end.

