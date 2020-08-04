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
    constructor Create;
    destructor Destroy; override;

    function Execute(TokenList: TTokenList): Boolean;
  end;

implementation

{ TConformity }

function TConformity.Execute(TokenList: TTokenList): Boolean;
begin
  TokenList.First;
  FTokenList := TokenList;

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
  else
    FCurrentState := FinalState;
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
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  case FTokenList.CurrentToken.TokenType of
    TTokenType.Variable, TTokenType.Value :
    begin
    end;
    TTokenType.SingleQuote :
    begin
      FTokenList.Next;

      if FTokenList.CurrentToken.TokenType = TTokenType.SingleQuote then
      begin
         FTokenList.Next;
         FCurrentState := BranchState;
         Exit;
      end;

      FTokenList.Next;

      if FTokenList.CurrentToken.TokenType <> TTokenType.SingleQuote then
        raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));
    end
    else raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));
  end;

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Bracket then
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.SemiColon then
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TConformity.ReservedState: Boolean;
var
  Token: TToken;
begin
  Result := False;
  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  if not VariableSyntaxCheck(FTokenList.CurrentToken.Value) then
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Colon then
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.VariableType then
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

  Token := FTokenList.CurrentToken;

  FTokenList.Next;

  case FTokenList.CurrentToken.TokenType of
    TTokenType.Space:
    begin
      FTokenList.Next;

      if FTokenList.CurrentToken.TokenType <> TTokenType.Equal then
        raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

      FTokenList.Next;

      if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
        raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

      FTokenList.Next;

      case FTokenList.CurrentToken.TokenType of
        TTokenType.SingleQuote:
        begin
          FTokenList.Next;

          if FTokenList.CurrentToken.TokenType <> TTokenType.Value then
            raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

          FTokenList.Next;

          if FTokenList.CurrentToken.TokenType <> TTokenType.SingleQuote then
            raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

          FTokenList.Next;
        end;
        TTokenType.Value:
        begin
          FTokenList.Next;
        end
        else
          raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));
      end;
    end;
    TTokenType.SemiColon:
    begin
    end
    else
      raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));
  end;

  if FTokenList.CurrentToken.TokenType <> TTokenType.SemiColon then
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

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

  if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Equal then
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
    raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

  FTokenList.Next;

  repeat

    case FTokenList.CurrentToken.TokenType of
      TTokenType.SingleQuote :
      begin
        FTokenList.Next;
        FTokenList.Next;

        if FTokenList.CurrentToken.TokenType <> TTokenType.SingleQuote then
          raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));
      end;
      TTokenType.Variable, TTokenType.Value, TTokenType.Operator:
      begin
      end;
      else
        raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));
    end;

    FTokenList.Next;

    if FTokenList.CurrentToken.TokenType = TTokenType.Semicolon then
      Break;

    if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
      raise Exception.Create(Format('%s Syntax Error!',[FTokenList.CurrentToken.GetPosition]));

    FTokenList.Next;

  until not FTokenList.CanNext;

  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TConformity.VariableSyntaxCheck(S: string): Boolean;
begin
  Result := TRegEx.IsMatch(S,'[a-zA-Z]');
end;

constructor TConformity.Create;
begin

end;

destructor TConformity.Destroy;
begin
  inherited;
end;

end.
