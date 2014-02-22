unit VisualClipboard;

interface

uses
  Windows, Forms, Messages, SysUtils, Classes, Graphics, Controls, clipbrd;

type

  TVisualClipboard = class(TGraphicControl)
  private
    FStream: TMemoryStream;
    FDisplayString: WideString;
    FDataTypeAsString: WideString;
    FDisplayStringNeedsUpdate: Boolean;
    FCaption: WideString;
    procedure SetCaption(const Value: WideString);
  protected
    procedure Paint; override;
    function DisplayString: WideString;
    procedure UpdateDisplayString;
  public
    DumpFile: String;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;
    procedure CopyClipboardFrom(AVisualClipboard: TVisualClipboard);
    procedure SaveToFile(FileName: TFileName);
    procedure LoadFromFile(FileName: TFileName);
    procedure CopyFromClipboard;
    procedure PasteToClipboard;
  published
    property Caption: WideString read FCaption write SetCaption;
    property DragKind;
    property DragCursor;
    property DragMode;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
  end;

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
  if GetOpenClipboardWindow() <> 0 then
    Exit;
  OpenClipboard(Application.Handle);
  //ClipBrd.Clipboard.Open;
  try
    Result := EmptyClipboard;
  finally
    CloseClipboard;
  //  ClipBrd.Clipboard.Close;
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
  if GetOpenClipboardWindow() <> 0 then
    Exit;
  OpenClipboard(Application.Handle);
  //ClipBrd.Clipboard.Open;
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
  //  ClipBrd.Clipboard.Close;
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
  if GetOpenClipboardWindow() <> 0 then
    Exit;
  OpenClipboard(Application.Handle);
  //ClipBrd.Clipboard.Open;
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
  // / ClipBrd.Clipboard.Close;
  end;
end;

procedure DrawNiceFrame(ACanvas: TCanvas; var ARect: TRect; AFaceColor,
  AFrameColor, ABackColor: TColor; AFrameSize: Integer);
var
  I: Integer;
begin
  ACanvas.Brush.Color := ABackColor;
  ACanvas.FillRect(Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Top + 15));
  ACanvas.Brush.Color := AFrameColor;
  ACanvas.Pen.Color := AFrameColor;
  ACanvas.MoveTo(ARect.Left + 5, ARect.Top); ACanvas.LineTo(ARect.Right - 5, ARect.Top);
  ACanvas.MoveTo(ARect.Left + 3, ARect.Top + 1); ACanvas.LineTo(ARect.Right - 3, ARect.Top + 1);
  ACanvas.MoveTo(ARect.Left + 2, ARect.Top + 2); ACanvas.LineTo(ARect.Right - 2, ARect.Top + 2);
  ACanvas.MoveTo(ARect.Left + 1, ARect.Top + 3); ACanvas.LineTo(ARect.Right - 1, ARect.Top + 3);
  ACanvas.MoveTo(ARect.Left + 1, ARect.Top + 4); ACanvas.LineTo(ARect.Right - 1, ARect.Top + 4);
  ACanvas.Rectangle(Rect(ARect.Left, ARect.Top + 5, ARect.Right, ARect.Top + 15));
  ACanvas.Pen.Width := 1;
  ACanvas.Brush.Color := AFaceColor;
  ARect.Top := ARect.Top + 15;
  if AFrameSize > 0 then
  begin
    ACanvas.Pen.Color := AFrameColor;
    ACanvas.Rectangle(ARect);
    InflateRect(ARect, -1, -1);
    for I := 1 to AFrameSize do
    begin
      ACanvas.Brush.Color := AFrameColor;
      ACanvas.FrameRect(ARect);
      InflateRect(ARect, -1, -1);
    end;
  end;
end;

{ TVisualClipboard }

procedure TVisualClipboard.CopyClipboardFrom(AVisualClipboard: TVisualClipboard);
begin
  if Assigned(AVisualClipboard) then
  begin
    FreeAndNil(FStream);
    FStream := TMemoryStreamEx.Create;
    AVisualClipboard.FStream.Position := 0;
    FStream.Size := AVisualClipboard.FStream.Size;
    FStream.CopyFrom(AVisualClipboard.FStream, AVisualClipboard.FStream.Size);
    FDisplayStringNeedsUpdate := True;
    Invalidate;
    Update;
  end;
end;

procedure TVisualClipboard.CopyFromClipboard;
var
  I: Integer;
begin
  FreeAndNil(FStream);
  FStream := TMemoryStreamEx.Create;
  for I := 0 to Pred(Clipboard.FormatCount) do
    SaveClipboardToStream(TMemoryStreamEx(FStream), Clipboard.Formats[I]);
  FDisplayStringNeedsUpdate := True;
end;

constructor TVisualClipboard.Create(AOwner: TComponent);
begin
  inherited;
  FStream := TMemoryStreamEx.Create;
  FDisplayString := '';
  FDisplayStringNeedsUpdate := False;
end;

destructor TVisualClipboard.Destroy;
begin
  if Assigned(FStream) then
    FreeAndNil(FStream);
end;

function TVisualClipboard.DisplayString: WideString;
begin
  if FDisplayStringNeedsUpdate then
    UpdateDisplayString;
  FDisplayStringNeedsUpdate := False;
  Result := FDisplayString;
end;

procedure TVisualClipboard.LoadFromFile(FileName: TFileName);
begin
  FStream.LoadFromFile(FileName);
  FDisplayStringNeedsUpdate := True;
end;

procedure TVisualClipboard.Paint;
var
  r1: TRect;
  w: WideString;
begin
  inherited;
  r1 := ClientRect;
  DrawNiceFrame(Canvas, r1, clWindow, 14914662, clWindow, 3);
  InflateRect(r1, -3, -3);
  w := DisplayString;
  Canvas.Brush.Color := clWindow;
  Canvas.Font.Color := clDkGray;
  DrawTextExW(Canvas.Handle, PWideChar(w), Length(w), r1, DT_END_ELLIPSIS, nil);
  r1 := Rect(12, 2, ClientWidth - 12, 15);
  Canvas.Brush.Color := 14914662;
  Canvas.Font.Color := clWhite;
  w := FCaption + '   ' + FDataTypeAsString;
  DrawTextExW(Canvas.Handle, PWideChar(w), Length(w), r1, DT_END_ELLIPSIS, nil);
end;

procedure TVisualClipboard.PasteToClipboard;
begin
  ClearClipboard;
  FStream.Position := 0;
  while FStream.Position < FStream.Size do
    LoadClipboardFromStream(TMemoryStreamEx(FStream));
end;

procedure TVisualClipboard.SaveToFile(FileName: TFileName);
begin
  FStream.SaveToFile(FileName);
end;

procedure TVisualClipboard.SetCaption(const Value: WideString);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Invalidate;
  end;
end;

procedure TVisualClipboard.UpdateDisplayString;

  procedure ProcessClipboardFormat(Stream: TMemoryStreamEx);
  var
    DataSize: LongInt;
    Format: Integer;
    FormatName: string;
    CustomFormat: Boolean;
    AAnsiString: AnsiString;
  begin
    CustomFormat := Stream.ReadBoolean;
    if CustomFormat then
    begin
      FormatName := Stream.ReadString;
      FDisplayString := FDisplayString + FormatName + #13#10;
      DataSize := Stream.ReadInteger;
      Stream.Position := FStream.Position + DataSize;
    end
    else
    begin
      Format := Stream.ReadInteger;
      DataSize := Stream.ReadInteger;
      case Format of
        {CF_TEXT,} CF_OEMTEXT: begin
          if DataSize > 256 then
          begin
            SetLength(AAnsiString, 256);
            Stream.ReadBuffer((@AAnsiString[1])^, 256);
            FDisplayString := FDisplayString + AAnsiString + #13#10;
            DataSize := DataSize - 256;
          end
          else
          begin
            SetLength(AAnsiString, DataSize);
            Stream.ReadBuffer((@AAnsiString[1])^, DataSize);
            FDisplayString := FDisplayString + AAnsiString + #13#10;
            DataSize := 0;
          end;
          if FDataTypeAsString <> 'Bitmap' then
            FDataTypeAsString := 'Text';
        end;
        CF_BITMAP,CF_DIB: FDataTypeAsString := 'Bitmap';
        //CF_DIB: FDataTypeAsString := 'Bitmap';
        {CF_BITMAP: FDisplayString := FDisplayString + 'CF_BITMAP' + #13#10;
        CF_METAFILEPICT: FDisplayString := FDisplayString + 'CF_METAFILEPICT' + #13#10;
        CF_SYLK: FDisplayString := FDisplayString + 'CF_SYLK' + #13#10;
        CF_DIF: FDisplayString := FDisplayString + 'CF_DIF' + #13#10;
        CF_TIFF: FDisplayString := FDisplayString + 'CF_TIFF' + #13#10;
        CF_OEMTEXT: begin
        end;
        CF_DIB: FDisplayString := FDisplayString + 'CF_DIB' + #13#10;
        CF_PALETTE: FDisplayString := FDisplayString + 'CF_PALETTE' + #13#10;
        CF_PENDATA: FDisplayString := FDisplayString + 'CF_PENDATA' + #13#10;
        CF_RIFF: FDisplayString := FDisplayString + 'CF_RIFF' + #13#10;
        CF_WAVE: FDisplayString := FDisplayString + 'CF_WAVE' + #13#10;
        CF_UNICODETEXT: begin
          if DataSize > 512 then
          begin
            SetLength(AWideString, 256);
            Stream.ReadBuffer((@AAnsiString[1])^, 2*256);
            FDisplayString := FDisplayString + AWideString + #13#10;
            DataSize := DataSize - 2*256;
          end
          else
          begin
            SetLength(AWideString, DataSize);
            Stream.ReadBuffer((@AWideString[1])^, DataSize);
            FDisplayString := FDisplayString + AWideString + #13#10;
            DataSize := 0;
          end;
        end;
        CF_ENHMETAFILE: FDisplayString := FDisplayString + 'CF_ENHMETAFILE' + #13#10;
        CF_HDROP: FDisplayString := FDisplayString + 'CF_HDROP' + #13#10;
        CF_LOCALE: FDisplayString := FDisplayString + 'CF_LOCALE' + #13#10;
        CF_MAX: FDisplayString := FDisplayString + 'CF_MAX' + #13#10; }
      else
        // FDisplayString := FDisplayString + 'CF_UNKNOWN' + #13#10;
      end;
      FStream.Position := FStream.Position + DataSize;
    end;
  end;

begin
  FDisplayString := '';
  FStream.Position := 0;
  FDataTypeAsString := '';
  while FStream.Position < FStream.Size do
    ProcessClipboardFormat(TMemoryStreamEx(FStream));
  if (Pos('FileName', FDisplayString) > 0)and(Pos('FileNameW', FDisplayString) > 0)and(Pos('Ole Private Data', FDisplayString) > 0) then
  begin
    FDisplayString := '[File]';
    FDataTypeAsString := 'Explorer';
  end;
  Hint := FDisplayString;
  ShowHint := Length(FDisplayString) > 0;
end;

end.
