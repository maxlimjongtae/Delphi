unit Token;

interface

uses
  System.SysUtils, System.RegularExpressions, Variable;

type
  {$SCOPEDENUMS ON}
  TTokenType = (Undefined, ReservedWord, Variable, VariableType, Space, Colon, SemiColon, Value, Equal, SingleQuote, &Operator, Return, Method, Bracket);
  {$SCOPEDENUMS OFF}

  TToken = class
  private
    FLine, FPos: Integer;
    FValue: string;
    FTokenType: TTokenType;
  public
    constructor Create(Value: string; TokenType: TTokenType; Line, Pos: Integer); overload;
    destructor Destroy; override;

    function GetPosition: string;

    property Value: string read FValue;
    property TokenType: TTokenType read FTokenType;
  end;

  function WhatIsTokenType(Value: string): TTokenType;

implementation

{ TToken }

function WhatIsTokenType(Value: string): TTokenType;
begin
  if Value = ' ' then
    Result := TTokenType.Space
  else if Value = ';' then
    Result := TTokenType.SemiColon
  else if Value = '=' then
    Result := TTokenType.Equal
  else if Value = ':' then
    Result := TTokenType.Colon
  else if Value = '''' then
    Result := TTokenType.SingleQuote
  else if Value = 'var' then
    Result := TTokenType.ReservedWord
  else if (Value = 'Integer') or (Value = 'string') then
    Result := TTokenType.VariableType
  else if (Value = #13) then
    Result := TTokenType.Return
  else if (Value = '+') or (Value = '-') or (Value = '*') or (Value = '/') then
    Result := TTokenType.Operator
  else if (TRegEx.IsMatch(Value,'^[0-9]+$')) or (TRegEx.IsMatch(Value,'^[a-zA-Z]+$')) then
    Result := TTokenType.Value
  else if (Value = 'Write') or (Value = 'WriteLn') then
    Result := TTokenType.Method
  else if (Value = '(') or (Value = ')')  then
    Result := TTokenType.Bracket
  else
    Result := TTokenType.Variable;
end;

constructor TToken.Create(Value: string; TokenType: TTokenType; Line, Pos: Integer);
begin
  FValue := Value;
  FTokenType := TokenType;
  FLine := Line;
  FPos := Pos;
end;

destructor TToken.Destroy;
begin
  inherited;
end;

function TToken.GetPosition: string;
begin
  Result := '[' + IntToStr(FLine) + ', ' + IntToStr(FPos) + ']';
end;

end.
