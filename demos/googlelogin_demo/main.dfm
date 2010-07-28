object Form11: TForm11
  Left = 0
  Top = 0
  Caption = 'Google Login'
  ClientHeight = 524
  ClientWidth = 355
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
  object Label7: TLabel
    Left = 8
    Top = 168
    Width = 61
    Height = 13
    Caption = 'TLoginResult'
  end
  object Label8: TLabel
    Left = 8
    Top = 195
    Width = 31
    Height = 13
    Caption = 'Label8'
  end
  object Label9: TLabel
    Left = 8
    Top = 264
    Width = 162
    Height = 13
    Caption = #1051#1086#1075' '#1082#1086#1083'-'#1074#1072' '#1087#1086#1083#1091#1095#1077#1085#1085#1099#1093' '#1076#1072#1085#1085#1099#1093
  end
  object Label10: TLabel
    Left = 8
    Top = 222
    Width = 114
    Height = 13
    Caption = #1055#1088#1086#1075#1088#1077#1089#1089' '#1072#1074#1090#1086#1088#1080#1079#1072#1094#1080#1080
  end
  object Image1: TImage
    Left = 8
    Top = 359
    Width = 241
    Height = 74
    AutoSize = True
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
    Left = 213
    Top = 27
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '123456789her'
  end
  object Button1: TButton
    Left = 8
    Top = 84
    Width = 170
    Height = 21
    Caption = #1051#1086#1075#1080#1085#1080#1084#1089#1103
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
    Left = 84
    Top = 138
    Width = 264
    Height = 21
    TabOrder = 4
  end
  object ResultEdit: TEdit
    Left = 84
    Top = 111
    Width = 264
    Height = 21
    TabOrder = 5
  end
  object Button2: TButton
    Left = 184
    Top = 84
    Width = 163
    Height = 21
    Caption = #1069#1082#1089#1090#1088#1077#1085#1085#1086#1077' '#1090#1086#1088#1084#1086#1078#1077#1085#1080#1077' '#1087#1086#1090#1086#1082#1072
    TabOrder = 6
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 84
    Top = 165
    Width = 264
    Height = 21
    TabOrder = 7
  end
  object Edit2: TEdit
    Left = 84
    Top = 192
    Width = 264
    Height = 21
    TabOrder = 8
    Text = 'Edit2'
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 241
    Width = 339
    Height = 17
    TabOrder = 9
  end
  object Memo1: TMemo
    Left = 8
    Top = 283
    Width = 339
    Height = 70
    TabOrder = 10
  end
  object Animate1: TAnimate
    Left = 8
    Top = 466
    Width = 80
    Height = 50
    CommonAVI = aviFindFolder
    DoubleBuffered = False
    ParentDoubleBuffered = False
    StopFrame = 29
    Timers = True
  end
  object Edit3: TEdit
    Left = 208
    Top = 456
    Width = 121
    Height = 21
    TabOrder = 12
    Text = 'Edit3'
  end
  object Button3: TButton
    Left = 216
    Top = 488
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 13
    OnClick = Button3Click
  end
  object GoogleLogin1: TGoogleLogin
    AppName = 
      'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.2.6) Gecko/2' +
      '0100625 Firefox/3.6.6'
    AccountType = atNone
    OnAutorization = GoogleLogin1Autorization
    OnAutorizCaptcha = GoogleLogin1AutorizCaptcha
    OnProgressAutorization = GoogleLogin1ProgressAutorization
    Left = 176
    Top = 8
  end
end
