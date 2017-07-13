{*********************************************************************}
{***        ИСПОЛЬЗОВАНИЕ ТЕКСТУРЫ ПРОИЗВОЛЬНОГО РАЗМЕРА           ***}
{*** Здесь текстура движется вместе с объектом.                    ***}
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
  Windows, Messages, Graphics, Forms, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);

  private
    DC : HDC;
    hrc : HGLRC;
    Angle : GLfloat;
    uTimerId : uint;
    wrkX, wrkY : Array [0..5] of Single;

    procedure SetDCPixelFormat;
    procedure PrepareImage;
  end;

const
  CUBE = 1;

var
  frmGL: TfrmGL;

implementation

uses mmSystem;

{$R *.DFM}

{======================================================================
Тик таймера}
procedure FNTimeCallBack (uTimerID, uMessage: UINT; dwUser, dw1, dw2: DWORD) stdcall;
begin
  frmGL.Angle := frmGL.Angle + 0.1;
  If (frmGL.Angle >= 60.0) then frmGL.Angle := 0.0;
  InvalidateRect(frmGL.Handle, nil, False);
end;

{======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
var
  i : 0..5;
begin
  Angle := 0;
  DC := GetDC (Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext (DC);
  wglMakeCurrent (DC, hrc);

  For i := 0 to 5 do begin
      wrkX [i] := sin (Pi / 3 * i);
      wrkY [i] := cos (Pi / 3 * i);
  end;

  glEnable (GL_DEPTH_TEST);

  PrepareImage;

  {--- список отдельного кубика ---}
  glNewList (CUBE, GL_COMPILE);
    glScalef (0.25, 0.25, 0.25);
    glBegin (GL_QUAD_STRIP);
        glTexCoord2d (0.0, 1.0);
        glVertex3f (-1.0,  1.0, 1.0);  // 1
        glTexCoord2d (0.0, 0.0);
        glVertex3f (-1.0, -1.0, 1.0);  // 2
       	glTexCoord2d (1.0, 1.0);
        glVertex3f (1.0,  1.0, 1.0);   // 3
        glTexCoord2d (1.0, 0.0);
        glVertex3f (1.0, -1.0, 1.0);   // 4
      	glTexCoord2d (0.0, 1.0);
        glVertex3f (1.0, 1.0, -1.0);   // 5
	glTexCoord2d (0.0, 0.0);
        glVertex3f (1.0, -1.0, -1.0);  // 6
        glTexCoord2d (1.0, 1.0);
        glVertex3f (-1.0,  1.0, -1.0); // 7
        glTexCoord2d (1.0, 0.0);
        glVertex3f (-1.0, -1.0, -1.0); // 8
      	glTexCoord2d (0.0, 1.0);
        glVertex3f (-1.0,  1.0, 1.0);  // 9
        glTexCoord2d (0.0, 0.0);
        glVertex3f (-1.0, -1.0, 1.0);  // 10
    glEnd;

    glBegin (GL_QUADS);
        glTexCoord2d (1.0, 0.0);
        glVertex3f (-1.0, 1.0, 1.0);
	glTexCoord2d (1.0, 1.0);
        glVertex3f (1.0, 1.0, 1.0);
	glTexCoord2d (0.0, 1.0);
        glVertex3f (1.0, 1.0, -1.0);
        glTexCoord2d (0.0, 0.0);
        glVertex3f (-1.0, 1.0, -1.0);
    glEnd;

    glBegin (GL_QUADS);
      glTexCoord2d (1.0, 0.0);
      glVertex3f (-1.0, -1.0, 1.0);
      glTexCoord2d (1.0, 1.0);
      glVertex3f (1.0, -1.0, 1.0);
      glTexCoord2d (0.0, 1.0);
      glVertex3f (1.0, -1.0, -1.0);
      glTexCoord2d (0.0, 0.0);
      glVertex3f (-1.0, -1.0, -1.0);
    glEnd;

    glScalef (4, 4, 4);

  glEndList;

  glClearColor (1.0, 0.75, 0.75, 0.0);
  uTimerID := timeSetEvent (4, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
end;

{======================================================================
Подготовка текстуры}
procedure TfrmGL.PrepareImage;

type
  PPixelArray = ^TPixelArray;
  TPixelArray = array [0..0] of Byte;

var
  Bitmap : TBitmap;
  Data : PPixelArray;
  BMInfo : TBitmapInfo;
  I, ImageSize : Integer;
  Temp : Byte;
  MemDC : HDC;
begin
  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile ('1.bmp');
  with BMinfo.bmiHeader do begin
    FillChar (BMInfo, SizeOf(BMInfo), 0);
    biSize := sizeof (TBitmapInfoHeader);
    biBitCount := 24;
    biWidth := Bitmap.Width;
    biHeight := Bitmap.Height;
    ImageSize := biWidth * biHeight;
    biPlanes := 1;
    biCompression := BI_RGB;

    MemDC := CreateCompatibleDC (0);
    GetMem (Data, ImageSize * 3);
    try
      GetDIBits (MemDC, Bitmap.Handle, 0, biHeight, Data, BMInfo, DIB_RGB_COLORS);
      For I := 0 to ImageSize - 1 do begin
          Temp := Data [I * 3];
          Data [I * 3] := Data [I * 3 + 2];
          Data [I * 3 + 2] := Temp;
      end;
      glTexImage2d(GL_TEXTURE_2D, 0, 3, biWidth,
                   biHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, Data);

      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
      glEnable(GL_TEXTURE_2D);
     finally
      FreeMem (Data);
      DeleteDC (MemDC);
      Bitmap.Free;
   end;
  end;
end;

{======================================================================
Рисование картинки}
procedure TfrmGL.FormPaint(Sender: TObject);
var
  i : 0..5;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glLoadIdentity;
  glTranslatef (0.0, 0.0, -9.0);
  glRotatef (60.0, 1.0, 0.0, 1.0);
  glRotatef (Angle, 0.0, 0.0, 1.0);

  For i := 0 to 5 do begin
      glPushMatrix;
      glTranslatef(wrkX [i], wrkY [i], 0.0);
      glRotatef(-60 * i, 0.0, 0.0, 1.0);
      glCallList (CUBE);
      glPopMatrix;
  end;

  SwapBuffers(DC);
end;

{======================================================================
Установка формата пикселей}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;

begin
  FillChar (pfd, SizeOf (pfd), 0);

  with pfd do begin
    nSize     := sizeof (pfd);
    nVersion  := 1;
    dwFlags   := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
    iPixelType:= PFD_TYPE_RGBA;
    cColorBits:= 24;
    cDepthBits:= 32;
    iLayerType:= PFD_MAIN_PLANE;
  end;

  nPixelFormat := ChoosePixelFormat (DC, @pfd);
  SetPixelFormat (DC, nPixelFormat, @pfd);
end;

{======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity;
  gluPerspective (18.0, Width / Height, 6.0, 10.0);
  glViewport (0, 0, Width, Height);
  glMatrixMode (GL_MODELVIEW);
end;

{======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  timeKillEvent (uTimerID);
  glDeleteLists (CUBE, 1);
  wglMakeCurrent (0, 0);
  wglDeleteContext (hrc);
  ReleaseDC (Handle, DC);
end;

end.

