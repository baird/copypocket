unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls,
  ComCtrls, Dialogs, Menus, Buttons, TrayIconEx, Clipbrd, ClipboardMonitor,
  ClipboardUtils, ExtCtrls, Registry, Encryption, VisualClipboard,
  TntStdCtrls, TntButtons, TntExtCtrls, AppEvnts;

const
  WM_INVOKE = WM_USER + 1;
  WM_TERMINATE = WM_USER + 13245;

type
  TfrmMain = class(TForm)
    HideTimer: TTimer;
    ScrollBox1: TScrollBox;
    DumpTimer: TTimer;
    CopyHotKey: THotKey;
    PasteHotKey: THotKey;
    TntLabel1: TTntLabel;
    TntLabel2: TTntLabel;
    TntLabel3: TTntLabel;
    TntBitBtn1: TTntBitBtn;
    TntBitBtn2: TTntBitBtn;
    TntBitBtn3: TTntBitBtn;
    TntPanel1: TTntPanel;
    TntGroupBox1: TTntGroupBox;
    TntListBox1: TTntListBox;
    TntButton1: TTntButton;
    TntButton2: TTntButton;
    TntEdit1: TTntEdit;
    TntButton3: TTntButton;
    TntLabel5: TTntLabel;
    TntLabel6: TTntLabel;
    TntGroupBox2: TTntGroupBox;
    TntGroupBox3: TTntGroupBox;
    TntCheckBox1: TTntCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    TntLabel7: TTntLabel;
    TntLabel8: TTntLabel;
    txt1: TTntLabel;
    txt2: TTntLabel;
    txt3: TTntLabel;
    TntLabel9: TTntLabel;
    txt4: TTntLabel;
    txt5: TTntLabel;
    TntBitBtn5: TTntBitBtn;
    ApplicationEvents1: TApplicationEvents;
    TntBitBtn4: TTntBitBtn;
    TntBitBtn6: TTntBitBtn;
    TntLabel10: TTntLabel;
    TntBitBtn7: TTntBitBtn;
    TntLabel4: TTntLabel;
    TntLabel11: TTntLabel;
    TntLabel12: TTntLabel;
    TntLabel13: TTntLabel;
    Panel1: TPanel;
    TntLabel14: TTntLabel;
    CopyTimer: TTimer;
    HotKey1: THotKey;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure KeyPress(Sender: TObject; var Key: Char);
    procedure BtnClick(Sender: TObject);
    procedure HideTimerTimer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DumpTimerTimer(Sender: TObject);
    procedure TntBitBtn3Click(Sender: TObject);
    procedure OnClipboardClick(Sender: TObject);
    procedure TntCheckBox1Click(Sender: TObject);
    procedure TntButton3Click(Sender: TObject);
    procedure TntBitBtn2Click(Sender: TObject);
    procedure TntBitBtn1Click(Sender: TObject);
    procedure TntButton2Click(Sender: TObject);
    procedure TntButton1Click(Sender: TObject);
    procedure TntBitBtn4Click(Sender: TObject);
    procedure Edit2Exit(Sender: TObject);
    procedure TntBitBtn5Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure VisualPocketsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure VisualPocketsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TntBitBtn6Click(Sender: TObject);
    procedure VisualClipboardMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VisualClipboardMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VisualClipboardMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure TntBitBtn7Click(Sender: TObject);
    procedure CopyTimerTimer(Sender: TObject);
  private
    TrayIcon: TTrayIconEx;
    PrevForeWindow: THandle;
    ClipToCopyTo: TVisualClipboard;
    ClipToPasteFrom: TVisualClipboard;
    ClipMonitor: TClipboardMonitor;
    PocketVCs: array[0..9]of TVisualClipboard;
    RowVCs: array[0..99]of TVisualClipboard;
    Profile: String;
    DumpingNeeded: Boolean;
    AllowApplicationClose: Boolean;
    LockedX: Integer;
    LockedY: Integer;
    LockedObject: TObject;
    procedure WMInvoke(var M: TMessage); message WM_INVOKE;
    procedure WMTerminate(var M: TMessage); message WM_TERMINATE;
    procedure WMQueryEndSession(var M: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure WMEndSession(var M: TWMEndSession); message WM_ENDSESSION;
    procedure Invoke;
    procedure Uninvoke;
    procedure ClipboardNotify(Sender: TComponent; Clipboard: TClipboard;
      FormatsAvailable: TList; var NotifyOtherApplications: Boolean);
    procedure LoadConfig;
    procedure SaveConfig;
  protected
    procedure HotyKeyMsg(var msg:TMessage); message WM_HOTKEY;
    procedure InitializeProfile(AProfile: String);
    procedure DumpProfile;
    procedure ArrangeVisualClipboards;
    procedure CleanProfile;
    procedure PushClipboard;
  public
    procedure UpdateRunOnStartupView;
    procedure UpdateProfileView;
    procedure UpdateButtons;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

var
  CopyAtom: Integer;
  PasteAtom: Integer;
  OverAtom: Integer;

function AppPath: String;
begin
  Result := ExtractFilePath(Application.ExeName);
  if Result[Length(Result)] <> '\' then
    Result := Result + '\';
end;

procedure SimulateKeyStroke(Key: Word; const Shift: TShiftState;
  SpecialKey: Boolean);
type
  TShiftKeyInfo = record
    Shift: Byte;
    VKey : Byte;
  end;
  ByteSet = set of 0..7;
const
  ShiftKeys: array [1..3] of TShiftKeyInfo =
      ((Shift: Ord(ssCtrl);  VKey: VK_CONTROL),
       (Shift: Ord(ssShift); VKey: VK_SHIFT),
       (Shift: Ord(ssAlt);   VKey: VK_MENU));
var
  flag: DWORD;
  bShift: ByteSet absolute Shift;
  i: Integer;
begin
  for i := 1 to 3 do
  begin
    if ShiftKeys[i].Shift in bShift then
      keybd_event(ShiftKeys[i].VKey, MapVirtualKey(ShiftKeys[i].VKey, 0), 0, 0);
  end;
  flag := 0;
  if SpecialKey then
    flag := KEYEVENTF_EXTENDEDKEY;
  keybd_event(Key, MapVirtualKey(Key, 0), flag, 0);
  flag := flag or KEYEVENTF_KEYUP;
  keybd_event(Key, MapVirtualKey(Key, 0), flag, 0);
  for i := 3 downto 1 do
  begin
    if ShiftKeys[i].Shift in bShift then
      keybd_event(ShiftKeys[i].VKey, MapVirtualKey(ShiftKeys[i].VKey, 0), KEYEVENTF_KEYUP, 0);
  end;
end;

function ShiftStateToModifier(const Shift: TShiftState): Word;
begin
  Result := 0;
  if ssShift in Shift then
    Result := Result or MOD_SHIFT;
  if ssAlt in Shift then
    Result := Result or MOD_ALT;
  if ssCtrl in Shift then
    Result := Result or MOD_CONTROL;
end;

function GetShortCutKey(ShortCut: TShortCut): Word;
var
  Shift: TShiftState;
begin
  ShortCutToKey(ShortCut, Result, Shift); // call in Menus!
end;

function GetShortCutModifier(ShortCut: TShortCut):Word;
var
  Key: Word;
  Shift: TShiftState;
begin
  ShortCutToKey(ShortCut, Key, Shift); // call in Menus!
  Result := ShiftStateToModifier(Shift);
end;

function RegisterHotShortCut(const H: THandle; const Atom: Integer; const ShortCut: TShortCut): Boolean;
var
  Key : Word;
  Shift: TShiftState;
begin
  UnregisterHotKey(H, Atom); // call in Windows
  ShortCutToKey(ShortCut, Key, Shift);
  Result := RegisterHotKey(H, Atom, ShiftStateToModifier(Shift), key);
end;

var
  CryptoChallenge: String;

procedure InitializeCryptoChallenge;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Reg.OpenKey('DXTineOFC.classes', True) then
    begin
      if Reg.ValueExists('challenge') then
        CryptoChallenge := Reg.ReadString('challenge')
      else
      begin
        Randomize;
        CryptoChallenge := IntToStr(Random(8900000) + 1000000);
        Sleep(1000);
        Randomize;
        CryptoChallenge := CryptoChallenge + IntToStr(Random(8900000) + 1000000);
        Reg.WriteString('challenge', CryptoChallenge);
      end;
    end;
  finally
    Reg.Free;
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

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  CopyAtom := GlobalAddAtom(PChar('49FEE95A-C78F-40F3-941D-614150D1B6FD'));
  PasteAtom := GlobalAddAtom(PChar('78E8350B-CFC6-4784-9BB0-397146BE2B30'));
  OverAtom := GlobalAddAtom(PChar('859A0791-98C0-4D9E-8B5D-BD925851D5F8'));
  TrayIcon := TTrayIconEx.Create(Self);
  TrayIcon.OnClick := TrayIconClick;
  ClipMonitor := TClipboardMonitor.Create(Self);
  ClipMonitor.NotifyOnChange := True;
  ClipMonitor.OnChange := ClipboardNotify;
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
  ShowWindow(Application.Handle, SW_SHOW);
  TntLabel3.Caption := TntLabel1.Caption;
  LoadConfig;
  UpdateProfileView;
  UpdateRunOnStartupView;
  Edit1.Text := Encrypt(CryptoChallenge, 9265);
  //if ParamStr(1) = '/startup' then
  //begin
    SetBounds(-1000, Top, Width, Height);
    HideTimer.Tag := 1;
  //end
  //else
    //Position := poScreenCenter;
  RegisterHotShortCut(Handle, CopyAtom, CopyHotKey.HotKey);
  RegisterHotShortCut(Handle, PasteAtom, PasteHotKey.HotKey);
  Height := 185;
  UpdateButtons;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  ClipMonitor.NotifyOnChange := False;
  ClipMonitor.Free;
  TrayIcon.Free;
  UnregisterHotKey(Handle, CopyAtom);
  GlobalDeleteAtom(CopyAtom);
  UnregisterHotKey(Handle, PasteAtom);
  GlobalDeleteAtom(PasteAtom);
  GlobalDeleteAtom(OverAtom);
end;

procedure TfrmMain.ClipboardNotify(Sender: TComponent; Clipboard: TClipboard;
  FormatsAvailable: TList; var NotifyOtherApplications: Boolean);
begin
  NotifyOtherApplications := True;
  if Tag <> 0 then
    Exit;
//  Tag := 1;
//  try
    CopyTimer.Tag := 40;
//  finally
//    Tag := 0;
//  end;
end;

procedure TfrmMain.CopyTimerTimer(Sender: TObject);
begin
  if CopyTimer.Tag = 1 then
  begin
    RegisterHotShortCut(Handle, OverAtom, Hotkey1.HotKey);
    try
      PushClipboard;
      if ClipToCopyTo <> nil then
      begin
        ClipToCopyTo.CopyFromClipboard;
        ClipToCopyTo.SaveToFile(ClipToCopyTo.DumpFile);
      end;
      ClipToCopyTo := nil;
    except
    end;
    UnregisterHotKey(Handle, OverAtom);
  end;
  if CopyTimer.Tag > 0 then
    CopyTimer.Tag := CopyTimer.Tag - 1;
end;

procedure TfrmMain.HotyKeyMsg(var msg: TMessage);
begin
  if (msg.LParamLo = GetShortCutModifier(CopyHotKey.HotKey)) and (msg.LParamHi = GetShortCutKey(CopyHotKey.HotKey)) then
  begin
    TntLabel3.Caption := TntLabel1.Caption;
    Invoke;
  end
  else if (msg.LParamLo = GetShortCutModifier(PasteHotKey.HotKey)) and (msg.LParamHi = GetShortCutKey(PasteHotKey.HotKey)) then
  begin
    TntLabel3.Caption := TntLabel2.Caption;
    Invoke;
  end;
end;

procedure TfrmMain.WMInvoke(var M: TMessage);
begin
  Invoke;
end;

procedure TfrmMain.WMTerminate(var M: TMessage);
begin
  Application.Terminate;
end;

procedure TfrmMain.TrayIconClick(Sender: TObject);
begin
  Invoke;
  SetBounds((Screen.Width - Width) div 2, (Screen.Height - 695) div 2, Width, Height);
end;

procedure TfrmMain.Invoke;
begin
  PrevForeWindow := GetForegroundWindow;
  TntPanel1.Visible := False;
  ShowWindow(Application.Handle, SW_RESTORE);
  Show;
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - 695) div 2;
  SetForegroundWindow(Handle);
  HideTimer.Tag := 0;
end;

procedure TfrmMain.Uninvoke;
begin
  Hide;
  SetForegroundWindow(PrevForeWindow);
end;

procedure TfrmMain.KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(27) then
    Uninvoke;
  if Key in ['4','5','6','7','8','9','0'] then
    if Encrypt(Encrypt(CryptoChallenge, 9265), 45674) <> Edit2.Text then
      Exit;
  if TntLabel3.Caption = TntLabel1.Caption then
  begin
    ClipToCopyTo := nil;
    case Key of
      '1': ClipToCopyTo := PocketVCs[0];
      '2': ClipToCopyTo := PocketVCs[1];
      '3': ClipToCopyTo := PocketVCs[2];
      '4': ClipToCopyTo := PocketVCs[3];
      '5': ClipToCopyTo := PocketVCs[4];
      '6': ClipToCopyTo := PocketVCs[5];
      '7': ClipToCopyTo := PocketVCs[6];
      '8': ClipToCopyTo := PocketVCs[7];
      '9': ClipToCopyTo := PocketVCs[8];
      '0': ClipToCopyTo := PocketVCs[9];
    end;
    if ClipToCopyTo <> nil then
    begin
      Uninvoke;
      SimulateKeyStroke(Ord('C'), [ssCtrl], False);
    end;
  end
  else if TntLabel3.Caption = TntLabel2.Caption then
  begin
    ClipToPasteFrom := nil;
    case Key of
      '1': ClipToPasteFrom := PocketVCs[0];
      '2': ClipToPasteFrom := PocketVCs[1];
      '3': ClipToPasteFrom := PocketVCs[2];
      '4': ClipToPasteFrom := PocketVCs[3];
      '5': ClipToPasteFrom := PocketVCs[4];
      '6': ClipToPasteFrom := PocketVCs[5];
      '7': ClipToPasteFrom := PocketVCs[6];
      '8': ClipToPasteFrom := PocketVCs[7];
      '9': ClipToPasteFrom := PocketVCs[8];
      '0': ClipToPasteFrom := PocketVCs[9];
    end;
    if (ClipToPasteFrom <> nil) then
    begin
      Tag := 1;
      try
        Uninvoke;
        ClipToPasteFrom.PasteToClipboard;
        SimulateKeyStroke(Ord('V'), [ssCtrl], False);
      finally
        Tag := 0;
      end;
    end;
    ClipToPasteFrom := nil;
  end;
end;

procedure TfrmMain.BtnClick(Sender: TObject);
var
  Key: Char;
begin
  Key := Chr(48 + TControl(Sender).Tag);
  KeyPress(Sender, Key);
end;

procedure TfrmMain.HideTimerTimer(Sender: TObject);
begin
//  if GetForegroundWindow <> Handle then
//    Hide;
  if Showing and (HideTimer.Tag > 0) then
  begin
    Hide;
    HideTimer.Tag := 0;
    SetBounds((Screen.Width - Width) div 2, (Screen.Height - 695) div 2, Width, Height);
  end;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmMain.DumpProfile;
var
  I: Integer;
begin
  if not DirectoryExists(AppPath + 'DB\' + Profile + '\') then
    Exit;
  for I := High(RowVCs) downto 0 do
    if RowVCs[I].DumpFile <> '' then
      if not FileExists(RowVCs[I].DumpFile) then
        RowVCs[I].SaveToFile(RowVCs[I].DumpFile);
end;

procedure TfrmMain.InitializeProfile(AProfile: String);
var
  sr: TSearchRec;
  I: Integer;
  sl: TStringList;
begin
  if DumpingNeeded then
    DumpProfile;
  for I := 0 to High(PocketVCs) do
  begin
    if Assigned(PocketVCs[I]) then
      FreeAndNil(PocketVCs[I]);
    PocketVCs[I] := TVisualClipboard.Create(Self);
    PocketVCs[I].OnDragDrop := VisualPocketsDragDrop;
    PocketVCs[I].OnDragOver := VisualPocketsDragOver;
    PocketVCs[I].OnMouseDown := VisualClipboardMouseDown;
    PocketVCs[I].OnMouseMove := VisualClipboardMouseMove;
    PocketVCs[I].OnMouseUp := VisualClipboardMouseUp;
    PocketVCs[I].Caption := IntToStr((I + 1) mod 10);
    PocketVCs[I].Cursor := crHandPoint;
    PocketVCs[I].OnClick := OnClipboardClick;
  end;
  for I := 0 to High(RowVCs) do
  begin
    if Assigned(RowVCs[I]) then
      FreeAndNil(RowVCs[I]);
    RowVCs[I] := TVisualClipboard.Create(Self);
    RowVCs[I].OnDragDrop := VisualPocketsDragDrop;
    //RowVCs[I].OnDragOver := VisualPocketsDragOver;
    RowVCs[I].OnMouseDown := VisualClipboardMouseDown;
    RowVCs[I].OnMouseMove := VisualClipboardMouseMove;
    RowVCs[I].OnMouseUp := VisualClipboardMouseUp;
    RowVCs[I].Cursor := crHandPoint;
    RowVCs[I].OnClick := OnClipboardClick;
  end;
  Profile := AProfile;
  ForceDirectories(AppPath + 'DB\' + Profile + '\');
  for I := 0 to High(PocketVCs) do
  begin
    PocketVCs[I].DumpFile := AppPath + 'DB\' + Profile + '\' + FormatFloat('0000000000', I) + '.pocket';
    if FileExists(PocketVCs[I].DumpFile) then
      PocketVCs[I].LoadFromFile(PocketVCs[I].DumpFile);
  end;
  sl := TStringList.Create;
  if FindFirst(AppPath + 'DB\' + Profile + '\'+ '*.row', faHidden, sr) = 0 then
  begin
    repeat
      if StrToFloatDef(Copy(ExtractFileName(sr.Name), 1, Pos('.', ExtractFileName(sr.Name)) - 1), -1) >= 0 then
        sl.Add(sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  sl.Sort;
  for i := sl.Count - 1 downto 0 do
  begin
    if sl.Count - 1 - i > High(RowVCs) then
      Break;
    RowVCs[sl.Count - 1 - i].DumpFile := AppPath + 'DB\' + Profile + '\' + sl[i];
    RowVCs[sl.Count - 1 - i].LoadFromFile(RowVCs[sl.Count - 1 - i].DumpFile);
  end;
  sl.Free;
  ArrangeVisualClipboards;
  CleanProfile;
end;

procedure TfrmMain.ArrangeVisualClipboards;
var
  I, J, K: Integer;
begin
  for I := 0 to High(PocketVCs) do
  begin
    PocketVCs[I].Parent := Self;
    PocketVCs[I].SetBounds(24 + I*84, 40, 80, 80);
  end;
  for K := 0 to High(RowVCs) do
  begin
    I := K div 10;
    J := K mod 10;
    RowVCs[10*I+J].Parent := ScrollBox1;
    RowVCs[10*I+J].SetBounds(14+J*84 - ScrollBox1.HorzScrollBar.Position, 4+I*84 - ScrollBox1.VertScrollBar.Position, 80, 80);
  end;
end;

procedure TfrmMain.CleanProfile;
var
  sl: TStringList;
  sr: TSearchRec;
  i: Integer;
begin
  if not DirectoryExists(AppPath + 'DB\' + Profile + '\') then
    Exit;
  sl := TStringList.Create;
  if FindFirst(AppPath + 'DB\' + Profile + '\' + '*.row', faHidden, sr) = 0 then
  begin
    repeat
      if StrToFloatDef(Copy(ExtractFileName(sr.Name), 1, Pos('.', ExtractFileName(sr.Name)) - 1), -1) >= 0 then
        sl.Add(sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  sl.Sort;
  for i := 0 to sl.Count - (High(RowVCs) + 2) do
    DeleteFile(AppPath + 'DB\' + Profile + '\' + sl[i]);
  sl.Free;
end;

procedure TfrmMain.PushClipboard;
var
  I: Integer;
begin
  RowVCs[High(RowVCs)].Free;
  for I := High(RowVCs) downto 1 do
    RowVCs[I] := RowVCs[I - 1];
  RowVCs[0] := TVisualClipboard.Create(Self);
  RowVCs[0].OnDragDrop := VisualPocketsDragDrop;
  //RowVCs[0].OnDragOver := VisualPocketsDragOver;
  RowVCs[0].OnMouseDown := VisualClipboardMouseDown;
  RowVCs[0].OnMouseMove := VisualClipboardMouseMove;
  RowVCs[0].OnMouseUp := VisualClipboardMouseUp;
  RowVCs[0].Cursor := crHandPoint;
  RowVCs[0].OnClick := OnClipboardClick;
  if RowVCs[1].DumpFile = '' then
    RowVCs[0].DumpFile := AppPath + 'DB\' + Profile + '\' + '0000000000.row'
  else
    if StrToFloatDef(Copy(ExtractFileName(RowVCs[1].DumpFile), 1, Pos('.', ExtractFileName(RowVCs[1].DumpFile)) - 1), -1) = -1 then
      RowVCs[0].DumpFile :=  AppPath + 'DB\' + Profile + '\' + '0000000000.row'
    else
      RowVCs[0].DumpFile :=  AppPath + 'DB\' + Profile + '\' + FormatFloat('0000000000', StrToFloatDef(Copy(ExtractFileName(RowVCs[1].DumpFile), 1, Pos('.', ExtractFileName(RowVCs[1].DumpFile)) - 1), -1) + 1) + '.row';
  ArrangeVisualClipboards;
  DumpingNeeded := True;
  RowVCs[0].CopyFromClipboard;
end;

procedure TfrmMain.DumpTimerTimer(Sender: TObject);
begin
  if DumpingNeeded then
    DumpProfile;
  DumpingNeeded := False;
end;

procedure TfrmMain.TntBitBtn3Click(Sender: TObject);
begin
  Uninvoke;
end;

procedure TfrmMain.OnClipboardClick(Sender: TObject);
begin
//  Uninvoke;
//  TVisualClipboard(Sender).PasteToClipboard;
//  SimulateKeyStroke(Ord('V'), [ssCtrl], False);
end;

procedure TfrmMain.LoadConfig;
var
  sl: TStringList;
begin
  if FileExists(AppPath + 'config.txt') then
  begin
    sl := TStringList.Create;
    try
      sl.LoadFromFile(AppPath + 'config.txt');
      Edit2.Text := sl.Values['registration_key'];
      InitializeProfile(sl.Values['current_profile']);
    except
      InitializeProfile('default');
    end;
    sl.Free;
  end
  else
    InitializeProfile('default');
end;

procedure TfrmMain.SaveConfig;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Values['current_profile'] := Profile;
    sl.Values['registration_key'] := Edit2.Text;
    sl.SaveToFile(AppPath + 'config.txt');
  except
  end;
  sl.Free;
end;

procedure TfrmMain.UpdateRunOnStartupView;
var
  Reg: TRegistry;
  b: Boolean;
  s: String;
begin
  b := False;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False) then
    begin
      s := LowerCase(Reg.ReadString('CopyPocket'));
      b := s = LowerCase('"' + AppPath + 'CopyPocket.exe" /startup');
    end;
  finally
    Reg.Free;
  end;
  TntCheckBox1.Checked := b;
end;

procedure TfrmMain.TntCheckBox1Click(Sender: TObject);
var
  Reg: TRegistry;
  b: Boolean;
begin
  b := TntCheckBox1.Checked;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False) then
    begin
      if b then
        Reg.WriteString('CopyPocket', LowerCase('"' + AppPath + 'CopyPocket.exe" /startup'))
      else
        Reg.DeleteValue('CopyPocket');
    end;
  finally
    Reg.Free;
  end;
end;

procedure TfrmMain.UpdateProfileView;
var
  sr: TSearchRec;
begin
  TntListBox1.Clear;
  if FindFirst(AppPath + 'DB\*', faDirectory, sr) = 0 then
  begin
    repeat
      if (sr.Name <> '.')and(sr.Name <> '..') then
        TntListBox1.Items.Add(sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  TntLabel6.Caption := Profile;
  Caption := 'Copy Pocket - ' + Profile;
end;

procedure TfrmMain.TntButton3Click(Sender: TObject);
begin
  CreateDir(AppPath + 'DB\' + TntEdit1.Text);
  UpdateProfileView;
  TntEdit1.Text := '';
end;

procedure TfrmMain.TntBitBtn2Click(Sender: TObject);
begin
  TntPanel1.Align := alBottom;
  TntPanel1.Height := ClientHeight - 165;
  TntPanel1.Visible := True;
  UpdateButtons;
end;

procedure TfrmMain.TntBitBtn1Click(Sender: TObject);
begin
  TntPanel1.Visible := False;
  UpdateButtons;
end;

procedure TfrmMain.TntButton2Click(Sender: TObject);

  procedure RemoveTree(RootDir: String);
  var
    SearchRec: TSearchRec;
    Erc: Integer;
  begin
    try
      Erc := FindFirst(RootDir + '*.*', faAnyFile, SearchRec);
      while Erc = 0 do
      begin
        if ((SearchRec.Name <> '.' ) and  (SearchRec.Name <> '..')) then
          if (SearchRec.Attr and faDirectory > 0) then
            RemoveTree(RootDir + SearchRec.Name + '\')
          else
            DeleteFile(RootDir + SearchRec.Name);
        Erc := FindNext(SearchRec);    
      end;
    finally
      FindClose(SearchRec);
      RemoveDir(RootDir);
    end;
  end;

var
  w: WideString;
begin
  if TntListBox1.ItemIndex < 0 then
    Exit;
  if LowerCase(Profile) = TntListBox1.Items[TntListBox1.ItemIndex] then
  begin
    w := txt1.Caption;
    MessageBoxW(Handle, PWideChar(w), '', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;
  w := txt2.Caption;
  if MessageBoxW(Handle, PWideChar(w), '', MB_YESNO + MB_ICONQUESTION) <> IDYES then
    Exit;
  RemoveTree(AppPath + 'DB\' + TntListBox1.Items[TntListBox1.ItemIndex] + '\');
  Sleep(50);
  UpdateProfileView;
end;

procedure TfrmMain.TntButton1Click(Sender: TObject);
var
  w: WideString;
begin
  if TntListBox1.ItemIndex < 0 then
    Exit;
  w := txt3.Caption;
  if MessageBoxW(Handle, PWideChar(w), '', MB_YESNO + MB_ICONQUESTION) <> IDYES then
    Exit;
  InitializeProfile(TntListBox1.Items[TntListBox1.ItemIndex]);
  UpdateProfileView;
  SaveConfig;
end;

procedure TfrmMain.TntBitBtn4Click(Sender: TObject);
var
  w: WideString;
begin
  if Encrypt(Encrypt(CryptoChallenge, 9265), 45674) = Edit2.Text then
  begin
    w := txt5.Caption;
    MessageBoxW(Handle, PWideChar(w), '', MB_OK + MB_ICONINFORMATION);
    Exit;
  end
  else
  begin
    w := txt4.Caption;
    MessageBoxW(Handle, PWideChar(w), '', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;
end;

procedure TfrmMain.Edit2Exit(Sender: TObject);
begin
  SaveConfig;
end;

procedure TfrmMain.TntBitBtn5Click(Sender: TObject);
begin
  AllowApplicationClose := True;
  Application.Terminate;
end;

procedure TfrmMain.WMQueryEndSession(var M: TWMQueryEndSession);
begin
  if DumpingNeeded then
    DumpProfile;
  Halt(1);
  M.Result := 1;
end;

procedure TfrmMain.WMEndSession(var M: TWMEndSession);
begin
  M.EndSession := True;
  inherited;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := AllowApplicationClose;
  if not CanClose then
    Hide;
end;

procedure TfrmMain.VisualPocketsDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  I: Integer;
begin
  if Encrypt(Encrypt(CryptoChallenge, 9265), 45674) <> Edit2.Text then
    for I := 3 to 9 do
      if Sender = self.PocketVCs[I] then
        Exit;
  if (Source is TVisualClipboard)and(Sender is TVisualClipboard) then
  begin
    TVisualClipboard(Sender).CopyClipboardFrom(TVisualClipboard(Source));
    TVisualClipboard(Sender).SaveToFile(TVisualClipboard(Sender).DumpFile);
  end;
end;

procedure TfrmMain.VisualPocketsDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TVisualClipboard;
end;

procedure TfrmMain.TntBitBtn6Click(Sender: TObject);
var
  w: WideString;
  sr: TSearchRec;
begin
  w := TntLabel10.Caption;
  if MessageBoxW(Handle, PWideChar(w), '', MB_YESNO + MB_ICONQUESTION) <> IDYES then
    Exit;
  if FindFirst(AppPath + 'DB\' + Profile + '\' + '*.row', faHidden, sr) = 0 then
  begin
    repeat
      DeleteFile(AppPath + 'DB\' + Profile + '\' + sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  InitializeProfile(Profile);
end;

procedure TfrmMain.VisualClipboardMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TVisualClipboard then
  begin
    LockedX := X;
    LockedY := Y;
    LockedObject := Sender;
  end;
end;

procedure TfrmMain.VisualClipboardMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift)and(LockedObject = Sender)and((Abs(LockedX - X) > 5)or(Abs(LockedY - Y) > 5)) then
  begin
    LockedObject := nil;
    TVisualClipboard(Sender).BeginDrag(True);
  end;
end;

procedure TfrmMain.VisualClipboardMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  K: Char;
begin
  if LockedObject = Sender then
  begin
    for I := 0 to 9 do
      if Sender = PocketVCs[I] then
      begin
        K := Char(((I + 1) mod 10) + 48);
        KeyPress(PocketVCs[I], K);
        Exit;
      end;
    Tag := 1;
    try
      Uninvoke;
      TVisualClipboard(Sender).PasteToClipboard;
      SimulateKeyStroke(Ord('V'), [ssCtrl], False);
    finally
      Tag := 0;
    end;
  end;
  LockedObject := nil;
end;

procedure TfrmMain.UpdateButtons;
begin
  if Height < 400 then
  begin
    TntBitBtn7.Caption := TntLabel4.Caption;
    TntPanel1.Enabled := False;
    TntPanel1.Visible := False;
    TntBitBtn1.Enabled := False;
    TntBitBtn2.Enabled := False;
    TntBitBtn6.Enabled := False;
  end
  else
  begin
    TntBitBtn7.Caption := TntLabel11.Caption;
    TntPanel1.Enabled := True;
    TntBitBtn1.Enabled := True;
    TntBitBtn2.Enabled := True;
    TntBitBtn6.Enabled := True;
  end;
  TntBitBtn6.Visible := not TntPanel1.Visible;
end;

procedure TfrmMain.TntBitBtn7Click(Sender: TObject);
begin
  if Height < 400 then
    Height := 695
  else
    Height := 185;
  UpdateButtons;
end;

initialization
  InitializeCryptoChallenge;
end.
