object Form6: TForm6
  Left = 0
  Top = 0
  Caption = 'Form6'
  ClientHeight = 456
  ClientWidth = 721
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 282
    Top = 259
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 6
    Top = 8
    Width = 707
    Height = 245
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object GoogleLogin1: TGoogleLogin
    AppName = 
      'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.2.6) Gecko/2' +
      '0100625 Firefox/3.6.6'
    AccountType = atNone
    Left = 116
    Top = 270
  end
end
