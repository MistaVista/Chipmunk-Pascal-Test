program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  UPhysics in 'UPhysics.pas',
  myLib in 'myLib.pas',
  UMovingObjects in 'UMovingObjects.pas',
  UBox in 'UBox.pas',
  UBall in 'UBall.pas',
  UCannon in 'UCannon.pas',
  UOwner in 'UOwner.pas',
  ULandscape in 'ULandscape.pas',
  UPoly in 'UPoly.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
