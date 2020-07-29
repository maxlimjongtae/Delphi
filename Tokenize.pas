unit Tokenize;

interface

uses
  System.SysUtils, System.Classes, System.TypInfo, Token, TokenList;

type
  TState = function: Boolean of object;

  TTokenize = class
  private
    FTokenList: TTokenList;

    FValue: string;
    FIndex: Integer;

    FCurrentState: TState;
    FTemporaryValue: string;

    function SemiColonState: Boolean;
    function ColonState: Boolean;
    function SpaceState: Boolean;
    function EqualState: Boolean;
    function OperatorState: Boolean;
    function ReturnState: Boolean;
    function UndefinedState: Boolean;

    function InitialState: Boolean;
    function BranchState: Boolean;
    function FinalState: Boolean;

    function CurrentValue: string;
  public
    constructor Create;
    destructor Destroy; override;

    function Execute(Value: string): TTokenList;

    function CanNext: Boolean;
    function ToString: string;
    procedure Next;

    property TokenList: TTokenList read FTokenlist write FTokenList;
    property Value: string write FValue;
    property Index: Integer read FIndex;
  end;

implementation

{ TTokenize }

function TTokenize.ColonState: Boolean;
begin
  Result := False;

  if FTemporaryValue <> EmptyStr then
  begin
    FTokenList.Add(TToken.Create(FTemporaryValue ,TTokenType.None));
    FTemporaryValue := '';
  end;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.Colon));

  Next;
  FCurrentState := BranchState;
end;

constructor TTokenize.Create;
begin
  FTokenList := TTokenList.Create;
  FValue := '';
  FTemporaryValue := '';
  FIndex := 1;
end;

function TTokenize.CurrentValue: String;
begin
  Result := FValue[FIndex];
end;

destructor TTokenize.Destroy;
begin
  FTokenList.Free;
  inherited;
end;

function TTokenize.BranchState: Boolean;
var
  S: string;
begin
  Result := False;

  if CanNext then
  begin

    S := CurrentValue;

    case WhatIsTokenType(CurrentValue) of
      TTokenType.SemiColon: FCurrentState := SemiColonState;
      TTokenType.Colon: FCurrentState := ColonState;
      TTokenType.Space: FCurrentState := SpaceState;
      TTokenType.Equal: FCurrentState := EqualState;
      TTokenType.Operator: FCurrentState := OperatorState;
      TTokenType.Return : FCurrentState := ReturnState;
      else FCurrentState := UndefinedState;
    end;
  end
  else
    FCurrentState := FinalState;
end;

function TTokenize.CanNext: Boolean;
begin
  if FIndex > Length(FValue) then
    Result := False
  else
    Result := True;
end;

procedure TTokenize.Next;
begin
  if CanNext then
    Inc(FIndex);
end;

function TTokenize.OperatorState: Boolean;
begin
  Result := False;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.Operator));

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.ReturnState: Boolean;
begin
  Next;
  FCurrentState := BranchState;
end;

function TTokenize.SemiColonState: Boolean;
begin
  Result := False;

  if FTemporaryValue <> EmptyStr then
  begin
    FTokenList.Add(TToken.Create(FTemporaryValue ,TTokenType.None));
    FTemporaryValue := '';
  end;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.SemiColon));

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.SpaceState: Boolean;
begin
  Result := False;

  if FTemporaryValue <> EmptyStr then
  begin
    FTokenList.Add(TToken.Create(FTemporaryValue ,TTokenType.None));
    FTemporaryValue := '';
  end;

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.ToString: string;
var
  I: Integer;
  TokenList: TTokenList;
  S: string;
begin
  S := '';

  for I := 0 to FTokenList.Count - 1 do
    S := S + FTokenList.Items[I].Value + ' [' + GetEnumName(Typeinfo(TTokenType),Ord(FTokenList.Items[I].TokenType)) + '] ';

  Result := S;
end;

function TTokenize.EqualState: Boolean;
begin
  Result := False;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.Operator));

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.UndefinedState: Boolean;
begin
  Result := False;

  FTemporaryValue := FTemporaryValue + CurrentValue;

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.Execute(Value: string): TTokenList;
begin
  FValue := Value;

  FCurrentState := InitialState;

  repeat
    FCurrentState;
  until FCurrentState = FinalState;

  Result := FTokenList;
end;

function TTokenize.FinalState: Boolean;
begin
  Result := True;
end;

function TTokenize.InitialState: Boolean;
begin
  Result := False;

  if FValue = EmptyStr then
    FCurrentState := FinalState
  else
    FCurrentState := BranchState;
end;

end.
