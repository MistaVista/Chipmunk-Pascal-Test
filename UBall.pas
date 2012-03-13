unit UBall;

interface

uses
  UMovingObjects, Chipmunk, Textures, Geometry, UObjects, dglOpenGL, dialogs,
  sysutils, UOwner;

type
  TBall = class(TMovingObject)
  private
    radius: Real;
  public
    constructor create(space: PcpSpace; pos: cpVect; radius, mass: Real;
                        texName: string; isstatic: Boolean;
                        data: Pointer; owner: TOwner);
    procedure Draw; override;
  end;

implementation

constructor TBall.Create(space: PcpSpace; pos: cpVect; radius, mass: Real;
                              texName: string; isstatic: Boolean;
                              data: Pointer; owner: TOwner);
var moment, mymass: cpFloat;
begin

// if ball should be static the body has mass and moment = INFINITY
// and the body is not added to space
If isstatic then body := cpBodyNew(INFINITY, INFINITY)
  else begin
    moment := cpMomentForCircle(mass, radius, 0, cpvzero );
    body := cpSpaceAddBody(space, cpBodyNew(mass, moment) );
    end;

body.p := pos;
body.data := owner;

shape := cpSpaceAddShape(space, cpCircleShapeNew(body, radius, cpvzero));
shape.u := 0.7;
shape.e := 0.5;

shape.collision_type := 0;
shape.data := data;

self.radius := radius;
LoadTexture(texName, texId, false);
end;

procedure TBall.Draw;
var pos, size: TVertex;
begin
  pos[0] := body.p.x;
  pos[1] := body.p.y;
  pos[2] := 0;

  size[0] := radius * 2;
  size[1] := radius * 2;
  size[2] := 0;

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 0.1);

  glPushMatrix;
    glTranslatef(pos[0], pos[1], 0);
    glRotatef( radtodeg(body.a), 0, 0, 1);
      glBindTexture(GL_TEXTURE_2D, TexId);
      pos[0] := -size[0] /2; pos[1] := -size[1] / 2; pos[2] := 0;
      DrawQuadEasyTex(Pos, Size);
  glPopMatrix;

  glDisable(GL_ALPHA_TEST);
  glDisable(GL_BLEND);
end;

end.
