{==============================================================================|
|Проект: Google API в Delphi                                                   |
|==============================================================================|
|unit: GFeedBurner                                                             |
|==============================================================================|
|Описание: Модуль для обработки данных каналов в FeedBurner.                   |
|==============================================================================|
|Зависимости:                                                                  |
|1. Для работы с HTTP-протоколом используется библиотека Synapse (httpsend.pas)|
|2. Для парсинга XML-документов используется библиотека NativeXML              |
|==============================================================================|
| Автор: Vlad. (vlad383@gmail.com)                                             |
| Дата:                                                                        |
| Версия: см. ниже                                                             |
| Copyright (c) 2009-2010 WebDelphi.ru                                         |
|==============================================================================|
| ЛИЦЕНЗИОННОЕ СОГЛАШЕНИЕ                                                      |
|==============================================================================|
| ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ», БЕЗ ЛЮБОГО ВИДА   |
| ГАРАНТИЙ, ЯВНО ВЫРАЖЕННЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ, НО НЕ ОГРАНИЧИВАЯСЬ  |
| ГАРАНТИЯМИ ТОВАРНОЙ ПРИГОДНОСТИ, СООТВЕТСТВИЯ ПО ЕГО КОНКРЕТНОМУ НАЗНАЧЕНИЮ  |
| И НЕНАРУШЕНИЯ ПРАВ. НИ В КАКОМ СЛУЧАЕ АВТОРЫ ИЛИ ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ    |
| ОТВЕТСТВЕННОСТИ ПО ИСКАМ О ВОЗМЕЩЕНИИ УЩЕРБА, УБЫТКОВ ИЛИ ДРУГИХ ТРЕБОВАНИЙ  |
| ПО ДЕЙСТВУЮЩИМ КОНТРАКТАМ, ДЕЛИКТАМ ИЛИ ИНОМУ, ВОЗНИКШИМ ИЗ, ИМЕЮЩИМ         |
| ПРИЧИНОЙ ИЛИ СВЯЗАННЫМ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ ИЛИ ИСПОЛЬЗОВАНИЕМ         |
| ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ ИЛИ ИНЫМИ ДЕЙСТВИЯМИ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ.    |
|                                                                              |
| This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF        |
| ANY KIND, either express or implied.                                         |
|==============================================================================|
| ОБНОВЛЕНИЯ КОМПОНЕНТА                                                        |
|==============================================================================|
| Последние обновления модуля GFeedBurner можно найти в репозитории по адресу: |
| http://github.com/googleapi                                                  |
|==============================================================================|
| История версий                                                               |
|==============================================================================|
|                                                                              |
|==============================================================================}
unit GFeedBurner;

interface

uses Windows,SysUtils, Classes, wininet, DateUtils, StrUtils, NativeXML,
     TypInfo;

resourcestring
  rsErrDate =      'Дата %s не может использоваться, так как она позднее текущей.';
  rsErrDateRange = 'Начальная дата не может быть больше конечной.';
  rsErrEntry =     'Недопустимое имя XML-узла. Имя узла должно быть <entry>';
  rsUnknownError = 'Неопознанная ошибка';
  rsFeedAPIError = 'Ошибка доступа к API. Код: %d; Описание: %s';
  rsRequestError = 'Ошибка выполнения HTTP-запроса';
  //API Errors
  rsAPIErr_1 = 'Канал не найден';
  rsAPIErr_2 = 'Этот канал не предоставляет доступ к Awareness API';
  rsAPIErr_3 = 'Элемент не найден в канале';
  rsAPIErr_4 = 'Данные ограничены; у этого канала не включена статистика FeedBurner Stats PRO';
  rsAPIErr_5 = 'Отсутствует необходимый параметр (URI)';
  rsAPIErr_6 = 'Неправильный параметр (DATES)';

const
  {версия модуля}
  GFeedBurnerVersion = 0.1;
  {шаблон URL для доступа к функциям API}
  AwaAPIParamURL = 'api/awareness/%s/%s';
  DateFormat = 'YYYY-MM-DD';
  APIVersion='1.0';
  MaxThrds = 10;

type
  TFeedBurner = class;
  TEntryCollection = class;
  TResyndicationData = class;
  TBasicEntry = class;


  TItemChangeEvent = procedure(Item: TCollectionItem) of object;
  TOnAPIRequestError = procedure (const Code:integer; Error: string) of object;
  TOnProgress = procedure(const Date: TDate; ThreadIdx:byte;
                                ProgressCurrent,ProgressMax:int64) of object;
  TOnDownload = TNotifyEvent;
  TOnThreadEnd = procedure(ThreadIdx:integer; Actives:byte)of object;
  TOnThreadStart = procedure (ThreadIdx:integer; Actives:byte) of object;
  TOnParseElement = procedure (Item:TBasicEntry) of object;


  EFeedBurner = class(Exception)
  private
    class var FAPILatErrCode: integer;
    class var FAPILastErrText: string;
  public
    class procedure ParseError(XMLNode: TXMLNode);overload;
    class procedure ParseError(XMLDoc: TNativeXML);overload;
    constructor CreateByXML(XMLDoc: TNativeXML);
  end;

  PDouble = ^double;
  TDateList = class(TList)
  private
    function GetItem(index:integer): TDate;
    procedure SetItem(index:integer;Value: TDate);
  public
    procedure Add(Date: TDate);
    procedure AddRange(StartDate,EndDate: TDate);
    procedure DeleteDuplicates;
    procedure SortDates;
    property  Items[Index: Integer]: TDate read GetItem write SetItem; default;
  end;


{Содержимое узла Entry при запросе GetFeedData}
 TBasicEntry = class(TCollectionItem)
  private
    Fdate: TDate;
    Fcirculation: integer;
    Fhits: integer;
    Freach: integer;
    Fdownloads: integer;
    FNode: TXMLNode;
    FResyndicationData: TResyndicationData;
  procedure SetNode(const Value: TXMLNode);virtual;
  procedure ParseXML(Node:TXMLNode);virtual;
  public
   constructor Create(Collection: TCollection);override;
   property Date: TDate read FDate;//дата за которую получены данные
   property Circulation: integer read FCirculation;//приблизительно количество людей, подписаых на фид
   property Hits: integer read FHits;//количество запросов данных из фида
   property Reach: integer read FReach;//охват аудитории
   property Downloads: integer read FDownloads;//количество закачек файлов
   property Node: TXMLNode read FNode write SetNode;//узел XML для разбора
   property FeedItems: TResyndicationData read FResyndicationData;
 end;

 TEntryCollection = class(TCollection)
  private
    FFeedBurner: TFeedBurner;
    FOnItemChange: TItemChangeEvent;
    function GetItem(Index: Integer): TBasicEntry;
    procedure SetItem(Index: Integer; const Value: TBasicEntry);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
    procedure DoItemChange(Item: TCollectionItem); dynamic;
  public
    constructor Create(FeedBurner: TFeedBurner);
    function Add: TBasicEntry;
    function IndexOf(Date: TDate):integer;
    property Items[Index: Integer]: TBasicEntry read GetItem write SetItem; default;
  published
    property OnItemChange: TItemChangeEvent read FOnItemChange write FOnItemChange;
  end;

 TItemData = class(TCollectionItem)
   private
     FTitle: string;
     FURL: string;
     FItemViews: integer;
     FClickThroughs: integer;
     FNode: TXMLNode;
     procedure ParseXML(Node: TXMLNode);virtual;
     procedure SetNode(aNode:TXmlNode);virtual;
   public
     constructor Create(Collection: TCollection);override;
     property Title: string read FTitle;
     property URL: string read FURL;
     property ItemViews: integer read FItemViews;
     property ClickThroughs: integer read FClickThroughs;
     property Node: TXMLNode read FNode write SetNode;
   end;

  TReferrer = class(TCollectionItem)
    private
      FItemViews: integer;
      FClickThroughs: integer;
      FURL : string;
      FNode: TXMLNode;
      procedure SetNode(aNode:TXMLNode);virtual;
      procedure ParseXML(Node: TXMLNode);virtual;
    public
     constructor Create(Collection: TCollection);override;
     property URL: string read FURL;
     property ItemViews: integer read FItemViews;
     property ClickThroughs: integer read FClickThroughs;
     property Node: TXMLNode read FNode write SetNode;
  end;

  TReferrerCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TReferrer;
    procedure SetItem(Index: Integer; const Value: TReferrer);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create;
    function Add: TReferrer;
    property Items[Index: Integer]: TReferrer read GetItem write SetItem; default;
 end;

  TResyndicationItem = class(TItemData)
  private
    FReferrers:TReferrerCollection;
    procedure ParseXML(Node: TXMLNode);override;
    procedure SetNode(aNode:TXmlNode);override;
  public
    constructor Create(Collection: TCollection);override;
    property Title;
    property URL;
    property ItemViews;
    property ClickThroughs;
    property Node;
    property Referrers: TReferrerCollection read FReferrers;
  end;

  TResyndicationData = class(TCollection)
  private
    function GetItem(Index: Integer): TResyndicationItem;
    procedure SetItem(Index: Integer; const Value: TResyndicationItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create();
    function Add: TResyndicationItem;
    property Items[Index: Integer]: TResyndicationItem read GetItem write SetItem; default;
 end;

  TRangeType = (trSingle, trDescrete, trContinued);

  TDateItem = class(TCollectionItem)
    private
      FStartDate: TDate;
      FEndDate  : TDate;
      FRangeType: TRangeType;
      procedure SetRangeType(Value:TRangeType);
      procedure SetEndDate(Value: TDate);
      procedure SetStartDate(Value: TDate);
      procedure Update;
    public
      constructor Create(Collection: TCollection);override;
    published
      property RangeType: TRangeType read FRangeType write SetRangeType;
      property StartDate: TDate read FStartDate write SetStartDate;
      property EndDate: TDate read FEndDate write SetEndDate;
  end;

  TTimeLine = class(TCollection)
  private
    FFeedBurner: TFeedBurner;
    function GetItem(Index: Integer): TDateItem;
    procedure SetItem(Index: Integer; const Value: TDateItem);
  protected
    procedure Update(Item: TCollectionItem); override;
    function GetOwner: TPersistent;
  public
    constructor Create(FeedBurner: TFeedBurner);
    function Add: TDateItem;
    property Items[Index: Integer]: TDateItem read GetItem write SetItem; default;
 end;

  TOperation = (toGetFeedData, toGetItemData, toGetResyndicationData);

  // поток используется только для получения XML-страницы
  TRSSThread = class(TThread)
  private
    FDate: TDate; //дата за которую необходимо получить данные
    FOperation: TOperation;//уровень статистики (операция)
    FURI: string; //URI блога для которого нужна статистика
    FIdx: integer; //индекс потока в массиве
    FParentComp:TFeedBurner;
    FParamStr  : string;
    FXMLDoc    : TNativeXML;
    FBasicEntry: TBasicEntry;
    Document: TMemoryStream;
    FProgress,FMaxProgress:cardinal;
    FOnProgress:TOnProgress;
    FOnThreadEnd:TOnThreadEnd;
    FOnParseElement: TOnParseElement;
    FOnThreadStart: TOnThreadStart;
    procedure SynProgress;// передача текушего прогресса авторизации в главную форму как положено в потоке
    procedure SynEndThread;
    function  XMLWithError(XMLDoc:TNativeXml):boolean;
    procedure GetParams;
  protected
    procedure Execute; override; // выполняем непосредственно авторизацию на сайте
  public
    constructor Create(CreateSuspennded: boolean; aParentComp:TFeedBurner;aIdx:integer;aDate:TDate;aOperation:TOperation;aURI:string);
  published
    property OnProgress: TOnProgress read FOnProgress write FOnProgress;//прогресс авторизации
    property OnThreadEnd:TOnThreadEnd read FOnThreadEnd write FOnThreadEnd;
    property OnParseElement: TOnParseElement read FOnParseElement write FOnParseElement;
    property OnThreadStart: TOnThreadStart read FOnThreadStart write FOnThreadStart;
  end;


  TFeedBurner = class(TComponent)
  private
     FThread : array of TRSSThread;
     FFeedURL: string;   //URL фида, например, http://feeds.feedburner.com/myDelphi
     Furi: string;       //URI фида, например, myDelphi
     FDates: TDateList; //список дат за которые необходимо получить статистику
     FFeedData:TEntryCollection;//данные по фиду
     FSilent: boolean;   //тихая обработка исключений API - все исключения API обрабатываются в событии
     FOnAPIRequestError:TOnAPIRequestError;//событие при возникновении исключения API
     FOnProgress: TOnProgress;
     FNextDateIdx: integer;
     FMaxThreads: byte;
     FAllThreads: byte;
     FAPIMethod: TOperation;
     FTimeLine  : TTimeLine;
     FOnParseElement: TOnParseElement;
     FOnThreadStart: TOnThreadStart;
     FOnThreadEnd:TOnThreadEnd;
     FOnDone : TOnDownload;
     procedure SetRange(const Value: TDateList);
     procedure SetFeedURL(const Value: string);
     procedure DoSilentError(XMLDoc:TNativeXml);
     procedure EndThread(ThreadIdx:integer; All:byte=0);
     procedure CreateThread(idx:integer; aDate:TDate);
     procedure SetMaxThreads(Value:byte);
     procedure SetTimeLine(Value: TTimeLine);
     procedure SetTimeLIme(const Value: TTimeLine);
     procedure GetDates;
  public
     constructor Create(AOwner: TComponent);override;
     procedure  Stop;
     procedure  Start;
     destructor Destroy;override;
     property   FeedData:TEntryCollection read FFeedData;
     property   Dates: TDateList read FDates;
   published
     property   APIMethod: TOperation read FAPIMethod write FAPIMethod;
     property   FeedURL: string read FFeedURL write SetFeedURL;
     property   SilentAPI: boolean read FSilent write FSilent;
     property   MaxThreads: byte read FMaxThreads write SetMaxThreads;
     property   TimeLine  : TTimeLine read FTimeLine write SetTimeLIme;
     property   OnAPIRequestError:TOnAPIRequestError read FOnAPIRequestError
                write FOnAPIRequestError;
     property   OnProgress:TOnProgress read FOnProgress write FOnProgress;
     property   OnParseElement: TOnParseElement read FOnParseElement write FOnParseElement;
     property   OnThreadStart: TOnThreadStart read FOnThreadStart write FOnThreadStart;
     property   OnThreadEnd:TOnThreadEnd read FOnThreadEnd write FOnThreadEnd;
     property   OnDone : TOnDownload read FOnDone write FOnDone;

end;

function Comparator(Item1, Item2: pointer): integer;inline;
procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('WebDelphi.ru',[TFeedBurner]);
end;

{ TFeedBurner }

constructor TFeedBurner.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFeedData:=TEntryCollection.Create(self);
  FDates:=TDateList.Create;
  FTimeLine:=TTimeLine.Create(self);
end;

procedure TFeedBurner.CreateThread(idx: integer; aDate:TDate);
begin
  if idx>(FDates.Count-1) then Exit;
  if (Length(FThread)-1)<idx then
    SetLength(FThread,Length(FThread)+1);
  FThread[idx]:= TRSSThread.Create(true,Self,idx,aDate,FAPIMethod,FURi);
  FThread[idx].OnProgress:=Self.OnProgress;
  FThread[idx].FreeOnTerminate := True;
  FThread[idx].FOnThreadEnd:=Self.EndThread;
  FThread[idx].FOnThreadStart:=Self.OnThreadStart;
  FThread[idx].FOnParseElement:=Self.OnParseElement;
  FThread[idx].Start;
  inc(FNextDateIdx);
  inc(FAllThreads);
  if Assigned(FOnThreadStart) then
     FOnThreadStart(Idx,FAllThreads);
end;

destructor TFeedBurner.Destroy;
begin
  FFeedData.Destroy;
  inherited Destroy;
end;

procedure TFeedBurner.DoSilentError(XMLDoc: TNativeXml);
begin
EFeedBurner.ParseError(XMLDoc);
if Assigned(FOnAPIRequestError) then
  FOnAPIRequestError(EFeedBurner.FAPILatErrCode,EFeedBurner.FAPILastErrText);
end;

procedure TFeedBurner.EndThread(ThreadIdx: integer; All:byte);
begin
 Dec(FAllThreads);

 if Assigned(FOnThreadEnd) then
   FOnThreadEnd(ThreadIdx,FAllThreads);

 FThread[ThreadIdx]:=nil;
 if FNextDateIdx<FDates.Count then
   begin
     if FAllThreads<FMaxThreads then
        CreateThread(ThreadIdx,FDates[FNextDateIdx]);
   end
 else
   if (FAllThreads=0)and(FNextDateIdx>=FDates.Count) then
     if Assigned(FOnDone) then
       FOnDone(Self);
end;

procedure TFeedBurner.GetDates;
var i: integer;
begin
  FDates.Clear;
  for I := 0 to FTimeLine.Count - 1 do
    begin
      case FTimeLine[i].RangeType of
        trSingle:FDates.Add(FTimeLine[i].StartDate);
        trDescrete:begin
                     FDates.Add(FTimeLine[i].StartDate);
                     FDates.Add(FTimeLine[i].EndDate);
                   end;
        trContinued:FDates.AddRange(FTimeLine[i].StartDate,FTimeLine[i].EndDate);
      end;
    end;
 FDates.DeleteDuplicates;
end;

procedure TFeedBurner.SetFeedURL(const Value: string);
var s:string;
begin
  FFeedURL:=Value;
  s:=ReverseString(FFeedURL);
  Furi:=ReverseString(Copy(s,1,pos('/',s)-1));
end;

procedure TFeedBurner.SetMaxThreads(Value: byte);
begin
  if (Value>MaxThreads) or (Value=0) then
    FMaxThreads:=MaxThrds
  else
    if Value<0 then
      FMaxThreads:=1
    else
      FMaxThreads:=Value;
end;

procedure TFeedBurner.SetRange(const Value: TDateList);
begin
  FDates.Assign(Value);
end;


procedure TFeedBurner.SetTimeLIme(const Value: TTimeLine);
begin
  FTimeLine.Assign(Value);;
end;

procedure TFeedBurner.SetTimeLine(Value: TTimeLine);
begin

end;

procedure TFeedBurner.Start;
var   i:integer;
begin
try
  GetDates;
  FFeedData.Clear;
  FThread:=nil;
  FNextDateIdx:=0;
  FAllThreads:=0;
  i:=0;
  repeat
      CreateThread(i,FDates[i]);
      inc(i);
  until (i=FDates.Count) or(i=FMaxThreads);
finally
end;
end;

procedure TFeedBurner.Stop;
var i:integer;
begin
try
  for I:=0 to Length(FThread) - 1 do
    begin
      if TerminateThread(FThread[i].Handle,0) then
        if Assigned(FOnThreadEnd)then
          FOnThreadEnd(i,FAllThreads);
    end;
  FAllThreads:=0;
  if Assigned(FOnDone) then
    FOnDone(self);
finally
  FThread:=nil
end;
end;

{ TBasicEntry }

constructor TBasicEntry.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FResyndicationData:=TResyndicationData.Create();
end;

procedure TBasicEntry.ParseXML(Node: TXMLNode);
var FormatSet: TFormatSettings;
    i:integer;
    List:TXMLNodeList;
begin
  if Node=nil then Exit;

  if LowerCase(Node.Name)<>'entry' then
    raise EFeedBurner.Create(rsErrEntry);

  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, FormatSet);
  FormatSet.DateSeparator := '-';
  FormatSet.ShortDateFormat := DateFormat;
  FDate := StrToDate(Node.ReadAttributeString('date'), FormatSet);

  Fcirculation:=Node.ReadAttributeInteger('circulation');
  Fhits:=Node.ReadAttributeInteger('hits');
  Freach:=Node.ReadAttributeInteger('reach');
  Fdownloads:=Node.ReadAttributeInteger('downloads');

  List:=TXmlNodeList.Create;
  Node.NodesByName('item',List);
  for I := 0 to List.Count - 1 do
    begin
      FResyndicationData.Add.Node:=List[i]
    end;
  Changed(false);
end;

procedure TBasicEntry.SetNode(const Value: TXMLNode);
begin
  if FNode<>Value then
    begin
      FNode := Value;
      ParseXML(Node);
    end;
end;

{ TFeedData }

function TEntryCollection.Add: TBasicEntry;
begin
  Result := TBasicEntry(inherited Add)
end;

constructor TEntryCollection.Create(FeedBurner: TFeedBurner);
begin
  inherited Create(TBasicEntry);
  FeedBurner := FeedBurner;
end;

procedure TEntryCollection.DoItemChange(Item: TCollectionItem);
begin
  if Assigned(FOnItemChange) then
    FOnItemChange(Item)
end;

function TEntryCollection.GetItem(Index: Integer): TBasicEntry;
begin
  Result := TBasicEntry(inherited GetItem(Index))
end;

function TEntryCollection.GetOwner: TPersistent;
begin
  Result := FFeedBurner
end;

function TEntryCollection.IndexOf(Date: TDate): integer;
var i:integer;
begin
Result:=-1;
  for I := 0 to Self.Count - 1 do
    begin
      if Trunc(GetItem(i).Fdate)=Trunc(Date) then
        begin
          Result:=i;
          break;
        end;
    end;
end;

procedure TEntryCollection.SetItem(Index: Integer; const Value: TBasicEntry);
begin
  inherited SetItem(Index, Value)
end;

procedure TEntryCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  DoItemChange(Item)
end;

{ EFeedBurner }

constructor EFeedBurner.CreateByXML(XMLDoc: TNativeXML);
begin
  ParseError(XMLDoc);
  CreateFmt(rsFeedAPIError,[FAPILatErrCode,FAPILastErrText]);
end;

class procedure EFeedBurner.ParseError(XMLNode: TXMLNode);
begin
  FAPILatErrCode:=XMLNode.ReadAttributeInteger('code');
  case FAPILatErrCode of
    1:FAPILastErrText:=rsAPIErr_1;
    2:FAPILastErrText:=rsAPIErr_2;
    3:FAPILastErrText:=rsAPIErr_3;
    4:FAPILastErrText:=rsAPIErr_4;
    5:FAPILastErrText:=rsAPIErr_5;
    6:FAPILastErrText:=rsAPIErr_6;
  else
    FAPILastErrText:=XMLNode.ReadAttributeString('msg')
  end;
end;

class procedure EFeedBurner.ParseError(XMLDoc: TNativeXML);
var Node:TXMLNode;
begin
  if XMLDoc=nil then
    raise Exception.Create(rsUnknownError);
  Node:=XMLDoc.Root.NodeByName('err');
  if Node=nil then
    raise Exception.Create(rsUnknownError);
  ParseError(Node);
end;

{ TItemData }

constructor TItemData.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

procedure TItemData.ParseXML(Node: TXMLNode);
begin
  if Node=nil then Exit;
  if LowerCase(Node.Name)<>'item' then
    raise EFeedBurner.Create(rsErrEntry);
  FTitle:=Node.ReadAttributeString('title');
  FURL:=Node.ReadAttributeString('url');
  FItemViews:=Node.ReadAttributeInteger('itemviews');
  FClickThroughs:=Node.ReadAttributeInteger('clickthroughs');
end;

procedure TItemData.SetNode(aNode: TXmlNode);
begin
  if aNode=nil then Exit;
  if aNode<>FNode then
    begin
      FNode:=aNode;
      ParseXML(FNode);
    end;
end;

{ TReferrer }

constructor TReferrer.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

procedure TReferrer.ParseXML(Node: TXMLNode);
begin
if Node=nil then Exit;
  if LowerCase(Node.Name)<>'referrer' then
    raise EFeedBurner.Create(rsErrEntry);
  FURL:=Node.ReadAttributeString('url');
  FItemViews:=Node.ReadAttributeInteger('itemviews');
  FClickThroughs:=Node.ReadAttributeInteger('clickthroughs');
end;

procedure TReferrer.SetNode(aNode: TXMLNode);
begin
if aNode=nil then Exit;
  if aNode<>FNode then
    begin
      FNode:=aNode;
      ParseXML(FNode);
    end;
end;

{ TReferrerCollection }

function TReferrerCollection.Add: TReferrer;
begin
Result := TReferrer(inherited Add)
end;

constructor TReferrerCollection.Create();
begin
  inherited Create(TReferrer);
end;

function TReferrerCollection.GetItem(Index: Integer): TReferrer;
begin
  Result := TReferrer(inherited GetItem(Index))
end;

procedure TReferrerCollection.SetItem(Index: Integer; const Value: TReferrer);
begin
inherited SetItem(Index, Value)
end;

procedure TReferrerCollection.Update(Item: TCollectionItem);
begin
 inherited Update(Item);
end;

{ TResyndicationItem }

constructor TResyndicationItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FReferrers:=TReferrerCollection.Create();
end;

procedure TResyndicationItem.ParseXML(Node: TXMLNode);
var i: integer;
    List:TXMLNodeList;
begin
  if Node=nil then Exit;
  inherited ParseXML(Node);
  List:=TXmlNodeList.Create;
  Node.NodesByName('referrer',List);
  for i:=0 to List.Count-1 do
    FReferrers.Add.Node:=List[i]

end;

procedure TResyndicationItem.SetNode(aNode: TXmlNode);
begin
  if aNode=nil then Exit;
  if aNode<>FNode then
    begin
      FNode:=aNode;
      ParseXML(FNode);
    end;
end;

{ TResyndicationData }

function TResyndicationData.Add: TResyndicationItem;
begin
  Result := TResyndicationItem(inherited Add)
end;

constructor TResyndicationData.Create();
begin
  inherited Create(TResyndicationItem);
end;

function TResyndicationData.GetItem(Index: Integer): TResyndicationItem;
begin
  Result := TResyndicationItem(inherited GetItem(Index))
end;


procedure TResyndicationData.SetItem(Index: Integer;
  const Value: TResyndicationItem);
begin
 inherited SetItem(Index, Value)
end;

procedure TResyndicationData.Update(Item: TCollectionItem);
begin
 inherited Update(Item);
end;

{ TRSSThread }

constructor TRSSThread.Create(CreateSuspennded: boolean;aParentComp: TFeedBurner;aIdx:integer;
                              aDate:TDate;aOperation:TOperation;aURI:string);
begin
  inherited Create(CreateSuspennded);
  FParentComp:=aParentComp;
  FDate := aDate;
  FOperation:=aOperation;
  FURI:=aURI;
  FIdx:=aIdx;
  FProgress:=0;
  FMaxProgress:=0;
  Document:=TMemoryStream.Create;
  FXMLDoc:=TNativeXml.Create;
  FBasicEntry:=TBasicEntry.Create(FParentComp.FeedData);
  GetParams;
end;

function GetUrlSize(const URL:string):integer;//результат в байтах
var
  hSession,hFile:hInternet;
  dwBuffer:array[1..20] of char;
  dwBufferLen,dwIndex:cardinal;
begin
Result:=0;
hSession:=InternetOpen('GetUrlSize',INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
if Assigned(hSession) then
begin
 hFile:=InternetOpenURL(hSession,PChar(URL),nil,0,INTERNET_FLAG_RELOAD,0);
 dwIndex:=0;
 dwBufferLen:=20;
 if HttpQueryInfo(hFile,HTTP_QUERY_CONTENT_LENGTH,@dwBuffer,dwBufferLen, dwIndex) then
    Result:=StrToInt(PChar(@dwBuffer));

 if Assigned(hFile) then InternetCloseHandle(hFile);
   InternetCloseHandle(hsession);
end;
end;

procedure TRSSThread.Execute;
var
  hInternet, hConnect, hRequest: pointer;
  dwBytesRead,i: cardinal;
  Buffer: array [0 .. 255] of Byte;
begin
  try
    Document.Clear;
    hInternet := InternetOpen(PChar('FeedBurner'),
      INTERNET_OPEN_TYPE_PRECONFIG, Nil, Nil, 0);
    if Assigned(hInternet) then
    begin
      // Открываем сессию
      hConnect := InternetConnect(hInternet,PChar('feedburner.google.com'),
                                  INTERNET_DEFAULT_HTTP_PORT,nil,nil,
                                  INTERNET_SERVICE_HTTP,0,1);
      if Assigned(hConnect) then
      begin
        // Формируем запрос
        hRequest := HttpOpenRequest(hConnect,PChar('GET'),
                      PChar(FParamStr),
                      HTTP_VERSION,nil,Nil,INTERNET_FLAG_RELOAD or
                      INTERNET_FLAG_NO_CACHE_WRITE or
                      INTERNET_FLAG_PRAGMA_NOCACHE or
                      INTERNET_FLAG_KEEP_CONNECTION, 1);
        if Assigned(hRequest) then
        begin
          FMaxProgress:=GetUrlSize('http://feedburner.google.com/'+FParamStr);
          if HttpSendRequest(hRequest, nil, 0, nil, 0) then
          begin
            repeat
              if Terminated then // проверка для экстренного закрытия потока
              begin
                InternetCloseHandle(hRequest);
                InternetCloseHandle(hConnect);
                InternetCloseHandle(hInternet);
                FreeAndNil(Document);
                FreeAndNil(FXMLDoc);
                Exit;
              end;
              FillChar(Buffer, SizeOf(Buffer), 0);
              if not InternetReadFile(hRequest, @Buffer, Length(Buffer), dwBytesRead) then
                Exit
              else
               Document.Write(Buffer, dwBytesRead);
               FProgress := Document.Size;
               Synchronize(SynProgress);
            until dwBytesRead = 0;
            Document.Position:=0;
          end;
        end;
      end;
    end;
  except
    InternetCloseHandle(hRequest);
    InternetCloseHandle(hConnect);
    InternetCloseHandle(hInternet);
    exit;
  end;

 FXMLDoc.LoadFromStream(Document);

if XMLWithError(FXMLDoc) then
  begin
    if FParentComp.FSilent then
      FParentComp.DoSilentError(FXMLDoc)
    else
      raise
        EFeedBurner.CreateByXML(FXMLDoc);
    FBasicEntry.Destroy;
  end
 else
   begin
     FBasicEntry.Node:=FXMLDoc.Root.NodeByName('feed').NodeByName('entry');
     if Assigned(FOnParseElement) then
       FOnParseElement(FBasicEntry);
   end;
FreeAndNil(Document);
FreeAndNil(FXMLDoc);
Synchronize(SynEndThread);
end;

procedure TRSSThread.GetParams;
var Oper, Date: string;
begin
  //составление параметров запроса
  Oper:='';
  Date:='';
  Oper:=GetEnumName(TypeInfo(TOperation),ord(FOperation));
  Delete(Oper,1,2);
  if FDate>0 then
    Date:='&dates='+FormatDateTime(DateFormat,FDate);
  FParamStr:=Format(AwaAPIParamURL,[APIVersion,Oper+'?uri='+FURI+Date])
end;

procedure TRSSThread.SynEndThread;
begin
  if Assigned(FOnThreadEnd) then
    FOnThreadEnd(FIdx,FParentComp.FAllThreads);
end;

procedure TRSSThread.SynProgress;
begin
if Assigned(FOnProgress) then
   OnProgress(FDate,FIdx,FProgress,FMaxProgress); // передаем прогресс авторизации
end;

function TRSSThread.XMLWithError(XMLDoc: TNativeXml): boolean;
begin
result:=true;
  if XMLDoc=nil then exit;
  if Document.Size=0 then Exit;

  if XMLDoc.Root.HasAttribute('stat') then
    Result:=XMLDoc.Root.ReadAttributeString('stat')='fail'
  else
    begin
      raise EFeedBurner.Create(rsRequestError);
    end;
end;

{ TDateList }

procedure TDateList.Add(Date: TDate);
var pD: PDouble;
begin
  new(pD);
  pD^:=Date;
  Self.Insert(Self.Count,pD);
end;

procedure TDateList.AddRange(StartDate, EndDate: TDate);
var i:integer;
begin
  for i:=0 to DaysBetween(StartDate,EndDate) do
    Add(IncDay(StartDate,i));
end;

function Comparator(Item1, Item2: pointer): integer;inline;
begin
  if PDouble(Item1)^<PDouble(Item2)^ then
    Result:=-1
  else
    if PDouble(Item1)^>PDouble(Item2)^ then
      Result:=1
    else
      Result:=0;
end;

procedure TDateList.DeleteDuplicates;
var i:integer;
    b:boolean;
begin
  b:=true;
  Self.Sort(Comparator);
  while b do
    begin
      i:=1;
      while i<Count do
        begin
          b:=Items[i]=Items[i-1];
          if b then Delete(i)
               else inc(i);
        end;
    end;
  Pack;
end;

function TDateList.GetItem(index:integer): TDate;
var pD:PDouble;
begin
  if Index>=Count then Exit;
  pD:=Get(index);
  Result:=pD^;
end;

procedure TDateList.SetItem(index:integer;Value: TDate);
begin
  if Index<0 then Exit;
  Add(Value);
end;

procedure TDateList.SortDates;
begin
  Self.Sort(Comparator);
end;

{ TDateItem }

constructor TDateItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FStartDate:=Now;
  FEndDate:=Now;
  FRangeType:=trSingle;
end;

procedure TDateItem.SetEndDate(Value: TDate);
begin
  if Value<FStartDate then
    FEndDate:=FStartDate
  else
    FEndDate:=Value;
 Update;
end;

procedure TDateItem.SetRangeType(Value: TRangeType);
begin
  if FStartDate=FEndDate then
    FRangeType:=trSingle
  else
    FRangeType:=Value;
  if Value=trSingle then
    FEndDate:=FStartDate;
end;

procedure TDateItem.SetStartDate(Value: TDate);
begin
  if Value>FEndDate then
    FStartDate:=FEndDate
  else
    FStartDate:=Value;
  Update;
end;

procedure TDateItem.Update;
begin
  if FEndDate=FStartDate then
    FRangeType:=trSingle
  else
    if FRangeType=trSingle then
      FRangeType:=trContinued
end;

{ TTimeLine }

function TTimeLine.Add: TDateItem;
begin
  result:=TDateItem(inherited Add)
end;

constructor TTimeLine.Create(FeedBurner: TFeedBurner);
begin
  inherited Create(TDateItem);
  FFeedBurner:=FeedBurner;
end;

function TTimeLine.GetItem(Index: Integer): TDateItem;
begin
  Result := TDateItem(inherited GetItem(Index))
end;

function TTimeLine.GetOwner: TPersistent;
begin
  Result:=FFeedBurner
end;

procedure TTimeLine.SetItem(Index: Integer; const Value: TDateItem);
begin
  inherited SetItem(Index, Value)
end;

procedure TTimeLine.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
end;

end.
