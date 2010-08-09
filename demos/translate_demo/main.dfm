object Form6: TForm6
  Left = 0
  Top = 0
  Caption = 'Form6'
  ClientHeight = 208
  ClientWidth = 428
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 10
    Top = 8
    Width = 31
    Height = 13
    Caption = #1060#1088#1072#1079#1072
  end
  object Label2: TLabel
    Left = 8
    Top = 87
    Width = 44
    Height = 13
    Caption = #1055#1077#1088#1077#1074#1086#1076
  end
  object Label3: TLabel
    Left = 10
    Top = 35
    Width = 7
    Height = 13
    Caption = 'C'
  end
  object Label4: TLabel
    Left = 10
    Top = 63
    Width = 13
    Height = 13
    Caption = #1053#1072
  end
  object Edit1: TEdit
    Left = 58
    Top = 5
    Width = 365
    Height = 21
    TabOrder = 0
    Text = 'Edit1'
  end
  object Memo1: TMemo
    Left = 6
    Top = 106
    Width = 417
    Height = 95
    TabOrder = 1
  end
  object Button1: TButton
    Left = 308
    Top = 41
    Width = 75
    Height = 25
    Caption = #1055#1077#1088#1077#1074#1077#1089#1090#1080
    TabOrder = 2
    OnClick = Button1Click
  end
  object ComboBox1: TComboBox
    Left = 58
    Top = 32
    Width = 239
    Height = 21
    Style = csDropDownList
    TabOrder = 3
    OnChange = ComboBox1Change
  end
  object ComboBox2: TComboBox
    Left = 58
    Top = 55
    Width = 239
    Height = 21
    Style = csDropDownList
    TabOrder = 4
    OnChange = ComboBox2Change
  end
  object Translator1: TTranslator
    SourceLang = unknown
    DestLang = lng_ru
    OnTranslate = Translator1Translate
    OnTranslateError = Translator1TranslateError
    Left = 192
    Top = 132
  end
end
