unit UPhysics;

interface

uses
  Chipmunk, Geometry, myLib, UObjects, Textures, dglOpenGL, Dialogs, SysUtils,
  UMovingObjects, UBox, UBall, UPoly, UOwner, UCannon, ULandscape, StdCtrls;

type
  TPhysics = class
  private
    LastActive: Integer;
    Scape: TLandscape;
    timeStep, radius: cpFloat;
    space: PcpSpace;
    myJoint: PcpConstraint;
    groundParts: array of RGroundPart;
    Objects: array of TMovingObject;
    procedure InitChipmunk;
    function CheckOwnerOfObject(obj: Integer; name: string): boolean;

    procedure Stonehenge(pos: cpVect; var iter: Integer);
  public
    memo: TMemo;
    constructor create(memo: TMemo);
    procedure Draw;
    procedure AddGroundPart(v0, v1: cpVect);
    function AddBlock(pos: cpVect; width, height, mass: Real;
                      texName: string; static: boolean; owner: TOwner): TMovingObject;
    function AddBall(pos: cpVect; radius, mass: Real;
                      texName: string; static: Boolean; owner: TOwner): TMovingObject;
    function AddCannon(pos: cpVect): TCannon;
    function AddPoly(pos: cpVect; polycount: Integer; polys: cpVectArray; mass: Real; static: boolean): TMovingObject;
    procedure MoveBlock(index: Integer; x, y: Real);
    procedure TurnBlock(index: Integer; a: Real);
    function GetBlockByClick(x, y: Real): Integer;
    procedure BlockSleep(index: integer);
    procedure BlockWake(index: integer);
    procedure DeleteObjectByShape(shape: PcpShape);
    procedure KeyDown(key: word);
    procedure KeyUp(key: word);
 end;

implementation

constructor TPhysics.create(memo: TMemo);
var obj: Pointer;
    blk: TMovingObject;
    i: Integer;
    p0, p1: cpVect;
begin
self.memo := memo;

  Randomize;
  setlength(Objects, 0);
  setlength(groundParts, 0);
  InitChipmunk;

  Scape := TLandscape.create(self, memo);
  // startpos, seglen, segcount, maxhei, minei, maxdif, mindif
  Scape.RandomLandscape( cpv(-80,10), 4, 40, 100, 10, 10, -10);
  Scape.CreatePolyFromMap;
  Scape.CreateLineGround;

  if Scape.FindPlatforms then begin
    Scape.GotoFirstPlatform;
    Scape.NextPlatform(p0, p1);
     AddCannon( cpv( ((p1.x - p0.x) / 2) + p0.x, p1.y + 5 ) );

    while Scape.NextPlatform(p0, p1) do begin
      i := 1;
      Stonehenge( cpv( ((p1.x - p0.x) / 2) + p0.x, p1.y + 5 ) , i );
      end;
  end;


end;

procedure TPhysics.InitChipmunk;
var gravity: cpVect;
begin
  cpLoad('chipmunk.dll');
  cpInitChipmunk;

  gravity := cpv(0, -100);
  space := cpSpaceNew;
  space.gravity := gravity;
  space.iterations := 20;
  space.elasticIterations := 20;

  timeStep := 1 / 100;
  space.sleepTimeThreshold := 1;
  
 // cpSpaceAddCollisionHandler(space, 1, 0, BeginTouch, nil, nil, nil, nil);
end;

procedure TPhysics.AddGroundPart(v0, v1: cpVect);
var newGround: PcpShape;
begin
  setlength( groundParts, length(groundParts)+1 );
  groundParts[ length(groundParts)-1 ].v0 := v0;
  groundParts[ length(groundParts)-1 ].v1 := v1;

  // add new ground part to chipmunk space
  {newGround := cpSegmentShapeNew(@space.staticBody, v0, v1, 1);
  newGround.u := 1;   // set friction
  cpSpaceAddShape(space, newGround);      }
end;

function TPhysics.AddBlock(pos: cpVect; width, height, mass: Real; texName: string; static: Boolean; owner: TOwner): TMovingObject;
begin
  setlength( Objects, length(Objects)+1 );
  Objects[ length(Objects)-1 ] := TBox.create(space, pos, width, height, mass, texName, static, @self, owner);
  result := Objects[ length(Objects)-1 ];
end;

function TPhysics.AddBall(pos: cpVect; radius, mass: Real; texName: string; static: boolean; owner: TOwner): TMovingObject;
begin
  setlength( Objects, length(Objects)+1 );
  Objects[ length(Objects)-1 ] := TBall.create(space, pos, radius, mass, texName, static, @self, owner);
  result := Objects[ length(Objects)-1 ];
end;

function TPhysics.AddPoly(pos: cpVect; polycount: Integer; polys: cpVectArray; mass: Real; static: boolean): TMovingObject;
var i: Integer;
begin
  setlength( Objects, length(Objects)+1 );
  Objects[ length(Objects)-1 ] := TPoly.Create;
  result := Objects[ length(Objects)-1 ];

  for i := 0 to polycount-1 do
    TPoly(result).AddPolyPoint(polys[i]);
    
  TPoly(result).CreateShapeAndBody(space, pos, mass, 'block.jpg', static, nil, nil);
end;

function TPhysics.AddCannon(pos: cpVect): TCannon;
var can: TCannon;
begin
  result := TCannon.create(@self, pos, cpv(5,5), 10,
                        DegToRad(-45), DegToRad(45), 'block.jpg', 'woodblock.jpg');
end;

procedure TPhysics.Draw;
var i: Integer;
begin

for i := 0 to length(groundParts)-1 do
  DrawChipLine( groundParts[i].v0, groundParts[i].v1 );

for i := 0 to length(Objects)-1 do
  Objects[i].Draw;

cpSpaceStep(space, timeStep);
end;

procedure TPhysics.MoveBlock(index: Integer; x, y: Real);
begin
  Objects[index].Move(x, y);
end;

procedure TPhysics.TurnBlock(index: Integer; a: Real);
begin

If CheckOwnerOfObject(index, 'CANNON') then
  TCannon(Objects[index].GetBody.data).Rotate(a)
    else Objects[index].Turn(a);

end;

function TPhysics.GetBlockByClick(x, y: Real): Integer;
var i: Integer;
    h: Real;
    p: cpVect;
    shape: PcpShape;
    layers: cpLayers;
    group: cpGroup;
begin
result := -1;

  p := cpv(x, y);
  shape := cpSpacePointQueryFirst(space, p, layers, group);

  if shape <> nil then
    for i := 0 to length(Objects)-1 do
      If shape = Objects[i].GetShape then
          result := i;

  if result <> -1 then LastActive := result;
end;

procedure TPhysics.DeleteObjectByShape(shape: PcpShape);
var i: Integer;
begin

  for i := 0 to length(Objects)-1 do
    if Objects[i].GetShape = shape then begin
      cpSpaceRemoveBody(space, Objects[i].GetBody);
      cpBodyFree( Objects[i].GetBody );
      cpSpaceRemoveShape(space, Objects[i].GetShape);
      cpShapeFree( Objects[i].GetShape );
      Objects[i].Kill;
      Objects[i].Free;
      Objects[i] := Objects[ length(Objects)-1 ];
      end;

end;

procedure TPhysics.BlockSleep(index: Integer);
begin
  Objects[index].Sleep;
end;

procedure TPhysics.BlockWake(index: Integer);
begin
  Objects[index].Activate;
end;

procedure TPhysics.KeyDown(key: word);
begin
  case key of
    32: begin
          if CheckOwnerOfObject(LastActive, 'CANNON') then begin
            // fill with ball and shooooot
            TCannon( Objects[lastActive].GetBody.data ).FillCannon( AddBall( cpvzero, 1, 50, 'ball.tga', false, nil) );
            TCannon( Objects[lastActive].GetBody.data ).Fire;
            end;
        end;
    end;
end;

procedure TPhysics.KeyUp(key: word);
begin

end;

function TPhysics.CheckOwnerOfObject(obj: Integer; name: string): boolean;
begin
result := false;

if (obj > 0) and (obj < length(Objects)) then
  if not (Objects[obj].GetBody.data = nil) then
    if name = TOwner( Objects[obj].GetBody.data ).GetName then result := true;

end;

procedure TPhysics.Stonehenge(pos: cpVect; var iter: Integer);
begin

if iter > 0 then begin
  dec(iter);

AddBlock( pos, 1, 5, 10, 'block.jpg', false, nil);
AddBlock( cpv( pos.x + 5, pos.y) , 1, 5, 10, 'block.jpg', false, nil);
AddBlock( cpv( pos.x + 2.5, pos.y + 5 ), 8, 1, 5, 'block.jpg', false, nil);

Stonehenge( cpv(pos.x, pos.y + 9), iter );
  end;

end;

end.
