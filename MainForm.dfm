object frmMain: TfrmMain
  Left = 203
  Top = 69
  BorderStyle = bsDialog
  Caption = 'Copy Pocket'
  ClientHeight = 668
  ClientWidth = 891
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  WindowState = wsMinimized
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = KeyPress
  OnMouseMove = VisualClipboardMouseMove
  DesignSize = (
    891
    668)
  PixelsPerInch = 96
  TextHeight = 13
  object TntLabel1: TTntLabel
    Left = 474
    Top = 70
    Width = 75
    Height = 13
    Caption = 'Copy To Pocket'
    Visible = False
  end
  object TntLabel2: TTntLabel
    Left = 474
    Top = 84
    Width = 89
    Height = 13
    Caption = 'Paste From Pocket'
    Visible = False
  end
  object TntLabel3: TTntLabel
    Left = 22
    Top = 14
    Width = 6
    Height = 23
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object TntLabel10: TTntLabel
    Left = 474
    Top = 98
    Width = 459
    Height = 13
    Caption = 
      'You are about to clear this profile'#39's history (not the pockets).' +
      ' Are you sure you want to do this?'
    Visible = False
  end
  object TntLabel4: TTntLabel
    Left = 474
    Top = 112
    Width = 44
    Height = 13
    Caption = '+ history'
    Visible = False
  end
  object TntLabel11: TTntLabel
    Left = 474
    Top = 126
    Width = 40
    Height = 13
    Caption = '- history'
    Visible = False
  end
  object TntLabel12: TTntLabel
    Left = 716
    Top = 6
    Width = 144
    Height = 13
    Alignment = taRightJustify
    Caption = 'Ctrl+Alt+C  -  Copy To Pocket'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 14914662
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object TntLabel13: TTntLabel
    Left = 703
    Top = 20
    Width = 157
    Height = 13
    Alignment = taRightJustify
    Caption = 'Ctrl+Alt+V  -  Paste From Pocket'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 14914662
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object ScrollBox1: TScrollBox
    Left = 5
    Top = 168
    Width = 881
    Height = 459
    HorzScrollBar.Margin = 10
    HorzScrollBar.Smooth = True
    HorzScrollBar.Tracking = True
    VertScrollBar.Margin = 10
    VertScrollBar.Smooth = True
    VertScrollBar.Tracking = True
    BevelInner = bvSpace
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
  end
  object CopyHotKey: THotKey
    Left = 56
    Top = 58
    Width = 121
    Height = 19
    HotKey = 49219
    Modifiers = [hkCtrl, hkAlt]
    TabOrder = 8
    Visible = False
  end
  object PasteHotKey: THotKey
    Left = 182
    Top = 58
    Width = 121
    Height = 19
    HotKey = 49238
    Modifiers = [hkCtrl, hkAlt]
    TabOrder = 9
    Visible = False
  end
  object TntPanel1: TTntPanel
    Left = 40
    Top = 160
    Width = 857
    Height = 467
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 2
    Visible = False
    object txt1: TTntLabel
      Left = 38
      Top = 6
      Width = 190
      Height = 13
      Caption = 'You can not delete your current profile!'
      Visible = False
    end
    object txt2: TTntLabel
      Left = 38
      Top = 22
      Width = 68
      Height = 13
      Caption = 'Cofirm delete!'
      Visible = False
    end
    object txt3: TTntLabel
      Left = 38
      Top = 38
      Width = 112
      Height = 13
      Caption = 'Confirm profile change!'
      Visible = False
    end
    object TntLabel9: TTntLabel
      Left = 470
      Top = 420
      Width = 266
      Height = 13
      Caption = 'Registration Key is needed to unlock the last 7 pockets.'
    end
    object txt4: TTntLabel
      Left = 38
      Top = 54
      Width = 114
      Height = 13
      Caption = 'Invalid registration key!'
      Visible = False
    end
    object txt5: TTntLabel
      Left = 38
      Top = 70
      Width = 188
      Height = 13
      Caption = 'Thank you for registering Copy Pocket!'
      Visible = False
    end
    object TntGroupBox1: TTntGroupBox
      Left = 58
      Top = 90
      Width = 353
      Height = 315
      Caption = ' Profiles '
      TabOrder = 0
      object TntLabel5: TTntLabel
        Left = 26
        Top = 256
        Width = 74
        Height = 13
        Caption = 'Current Profile:'
      end
      object TntLabel6: TTntLabel
        Left = 26
        Top = 270
        Width = 3
        Height = 13
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object TntListBox1: TTntListBox
        Left = 28
        Top = 56
        Width = 209
        Height = 155
        ItemHeight = 13
        TabOrder = 0
      end
      object TntButton1: TTntButton
        Left = 250
        Top = 54
        Width = 75
        Height = 25
        Caption = 'Set Profile'
        TabOrder = 1
        OnClick = TntButton1Click
      end
      object TntButton2: TTntButton
        Left = 250
        Top = 82
        Width = 75
        Height = 25
        Caption = 'Del Profile'
        TabOrder = 2
        OnClick = TntButton2Click
      end
      object TntEdit1: TTntEdit
        Left = 26
        Top = 220
        Width = 211
        Height = 21
        TabOrder = 3
      end
      object TntButton3: TTntButton
        Left = 248
        Top = 216
        Width = 75
        Height = 25
        Caption = 'Add Profile'
        TabOrder = 4
        OnClick = TntButton3Click
      end
    end
    object TntGroupBox2: TTntGroupBox
      Left = 460
      Top = 90
      Width = 379
      Height = 97
      Caption = ' Run On Startup '
      TabOrder = 1
      object TntCheckBox1: TTntCheckBox
        Left = 34
        Top = 44
        Width = 321
        Height = 17
        Caption = 'Start the program when Windows starts'
        TabOrder = 0
        OnClick = TntCheckBox1Click
      end
    end
    object TntGroupBox3: TTntGroupBox
      Left = 460
      Top = 196
      Width = 379
      Height = 209
      Caption = ' Registration Key '
      TabOrder = 2
      object TntLabel7: TTntLabel
        Left = 19
        Top = 59
        Width = 86
        Height = 13
        Alignment = taRightJustify
        Caption = 'Registration Code'
      end
      object TntLabel8: TTntLabel
        Left = 27
        Top = 138
        Width = 79
        Height = 13
        Alignment = taRightJustify
        Caption = 'Registration Key'
      end
      object Edit1: TEdit
        Left = 108
        Top = 54
        Width = 231
        Height = 21
        ReadOnly = True
        TabOrder = 0
      end
      object Edit2: TEdit
        Left = 110
        Top = 134
        Width = 179
        Height = 21
        TabOrder = 1
        OnExit = Edit2Exit
      end
      object TntBitBtn4: TTntBitBtn
        Left = 290
        Top = 134
        Width = 51
        Height = 19
        Caption = 'Test'
        TabOrder = 2
        OnClick = TntBitBtn4Click
        OnKeyPress = KeyPress
      end
    end
  end
  object TntBitBtn5: TTntBitBtn
    Left = 786
    Top = 635
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Exit'
    TabOrder = 7
    OnClick = TntBitBtn5Click
    OnKeyPress = KeyPress
  end
  object TntBitBtn6: TTntBitBtn
    Left = 198
    Top = 635
    Width = 93
    Height = 25
    Caption = 'Clear History'
    TabOrder = 5
    OnClick = TntBitBtn6Click
    OnKeyPress = KeyPress
  end
  object TntBitBtn3: TTntBitBtn
    Left = 704
    Top = 635
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Hide'
    TabOrder = 6
    OnClick = TntBitBtn3Click
    OnKeyPress = KeyPress
  end
  object TntBitBtn1: TTntBitBtn
    Left = 22
    Top = 635
    Width = 75
    Height = 25
    Caption = 'History'
    TabOrder = 3
    OnClick = TntBitBtn1Click
    OnKeyPress = KeyPress
  end
  object TntBitBtn2: TTntBitBtn
    Left = 110
    Top = 635
    Width = 75
    Height = 25
    Caption = 'Options'
    TabOrder = 4
    OnClick = TntBitBtn2Click
    OnKeyPress = KeyPress
  end
  object TntBitBtn7: TTntBitBtn
    Left = 24
    Top = 128
    Width = 75
    Height = 25
    Caption = '+ history'
    TabOrder = 0
    OnClick = TntBitBtn7Click
    OnKeyPress = KeyPress
  end
  object Panel1: TPanel
    Left = 418
    Top = 642
    Width = 277
    Height = 19
    Anchors = [akLeft, akBottom]
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 10
    DesignSize = (
      277
      19)
    object TntLabel14: TTntLabel
      Left = 51
      Top = 4
      Width = 192
      Height = 11
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      Caption = 'Copyright 2009 New Merkel Consulting Group'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 14914662
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object HotKey1: THotKey
    Left = 116
    Top = 22
    Width = 121
    Height = 19
    HotKey = 16451
    Modifiers = [hkCtrl]
    TabOrder = 11
    Visible = False
  end
  object HideTimer: TTimer
    Interval = 10
    OnTimer = HideTimerTimer
    Left = 220
    Top = 624
  end
  object DumpTimer: TTimer
    Interval = 5000
    OnTimer = DumpTimerTimer
    Left = 254
    Top = 624
  end
  object ApplicationEvents1: TApplicationEvents
    Left = 436
    Top = 70
  end
  object CopyTimer: TTimer
    Interval = 10
    OnTimer = CopyTimerTimer
    Left = 286
    Top = 624
  end
end
