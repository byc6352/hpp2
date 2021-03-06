program pp;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fMain},
  uWeb in 'uWeb.pas' {fWeb},
  uFuncs in 'uFuncs.pas',
  uConfig in 'uConfig.pas',
  uXml in 'uXml.pas',
  uAuth in 'uAuth.pas',
  uTryDown in 'uTryDown.pas',
  uDataSocket in 'uDataSocket.pas',
  uHookSocketProcessor in 'uHookSocketProcessor.pas',
  uMyJoson in 'uMyJoson.pas',
  uDataPakageParser in 'uDataPakageParser.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfWeb, fWeb);
  Application.Run;
end.
