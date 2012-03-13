unit UPoly;

interface

uses
  UMovingObjects, Chipmunk, Textures, UObjects, Geometry, dglOpenGL, myLib, dialogs,
  UOwner;

type
  TPoly = class(TMovingObject)
  private
    drawit: Boolean;
    space: PcpSpace;
    PolyPoints: cpVectArray;
  public
    constructor Create;
    procedure AddPolyPoint(p: cpVect);
    procedure AddPolyArray(num: Integer; a: cpVectArray);
    procedure CreateShapeAndBody(space: PcpSpace; pos: cpVect; mass: Real;
                              texName: string; isstatic: Boolean;
                              data: Pointer; owner: TOwner);
    procedure Draw; override;
  end;

implementation

constructor TPoly.Create;
begin
setlength(PolyPoints, 0);

drawit := false;
end;

procedure TPoly.AddPolyPoint(p: cpVect);
begin
  setlength( PolyPoints, length(PolyPoints)+1 );
  PolyPoints[ length(PolyPoints)-1 ] := p;
end;

procedure TPoly.AddPolyArray(num: Integer; a: cpVectArray);
begin
  PolyPoints := AppendcpVectArray( length(PolyPoints), num, PolyPoints, a );  
end;

procedure TPoly.CreateShapeAndBody(space: PcpSpace; pos: cpVect; mass: Real;
                              texName: string; isstatic: Boolean;
                              data: Pointer; owner: TOwner);
var moment: cpFloat;
begin

// if poly should be static the body has mass and moment = INFINITY
// and the body is not added to space
If isstatic then body := cpBodyNew(INFINITY, INFINITY)
  else begin
    moment := cpMomentForPoly( mass, length(PolyPoints), @PolyPoints[0], cpvzero);
    body := cpSpaceAddBody(space, cpBodyNew(mass, moment) );
    end;

body.p := pos;
body.data := owner;

if not cpPolyValidate( @PolyPoints[0], length(PolyPoints) ) then
  showmessage('plyerror!');

shape := cpSpaceAddShape(space, cpPolyShapeNew(body, length(PolyPoints),
                         @PolyPoints[0], cpvzero) );
shape.u := 0.7;
shape.e := 0.5;
shape.collision_type := 0;
shape.data := data;

drawit := true;
self.static := isstatic;
LoadTexture(TexName, TexId, false);
end;

procedure TPoly.Draw;
var pos, v: TVertex;
    i: Integer;
begin

If drawit then begin
  pos := cpVectToVertex(body.p, 0);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 0.1);

  glPushMatrix;
    glTranslatef(pos[0], pos[1], 0);
    glRotatef( radtodeg(body.a), 0, 0, 1);
    glBindTexture(GL_TEXTURE_2D, texId);

    DrawChipPoly(length(PolyPoints), PolyPoints);

  glPopMatrix;

  glDisable(GL_ALPHA_TEST);
  glDisable(GL_BLEND);
end;

end;

end.

