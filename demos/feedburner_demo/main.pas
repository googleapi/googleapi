unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GFeedBurner, StdCtrls, uGoogleLogin;

type
  TForm6 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    GoogleLogin1: TGoogleLogin;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.dfm}

procedure TForm6.Button1Click(Sender: TObject);
var FB:TFeedBurner;
    i:integer;
begin
FB:=TFeedBurner.Create(self);
//FB.DateRange:=TDateRange.Create;
//FB.DateRange.Add(Now-1);
FB.DateRange.AddRange(Now-5,Now-1);
FB.DateRange.AddRange(Now-5,Now-1,rtDescrete);
FB.FeedURL:='http://feeds.feedburner.com/myDelphi';
FB.GetFeedData;
for I := 0 to FB.FeedData.Count - 1 do
  Memo1.Lines.Add('Date '+DateToStr(FB.FeedData[i].Date)+' circulation '+IntToStr(FB.FeedData[i].Circulation))


end;

end.
