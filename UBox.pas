unit UBox;

interface

uses
  UMovingObjects, Chipmunk, Textures, Geometry, UObjects, dglOpenGL,
  dialogs, sysutils, UOwner;

type
  TBox = class(TMovingObject)
  private
    width, height: Real;
    // Texture stretching factors (more in UObjects)
    xFac, yFac: Real;
  public
    constructor create(space: PcpSpace; pos: cpVect; width, height, mass: Real;
                        texName: string; isstatic: Boolean;
                        data: Pointer; owner: TOwner);
    procedure Draw; override;
    procedure SetTexFac(xF, yF: Real);
  end;

implementation

constructor TBox.Create(space: PcpSpace; pos: cpVect; width, height, mass: Real;
                              texName: string; isstatic: Boolean;
                              data: Pointer; owner: TOwner);
var moment, mymass: cpFloat;
begin

// if box should be static the body has mass and moment = INFINITY
// and the body is not added to space
If isstatic then body := cpBodyNew(INFINITY, INFINITY)
  else begin
    moment := cpMomentForBox(mass, width, height);
    body := cpSpaceAddBody(space, cpBodyNew(mass, moment) );
    end;

body.p := pos;
body.data := owner;

shape := cpSpaceAddShape(space, cpBoxShapeNew(body, width, height));
shape.u := 0.7;
shape.e := 0.1;

shape.collision_type := 0;
shape.data := data;

self.width := width;
self.height := height;
self.static := isstatic;
LoadTexture(texName, texId, false);

SetTexFac(INFINITY, INFINITY);
end;

procedure TBox.Draw;
var pos, size: TVertex;
begin
  pos[0] := body.p.x;
  pos[1] := body.p.y;
  pos[2] := 0;

  size[0] := width;
  size[1] := height;
  size[2] := 0;

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 0.1);

  glPushMatrix;
    glTranslatef(pos[0], pos[1], 0);
    glRotatef( radtodeg(body.a), 0, 0, 1);
    glBindTexture(GL_TEXTURE_2D, texId);
      pos[0] := -size[0] /2; pos[1] := -size[1] / 2; pos[2] := 0;
      DrawQuad(Pos, Size, xFac, yFac);
  glPopMatrix;

  glDisable(GL_ALPHA_TEST);
  glDisable(GL_BLEND);
end;

procedure TBox.SetTexFac(xF, yF: Real);
begin
  If xF = INFINITY then xFac := width
    else xFac := xF;
  If yF = INFINITY then yFac := height
    else yFac := yF;
end;

end.
 