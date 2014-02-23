program CopyPocket;

uses
  ProcessSharedString,
  Windows,
  Messages,
  Classes,
  SysUtils,
  Forms,
  MainForm in 'MainForm.pas' {frmMain},
  ClipboardUtils in 'ClipboardUtils.pas',
  Encryption in 'Encryption.pas',
  VisualClipboard in 'VisualClipboard.pas';

{$R *.res}

var
  pss: TProcessSharedAnsiString;
begin
  pss := TProcessSharedAnsiString.Create('A8EA4156-797C-4FF1-96CE-844061200D44');
  try
    pss.Lock;
    try
      if pss.Value = '' then
        pss.Value := '0'
      else
      begin
        SendMessage(StrToInt(pss.Value), WM_USER + 1, 0, 0);
        Exit;
      end;
      Application.Initialize;
      Application.Title := 'Copy Pocket';
  Application.CreateForm(TfrmMain, frmMain);
  pss.Value := IntToStr(frmMain.Handle);
    finally
      pss.Unlock;
    end;
    Application.Run;
    pss.Value := '';
  finally
    pss.Free;
  end;
end.
