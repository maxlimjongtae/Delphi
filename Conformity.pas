unit Conformity; // Check Syntax

interface

uses
  System.RegularExpressions, System.SysUtils, System.Classes,
  System.Generics.Collections, Token, TokenList, Variable,
  Vcl.Dialogs;

type
  TState = function: Boolean of object;

  TConformity = class
  private
    FCurrentState: TState;
    FTokenList: TTokenList;

    function StringState: Boolean;
    function ReturnState: Boolean;
    function ReservedWordState: Boolean;
    function MethodState: Boolean;
    function VariableState: Boolean;

    function BranchState: Boolean;
    function InitialState: Boolean;
    function FinalState: Boolean;

    function VariableSynTaxCheck(S: string): Boolean;
    function CurrentTokenValue: string;
    function CurrentTokenType: TTokenType;
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

  case FTokenList.CurrentToken.TokenType of
    TTokenType.String:
      FCurrentState := StringState;

    TTokenType.Return:
      FCurrentState := ReturnState;

    TTokenType.TheEnd:
      FCurrentState := FinalState;

    else FCurrentState := FinalState;
  end;
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
begin
  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.LeftBracket then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;

  case FTokenList.CurrentToken.TokenType of
    TTokenType.String:
    begin
    end;
    TTokenType.SingleQuote:
    begin
      FTokenList.Next;

      if FTokenList.CurrentToken.TokenType = TTokenType.String then
      begin
        FTokenList.Next;

        if FTokenList.CurrentToken.TokenType <> TTokenType.SingleQuote then
          raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));
      end
      else if FTokenList.CurrentToken.TokenType = TTokenType.SingleQuote then
      else
        raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));
    end
    else raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));
  end;

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.RightBracket then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.SemiColon then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TConformity.ReservedWordState: Boolean;
begin
  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.String then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Colon then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.String then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;

  case FTokenList.CurrentToken.TokenType of
    TTokenType.SemiColon:
    begin
    end;
    TTokenType.Space:
    begin
      FTokenList.Next;

      if FTokenList.CurrentToken.TokenType <> TTokenType.Equal then
        raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

      FTokenList.Next;

      if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
        raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

      FTokenList.Next;

      case FTokenList.CurrentToken.TokenType of
        TTokenType.SingleQuote:
        begin
          FTokenList.Next;

          if FTokenList.CurrentToken.TokenType <> TTokenType.String then
            raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

          FTokenList.Next;

          if FTokenList.CurrentToken.TokenType <> TTokenType.SingleQuote then
            raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

          FTokenList.Next;
        end;
        TTokenType.Numeric, TTokenType.String:
        begin
          FTokenList.Next;
        end
        else
          raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));
      end;
    end
    else
      raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));
  end;

  if FTokenList.CurrentToken.TokenType <> TTokenType.SemiColon then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TConformity.StringState: Boolean;
begin
  case WhatIsTokenKeyword(CurrentTokenValue) of
    TTokenKeyword.var:
      FCurrentState := ReservedWordState;

    TTokenKeyword.Write, TTokenKeyword.WriteLn:
      FCurrentState := MethodState;

    else FCurrentState := VariableState;
  end;
end;

function TConformity.ReturnState: Boolean;
begin
  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TConformity.VariableState: Boolean;
begin
  if FTokenList.CurrentToken.TokenType <> TTokenType.String then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Equal then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;

  if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
    raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

  FTokenList.Next;

  repeat
    case FTokenList.CurrentToken.TokenType of
      TTokenType.String, TTokenType.Numeric:
      begin
      end;
      TTokenType.SingleQuote:
      begin
        FTokenList.Next;

        if FTokenList.CurrentToken.TokenType <> TTokenType.String then
          raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

        FTokenList.Next;

        if FTokenList.CurrentToken.TokenType <> TTokenType.SingleQuote then
          raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));
      end
      else
        raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));
    end;

    FTokenList.Next;

    case FTokenList.CurrentToken.TokenType of
      TTokenType.SemiColon:
      begin
        Break;
      end;
      TTokenType.Space:
      begin
        FTokenList.Next;

        if FTokenList.CurrentToken.TokenType <> TTokenType.Operator then
          raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));

        FTokenList.Next;

        if FTokenList.CurrentToken.TokenType <> TTokenType.Space then
          raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));
      end
      else
        raise Exception.Create(Format('%s Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.Caret]));
    end;

    FTokenList.Next;
  until not FTokenList.CanNext;

  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TConformity.VariableSyntaxCheck(S: string): Boolean;
begin
  Result := TRegEx.IsMatch(S,'^[a-zA-Z]+$');
end;

constructor TConformity.Create;
begin

end;

function TConformity.CurrentTokenType: TTokenType;
begin
  Result := FTokenList.CurrentToken.TokenType;
end;

function TConformity.CurrentTokenValue: string;
begin
  Result := FTokenList.CurrentToken.Value;
end;

destructor TConformity.Destroy;
begin
  inherited;
end;

end.
