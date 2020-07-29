unit Conformity; // Check Syntax

interface

uses
  System.RegularExpressions, System.SysUtils, System.Classes,
  System.Generics.Collections, Token, TokenList, Variable;

type
  TState = function: Boolean of object;

  TConformity = class
  private
    FDictionary: TDictionary<string, TVariable>;
    FCurrentState: TState;
    FTokenList: TTokenList;

    function ReservedState: Boolean;
    function VariableState: Boolean;
    function MethodState: Boolean;

    function BranchState: Boolean;
    function InitialState: Boolean;
    function FinalState: Boolean;

    function VariableSynTaxCheck(S: string): Boolean;
    function ValueSynTaxCheck(V: Variant; VariableType: TVariableType): Boolean;
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

  for S in FDictionary.Keys do
    Result := Result + FDictionary.Items[S].ToString;
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
      TTokenType.Return : FTokenList.Next;
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
  S: string;
  Variable: TVariable;
begin
  S := '';

  FTokenList.Next;

  if VariableSynTaxCheck(FTokenList.CurrentToken.Value) then
  begin

    if FDictionary.ContainsKey(FTokenList.CurrentToken.Value) then
      raise Exception.Create('Duplicate Key')
    else
    begin
      Variable := TVariable.Create(FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Value, TVariableType.None);
      FDictionary.Add(FTokenList.CurrentToken.Value , Variable);
      S:= FTokenList.CurrentToken.Value;
    end;

    FTokenList.Next;

    if WhatIsTokenType(FTokenList.CurrentToken.Value) <> TTokenType.Colon then
      raise Exception.Create('Error Message');
    begin
      FTokenList.Next;

      if WhatIsTokenType(FTokenList.CurrentToken.Value) = TTokenType.VariableType then
      begin
        Variable.VariableType := WhatIsVariableType(FTokenList.CurrentToken.Value);
        FDictionary.AddOrSetValue(S,Variable);

        FTokenList.Next;

        if WhatIsTokenType(FTokenList.CurrentToken.Value) = TTokenType.SemiColon then
        begin
          FTokenList.Next;

          FCurrentState := BranchState;
        end
        else if WhatIsTokenType(FTokenList.CurrentToken.Value) = TTokenType.Equal then
        begin
          FTokenlist.Next;

          if ValueSynTaxCheck(FTokenList.CurrentToken.Value, Variable.VariableType) then
            Variable.Vaule := FTokenList.CurrentToken.Value;

        end else raise Exception.Create('SemiColon Not Found!');
      end else raise Exception.Create('VariableType Not Found!');
    end else raise Exception.Create('Colon Not Found!');
  end else raise Exception.Create('Variable SynTax Error!');
end;

function TConformity.ValueSynTaxCheck(V: Variant; VariableType: TVariableType): Boolean;
begin
  case VariableType of
    TVariableType.Integer: Result := TRegEx.IsMatch(V,'[a-zA-Z]');
    TVariableType.string: Result := TRegEx.IsMatch(V,'[0-9]');
    else raise Exception.Create('Unkwon Variable Types');
  end;
end;

function TConformity.VariableState: Boolean;
begin

end;

function TConformity.VariableSynTaxCheck(S: string): Boolean;
begin
  Result := TRegEx.IsMatch(S,'[a-zA-Z]');
end;

constructor TConformity.Create;
begin
  FDictionary := TDictionary<string, TVariable>.Create;
end;

destructor TConformity.Destroy;
begin
  FDictionary.Free;
  inherited;
end;

end.
