unit Script.FormView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.RegularExpressions, Tokenize, Token, TokenList, Conformity,
  Vcl.ExtCtrls;

type
  TScriptView = class(TForm)
    Memo1: TMemo;
    Button: TButton;
    Memo2: TMemo;
    Panel1: TPanel;
    procedure ButtonClick(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Write(S: string); overload;
    procedure Write(I: Integer); overload;
    procedure WriteLn(S: string); overload;
    procedure WriteLn(I: Integer); overload;

    procedure Run(S: string);
  end;

var
  ScriptView: TScriptView;

implementation

{$R *.dfm}

{ TForm1 }

procedure TScriptView.Write(S: string);
begin

end;

procedure TScriptView.ButtonClick(Sender: TObject);
begin
  Run(Memo1.Lines.Text);
end;

procedure TScriptView.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
end;

procedure TScriptView.Memo1Change(Sender: TObject);
begin
  Run(Memo1.Lines.Text);
end;

procedure TScriptView.Run(S: string);
var
  Tokenize: TTokenize;
  Conformity: TConformity;
begin
  Memo2.Clear;
  Tokenize := TTokenize.Create;
  try
    Conformity := TConformity.Create;
    try
      Memo2.lines.Add(Conformity.Execute(Tokenize.Execute(S)));
      Memo2.lines.Add(Tokenize.ToString);
    finally
      Conformity.Free;
    end;
  finally
    Tokenize.Free;
  end;
end;

procedure TScriptView.Write(I: Integer);
begin

end;

procedure TScriptView.WriteLn(S: string);
begin

end;

procedure TScriptView.WriteLn(I: Integer);
begin

end;

end.
