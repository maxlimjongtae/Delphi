unit Scripter;

interface

uses System.SysUtils, Tokenize, TokenList, Conformity, Calculration;

type
  TScripter = class
  private
    FTokenList: TTokenList;
    FTokenize: TTokenize;
    FConformity: TConformity;
    FCalculration: TCalculration;
  public
    constructor Create;
    destructor Destroy; override;

    function Execute(Value: string): string;
  end;

implementation

{ TScripter }

constructor TScripter.Create;
begin
  FTokenize := TTokenize.Create;
  FConformity := TConformity.Create;
  FCalculration := TCalculration.Create;
end;

destructor TScripter.Destroy;
begin
  FTokenize.Free;
  FConformity.Free;
  FCalculration.Free;
  inherited;
end;

function TScripter.Execute(Value: string): string;
begin
  FTokenList := FTokenize.Execute(Value);

  Result := FTokenize.ToString + sLineBreak;

  if not FConformity.Execute(FTokenList) then
//    raise Exception.Create('Error Message');
//
//  Result := Result + FCalculration.Execute(FTokenList);
end;

end.
