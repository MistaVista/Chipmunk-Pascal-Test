unit myLib;

interface

uses
  Chipmunk, dglOpenGL;

type
  RBall = record
    body: PcpBody;
    shape: PcpShape;
    radius: Real;
    TexId: gluInt;
    static: boolean;
    end;
  RBox = record
    body: PcpBody;
    shape: PcpShape;
    width: Real;
    height: Real;
    texId: gluInt;
    static: boolean;
    end;
  RGroundPart = record
    v0: cpVect;
    v1: cpVect;
    end;
  RGroundingContext = record
    normal: cpVect;
    impulse: cpVect;
    penetration: cpFloat;
    body: PcpBody;
    end;

function IsEqualWithTolerance(a, b, tolerance: Real): Boolean;
function AppendcpVectArray(anum, bnum: Integer; a, b: cpVectArray): cpVectArray;
procedure DividecpVectArray(num: Integer; orig: cpVectArray; var part1, part2: cpVectArray);

procedure DividecpVectArrayCreatePolyFromMapVersion(num: Integer; orig: cpVectArray; var part1, part2: cpVectArray);

implementation

function IsEqualWithTolerance(a, b, tolerance: Real): Boolean;
begin
  if (a >= b - tolerance) and ( a <= b + tolerance ) then result := true
    else result := false;
end;

function AppendcpVectArray(anum, bnum: Integer; a, b: cpVectArray): cpVectArray;
var i: Integer;
begin
  setlength( result, anum + bnum );

  for i := 0 to anum - 1 do
    result[i] := a[i];

  for i := 0 to bnum - 1 do
    result[ anum + i ] := b[ anum + i ];
    
end;

// orig = part1|part2
procedure DividecpVectArray(num: Integer; orig: cpVectArray; var part1, part2: cpVectArray);
var i: Integer;
begin

  setlength( part2, length(orig) - num  );
  for i := num to length(orig)-1 do
    part2[i - num] := orig[i];

  // cut part1 to the length of num
  part1 := orig;
  setlength( part1, num );

end;

// SPECIAL PROCEDURE for TPoly class
// orig = part1|part2
// PLUS: part1[last] = part2[first]
procedure DividecpVectArrayCreatePolyFromMapVersion(num: Integer; orig: cpVectArray; var part1, part2: cpVectArray);
var i: Integer;
begin

if num < 2 then begin
  setlength(part1, 0);
  setlength(part2, length(orig) );
  part2 := orig;
  end else begin

  setlength( part2, length(orig) - num + 1  );
  for i := num - 1 to length(orig)-1 do
    part2[i - num - 1 ] := orig[i];

  // cut part1 to the length of num
  part1 := orig;
  setlength( part1, num );
  end;

end;

end.
 