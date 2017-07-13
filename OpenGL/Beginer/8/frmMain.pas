{*********************************************************************}
{***                 СФЕРА И КОНУС                                 ***}
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
  TfrmCube = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    DC : HDC;
    hrc : HGLRC;
    Palette : HPalette;
    quadSphere : GLUquadricObj ;
    quadConus : GLUquadricObj ;
    Angle : GlFloat;
    stepAngle : GlFloat;

    procedure InitializeRC;
    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMQueryNewPalette(var Msg: TWMQueryNewPalette); message WM_QUERYNEWPALETTE;
    procedure WMPaletteChanged(var Msg: TWMPaletteChanged); message WM_PALETTECHANGED;
  end;

const
  // массив свойств материала
  ColorSphere: Array[0..3] of GLfloat = (0.0, 0.0, 1.0, 1.0);
  ColorConus: Array[0..3] of GLfloat = (1.0, 0.0, 0.0, 1.0);
  CONUS = 1;
var
  frmCube: TfrmCube;

implementation

{$R *.DFM}

{=======================================================================
Процедура инициализации источника цвета}
procedure TfrmCube.InitializeRC;
begin
  glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
  glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);   // включаем источник света 0
end;

{=======================================================================
Рисование картинки}
procedure TfrmCube.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  // очистка буфера цвета и буфера глубины
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glLoadIdentity;
  glTranslatef (0.0, 0.0, -8.0);
  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @ColorSphere);
  gluSphere(quadSphere, 1 / abs(Angle + 1), // радиус
                        20,   // количество линий - "долгота"
                        20);  // количество линий - "широта"
  glRotatef (Angle, 0.0, 0.0, 1.0);
  glRotatef (Angle, 0.0, 1.0, 0.0);
  glCallList (CONUS);
  SwapBuffers(DC);               // конец работы
  EndPaint(Handle, ps);
end;

{=======================================================================
Тик таймера}
procedure TfrmCube.Timer1Timer(Sender: TObject);
begin
  Angle := Angle + stepAngle;
  If Angle > 90 then stepAngle := -stepAngle
     else If Angle < -90 then stepAngle := -stepAngle;
  InvalidateRect(Handle, nil, False);
end;

// Дальше идут обычные для OpenGL действия
{=======================================================================
Создание окна}
procedure TfrmCube.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  InitializeRC;
  Angle := 0;
  stepAngle := 3.0;

  // Создаем объект, который будем изображать - сфера
  quadSphere := gluNewQuadric();
  gluQuadricDrawStyle(quadSphere, GLU_FILL); // Стиль визуализации
  // Создаем объект, который будем изображать - конус
  quadConus := gluNewQuadric();
  gluQuadricDrawStyle(quadConus, GLU_FILL);  // Стиль визуализации

  glNewList (CONUS, GL_COMPILE);
  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @ColorConus);
  glTranslatef(0.0 , -0.4, 0.0);
  gluCylinder (quadConus, 0.25,  // радиус 1
                     0.0,        // радиус 2
                     0.8,        // высота
                     20,         // количество линий - "долгота"
                     20);        // количество линий - "широта"
  glEndList;
end;

{=======================================================================
Задаем формат пикселей}
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

    // Стандартные установки номера версии и числа элементов палитры
    lpPalette^.palVersion := $300;
    lpPalette^.palNumEntries := nColors;

    byRedMask   := (1 shl pfd.cRedBits) - 1;
    byGreenMask := (1 shl pfd.cGreenBits) - 1;
    byBlueMask  := (1 shl pfd.cBlueBits) - 1;

    // Заполняем палитру цветами
    for i := 0 to nColors - 1 do begin
      lpPalette^.palPalEntry[i].peRed   := (((i shr pfd.cRedShift)   and byRedMask)   * 255) DIV byRedMask;
      lpPalette^.palPalEntry[i].peGreen := (((i shr pfd.cGreenShift) and byGreenMask) * 255) DIV byGreenMask;
      lpPalette^.palPalEntry[i].peBlue  := (((i shr pfd.cBlueShift)  and byBlueMask)  * 255) DIV byBlueMask;
      lpPalette^.palPalEntry[i].peFlags := 0;
    end;

    // Создаем палитру
    Palette := CreatePalette(lpPalette^);
    HeapFree(hHeap, 0, lpPalette);

    // Устанавливаем ее в контексте устройства
    if (Palette <> 0) then begin
      SelectPalette(DC, Palette, False);
      RealizePalette(DC);
    end;
  end;

end;

{=======================================================================
Изменение размеров окна}
procedure TfrmCube.FormResize(Sender: TObject);
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(10.0, Width / Height, 1.0, 10.0);
  glViewport(0, 0, Width, Height);
  glMatrixMode(GL_MODELVIEW);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы}
procedure TfrmCube.FormDestroy(Sender: TObject);
begin
  glDeleteLists (CONUS, 1);
  gluDeleteQuadric (quadSphere);
  gluDeleteQuadric (quadConus);
  wglMakeCurrent (0, 0);
  wglDeleteContext (hrc);
  ReleaseDC (Handle, DC);
end;

{=======================================================================
Обработка сообщений}
procedure TfrmCube.WMQueryNewPalette(var Msg : TWMQueryNewPalette);
begin
  // Это сообщение посылается окну, которое становится активным
  // В ответ мы должны реализовать свою логическую палитру, т.к.
  // пока главное окно не было активным, другое прложение
  // могло изменить системную палитру
  if (Palette <> 0) then begin
    Msg.Result := RealizePalette(DC);

  // Если удалось отобразить хоть один цвет в системную палитру,
  // перерисовываем окно
  if (Msg.Result <> GDI_ERROR) then
    InvalidateRect(Handle, nil, False);
  end;
end;

procedure TfrmCube.WMPaletteChanged(var Msg : TWMPaletteChanged);
begin
  if ((Palette <> 0) and (THandle(TMessage(Msg).wParam) <> Handle))
  then begin
    if (RealizePalette(DC) <> GDI_ERROR) then
      UpdateColors(DC);

    Msg.Result := 0;
  end;
end;

end.

