unit Script.FormView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.RegularExpressions,
  Tokenize, Token, TokenList, Conformity, Vcl.ExtCtrls, Calculration;

type
  TScriptView = class(TForm)
    Memo1: TMemo;
    Button: TButton;
    Memo2: TMemo;
    Panel1: TPanel;
    procedure ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Run;
  end;

var
  ScriptView: TScriptView;

implementation

{$R *.dfm}

{ TForm1 }

procedure TScriptView.ButtonClick(Sender: TObject);
begin
  Run;
end;

procedure TScriptView.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
end;

procedure TScriptView.Memo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_RETURN then
   Run;
end;

procedure TScriptView.Run;
var
  Tokenize: TTokenize;
  TokenList: TTokenList;
  Conformity: TConformity;
  Calculration: TCalculration;
begin
  Memo2.Lines.Clear;

  Tokenize := TTokenize.Create;
  try
    TokenList := Tokenize.Execute(Memo1.Lines.Text);
    Memo2.Lines.Add(Tokenize.ToString);
    Conformity := TConformity.Create;
    try
      Calculration := TCalculration.Create;
      try
        if Conformity.Execute(TokenList) then
           Memo2.Lines.Add(Calculration.Execute(TokenList));
      finally
        Calculration.Free;
      end;
    finally
      Conformity.Free;
    end;
  finally
    Tokenize.Free;
  end;
end;

end.
