object Form1: TForm1
  Left = 0
  Top = 0
  Caption = #1057#1086#1073#1099#1090#1080#1103' '#1074' '#1082#1072#1083#1077#1085#1076#1072#1088#1077
  ClientHeight = 322
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 25
    Height = 13
    Caption = 'Login'
  end
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object Label3: TLabel
    Left = 8
    Top = 56
    Width = 58
    Height = 13
    Caption = #1057#1086#1089#1090#1086#1103#1085#1080#1077':'
  end
  object Label4: TLabel
    Left = 72
    Top = 56
    Width = 82
    Height = 13
    Caption = #1053#1077#1090' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103
  end
  object Label5: TLabel
    Left = 8
    Top = 80
    Width = 149
    Height = 13
    Caption = #1042#1089#1077' '#1082#1072#1083#1077#1085#1076#1072#1088#1080' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
  end
  object Label6: TLabel
    Left = 407
    Top = 80
    Width = 28
    Height = 13
    Caption = #1042#1089#1077#1075#1086
  end
  object Label7: TLabel
    Left = 448
    Top = 80
    Width = 6
    Height = 13
    Caption = '0'
  end
  object Label8: TLabel
    Left = 27
    Top = 102
    Width = 112
    Height = 13
    Caption = #1057#1086#1073#1099#1090#1080#1103' '#1074' '#1082#1072#1083#1077#1085#1076#1072#1088#1077
  end
  object Label9: TLabel
    Left = 244
    Top = 8
    Width = 246
    Height = 38
    Alignment = taCenter
    Caption = #1055#1088#1080#1084#1077#1088' '#1088#1072#1073#1086#1090#1099' '#1089' '#1089#1086#1073#1099#1090#1080#1103#1084#1080' '#13#10#1074' '#1082#1072#1083#1077#1085#1076#1072#1088#1103#1093
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 60
    Top = 5
    Width = 97
    Height = 21
    TabOrder = 0
  end
  object Edit2: TEdit
    Left = 60
    Top = 29
    Width = 97
    Height = 21
    TabOrder = 1
  end
  object Button1: TButton
    Left = 163
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Login'
    TabOrder = 2
    OnClick = Button1Click
  end
  object ComboBox1: TComboBox
    Left = 163
    Top = 77
    Width = 238
    Height = 21
    Style = csDropDownList
    TabOrder = 3
    OnChange = ComboBox1Change
  end
  object ComboBox2: TComboBox
    Left = 163
    Top = 99
    Width = 238
    Height = 21
    Style = csDropDownList
    TabOrder = 4
    OnChange = ComboBox2Change
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 126
    Width = 500
    Height = 196
    Align = alBottom
    Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1087#1086' '#1089#1086#1073#1099#1090#1080#1102
    TabOrder = 5
    object Label11: TLabel
      Left = 12
      Top = 20
      Width = 46
      Height = 13
      Caption = #1057#1086#1079#1076#1072#1085#1086' '
    end
    object Label12: TLabel
      Left = 72
      Top = 21
      Width = 37
      Height = 13
      Caption = 'Label12'
    end
    object Label13: TLabel
      Left = 12
      Top = 39
      Width = 48
      Height = 13
      Caption = #1048#1079#1084#1077#1085#1077#1085#1086
    end
    object Label14: TLabel
      Left = 72
      Top = 40
      Width = 37
      Height = 13
      Caption = 'Label14'
    end
    object Label15: TLabel
      Left = 12
      Top = 63
      Width = 53
      Height = 13
      Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082
    end
    object Label17: TLabel
      Left = 12
      Top = 117
      Width = 87
      Height = 13
      Caption = #1053#1072#1095#1072#1083#1086' '#1089#1086#1073#1099#1090#1080#1103':'
    end
    object Label18: TLabel
      Left = 208
      Top = 117
      Width = 81
      Height = 13
      Caption = #1050#1086#1085#1077#1094' '#1089#1086#1073#1099#1090#1080#1103':'
    end
    object Label21: TLabel
      Left = 12
      Top = 145
      Width = 111
      Height = 13
      Caption = #1052#1077#1090#1086#1076#1099' '#1086#1087#1086#1074#1077#1097#1077#1085#1080#1103':'
    end
    object Label16: TLabel
      Left = 12
      Top = 90
      Width = 49
      Height = 13
      Caption = #1054#1087#1080#1089#1072#1085#1080#1077
    end
    object CheckBox1: TCheckBox
      Left = 136
      Top = 141
      Width = 45
      Height = 17
      Caption = 'SMS'
      TabOrder = 0
    end
    object CheckBox2: TCheckBox
      Left = 187
      Top = 141
      Width = 48
      Height = 17
      Caption = 'E-mail'
      TabOrder = 1
    end
    object CheckBox3: TCheckBox
      Left = 241
      Top = 141
      Width = 124
      Height = 17
      Caption = #1042#1089#1087#1083#1099#1074#1072#1102#1097#1077#1077' '#1086#1082#1085#1086
      TabOrder = 2
    end
    object Edit4: TEdit
      Left = 105
      Top = 59
      Width = 344
      Height = 21
      TabOrder = 3
    end
    object Edit5: TEdit
      Left = 105
      Top = 86
      Width = 344
      Height = 21
      TabOrder = 4
    end
    object DateTimePicker1: TDateTimePicker
      Left = 105
      Top = 113
      Width = 97
      Height = 21
      Date = 40264.649768275460000000
      Time = 40264.649768275460000000
      TabOrder = 5
    end
    object DateTimePicker4: TDateTimePicker
      Left = 301
      Top = 113
      Width = 97
      Height = 21
      Date = 40264.649768275460000000
      Time = 40264.649768275460000000
      TabOrder = 6
    end
    object Button2: TButton
      Left = 87
      Top = 164
      Width = 130
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1080#1079#1084#1077#1085#1077#1085#1080#1103
      TabOrder = 7
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 223
      Top = 164
      Width = 133
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1101#1090#1086' '#1089#1086#1073#1099#1090#1080#1077
      TabOrder = 8
      OnClick = Button3Click
    end
  end
  object Button4: TButton
    Left = 407
    Top = 99
    Width = 75
    Height = 21
    Caption = #1053#1086#1074#1086#1077
    TabOrder = 6
    OnClick = Button4Click
  end
end
