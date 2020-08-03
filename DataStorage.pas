unit DataStorage;

interface

uses
  System.Generics.Collections, Variable;

type
  TDataStorage = class
  private
    FItems: TDictionary<string, TVariable>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    function ToString: string;

    property Items: TDictionary<string, TVariable> read FItems write FItems;
  end;

implementation

{ TDataStorage }

procedure TDataStorage.Clear;
var
  S: string;
begin
  for S in FItems.Keys do
    FItems.Items[S].Free;
end;

constructor TDataStorage.Create;
begin
  FItems := TDictionary<string, TVariable>.Create;
end;

destructor TDataStorage.Destroy;
begin
  Clear;
  inherited;
end;

function TDataStorage.ToString: string;
var
  S: string;
begin
  for S in FItems.Keys do
    Result := Result + 'Key : ' + S + FItems.Items[S].ToString + #13#10;
end;

end.
