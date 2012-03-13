unit UOwner;

interface

uses
  myLib;

type
  TOwner = class
  protected
    name: string;
  public
    Grounding: RGroundingContext;
    function GetName: string;
  end;
  
implementation

function TOwner.GetName: string;
begin
  result := name;
end;

end.
 