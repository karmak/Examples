{*********************************************************************}
{***                        ОТРАЖЕНИЕ                              ***}
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

const
  cyan : Array [0..3] of GLfloat = (0.0, 1.0, 1.0, 1.0);
  green : Array [0..3] of GLfloat = (0.2, 1.0, 0.2, 1.0);
  table_mat : Array [0..3] of GLfloat  = (1.0, 1.0, 1.0, 0.5);

const
  {вспомогательные константы}
  DEG2RAD = Pi / 180.0;
  DIST = 20.0;
  {идентификаторы списков}
  TABLE = 1;
  CYLINDER = 2;
  CONUS = 3;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    DC: HDC;
    hrc: HGLRC;
    ps : TPaintStruct;
    q, qDisk : GLUquadricObj;
    uTimerId : uint;
    xrot : GLFloat;
    yrot : GLFloat;
    spin : GLFloat;
    eyex, eyey, eyez : GLfloat;

    procedure SetDCPixelFormat;
    procedure make_objects;
    procedure draw_objects;
    procedure PrepareImage;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

uses mmSystem;

{$R *.DFM}

{======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
begin
  BeginPaint(Handle, ps);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
  eyex := dist * cos(yrot * DEG2RAD) * cos(xrot * DEG2RAD);
  eyez := dist * sin(yrot * DEG2RAD) * cos(xrot * DEG2RAD);
  eyey := dist * sin(xrot * DEG2RAD);
  // точка зрения сверху
  glPushMatrix;
  gluLookAt(eyex, eyey, eyez, 0.0, 0.0, 0.0,  0.0, 1.0, 0.0);
  // рисуем стол в плоскости отражения
  glEnable(GL_STENCIL_TEST);
  glStencilFunc(GL_ALWAYS, 1, 1); // stencil задаем 1
  glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
  glColorMask(0, 0, 0, 0);

  glCallList(table);

  glColorMask(1, 1, 1, 1);
  //  точка отражения
  //  рисуем, когда stencil = 1
  if eyey > 0.0 then begin
     glPushMatrix;
     glStencilFunc(GL_EQUAL, 1, 1); // рисуем при 1
     glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
     glScalef(1.0, -1.0, 1.0);
     draw_objects;
     glPopMatrix;
  end;
  glDisable(GL_STENCIL_TEST);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glCallList(table);
  glDisable(GL_BLEND);
  // смотрим сверху
  glPushMatrix;
  draw_objects;
  glPopMatrix;
  glPopMatrix;

  SwapBuffers(DC);          // конец работы
  EndPaint(Handle, ps);
end;

{======================================================================
Подготовка списков}
procedure TfrmGL.make_objects;
begin
  glNewList(table, GL_COMPILE);
    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @table_mat);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @table_mat);
    // квадрат, покрытый текстурой
    glEnable(GL_TEXTURE_2D);
    glPushMatrix;
    glScalef(4.0, 4.0, 4.0);
    glBegin(GL_POLYGON);
      glNormal3f(0.0, 1.0, 0.0);
      glTexCoord2f(0.0, 0.0);
      glVertex3f(-1.0, 0.0,  1.0);
      glTexCoord2f(1.0, 0.0);
      glVertex3f( 1.0, 0.0,  1.0);
      glTexCoord2f(1.0, 1.0);
      glVertex3f( 1.0, 0.0, -1.0);
      glTexCoord2f(0.0, 1.0);
      glVertex3f(-1.0, 0.0, -1.0);
    glEnd;
    glPopMatrix;
    glDisable(GL_TEXTURE_2D);
  glEndList;

  glNewList(CYLINDER, GL_COMPILE);
    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @cyan);
    gluCylinder(q, 0.5, 0.5, 1.0, 10, 20);
  glEndList;

  glNewList(CONUS, GL_COMPILE);
    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @green);
    gluCylinder(q, 1.5, 0.0,  2.5, 10, 20);
    {рисуем крышку}
    gluDisk(qDisk, 0.0, 1.5, 10, 20);
  glEndList;
end;

{======================================================================
Рисование объектов}
procedure TfrmGL.draw_objects;
begin
  If (eyex < 0.5) then begin
   glPushMatrix;
   glTranslatef(1.0, 1.5, 0.0);
   glRotatef(spin, 1.0, 0.5, 0.0);
   glRotatef(0.5*spin, 0.0, 0.5, 1.0);
   glEnable(GL_DEPTH_TEST);
   glCallList(CYLINDER);
   glPopMatrix;

   glPushMatrix;
   glTranslatef(-1.0, 0.85+3.0*abs(cos(0.01*spin)), 0.0);
   glRotatef(0.5*spin, 0.0, 0.5, 1.0);
   glRotatef(spin, 1.0, 0.5, 0.0);
   glScalef(0.5, 0.5, 0.5);
   glCallList(CONUS);
   glDisable(GL_DEPTH_TEST);
   glPopMatrix;
   end
   else begin
   glPushMatrix;
   glTranslatef(-1.0, 0.85+3.0*abs(cos(0.01*spin)), 0.0);
   glRotatef(0.5*spin, 0.0, 0.5, 1.0);
   glRotatef(spin, 1.0, 0.5, 0.0);
   glScalef(0.5, 0.5, 0.5);
   glEnable(GL_DEPTH_TEST);
   glCallList(CONUS);
   glPopMatrix;

   glPushMatrix;
   glTranslatef(1.0, 1.5, 0.0);
   glRotatef(spin, 1.0, 0.5, 0.0);
   glRotatef(0.5*spin, 0.0, 0.5, 1.0);
   glCallList(CYLINDER);
   glDisable(GL_DEPTH_TEST);
   glPopMatrix;
  end;
end;

// Дальше идут обычные для OpenGL действия
{======================================================================
Тик таймера}
procedure FNTimeCallBack (uTimerID, uMessage: UINT; dwUser, dw1, dw2: DWORD) stdcall;
begin
  With frmGL do begin
       spin := spin + 0.1;
       yrot := yrot + 0.2;
       If (yrot >= 360.0) then yrot := 0.0;
  end;
  InvalidateRect(frmGL.Handle, nil, False);
end;

{======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  PrepareImage;
  q := gluNewQuadric;
  qDisk := gluNewQuadric;
  gluQuadricOrientation(qDisk, GLU_INSIDE); // отражает в противоположную сторону
  make_objects;
  xrot := 30.0;
  yrot := 50.0;
  spin := 0.0;
  glEnable(GL_NORMALIZE);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glClearColor(0.5, 0.5, 0.5, 1.0);
  uTimerID := timeSetEvent (4, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
end;

{======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
var
  gldAspect : GLdouble;
begin
  gldAspect := Width / Height;
  glViewport(0, 0, Width, Height);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glFrustum(-gldaspect, gldaspect, -1.0, 1.0, 4.0, 25.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

{======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  timeKillEvent (uTimerID);
  gluDeleteQuadric (q);
  gluDeleteQuadric (qDisk);
  glDeleteLists (table, 3);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
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
     finally
      FreeMem (Data);
      DeleteDC (MemDC);
      Bitmap.Free;
   end;
  end;
end;

{======================================================================
Устанавливаем формат пикселей}
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

end.

