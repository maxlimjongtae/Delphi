unit Tokenize;

interface

uses
  System.SysUtils, System.Classes, System.TypInfo, Token, TokenList;

type
  TState = function: Boolean of object;

  TTokenize = class
  private
    FTokenList: TTokenList;

    FLine, FPos: Integer;
    FValueIndex: Integer;
    FValue: string;
    FTemporaryValue: string;
    FCurrentState: TState;


    function SemiColonState: Boolean;
    function ColonState: Boolean;
    function SpaceState: Boolean;
    function EqualState: Boolean;
    function OperatorState: Boolean;
    function ReturnState: Boolean;
    function UndefinedState: Boolean;
    function SingleQuoteState: Boolean;
    function BracketState: Boolean;

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

//    property TokenList: TTokenList read FTokenlist;
//    property Value: string write FValue;
//    property Index: Integer read FValueIndex;
  end;

implementation

{ TTokenize }

function TTokenize.ColonState: Boolean;
begin
  Result := False;

  if FTemporaryValue <> EmptyStr then
  begin
    FTokenList.Add(TToken.Create(FTemporaryValue ,TTokenType.Variable, FLine, FPos-1));
    FTemporaryValue := '';
  end;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.Colon, FLine, FPos));

  Next;
  FCurrentState := BranchState;
end;

constructor TTokenize.Create;
begin
  FTokenList := TTokenList.Create;
  FValue := '';
  FTemporaryValue := '';
  FValueIndex := 1;
  FLine := 1;
  FPos := 1;
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

function TTokenize.BracketState: Boolean;
begin
  Result := False;

  if FTemporaryValue <> EmptyStr then
  begin
    FTokenList.Add(TToken.Create(FTemporaryValue , WhatIsTokenType(FTemporaryValue), FLine, FPos-1));
    FTemporaryValue := '';
  end;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.Bracket, FLine, FPos));

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.BranchState: Boolean;
var
  S: string;
begin
  Result := False;

  S := CurrentValue;
  if CanNext then
  begin
    case WhatIsTokenType(CurrentValue) of
      TTokenType.SemiColon: FCurrentState := SemiColonState;
      TTokenType.Colon: FCurrentState := ColonState;
      TTokenType.Space: FCurrentState := SpaceState;
      TTokenType.Equal: FCurrentState := EqualState;
      TTokenType.Operator: FCurrentState := OperatorState;
      TTokenType.Return : FCurrentState := ReturnState;
      TTokenType.SingleQuote : FCurrentState := SingleQuoteState;
      TTokenType.Bracket : FCurrentState := BracketState;
      else FCurrentState := UndefinedState;
    end;
  end
  else
    FCurrentState := FinalState;
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

  if FTemporaryValue <> EmptyStr then
  begin
    FTokenList.Add(TToken.Create(FTemporaryValue , WhatIsTokenType(FTemporaryValue), FLine, FPos-1));
    FTemporaryValue := '';
  end;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.Return, FLine, FPos));

  Next;
  NextLine;
  FCurrentState := BranchState;
end;

function TTokenize.SemiColonState: Boolean;
begin
  Result := False;

  if FTemporaryValue <> EmptyStr then
  begin
    FTokenList.Add(TToken.Create(FTemporaryValue, WhatIsTokenType(FTemporaryValue), FLine, FPos-1));
    FTemporaryValue := '';
  end;

  FTokenList.Add(TToken.Create(CurrentValue ,TTokenType.SemiColon, FLine, FPos));

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.SingleQuoteState: Boolean;
begin
  Result := False;

  while CanNext do
  begin
    Next;

    if WhatIsTokenType(CurrentValue) = TTokenType.Return then
    begin
      FCurrentState := ReturnState;
      Exit;
    end;

    // return, semicolon
    if WhatIsTokenType(CurrentValue) = TTokenType.SingleQuote then
    begin
      FTokenList.Next;
      Break;
    end;

    FTemporaryValue := FTemporaryValue + CurrentValue;
  end;

  FTokenList.Add(TToken.Create(FTemporaryValue , TTokenType.Value, FLine, FPos-1));
  FTemporaryValue := '';

  Next;
  FCurrentState := BranchState;
end;

function TTokenize.SpaceState: Boolean;
begin
  Result := False;

  if FTemporaryValue <> EmptyStr then
  begin
    FTokenList.Add(TToken.Create(FTemporaryValue , WhatIsTokenType(FTemporaryValue), FLine, FPos-1));
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
  begin
    if FTokenList.Items[I].TokenType = TTokenType.Return then
      S := S + #13#10
    else
      S := S + format('%s (%s) %s ' ,
      [FTokenList.Items[I].Value,
      GetEnumName(Typeinfo(TTokenType),Ord(FTokenList.Items[I].TokenType)),
      FTokenList.Items[I].GetPosition ]);
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
