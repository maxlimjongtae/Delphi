unit Script.FormView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.RegularExpressions,
  Vcl.ExtCtrls, Scripter;

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
  Scripter: TScripter;
  S: string;
  InputText: string;
begin
          {
  InputText :=
  'var a: Integer;' + #13#10 +
  'vara: Integer;' + #13#10 +
  'var a:Integer;' + #13#10 +
  'vara:Integer;' + #13#10 +
  'var abcde: Integer;' + #13#10 +
  'var a10: Integer;' + #13#10 +
  'var a10z: Integer;' + #13#10 +
  'var b: Integer = 12;' + #13#10 +
  'var a: Integer = 10 ;' + #13#10 +
  'var a: Integer =10;' + #13#10 +
  'var a: Integer=10;' + #13#10 +
  'var c: string = ''15'';' + #13#10 +
  'var a: Integer= ''10'';' + #13#10 +
  'var a: Integer=''10'';' + #13#10 +
  'var a: Integer = ''10'' ;' + #13#10 +

  'a = ''  1  '';' + #13#10 +
  'a =''1'';' + #13#10 +
  'a=''1'';' + #13#10 +
  'a= ''1'';' + #13#10 +
  'a = ''1'' ;' + #13#10 +
  'a = 1;' + #13#10 +
  'a=1;' + #13#10 +
  'a =1;' + #13#10 +
  'a =1 ;' + #13#10 +
  'a = 1 ;' + #13#10 +
  'a = b;' + #13#10 +
  'a=b;' + #13#10 +
  'a=b ;' + #13#10 +
  'a = b ;' + #13#10 +
  'a= b ;' + #13#10 +

  'WriteLn(A);' + #13#10 +
  'WriteLn(a);' + #13#10 +
  'WriteLn(''1'');' + #13#10 +
  'WriteLn(1);' + #13#10 +
  'WriteLn(b);' + #13#10 +
  'WriteLn(b);' + #13#10
  ;

  Memo1.Clear;
  Memo1.Lines.Add(InputText);}

  Memo2.Clear;
  Scripter := TScripter.Create;
  try
    S := Scripter.Execute(Memo1.Text);
    Memo2.Lines.Add(S);
  finally
    Scripter.Free;
  end;
end;

end.
