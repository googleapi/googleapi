unit GCalendar;

interface

uses WinInet, GData, Graphics, strutils, httpsend, GHelper, XMLIntf,
  GoogleLogin, Windows,  SysUtils, Variants, Classes, Dialogs,
  StdCtrls, XMLDoc, xmldom, Generics.Collections, msxml, GDataCommon;

const
  AllCelendarsLink  ='http://www.google.com/calendar/feeds/default/allcalendars/full';
  OwnerCelendarLink ='http://www.google.com/calendar/feeds/default/owncalendars/full';

  cgCalTagNames: array [0 .. 15] of string = ('gCal:accesslevel', 'gCal:color',
    'gCal:hidden', 'gCal:selected', 'gCal:settingsProperty', 'gCal:sequence',
    'gCal:suppressReplyNotifications', 'gCal:syncEvent', 'gCal:timezone',
    'gCal:timesCleaned', 'gCal:uid', 'gCal:webContent',
    'gCal:webContentGadgetPrefss', 'gCal:guestsCanModify',
    'gCal:guestsCanInviteOthers', 'gCal:guestsCanSeeGuests');

  clNameSpaces: array [0 .. 2, 0 .. 1] of string =
    (('', 'http://www.w3.org/2005/Atom'), ('gd',
      'http://schemas.google.com/g/2005'), ('gCal',
      'http://schemas.google.com/gCal/2005'));
  clCategories: array [0 .. 1, 0 .. 1] of string = (('scheme',
      'http://schemas.google.com/g/2005#kind'), ('term',
      'http://schemas.google.com/g/2005#event'));

 clEventRequareTags :array [0..19]of string=('id',
 'published','updated','title','link','content','author','gd:eventStatus',
 'gd:where','gd:who','gd:when','gd:recurrence','gd:reminder',
 'gd:transparency','gd:visibility','gCal:guestsCanInviteOthers',
 'gCal:guestsCanModify','gCal:guestsCanSeeGuests','gCal:sequence','gCal:uid');

type
  TgCalEnum = (egCalaccesslevel, egCalcolor, egCalhidden, egCalselected,
    egCalsettingsProperty, egCalsequence, egCalsuppressReplyNotifications,
    egCalsyncEvent, egCaltimezone, egCaltimesCleaned, egCaluid,
    egCalwebContent, egCalwebContentGadgetPrefss, egCalguestsCanModify,
    egCalguestsCanInviteOthers, egCalguestsCanSeeGuests);

const
  cgCalaccesslevel: array [0 .. 5] of string =
    ('none', 'read', 'freebusy', 'editor', 'owner', 'root');

type
  TAccessLevel = (alNone, alRead, alFreebusy, alEditor, alOwner, alRoot);

type
  TgCalsuppressReplyNotifications = class(TPersistent)
  private
    FValue: boolean;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root: IXMLNode): IXMLNode;
    property Value: boolean read FValue write FValue;
  end;

type
  TgCalsyncEvent = class(TPersistent)
  private
    FValue: boolean;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root: IXMLNode): IXMLNode;
    property Value: boolean read FValue write FValue;
  end;

type
  TgCaluid = class(TPersistent)
  private
    FValue: string;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root: IXMLNode): IXMLNode;
    property Value: string read FValue write FValue;
  end;

type
  TgCalsequence = class(TPersistent)
  private
    FValue: integer;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root: IXMLNode): IXMLNode;
    property Value: integer read FValue write FValue;
  end;

type
  TgCalguestsCanSeeGuests = class(TPersistent)
  private
    FValue: boolean;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root: IXMLNode): IXMLNode;
    property Value: boolean read FValue write FValue;
  end;

type
  TgCalguestsCanInviteOthers = class(TPersistent)
  private
    FValue: boolean;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root: IXMLNode): IXMLNode;
    property Value: boolean read FValue write FValue;
  end;

type
  TgCalguestsCanModify = class(TPersistent)
  private
    FValue: boolean;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root: IXMLNode): IXMLNode;
    property Value: boolean read FValue write FValue;
  end;

type
  TgCalwebContent = packed record
    // atom:link Properties
    rel: string;
    title: string;
    href: string;
    typ: string;
    // Properties
    height: integer;
    width: integer;
    url: string;
  end;

type
  TgCalwebContentGadgetPrefs = packed record
    Name: string;
    Value: string;
  end;

type
  TCelendarLink = packed record
    rel: string;
    ltype: string;
    href: string;
  end;

type
  TCelendarLinksList = TList<TCelendarLink>;

type
  TAuthorTag = Class(TPersistent)
  private
    FAuthor: string;
    FEmail : string;
    FUID   : string;
  public
    constructor Create(ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    property Author: string read FAuthor write FAuthor;
    property Email: string read FEmail write FEmail;
  end;

type
  TgCaltimezone = Class(TPersistent)
  private
    FValue: string;
    FDescription: string;
    FGMT: extended;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root: IXMLNode): IXMLNode;
    property Value: string read FValue write FValue;
    property Description: string read FDescription write FDescription;
    property GMT: extended read FGMT write FGMT;
  end;

type
  TgCalHidden = class(TPersistent)
  private
    FValue: boolean;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root: IXMLNode): IXMLNode;
    property Value: boolean read FValue write FValue;
  end;

type
  TgCalcolor = class(TPersistent)
  private
    FValue: string;
    FColor: TColor;
    procedure SetColor(aColor: TColor);
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root: IXMLNode): IXMLNode;
    property Value: string read FValue write FValue;
    property Color: TColor read FColor write SetColor;
  end;

type
  TgCalselected = class(TPersistent)
  private
    FValue: boolean;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    property Value: boolean read FValue write FValue;
  end;

type
  TgCalAccessLevel = class(TPersistent)
  private
    FValue: string;
    FLevel: TAccessLevel;
    procedure SetLevel(aLevel: TAccessLevel);
    procedure SetValue(aValue: string);
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    property Value: string read FValue write SetValue;
    property Level: TAccessLevel read FLevel write SetLevel;
  end;

type
  TgCaltimesCleaned = class(TPersistent)
  private
    FValue: integer;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    property Value: integer read FValue write FValue;
  end;

type
  TAttribute = packed record
    Name: string;
    Value: string;
  end;

type
  TTextTag = class(TPersistent)
  private
    FName: string;
    FValue: string;
    FAttributes: TList<TAttribute>;
  public
    Constructor Create(const ByNode: IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root: IXMLNode): IXMLNode;
    property Value: string read FValue write FValue;
    property Name: string read FName write FName;
    property Attributes: TList<TAttribute>read FAttributes write FAttributes;
  end;

type
  TCelenrarEvent = class
  private
    Fid: string;
    FEtag: string;
    FAuth: string;
    Fpublished: TDateTime;
    Fupdated: TDateTime;
    FTitle: TTextTag;
    FDescription: TTextTag;
    FLinks: TCelendarLinksList; // ссылки события
    FAuthor: TAuthorTag;
    FeventStatus: TgdEventStatus;
    Fwhere: TgdWhere;
    Fwhen: TgdWhen;
    Fwho: TgdWho;
    Frecurrence: TgdRecurrence;
    Freminders: TList<TgdReminder>;
    Ftransparency: TgdTransparency;
    Fvisibility: TgdVisibility;
    FguestsCanInviteOthers: TgCalguestsCanInviteOthers;
    FguestsCanModify: TgCalguestsCanModify;
    FguestsCanSeeGuests: TgCalguestsCanSeeGuests;
    Fsequence: TgCalsequence;
    Fuid: TgCaluid;
    procedure AddLink(const aNode: IXMLNode);
    procedure AddRemainder(const aNode: IXMLNode);
    procedure RetriveETag(const aLink: string);
    procedure InsertCategory(Root: IXMLNode);
    function GetEditURL: string;
    function GetTitle: string;
    procedure SetTitle(aTitle:string);
    function GetDescription: string;
    procedure SetDescription(aDescr: string);
  public
    constructor Create(const ByNode: IXMLNode=nil; aAuth: string='');overload;
    destructor Destroy;
    procedure ParseXML(Node: IXMLNode);
    function Update:boolean;
    function DeleteThis:boolean;
    property ID: string read Fid;
    property Etag: string read FEtag;
    property PublishedTime: TDateTime read Fpublished;
    property UpdateTime: TDateTime read Fupdated;
    property Title: string read GetTitle write SetTitle;
    property Description: string read GetDescription write SetDescription;
    property Links: TCelendarLinksList read FLinks;
    property Author: TAuthorTag read FAuthor write FAuthor;
    property EventStatus: TgdEventStatus read FeventStatus write FeventStatus;
    property Where: TgdWhere read Fwhere write Fwhere;
    property When: TgdWhen read Fwhen write Fwhen;
    property Who: TgdWho read Fwho write Fwho;
    property Recurrence: TgdRecurrence read Frecurrence write Frecurrence;
    property Reminders: TList<TgdReminder> read Freminders write Freminders;
    property Transparency
      : TgdTransparency read Ftransparency write Ftransparency;
    property Visibility: TgdVisibility read Fvisibility write Fvisibility;
    property GuestsCanInviteOthers
      : TgCalguestsCanInviteOthers read FguestsCanInviteOthers write
      FguestsCanInviteOthers;
    property GuestsCanModify: TgCalguestsCanModify read FguestsCanModify write
      FguestsCanModify;
    property GuestsCanSeeGuests
      : TgCalguestsCanSeeGuests read FguestsCanSeeGuests write
      FguestsCanSeeGuests;
    property Sequence: TgCalsequence read Fsequence write Fsequence;
    property UID: TgCaluid read Fuid;
  end;

type
  TCelendar = class
  private
    FAuth: string;
    Fid: string;
    FEtag: string;
    FTitle: TTextTag;
    FDescription: TTextTag;
    FLinks: TCelendarLinksList; // ссылки календаря
    FAuthor: TAuthorTag;
    Ftimezone: TgCaltimezone;
    Fpublished: TDateTime;
    Fupdated: TDateTime;
    Fhidden: TgCalHidden;
    FVColor: TgCalcolor;
    Fselected: TgCalselected;
    Faccesslevel: TgCalAccessLevel;
    Fwhere: TgdWhere;
    FgCaltimesCleaned: TgCaltimesCleaned;
    FEvents: TList<TCelenrarEvent>;
    procedure AddLink(const aNode: IXMLNode);
    function GetLink(index: integer): TCelendarLink;
    procedure SetLink(i: integer; Link: TCelendarLink);
    function GetLinksCount: integer;
    function GetEvent(i: integer): TCelenrarEvent;
    procedure InsertCategory(Root: IXMLNode);
    function GetEventFeedLink: string;
    function GetEventCount: integer;
    function GetTitle:string;
    function GetDescription: string;
    procedure SetTitle(aTitle: string);
    procedure SetDescription(aDescr: string);
  public
    constructor Create(const ByNode: IXMLNode=nil; aAuth: string='');
    procedure ParseXML(Node: IXMLNode);
    function AddSingleEvent(aEvent: TCelenrarEvent): boolean;
    function RetrieveEvents: integer;
    function SendToGoogle(const GoogleAuth: string): boolean;
    property Auth: string read FAuth write FAuth;
    property title: string read GetTitle write SetTitle;
    property Description: string read GetDescription write SetDescription;
    property LinkCount: integer read GetLinksCount;
    property Link[i: integer]: TCelendarLink read GetLink write SetLink;
    property Author: TAuthorTag read FAuthor write FAuthor;
    property TimeZone: TgCaltimezone read Ftimezone write Ftimezone;
    property PublishedTime: TDateTime read Fpublished write Fpublished;
    property UpdatedTime: TDateTime read Fupdated write Fupdated;
    property Hidden: TgCalHidden read Fhidden write Fhidden;
    property Color: TgCalcolor read FVColor write FVColor;
    property Selected: TgCalselected read Fselected write Fselected;
    property AccessLevel: TgCalAccessLevel read Faccesslevel write Faccesslevel;
    property Where: TgdWhere read Fwhere write Fwhere;
    property TimesCleaned: TgCaltimesCleaned read FgCaltimesCleaned write
      FgCaltimesCleaned;
    property Event[i: integer]: TCelenrarEvent read GetEvent;
    property EventCount: integer read GetEventCount;
  end;

type
  TCelendarList = TList<TCelendar>;

type
  TGoogleCalendar = class
  private
    FAccount: TGoogleLogin;
    FCelendars: TCelendarList; // календари пользователя
  public
    constructor Create(const Email, password: string);
    function Login: boolean;
    procedure RetriveCelendars(const Owner: boolean);
    property Account: TGoogleLogin read FAccount write FAccount;
    property AllCelendars: TCelendarList read FCelendars;
  end;

function GetGClalNodeType(NodeName: string): TgCalEnum;

implementation

function GetGClalNodeType(NodeName: string): TgCalEnum;
var
  i: integer;
begin
  i := AnsiIndexStr(NodeName, cgCalTagNames);
  if i > - 1 then
    Result := TgCalEnum(i)
end;

{ TGoogleCalengar }

constructor TGoogleCalendar.Create(const Email, password: string);
begin
  inherited Create;
  try
    FAccount:= TGoogleLogin.Create(Email, password);
    FAccount.Service := 'cl';
    FAccount.Source := DefoultAppName;
    FCelendars := TCelendarList.Create;
  except
    Destroy;
  end;
end;

function TGoogleCalendar.Login: boolean;
begin
  FAccount.Login();
  if Account.LastResult = lrOk then
    Result := true
  else
    Result := false;
end;

procedure TGoogleCalendar.RetriveCelendars(const Owner: boolean);
var
  Doc: IXMLDocument;
  i: integer;
begin
  FCelendars.Clear;
  Doc := NewXMLDocument();
  if not Owner then
    Doc.LoadFromStream(SendRequest('GET',AllCelendarsLink, FAccount.Auth))
  else
    Doc.LoadFromStream(SendRequest('GET',OwnerCelendarLink, FAccount.Auth));
  for i := 0 to Doc.DocumentElement.ChildNodes.Count - 1 do
    if LowerCase(Doc.DocumentElement.ChildNodes[i].NodeName) = 'entry' then
      FCelendars.Add(TCelendar.Create(Doc.DocumentElement.ChildNodes[i], FAccount.Auth));
end;

{ TCelendar }

procedure TCelendar.AddLink(const aNode: IXMLNode);
var
  Link: TCelendarLink;
begin
  try
    Link.rel := aNode.Attributes['rel'];
    Link.ltype := aNode.Attributes['type'];
    Link.href := aNode.Attributes['href'];
    FLinks.Add(Link);
  except
    Exception.Create(Format(rcErrReadNode, [aNode.NodeName]));
  end;
end;

function TCelendar.AddSingleEvent(aEvent: TCelenrarEvent): boolean;
var
  aDoc: IXMLDocument;
  Root, WhenNode: IXMLNode;
  i: integer;
 Stream: TStream;
begin
  aDoc := NewXMLDocument();
  aDoc.Active := true;
  Root := aDoc.AddChild('entry');
  for i := 0 to High(clNameSpaces) - 1 do
    Root.DeclareNamespace(clNameSpaces[i, 0], clNameSpaces[i, 1]);
  InsertCategory(Root);
  aEvent.FTitle.AddToXML(Root);
  aEvent.FDescription.AddToXML(Root);
  aEvent.Ftransparency.AddToXML(Root);
  aEvent.FeventStatus.AddToXML(Root);
  aEvent.Fwhere.AddToXML(Root);
  WhenNode := aEvent.Fwhen.AddToXML(Root);
  if aEvent.Freminders.Count > 0 then
    for i := 0 to aEvent.Freminders.Count - 1 do
      aEvent.Freminders[i].AddToXML(WhenNode);
 Stream:=TStringStream.Create('');
 aDoc.SaveToStream(Stream);
if length(GetEventFeedLink) > 0 then
 aDoc.LoadFromStream(SendRequest('POST', GetEventFeedLink, FAuth,Stream));
Result:=aDoc.DocumentElement.ChildNodes.FindNode('entry')<>nil;
end;

constructor TCelendar.Create(const ByNode: IXMLNode; aAuth: string);
begin
  inherited Create;
  FAuth := aAuth;
  FLinks := TCelendarLinksList.Create;
  FAuthor := TAuthorTag.Create(nil);
  Ftimezone := TgCaltimezone.Create(nil);
  Fhidden := TgCalHidden.Create(nil);
  FVColor := TgCalcolor.Create(nil);
  Faccesslevel := TgCalAccessLevel.Create(nil);
  FgCaltimesCleaned := TgCaltimesCleaned.Create(nil);
  FTitle := TTextTag.Create(nil);
  FDescription := TTextTag.Create(nil);
  Fwhere := TgdWhere.Create(nil);
  FEvents := TList<TCelenrarEvent>.Create;
  Fselected := TgCalselected.Create(nil);
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

function TCelendar.GetDescription: string;
begin
  Result:=FDescription.Value
end;

function TCelendar.GetEvent(i: integer): TCelenrarEvent;
begin
  if (i <= FEvents.Count) and (i > - 1) then
    Result := FEvents[i]
  else
    raise Exception.Create(rcErrMissAgrument);
end;

function TCelendar.GetEventCount: integer;
begin
  Result:=FEvents.Count;
end;

function TCelendar.GetEventFeedLink: string;
var
  i: integer;
begin
  Result := '';
  if FLinks.Count = 0 then
    Exit;
  for i := 0 to FLinks.Count - 1 do
    if FLinks[i].rel = 'http://schemas.google.com/gCal/2005#eventFeed' then
    begin
      Result := FLinks[i].href;
      break;
    end;
end;

function TCelendar.GetLink(index: integer): TCelendarLink;
begin
  Result := FLinks.Items[index];
end;

function TCelendar.GetLinksCount: integer;
begin
  Result := FLinks.Count
end;

function TCelendar.GetTitle: string;
begin
  Result:=FTitle.Value;
end;

procedure TCelendar.InsertCategory(Root: IXMLNode);
var
  Node: IXMLNode;
begin
  Node := Root.OwnerDocument.CreateElement('category',
    'http://www.w3.org/2005/Atom'); // создали узел
  Node.Attributes[clCategories[0, 0]] := clCategories[0, 1];
  // присвоили значение
  Node.Attributes[clCategories[1, 0]] := clCategories[1, 1];
  // присвоили значение
  Root.ChildNodes.Add(Node); // записали документ
end;

procedure TCelendar.ParseXML(Node: IXMLNode);
var
  j, index: integer;
  Entry: IXMLNodeList;
begin
  if Node = nil then
    Exit;
  Entry := Node.ChildNodes;
  FEtag := Node.Attributes['gd:etag'];
  for j := 0 to Entry.Count - 1 do
  begin
    if Entry.Get(j).NodeName = 'id' then
      Fid := Entry.Get(j).NodeValue
    else
      if Entry.Get(j).NodeName = 'title' then
        FTitle.ParseXML(Entry.Get(j))
      else
        if Entry.Get(j).NodeName = 'summary' then
          FDescription.ParseXML(Entry.Get(j))
        else
          if Entry.Get(j).NodeName = 'published' then
            Fpublished := ServerDateToDateTime(Entry.Get(j).NodeValue)
          else
            if Entry.Get(j).NodeName = 'updated' then
              Fupdated := ServerDateToDateTime(Entry.Get(j).NodeValue)
            else
              if Entry.Get(j).NodeName = 'gd:where' then
                Fwhere := gdWhere(Entry[j])
              else
                if Entry.Get(j).NodeName = 'link' then
                  AddLink(Entry[j])
                else
                  if Entry.Get(j).NodeName = 'gCal:selected' then
                    Fselected.ParseXML(Entry[j])
                  else
                  begin
                    index := AnsiIndexStr(Entry[j].NodeName, cgCalTagNames);
                    if index > - 1 then
                    begin
                      case TgCalEnum(index) of
                        egCalaccesslevel:
                          Faccesslevel.ParseXML(Entry[j]);
                        egCalcolor:
                          FVColor.ParseXML(Entry[j]);
                        egCalhidden:
                          Fhidden.ParseXML(Entry[j]);
                        egCalselected:
                          Fselected.ParseXML(Entry[j]);
                        egCaltimezone:
                          Ftimezone.ParseXML(Entry[j]);
                        egCaltimesCleaned:
                          FgCaltimesCleaned.ParseXML(Entry[j]);
                      else
                        ShowMessage(rcUnUsedTag + Entry[j].NodeName);
                      end;
                    end;
                  end;
  end;
end;

function TCelendar.RetrieveEvents: integer;
var
  i: integer;
  aDoc: IXMLDocument;
  tmpURL: string;
begin
FEvents.Clear;
  for i := 0 to FLinks.Count - 1 do
    if FLinks[i].rel = 'alternate' then
    begin
      aDoc := NewXMLDocument();
      aDoc.LoadFromStream(SendRequest('GET', FLinks[i].href, FAuth));
      break;
    end;
  if not aDoc.IsEmptyDoc then
  begin
    for i := 0 to aDoc.DocumentElement.ChildNodes.Count - 1 do
      if aDoc.DocumentElement.ChildNodes[i].NodeName = 'entry' then
        FEvents.Add(TCelenrarEvent.Create(aDoc.DocumentElement.ChildNodes[i],
            FAuth));
  end;
  Result := FEvents.Count;
end;

function TCelendar.SendToGoogle(const GoogleAuth: string): boolean;
var
  aDoc, cDoc: IXMLDocument;
  Root, Node: IXMLNode;
  i: integer;
  tmpURL: string;
  V: OleVariant;
begin
  aDoc := NewXMLDocument;
  aDoc.Active := true;
  Root := aDoc.AddChild('entry');
  for i := 0 to High(clNameSpaces) do
    Root.DeclareNamespace(clNameSpaces[i, 0], clNameSpaces[i, 1]);
  FTitle.AddToXML(Root);
  FDescription.AddToXML(Root);
  Ftimezone.AddToXML(Root);
  Fhidden.AddToXML(Root);
  FVColor.AddToXML(Root);
  Fwhere.AddToXML(Root);
  with THTTPSend.Create do
  begin
    Headers.Add('GData-Version: 2');
    Headers.Add('Authorization: GoogleLogin auth=' + GoogleAuth);
    MimeType := 'application/atom+xml';
    aDoc.SaveToStream(Document);
    HTTPMethod('POST',OwnerCelendarLink);
    if (ResultCode > 200) and (ResultCode < 400) then
    begin
      tmpURL := GetNewLocationURL(Headers);
      Document.Clear;
      aDoc.SaveToStream(Document);
      Headers.Clear;
      MimeType := 'application/atom+xml';
      Headers.Add('GData-Version: 2');
      Headers.Add('Authorization: GoogleLogin auth=' + GoogleAuth);
      HTTPMethod('POST', tmpURL);
    end;
    Result := ResultCode = 201;
  end;
end;

procedure TCelendar.SetDescription(aDescr: string);
begin
  FDescription.Value:=aDescr;
end;

procedure TCelendar.SetLink(i: integer; Link: TCelendarLink);
begin
  if FLinks.Contains(Link) then
  begin
    ShowMessage(rcDuplicateLink);
    Exit;
  end;
  FLinks.Insert(i, Link);
end;

procedure TCelendar.SetTitle(aTitle: string);
begin
  FTitle.Value:=aTitle
end;

{ TgCaltimezone }

function TgCaltimezone.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root = nil then
    Exit;
  Result := Root.AddChild(cgCalTagNames[ord(egCaltimezone)]);
  Result.Attributes['value'] := FValue;
end;

constructor TgCaltimezone.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCaltimezone.ParseXML(Node: IXMLNode);
var
  i: integer;
begin
  if GetGClalNodeType(Node.NodeName) <> egCaltimezone then
    raise Exception.Create
      (Format(rcErrCompNodes, [cgCalTagNames[ord(egCaltimezone)]]));
  try
    FValue := Node.Attributes['value'];
    for i := 0 to High(GoogleTimeZones) - 1 do
    begin
      if Trim(LowerCase(GoogleTimeZones[i, 0])) = Trim(LowerCase(FValue)) then
      begin
        FDescription := GoogleTimeZones[i, 1];
        FGMT := StrToFloat(GoogleTimeZones[i, 2]);
      end;
    end;
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TAuthorTag }

constructor TAuthorTag.Create(ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TAuthorTag.ParseXML(Node: IXMLNode);
var
  i: integer;
begin
  try
    for i := 0 to Node.ChildNodes.Count - 1 do
    begin
      if Node.ChildNodes[i].NodeName = 'name' then
        FAuthor := Node.ChildNodes[i].Text
      else
        if Node.ChildNodes[i].NodeName = 'email' then
          FEmail := Node.ChildNodes[i].Text
        else
          if Node.ChildNodes[i].NodeName = 'uid' then
            FUID:=Node.ChildNodes[i].Text;
    end;
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgCalhidden }

function TgCalHidden.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root = nil then
    Exit;
  Result := Root.AddChild(cgCalTagNames[ord(egCalhidden)]);
  Result.Attributes['value'] := FValue;
end;

constructor TgCalHidden.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCalHidden.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCalhidden then
    raise Exception.Create
      (Format(rcErrCompNodes, [cgCalTagNames[ord(egCalhidden)]]));
  try
    FValue := Node.Attributes['value'];
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgCalcolor }

function TgCalcolor.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root = nil then
    Exit;
  Result := Root.AddChild(cgCalTagNames[ord(egCalcolor)]);
  Result.Attributes['value'] := FValue;
end;

constructor TgCalcolor.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then Exit;
  ParseXML(ByNode);
end;

procedure TgCalcolor.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCalcolor then
    raise Exception.Create
      (Format(rcErrCompNodes, [cgCalTagNames[ord(egCalcolor)]]));
  try
    FValue := Node.Attributes['value'];
    FColor := HexToColor(FValue);
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

procedure TgCalcolor.SetColor(aColor: TColor);
begin
  FColor := aColor;
  FValue := ColorToHex(aColor);
end;

{ TgCalselected }

constructor TgCalselected.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCalselected.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCalselected then
    raise Exception.Create
      (Format(rcErrCompNodes, [cgCalTagNames[ord(egCalselected)]]));
  try
    FValue := Node.Attributes['value'];
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgCalaccesslevel }

constructor TgCalAccessLevel.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCalAccessLevel.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCalaccesslevel then
    raise Exception.Create(Format(rcErrCompNodes,
        [cgCalTagNames[ord(egCalaccesslevel)]]));
  try
    FValue := Node.Attributes['value'];
    if AnsiIndexStr(FValue, cgCalaccesslevel) <> -1 then
      FLevel := TAccessLevel(AnsiIndexStr(FValue, cgCalaccesslevel))
    else
      raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

procedure TgCalAccessLevel.SetLevel(aLevel: TAccessLevel);
begin
  try
    FValue := cgCalaccesslevel[ord(aLevel)];
    FLevel := aLevel;
  except
    Exception.Create
      (Format(rcErrWriteNode, [cgCalTagNames[ord(egCalaccesslevel)]]));
  end;
end;

procedure TgCalAccessLevel.SetValue(aValue: string);
var
  i: integer;
  s: string;
begin
  try
    s := Trim(LowerCase(FValue));
    i := AnsiIndexStr(s, cgCalaccesslevel);
    if i <> 1 then
    begin
      FLevel := TAccessLevel(i);
      FValue := s;
    end
    else
      raise Exception.Create
        (Format(rcErrWriteNode, [cgCalTagNames[ord(egCalaccesslevel)]]));
  except
    Exception.Create
      (Format(rcErrWriteNode, [cgCalTagNames[ord(egCalaccesslevel)]]));
  end;
end;

{ TgCaltimesCleaned }

constructor TgCaltimesCleaned.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCaltimesCleaned.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCaltimesCleaned then
    raise Exception.Create(Format(rcErrCompNodes,
        [cgCalTagNames[ord(egCaltimesCleaned)]]));
  try
    FValue := Node.Attributes['value'];
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TTitleTag }

function TTextTag.AddToXML(Root: IXMLNode): IXMLNode;
var
  i: integer;
begin
  Result:= Root.OwnerDocument.CreateElement(FName, clNameSpaces[0, 1]);
  Result.Text := AnsiToUtf8(FValue);
  for i := 0 to FAttributes.Count - 1 do
    Result.Attributes[FAttributes[i].Name] := FAttributes[i].Value;
  Root.ChildNodes.Add(Result);
end;

constructor TTextTag.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  FAttributes := TList<TAttribute>.Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TTextTag.ParseXML(Node: IXMLNode);
var
  i: integer;
  Attr: TAttribute;
begin
  try
    FValue := Node.Text;
    FName := Node.NodeName;
    for i := 0 to Node.AttributeNodes.Count - 1 do
    begin
      Attr.Name := Node.AttributeNodes[i].NodeName;
      Attr.Value := Node.Attributes[Attr.Name];
      FAttributes.Add(Attr)
    end;
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgCalguestsCanInviteOthers }

function TgCalguestsCanInviteOthers.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root = nil then
    Exit;
  Result := Root.AddChild(cgCalTagNames[ord(egCalguestsCanInviteOthers)]);
  Result.Attributes['value'] := LowerCase(BoolToStr(FValue, true));
end;

constructor TgCalguestsCanInviteOthers.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCalguestsCanInviteOthers.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCalguestsCanInviteOthers then
    raise Exception.Create(Format(rcErrCompNodes, [cgCalTagNames[ord
          (egCalguestsCanInviteOthers)]]));
  try
    FValue := Node.Attributes['value'];
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgCalguestsCanModify }

function TgCalguestsCanModify.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root = nil then
    Exit;
  Result := Root.AddChild(cgCalTagNames[ord(egCalguestsCanModify)]);
  Result.Attributes['value'] := LowerCase(BoolToStr(FValue, true));
end;

constructor TgCalguestsCanModify.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCalguestsCanModify.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCalguestsCanModify then
    raise Exception.Create(Format(rcErrCompNodes,
        [cgCalTagNames[ord(egCalguestsCanModify)]]));
  try
    FValue := Node.Attributes['value'];
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgCalguestsCanSeeGuests }

function TgCalguestsCanSeeGuests.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root = nil then
    Exit;
  Result := Root.AddChild(cgCalTagNames[ord(egCalguestsCanSeeGuests)]);
  Result.Attributes['value'] := LowerCase(BoolToStr(FValue, true));
end;

constructor TgCalguestsCanSeeGuests.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCalguestsCanSeeGuests.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCalguestsCanSeeGuests then
    raise Exception.Create(Format(rcErrCompNodes,
        [cgCalTagNames[ord(egCalguestsCanSeeGuests)]]));
  try
    FValue := Node.Attributes['value'];
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgCalsequence }

function TgCalsequence.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root = nil then
    Exit;
  Result := Root.AddChild(cgCalTagNames[ord(egCalguestsCanSeeGuests)]);
  Result.Attributes['value'] := IntToStr(FValue);
end;

constructor TgCalsequence.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCalsequence.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCalsequence then
    raise Exception.Create
      (Format(rcErrCompNodes, [cgCalTagNames[ord(egCalsequence)]]));
  try
    FValue := Node.Attributes['value'];
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgCaluid }

function TgCaluid.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root = nil then
    Exit;
  Result := Root.AddChild(cgCalTagNames[ord(egCalguestsCanSeeGuests)]);
  Result.Attributes['value'] := FValue;
end;

constructor TgCaluid.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCaluid.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCaluid then
    raise Exception.Create
      (Format(rcErrCompNodes, [cgCalTagNames[ord(egCaluid)]]));
  try
    FValue := Node.Attributes['value'];
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgCalsuppressReplyNotifications }

function TgCalsuppressReplyNotifications.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root = nil then
    Exit;
  Result := Root.AddChild(cgCalTagNames[ord(egCalguestsCanSeeGuests)]);
  Result.Attributes['value'] := BoolToStr(FValue, true);
end;

constructor TgCalsuppressReplyNotifications.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCalsuppressReplyNotifications.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCalsuppressReplyNotifications then
    raise Exception.Create(Format(rcErrCompNodes, [cgCalTagNames[ord
          (egCalsuppressReplyNotifications)]]));
  try
    FValue := Node.Attributes['value'];
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgCalsyncEvent }

function TgCalsyncEvent.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root = nil then
    Exit;
  Result := Root.AddChild(cgCalTagNames[ord(egCalguestsCanSeeGuests)]);
  Result.Attributes['value'] := BoolToStr(FValue, true);
end;

constructor TgCalsyncEvent.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgCalsyncEvent.ParseXML(Node: IXMLNode);
begin
  if GetGClalNodeType(Node.NodeName) <> egCalsyncEvent then
    raise Exception.Create
      (Format(rcErrCompNodes, [cgCalTagNames[ord(egCalsyncEvent)]]));
  try
    FValue := Node.Attributes['value'];
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TCelenrarEvent }

procedure TCelenrarEvent.AddLink(const aNode: IXMLNode);
var
  Link: TCelendarLink;
begin
  try
    Link.rel := aNode.Attributes['rel'];
    Link.ltype := aNode.Attributes['type'];
    Link.href := aNode.Attributes['href'];
    FLinks.Add(Link);
  except
    Exception.Create(Format(rcErrReadNode, [aNode.NodeName]));
  end;
end;

procedure TCelenrarEvent.AddRemainder(const aNode: IXMLNode);
var
  Remainder: TgdReminder;
begin
  Remainder := TgdReminder.Create(aNode);
  Freminders.Add(Remainder);
end;


constructor TCelenrarEvent.Create(const ByNode: IXMLNode; aAuth: string);
var Attr: TAttribute;
begin
  inherited Create;
  FAuth := aAuth;
  Attr.Name:='type';
  Attr.Value:='text';
  FTitle := TTextTag.Create(nil);
  FTitle.Name:='title';
  FTitle.Attributes.Add(Attr);
  FDescription := TTextTag.Create(nil);
  FDescription.Name:='content';
  FDescription.FAttributes.Add(Attr);
  FLinks := TCelendarLinksList.Create; // ссылки события
  FAuthor := TAuthorTag.Create(nil);
  FeventStatus := TgdEventStatus.Create(nil);
  Fwhere := TgdWhere.Create(nil);
  Fwhen := TgdWhen.Create(nil);
  Fwho := TgdWho.Create(nil);
  Frecurrence := TgdRecurrence.Create(nil);
  Freminders := TList<TgdReminder>.Create;
  Ftransparency := TgdTransparency.Create(nil);
  Fvisibility := TgdVisibility.Create(nil);
  FguestsCanInviteOthers := TgCalguestsCanInviteOthers.Create(nil);
  FguestsCanModify := TgCalguestsCanModify.Create(nil);
  FguestsCanSeeGuests := TgCalguestsCanSeeGuests.Create(nil);
  Fsequence := TgCalsequence.Create(nil);
  Fuid := TgCaluid.Create(nil);

  if ByNode <> nil then
    ParseXML(ByNode);

end;

function TCelenrarEvent.DeleteThis:boolean;
var tmpURL:string;
begin
  if length(GetEditURL) > 0 then
    with THTTPSend.Create do
    begin
      Headers.Add('GData-Version: 2');
      Headers.Add('Authorization: GoogleLogin auth=' + FAuth);
      MimeType := 'application/atom+xml';
      Headers.Add('If-Match: ' + FEtag);
      HTTPMethod('DELETE', GetEditURL);
      if (ResultCode > 200) and (ResultCode < 400) then
      begin
        tmpURL := GetNewLocationURL(Headers);
        Document.Clear;
        Headers.Clear;
        MimeType := 'application/atom+xml';
        Headers.Add('GData-Version: 2');
        Headers.Add('Authorization: GoogleLogin auth=' + FAuth);
        Headers.Add('If-Match: ' + FEtag);
        HTTPMethod('DELETE', tmpURL);
      end;
      Result:=ResultCode=200;
    end;
end;

destructor TCelenrarEvent.Destroy;
begin
  inherited Destroy;
end;

function TCelenrarEvent.GetDescription: string;
begin
 Result:=FDescription.FValue
end;

function TCelenrarEvent.GetEditURL: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to FLinks.Count - 1 do
  begin
    if FLinks[i].rel = 'edit' then
    begin
      Result := FLinks[i].href;
      break;
    end;
  end;
end;

function TCelenrarEvent.GetTitle: string;
begin
  result:=FTitle.FValue;
end;

procedure TCelenrarEvent.InsertCategory(Root: IXMLNode);
var
  Node: IXMLNode;
begin
  Node := Root.OwnerDocument.CreateElement('category',
    'http://www.w3.org/2005/Atom'); // создали узел
  Node.Attributes[clCategories[0, 0]] := clCategories[0, 1];
  // присвоили значение
  Node.Attributes[clCategories[1, 0]] := clCategories[1, 1];
  // присвоили значение
  Root.ChildNodes.Add(Node); // записали документ
end;

procedure TCelenrarEvent.ParseXML(Node: IXMLNode);
var
  i, j: integer;
  Name:AnsiString;
begin
  for i := 0 to Node.ChildNodes.Count - 1 do
  begin
    Name:=Node.ChildNodes[i].NodeName;
    j:=AnsiIndexText(Name,clEventRequareTags);
    case j of
      0:Fid := Node.ChildNodes[i].Text;
      1:Fpublished := ServerDateToDateTime(Node.ChildNodes[i].Text);
      2:Fupdated := ServerDateToDateTime(Node.ChildNodes[i].Text);
      3:FTitle.ParseXML(Node.ChildNodes[i]);
      4:begin
          AddLink(Node.ChildNodes[i]);
          if FLinks[FLinks.Count - 1].rel = 'self' then
            RetriveETag(FLinks[FLinks.Count - 1].href);
        end;
      5:FDescription.ParseXML(Node.ChildNodes[i]);
      6:FAuthor.ParseXML(Node.ChildNodes[i]);
      7:FeventStatus := gdEventStatus(Node.ChildNodes[i]);
      8:Fwhere.ParseXML(Node.ChildNodes[i]);
      9:Fwho.ParseXML(Node.ChildNodes[i]);
      10:begin
          Fwhen.ParseXML(Node.ChildNodes[i]);
          if Node.ChildNodes[i].ChildNodes.Count > 0 then
            begin
              for j := 0 to Node.ChildNodes[i].ChildNodes.Count - 1 do
                AddRemainder(Node.ChildNodes[i].ChildNodes[j])
            end;
         end;
      11:Frecurrence.ParseXML(Node.ChildNodes[i]);
      12:AddRemainder(Node.ChildNodes[i]);
      13:Ftransparency.ParseXML(Node.ChildNodes[i]);
      14:Fvisibility.ParseXML(Node.ChildNodes[i]);
      15:FguestsCanInviteOthers.ParseXML(Node.ChildNodes[i]);
      16:FguestsCanModify.ParseXML(Node.ChildNodes[i]);
      17:FguestsCanSeeGuests.ParseXML(Node.ChildNodes[i]);
      18:Fsequence.ParseXML(Node.ChildNodes[i]);
      19:Fuid.ParseXML(Node.ChildNodes[i]);
    end;
  end;
end;

procedure TCelenrarEvent.RetriveETag(const aLink: string);
var
  tmpURL: string;
  i: integer;
begin
  with THTTPSend.Create do
  begin
    Headers.Add('GData-Version: 2');
    Headers.Add('Authorization: GoogleLogin auth=' + FAuth);
    MimeType := 'application/atom+xml';
    HTTPMethod('HEAD', aLink);
    if (ResultCode > 200) and (ResultCode < 400) then
    begin
      tmpURL := GetNewLocationURL(Headers);
      Document.Clear;
      Headers.Clear;
      MimeType := 'application/atom+xml';
      Headers.Add('GData-Version: 2');
      Headers.Add('Authorization: GoogleLogin auth=' + FAuth);
      HTTPMethod('HEAD', tmpURL);
    end;
    for i := 0 to Headers.Count - 1 do
    begin
      if pos('ETag: ', Headers[i]) > 0 then
      begin
        FEtag := copy(Headers[i], 7, length(Headers[i]) - 6);
        break;
      end;
    end;
  end;
end;

procedure TCelenrarEvent.SetDescription(aDescr: string);
begin
  FDescription.Value:=aDescr;
end;

procedure TCelenrarEvent.SetTitle(aTitle: string);
begin
  FTitle.FValue:=aTitle;
end;

function TCelenrarEvent.Update: boolean;
var
  i: integer;
  aDoc: IXMLDocument;
  Root, Node: IXMLNode;
  tmpURL: string;
begin
  aDoc := NewXMLDocument();
  aDoc.Active := true;
  aDoc.Options := [doNodeAutoIndent];
  Root := aDoc.AddChild('entry');
  for i := 0 to High(clNameSpaces) do
    Root.DeclareNamespace(clNameSpaces[i, 0], clNameSpaces[i, 1]);
  Root.Attributes['gd:etag'] := FEtag;
  InsertCategory(Root);
  Node := aDoc.CreateElement('id', clNameSpaces[0, 1]);
  Node.Text := Fid;
  aDoc.DocumentElement.ChildNodes.Add(Node);

  FTitle.AddToXML(Root);
  FDescription.AddToXML(Root);
  FeventStatus.AddToXML(Root);
  Fwhere.AddToXML(Root);
  Node:=Fwhen.AddToXML(Root);

  if Frecurrence.Text.Count=0 then
    begin
      for I:=0 to FReminders.Count - 1 do
        Freminders[i].AddToXML(Node);
    end
  else
    begin
      for I:=0 to FReminders.Count - 1 do
        Freminders[i].AddToXML(Root);
    end;

  Fwho.AddToXML(Root);
  Ftransparency.AddToXML(Root);
  Fvisibility.AddToXML(Root);
  FguestsCanInviteOthers.AddToXML(Root);
  FguestsCanModify.AddToXML(Root);
  FguestsCanSeeGuests.AddToXML(Root);


  if length(GetEditURL) > 0 then
    with THTTPSend.Create do
    begin
      Headers.Add('GData-Version: 2');
      Headers.Add('Authorization: GoogleLogin auth=' + FAuth);
      MimeType := 'application/atom+xml';
      Headers.Add('If-Match: ' + FEtag);
      aDoc.SaveToStream(Document);
      HTTPMethod('PUT', GetEditURL);
      if (ResultCode > 200) and (ResultCode < 400) then
        begin
          tmpURL := GetNewLocationURL(Headers);
          Document.Clear;
          aDoc.SaveToStream(Document);
          Headers.Clear;
          MimeType := 'application/atom+xml';
          Headers.Add('GData-Version: 2');
          Headers.Add('Authorization: GoogleLogin auth=' + FAuth);
          Headers.Add('If-Match: ' + FEtag);
          HTTPMethod('PUT', tmpURL);
        end;
      Result:=ResultCode=200;
      if Result then
        begin
          aDoc.LoadFromStream(Document);
          Self.ParseXML(aDoc.DocumentElement);
        end;
    end;
end;

end.
