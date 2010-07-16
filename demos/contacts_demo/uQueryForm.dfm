object fQuery: TfQuery
  Left = 0
  Top = 0
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1079#1072#1075#1088#1091#1079#1082#1080' '#1082#1086#1085#1090#1072#1082#1090#1086#1074
  ClientHeight = 175
  ClientWidth = 338
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnHide = FormHide
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 13
    Width = 218
    Height = 13
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1082#1086#1085#1090#1072#1082#1090#1086#1074' '#1074' '#1086#1076#1085#1086#1084' '#1076#1086#1082#1091#1084#1077#1085#1090#1077
  end
  object Label2: TLabel
    Left = 8
    Top = 36
    Width = 214
    Height = 13
    Caption = #1048#1085#1076#1077#1082#1089' '#1087#1077#1088#1074#1086#1075#1086' '#1074#1086#1079#1074#1088#1072#1097#1072#1077#1084#1086#1075#1086' '#1082#1086#1085#1090#1072#1082#1090#1072
  end
  object Label4: TLabel
    Left = 8
    Top = 78
    Width = 57
    Height = 13
    Caption = #1085#1077' '#1087#1086#1079#1076#1085#1077#1077
  end
  object Label5: TLabel
    Left = 8
    Top = 101
    Width = 163
    Height = 13
    Caption = #1055#1086#1088#1103#1076#1086#1082' '#1089#1086#1088#1090#1080#1088#1086#1074#1082#1072' '#1082#1086#1085#1090#1072#1082#1090#1086#1074
  end
  object Edit1: TEdit
    Left = 248
    Top = 9
    Width = 37
    Height = 21
    TabOrder = 0
    Text = '0'
  end
  object UpDown1: TUpDown
    Left = 285
    Top = 9
    Width = 16
    Height = 21
    Associate = Edit1
    Max = 10000
    TabOrder = 1
  end
  object Edit2: TEdit
    Left = 248
    Top = 32
    Width = 37
    Height = 21
    TabOrder = 2
    Text = '1'
  end
  object UpDown2: TUpDown
    Left = 285
    Top = 32
    Width = 16
    Height = 21
    Associate = Edit2
    Min = 1
    Position = 1
    TabOrder = 3
  end
  object DateTimePicker1: TDateTimePicker
    Left = 71
    Top = 74
    Width = 82
    Height = 21
    Date = 40363.856958194450000000
    Time = 40363.856958194450000000
    TabOrder = 4
  end
  object ComboBox1: TComboBox
    Left = 177
    Top = 97
    Width = 140
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 5
    Text = #1055#1086' '#1074#1086#1079#1088#1072#1089#1090#1072#1085#1080#1102
    Items.Strings = (
      #1055#1086' '#1074#1086#1079#1088#1072#1089#1090#1072#1085#1080#1102
      #1055#1086' '#1091#1073#1099#1074#1072#1085#1080#1102)
  end
  object Button1: TButton
    Left = 128
    Top = 147
    Width = 75
    Height = 25
    Caption = #1055#1088#1080#1085#1103#1090#1100
    TabOrder = 6
    OnClick = Button1Click
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 124
    Width = 306
    Height = 17
    Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1091#1076#1072#1083#1077#1085#1085#1099#1077' '#1082#1086#1085#1090#1072#1082#1090#1099
    TabOrder = 7
  end
  object CheckBox2: TCheckBox
    Left = 8
    Top = 55
    Width = 329
    Height = 17
    Caption = #1047#1072#1075#1088#1091#1078#1072#1090#1100' '#1090#1086#1083#1100#1082#1086' '#1090#1077' '#1082#1086#1085#1090#1072#1082#1090#1099' '#1091' '#1082#1086#1090#1086#1088#1099#1093' '#1076#1072#1090#1072' '#1086#1073#1085#1086#1074#1083#1077#1085#1080#1103
    TabOrder = 8
  end
end
