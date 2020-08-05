unit Calculration;

interface

uses
  System.RegularExpressions, System.SysUtils, System.Classes,
  System.Generics.Collections, Tokenize, Token, TokenList, Variable,
  System.Variants, Method;

type
  TState = function: Boolean of object;

  TCalculration = class
  private
    FCurrentState: TState;
    FTokenList: TTokenList;
    FResult: string;
    FDataStorage: TDictionary<string, TVariable>;

    function ReservedState: Boolean;
    function VariableState: Boolean;
    function MethodState: Boolean;
    function ReturnState: Boolean;

    function BranchState: Boolean;
    function InitialState: Boolean;
    function FinalState: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure VariableClear;
    function ToString: string;

    function Execute(TokenList : TTokenList): string;
  end;

implementation

{ TCalculration }

function TCalculration.BranchState: Boolean;
begin
  Result := False;

  if FTokenList.CanNext then
  begin
    case WhatIsTokenType(FTokenList.CurrentToken.Value) of
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

constructor TCalculration.Create;
begin
  FDataStorage := TDictionary<string, TVariable>.Create;
  FResult := '';
end;

destructor TCalculration.Destroy;
begin
  FResult := '';
  VariableClear;
  FDataStorage.Free;
  inherited;
end;

function TCalculration.Execute(TokenList : TTokenList): string;
begin
  TokenList.First;
  FTokenList := TokenList;

  FCurrentState := InitialState;

  repeat
    FCurrentState;
  until FCurrentState = FinalState;

  Result := FResult;
end;

function TCalculration.FinalState: Boolean;
begin
  Result := True;
end;

function TCalculration.InitialState: Boolean;
begin
  if FTokenList.Count = 0 then
    FCurrentState := FinalState
  else
    FCurrentState := BranchState;
end;

function TCalculration.MethodState: Boolean;
var
  MethodName, Values: string;
  Variable: TVariable;
  Method: TMethod;
begin
  Result := False;

  MethodName := FTokenList.CurrentToken.Value;

  FTokenList.Next;
  FTokenList.Next;

  case FTokenList.CurrentToken.TokenType of
    TTokenType.Variable :
    begin

      if not FDataStorage.ContainsKey(FTokenList.CurrentToken.Value) then
        raise Exception.Create(Format('%s is Undefined Variable %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

      Variable := FDataStorage.Items[FTokenList.CurrentToken.Value];
      Values := Variable.Value;
    end;
    TTokenType.SingleQuote :
    begin
      FTokenList.Next;
      Values := Values + FTokenList.CurrentToken.Value;
    end;
    TTokenType.Value:
    begin
      Values := Values + FTokenList.CurrentToken.Value;
    end
    else raise Exception.Create(Format('%s is Syntax Error! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));
  end;

  FTokenList.Next;
  FTokenList.Next;

  Method := TMethod.Create;
  try
    case WhatIsMethodType(MethodName) of
      TMethodType.Write: FResult := FResult + Method.Write(Values);
      TMethodType.WriteLn: FResult := FResult + Method.WriteLn(Values);
      else raise Exception.Create(Format('%s is Undefined Method! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));
    end;
  finally
    Method.Free;
  end;

  FTokenList.Next;
  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TCalculration.ReservedState: Boolean;
var
  S: string;
  Variable: TVariable;
begin
  Result := False;
  S := '';

  FTokenList.Next;
  FTokenList.Next;

  if FDataStorage.ContainsKey(FTokenList.CurrentToken.Value) then
    raise Exception.Create(Format('%s is Duplicate Variable! %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

  S := FTokenList.CurrentToken.Value;
  Variable := TVariable.Create('', TVariableType.None);
  FDataStorage.Add(S, Variable);

  FTokenList.Next;
  FTokenList.Next;
  FTokenList.Next;

  Variable.VariableType := WhatIsVariableType(FTokenList.CurrentToken.Value);
  FDataStorage.AddOrSetValue(S,Variable);

  FTokenList.Next;

  case FTokenList.CurrentToken.TokenType of
    TTokenType.SemiColon:;
    TTokenType.Space:
    begin
      FTokenList.Next;
      FTokenList.Next;
      FTokenList.Next;

      case FTokenList.CurrentToken.TokenType of
        TTokenType.SingleQuote :
        begin
          FTokenList.Next;

          if Variable.VariableType <>  TVariableType.string then
            raise Exception.Create(Format('%s is MissMatch Type',[FTokenList.CurrentToken.Value]));

          Variable.Value := FTokenList.CurrentToken.Value;
          FDataStorage.AddOrSetValue(S,Variable);

          FTokenList.Next;
          FTokenList.Next;
        end;
        TTokenType.Value:
        begin
          if Variable.VariableType <>  TVariableType.Integer then
            raise Exception.Create(Format('%s is MissMatch Type',[FTokenList.CurrentToken.Value]));

          Variable.Value := FTokenList.CurrentToken.Value;
          FDataStorage.AddOrSetValue(S,Variable);
          FTokenList.Next;
        end
        else
          raise Exception.Create(Format('Syntax Error! %s',[FTokenList.CurrentToken.GetPosition]));
      end;
    end
    else
      raise Exception.Create(Format('Syntax Error! %s',[FTokenList.CurrentToken.GetPosition]));
  end;

  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TCalculration.ReturnState: Boolean;
begin
  FTokenList.Next;
  FCurrentState := BranchState;
end;

function TCalculration.ToString: string;
begin
end;

procedure TCalculration.VariableClear;
var
  S: string;
begin
  for S in FDataStorage.Keys do
    FDataStorage.Items[S].Free;
end;

function TCalculration.VariableState: Boolean;
var
  TargetVariable, CurrentVariable : TVariable;
  CurrentTokenValue: string;
  V: Variant;
begin
  Result := False;
  CurrentTokenValue := FTokenList.CurrentToken.Value;
  VarClear(V);

  if not FDataStorage.ContainsKey(FTokenList.CurrentToken.Value) then
    raise Exception.Create(Format('%s is Undefined Variable %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

  TargetVariable := FDataStorage.Items[FTokenList.CurrentToken.Value];

  FTokenList.Next;
  FTokenList.Next;
  FTokenList.Next;
  FTokenList.Next;

  repeat
    case FTokenList.CurrentToken.TokenType of
      TTokenType.Variable:
      begin
        if not FDataStorage.ContainsKey(FTokenList.CurrentToken.Value) then
          raise Exception.Create(Format('%s is Undefined Variable %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

        CurrentVariable := FDataStorage.Items[FTokenList.CurrentToken.Value];

        if CurrentVariable.VariableType <> TargetVariable.VariableType then
          raise Exception.Create(Format('%s is VariableType Missmatch %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

        case TargetVariable.VariableType of
          TVariableType.Integer: V := V + StrToInt(CurrentVariable.Value);
          TVariableType.string: V := V + CurrentVariable.Value;
        end;

      end;
      TTokenType.SingleQuote :
      begin
        FTokenList.Next;

        if TargetVariable.VariableType <> WhatIsValueType(FTokenList.CurrentToken.Value) then
          raise Exception.Create(Format('%s is MissMatch VariableType %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

        case TargetVariable.VariableType of
          TVariableType.Integer: V := V + StrToInt(FTokenList.CurrentToken.Value);
          TVariableType.string: V := V + FTokenList.CurrentToken.Value;
        end;

        FTokenList.Next;
      end;
      TTokenType.Value:
      begin
        if TargetVariable.VariableType <> WhatIsValueType(FTokenList.CurrentToken.Value) then
          raise Exception.Create(Format('%s is MissMatch VariableType %s',[FTokenList.CurrentToken.Value, FTokenList.CurrentToken.GetPosition]));

        case TargetVariable.VariableType of
          TVariableType.Integer: V := V + StrToInt(FTokenList.CurrentToken.Value);
          TVariableType.string: V := V + FTokenList.CurrentToken.Value;
        end;
      end;
      TTokenType.Operator:
      begin

      end;
      else
        raise Exception.Create(Format('Syntax Error! %s',[FTokenList.CurrentToken.GetPosition]));
    end;

    FTokenList.Next;

    if FTokenList.CurrentToken.TokenType = TTokenType.Semicolon then
    begin
      TargetVariable.Value := V;
      FDataStorage.AddOrSetValue(CurrentTokenValue, TargetVariable);
      Break;
    end;

    FTokenList.Next;

  until not FTokenList.CanNext;

  FTokenList.Next;
  FCurrentState := BranchState;
end;

end.
