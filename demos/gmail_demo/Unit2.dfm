object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 276
  ClientWidth = 535
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label7: TLabel
    Left = 8
    Top = 5
    Width = 68
    Height = 13
    Caption = #1057#1086#1076#1077#1088#1078#1080#1084#1086#1077':'
  end
  object Label8: TLabel
    Left = 245
    Top = 5
    Width = 111
    Height = 13
    Caption = #1060#1072#1081#1083#1099' '#1076#1083#1103' '#1086#1090#1087#1088#1072#1074#1082#1080':'
  end
  object Memo1: TMemo
    Left = 8
    Top = 21
    Width = 228
    Height = 184
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 17
    Top = 211
    Width = 101
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1090#1077#1082#1089#1090
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 120
    Top = 211
    Width = 94
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' HTML'
    TabOrder = 2
    OnClick = Button2Click
  end
  object ListBox2: TListBox
    Left = 245
    Top = 20
    Width = 282
    Height = 216
    ItemHeight = 13
    PopupMenu = PopupMenu2
    TabOrder = 3
  end
  object Button3: TButton
    Left = 208
    Top = 248
    Width = 75
    Height = 25
    Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100
    TabOrder = 4
    OnClick = Button3Click
  end
  object PopupMenu1: TPopupMenu
    Left = 329
    Top = 224
    object N1: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    end
    object N2: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 349
    Top = 76
    object N3: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      OnClick = N3Click
    end
    object N4: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      OnClick = N4Click
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 417
    Top = 76
  end
  object GMailSMTP1: TGMailSMTP
    Login = 'vlad383@gmail.com'
    Password = 'vlad383383'
    Host = 'smtp.gmail.com'
    FromEmail = 'vlad383@gmail.com'
    FromName = 'Vlad'
    Port = 587
    Recipients.Strings = (
      'bvv36@yandex.ru')
    Left = 44
    Top = 72
  end
end
