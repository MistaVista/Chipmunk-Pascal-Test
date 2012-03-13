unit ULandscape;

interface

uses
  Chipmunk, Dialogs, StdCtrls, SysUtils;

type
  TLandscape = class
  private
    memo: TMemo;
    owner: Pointer;
    map: array of array of cpVect;
    procedure DeleteFromMap(x,y: Integer);
  public
    constructor create(owner: Pointer; mem: TMemo);
    // pos: start pos on the left bottom size
    // ATTENTION: Width and maxheight unit in blocks
    procedure RandomLandscape(pos, blocksize: cpVect;
                              width, maxheight, blockcount: Integer);
  end;

implementation

uses
  UPhysics;

constructor TLandscape.create(owner: Pointer; mem: TMemo);
begin
  self.owner := owner;
  memo := mem;
end;

procedure TLandscape.RandomLandscape(pos, blocksize: cpVect;
                                      width, maxheight, blockcount: Integer);
var i, j, x, y: Integer;
begin

// init the map
setlength( map, width-1 );

for i := 0 to length(map)-1 do begin
  setlength( map[i], maxheight-1 );
  for j := 0 to length( map[i] ) - 1 do begin
    map[i,j].x := i * blocksize.x;
    map[i,j].y := j * blocksize.y;
    end;
  end;

i := 1;

while ( length(map) > 0 ) and (i < blockcount) do begin
  x := Random( length(map) );
  // no flying block just stacking
  y := 0;
  memo.Lines.Add( inttostr(length(map)) + ' ' + Inttostr(x) + ' ' + inttostr(y) );

  TPhysics(owner).AddBlock( cpvadd(pos, map[x,y]), blocksize.x, blocksize.y, 42,
                            'ground.jpg', true, self);
  DeleteFromMap(x,y);
  inc(i);
  end;



end;

procedure TLandscape.DeleteFromMap(x,y: Integer);
var i: Integer;
begin

if x >= length(map) then begin
  showmessage('x to big');
  exit;
  end;

if y >= length(map[x]) then begin
  showmessage('y to big');
  exit;
  end;

if x < 0 then begin
  showmessage('x to small');
  exit;
  end;

if y < 0 then begin
  showmessage('y to small');
  exit;
  end;

if length( map[x] ) = 1 then begin
  // Now delete map[x]

  if length(map) > 1 then
    for i := x to length(map) - 2 do
      map[i] := map[i+1];

  setlength( map, length(map)-1 );
  end else begin
    // Now delete map[x,y]

    if length(map[x]) > 1 then
      for i := y to length(map[x]) - 2 do
        map[x,i] := map[x,i+1];

    setlength( map[x], length(map[x])-1 );
    end;

end;

end.
 