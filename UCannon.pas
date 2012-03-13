unit UCannon;

interface

uses
  Chipmunk, UMovingObjects, UOwner, Math;

type
  TCannon = class(TOwner)
  private
    pos, anchorpoint: cpVect;
    min_a, max_a, angle, power, bulletDist: Real;
    frame, inner: TMovingObject;
    Owner: Pointer;
    bullet: TMovingObject;
    bulletGroupOrig: Cardinal;
  public
    constructor create(own: Pointer; pos, size: cpVect; mass, minangle, maxangle: Real; frameTex, innerTex: string);
    procedure Rotate(delta: Real);
    procedure FillCannon(obj: TMovingObject);
    function Fire: Boolean;
  end;

implementation

uses
  UPhysics;

constructor TCannon.create(own: Pointer; pos, size: cpVect; mass, minangle, maxangle: Real; frameTex, innerTex: string);
begin
  name := 'CANNON';

  min_a := minangle;
  max_a := maxangle;
  angle := 0;
  power := 10000;
  Owner := own;

  self.pos := pos;
  anchorpoint := cpvadd( pos, cpvmult(size, 0.5) );

  // create to static blocks (frame and inner) with owner = self
  // and set them in the same group
  frame := TPhysics(Owner^).AddBlock(pos, size.x, size.y, mass, frameTex, true, self);
  inner := TPhysics(Owner^).AddBlock(anchorpoint, size.x*2, size.y/2, mass, innerTex, true, self);
  frame.SetGroup(42);
  inner.SetGroup(42);

  bulletDist := size.x;
end;

procedure TCannon.Rotate(delta: Real);
var fv: cpVect;
begin
  inner.Turn(delta);
  if bullet <> nil then begin
    fv := cpvforangle( inner.GetBody.a );
    fv := cpvnormalize( fv );
    fv := cpvrotate( cpv( bulletDist , 0), fv );
    bullet.GetBody.p := cpvAdd( inner.GetBody.p, fv );
    end;

end;

procedure TCannon.FillCannon(obj: TMovingObject);
begin
  bullet := obj;
  bulletGroupOrig := bullet.GetShape.group;
  bullet.SetGroup(42);
  bullet.GetBody.p := cpv(anchorpoint.x + bulletDist, anchorpoint.y);
  bullet.GetBody.v := cpvzero;
  bullet.GetBody.a := 0;
  bullet.Sleep;
  Rotate(0);
end;

function TCannon.Fire: Boolean;
var fv: cpVect;
begin

If bullet = nil then result := false
  else begin
    // TODO: should cannon power be relative to mass of bullet??
    //power := power * bullet.GetBody.m;

    // create vector from anchorpoint to bulletpos
    // this vector is the direction the bullet has to take
    fv := cpv( bullet.GetBody.p.x, bullet.GetBody.p.y );
    fv := cpvSub( fv, cpv( inner.GetBody.p.x, inner.GetBody.p.y ) );
    fv := cpvNormalize( fv );
    fv := cpvMult( fv, power );

    bullet.Activate;
    cpBodyApplyImpulse(bullet.GetBody, fv , cpvzero);
    bullet.SetGroup(bulletGroupOrig);
    bullet := nil;
  end;

end;

end.