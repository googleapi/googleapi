object Form11: TForm11
  Left = 0
  Top = 0
  Caption = 'Google Login'
  ClientHeight = 167
  ClientWidth = 340
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
    Top = 31
    Width = 24
    Height = 13
    Caption = 'Email'
  end
  object Label2: TLabel
    Left = 165
    Top = 31
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object Label4: TLabel
    Left = 8
    Top = 8
    Width = 152
    Height = 13
    Caption = #1057#1074#1077#1076#1077#1085#1080#1103' '#1086#1073' '#1072#1082#1082#1072#1091#1085#1090#1077' Google'
  end
  object Label3: TLabel
    Left = 8
    Top = 115
    Width = 53
    Height = 13
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090
  end
  object Label5: TLabel
    Left = 8
    Top = 60
    Width = 36
    Height = 13
    Caption = #1057#1077#1088#1074#1080#1089
  end
  object Label6: TLabel
    Left = 8
    Top = 141
    Width = 27
    Height = 13
    Caption = 'AUTH'
  end
  object EmailEdit: TEdit
    Left = 38
    Top = 27
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object PassEdit: TEdit
    Left = 213
    Top = 27
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object Button1: TButton
    Left = 120
    Top = 84
    Width = 75
    Height = 21
    Caption = 'Connect'
    TabOrder = 2
    OnClick = Button1Click
  end
  object ComboBox1: TComboBox
    Left = 50
    Top = 57
    Width = 284
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 3
    Text = #1051#1102#1073#1086#1081
    Items.Strings = (
      #1051#1102#1073#1086#1081
      'Google Analytics Data APIs'
      'Google Apps Provisioning APIs'
      'Google Base Data API'
      'Google Sites Data API'
      'Blogger Data API'
      'Book Search Data API'
      'Calendar Data API'
      'Google Code Search Data API'
      'Contacts Data API'
      'Documents List Data API'
      'Finance Data API'
      'Gmail Atom feed'
      'Health Data API'
      'Maps Data APIs'
      'Picasa Web Albums Data API'
      'Sidewiki Data API'
      'Spreadsheets Data API'
      'Webmaster Tools API'
      'YouTube Data API')
  end
  object AuthEdit: TEdit
    Left = 68
    Top = 138
    Width = 264
    Height = 21
    TabOrder = 4
  end
  object ResultEdit: TEdit
    Left = 68
    Top = 111
    Width = 264
    Height = 21
    TabOrder = 5
  end
  object GoogleLogin1: TGoogleLogin
    AccountType = atHOSTED_OR_GOOGLE
    Service = tsNone
    OnAfterLogin = GoogleLogin1AfterLogin
    Left = 256
    Top = 4
  end
end
