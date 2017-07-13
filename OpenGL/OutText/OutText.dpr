{*********************************************************************}
{***               ВЫВОД ПРОИЗВОЛЬНОГО ТЕКСТА                      ***}
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

program OutText;

uses
  Windows, Messages, OpenGL;

const
  AppName = 'GLFont';
  GLF_START_LIST = 1000;
  id_Timer = 100;              // идентификатор таймера
  Litera : PChar = 'OpenGL';   // выводимый текст

var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;
  ps : TPAINTSTRUCT;
  gldAspect : GLdouble ;
  glnWidth, glnHeight : GLsizei;
  lf : TLOGFONT;                          // для Delphi 4 - LOGFONT
  hFontNew, hOldFont : HFONT;
  agmf : Array [0..255] of TGLYPHMETRICSFLOAT ;
  // для Delphi 4 :
  {agmf : Array [0..255] of GLYPHMETRICSFLOAT;}
  AngY, AngX, AngZ : GLfloat;
  radius : GLfloat;
  maxObjectSize, aspect : GLfloat;
  near_plane, far_plane : GLdouble;
  lpMsgBuf: PChar;

// Установка формата пикселей вынесена в отдельный файл.
{$I SetDCPixelFormat}

// Процедура собственно рисования - команды OpenGL.
procedure DrawScene;
begin
  glClear (GL_COLOR_BUFFER_BIT );
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -radius);
  glRotatef(AngX, 1.0, 0.0, 0.0);
  glRotatef(AngY, 0.0, 1.0, 0.0);
  glRotatef(AngZ, 0.0, 0.0, 1.0);
  glScalef(0.3, 0.3, 0.3);        // масштабируем изображение
  glListBase(GLF_START_LIST);
  glCallLists(6, GL_UNSIGNED_BYTE, Litera); // В Litera 6 символов

  glFlush; // завершение отрисовки
end;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; export; stdcall;
Begin
  WindowProc := 0;
  case Message of
  wm_Destroy :
      begin
      wglDeleteContext (hrc); // удаление контекста воспроизведения
      KillTimer(Window, id_Timer);
      glDeleteLists(GLF_START_LIST, 256);
      PostQuitMessage (0);
      Exit;
      end;
  wm_Create:
      begin
      AngY := 5.0;
      AngX := 1.0;
      AngZ := 3.0;

      near_plane := 2.0;
      far_plane := -2.0;
      maxObjectSize := 2.0;
      radius := near_plane + maxObjectSize/2.0;

      dc := GetDC (Window);
      SetDCPixelFormat (dc);
      hrc := wglCreateContext (dc);
      wglMakeCurrent(dc, hrc);
      glColor3f(0, 0, 1.0);           // цвет рисования - синий

      // подготовка вывода текста
      FillChar(lf, SizeOf(lf), 0);
      lf.lfHeight               :=   -28 ;
      lf.lfWeight               :=   FW_NORMAL ;
      lf.lfCharSet              :=   ANSI_CHARSET ;
      lf.lfOutPrecision         :=   OUT_DEFAULT_PRECIS ;
      lf.lfClipPrecision        :=   CLIP_DEFAULT_PRECIS ;
      lf.lfQuality              :=   DEFAULT_QUALITY ;
      lf.lfPitchAndFamily       :=   FF_DONTCARE OR DEFAULT_PITCH;
      lstrcpy (lf.lfFaceName, 'Arial') ;

      hFontNew := CreateFontIndirect(lf);
      hOldFont := SelectObject(DC,hFontNew);

      wglUseFontOutlines(DC, 0, 255, GLF_START_LIST, 0.0, 0.15,
         WGL_FONT_POLYGONS, @agmf);

      DeleteObject(SelectObject(DC,hOldFont));
      DeleteObject(SelectObject(DC,hFontNew));
      SetTimer (Window, id_Timer, 50, nil); // Установка таймера
      end;
  wm_Size:  // при изменении размеров окна отслеживаем текущие размеры окна
      begin
      glnWidth := LoWord (lParam);         // ширина окна
      glnHeight := HiWord (lParam);        // высота окна
      gldAspect := glnWidth / glnHeight;   // эта величина нужна для установления перспективы
      glMatrixMode(GL_PROJECTION);         // сделать текущей матрицу проекции
      glLoadIdentity;                      // заменяет текущую матрицу на единичную
      // определение перспективы - из библиотеки glu32.dll
      gluPerspective(40.0,           // угол видимости в направлении оси Y
                     gldAspect,      // угол видимости в направлении оси X - через аспект
                     1.0,            // расстояние от наблюдателя до ближней плоскости отсечения
                     4.0);          // расстояние от наблюдателя до дальней плоскости отсечения
      glViewport(0, 0, glnWidth, glnHeight);
      glMatrixMode (GL_MODELVIEW);
      end;
  wm_Timer:
      begin
      AngX := AngX + 3.0;
      AngY := AngY + 3.0;
      AngZ := AngZ + 1.0;
      InvalidateRect(Window, nil, False);
      end;
  wm_Paint: DrawScene;
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
  If RegisterClass (WindowClass) = 0 then Halt (255);
  Window := CreateWindow (AppName, AppName,
      ws_OverLappedWindow or ws_ClipChildren or ws_ClipSiBlings, // обязательно для OpenGL
      cw_UseDefault, cw_UseDefault,
      cw_UseDefault, cw_UseDefault,
      HWND_DESKTOP, 0, HInstance, nil);
  ShowWindow (Window, CmdShow);
  UpdateWindow (Window);
  While GetMessage (Message, 0, 0, 0) do begin
      TranslateMessage (Message);
      DispatchMessage (Message);
  end;
end.
