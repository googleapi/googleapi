object Form11: TForm11
  Left = 0
  Top = 0
  Caption = 'Google Login'
  ClientHeight = 353
  ClientWidth = 600
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
    Left = 175
    Top = 30
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
    Top = 108
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
    Top = 134
    Width = 27
    Height = 13
    Caption = 'AUTH'
  end
  object Label7: TLabel
    Left = 8
    Top = 161
    Width = 61
    Height = 13
    Caption = 'TLoginResult'
  end
  object Label9: TLabel
    Left = 8
    Top = 257
    Width = 162
    Height = 13
    Caption = #1051#1086#1075' '#1082#1086#1083'-'#1074#1072' '#1087#1086#1083#1091#1095#1077#1085#1085#1099#1093' '#1076#1072#1085#1085#1099#1093
  end
  object Label10: TLabel
    Left = 8
    Top = 215
    Width = 114
    Height = 13
    Caption = #1055#1088#1086#1075#1088#1077#1089#1089' '#1072#1074#1090#1086#1088#1080#1079#1072#1094#1080#1080
  end
  object imgCaptcha: TImage
    Left = 361
    Top = 173
    Width = 224
    Height = 97
    Proportional = True
    Stretch = True
  end
  object Label11: TLabel
    Left = 361
    Top = 276
    Width = 190
    Height = 13
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1090#1077#1082#1089#1090' '#1089' '#1082#1072#1088#1090#1080#1085#1082#1080' '#1074' '#1101#1090#1086' '#1087#1086#1083#1077
  end
  object Label12: TLabel
    Left = 361
    Top = 62
    Width = 230
    Height = 91
    Caption = 
      #1044#1083#1103' '#1090#1086#1075#1086' '#1095#1090#1086#1073#1099' '#1091#1074#1080#1076#1077#1090' '#1082#1072#1087#1095#1091' '#1085#1077#1086#1073#1093#1086#1076#1080#1084#1086' '#1085#1077#1089#1082#1086#1083#1100#1082#1086' '#1088#1072#1079' '#1074#1074#1077#1089#1090#1080' '#1085#1077#1087#1088 +
      #1072#1074#1080#1083#1100#1085#1099#1081' '#1087#1072#1088#1086#1083#1100' '#1080#1083#1080' '#1083#1086#1075#1080#1085'.'#13#10#1055#1086#1089#1083#1077' '#1090#1086#1075#1086' '#1082#1072#1082' '#1074#1074#1077#1083#1080' '#1082#1072#1087#1095#1091' '#1085#1077#1086#1073#1093#1086#1076#1080#1084 +
      #1086' '#1087#1088#1086#1074#1077#1088#1080#1090#1100' '#1087#1072#1088#1086#1083#1100' '#1085#1072' '#1087#1088#1072#1074#1080#1083#1100#1085#1086#1089#1090#1100' '#1077#1089#1083#1080' '#1086#1085' '#1085#1077' '#1087#1088#1072#1074#1080#1083#1100#1085#1099#1081' '#1080#1089#1087#1088#1072#1074#1080 +
      #1090#1100' '#1077#1075#1086'.'#13#10
    WordWrap = True
  end
  object EmailEdit: TEdit
    Left = 38
    Top = 27
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'GoLabApi@gmail.com'
  end
  object PassEdit: TEdit
    Left = 227
    Top = 27
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '123456789her'
  end
  object Button1: TButton
    Left = 360
    Top = 8
    Width = 225
    Height = 21
    Caption = #1051#1086#1075#1080#1085#1080#1084#1089#1103
    TabOrder = 2
    OnClick = Button1Click
  end
  object ComboBox1: TComboBox
    Left = 64
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
    Left = 84
    Top = 131
    Width = 264
    Height = 21
    TabOrder = 4
  end
  object ResultEdit: TEdit
    Left = 84
    Top = 104
    Width = 264
    Height = 21
    TabOrder = 5
  end
  object Button2: TButton
    Left = 360
    Top = 35
    Width = 225
    Height = 21
    Caption = #1069#1082#1089#1090#1088#1077#1085#1085#1086#1077' '#1090#1086#1088#1084#1086#1078#1077#1085#1080#1077' '#1087#1086#1090#1086#1082#1072' Destroy'
    TabOrder = 6
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 84
    Top = 158
    Width = 264
    Height = 21
    TabOrder = 7
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 234
    Width = 339
    Height = 17
    TabOrder = 8
  end
  object Memo1: TMemo
    Left = 8
    Top = 276
    Width = 339
    Height = 70
    TabOrder = 9
  end
  object edtCaptcha: TEdit
    Left = 361
    Top = 295
    Width = 224
    Height = 21
    TabOrder = 10
  end
  object Button3: TButton
    Left = 361
    Top = 322
    Width = 224
    Height = 25
    Caption = #1040#1074#1090#1086#1088#1080#1079#1072#1094#1080#1103' '#1087#1086#1089#1083#1077' '#1074#1074#1086#1076#1072' '#1082#1072#1087#1095#1080
    TabOrder = 11
    OnClick = Button3Click
  end
  object GoogleLogin1: TGoogleLogin
    AppName = 'My-Application'
    AccountType = atNone
    Left = 172
    Top = 184
  end
end
