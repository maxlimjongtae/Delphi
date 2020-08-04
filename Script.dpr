program Script;

uses
  Vcl.Forms,
  Script.FormView in 'Script.FormView.pas' {ScriptView},
  Tokenize in 'Tokenize.pas',
  TokenList in 'TokenList.pas',
  Token in 'Token.pas',
  Conformity in 'Conformity.pas',
  Variable in 'Variable.pas',
  Method in 'Method.pas',
  Calculration in 'Calculration.pas',
  DataStorage in 'DataStorage.pas',
  Scripter in 'Scripter.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TScriptView, ScriptView);
  Application.Run;
end.
