unit Tokenize;

interface

uses
  System.SysUtils, System.Classes, System.TypInfo, Token, TokenList, Variable;

type
  TState = function: Boolean of object;

  TTokenize = class
  const
    START_INDEX = 1;
  private
    FTokenList: TTokenList;

    FLine, FPos: Integer;
    FValueIndex: Integer;
    FValue: string;
    FCurrentState: TState;

    function SemiColonState: Boolean;
    function ColonState: Boolean;
    function SpaceState: Boolean;
    function EqualState: Boolean;
    function OperatorState: Boolean;
    function ReturnState: Boolean;
    function SingleQuoteState: Boolean;
    function StringState: Boolean;
    function NumericState: Boolean;
    function LeftBracketState: Boolean;
    function RightBracketState: Boolean;
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
    procedure NextLine;
  end;

implementation

{ TTokenize }

function TTokenize.ColonState: Boolean;
begin
  Result := False;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.Colon, FLine, FPos));

  Next;
  FCurrentState := BranchState;
end;

constructor TTokenize.Create;
begin
  FTokenList := TTokenList.Create;
  FValue := '';
  FValueIndex := START_INDEX;
  FLine := START_INDEX;
  FPos := START_INDEX;
end;

function TTokenize.CurrentValue: String;
begin
  Result := FValue[FValueIndex];
end;

destructor TTokenize.Destroy;
begin
  FTokenList.Free;
  inherited;
end;

function TTokenize.LeftBracketState: Boolean;
begin
  Result := False;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.LeftBracket, FLine, FPos));
  Next;

  FCurrentState := BranchState;
end;

function TTokenize.BranchState: Boolean;
begin
  Result := False;

  case WhatIsTokenType(CurrentValue) of
    TTokenType.SemiColon:
      FCurrentState := SemiColonState;

    TTokenType.Colon:
      FCurrentState := ColonState;

    TTokenType.Space:
      FCurrentState := SpaceState;

    TTokenType.Equal:
      FCurrentState := EqualState;

    TTokenType.Return:
      FCurrentState := ReturnState;

    TTokenType.SingleQuote:
      FCurrentState := SingleQuoteState;

    TTokenType.LeftBracket:
      FCurrentState := LeftBracketState;

    TTokenType.RightBracket:
      FCurrentState := RightBracketState;

    TTokenType.Operator:
      FCurrentState := OperatorState;

    TTokenType.String:
      FCurrentState := StringState;

    TTokenType.Numeric:
      FCurrentState := NumericState;

    TTokenType.TheEnd:
      FCurrentState := FinalState;

    else FCurrentState := UndefinedState;
  end;
end;

function TTokenize.CanNext: Boolean;
begin
  if FValueIndex > Length(FValue) then
    Result := False
  else
    Result := True;
end;

procedure TTokenize.Next;
begin
  if CanNext then
  begin
    Inc(FValueIndex);
    Inc(FPos);
  end;
end;

procedure TTokenize.NextLine;
begin
  Next;
  Inc(FLine);
  FPos := 1;
end;

function TTokenize.NumericState: Boolean;
var
  S: string;
begin
  Result := False;
  S := '';

  While WhatIsTokenType(CurrentValue) = TTokenType.Numeric do
  begin
    S := S + CurrentValue;
    Next;
  end;

  if not S.IsEmpty then
    FTokenList.Add(TToken.Create(S, TTokenType.Numeric, FLine, FPos - 1));

  FCurrentState := BranchState;
end;

function TTokenize.OperatorState: Boolean;
begin
  Result := False;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.Operator, FLine, FPos));

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.ReturnState: Boolean;
begin
  Result := False;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.Return, FLine, FPos));

  Next;
  NextLine;
  FCurrentState := BranchState;
end;

function TTokenize.RightBracketState: Boolean;
begin
  Result := False;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.RightBracket, FLine, FPos));

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.SemiColonState: Boolean;
begin
  Result := False;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.SemiColon, FLine, FPos));

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.SingleQuoteState: Boolean;
var
  S: string;
begin
  Result := False;
  S := '';
  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.SingleQuote, FLine, FPos));
  Next;

  While WhatIsTokenType(CurrentValue) <> TTokenType.SingleQuote do
  begin
    S := S + CurrentValue;
    Next;
  end;

  if not S.IsEmpty then
    FTokenList.Add(TToken.Create(S, TTokenType.String, FLine, FPos - 1));

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.SingleQuote, FLine, FPos));

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.SpaceState: Boolean;
begin
  Result := False;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.Space, FLine, FPos));

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.StringState: Boolean;
var
  S: string;
begin
  Result := False;
  S := '';

  While WhatIsTokenType(CurrentValue) = TTokenType.String do
  begin
    S := S + CurrentValue;
    Next;
  end;

  if not S.IsEmpty then
    FTokenList.Add(TToken.Create(S, TTokenType.String, FLine, FPos - 1));

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
  begin
    if FTokenList.Items[I].TokenType = TTokenType.Return then
      S := S + #13#10
    else
      S := S + format('%s [%s]' ,
      [FTokenList.Items[I].Value,
      GetEnumName(Typeinfo(TTokenType),Ord(FTokenList.Items[I].TokenType)) ]);
  end;

  Result := S;
end;

function TTokenize.EqualState: Boolean;
begin
  Result := False;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.Equal, FLine, FPos));

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.UndefinedState: Boolean;
begin
  raise Exception.Create(Format('%s is Undefined Value!',[CurrentValue]));
end;

function TTokenize.Execute(Value: string): TTokenList;
begin
  FValue := Value;

  FCurrentState := InitialState;

  repeat
    FCurrentState;
  until FCurrentState = FinalState;

  FTokenList.Add(TToken.Create(#0, TTokenType.TheEnd, FLine, FPos));
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
