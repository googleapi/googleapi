object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 455
  ClientWidth = 903
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 278
    Top = 287
    Width = 227
    Height = 146
    Stretch = True
  end
  object Button1: TButton
    Left = 8
    Top = 217
    Width = 201
    Height = 25
    Caption = #1055#1086#1083#1091#1095#1077#1085#1080#1077' '#1082#1083#1102#1095#1072
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 825
    Height = 81
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
    WantTabs = True
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 190
    Width = 145
    Height = 21
    TabOrder = 2
    Text = 'ComboBox1'
    OnChange = ComboBox1Change
  end
  object Button2: TButton
    Left = 8
    Top = 244
    Width = 201
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1087#1086#1089#1090#1072
    TabOrder = 3
    OnClick = Button2Click
  end
  object Memo2: TMemo
    Left = 8
    Top = 95
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo2')
    TabOrder = 4
  end
  object Memo3: TMemo
    Left = 230
    Top = 95
    Width = 618
    Height = 174
    Lines.Strings = (
      '<p>Memo2</p>')
    TabOrder = 5
  end
  object Button3: TButton
    Left = 8
    Top = 271
    Width = 201
    Height = 25
    Caption = #1055#1086#1083#1091#1095#1077#1085#1080#1077' '#1087#1086#1089#1090#1072
    TabOrder = 6
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 8
    Top = 298
    Width = 201
    Height = 25
    Caption = #1055#1086#1083#1091#1095#1077#1085#1080#1077' '#1087#1086#1089#1090#1072' '#1089' '#1087#1072#1088#1072#1084#1077#1090#1088#1072#1084#1080
    TabOrder = 7
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 8
    Top = 325
    Width = 201
    Height = 25
    Caption = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077' '#1087#1086#1089#1090#1072
    TabOrder = 8
    OnClick = Button5Click
  end
  object Edit1: TEdit
    Left = 390
    Top = 198
    Width = 185
    Height = 21
    TabOrder = 9
  end
  object Button6: TButton
    Left = 8
    Top = 353
    Width = 201
    Height = 25
    Caption = #1059#1076#1072#1083#1077#1085#1080#1077' '#1087#1086#1089#1090#1072
    TabOrder = 10
    OnClick = Button6Click
  end
  object ProgressBar1: TProgressBar
    Left = 390
    Top = 108
    Width = 150
    Height = 17
    TabOrder = 11
  end
  object Button7: TButton
    Left = 8
    Top = 384
    Width = 201
    Height = 25
    Caption = #1055#1086#1083#1091#1095#1077#1085#1080#1077' '#1074#1089#1077#1093' '#1082#1086#1084#1084#1077#1085#1090#1072#1088#1080#1077#1074
    TabOrder = 12
    OnClick = Button7Click
  end
  object Edit2: TEdit
    Left = 390
    Top = 171
    Width = 161
    Height = 21
    TabOrder = 13
    Text = 'Edit2'
  end
  object Blogger1: TBlogger
    AppName = 'MyCompany'
    Blogs = <>
    OnProgress = Blogger1Progress
    OnError = Blogger1Error
    Left = 584
    Top = 8
  end
  object GoogleLogin1: TGoogleLogin
    AppName = 
      'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.2.6) Gecko/2' +
      '0100625 Firefox/3.6.6'
    AccountType = atGOOGLE
    Email = 'nmdsoft@gmail.com'
    Service = blogger
    OnAutorization = GoogleLogin1Autorization
    OnAutorizCaptcha = GoogleLogin1AutorizCaptcha
    OnError = GoogleLogin1Error
    Left = 584
    Top = 56
  end
end
