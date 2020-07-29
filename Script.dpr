program Script;

uses
  Vcl.Forms,
  Script.FormView in 'Script.FormView.pas' {ScriptView},
  Tokenize in 'Tokenize.pas',
  TokenList in 'TokenList.pas',
  Token in 'Token.pas',
  Conformity in 'Conformity.pas',
  Common in 'Common.pas',
  Variable in 'Variable.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TScriptView, ScriptView);
  Application.Run;
end.
