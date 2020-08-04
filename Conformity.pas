unit Conformity; // Check Syntax

interface

uses
  System.RegularExpressions, System.SysUtils, System.Classes,
  System.Generics.Collections, Token, TokenList, Variable, DataStorage,
  Vcl.Dialogs;

type
  TState = function: Boolean of object;

  TConformity = class
  private
    FCurrentState: TState;
    FTokenList: TTokenList;

    function ReservedState: Boolean;
    function VariableState: Boolean;
    function MethodState: Boolean;
    function ReturnState: Boolean;

    function BranchState: Boolean;
    function InitialState: Boolean;
    function FinalState: Boolean;

    function VariableSynTaxCheck(S: string): Boolean;

  public
    constructor Create(TokenList: TTokenList);
    destructor Destroy; override;

    function Execute: Boolean;
  end;

implementation

{ TConformity }

function TConformity.Execute: Boolean;
begin
  FCurrentState := InitialState;

  repeat
    FCurrentState;
  until FCurrentState = FinalState;

  Result := True;
end;

function TConformity.BranchState: Boolean;
begin
  Result := False;

  if FTokenList.CanNext then
  begin
    case FTokenList.CurrentToken.TokenType of
      TTokenType.ReservedWord : FCurrentState := ReservedState;
      TTokenType.Variable : FCurrentState := VariableState;
      TTokenType.Method : FCurrentState := MethodState;
      TTokenType.Return : FCurrentState := ReturnState;
      else FCurrentState := FinalState;
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
var
  S: string;
begin
  Result := False;
  FTokenList.Next;
  S := FTokenList.CurrentToken.Value;

  if WhatIsTokenType(FTokenList.CurrentToken.Value) <> TTokenType.Bracket then
    raise Exception.Create(Format('%s is Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  case WhatIsTokenType(FTokenList.CurrentToken.Value) of
    TTokenType.Variable :
    begin
    end;
    TTokenType.SingleQuote :
    begin
      FTokenList.Next;

      if WhatIsTokenType(FTokenList.CurrentToken.Value) = TTokenType.SingleQuote then
      begin
         FTokenList.Next;
         FCurrentState := BranchState;
         Exit;
      end;

      FTokenList.Next;

      if WhatIsTokenType(FTokenList.CurrentToken.Value) <> TTokenType.SingleQuote then
        raise Exception.Create(Format('%s is Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

    end
    else raise Exception.Create(Format('%s is Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));
  end;

  FTokenList.Next;

  if WhatIsTokenType(FTokenList.CurrentToken.Value) <> TTokenType.Bracket then
    raise Exception.Create(Format('%s is Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  if WhatIsTokenType(FTokenList.CurrentToken.Value) <> TTokenType.SemiColon then
    raise Exception.Create(Format('Syntax Error! %s',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TConformity.ReservedState: Boolean;
begin
  Result := False;

  FTokenList.Next;

  if not VariableSyntaxCheck(FTokenList.CurrentToken.Value) then
    raise Exception.Create(Format('%s is Variable Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  if WhatIsTokenType(FTokenList.CurrentToken.Value) <> TTokenType.Colon then
    raise Exception.Create(Format('%s is Colon Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  if WhatIsTokenType(FTokenList.CurrentToken.Value) <> TTokenType.VariableType then
    raise Exception.Create(Format('%s is VriableType Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  case FTokenList.CurrentToken.TokenType of
    TTokenType.SemiColon:
    begin

    end;
    TTokenType.Equal:
    begin
      FTokenlist.Next;

      case FTokenList.CurrentToken.TokenType of
        TTokenType.SingleQuote :;
        TTokenType.Value: FTokenList.Next;
        else
          raise Exception.Create(Format('%s is Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));
      end;
    end
    else
      raise Exception.Create(Format('Syntax Error! %s',[FTokenList.CurrentToken.GetPosition]));
  end;

  if FTokenList.CurrentToken.TokenType <> TTokenType.SemiColon then
    raise Exception.Create(Format('Syntax Error! %s',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TConformity.ReturnState: Boolean;
begin
  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TConformity.VariableState: Boolean;
begin
  Result := False;

  FTokenList.Next;

  if WhatIsTokenType(FTokenList.CurrentToken.Value) <> TTokenType.Equal then
    raise Exception.Create(Format('Syntax Error! %s',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  repeat
    case WhatIsTokenType(FTokenList.CurrentToken.Value) of
      TTokenType.SingleQuote :
      begin
        FTokenList.Next;
        FTokenList.Next;

        if WhatIsTokenType(FTokenList.CurrentToken.Value) <> TTokenType.SingleQuote then
         raise Exception.Create(Format('SingleQuote Not Found %s',[FTokenList.CurrentToken.GetPosition]));
      end;
      TTokenType.Variable:;
      TTokenType.Value:;
      TTokenType.Operator:;
      else
        raise Exception.Create(Format('Syntax Error! %s',[FTokenList.CurrentToken.GetPosition]));
    end;

    FTokenList.Next;

    if FTokenList.CurrentToken.TokenType = TTokenType.Semicolon then
      Break;

  until not FTokenList.CanNext;

  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TConformity.VariableSyntaxCheck(S: string): Boolean;
begin
  Result := TRegEx.IsMatch(S,'[a-zA-Z]');
end;

constructor TConformity.Create(TokenList: TTokenList);
begin
  TokenList.First;
  FTokenList := TokenList;
end;

destructor TConformity.Destroy;
begin
  inherited;
end;

end.
