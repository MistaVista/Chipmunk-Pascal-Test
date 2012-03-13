unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dglOpenGL, ExtCtrls, StdCtrls, UPhysics, Geometry, UMouseGL,
  Chipmunk;

const
  NearClipping = 1;
  FarClipping  = 1000;

type
  T3D_Point = array[0..2] of double;
  P3d = record
    x: Real;
    y: Real;
    z: Real;
    end;
  TForm1 = class(TForm)
    MemoInfo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  procedure IdleHandler(Sender: TObject; var Done: Boolean);
    procedure MemoInfoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MemoInfoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    myMouse: TMouseGL;
    StartTime, TimeCount, FrameCount: Cardinal; //FrameCounter
    Frames, DrawTime: Cardinal;                 //& Timebased Movement
    TexId: Integer;
    CamPos: P3d;
    alpha: Real;
    myPhys: TPhysics;
    ActiveBlock: Integer;
    procedure SetupGL;
    procedure Init;
    procedure ErrorHandler;
    procedure Render;
    function GetOGLPos(X, Y: Integer): T3D_Point;
  public
    DC: HDC;    //Handle auf Zeichenfläche
    RC: HGLRC;  //Rendering Context
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  DC:= GetDC(Handle);
  if not InitOpenGL then Application.Terminate;
  RC:= CreateRenderingContext( DC,
                               [opDoubleBuffered],
                               32,
                               24,
                               0,0,0,
                               0);
  ActivateRenderingContext(DC, RC);
  SetupGL;
  Init;
  Application.OnIdle := IdleHandler;
end;

procedure TForm1.SetupGL;
begin
  glClearColor(0.1, 0.1, 0.1, 1); //Hintergrundfarbe
  glEnable(GL_DEPTH_TEST);        //Tiefentest aktivieren
  glEnable(GL_CULL_FACE);       //Backface Culling aktivieren
  glEnable(GL_TEXTURE_2D);
end;

procedure TForm1.Init;
var i: integer;
    p, s, f0, f1: TVertex;
begin
  Randomize;

  // Init MouseGL Object
  Windows.ShowCursor(false);

  // Set initpos and size
  p[0] := 0; p[1] := 0; p[2] := 0;
  s[0] := 2; s[1] := 2; s[2] := 0.1;

  // Set frame
  f0[0] := -80; f0[1] := 0; f0[2] := 0;
  f1[0] := 80; f1[1] := 120; f1[2] := 0;
  myMouse := TMouseGL.create(p, s, f0, f1, ClientWidth, ClientHeight);

  myPhys := TPhysics.create(MemoInfo);
  CamPos.x := 0; CamPos.y := -59; CamPos.z := -150;
  alpha := 0;
  If fileexists('info.nfo') then MemoInfo.Lines.LoadFromFile('info.nfo');
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(45.0, ClientWidth/ClientHeight, NearClipping, FarClipping);    
 
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  myMouse.Free;
  myPhys.Free;
  DeactivateRenderingContext;
  DestroyRenderingContext(RC);
  ReleaseDC(Handle, DC);
end;

procedure TForm1.Render;
var r,g,b: Real; i: integer;
    p: TVertex;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(45.0, ClientWidth/ClientHeight, NearClipping, FarClipping);

  glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;
    glTranslatef(CamPos.X, CamPos.Y, CamPos.Z);
    glRotatef(alpha,0,1,0);

  // Put yor Render Functions here
  if myMouse.LeftPressed then begin
    p := myMouse.GetPosGL;
    myPhys.MoveBlock(ActiveBlock, p[0], p[1]);
    end;

  myPhys.Draw;
  myMouse.Draw;

  SwapBuffers(DC);
end;

procedure TForm1.IdleHandler(Sender: TObject; var Done: Boolean);
begin
  StartTime:= GetTickCount;
  Render;
  DrawTime:= GetTickCount - StartTime;
  Inc(TimeCount, DrawTime);
  Inc(FrameCount);
 
  if TimeCount >= 1000 then begin
    Frames:= FrameCount;
    TimeCount:= TimeCount - 1000;
    FrameCount:= 0;
    Form1.Caption:= InttoStr(Frames) + 'FPS';
    ErrorHandler;
    end;

  Done:= false;
  sleep(10);
end;

procedure TForm1.ErrorHandler;
var s: string;
begin
  s := '|   CamPosition:    X = ' + FloatToStr(Campos.X)
        + '   Y = ' + FloatToStr(Campos.y)
        + '   Z = ' + FloatToStr(Campos.z)
        + '   Alpha = ' + FloatToStr(alpha);

  Form1.Caption := Form1.Caption + ' ' + gluErrorString(glGetError) + s;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var p: TVertex;
    x, y: Integer;
begin
  myPhys.KeyDown(key);
  case key of
    //37: if myMouse.LeftPressed then myPhys.TurnBlock(ActiveBlock, 0.1);  // ARROW_LEFT
    //39: if myMouse.LeftPressed then myPhys.TurnBlock(ActiveBlock, -0.1);   // ARROW_RIGHT
    67: begin                           // C
          p := myMouse.GetPosGL;
          x := Random(10) + 5;
          y := Random(10) + 5;
          myPhys.AddCannon( cpv(p[0],p[1]) );
          //myPhys.AddBlock( cpv(p[0],p[1]), x, y, x*y*x*y, 'block.jpg', false, nil);
        end;
    86: begin                           // V
          p := myMouse.GetPosGL;
          x := Random(10) + 5;
          y := Random(10) + 5;
          //myPhys.AddPoly( cpv(p[0],p[1]) );
          //myPhys.AddBlock( cpv(p[0],p[1]), x, y, x*y, 'woodblock.jpg', false, nil);
        end;
    66: begin                         // B
          p := myMouse.GetPosGL;
          myPhys.AddBall( cpv(p[0],p[1]), 2, 16, 'ball.tga', false, nil);
        end;
    27: Close;                        // ESC
    65: CamPos.X := CamPos.X + 0.05;  // A
    68: CamPos.X := CamPos.X - 0.05;  // D
    87: CamPos.Y := CamPos.Y - 0.05;  // W
    83: CamPos.Y := CamPos.Y + 0.05;  // S
    //38: CamPos.Z := CamPos.Z + 1;     // ARROW_UP
    //40: CamPos.Z := CamPos.Z - 1;     // ARROW_DOWN
    81: alpha := alpha + 1;           // Q
    69: alpha := alpha - 1;           // E
    112: If MemoInfo.Visible then     // F1
              MemoInfo.Visible := false
                else MemoInfo.Visible := true;
    116:  Align := alClient;          // F5
    end;
end;

procedure TForm1.MemoInfoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Form1.KeyDown(Key,Shift);
end;

procedure TForm1.MemoInfoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Form1.KeyUp(Key,Shift);
end;

function TForm1.GetOGLPos(X, Y: Integer): T3D_Point;
var Viewport: TGLVectori4;
    Modelview, Projection: TGLMatrixd4;
    Z: TGLFloat;
    Y_new: Integer;
begin
  glGetDoublev(GL_MODELVIEW_MATRIX, @modelview );       //Aktuelle Modelview Matrix in einer Variable ablegen
  glGetDoublev(GL_PROJECTION_MATRIX, @projection );     //Aktuelle Projection[s] Matrix in einer Variable ablegen
  glGetIntegerv(GL_VIEWPORT, @viewport );               // Aktuellen Viewport in einer Variable ablegen
  Y_new := viewport[3] - y;                             // In OpenGL steigt Y von unten (0) nach oben
 
  // Auslesen des Tiefenpuffers an der Position (X/Y_new)
  glReadPixels(X, Y_new, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, @Z );
 
  // Errechnen des Punktes, welcher mit den beiden Matrizen multipliziert (X/Y_new/Z) ergibt:
  gluUnProject(X, Y_new, Z, modelview, projection, viewport, @Result[0], @Result[1], @Result[2]);
end;


procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  myMouse.MoveTo(x, y);
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var p: TVertex;
begin
  p := myMouse.GetPosGL;
  ActiveBlock := myPhys.GetBlockByClick(p[0], p[1]);
  if ActiveBlock > -1 then begin
    myPhys.BlockSleep(ActiveBlock);
    myMouse.LeftPressed := true;
    end;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  myMouse.LeftPressed := false;
  if ActiveBlock > -1 then myPhys.BlockWake(ActiveBlock);
end;

procedure TForm1.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
if myMouse.LeftPressed then begin
  myPhys.TurnBlock(ActiveBlock, WheelDelta / 1000);
  Handled := true;
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  myPhys.KeyUp(key);
end;

end.

