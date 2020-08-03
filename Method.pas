unit Method;

interface

uses
  System.SysUtils;

type
  {$SCOPEDENUMS ON}
  TMethodType = (Undefined, Write, WriteLn);
  {$SCOPEDENUMS OFF}

  TMethod = class
  private
    FMethodType: TMethodType;
  public
    constructor Create;
    destructor Destroy; override;

    property MethodType: TMethodType read FMethodType write FMethodType;

    function Write(Value: string): string; overload;
    function Write(Value: Integer): string; overload;
    function WriteLn(Value: string): string; overload;
    function WriteLn(Value: Integer): string; overload;
  end;

  function WhatIsMethodType(Value: string): TMethodType;

implementation

function WhatIsMethodType(Value: string): TMethodType;
begin
  if Value = 'Write' then
    Result := TMethodType.Write
  else if Value = 'WriteLn' then
    Result := TMethodType.WriteLn
  else
    Result := TMethodType.Undefined;
end;

{ TMethod }

constructor TMethod.Create;
begin

end;

destructor TMethod.Destroy;
begin

  inherited;
end;

function TMethod.Write(Value: string): string;
begin
  Result := Value;
end;

function TMethod.Write(Value: Integer): string;
begin
  Result := IntToStr(Value);
end;

function TMethod.WriteLn(Value: string): string;
begin
  Result := Value + #13#10;
end;

function TMethod.WriteLn(Value: Integer): string;
begin
  Result := IntToStr(Value) + #13#10;
end;

end.
