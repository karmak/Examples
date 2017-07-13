program Anim;

uses
  Forms,
  frmMain in 'frmMain.pas' {frmCube};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmCube, frmCube);
  Application.Run;
end.

