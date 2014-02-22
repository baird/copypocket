unit processsharedstring;

interface

uses
  SysUtils,
  Classes,
  Windows;

type

  TProcessSharedAnsiString = class
  private
    FIdentifier: AnsiString;
    MappedFileSentry: THandle;
    MappingHandle: THandle;
    function MapView(Count: Int64): Pointer;
    function UnmapView(Ptr: Pointer): Boolean;
    function GetValue: AnsiString;
    procedure SetValue(const Value: AnsiString);
    procedure AcquireMutex;
    procedure ReleaseMutex;
  public
    constructor Create(GlobalName: AnsiString);
    destructor Destroy; override;
    property Value: AnsiString read GetValue write SetValue;
    procedure Lock;
    procedure Unlock;
  end;

implementation

const
  MappedFileSize = 16384;

{ TProcessSharedAnsiString }

procedure TProcessSharedAnsiString.AcquireMutex;
begin
  WaitForSingleObject(MappedFileSentry, INFINITE);
end;

constructor TProcessSharedAnsiString.Create(GlobalName: AnsiString);
begin
  inherited Create;
  MappedFileSentry := CreateMutex(nil, False, '7B31BF45-60D3-4F07-8308-DD7FEC8D065B');
  AcquireMutex;
  try
    MappingHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PAnsiChar(GlobalName));
    if MappingHandle = 0 then
    begin
      MappingHandle := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0,
        MappedFileSize, PAnsiChar(GlobalName));
      SetValue('');
    end;
  finally
    ReleaseMutex;
  end;
  FIdentifier := GlobalName;
end;

destructor TProcessSharedAnsiString.Destroy;
begin
  CloseHandle(MappedFileSentry);
  inherited;
end;

function TProcessSharedAnsiString.GetValue: AnsiString;
var
  P: Pointer;
  J: Integer;
begin
  Result := '';
  AcquireMutex;
  try
    P := MapView(MappedFileSize);
    if P <> nil then
    try
      SetLength(Result, Integer(P^));
      Cardinal(P) := Cardinal(P) + 4;
      for J := 1 to Length(Result) do
      begin
        Result[J] := AnsiChar(P^);
        Cardinal(P) := Cardinal(P) + 1;
      end;
    finally
      UnmapView(P);
    end;
  finally
    ReleaseMutex;
  end;
end;

procedure TProcessSharedAnsiString.Lock;
begin
  AcquireMutex;
end;

function TProcessSharedAnsiString.MapView(Count: Int64): Pointer;
begin
  Result := MapViewOfFile(MappingHandle, FILE_MAP_ALL_ACCESS, 0, 0, Count);
  if Result = nil then
    raise Exception.Create('Could not map view of file: ' + FIdentifier);
end;

procedure TProcessSharedAnsiString.ReleaseMutex;
begin
  Windows.ReleaseMutex(MappedFileSentry);
end;

procedure TProcessSharedAnsiString.SetValue(const Value: AnsiString);
var
  P: Pointer;
  I, J: Integer;
begin
  AcquireMutex;
  try
    P := MapView(MappedFileSize);
    if P <> nil then
    try
      I := Length(Value);
      if I > MappedFileSize - 4 then
        I := MappedFileSize - 4;
      Integer(P^) := I;
      Cardinal(P) := Cardinal(P) + 4;
      for J := 1 to I do
      begin
        AnsiChar(P^) := Value[J];
        Cardinal(P) := Cardinal(P) + 1;
      end;
    finally
      UnmapView(P);
    end;
  finally
    ReleaseMutex;
  end;
end;

procedure TProcessSharedAnsiString.Unlock;
begin
  ReleaseMutex;
end;

function TProcessSharedAnsiString.UnmapView(Ptr: Pointer): Boolean;
begin
  Result := UnmapViewOfFile(Ptr);
end;

end.

