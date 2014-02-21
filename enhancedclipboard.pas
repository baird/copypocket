unit EnhancedClipboard;

{
  Examples:

  1) Example of event handler:

     Procedure TGridLayout.EnhancedClipboardChange(Sender: TComponent;
                                                   Clipboard: TClipboard; FormatsAvailable: TList;
                                                   var NotifyOtherApplications: Boolean);
     begin
        if FormatsAvailable.IndexOf(Pointer(CF_TEXT)) > -1 then
           MyAction.Enabled := true
        else
           MyAction.Enabled := false;
     end;

  2) Example of copying to the clip board. We will copy a string.
        if Length(MyString) > 0 then
           EnhancedClipboard.CopyDataToClipboard(CF_TEXT, Pointer(MyString), length(MyString)-1);

  3) Example of pasting from the clipboard. We will use CF_TEXT;

     if (EnhancedClipboard.Clipboard.HasFormat(CF_TEXT)) then
     begin
        Size := EnhancedClipboard.DataSize(CF_TEXT);
        if (Size > 0) then
        begin
           SetLength(MyString, Size);
           EnhancedClipboard.CopyDataFromClipboard(CF_TEXT, Pointer(MyString), Size);

           ProcessMyString(MyString);
        end;
     end;

--  OutStanding issue, doest read clip board on create cause onchange isnt assigned.
}

interface

uses
  Windows, Messages, SysUtils, Classes, clipbrd;

type
  TEnhClipboardNotifyProc = Procedure(Sender: TComponent;
                                      Clipboard: TClipboard;
                                      FormatsAvailable: TList;
                                      var NotifyOtherApplications: boolean) of object;

  TEnhancedClipboard = class(TComponent)
  private
    FNextInChain: THandle;
    FOnChange: TEnhClipboardNotifyProc;
    FHandle: HWND;
    FNotifyOnChange: boolean;
    procedure WndProc(var Msg: TMessage);
  protected
    procedure WMDrawClipboard(var Msg: TWMDrawClipboard); {message WM_DrawClipboard;}
    procedure WMChangeCBChain(var Msg: TWMChangeCBChain); {message WM_ChangeCBChain;}
    procedure SetNotifyOnChange(Value: Boolean);
    function  GetClipBoard: TCLipboard;
    function  GetFormatsAsList: TList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   CopyDataToClipboard(Format: word; Data: Pointer; Size: Longint);
    function    DataSize(Format: word): longint;
    function    CopyDataFromClipboard(Format: word; Data: Pointer; Size: longint): Pointer;
  published
    property NotifyOnChange: boolean read FNotifyOnChange write SetNotifyOnChange;
    property OnChange: TEnhClipboardNotifyProc read FOnChange write FOnChange;
    property Clipboard: TClipboard read GetClipBoard;
  end;

procedure Register;

implementation

uses
  Forms, Math;

function GetErrorStr: PChar;
var
  lpMsgBuf: Pointer;
begin
   FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
     nil, GetLastError(), 0, @lpMsgBuf, 0, nil);
   Result := PChar(lpMsgBuf);
end;

constructor TEnhancedClipboard.Create(AOwner: TComponent);
var
  Msg: TWMDRAWCLIPBOARD;
begin
  inherited Create(AOwner);
  { Allocate a window Handle for messages }
  FHandle := Classes.AllocateHWnd(WndProc);
  { Update the app about whats on the clip board now we wont be notified
    until a change occurs }
  with ClipBrd.Clipboard do
  try
    Open;
    if ClipBrd.Clipboard.FormatCount > 0 then
      WMDrawClipboard(Msg);
  finally
    Close;
  end;
end;

destructor TEnhancedClipboard.Destroy;
begin
  Classes.DeAllocateHWnd(FHandle);
  inherited Destroy;
end;

procedure TEnhancedClipboard.WMDrawClipboard(var Msg: TWMDrawClipboard);
var
  Formats: TList;
  NotifyOtherApps: Boolean;
begin
  Formats := nil;
  if Assigned(OnChange) then
  begin
    try
      { Get all the formats as a set }
      Formats := GetFormatsAsList;
      { Set the  notify other apps to true by default }
      NotifyOtherApps := true;
      { Trigger the Event }
      OnChange(Self, Clipboard, Formats, NotifyOtherApps);
      if (NotifyOtherApps) and (FNextInChain <> 0) then
        PostMessage(FNextInChain, WM_DrawClipboard, 0, 0);
    finally
      Formats.Free;
    end;
  end;
  inherited;
end;

procedure TEnhancedClipboard.WMChangeCBChain(var Msg: TWMChangeCBChain);
begin
  with Msg do
  begin
    if FNextInChain = Remove then
      FNextInChain := Next
    else
      if FNextInChain <> 0 then
        PostMessage(FNextInChain, WM_ChangeCBChain, Remove, Next);
  end;
  inherited;
end;

procedure TEnhancedClipboard.SetNotifyOnChange(Value: boolean);
begin
  Assert(FHandle > 0, 'Handle must never be 0. Please Assign a handle or left the application handle default in');
  FNotifyOnChange := Value;
  if (FNotifyOnChange) then
  begin
    if not (csDesigning in ComponentState) then
      FNextInChain := SetClipboardViewer(FHandle)
  end
  else
    ChangeClipboardChain(FHandle, FNextInChain);
end;

function TEnhancedClipboard.GetFormatsAsList: TList;
var i: longint;
begin
   Result := TList.Create;
   with Result do
   begin
      Capacity := ClipBrd.Clipboard.FormatCount;
      for i := 0 to Capacity do
          Result.Add(Pointer(ClipBrd.Clipboard.Formats[i]));
   end;
end;

function TEnhancedClipboard.GetClipBoard: TClipboard;
begin
  Result := clipbrd.Clipboard;
end;

procedure TEnhancedClipboard.CopyDataToClipboard(Format: word; Data: pointer; Size: longint);
var ClipData: THandle;
begin
   ClipData := 0;
   Assert(Data <> nil, 'You must provide a preallocated pointer');
   Assert(Size > 0, 'You must specify the size of the memory block pointer to by Data');
   Assert(Format > 0, 'You must provide a valid format');
   with ClipBrd.Clipboard do
   try
     Open;
     try
       try
         ClipData := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, Size);
         Move(Data^, GlobalLock(ClipData)^, Size);
         SetAsHandle(Format, ClipData);
       finally
         if ClipData <> 0 then
            GlobalUnlock(ClipData);
       end;
     except
       if ClipData <> 0 then
          GlobalFree(ClipData);
       raise;
     end;
   finally
     Close;
   end;
end;

function TEnhancedClipboard.DataSize(Format: Word): Longint;
var
  ClipData: THandle;
  Flags: longint;
begin
  Result := 0;
  Assert(Format > 0, 'You must provide a valid format');
  with ClipBrd.Clipboard do
  begin
    try
      Open;
      if HasFormat(Format) then
      begin
        ClipData := GetAsHandle(Format);
        Flags := GlobalFlags(ClipData);
        if not (Flags and GMEM_DISCARDED = GMEM_DISCARDED) then
          Result := GlobalSize(ClipData);
      end;
    finally
      Close;
    end;
  end;
end;

function TEnhancedClipboard.CopyDataFromClipboard(Format: Word; Data: Pointer; Size: Longint): Pointer;
var
  ClipData: THandle;
  ClipDataSize, BufferSize, Flags: Longint;
begin
  Result := nil;
  Assert(Data <> nil, 'You must provide a preallocated pointer');
  Assert(Size > 0, 'You must specify the size of the memory block pointer to by Data');
  Assert(Format > 0, 'You must provide a valid format');
  with ClipBrd.Clipboard do
  begin
    try
      Open;
      if HasFormat(Format) then
      begin
        ClipData := GetAsHandle(Format);
        Flags := GlobalFlags(ClipData);
        if not (Flags AND GMEM_DISCARDED = GMEM_DISCARDED) then
          ClipDataSize := GlobalSize(ClipData)
        else
          raise Exception.Create('Clipboard Data Invalid');
        BufferSize := Min(Size, ClipDataSize);
        try
          Move(GlobalLock(ClipData)^, Data^, BufferSize);
        finally
          GlobalUnlock(ClipData);
        end;
      end
      else
        raise Exception.Create('Format not availble on clipboard');
    finally
      Close;
    end;
  end;
end;

procedure TEnhancedClipboard.WndProc(var Msg: TMessage);
var
  WMDrawClipboardMsg: TWMDrawClipboard absolute Msg;
  WMChangeCBChainMsg: TWMChangeCBChain absolute Msg;
begin
  case Msg.Msg of
    WM_DRAWCLIPBOARD: WMDrawClipboard(WMDrawClipboardMsg);
    WM_CHANGECBCHAIN: WMChangeCBChain(WMChangeCBChainMsg);
  else
    DefWindowProc(FHandle, Msg.Msg, Msg.WParam, Msg.LParam);
  end;
end;

procedure Register;
begin
  RegisterComponents('Utils', [TEnhancedClipboard]);
end;

end.
