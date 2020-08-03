unit Variable;

interface

uses
  System.SysUtils, System.TypInfo, System.Classes, System.Variants;

type
  {$SCOPEDENUMS ON}
  TVariableType = (None, Integer, &string);
  {$SCOPEDENUMS OFF}

  TVariable = class
  private
    FValue: Variant;
    FVariableType: TVariableType;
  public
    constructor Create(Value: Variant; VariableType: TVariableType);
    destructor Destroy; override;

    function ToString: string;

    property Value: Variant read FValue write FValue;
    property VariableType: TVariableType read FVariableType write FVariableType;
  end;

  function WhatIsVariableType(Value: string): TVariableType;
  function WhatIsValueType(Value: string): TVariableType;

implementation

function WhatIsValueType(Value: string): TVariableType;
var
  I: Integer;
begin
  if TryStrToInt(Value,I) then
    Result := TVariableType.Integer
  else
    Result := TVariableType.string;
end;

function WhatIsVariableType(Value: string): TVariableType;
begin
  if Value = 'Integer' then
    Result := TVariableType.Integer
  else if Value = 'string' then
    Result := TVariableType.string;
end;

{ TVariable }

constructor TVariable.Create(Value: Variant; VariableType: TVariableType);
begin
  FValue := Value;
  FVariableType := VariableType;
end;

destructor TVariable.Destroy;
begin
  inherited;
end;

function TVariable.ToString: string;
begin
  Result := '[Value]: ' + VarToStr(FValue) + ' [VariableType]: ' + GetEnumName(Typeinfo(TVariableType),Ord(FVariableType)) ;
end;

end.
