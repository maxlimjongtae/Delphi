unit Calculration;

interface

uses
  System.RegularExpressions, System.SysUtils, System.Classes,
  System.Generics.Collections, Token, TokenList, VariableStorage;

type
  TCalculration = class
  private
    FVariable: TDictionary<string, TVariableStorage>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure VariableClear;
    function ToString: string;
  end;

implementation

{ TCalculration }

constructor TCalculration.Create;
begin
  FVariable := TDictionary<string, TVariableStorage>.Create;
end;

destructor TCalculration.Destroy;
begin
  VariableClear;
  FVariable.Free;
  inherited;
end;

function TCalculration.ToString: string;
var
  S: string;
begin
  for S in FVariable.Keys do
    Result := Result + 'Key : ' + S + FVariable.Items[S].ToString + #13#10;
end;

procedure TCalculration.VariableClear;
  S: string;
begin
  for S in FVariable.Keys do
    FVariable.Items[S].Free;
end;

end.
