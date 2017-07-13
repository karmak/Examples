{***********************************************************************}
{***              МИНИМАЛЬНАЯ ПРОГРАММА OpenGL                       ***}
{*** Вариант с использованием RAD - технологии.                      ***}
{***********************************************************************}
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
unit Unit1;

interface

uses
  Windows, Messages, Forms, OpenGL;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    hrc: HGLRC;                   // контекст воспроизведения OpenGL

  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

{=======================================================================
Процедура заполнения полей структуры PIXELFORMATDESCRIPTOR}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR; // данные формата пикселей
 nPixelFormat : Integer;
Begin
 With pfd do begin
  nSize := sizeof (TPIXELFORMATDESCRIPTOR); // размер структуры
  nVersion := 1;                            // номер версии
  dwFlags := PFD_DRAW_TO_WINDOW OR PFD_SUPPORT_OPENGL; // множество битовых флагов, определяющих устройство и интерфейс
  iPixelType := PFD_TYPE_RGBA; // режим для изображения цветов
  cColorBits := 16;            // число битовых плоскостей в каждом буфере цвета
  cRedBits := 0;               // число битовых плоскостей красного в каждом буфере RGBA
  cRedShift := 0;              // смещение от начала числа битовых плоскостей красного в каждом буфере RGBA
  cGreenBits := 0;             // число битовых плоскостей зелёного в каждом буфере RGBA
  cGreenShift := 0;            // смещение от начала числа битовых плоскостей зелёного в каждом буфере RGBA
  cBlueBits := 0;              // число битовых плоскостей синего в каждом буфере RGBA
  cBlueShift := 0;             // смещение от начала числа битовых плоскостей синего в каждом буфере RGBA
  cAlphaBits := 0;             // число битовых плоскостей альфа в каждом буфере RGBA
  cAlphaShift := 0;            // смещение от начала числа битовых плоскостей альфа в каждом буфере RGBA
  cAccumBits := 0;             // общее число битовых плоскостей в буфере аккумулятора
  cAccumRedBits := 0;          // число битовых плоскостей красного в буфере аккумулятора
  cAccumGreenBits := 0;        // число битовых плоскостей зелёного в буфере аккумулятора
  cAccumBlueBits := 0;         // число битовых плоскостей синего в буфере аккумулятора
  cAccumAlphaBits := 0;        // число битовых плоскостей альфа в буфере аккумулятора
  cDepthBits := 32;            // размер буфера глубины (ось z)
  cStencilBits := 0;           // размер буфера трафарета
  cAuxBuffers := 0;            // число вспомогательных буферов
  iLayerType := PFD_MAIN_PLANE;// тип плоскости
  bReserved := 0;              // число плоскостей переднего и заднего плана
  dwLayerMask := 0;            //
  dwVisibleMask := 0;          // индекс или цвет прозрачности нижней плоскости
  dwDamageMask := 0;           // игнорируется
  end;

  nPixelFormat := ChoosePixelFormat (hdc, @pfd); // запрос системе - поддерживается ли выбранный формат пикселей
  SetPixelFormat (hdc, nPixelFormat, @pfd);      // устанавливаем формат пикселей в контексте устройства
End;

{=======================================================================
Создание окна}
procedure TForm1.FormCreate(Sender: TObject);
begin
  SetDCPixelFormat (Canvas.Handle);
  hrc := wglCreateContext (Canvas.Handle);
end;

{=======================================================================
Рисование в окне}
procedure TForm1.FormPaint(Sender: TObject);
begin
  wglMakeCurrent(Canvas.Handle, hrc);       // устанавливаем контекст воспроизведения
{************ ЗДЕСЬ РАСПОЛАГАЮТСЯ КОМАНДЫ РИСОВАНИЯ OpenGL **************}

       glClearColor (0.85, 0.75, 0.5, 1.0); // определение цвета фона
       glClear (GL_COLOR_BUFFER_BIT);       // установление цвета фона

{************************************************************************}
  wglMakeCurrent(0, 0);                     // освобождаем контекст воспроизведения
end;

{=======================================================================
Завершение работы}
procedure TForm1.FormDestroy(Sender: TObject);
begin
  wglDeleteContext (hrc); // удаление контекста OpenGL
end;

end.

