// Процедура заполнения полей структуры PIXELFORMATDESCRIPTOR
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR; // данные формата пикселей
 nPixelFormat : Integer;
Begin
 With pfd do  begin
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
