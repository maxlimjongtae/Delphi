unit TokenList;

interface

uses
  Token, System.SysUtils;

type
  TTokenList = class
  private
    FTokenList: TArray<TToken>;
    FIndex: Integer;

    function GetItmes(index: Integer): TToken;
    procedure SetItems(index: Integer; const Token: TToken);
  public
    constructor Create;
    destructor Destroy; override;

    function Count: Integer;
    function CanNext: Boolean;
    function CurrentToken: TToken;

    procedure Add(Token: TToken); overload;
    procedure Add(Value: string; TokenType: TTokenType); overload;
    procedure Delete(Index: Integer);
    procedure Clear;
    procedure Next;

    property Items[index : Integer] : TToken read GetItmes write SetItems;
  end;
implementation

{ TTokenList }

procedure TTokenList.Add(Token: TToken);
begin
  SetLength(FTokenList, Length(FTokenList) + 1);
  FTokenList[High(FTokenList)] := Token;
end;

procedure TTokenList.Add(Value: string; TokenType: TTokenType);
begin
  SetLength(FTokenList, Length(FTokenList) + 1);
  FTokenList[High(FTokenList)] := TToken.Create(Value, TokenType);
end;

function TTokenList.CanNext: Boolean;
begin
  Result := Length(FTokenList) >= FIndex;
end;

procedure TTokenList.Clear;
var
  I: Integer;
begin
  for I := Low(FTokenList) to High(FTokenList) do
    FTokenList[I].Free;

  SetLength(FTokenList, 0);
  FIndex := 0;
end;

function TTokenList.Count: Integer;
begin
  Result := Length(FTokenList);
end;

constructor TTokenList.Create;
begin
  FIndex := 0;
end;

function TTokenList.CurrentToken: TToken;
begin
  if FTokenList[FIndex] <> nil then
    Result := FTokenList[FIndex]
  else
    raise Exception.Create('Token not found!');
end;

procedure TTokenList.Delete(Index: Integer);
var
  I: Integer;
begin
  if Length(FTokenList) > Index then
  begin
    FTokenList[Index].Free;

    for I := Index to Length(FTokenList) - 1 do
      FTokenList[I] := FTokenList[I + 1];

    SetLength(FTokenList, Length(FTokenList) - 1);
  end;
end;

destructor TTokenList.Destroy;
begin
  Clear;
  inherited;
end;

function TTokenList.GetItmes(index: Integer): TToken;
begin
  if Length(FTokenList) > Index then
    Result := FTokenList[Index]
  else
    Result := nil;
end;

procedure TTokenList.Next;
begin
  if CanNext then
    Inc(FIndex);
end;

procedure TTokenList.SetItems(index: Integer; const Token: TToken);
begin
  if Length(FTokenList) > Index then
    FTokenList[Index] := Token;
end;

end.
