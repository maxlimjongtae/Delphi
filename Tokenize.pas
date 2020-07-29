unit Tokenize;

interface

uses System.SysUtils, System.Classes, System.TypInfo, Token, TokenList;

type
  TTokenize = class
  private
    FTokenList: TTokenList;

    FValue: string;
    FString: string;
    FIndex: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    function Tokenize: TTokenList;
    function CurrentValue: string;
    function CanNext: Boolean;

    function Print: string;

    procedure Next;

    property TokenList: TTokenList read FTokenlist write FTokenList;
    property Value: string read FValue write FValue;
    property Index: Integer read FIndex write FIndex;
  end;

implementation

{ TTokenize }

constructor TTokenize.Create;
begin
  FValue := '';
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

function TTokenize.CanNext: Boolean;
begin
  if FIndex > Length(FValue) then
    Result := False
  else
    Result := True;
end;

procedure TTokenize.Next;
begin
  Inc(FIndex);
end;

function TTokenize.Print: string;
var
  I: Integer;
  TokenList: TTokenList;
  S: string;
begin
  S := '';

  for I := 0 to FTokenList.Count - 1 do
    S := S + FTokenList.Items[I].Value + ' [' + GetEnumName(Typeinfo(TTokenType),Ord(FTokenList.Items[I].FTokenType)) + '] ';

  Result := S;
end;

function TTokenize.Tokenize: TTokenList;
var
  I: Integer;
  S: string;
  Token: TToken;
begin

  Result := TTokenList.Create;
  S := '';

  repeat
    case WhatIsTokenType(CurrentValue) of
      TTokenType.Space:
      begin
        if S <> EmptyStr then
        begin
          Token := TToken.Create;
          Token.FValue := S;
          Token.FTokenType := TTokenType.None;

          Result.Add(Token);

          S := '';
        end;
      end;
      TTokenType.SemiColon:
      begin
        if S <> EmptyStr then
        begin
          Token := TToken.Create;
          Token.FValue := S;
          Token.FTokenType := TTokenType.None;

          Result.Add(Token);

          S := '';
        end;

        Token := TToken.Create;
        Token.FValue := CurrentValue;
        Token.FTokenType := TTokenType.SemiColon;

        Result.Add(Token);
      end;
      TTokenType.Colon:
      begin
        if S <> EmptyStr then
        begin
          Token := TToken.Create;
          Token.FValue := S;
          Token.FTokenType := TTokenType.None;

          Result.Add(Token);

          S := '';
        end;

        Token := TToken.Create;
        Token.FValue := CurrentValue;
        Token.FTokenType := TTokenType.Colon;

        Result.Add(Token);
      end;
      TTokenType.Equal:
      begin
        Token := TToken.Create;
        Token.FValue := CurrentValue;
        Token.FTokenType := TTokenType.Equal;

        Result.Add(Token);
      end;
      TTokenType.Operator:
      begin
        Token := TToken.Create;
        Token.FValue := CurrentValue;
        Token.FTokenType := TTokenType.Operator;

        Result.Add(Token);
      end
      else
      begin
        S := S + CurrentValue;

        if WhatIsTokenType(S) = TTokenType.Return then
        begin
          Token := TToken.Create;
          Token.FValue := S;
          Token.FTokenType := TTokenType.Return;

          Result.Add(Token);

          S := '';
        end;

      end;
    end;

    Next;
  until not CanNext;
end;

end.
