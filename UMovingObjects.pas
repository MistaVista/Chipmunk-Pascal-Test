unit UMovingObjects;

interface

uses
  Chipmunk, dglOpenGL, UOwner;

type
  TMovingObject = class(TOwner)
  protected
    TexId: gluInt;
    static, visible: Boolean;
    shape: PcpShape;
    body: PcpBody;
    mySpace: PcpSpace;
  public
    procedure Draw; virtual; abstract;
    procedure Move(x,y: Real);
    procedure Turn(a: Real);
    procedure Kill; virtual; abstract;
    function Sleep: boolean;
    function Activate: boolean;
    function GetSpace: PcpSpace;

    // Getter and Setter
    function GetShape: PcpShape;
    function GetBody: PcpBody;
    function IsStatic: Boolean;
    procedure SetGroup(grp: Integer);
    procedure SetVisible(vis: boolean);
  end;

implementation

function TMovingObject.GetSpace: PcpSpace;
begin
  result := mySpace;
end;

procedure TMovingObject.Move(x, y: Real);
begin
  if not static then begin
    body.p.x := x;
    body.p.y := y;
    body.v.x := 0;
    body.v.y := 0;
    end;
end;

procedure TMovingObject.Turn(a: Real);
begin
  body.a := body.a + a;
  If static then cpBodySetAngle(body, body.a);
end;

function TMovingObject.Sleep: Boolean;
begin
  If static then result := false
    else begin
      cpBodySleep(body);
      result := true;
      end;
end;

function TMovingObject.Activate: Boolean;
begin
  If static then result := false
    else begin
      cpBodyActivate(body);
      result := true;
      end;
end;

// Getter and Setter

function TMovingObject.GetShape: PcpShape;
begin
  result := shape;
end;

function TMovingObject.GetBody: PcpBody;
begin
  result := body;
end;

function TMovingObject.IsStatic: Boolean;
begin
  result := static;
end;

procedure TMovingObject.SetGroup(grp: Integer);
begin
  shape.group := grp;
end;

procedure TMovingObject.SetVisible(vis: boolean);
begin
  visible := vis;
end;

end.
 