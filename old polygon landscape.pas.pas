unit ULandscape;

interface

uses
  Chipmunk, Dialogs, StdCtrls, SysUtils, myLib, UPoly;

type
  TLandscape = class
  private
    PlatformTolerance: Real;
    memo: TMemo;
    owner: Pointer;
    map: cpVectArray;
    CurPlatform: Integer;
    Platforms: array of array[0..1] of cpVect;
    procedure AddPlatform(p0, p1: cpVect);
  public
    constructor create(owner: Pointer; mem: TMemo);

    procedure RandomLandscape(pos: cpVect; seglen: Real;
                              segcount, maxhei, minhei, maxdif, mindif: Integer);
    procedure CreateLineGround;
    procedure CreatePolyFromMap;

    function FindPlatforms: Boolean;
    procedure AddToMap( p: cpVect);

    function NextPlatform(var p0, p1: cpVect): boolean;
    function GotoFirstPlatform: boolean;
  end;

implementation

uses
  UPhysics;

constructor TLandscape.create(owner: Pointer; mem: TMemo);
begin
  PlatformTolerance := 0;
  self.owner := owner;
  memo := mem;
end;

procedure TLandscape.RandomLandscape(pos: cpVect; seglen: Real;
                                      segcount, maxhei, minhei, maxdif, mindif: Integer);
var i: Integer;
    p0, p1: cpVect;
begin
setlength( map, 0 );
p0 := pos;

for i := 0 to segcount - 1 do begin
  p1.x := p0.x + seglen;
  p1.y := p1.y + Random(maxdif - mindif) + mindif;
  If p1.y > maxhei then p1.y := maxhei;
  If p1.y < minhei then p1.y := minhei;

  AddToMap( p0 );
  If (i = segcount -1) then AddToMap( p1 ); // last run

  p0 := p1;
  end;

end;

procedure TLandscape.CreateLineGround;
var i: Integer;
begin
  for i := 1 to length(map)-1 do
    TPhysics(owner).AddGroundPart( map[i-1], map[i]);
end;

procedure TLandscape.CreatePolyFromMap;
var i, j: Integer;
    p0, p1, pos: cpVect;
    up: Boolean;
    poly: TPoly;
    polys, hmap: cpVectArray;
begin
  up := true;
  i := 1;

  setlength( hmap, length(map) );
  hmap := map;

  while length(hmap) > 1 do begin
    p0 := hmap[i-1];
    p1 := hmap[i];

    if p1.y < p0.y then up := false;

    // if its gone down and then up again poly would not be convex
    // or last run at the end of hmap
    // so cut and create poly
    If (not up and (p1.y > p0.y)) or (i = length(hmap)-1 )then begin
        // cut:   hmap = polys|hmap
        DividecpVectArray( i, hmap, polys, hmap );

        if length(polys) > 0 then begin
          // calc pos of poly
          pos := polys[0];

          // polys coords must be relativ from pos
          for j := 0 to length(polys)-1 do
            polys[j] := cpvSub( polys[j], pos );

          // clockwise widing, so now add bottom rigth, then bottom left
          setlength( polys, length(polys)+2 );
          polys[ length(polys)-2 ].x := polys[ length(polys)-3 ].x;
          polys[ length(polys)-2 ].y := -100;

          polys[ length(polys)-1 ].x := 0;
          polys[ length(polys)-1 ].y := -100;

          TPhysics(owner).AddPoly( pos, length(polys), polys, 42, true );
          up := true;
          i := 1;
          end;
      
      end else inc(i);

  end;

end;

procedure TLandscape.AddToMap(p: cpVect);
begin
  setlength( map, length(map)+1 );
  map[ length(map)-1 ] := p;
end;

// PLATFORM MANAGEMENT

function TLandscape.FindPlatforms: Boolean;
var i: Integer;
    p0, p1, platStart: cpVect;
    IsPlatform: Boolean;
begin
setlength( Platforms, 0 );
result := false;
IsPlatform := false;

for i := 1 to length(map) -1 do begin
  p0 := map[i-1];
  p1 := map[i];

  // Platform starts
  If IsEqualWithTolerance( p0.y, p1.y, PlatformTolerance ) then
    If not IsPlatform then begin
      platStart := p0;
      IsPlatform := true;
      end;

  // Platform ends
  If not (IsEqualWithTolerance( p0.y, p1.y, PlatformTolerance )) and IsPlatform
    then begin
      IsPlatform := false;
      AddPlatform(platStart, p0);
      end;

  // Last element and platform? platform ends!
  if ( i = length(map)-1 ) and IsPlatform then begin
    AddPlatform(platStart, p1);
    end;

  end;

If length( Platforms ) > 0 then result := true;

end;   

procedure TLandscape.AddPlatform(p0, p1: cpVect);
begin
  setlength( platforms, length(platforms)+1 );
  Platforms[ length(platforms)-1 ][0] := p0;
  Platforms[ length(platforms)-1 ][1] := p1;
end;

function TLandscape.NextPlatform(var p0, p1: cpVect): boolean;
begin
  if CurPlatform < length(Platforms)-1 then begin
    p0 := Platforms[CurPlatform][0];
    p1 := Platforms[CurPlatform][0];
    inc(CurPlatform);
    result := true;
    end else result := false;
end;

function TLandscape.GotoFirstPlatform: boolean;
begin
  if length(platforms) > 0 then begin
    result := true;
    CurPlatform := 0;
      end else result := false;
end;

end.
 