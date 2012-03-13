unit UMouseGL;

interface

uses
  dglOpenGL, Textures, UObjects, Geometry;

type
  TMouseGL = class
  private
    fX, fY: Real;
    pos, size: TVertex;
    frame0, frame1: TVertex;  // frame0 left bottm     frame1 right top
    TexId: gluInt;
    procedure DrawFrame;
  public
    LeftPressed: Boolean;
    constructor create(p, s, f0, f1: TVertex; cWidth, cHeight: Integer);
    procedure Draw;
    procedure MoveTo(x, y: Real);
    procedure MoveTotal(x, y, z: Real);
    procedure ChangeWindowSize(cWidth, cHeight: Integer);
    function GetPosGL: TVertex;
  end;

implementation

constructor TMouseGL.create(p, s, f0, f1: TVertex; cWidth, cHeight: Integer);
begin
  LeftPressed := false;
  pos := p;
  size := s;
  frame0 := f0;
  frame1 := f1;
  fX := (frame1[0] - frame0[0]) / cWidth;
  fY := (frame1[1] - frame0[1]) / cHeight;
  LoadTexture('mouse.tga', TexId, false);
end;

procedure TMouseGL.MoveTotal(x, y, z: Real);
begin
  pos[0] := x;
  pos[1] := y;
  pos[2] := z;
end;

procedure TMouseGL.MoveTo(x, y: Real);
begin
  pos[0] := frame0[0] + (x * fX);
  pos[1] := frame1[1] - (y * fY);
end;

procedure TMouseGL.Draw;
begin
  DrawFrame;

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 0.1);

  glBindTexture(GL_TEXTURE_2D, TexId);
    DrawQuadEasyTex(pos, size);

  glDisable(GL_ALPHA_TEST);
  glDisable(GL_BLEND);
end;

procedure TMouseGL.DrawFrame;
var tl, br: TVertex;
begin
  tl := frame0;
  tl[1] := frame1[1];

  br := frame1;
  br[1] := frame0[1];

  DrawLine(frame0, tl);
  DrawLine(tl, frame1);
  DrawLine(frame1, br);
  DrawLine(br, frame0);
end;

procedure TMouseGL.ChangeWindowSize(cWidth, cHeight: Integer);
begin
  fX := (frame1[0] - frame0[0]) / cWidth;
  fY := (frame1[1] - frame0[1]) / cHeight;
end;

function TMouseGL.GetPosGL: TVertex;
begin
  result := pos;
  result[1] := pos[1] + size[1];
end;

end.
 