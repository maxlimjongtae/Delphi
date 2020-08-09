unit Token;

interface

uses
  System.SysUtils, System.RegularExpressions, Variable,
  System.TypInfo;

type
  {$SCOPEDENUMS ON}
  TTokenType = (Undefined, Space, Colon, SemiColon, Equal, SingleQuote,
  &Operator, Return, LeftBracket, RightBracket, &String, Numeric, TheEnd);

  TTokenKeyword = (Undefined, &var, Write, WriteLn);
  {$SCOPEDENUMS OFF}

  TToken = class
  private
    FLine, FPos: Integer;
    FValue: string;
    FTokenType: TTokenType;
  public
    constructor Create(Value: string; TokenType: TTokenType; Line, Pos: Integer);
    destructor Destroy; override;

    function Caret: string;

    property Value: string read FValue;
    property TokenType: TTokenType read FTokenType;
  end;

  function WhatIsTokenType(Value: string): TTokenType;
  function WhatIsTokenKeyword(Value: string): TTokenKeyword;

implementation

{ TToken }

function WhatIsTokenKeyword(Value: string): TTokenKeyword;
begin
  if Value = 'var' then
    Result := TTokenKeyword.var
  else if Value = 'Write' then
    Result := TTokenKeyword.Write
  else if Value = 'WriteLn' then
    Result := TTokenKeyword.WriteLn
  else
    Result := TTokenKeyword.Undefined;
end;

function WhatIsTokenType(Value: string): TTokenType;
begin
  case Value[1] of
    'a'..'z','A'..'Z':
      Result := TTokenType.String;
    '0'..'9' :
      Result := TTokenType.Numeric;
    #8, #32 : // ' '
      Result := TTokenType.Space;
    #13 : // Carriage Return
      Result := TTokenType.Return;
    #40 : // (
      Result := TToKenType.LeftBracket;
    #41 : // )
      Result := TTokenType.RightBracket;
    '+','-','*','/' :
      Result := TTokenType.Operator;
    #58 :
      Result := TTokenType.Colon;
    #59 :
      Result := TTokenType.SemiColon;
    #61 :
      Result := TTokenType.Equal;
    #39 : // '
      Result := TTokenType.SingleQuote;
    #0 :
      Result := TTokenType.TheEnd
    else Result := TTokenType.Undefined;
  end;
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

function TToken.Caret: string;
begin
  Result := '[' + IntToStr(FLine) + ':' + IntToStr(FPos) + ']';
end;

end.
