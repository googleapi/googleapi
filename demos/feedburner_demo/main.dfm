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
  object Label1: TLabel
    Left = 0
    Top = 262
    Width = 721
    Height = 13
    Align = alTop
    Caption = 'Label1'
    ExplicitWidth = 31
  end
  object Button1: TButton
    Left = 298
    Top = 423
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 721
    Height = 245
    Align = alTop
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 245
    Width = 721
    Height = 17
    Align = alTop
    TabOrder = 2
  end
  object Button2: TButton
    Left = 4
    Top = 423
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Memo2: TMemo
    Left = 0
    Top = 275
    Width = 721
    Height = 138
    Align = alTop
    Lines.Strings = (
      'Memo2')
    TabOrder = 4
  end
  object FeedBurner1: TFeedBurner
    APIMethod = toGetResyndicationData
    FeedURL = 'http://feeds.feedburner.com/myDelphi'
    SilentAPI = True
    MaxThreads = 10
    OnAPIRequestError = FeedBurner1APIRequestError
    OnProgress = FeedBurner1Progress
    OnParseElement = FeedBurner1ParseElement
    OnThreadStart = FeedBurner1ThreadStart
    OnThreadEnd = FeedBurner1ThreadEnd
    TimeLine = <
      item
        RangeType = trContinued
        StartDate = 40391.464777777780000000
        EndDate = 40405.457338449070000000
      end>
    Left = 326
    Top = 128
  end
end
