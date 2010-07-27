object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 305
  ClientWidth = 616
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
    Top = 97
    Width = 68
    Height = 13
    Caption = #1057#1086#1076#1077#1088#1078#1080#1084#1086#1077':'
  end
  object Label8: TLabel
    Left = 327
    Top = 97
    Width = 111
    Height = 13
    Caption = #1060#1072#1081#1083#1099' '#1076#1083#1103' '#1086#1090#1087#1088#1072#1074#1082#1080':'
  end
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 40
    Height = 13
    Caption = #1054#1090' '#1082#1086#1075#1086
  end
  object lbl1: TLabel
    Left = 216
    Top = 12
    Width = 145
    Height = 13
    Caption = '('#1085#1072#1087#1088#1080#1084#1077#1088', pupki@gmail.com)'
  end
  object lbl2: TLabel
    Left = 8
    Top = 38
    Width = 25
    Height = 13
    Caption = #1050#1086#1084#1091
  end
  object lbl3: TLabel
    Left = 215
    Top = 38
    Width = 160
    Height = 13
    Caption = '('#1053#1072#1087#1088#1080#1084#1077#1088', Sidorov@yandex.ru)'
  end
  object lbl4: TLabel
    Left = 8
    Top = 66
    Width = 83
    Height = 13
    Caption = #1058#1077#1084#1072' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
  end
  object lbl5: TLabel
    Left = 373
    Top = 11
    Width = 30
    Height = 13
    Caption = #1051#1086#1075#1080#1085
  end
  object lbl6: TLabel
    Left = 491
    Top = 12
    Width = 37
    Height = 13
    Caption = #1055#1072#1088#1086#1083#1100
  end
  object Memo1: TMemo
    Left = 8
    Top = 116
    Width = 313
    Height = 85
    TabOrder = 0
  end
  object Button1: TButton
    Left = 44
    Top = 207
    Width = 110
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1082#1072#1082' '#1090#1077#1082#1089#1090
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 160
    Top = 207
    Width = 112
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1082#1072#1082' HTML'
    TabOrder = 2
    OnClick = Button2Click
  end
  object ListBox2: TListBox
    Left = 327
    Top = 116
    Width = 282
    Height = 85
    ItemHeight = 13
    TabOrder = 3
  end
  object Button3: TButton
    Left = 268
    Top = 255
    Width = 75
    Height = 25
    Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100
    TabOrder = 4
    OnClick = Button3Click
  end
  object Edit1: TEdit
    Left = 54
    Top = 8
    Width = 155
    Height = 21
    TabOrder = 5
  end
  object Edit2: TEdit
    Left = 54
    Top = 35
    Width = 155
    Height = 21
    TabOrder = 6
  end
  object Edit3: TEdit
    Left = 97
    Top = 62
    Width = 512
    Height = 21
    TabOrder = 7
    Text = #1058#1077#1084#1072' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
  end
  object btn1: TButton
    Left = 366
    Top = 207
    Width = 89
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1092#1072#1081#1083
    TabOrder = 8
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 461
    Top = 207
    Width = 118
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1099#1073#1088#1072#1085#1085#1099#1081
    TabOrder = 9
    OnClick = btn2Click
  end
  object Edit4: TEdit
    Left = 409
    Top = 8
    Width = 76
    Height = 21
    TabOrder = 10
  end
  object Edit5: TEdit
    Left = 534
    Top = 8
    Width = 75
    Height = 21
    TabOrder = 11
  end
  object chk1: TCheckBox
    Left = 8
    Top = 238
    Width = 405
    Height = 17
    Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1087#1086#1083#1103' '#1082#1086#1084#1087#1086#1085#1077#1085#1090#1072' '#1087#1086#1089#1083#1077' '#1086#1090#1087#1088#1072#1082#1080' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
    TabOrder = 12
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 286
    Width = 616
    Height = 19
    Panels = <
      item
        Width = 200
      end>
  end
  object OpenDialog1: TOpenDialog
    Left = 449
    Top = 140
  end
  object GMailSMTP1: TGMailSMTP
    Host = 'smtp.gmail.com'
    Port = 587
    Mailer = 'MyMegaMailer'
    OnStatus = GMailSMTP1Status
    Left = 48
    Top = 120
  end
end
