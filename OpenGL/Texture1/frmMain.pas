{*********************************************************************}
{***                 ИСПОЛЬЗОВАНИЕ ТЕКСТУРЫ                        ***}
{*** Используется текстура 64Х64 пикселя.                          ***}
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

type
  TfrmGL = class(TForm)
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);

  private
    DC: HDC;
    hrc: HGLRC;
    Angle: GLfloat;
    Angle1: GLfloat;
    bitmap: TBitmap;
    bits: Array [0..63, 0..63, 0..3] of GLubyte;

    procedure InitializeRC;
    procedure SetDCPixelFormat;
    procedure BmpTexture;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{**********************************************************************}
{***          ПРОЦЕДУРА ЗАГРУЗКИ И ИНИЦИАЛИЗАЦИИ ТЕКСТУРЫ           ***}
{**********************************************************************}
procedure TfrmGL.BmpTexture;
var
  i, j: Integer;
begin
   bitmap := TBitmap.Create;
   bitmap.LoadFromFile('gold.bmp'); // загрузка текстуры из файла

   {--- заполнение битового массива ---}
    for i := 0 to 63 do
      for j := 0 to 63 do begin
        bits [i, j, 0] := GetRValue(bitmap.Canvas.Pixels[i,j]);
        bits [i, j, 1] := GetGValue(bitmap.Canvas.Pixels[i,j]);
        bits [i, j, 2] := GetBValue(bitmap.Canvas.Pixels[i,j]);
        bits [i, j, 3] := 255;
    end;

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
                 64, 64,     // здесь задается размер текстуры
                 0, GL_RGBA, GL_UNSIGNED_BYTE, @bits);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_TEXTURE_GEN_S);
    glEnable(GL_TEXTURE_GEN_T);
end;

{=======================================================================
Тик таймера}
procedure TfrmGL.TimerTimer(Sender: TObject);
begin
  // Каждый "тик" изменяется значение угла
  Angle := Angle + 3.5;
  Angle1 := Angle1 + 3.5;
{  if (Angle >= 90.0) then
    Angle := 0.0;
  if (Angle1 >= 90.0) then
    Angle1 := 0.0;}
  InvalidateRect(Handle, nil, False); // перерисовка региона (Windows API)
end;

// Дальше идут обычные для OpenGL действия
{=======================================================================
Процедура инициализации источника цвета}
procedure TfrmGL.InitializeRC;
begin
  glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
  glEnable(GL_LIGHTING);  // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);    // включаем источник света 0
end;

{=======================================================================
Задаем формат пикселя}
procedure TfrmGL.SetDCPixelFormat;
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
Создание формы}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  Angle := 0;
  Angle1 := 0;
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  InitializeRC;
  BmpTexture;
  Timer.Enabled := True;
end;

{=======================================================================
Изменение размеров формы}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30.0, Width / Height, 1.0, 9.0);
  glViewport(0, 0, Width, Height);
  glMatrixMode(GL_MODELVIEW);
end;

{=======================================================================
Рисование картинки, обработка сообщения WM_PAINT}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  // очистка буфера цвета и ьуфера глубины
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  // трехмерность
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -8.0);
  glRotatef(Angle1, 1.0, 0.0, 0.0);
  glRotatef(Angle, 0.0, 8.0, 0.0); // поворот на угол

  // Стороны куба (нижняя не рисуется)
  glBegin(GL_POLYGON);
    glNormal3f(0.0, 0.0, 1.0);
    glVertex3f(1.0, 1.0, 1.0);
    glVertex3f(-1.0, 1.0, 1.0);
    glVertex3f(-1.0, -1.0, 1.0);
    glVertex3f(1.0, -1.0, 1.0);
  glEnd;

  glBegin(GL_POLYGON);
    glNormal3f(0.0, 0.0, -1.0);
    glVertex3f(-1.0, -1.0, -1.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(1.0, 1.0, -1.0);
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

  // конец работы
  SwapBuffers(DC);

  EndPaint(Handle, ps);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  Timer.Enabled := False;
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
end;

end.

