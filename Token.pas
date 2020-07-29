unit Token;

interface

type
  {$SCOPEDENUMS ON}
  TTokenType = (None, ReservedWord, Variable, VariableType, Space, Colon, SemiColon, Value, Equal, SingleQuote, &Operator, Return);
  {$SCOPEDENUMS OFF}

  TToken = class
  private
    FValue: string;
    FTokenType: TTokenType;
  public
    constructor Create;
    destructor Destroy; override;

    property Value: string read FValue write FValue;
    property TokenType: TTokenType read FTokenType write FTokenType;
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
  else if Value = #13#10 then
    Result := TTokenType.Return
  else if (Value = '+') or (Value = '-') or (Value = '*') or (Value = '/') then
    Result := TTokenType.Operator
  else
    Result := TTokenType.Variable;
end;

constructor TToken.Create;
begin

end;

destructor TToken.Destroy;
begin
  inherited;
end;

end.
