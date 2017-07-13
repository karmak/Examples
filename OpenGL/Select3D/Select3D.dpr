{*********************************************************************}
{***        ИСПОЛЬЗОВАНИЕ БУФЕРА ВЫБОРА                            ***}
{*** Вариант с выбором трехмерных объектов (кубиков).              ***}
{*** При щелчке на каком-либо объекте он меняет цвет.              ***}
{*** Для укорочения кода кубики рисуются упрощенно.                ***}
{*** Пример построен на API.                                       ***}
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
program Select3D;

uses
  Messages, Windows, OpenGL;

const
  AppName = 'GL_Select';
  MaxObjects = 100;     // максимальное число объектов
  MaxSelect = 10;       // максимально выбранное число объектов

{--- вспомогательный тип - массив координат ---}
type
  CoordArray = Array [1..8] of GlFloat;

{--- запись для хранения объектов ---}
type
  GLObject = record                   // объект - куб
     x, y, z : CoordArray;            // координаты восьми вершин куьа по осям
     color : Array [0..2] of GLFloat; // цвет
  end;

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  windW, windH : GLint;
  dc : HDC;
  hrc : HGLRC;
  ps : TPAINTSTRUCT;
  objects : Array [0..MaxObjects - 1] of GLObject;
  objectCount : GLint;
  numObjects : GLint;
  vp : Array [0..3] of GLint;
  selectBuf : Array [0..MAXSELECT - 1] of GLuint;
  hit : GLint;
  mouseX, mouseY : Integer;

{$I SetDC}

{======================================================================
Рисование отдельного куба}
procedure OneCube (x, y, z : CoordArray);
begin
  // рисование шести сторон куба
  glBegin(GL_POLYGON);
    glVertex3f(x[1], y[1], z[1]);
    glVertex3f(x[2], y[2], z[2]);
    glVertex3f(x[3], y[3], z[3]);
    glVertex3f(x[4], y[4], z[4]);
  glEnd;

  glBegin(GL_POLYGON);
    glVertex3f(x[5], y[5], z[5]);
    glVertex3f(x[6], y[6], z[6]);
    glVertex3f(x[7], y[7], z[7]);
    glVertex3f(x[8], y[8], z[8]);
  glEnd;

  glBegin(GL_POLYGON);
    glVertex3f(x[2], y[2], z[2]);
    glVertex3f(x[8], y[8], z[8]);
    glVertex3f(x[7], y[7], z[7]);
    glVertex3f(x[3], y[3], z[3]);
  glEnd;

  glBegin(GL_POLYGON);
    glVertex3f(x[1], y[1], z[1]);
    glVertex3f(x[4], y[4], z[4]);
    glVertex3f(x[6], y[6], z[6]);
    glVertex3f(x[5], y[5], z[5]);
  glEnd;

  glBegin(GL_POLYGON);
    glVertex3f(x[8], y[8], z[8]);
    glVertex3f(x[2], y[2], z[2]);
    glVertex3f(x[1], y[1], z[1]);
    glVertex3f(x[5], y[5], z[5]);
  glEnd;

  glBegin(GL_POLYGON);
    glVertex3f(x[7], y[7], z[7]);
    glVertex3f(x[6], y[6], z[6]);
    glVertex3f(x[4], y[4], z[4]);
    glVertex3f(x[3], y[3], z[3]);
  glEnd;
end;

{======================================================================
Заполнение массива объектов. num - нужное количество объектов}
procedure InitObjects(num : GLint);
var
  i : GLint ;
  x, y, z : GLfloat ;
begin
  objectCount := num;

  For i := 0 to num - 1 do begin
  // базовая вершина кубика
  x := random(30) - 15;
  y := random(30) - 15;
  z := random(30) - 15;

  // координаты вершин кубика
  objects[i].x [1] := 1.0 + x;
  objects[i].y [1] := 1.0 + y;
  objects[i].z [1] := 1.0 + z;
  objects[i].x [2] := -1.0 + x;
  objects[i].y [2] := 1.0 + y;
  objects[i].z [2] := 1.0 + z;
  objects[i].x [3] := -1.0 + x;
  objects[i].y [3] := -1.0 + y;
  objects[i].z [3] := 1.0 + z;
  objects[i].x [4] := 1.0 + x;
  objects[i].y [4] := -1.0 + y;
  objects[i].z [4] := 1.0 + z;
  objects[i].x [5] := 1.0 + x;
  objects[i].y [5] := 1.0 + y;
  objects[i].z [5] := -1.0 + z;
  objects[i].x [6] := 1.0 + x;
  objects[i].y [6] := -1.0 + y;
  objects[i].z [6] := -1.0 + z;
  objects[i].x [7] := -1.0 + x;
  objects[i].y [7] := -1.0 + y;
  objects[i].z [7] := -1.0 + z;
  objects[i].x [8] := -1.0 + x;
  objects[i].y [8] := 1.0 + y;
  objects[i].z [8] := -1.0 + z;

  // заполняем случайно массив цветов кубика
  objects[i].color[0] := (random(100) + 50) / 150.0;
  objects[i].color[1] := (random(100) + 50) / 150.0;
  objects[i].color[2] := (random(100) + 50) / 150.0;
  end;
end;

{=======================================================================
Рисование массива объектов}
procedure Render (mode : GLenum);
var
  i : GLuint;
begin
  For i := 0 to objectCount - 1 do begin
   If mode = GL_SELECT then glLoadName(i); // загрузка очередного имени
   glColor3fv(@objects[i].color);          // цвет для очередного объекта
   OneCube (objects[i].x, objects[i].y, objects[i].z); // рисуем кубик
  end;
end;

{=======================================================================
Основная процедура рисования картинки}
procedure DrawScene;
begin
  glPushMatrix;
  glGetIntegerv(GL_VIEWPORT, @vp);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(100.0, windW/windH, 10.0, 150.0);
  glMatrixMode(GL_MODELVIEW);

  glClear (GL_COLOR_BUFFER_BIT);

  // этот фрагмент нужен для придания трёхмерности
  glTranslatef(0.0, 0.0, -8.0);   // перенос объекта - ось Z
  glRotatef(30.0, 1.0, 0.0, 0.0); // поворот объекта - ось X
  glRotatef(70.0, 0.0, 1.0, 0.0); // поворот объекта - ось Y

  Render(GL_RENDER);              // рисуем массив объектов без выбора

  glPopMatrix;

  glFlush;
end;

{=======================================================================
Выбор объекта в точке}
function DoSelect(x : GLint; y : GLint) : GLint;
var
  hits : GLint;
begin
  glSelectBuffer(MAXSELECT, @selectBuf); // создание буфера выбора
  glRenderMode(GL_SELECT); // режим выбора
  // режим выбора нужен для работы следующих команд
  glInitNames;             // инициализация стека имен
  glPushName(0);           // помещение имени в стек имен

  glPushMatrix;

  glGetIntegerv(GL_VIEWPORT, @vp);

  glMatrixMode(GL_PROJECTION);   // сделать текущей матрицу проекции
  glLoadIdentity;                // заменяет текущую матрицу на единичную
  gluPickMatrix(x, windH - y, 4, 4, @vp);
  gluPerspective(100.0,          // угол видимости в направлении оси Y
                 windW/windH,    // угол видимости в направлении оси X - через аспект
                 10.0,           // расстояние от наблюдателя до ближней плоскости отсечения
                 150.0);         // расстояние от наблюдателя до дальней плоскости отсечения
  glMatrixMode(GL_MODELVIEW);

  // этот фрагмент нужен для придания трёхмерности
  glTranslatef(0.0, 0.0, -8.0);   // перенос объекта - ось Z
  glRotatef(30.0, 1.0, 0.0, 0.0); // поворот объекта - ось X
  glRotatef(70.0, 0.0, 1.0, 0.0); // поворот объекта - ось Y

  glClear(GL_COLOR_BUFFER_BIT);

  Render(GL_SELECT);          // рисуем массив объектов с выбором

  glPopMatrix;

  hits := glRenderMode(GL_RENDER);

  if hits <= 0
     then DoSelect := -1
     else DoSelect := selectBuf[(hits-1)*4+3];
end;

{=======================================================================
Перекрашивание объекта номер h}
procedure Recolor (h : GLint);
begin
  objects[h].color[0] := (random(100) + 50) / 150.0;
  objects[h].color[1] := (random(100) + 50) / 150.0;
  objects[h].color[2] := (random(100) + 50) / 150.0;
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
  wm_Create:   begin
               Randomize;
               dc := GetDC (Window);
               SetDCPixelFormat (dc);
               hrc := wglCreateContext (dc); // создание контекста воспроизведения
               wglMakeCurrent (dc, hrc);     // установить текущий контекст воспроизведения
               numObjects := 10;
               InitObjects(numObjects);
               end;
  wm_Size:  // при изменении размеров окна отслеживаем текущие размеры окна
               begin
               windW := LoWord (lParam);         // ширина окна
               windH := HiWord (lParam);         // высота окна
               glViewport(0, 0, windW, windH);
               end;
  wm_Paint:    begin
               BeginPaint (Window, ps);
               DrawScene;
               EndPaint (Window, ps);
               end;
  wm_LButtonDown:
               begin
               {--- реакция на щелчок мыши ---}
               mouseX := LoWord (lParam);
               mouseY := HiWord (lParam);
               hit := DoSelect(mouseX, mouseY);    // номер объекта под курсором
               if hit <> -1 then Recolor(hit);     // перекрашиваем объект
               InvalidateRect(Window, nil, False); // обновляем картинку
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

