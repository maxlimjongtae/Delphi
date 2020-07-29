unit Variable;

interface

uses System.SysUtils, System.TypInfo, System.Classes, System.Variants;

type
  {$SCOPEDENUMS ON}
  TVariableType = (None, Integer, &string);
  {$SCOPEDENUMS OFF}

  TVariable = class
  private
    FVariable: string; //name
    FValue: Variant;
    FVariableType: TVariableType;
  public
    constructor Create(Variable: string; Value: Variant; VariableType: TVariableType);
    destructor Destroy; override;

    function ToString: string;

    property Variable: string read FVariable write FVariable;
    property Vaule: Variant read FValue write FValue;
    property VariableType: TVariableType read FVariableType write FVariableType;
  end;

  function WhatIsVariableType(Value: string): TVariableType;

implementation

function WhatIsVariableType(Value: string): TVariableType;
begin
  if Value = 'Integer' then
    Result := TVariableType.Integer
  else if Value = 'string' then
    Result := TVariableType.string;
end;

{ TVariable }

constructor TVariable.Create(Variable: string; Value: Variant;
  VariableType: TVariableType);
begin
  FVariable := Variable;
  FValue := Value;
  FVariableType := VariableType;
end;

destructor TVariable.Destroy;
begin
  inherited;
end;

function TVariable.ToString: string;
begin
  Result := '[Variable]: ' + FVariable +' [Value]: ' + VarToStr(FValue) + ' [VariableType]: ' + GetEnumName(Typeinfo(TVariableType),Ord(FVariableType)) ;
end;

end.
