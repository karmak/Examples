// ��������� ���������� ����� ��������� PIXELFORMATDESCRIPTOR
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR; // ������ ������� ��������
 nPixelFormat : Integer;
Begin
 With pfd do  begin
  nSize := sizeof (TPIXELFORMATDESCRIPTOR); // ������ ���������
  nVersion := 1;                            // ����� ������
  dwFlags := PFD_DRAW_TO_WINDOW OR PFD_SUPPORT_OPENGL; // ��������� ������� ������, ������������ ���������� � ���������
  iPixelType := PFD_TYPE_RGBA; // ����� ��� ����������� ������
  cColorBits := 16;            // ����� ������� ���������� � ������ ������ �����
  cRedBits := 0;               // ����� ������� ���������� �������� � ������ ������ RGBA
  cRedShift := 0;              // �������� �� ������ ����� ������� ���������� �������� � ������ ������ RGBA
  cGreenBits := 0;             // ����� ������� ���������� ������� � ������ ������ RGBA
  cGreenShift := 0;            // �������� �� ������ ����� ������� ���������� ������� � ������ ������ RGBA
  cBlueBits := 0;              // ����� ������� ���������� ������ � ������ ������ RGBA
  cBlueShift := 0;             // �������� �� ������ ����� ������� ���������� ������ � ������ ������ RGBA
  cAlphaBits := 0;             // ����� ������� ���������� ����� � ������ ������ RGBA
  cAlphaShift := 0;            // �������� �� ������ ����� ������� ���������� ����� � ������ ������ RGBA
  cAccumBits := 0;             // ����� ����� ������� ���������� � ������ ������������
  cAccumRedBits := 0;          // ����� ������� ���������� �������� � ������ ������������
  cAccumGreenBits := 0;        // ����� ������� ���������� ������� � ������ ������������
  cAccumBlueBits := 0;         // ����� ������� ���������� ������ � ������ ������������
  cAccumAlphaBits := 0;        // ����� ������� ���������� ����� � ������ ������������
  cDepthBits := 32;            // ������ ������ ������� (��� z)
  cStencilBits := 0;           // ������ ������ ���������
  cAuxBuffers := 0;            // ����� ��������������� �������
  iLayerType := PFD_MAIN_PLANE;// ��� ���������
  bReserved := 0;              // ����� ���������� ��������� � ������� �����
  dwLayerMask := 0;            //
  dwVisibleMask := 0;          // ������ ��� ���� ������������ ������ ���������
  dwDamageMask := 0;           // ������������
  end;

  nPixelFormat := ChoosePixelFormat (hdc, @pfd); // ������ ������� - �������������� �� ��������� ������ ��������
  SetPixelFormat (hdc, nPixelFormat, @pfd);      // ������������� ������ �������� � ��������� ����������
End;
