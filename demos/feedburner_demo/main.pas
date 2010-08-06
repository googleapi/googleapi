unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GFeedBurner, StdCtrls, ComCtrls;

type
  TForm6 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    Button2: TButton;
    Memo2: TMemo;
    FeedBurner1: TFeedBurner;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FeedBurner1APIRequestError(const Code: Integer; Error: string);
    procedure FeedBurner1ParseElement(Item: TBasicEntry);
    procedure FeedBurner1ThreadEnd(ThreadIdx: Integer; Actives: Byte);
    procedure FeedBurner1ThreadStart(ThreadIdx: Integer; Actives: Byte);
    procedure FeedBurner1Progress(const Date: TDate; ThreadIdx: Byte;
      ProgreeCurrent, ProgreeMax: Int64);
  private
    { Private declarations }
  public
    procedure OnAPIRequestError (const Code:integer; Error: string);
    procedure OnProgress(Max,Current:int64);
    procedure OnAnalyse(Sender:TObject);
    procedure ItemChangeEvent (Item: TBasicEntry);
  end;

var
  Form6: TForm6;
  FB:TFeedBurner;
implementation

{$R *.dfm}

procedure TForm6.Button1Click(Sender: TObject);
begin
//FeedBurner1.DateRange.Add(Now-2);
//FeedBurner1.DateRange.Add(Now-3);
//FeedBurner1.DateRange.Add(Now-4);
//FeedBurner1.DateRange.Add(Now-5);
//FeedBurner1.DateRange.AddRange(Now-5,Now);
//FeedBurner1.DateRange.AddRange(Now-5,Now-2);
//FeedBurner1.DateRange.AddRange(Now-200,Now-2);
FeedBurner1.Start;
end;

procedure TForm6.Button2Click(Sender: TObject);
begin
 FeedBurner1.Stop;
end;

procedure TForm6.FeedBurner1APIRequestError(const Code: Integer; Error: string);
begin
 Memo1.Lines.Add('Ошибка '+IntToStr(Code)+' '+Error)
end;

procedure TForm6.FeedBurner1ParseElement(Item: TBasicEntry);
var i,j: integer;
begin
 Memo2.Lines.Add('----------'+DateToStr(Item.Date)+'----------');
 Memo2.Lines.Add('---------- Circulation: '+IntToStr(Item.Circulation)+'----------');
    for i := 0 to Item.FeedItems.Count - 1 do
      begin
        Memo2.Lines.Add('Title: '+Item.FeedItems[i].Title);
        for j:= 0 to Item.FeedItems[i].Referrers.Count - 1 do
          begin
            Memo2.Lines.Add('    Referrer: '+Item.FeedItems[i].Referrers[j].URL);
            Application.ProcessMessages;
          end;
      end;
end;


procedure TForm6.FeedBurner1Progress(const Date: TDate; ThreadIdx: Byte;
  ProgreeCurrent, ProgreeMax: Int64);
begin
ProgressBar1.Max:=ProgreeMax;
  ProgressBar1.Position:=ProgreeCurrent;
  Label1.Caption:=IntToStr(ProgreeMax)+' из '+IntToStr(ProgreeCurrent)
end;

procedure TForm6.FeedBurner1ThreadEnd(ThreadIdx: Integer; Actives: Byte);
begin
 Memo1.Lines.Add(' Поток '+IntToStr(ThreadIdx)+ ' остановлен. Активных потоков '+IntToStr(Actives));
end;

procedure TForm6.FeedBurner1ThreadStart(ThreadIdx: Integer; Actives: Byte);
begin
  Memo1.Lines.Add('Стартовал поток '+IntToStr(ThreadIdx)+' остановлен. Активных потоков '+IntToStr(Actives));
end;

//procedure TForm6.FeedBurner1ThreadEnd(ThreadIdx: Integer);
//begin
// Memo1.Lines.Add(' Поток '+IntToStr(ThreadIdx)+ ' остановлен');
//end;
//
//procedure TForm6.FeedBurner1ThreadStart(ThreadIdx: Integer);
//begin
//
//end;

procedure TForm6.ItemChangeEvent(Item: TBasicEntry);
var i,j: integer;
begin
 Memo2.Lines.Add('----------'+DateToStr(Item.Date)+'----------');
 Memo2.Lines.Add('---------- Circulation: '+IntToStr(Item.Circulation)+'----------');
    for i := 0 to Item.FeedItems.Count - 1 do
      begin
        Memo2.Lines.Add('Title: '+Item.FeedItems[i].Title);
        for j:= 0 to Item.FeedItems[i].Referrers.Count - 1 do
          begin
            Memo2.Lines.Add('    Referrer: '+Item.FeedItems[i].Referrers[j].URL);
            Application.ProcessMessages;
          end;
      end;
end;

procedure TForm6.OnAnalyse(Sender: TObject);
var i,j,k:integer;
begin
for I := 0 to FB.FeedData.Count - 1 do
  begin
    Memo1.Lines.Add('----------'+DateToStr(FB.FeedData[i].Date)+'----------');
    Memo1.Lines.Add('---------- Circulation: '+IntToStr(FB.FeedData[i].Circulation)+'----------');
    for j := 0 to FB.FeedData[i].FeedItems.Count - 1 do
      begin
        Memo1.Lines.Add('Title: '+FB.FeedData[i].FeedItems[j].Title);
        for k:= 0 to FB.FeedData[i].FeedItems[j].Referrers.Count - 1 do
          begin
            Memo1.Lines.Add('    Referrer: '+FB.FeedData[i].FeedItems[j].Referrers[k].URL);
            Application.ProcessMessages;
          end;
      end;
  end;
//for I := 0 to FB.DateRange.Count - 1 do
//   Memo2.Lines.Add(DateToStr(FB.DateRange[i]))
end;

procedure TForm6.OnAPIRequestError(const Code: integer; Error: string);
begin
  Memo1.Lines.Add('Ошибка '+IntToStr(Code)+' '+Error)
end;

procedure TForm6.OnProgress(Max, Current: int64);
begin
  
end;

end.
