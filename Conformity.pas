unit Conformity; // Check Syntax

interface

uses
  System.RegularExpressions, System.SysUtils, System.Classes,
  System.Generics.Collections, Token, TokenList, VariableStorage;

type
  TState = function: Boolean of object;

  TConformity = class
  private
    FVariable: TDictionary<string, TVariableStorage>;

    FCurrentState: TState;
    FTokenList: TTokenList;

    function ReservedState: Boolean;
    function VariableState: Boolean;
    function MethodState: Boolean;

    function BranchState: Boolean;
    function InitialState: Boolean;
    function FinalState: Boolean;

    function VariableSynTaxCheck(S: string): Boolean;
    function ValueSyntaxCheck(S: string; VariableType: TVariableType): Boolean;

    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;

    function Execute(TokenList: TTokenList): string;
  end;

implementation

{ TConformity }

function TConformity.Execute(TokenList: TTokenList): string;
var
  S: string;
begin
  FTokenList := TokenList;

  FCurrentState := InitialState;

  repeat
    FCurrentState;
  until FCurrentState = FinalState;

  for S in FVariable.Keys do
    Result := Result + FVariable.Items[S].ToString;
end;

function TConformity.BranchState: Boolean;
var
  S: string;
begin
  Result := False;

  if FTokenList.CanNext then
  begin
    S := FTokenList.CurrentToken.Value;
    case WhatIsTokenType(FTokenList.CurrentToken.Value) of
      TTokenType.ReservedWord : FCurrentState := ReservedState;
      TTokenType.Variable : FCurrentState := VariableState;
      TTokenType.Return : FTokenList.Next
      else {handling exceptions}
    end;
  end
  else FCurrentState := FinalState;
end;

function TConformity.FinalState: Boolean;
begin
  Result := True;
end;

function TConformity.InitialState: Boolean;
begin
  if FTokenList.Count = 0 then
    FCurrentState := FinalState
  else
    FCurrentState := BranchState;
end;

function TConformity.MethodState: Boolean;
begin

end;

function TConformity.ReservedState: Boolean;
var
  S, S2: string;
  Variable: TVariableStorage;
begin
  Result := False;
  S := '';

  FTokenList.Next;

  S2 := FTokenList.CurrentToken.Value;

  if not VariableSyntaxCheck(FTokenList.CurrentToken.Value) then
    raise Exception.Create('Variable Syntax Error!');

  if FVariable.ContainsKey(FTokenList.CurrentToken.Value) then
    raise Exception.Create('Duplicate Key');

  Variable := TVariableStorage.Create('', TVariableType.None);
  FVariable.Add(FTokenList.CurrentToken.Value , Variable);
  S:= FTokenList.CurrentToken.Value;

  FTokenList.Next;

  if WhatIsTokenType(FTokenList.CurrentToken.Value) <> TTokenType.Colon then
    raise Exception.Create('Colon Not Found');

  FTokenList.Next;

  if WhatIsTokenType(FTokenList.CurrentToken.Value) <> TTokenType.VariableType then
    raise Exception.Create('VariableType Not Found!');

  Variable.VariableType := WhatIsVariableType(FTokenList.CurrentToken.Value);
  FVariable.AddOrSetValue(S,Variable);

  FTokenList.Next;

  case WhatIsTokenType(FTokenList.CurrentToken.Value) of
    TTokenType.SemiColon:
    begin
      FTokenList.Next;
      FCurrentState := BranchState;
    end;
    TTokenType.Equal:
    begin
      FTokenlist.Next;

      if ValueSyntaxCheck(FTokenList.CurrentToken.Value, Variable.VariableType) then
        Variable.Vaule := FTokenList.CurrentToken.Value;
    end
    else raise Exception.Create('SemiColon Not Found');
  end;
end;

function TConformity.ValueSyntaxCheck(S: string; VariableType: TVariableType): Boolean;
begin
  case VariableType of
    TVariableType.Integer: Result := TRegEx.IsMatch(S,'[0-9]');
    TVariableType.string: Result := TRegEx.IsMatch(S,'[a-zA-Z]');
    else raise Exception.Create('Undefined Type');
  end;
end;

function TConformity.VariableState: Boolean;
begin

end;

function TConformity.VariableSyntaxCheck(S: string): Boolean;
begin
  Result := TRegEx.IsMatch(S,'[a-zA-Z]');
end;

procedure TConformity.Clear;
var
  S: string;
begin
  for S in FVariable.Keys do
    FVariable.Items[S].Free;
end;

constructor TConformity.Create;
begin
  FVariable := TDictionary<string, TVariableStorage>.Create;
end;

destructor TConformity.Destroy;
begin
  Clear;
  FVariable.Free;
  inherited;
end;

end.
