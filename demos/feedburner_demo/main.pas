unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GFeedBurner, StdCtrls, ComCtrls, ToolWin, ActnMan, ActnCtrls, Ribbon,
  ImgList, RibbonLunaStyleActnCtrls, ActnList, RibbonActnCtrls, ExtCtrls,
  TeEngine, Series, TeeProcs, Chart;

type
  TForm6 = class(TForm)
    FeedBurner1: TFeedBurner;
    ActionManager1: TActionManager;
    Images_16x16: TImageList;
    Ribbon1: TRibbon;
    RibbonPage1: TRibbonPage;
    RibbonGroup1: TRibbonGroup;
    silentapi_act: TAction;
    RibbonGroup2: TRibbonGroup;
    getfeeddata_act: TAction;
    getitemdata_act: TAction;
    GetResyndicationData_act: TAction;
    Images_32x32: TImageList;
    RibbonSpinEdit1: TRibbonSpinEdit;
    Action1: TAction;
    RibbonGroup3: TRibbonGroup;
    start_act: TAction;
    stop_act: TAction;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    Panel1: TPanel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    Chart1: TChart;
    circulation_graph: TBarSeries;
    reach_graph: TBarSeries;
    clicks_graph: TBarSeries;
    views_graph: TLineSeries;
    procedure silentapi_actExecute(Sender: TObject);
    procedure getfeeddata_actExecute(Sender: TObject);
    procedure getitemdata_actExecute(Sender: TObject);
    procedure GetResyndicationData_actExecute(Sender: TObject);
    procedure RibbonSpinEdit1Change(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure start_actExecute(Sender: TObject);
    procedure stop_actExecute(Sender: TObject);
    procedure FeedBurner1ThreadStart(ThreadIdx: Integer; Actives: Byte);
    procedure FeedBurner1ThreadEnd(ThreadIdx: Integer; Actives: Byte);
    procedure FeedBurner1APIRequestError(const Code: Integer; Error: string);
    procedure FeedBurner1Done(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    function GetViewsCount(Date: TDate):integer;
  public
  end;

var
  Form6: TForm6;

implementation

uses uTimeLine;

{$R *.dfm}

procedure TForm6.Action1Execute(Sender: TObject);
begin
  fTimeLine.ShowModal;
end;

procedure TForm6.FeedBurner1APIRequestError(const Code: Integer; Error: string);
begin
Memo1.Lines.Add('Ошибка '+IntToStr(Code)+' '+Error);
end;

procedure TForm6.FeedBurner1Done(Sender: TObject);
var i,idx:integer;
begin
  circulation_graph.Active:=CheckBox1.Checked;
  reach_graph.Active:=CheckBox2.Checked;
  clicks_graph.Active:=CheckBox3.Checked;
  views_graph.Active:=CheckBox4.Checked;
  for I := 0 to FeedBurner1.Dates.Count - 1 do
    begin
      idx:=FeedBurner1.FeedData.IndexOf(FeedBurner1.Dates[i]);
      if idx>=0 then
         begin
            if circulation_graph.Active then
              circulation_graph.AddXY(FeedBurner1.Dates[i],FeedBurner1.FeedData.Items[idx].Circulation);
            if reach_graph.Active then
              reach_graph.AddXY(FeedBurner1.Dates[i],FeedBurner1.FeedData.Items[idx].Reach);
            if clicks_graph.Active then
              clicks_graph.AddXY(FeedBurner1.Dates[i],FeedBurner1.FeedData.Items[idx].Hits);
            if views_graph.Active then
              views_graph.AddXY(FeedBurner1.Dates[i],GetViewsCount(FeedBurner1.Dates[i]));
         end;
    end;
end;

procedure TForm6.FeedBurner1ThreadEnd(ThreadIdx: Integer; Actives: Byte);
begin
Memo1.Lines.Add('Поток '+IntToStr(ThreadIdx)+' завершил работу. Всего активных потоков '+IntToStr(Actives))
end;

procedure TForm6.FeedBurner1ThreadStart(ThreadIdx: Integer; Actives: Byte);
begin
  Memo1.Lines.Add('Стартовал поток '+IntToStr(ThreadIdx)+' Всего активных потоков '+IntToStr(Actives))
end;

procedure TForm6.FormShow(Sender: TObject);
begin
  case FeedBurner1.APIMethod of
    toGetFeedData: getfeeddata_act.Checked:=true;
    toGetItemData: getitemdata_act.Checked:=true;
    toGetResyndicationData: GetResyndicationData_act.Checked:=true;
  end;
  RibbonSpinEdit1.Value:=FeedBurner1.MaxThreads;
  silentapi_act.Checked:=FeedBurner1.SilentAPI;
end;

procedure TForm6.getfeeddata_actExecute(Sender: TObject);
begin
  getfeeddata_act.Checked:=not getfeeddata_act.Checked;
  FeedBurner1.APIMethod:=toGetFeedData;
end;

procedure TForm6.getitemdata_actExecute(Sender: TObject);
begin
  getitemdata_act.Checked:=not getitemdata_act.Checked;
  FeedBurner1.APIMethod:=toGetItemData;
end;

procedure TForm6.GetResyndicationData_actExecute(Sender: TObject);
begin
  GetResyndicationData_act.Checked:=not GetResyndicationData_act.Checked;
  FeedBurner1.APIMethod:=toGetResyndicationData;
end;

function TForm6.GetViewsCount(Date: TDate): integer;
var Entry: TBasicEntry;
    i,idx:integer;
begin
  Result:=0;
  idx:=FeedBurner1.FeedData.IndexOf(Date);
  if idx>=0 then
    begin
      Entry:=FeedBurner1.FeedData.Items[idx];
      for i:= 0 to Entry.FeedItems.Count - 1 do
         Result:=Result+Entry.FeedItems[i].ItemViews;
    end;
end;

procedure TForm6.RibbonSpinEdit1Change(Sender: TObject);
begin
  FeedBurner1.MaxThreads:=RibbonSpinEdit1.Value
end;

procedure TForm6.silentapi_actExecute(Sender: TObject);
begin
  silentapi_act.Checked:=not silentapi_act.Checked;
  FeedBurner1.SilentAPI:=silentapi_act.Checked;
end;

procedure TForm6.start_actExecute(Sender: TObject);
begin
  Memo1.Lines.Clear;
  FeedBurner1.Start;
end;

procedure TForm6.stop_actExecute(Sender: TObject);
begin
 FeedBurner1.Stop;
end;

end.
