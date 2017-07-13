
//------------------------------------------------------------------------
//
// Author      : Maarten Kronberger
// Email       : sulacomcclaw@hotmail.com
// Website     : http://www.sulaco.co.za
// Date        : 24 November 2003
// Version     : 1.0
// Description : Scene Antialiasing
//
//------------------------------------------------------------------------
program OpenGLApp;

uses
  Windows,
  Messages,
  Math,
  OpenGL,
  Jitter in 'Jitter.pas';

const
  WND_TITLE = 'Scene Antialiasing by McCLaw (RedBook)';
  FPS_TIMER = 1;                     // Timer to calculate FPS
  FPS_INTERVAL = 1000;               // Calculate FPS every 1000 ms

  // User Constants

  // Icosahedron constants
  X = 0.525731112119133606;
  Z = 0.850650808352039932;

  vdata : array [0..11] of array [0..2] of GLfloat = (
   (-X, 0.0, Z), (X, 0.0, Z), (-X, 0.0, -Z), (X, 0.0, -Z),
   (0.0, Z, X), (0.0, Z, -X), (0.0, -Z, X), (0.0, -Z, -X),
   (Z, X, 0.0), (-Z, X, 0.0), (Z, -X, 0.0), (-Z, -X, 0.0)
    );

  tindices : array [0..19] of array [0..2] of GLint = (
   (0,4,1), (0,9,4), (9,5,4), (4,5,8), (4,8,1),
   (8,10,1), (8,3,10),(5,3,8), (5,2,3), (2,7,3),
   (7,10,3), (7,6,10), (7,11,6), (11,0,6), (0,1,6),
   (6,1,10), (9,0,11), (9,11,2), (9,2,5), (7,2,11)
   );


  // Lighting and materials
  mat_ambient : array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
  mat_specular : array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
  light_position : array [0..3] of GLfloat = (0.0, 0.0, 10.0, 1.0 );
  lm_ambient : array [0..3] of GLfloat = ( 0.2, 0.2, 0.2, 1.0 );

  torus_diffuse : array [0..3] of GLfloat = ( 0.7, 0.7, 0.0, 1.0 );
  cube_diffuse : array [0..3] of GLfloat = ( 0.0, 0.7, 0.7, 1.0 );
  sphere_diffuse : array [0..3] of GLfloat = (0.7, 0.0, 0.7, 1.0 );
  octa_diffuse : array [0..3] of GLfloat = ( 0.7, 0.4, 0.4, 1.0 );

  // Jitter constants
  ACSIZE = 8;

var
  h_Wnd  : HWND;                     // Global window handle
  h_DC   : HDC;                      // Global device context
  h_RC   : HGLRC;                    // OpenGL rendering context
  keys : Array[0..255] of Boolean;   // Holds keystrokes
  FPSCount : Integer = 0;            // Counter for FPS
  ElapsedTime : Integer;             // Elapsed time between frames

  // User Variables

  spin : GLfloat = 0.0;              // Var used for the amount to rotate an object by

  TorusDL : GLuint;                  // For torus DL
  CubeDL : GLuint;                   // For Cube DL
  IcosDL : GLuint;                   // For Icosahedron
  SphereQuadric : GLUquadricObj;     // Quadric for our sphere

   // Mouse
  MouseButton : Integer = -1;         // mouse button down
  Xcoord, Ycoord : Integer;   // Mouse Coordinates




{$R *.RES}

{------------------------------------------------------------------}
{  Function to convert int to string. (No sysutils = smaller EXE)  }
{------------------------------------------------------------------}
function IntToStr(Num : Integer) : String;  // using SysUtils increase file size by 100K
begin
  Str(Num, result);
end;


{------------------------------------------------------------------}
{  Calculate the next rotation value an assign it to spin          }
{------------------------------------------------------------------}
procedure SpinDisplay();
begin
    spin := spin + 2.0;
    if spin > 360.0 then
        spin := spin - 360.0;
end;

{------------------------------------------------------------------}
{  Used for scene jittering and as a replacement for gluPerspective}
{------------------------------------------------------------------}
procedure accFrustum(dleft, dright, dbottom, dtop, dnear, dfar, dpixdx, dpixdy, deyedx, deyedy, dfocus : GLdouble );
var
  xwsize, ywsize :GLdouble;
  dx, dy : GLdouble;
  viewport : array [0..3] of GLint;
begin

    glGetIntegerv(GL_VIEWPORT, @viewport);                         // Get the current viewport

    xwsize := dright - dleft;
    ywsize := dtop - dbottom;
    dx := -(dpixdx * xwsize/viewport[2] + deyedx * dnear/dfocus);
    dy := -(dpixdy * ywsize/viewport[3] + deyedy * dnear/dfocus);

    glMatrixMode(GL_PROJECTION);                                   // Switch the the Projection Matrix
    glLoadIdentity();                                              // Load A new matix onto the stack 
    glFrustum (dleft + dx, dright + dx, dbottom + dy, dtop + dy, dnear, dfar);  // Set the frustrum
    glMatrixMode(GL_MODELVIEW);                                    // Switch to the Modelview matrix
    glLoadIdentity();                                              // Load A new matix onto the stack
    glTranslatef (-deyedx, -deyedy, 0.0);                          // Translate the scene according to the eye coordinates 
end;

{------------------------------------------------------------------}
{  Used for scene jittering and as a replacement for gluPerspective}
{------------------------------------------------------------------}
procedure accPerspective(dfovy, daspect, dnear, dfar, dpixdx, dpixdy, deyedx, deyedy, dfocus : GLdouble);
var
  fov2, left, right, bottom, top : GLdouble;
begin

    fov2 := ((dfovy*PI) / 180.0) / 2.0;

    top := dnear / (ArcCos(fov2) / ArcSin(fov2));
    bottom := -top;
    right := top * daspect;
    left := -right;

    accFrustum (left, right, bottom, top, dnear, dfar,
        dpixdx, dpixdy, deyedx, deyedy, dfocus);        // Setup the accumilation frustrum
end;

{------------------------------------------------------------------}
{  Substitute for auxWireBox (Draws a box with quads)              }
{------------------------------------------------------------------}
procedure DrawBox(Height, Width, Depth : GLfloat);
var HalfHeight, HalfWidth, HalfDepth : GLfloat;
begin

  HalfHeight := Height/2;
  HalfWidth := Width/2;
  HalfDepth := Depth/2;

  glBegin(GL_QUADS);
    // Front Face
    glNormal3f( 0.0, 0.0, 1.0);
    glVertex3f(-HalfWidth, -HalfHeight,  HalfDepth);
    glVertex3f( HalfWidth, -HalfHeight,  HalfDepth);
    glVertex3f( HalfWidth,  HalfHeight,  HalfDepth);
    glVertex3f(-HalfWidth,  HalfHeight,  HalfDepth);
    // Back Face
    glNormal3f( 0.0, 0.0,-1.0);
    glVertex3f(-HalfWidth, -HalfHeight, -HalfDepth);
    glVertex3f(-HalfWidth,  HalfHeight, -HalfDepth);
    glVertex3f( HalfWidth,  HalfHeight, -HalfDepth);
    glVertex3f( HalfWidth, -HalfHeight, -HalfDepth);
    // Top Face
    glNormal3f( 0.0, 1.0, 0.0);
    glVertex3f(-HalfWidth,  HalfHeight, -HalfDepth);
    glVertex3f(-HalfWidth,  HalfHeight,  HalfDepth);
    glVertex3f( HalfWidth,  HalfHeight,  HalfDepth);
    glVertex3f( HalfWidth,  HalfHeight, -HalfDepth);
    // Bottom Face
    glNormal3f( 0.0,-1.0, 0.0);
    glVertex3f(-HalfWidth, -HalfHeight, -HalfDepth);
    glVertex3f( HalfWidth, -HalfHeight, -HalfDepth);
    glVertex3f( HalfWidth, -HalfHeight,  HalfDepth);
    glVertex3f(-HalfWidth, -HalfHeight,  HalfDepth);
    // Right face
    glNormal3f( 1.0, 0.0, 0.0);
    glVertex3f( HalfWidth, -HalfHeight, -HalfDepth);
    glVertex3f( HalfWidth,  HalfHeight, -HalfDepth);
    glVertex3f( HalfWidth,  HalfHeight,  HalfDepth);
    glVertex3f( HalfWidth, -HalfHeight,  HalfDepth);
    // Left Face
    glNormal3f(-1.0, 0.0, 0.0);
    glVertex3f(-HalfWidth, -HalfHeight, -HalfDepth);
    glVertex3f(-HalfWidth, -HalfHeight,  HalfDepth);
    glVertex3f(-HalfWidth,  HalfHeight,  HalfDepth);
    glVertex3f(-HalfWidth,  HalfHeight, -HalfDepth);
  glEnd();
end;

{------------------------------------------------------------------}
{  Create a torus be giving inner, outer radius and detail level   }
{------------------------------------------------------------------}
procedure CreateTorus(TubeRadius, Radius : GLfloat; Sides, Rings : Integer);
var I, J : Integer;
    theta, phi, theta1 : GLfloat;
    cosTheta, sinTheta : GLfloat;
    cosTheta1, sinTheta1 : GLfloat;
    ringDelta, sideDelta : GLfloat;
    cosPhi, sinPhi, dist : GLfloat;
begin
  sideDelta := 2.0 * Pi / Sides;
  ringDelta := 2.0 * Pi / rings;
  theta := 0.0;
  cosTheta := 1.0;
  sinTheta := 0.0;

  TorusDL :=glGenLists(1);
  glNewList(TorusDL, GL_COMPILE);
    for i := rings - 1 downto 0 do
    begin
      theta1 := theta + ringDelta;
      cosTheta1 := cos(theta1);
      sinTheta1 := sin(theta1);
      glBegin(GL_QUAD_STRIP);
        phi := 0.0;
        for j := Sides downto 0 do
        begin
          phi := phi + sideDelta;
          cosPhi := cos(phi);
          sinPhi := sin(phi);
          dist := Radius + (TubeRadius * cosPhi);

          glNormal3f(cosTheta1 * cosPhi, -sinTheta1 * cosPhi, sinPhi);
          glVertex3f(cosTheta1 * dist, -sinTheta1 * dist, TubeRadius * sinPhi);

          glNormal3f(cosTheta * cosPhi, -sinTheta * cosPhi, sinPhi);
          glVertex3f(cosTheta * dist, -sinTheta * dist, TubeRadius * sinPhi);
        end;
      glEnd();
      theta := theta1;
      cosTheta := cosTheta1;
      sinTheta := sinTheta1;
    end;
  glEndList();
end;

{------------------------------------------------------------------}
{  Create an Icosahedron in a Display list                         }
{------------------------------------------------------------------}
procedure CreateIcosahedron();
var i :GLint;
begin
  IcosDL :=glGenLists(1);
  glNewList(IcosDL, GL_COMPILE);
    for i := 0 to 19 do
    begin
        glBegin(GL_TRIANGLES);
          glNormal3fv(@vdata[tindices[i][0]][0]);
          glVertex3fv(@vdata[tindices[i][0]][0]);
          glNormal3fv(@vdata[tindices[i][1]][0]);
          glVertex3fv(@vdata[tindices[i][1]][0]);
          glNormal3fv(@vdata[tindices[i][2]][0]);
          glVertex3fv(@vdata[tindices[i][2]][0]);
      glEnd();
    end;
  glEndList;
end;

{------------------------------------------------------------------}
{  Draw all the objects in the scene                               }
{------------------------------------------------------------------}
procedure DrawObjects();
begin
  glPushMatrix ();                                           // Load a new matrix onto the stack
    glTranslatef (0.0, 0.0, -5.0);                           // Maove the scene back 5 units
    glRotatef (30.0, 1.0, 0.0, 0.0);                         // Rotate the scene 30 degrees on the x-axis

    glPushMatrix ();                                         // Load a new matrix onto the stack
      glTranslatef (-0.80, 0.35, 0.0);                       // Move the scene
      glRotatef (100.0, 1.0, 0.0, 0.0);                      // Rotate 100 degrees on the x-axis
      glMaterialfv(GL_FRONT, GL_DIFFUSE, @torus_diffuse);    // Set the Torus material
      glCallList(TorusDL);                                   // Draw the Torus
    glPopMatrix ();                                          // Restore the last saved matrix

   glPushMatrix ();                                          // Load a new matrix onto the stack
      glTranslatef (-0.75, -0.50, 0.0);                      // Move the scene
      glRotatef (45.0, 0.0, 0.0, 1.0);                       // Rotate 45 degrees on the z-axis
      glRotatef (45.0, 1.0, 0.0, 0.0);                       // Rotate 45 degrees on the x-axis
      glMaterialfv(GL_FRONT, GL_DIFFUSE, @cube_diffuse);     // Set the Cube material
      glCallList(CubeDL);                                    // Draw the cube
    glPopMatrix ();                                          // Restore the last saved matrix

    glPushMatrix ();                                         // Load a new matrix onto the stack
      glTranslatef (0.75, 0.60, 0.0);                        // Move the scene
      glRotatef (30.0, 1.0, 0.0, 0.0);                       // Rotate 30 degrees on the x-axis
      glMaterialfv(GL_FRONT, GL_DIFFUSE, @sphere_diffuse);   // Set the Sphere material
      gluSphere(SphereQuadric,1.0,32,32);                    // Draw the sphere
    glPopMatrix ();                                          // Restore the last saved matrix

    glPushMatrix ();                                         // Load a new matrix onto the stack
      glTranslatef (0.70, -0.90, 0.25);                      // Move the scene
      glMaterialfv(GL_FRONT, GL_DIFFUSE, @octa_diffuse);     // Set the Icosahedron material
      glCallList(IcosDL);                                    // Draw the Icosahedron
    glPopMatrix ();                                          // Restore the last saved matrix

  glPopMatrix ();                                            // Restore the matrix we saved initially
end;

{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}
procedure glDraw();
var
  viewport : array [0..3] of GLint;
  jitter : GLint;
begin


    glGetIntegerv (GL_VIEWPORT, @viewport);                  // Get the current Viewport

    glClear(GL_ACCUM_BUFFER_BIT);                            // Clear the Accumulation Buffer
    for jitter := 0 to ACSIZE -1 do
    begin
        glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // Clear the Colour and Depth Buffer
        accPerspective (50.0,
            viewport[2]/viewport[3],
            1.0, 15.0, j8[jitter].x, j8[jitter].y,
            0.0, 0.0, 1.0);
        DrawObjects ();                                      // Set the accumulation Perspective
        glAccum(GL_ACCUM, 1.0/ACSIZE);                       // Accumilate the scene
    end;
    glAccum (GL_RETURN, 1.0);                                // Return the accumulated scene to the Colour buffer

    glFlush();              // ( Force the buffer to draw or send a network packet of commands in a networked system)

end;


{------------------------------------------------------------------}
{  Initialise OpenGL                                               }
{------------------------------------------------------------------}
procedure glInit();
begin
  glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient);     // Set the Ambient Material
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);   // Set the Specular Material
  glMaterialf(GL_FRONT, GL_SHININESS, 50.0);            // Set the Material Shininess
  glLightfv(GL_LIGHT0, GL_POSITION, @light_position);   // Set the Light Position
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @lm_ambient);  // Set the Light Ambient Value 

  glEnable(GL_LIGHTING);                                // Enable Lighting
  glEnable(GL_LIGHT0);                                  // Enable Light 0
  glDepthFunc(GL_LEQUAL);                               // Set the Depth Funtion To Linear Equal
  glEnable(GL_DEPTH_TEST);                              // Enable Depth Testing (Hidden Surface Removal)
  glShadeModel (GL_FLAT);                               // Use Flat Shading
  glClearColor(0.0, 0.0, 0.0, 0.0);                     // Initialize the Colour buffer to black
  glClearAccum(0.0, 0.0, 0.0, 0.0);                     // Initialize the Accumulation buffer to black

  CreateTorus( 0.275, 0.85, 10, 20);                    // Create a Torus

  CubeDL := glGenLists(1);                              // Create a Cube
  glNewList(CubeDL, GL_COMPILE);
    DrawBox(1.5,1.5,1.5);
  glEndList;

  SphereQuadric := gluNewQuadric();		                 // Create A Pointer To The Quadric Object (Return 0 If No Memory) (NEW)
  gluQuadricNormals(SphereQuadric, GLU_SMOOTH);	       // Create Smooth Normals (NEW)

  CreateIcosahedron();                                 // Create an Icosahedron
end;


{------------------------------------------------------------------}
{  Handle window resize                                            }
{------------------------------------------------------------------}
procedure glResizeWnd(Width, Height : Integer);
begin
  glViewport(0, 0, Width, Height);        // Set the Viewport to the size of the sceen
end;

{------------------------------------------------------------------}
{  Processes all the mouse clicks                                  }
{------------------------------------------------------------------}
procedure ProcessMouse;
begin
  case MouseButton of
  1: // Left Mouse Button
    begin
      MouseButton := 0; // Cancel our mouse click (To use this procedure as a mouse down event remove this line)
    end;
  2: // Right Mouse Button
    begin
      MouseButton := 0; // Cancel our mouse click (To use this procedure as a mouse down event remove this line)
    end;
  3: // Middle Mouse Button
    begin
      MouseButton := 0; // Cancel our mouse click (To use this procedure as a mouse down event remove this line)
    end;
  end;
end;

{------------------------------------------------------------------}
{  Processes all the keystrokes                                    }
{------------------------------------------------------------------}
procedure ProcessKeys;
begin
  // Reserved for future use
end;


{------------------------------------------------------------------}
{  Determines the application’s response to the messages received  }
{------------------------------------------------------------------}
function WndProc(hWnd: HWND; Msg: UINT;  wParam: WPARAM;  lParam: LPARAM): LRESULT; stdcall;
begin
  case (Msg) of
    WM_CREATE:
      begin
        // Insert stuff you want executed when the program starts
      end;
    WM_CLOSE:
      begin
        PostQuitMessage(0);
        Result := 0
      end;
    WM_KEYDOWN:       // Set the pressed key (wparam) to equal true so we can check if its pressed
      begin
        keys[wParam] := True;
        Result := 0;
      end;
    WM_KEYUP:         // Set the released key (wparam) to equal false so we can check if its pressed
      begin
        keys[wParam] := False;
        Result := 0;
      end;
    WM_LBUTTONDOWN:
      begin
        ReleaseCapture();   // need them here, because if mouse moves off
        SetCapture(h_Wnd);  // window and returns, it needs to reset status
        MouseButton := 1;
        Xcoord := LOWORD(lParam);
        Ycoord := HIWORD(lParam);
        Result := 0;
      end;
    WM_LBUTTONUP:
      begin
        ReleaseCapture();   // above
        MouseButton := 0;
        XCoord := 0;
        YCoord := 0;
        Result := 0;
      end;
    WM_SIZE:          // Resize the window with the new width and height
      begin
        glResizeWnd(LOWORD(lParam),HIWORD(lParam));
        Result := 0;
      end;
    WM_TIMER :                     // Add code here for all timers to be used.
      begin
        if wParam = FPS_TIMER then
        begin
          FPSCount :=Round(FPSCount * 1000/FPS_INTERVAL);   // calculate to get per Second incase intercal is less or greater than 1 second
          SetWindowText(h_Wnd, PChar(WND_TITLE + '   [' + intToStr(FPSCount) + ' FPS]'));
          FPSCount := 0;
          Result := 0;
        end;
      end;
    else
      Result := DefWindowProc(hWnd, Msg, wParam, lParam);    // Default result if nothing happens
  end;
end;


{---------------------------------------------------------------------}
{  Properly destroys the window created at startup (no memory leaks)  }
{---------------------------------------------------------------------}
procedure glKillWnd(Fullscreen : Boolean);
begin
  if Fullscreen then             // Change back to non fullscreen
  begin
    ChangeDisplaySettings(devmode(nil^), 0);
    ShowCursor(True);
  end;

  // Makes current rendering context not current, and releases the device
  // context that is used by the rendering context.
  if (not wglMakeCurrent(h_DC, 0)) then
    MessageBox(0, 'Release of DC and RC failed!', 'Error', MB_OK or MB_ICONERROR);

  // Attempts to delete the rendering context
  if (not wglDeleteContext(h_RC)) then
  begin
    MessageBox(0, 'Release of rendering context failed!', 'Error', MB_OK or MB_ICONERROR);
    h_RC := 0;
  end;

  // Attemps to release the device context
  if ((h_DC > 0) and (ReleaseDC(h_Wnd, h_DC) = 0)) then
  begin
    MessageBox(0, 'Release of device context failed!', 'Error', MB_OK or MB_ICONERROR);
    h_DC := 0;
  end;

  // Attempts to destroy the window
  if ((h_Wnd <> 0) and (not DestroyWindow(h_Wnd))) then
  begin
    MessageBox(0, 'Unable to destroy window!', 'Error', MB_OK or MB_ICONERROR);
    h_Wnd := 0;
  end;

  // Attempts to unregister the window class
  if (not UnRegisterClass('OpenGL', hInstance)) then
  begin
    MessageBox(0, 'Unable to unregister window class!', 'Error', MB_OK or MB_ICONERROR);
    hInstance := 0;
  end;
end;


{--------------------------------------------------------------------}
{  Creates the window and attaches a OpenGL rendering context to it  }
{--------------------------------------------------------------------}
function glCreateWnd(Width, Height : Integer; Fullscreen : Boolean; PixelDepth : Integer) : Boolean;
var
  wndClass : TWndClass;         // Window class
  dwStyle : DWORD;              // Window styles
  dwExStyle : DWORD;            // Extended window styles
  dmScreenSettings : DEVMODE;   // Screen settings (fullscreen, etc...)
  PixelFormat : GLuint;         // Settings for the OpenGL rendering
  h_Instance : HINST;           // Current instance
  pfd : TPIXELFORMATDESCRIPTOR;  // Settings for the OpenGL window
begin
  h_Instance := GetModuleHandle(nil);       //Grab An Instance For Our Window
  ZeroMemory(@wndClass, SizeOf(wndClass));  // Clear the window class structure

  with wndClass do                    // Set up the window class
  begin
    style         := CS_HREDRAW or    // Redraws entire window if length changes
                     CS_VREDRAW or    // Redraws entire window if height changes
                     CS_OWNDC;        // Unique device context for the window
    lpfnWndProc   := @WndProc;        // Set the window procedure to our func WndProc
    hInstance     := h_Instance;
    hCursor       := LoadCursor(0, IDC_ARROW);
    lpszClassName := 'OpenGL';
  end;

  if (RegisterClass(wndClass) = 0) then  // Attemp to register the window class
  begin
    MessageBox(0, 'Failed to register the window class!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit
  end;

  // Change to fullscreen if so desired
  if Fullscreen then
  begin
    ZeroMemory(@dmScreenSettings, SizeOf(dmScreenSettings));
    with dmScreenSettings do begin              // Set parameters for the screen setting
      dmSize       := SizeOf(dmScreenSettings);
      dmPelsWidth  := Width;                    // Window width
      dmPelsHeight := Height;                   // Window height
      dmBitsPerPel := PixelDepth;               // Window color depth
      dmFields     := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
    end;

    // Try to change screen mode to fullscreen
    if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_FAILED) then
    begin
      MessageBox(0, 'Unable to switch to fullscreen!', 'Error', MB_OK or MB_ICONERROR);
      Fullscreen := False;
    end;
  end;

  // If we are still in fullscreen then
  if (Fullscreen) then
  begin
    dwStyle := WS_POPUP or                // Creates a popup window
               WS_CLIPCHILDREN            // Doesn't draw within child windows
               or WS_CLIPSIBLINGS;        // Doesn't draw within sibling windows
    dwExStyle := WS_EX_APPWINDOW;         // Top level window
    ShowCursor(False);                    // Turn of the cursor (gets in the way)
  end
  else
  begin
    dwStyle := WS_OVERLAPPEDWINDOW or     // Creates an overlapping window
               WS_CLIPCHILDREN or         // Doesn't draw within child windows
               WS_CLIPSIBLINGS;           // Doesn't draw within sibling windows
    dwExStyle := WS_EX_APPWINDOW or       // Top level window
                 WS_EX_WINDOWEDGE;        // Border with a raised edge
  end;

  // Attempt to create the actual window
  h_Wnd := CreateWindowEx(dwExStyle,      // Extended window styles
                          'OpenGL',       // Class name
                          WND_TITLE,      // Window title (caption)
                          dwStyle,        // Window styles
                          0, 0,           // Window position
                          Width, Height,  // Size of window
                          0,              // No parent window
                          0,              // No menu
                          h_Instance,     // Instance
                          nil);           // Pass nothing to WM_CREATE
  if h_Wnd = 0 then
  begin
    glKillWnd(Fullscreen);                // Undo all the settings we've changed
    MessageBox(0, 'Unable to create window!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Try to get a device context
  h_DC := GetDC(h_Wnd);
  if (h_DC = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to get a device context!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Settings for the OpenGL window
  with pfd do
  begin
    nSize           := SizeOf(TPIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
    nVersion        := 1;                    // The version of this data structure
    dwFlags         := PFD_DRAW_TO_WINDOW    // Buffer supports drawing to window
                       or PFD_SUPPORT_OPENGL // Buffer supports OpenGL drawing
                       or PFD_DOUBLEBUFFER;  // Supports double buffering
    iPixelType      := PFD_TYPE_RGBA;        // RGBA color format
    cColorBits      := PixelDepth;           // OpenGL color depth
    cRedBits        := 0;                    // Number of red bitplanes
    cRedShift       := 0;                    // Shift count for red bitplanes
    cGreenBits      := 0;                    // Number of green bitplanes
    cGreenShift     := 0;                    // Shift count for green bitplanes
    cBlueBits       := 0;                    // Number of blue bitplanes
    cBlueShift      := 0;                    // Shift count for blue bitplanes
    cAlphaBits      := 0;                    // Not supported
    cAlphaShift     := 0;                    // Not supported
    cAccumBits      := 3;                    // Accumulation buffer
    cAccumRedBits   := 1;                    // Number of red bits in a-buffer
    cAccumGreenBits := 1;                    // Number of green bits in a-buffer
    cAccumBlueBits  := 1;                    // Number of blue bits in a-buffer
    cAccumAlphaBits := 0;                    // Number of alpha bits in a-buffer
    cDepthBits      := 16;                   // Specifies the depth of the depth buffer
    cStencilBits    := 0;                    // Turn off stencil buffer
    cAuxBuffers     := 0;                    // Not supported
    iLayerType      := PFD_MAIN_PLANE;       // Ignored
    bReserved       := 0;                    // Number of overlay and underlay planes
    dwLayerMask     := 0;                    // Ignored
    dwVisibleMask   := 0;                    // Transparent color of underlay plane
    dwDamageMask    := 0;                     // Ignored
  end;

  // Attempts to find the pixel format supported by a device context that is the best match to a given pixel format specification.
  PixelFormat := ChoosePixelFormat(h_DC, @pfd);
  if (PixelFormat = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to find a suitable pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Sets the specified device context's pixel format to the format specified by the PixelFormat.
  if (not SetPixelFormat(h_DC, PixelFormat, @pfd)) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to set the pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Create a OpenGL rendering context
  h_RC := wglCreateContext(h_DC);
  if (h_RC = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to create an OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Makes the specified OpenGL rendering context the calling thread's current rendering context
  if (not wglMakeCurrent(h_DC, h_RC)) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to activate OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Initializes the timer used to calculate the FPS
  SetTimer(h_Wnd, FPS_TIMER, FPS_INTERVAL, nil);

  // Settings to ensure that the window is the topmost window
  ShowWindow(h_Wnd, SW_SHOW);
  SetForegroundWindow(h_Wnd);
  SetFocus(h_Wnd);

  // Ensure the OpenGL window is resized properly
  glResizeWnd(Width, Height);
  glInit(); // Initialise any OpenGL States and variables 

  Result := True;
end;


{--------------------------------------------------------------------}
{  Main message loop for the application                             }
{--------------------------------------------------------------------}
function WinMain(hInstance : HINST; hPrevInstance : HINST;
                 lpCmdLine : PChar; nCmdShow : Integer) : Integer; stdcall;
var
  msg : TMsg;
  finished : Boolean;
  DemoStart, LastTime : DWord;
begin
  finished := False;

  // Perform application initialization:
  if not glCreateWnd(250, 250, FALSE, 32) then
  begin
    Result := 0;
    Exit;
  end;

  DemoStart := GetTickCount();            // Get Time when demo started

  // Main message loop:
  while not finished do
  begin
    if (PeekMessage(msg, 0, 0, 0, PM_REMOVE)) then // Check if there is a message for this window
    begin
      if (msg.message = WM_QUIT) then     // If WM_QUIT message received then we are done
        finished := True
      else
      begin                               // Else translate and dispatch the message to this window
  	TranslateMessage(msg);
        DispatchMessage(msg);
      end;
    end
    else
    begin
      Inc(FPSCount);                      // Increment FPS Counter

      LastTime :=ElapsedTime;
      ElapsedTime :=GetTickCount() - DemoStart;     // Calculate Elapsed Time
      ElapsedTime :=(LastTime + ElapsedTime) DIV 2; // Average it out for smoother movement

      glDraw();                           // Draw the scene ( Call any OpenGL Rendering code in this function)
      SwapBuffers(h_DC);                  // Display the scene

      if (keys[VK_ESCAPE]) then           // If user pressed ESC then set finised TRUE
        finished := True
      else
        ProcessKeys;                      // Check for any other key Pressed
        ProcessMouse;                     // Check for mouse clicks
    end;
  end;
  glKillWnd(FALSE);
  Result := msg.wParam;
end;


begin
  WinMain( hInstance, hPrevInst, CmdLine, CmdShow );
end.
