{*********************************************************************}
{***                 КОМАНДЫ OpenGL                                ***}
{*** Трёхмерные построения с использованием команд OpenGL.         ***}
{*** Вариант с использованием только функций API.                  ***}
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
program Cube;

uses
  Messages, Windows, OpenGL;

const
  AppName = 'Cube';

var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;
  ps : TPAINTSTRUCT;
  gldAspect : GLdouble ;
  glnWidth, glnHeight : GLsizei;

// Установка формата пикселей вынесена в отдельный файл.
{$I SetDCPixelFormat}

{=======================================================================
Процедура собственно рисования - команды OpenGL.}
procedure DrawScene;
begin
  glEnable(GL_DEPTH_TEST);             // разрешаем выполнение теста глубины
  glClearColor (0.85, 0.75, 0.5, 1.0); // определение цвета фона
  glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // очищаются буфер цвета и буфер глубины

  glLoadIdentity;                 // заменяет текущую матрицу на единичную
  // этот фрагмент нужен для придания трёхмерности
  glTranslatef(0.0, 0.0, -8.0);   // перенос объекта - ось Z
  glRotatef(30.0, 1.0, 0.0, 0.0); // поворот объекта - ось X
  glRotatef(70.0, 0.0, 1.0, 0.0); // поворот объекта - ось Y

  glColor3f(0, 0, 1.0); // цвет рисования - синий

  // рисование шести сторон куба
  glBegin(GL_POLYGON);
    glVertex3f(1.0, 1.0, 1.0);
    glVertex3f(-1.0, 1.0, 1.0);
    glVertex3f(-1.0, -1.0, 1.0);
    glVertex3f(1.0, -1.0, 1.0);
  glEnd;

  glBegin(GL_POLYGON);
    glVertex3f(1.0, 1.0, -1.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(-1.0, -1.0, -1.0);
    glVertex3f(-1.0, 1.0, -1.0);
  glEnd;

  glBegin(GL_POLYGON);
    glVertex3f(-1.0, 1.0, 1.0);
    glVertex3f(-1.0, 1.0, -1.0);
    glVertex3f(-1.0, -1.0, -1.0);
    glVertex3f(-1.0, -1.0, 1.0);
  glEnd;

  glBegin(GL_POLYGON);
    glVertex3f(1.0, 1.0, 1.0);
    glVertex3f(1.0, -1.0, 1.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(1.0, 1.0, -1.0);
  glEnd;

  glBegin(GL_POLYGON);
    glVertex3f(-1.0, 1.0, -1.0);
    glVertex3f(-1.0, 1.0, 1.0);
    glVertex3f(1.0, 1.0, 1.0);
    glVertex3f(1.0, 1.0, -1.0);
  glEnd;

  glBegin(GL_POLYGON);
    glVertex3f(-1.0, -1.0, -1.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(1.0, -1.0, 1.0);
    glVertex3f(-1.0, -1.0, 1.0);
  glEnd;

  glFlush; // завершение отрисовки
end;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; export; stdcall;
Begin
  WindowProc := 0;
  case Message of
  wm_Destroy :
      begin
      wglMakeCurrent (dc, 0);
      wglDeleteContext (hrc); // удаление контекста воспроизведения
      ReleaseDC (Window, dc);
      PostQuitMessage (0);
      Exit;
      end;
  wm_Create:
      begin
      dc := GetDC (Window);
      SetDCPixelFormat (dc);
      hrc := wglCreateContext (dc); // создание контекста воспроизведения
      wglMakeCurrent (dc, hrc);    // установить текущий контекст воспроизведения
      end;
  wm_Size:  // при изменении размеров окна отслеживаем текущие размеры окна
      begin
      glnWidth := LoWord (lParam);         // ширина окна
      glnHeight := HiWord (lParam);        // высота окна
      gldAspect := glnWidth / glnHeight;   // эта величина нужна для установления перспективы
      glMatrixMode(GL_PROJECTION); // сделать текущей матрицу проекции
      glLoadIdentity;              // заменяет текущую матрицу на единичную
      // определение перспективы - из библиотеки glu32.dll
      gluPerspective(30.0,           // угол видимости в направлении оси Y
                     gldAspect,      // угол видимости в направлении оси X - через аспект
                     1.0,            // расстояние от наблюдателя до ближней плоскости отсечения
                     10.0);          // расстояние от наблюдателя до дальней плоскости отсечения
      glViewport(0, 0, glnWidth, glnHeight);
      glMatrixMode(GL_MODELVIEW);    // сделать текущей видовую матрицу
      end;
  wm_Paint:
      begin
      dc := BeginPaint (Window, ps);
      DrawScene;
      EndPaint (Window, ps);
      end;
  end; // case

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

Begin
  With WindowClass do begin
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
      ws_OverLappedWindow or ws_ClipChildren or ws_ClipSiBlings,
      cw_UseDefault, cw_UseDefault,
      cw_UseDefault, cw_UseDefault,
      HWND_DESKTOP, 0, HInstance, nil);
  ShowWindow (Window, CmdShow);
  While GetMessage (Message, 0, 0, 0) do begin
      TranslateMessage (Message);
      DispatchMessage (Message);
  end;
end.
