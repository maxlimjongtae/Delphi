unit VariableStorage;

interface

uses
  System.SysUtils, System.TypInfo, System.Classes, System.Variants;

type
  {$SCOPEDENUMS ON}
  TVariableType = (None, Integer, &string);
  {$SCOPEDENUMS OFF}

  TVariableStorage = class
  private
    FValue: Variant;
    FVariableType: TVariableType;
  public
    constructor Create(Value: Variant; VariableType: TVariableType);
    destructor Destroy; override;

    function ToString: string;

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

constructor TVariableStorage.Create(Value: Variant; VariableType: TVariableType);
begin
  FValue := Value;
  FVariableType := VariableType;
end;

destructor TVariableStorage.Destroy;
begin
  inherited;
end;

function TVariableStorage.ToString: string;
begin
  Result := '[Value]: ' + VarToStr(FValue) + ' [VariableType]: ' + GetEnumName(Typeinfo(TVariableType),Ord(FVariableType)) ;
end;

end.
