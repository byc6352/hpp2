program test;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fMain},
  uWeb in 'uWeb.pas' {fWeb},
  uFuncs in 'uFuncs.pas',
  uConfig in 'uConfig.pas',
  uXml in 'uXml.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfWeb, fWeb);
  Application.Run;
end.
