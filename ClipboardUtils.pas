unit ClipboardUtils;

interface

uses
  Windows, Forms, Messages, SysUtils, Classes, clipbrd;

//function ClearClipboard: Boolean;
//procedure SaveClipboardToFile(FileName: TFileName);
//procedure LoadClipboardFromFile(FileName: TFileName);

implementation

type
  TMemoryStreamEx = class(TMemoryStream)
  public
    procedure WriteInteger(Value: Integer);
    function ReadInteger: Integer;
    procedure WriteBoolean(Value: Boolean);
    function ReadBoolean: Boolean;
    procedure WriteString(Value: string);
    procedure WriteStringEx(Value: array of Char);
    function ReadString: string;
  end;

procedure TMemoryStreamEx.WriteInteger(Value: Integer);
begin
  Write(Value, SizeOf(Value));
end;

function TMemoryStreamEx.ReadInteger: Integer;
begin
  Read(Result, SizeOf(Result));
end;

procedure TMemoryStreamEx.WriteBoolean(Value: Boolean);
begin
  WriteInteger(Integer(Value));
end;

function TMemoryStreamEx.ReadBoolean: Boolean;
begin
  Result := Boolean(ReadInteger);
end;

procedure TMemoryStreamEx.WriteString(Value: string);
var
  StrLength: Integer;
begin
  StrLength := Length(Value);
  WriteInteger(StrLength);
  WriteBuffer(Value[1], StrLength);
end;

procedure TMemoryStreamEx.WriteStringEx(Value: array of Char);
var
  S: string;
begin
  S := Value;
  WriteString(S);
end;

function TMemoryStreamEx.ReadString: string;
var
  StrLength: Integer;
begin
  StrLength := ReadInteger;
  SetLength(Result, StrLength);
  ReadBuffer(Result[1], StrLength);
end;

function ClearClipboard: Boolean;
begin
  OpenClipboard(Application.Handle);
  try
    Result := EmptyClipboard;
  finally
    CloseClipboard;
  end;
end;

procedure SaveClipboardToStream(Stream: TMemoryStreamEx; Format: Integer);
var
  Data: THandle;
  DataPtr: Pointer;
  DataSize: LongInt;
  buff: array[0..127] of Char;
  CustomFormat: Boolean;
begin
  OpenClipboard(Application.Handle);
  try
    Data := GetClipboardData(Format);
    if Data <> 0 then
    begin
      DataPtr := GlobalLock(Data);
      if DataPtr <> nil then
      begin
        DataSize := GlobalSize(Data);
        try
          FillChar(buff, SizeOf(buff), #0);
          CustomFormat := GetClipboardFormatName(Format, @buff, SizeOf(buff)) <> 0;
          Stream.WriteBoolean(CustomFormat);
          if CustomFormat then
            Stream.WriteString(buff) else
              Stream.WriteInteger(Format);
          Stream.WriteInteger(DataSize);
          Stream.WriteBuffer(DataPtr^, DataSize);
        finally
          GlobalUnlock(Data);
        end;
      end;
    end;
  finally
    CloseClipboard;
  end;
end;

procedure SaveClipboardToFile(FileName: TFileName);
var
  I: Integer;
  Stream: TMemoryStreamEx;
begin
  Stream := TMemoryStreamEx.Create;
  try
    for I := 0 to Pred(Clipboard.FormatCount) do
      SaveClipboardToStream(Stream, Clipboard.Formats[I]);
    Stream.SaveToFile(FileName);
  finally
    Stream.Free;
  end;
end;

procedure LoadClipboardFromStream(Stream: TMemoryStreamEx);
var
  Data: THandle;
  DataPtr: Pointer;
  DataSize: LongInt;
  Format: Integer;
  FormatName: string;
  CustomFormat: Boolean;
begin
  OpenClipboard(Application.Handle);
  try
    CustomFormat := Stream.ReadBoolean;
    if CustomFormat then
    begin
      FormatName := Stream.ReadString;
      Format := RegisterClipboardFormat(PChar(FormatName));
    end else
    begin
      Format := Stream.ReadInteger;
    end;
    DataSize := Stream.ReadInteger;
    Data := GlobalAlloc(GMEM_MOVEABLE, DataSize);
    try
      DataPtr := GlobalLock(Data);
      try
        Stream.ReadBuffer(DataPtr^, DataSize);
        SetClipboardData(Format, Data);
      finally
        GlobalUnlock(Data);
      end;
    except
      GlobalFree(Data);
      raise;
    end;
  finally
    CloseClipboard;
  end;
end;

procedure LoadClipboardFromFile(FileName: TFileName);
var
  Stream: TMemoryStreamEx;
begin
  Stream := TMemoryStreamEx.Create;
  try
    Stream.LoadFromFile(FileName);
    Stream.Position := 0;
    ClearClipboard;
    while Stream.Position < Stream.Size do
      LoadClipboardFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

end.
