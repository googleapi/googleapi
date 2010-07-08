unit GDataCommon;

interface

uses NativeXML, Classes, StrUtils, SysUtils, GHelper, typinfo, uLanguage,GConsts;

type
  TgdEnum = (gd_country, gd_additionalName,gd_name, gd_email, gd_extendedProperty,
  gd_geoPt, gd_im,gd_orgName, gd_orgTitle, gd_organization, gd_originalEvent,
  gd_phoneNumber, gd_postalAddress, gd_rating, gd_recurrence,gd_reminder,
  gd_resourceId, gd_when, gd_agent, gd_housename, gd_street, gd_pobox,
  gd_neighborhood, gd_city, gd_subregion,gd_region, gd_postcode,gd_formattedAddress,
  gd_structuredPostalAddress, gd_entryLink, gd_where, gd_familyName,
  gd_givenName, gd_namePrefix, gd_nameSuffix,gd_fullName, gd_orgDepartment,
  gd_orgJobDescription, gd_orgSymbol, gd_famileName, gd_eventStatus,
  gd_visibility, gd_transparency, gd_attendeeType, gd_attendeeStatus,
  gd_comments, gd_deleted,gd_feedLink, gd_who, gd_recurrenceException);

type
  TGDataTags = set of TgdEnum;

type
  TEventStatus = (es_None, es_event_canceled, es_event_confirmed,
                  es_event_tentative);
  TgdEventStatus = class
    private
      FRel : TEventStatus;
    public
      Constructor Create(const ByNode:TXMLNode=nil);
      procedure Clear;
      function IsEmpty: boolean;
      procedure ParseXML(Node: TXMLNode);
      function RelToString: string;
      function AddToXML(Root:TXMLNode):TXMLNode;
      property Rel: TEventStatus read FRel write FRel;
  end;

type
  TVisibility = (vs_None, vs_event_confidential, vs_event_default,
                 vs_event_private, vs_event_public);
  TgdVisibility = class
    private
      FRel: TVisibility;
    public
      Constructor Create(const ByNode:TXMLNode=nil);
      procedure Clear;
      function IsEmpty:boolean;
      function RelToString: string;
      procedure ParseXML(Node: TXMLNode);
      function AddToXML(Root:TXMLNode):TXMLNode;
      property Rel: TVisibility read FRel write FRel;
  end;

type
  TTransparency = (tt_None, tt_event_opaque, tt_event_transparent);
  TgdTransparency = class(TPersistent)
    private
      FRel : TTransparency;
    public
      Constructor Create(const ByNode:TXMLNode=nil);
      procedure Clear;
      function IsEmpty:boolean;
      procedure ParseXML(Node: TXMLNode);
      function AddToXML(Root:TXMLNode):TXMLNode;
      function RelToString: string;
      property Rel: TTransparency read FRel write FRel;
  end;

type
  TAttendeeType = (at_None, at_event_optional, at_event_required);
  TgdAttendeeType = class
    private
      FRel: TAttendeeType;
    public
      Constructor Create(const ByNode:TXMLNode=nil);
      procedure Clear;
      function IsEmpty:boolean;
      function RelToString:string;
      procedure ParseXML(Node: TXMLNode);
      function AddToXML(Root:TXMLNode):TXMLNode;
      property Rel: TAttendeeType read FRel write FRel;
  end;

type
  TAttendeeStatus = (as_None, as_event_accepted, as_event_declined,
                     as_event_invited, as_event_tentative);
  TgdAttendeeStatus = class
    private
      FRel: TAttendeeStatus;
  public
      Constructor Create(const ByNode:TXMLNode=nil);
      procedure Clear;
      function isEmpty: boolean;
      procedure ParseXML(Node: TXMLNode);
      function  RelToString: string;
      function AddToXML(Root:TXMLNode):TXMLNode;
      property Rel: TAttendeeStatus read FRel write FRel;
  end;

type
  TEntryTerms = (et_None, et_Any, et_Contact, et_Event, et_Message, et_Type);

type
  TgdCountry = class(TPersistent)
    private
     FCode: string;
     FValue: string;
    public
     Constructor Create(const ByNode:TXMLNode=nil);
     procedure Clear;
     function IsEmpty: boolean;
     procedure   ParseXML(Node: TXMLNode);
     function    AddToXML(Root:TXMLNode):TXMLNode;
     property Code: string read FCode write FCode;
     property Value: string read FValue write FValue;
  end;

type
  TgdAdditionalName = TTextTag;
  TgdFamilyName = TTextTag;
  TgdGivenName = TTextTag;
  TgdNamePrefix = TTextTag;
  TgdNameSuffix = TTextTag;
  TgdFullName = TTextTag;
  TgdOrgDepartment = TTextTag;
  TgdOrgJobDescription = TTextTag;
  TgdOrgSymbol = TTextTag;

type
  TgdName = class
  private
    FGivenName: TTextTag;
    FAdditionalName: TTextTag;
    FFamilyName: TTextTag;
    FNamePrefix: TTextTag;
    FNameSuffix: TTextTag;
    FFullName: TTextTag;
    function GetFullName:string;
    procedure SetFullName(aFullName: TTextTag);
    procedure SetGivenName(aGivenName: TTextTag);
    procedure SetAdditionalName(aAdditionalName: TTextTag);
    procedure SetFamilyName(aFamilyName: TTextTag);
    procedure SetNamePrefix(aNamePrefix: TTextTag);
    procedure SetNameSuffix(aNameSuffix: TTextTag);
  public
    constructor Create(ByNode: TXMLNode=nil);
    procedure   ParseXML(const Node: TXmlNode);
    procedure Clear;
    function IsEmpty:boolean;
    function AddToXML(Root:TXMLNode):TXmlNode;
    property GivenName: TTextTag read FGivenName write SetGivenName;
    property AdditionalName: TTextTag read FAdditionalName write SetAdditionalName;
    property FamilyName: TTextTag read FFamilyName write SetFamilyName;
    property NamePrefix: TTextTag read FNamePrefix write SetNamePrefix;
    property NameSuffix: TTextTag read FNameSuffix write SetNameSuffix;
    property FullName: TTextTag read FFullName write SetFullName;
    property FullNameString: string read GetFullName;
end;

type
  TTypeElement = (em_None, em_home,em_other, em_work);
  TgdEmail = class(TPersistent)
    private
      FAddress: string;
      FRel: TTypeElement;
      FLabel: string;
      FPrimary: boolean;
      FDisplayName:string;
    public
      constructor Create(ByNode: TXMLNode=nil);
      procedure Clear;
      function IsEmpty:boolean;
      procedure   ParseXML(const Node: TXmlNode);
      function AddToXML(Root:TXMLNode):TXmlNode;
      function RelToString:string;
      property Address : string read FAddress write FAddress;
      property Labl:string read FLabel write FLabel;
      property Rel: TTypeElement read FRel write FRel;
      property DisplayName: string read FDisplayName write FDisplayName;
      property Primary: boolean read FPrimary write FPrimary;
  end;

type
  TgdExtendedPropertyStruct = record
    Name: string;
    Value: string;
  end;

type
  TgdGeoPtStruct = record
    Elav: extended;
    Labels: string;
    Lat: extended;
    Lon: extended;
    Time: TDateTime;
  end;

type
  TIMProtocol = (ti_None, ti_AIM,ti_MSN,ti_YAHOO,ti_SKYPE,ti_QQ,ti_GOOGLE_TALK,
                 ti_ICQ, ti_JABBER);
  TIMtype = (im_None, im_home,im_netmeeting,im_other,im_work);
  TgdIm = class
  private
    FAddress: string;
    FLabel: string;
    FPrimary: boolean;
    FIMProtocol:TIMProtocol;
    FIMType:TIMtype;
  public
    constructor Create(ByNode: TXMLNode=nil);
    procedure   ParseXML(const Node: TXmlNode);
    procedure Clear;
    function IsEmpty: boolean;
    function AddToXML(Root:TXMLNode):TXmlNode;
    function ImTypeToString: string;
    function ImProtocolToString: string;
    property Address: string read FAddress write FAddress;
    property iLabel: string read FLabel write FLabel;
    property ImType: TIMtype read FIMType write FIMType;
    property Protocol: TIMProtocol read FIMProtocol write FIMProtocol;
    property Primary: boolean read FPrimary write FPrimary;
end;

  TgdOrgName = TTextTag;
  TgdOrgTitle = TTextTag;

type
  TgdOrganization = class
  private
     FLabel: string;
     Frel: string;
     Fprimary: boolean;
     ForgName: TgdOrgName;
     ForgTitle: TgdOrgTitle;
  public
    constructor Create(ByNode: TXMLNode=nil);
    procedure   ParseXML(const Node: TXmlNode);
    function AddToXML(Root:TXMLNode):TXmlNode;
    function IsEmpty:boolean;
    procedure Clear;
    property Labl: string read FLabel write FLabel;
    property Rel: string Read FRel write FRel;
    property Primary: boolean read Fprimary write Fprimary;
    property OrgName: TgdOrgName read ForgName write ForgName;
    property OrgTitle: TgdOrgTitle read ForgTitle write ForgTitle;
end;

type
  TgdOriginalEventStruct = record
    id: string;
    href: string;
  end;

type
  TPhonesRel=(tp_None, tp_Assistant,tp_Callback,tp_Car,Tp_Company_main,
      tp_Fax, tp_Home,tp_Home_fax,tp_Isdn,tp_Main,tp_Mobile,tp_Other,
      tp_Other_fax, tp_Pager,tp_Radio,tp_Telex,tp_Tty_tdd,Tp_Work,
      tp_Work_fax,  tp_Work_mobile,tp_Work_pager);
  TgdPhoneNumber = class
    private
      FPrimary: boolean;
      FLabel: string;
      Frel: TPhonesRel;
      FUri: string;
      FValue: string;
    public
      constructor Create(ByNode: TXMLNode=nil);
      function IsEmpty: boolean;
      procedure Clear;
      procedure   ParseXML(const Node: TXmlNode);
      function AddToXML(Root:TXMLNode):TXmlNode;
      function RelToString:string;
      property Primary: boolean read FPrimary write FPrimary;
      property Labl: string read FLabel write FLabel;
      property Rel: TPhonesRel read Frel write Frel;
      property Uri: string read FUri write FUri;
      property Text: string read FValue write FValue;
  end;

type
  TgdPostalAddressStruct = record
    Labels: string;
    rel: string;
    primary: boolean;
    Text: string;
  end;

type
  TgdRatingStruct = record
    Average: extended;
    Max: integer;
    Min: integer;
    numRaters: integer;
    rel: string;
    Value: integer;
  end;

type
  TgdRecurrence = class
  private
    FText: TStringList;
  public
    Constructor Create(const ByNode:TXMLNode=nil);
    procedure Clear;
    function IsEmpty: boolean;
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root:TXMLNode):TXMLNode;
    property Text: TStringList read FText write FText;
end;


{ TODO -oVlad -cBug : Переделать: добавить "неопределенное значение" в типы. Убрать константы }
const
  cMethods : array [0..2]of string =('alert','email','sms');
type
  TMethod = (tmAlert, tmEmail, tmSMS);
  TRemindPeriod = (tpDays, tpHours, tpMinutes);

type
  TgdReminder = class (TPersistent)
    private
      FabsoluteTime: TDateTime;
      Fmethod:       TMethod;
      FPeriod:       TRemindPeriod;
      FPeriodValue:  integer;
    public
      Constructor Create(const ByNode:TXMLNode);
      procedure ParseXML(Node: TXMLNode);
      function  AddToXML(Root:TXMLNode):TXMLNode;
      property  AbsTime: TDateTime read FabsoluteTime write FabsoluteTime;
      property  Method: TMethod read Fmethod write Fmethod;
      property  Period: TRemindPeriod read FPeriod write FPeriod;
      property  PeriodValue:integer read FPeriodValue write FPeriodValue;
  end;

type
  TgdResourceIdStruct = string;

type
  TDateFormat = (tdDate, tdServerDate);
  TgdWhen = class
    private
      FendTime: TDateTime;
      FstartTime: TDateTime;
      FvalueString: string;
    public
      Constructor Create(const ByNode:TXMLNode=nil);
      procedure Clear;
      function isEmpty:boolean;
      procedure ParseXML(Node: TXMLNode);
      function AddToXML(Root:TXMLNode;DateFormat:TDateFormat):TXMLNode;
      property endTime: TDateTime read FendTime write FendTime;
      property startTime: TDateTime read FstartTime write FstartTime;
      property valueString: string read FvalueString write FvalueString;
  end;

type
  TgdAgent = TTextTag;
  TgdHousename = TTextTag;
  TgdStreet = TTextTag;
  TgdPobox = TTextTag;
  TgdNeighborhood = TTextTag;
  TgdCity = TTextTag;
  TgdSubregion = TTextTag;
  TgdRegion = TTextTag;
  TgdPostcode = TTextTag;
  TgdFormattedAddress = TTextTag;

type
  TgdStructuredPostalAddress = class
    private
     FRel: string;
     FMailClass: string;
     FUsage: string;
     Flabel: string;
     Fprimary: boolean;
     FAgent: TgdAgent;
     FHouseName: TgdHousename;
     FStreet: TgdStreet;
     FPobox: TgdPobox;
     FNeighborhood: TgdNeighborhood;
     FCity: TgdCity;
     FSubregion: TgdSubregion;
     FRegion: TgdRegion;
     FPostcode: TgdPostcode;
     FCountry: TgdCountry;
     FFormattedAddress: TgdFormattedAddress;
    public
      Constructor Create(const ByNode:TXMLNode=nil);
      procedure Clear;
      procedure ParseXML(Node: TXMLNode);
      function AddToXML(Root:TXMLNode):TXMLNode;
      function IsEmpty: boolean;
      property Rel: string read FRel write FRel;
      property MailClass: string read FMailClass write FMailClass;
      property Usage: string read FUsage write FUsage;
      property Labl: string read Flabel write Flabel;
      property Primary: boolean read FPrimary write FPrimary;
      property Agent: TgdAgent read FAgent write FAgent;
      property HouseName: TgdHousename read FHouseName write FHouseName;
      property Street: TgdStreet read FStreet write FStreet;
      property Pobox: TgdPobox read FPobox write FPobox;
      property Neighborhood: TgdNeighborhood read FNeighborhood write FNeighborhood;
      property City: TgdCity read FCity write FCity;
      property Subregion: TgdSubregion read FSubregion write FSubregion;
      property Region: TgdRegion read FRegion write FRegion;
      property Postcode: TgdPostcode read FPostcode write FPostcode;
      property Coutry: TgdCountry read FCountry write FCountry;
      property FormattedAddress: TgdFormattedAddress read FFormattedAddress write FFormattedAddress;
  end;

type
  TgdEntryLink = class
    private
      Fhref: string;
      FReadOnly: boolean;
      Frel: string;
      FAtomEntry: TXMLNode;
    public
      Constructor Create(const ByNode:TXMLNode=nil);
      procedure ParseXML(Node: TXMLNode);
      procedure Clear;
      function IsEmpty:boolean;
      function AddToXML(Root:TXMLNode):TXMLNode;
      property Href: string read Fhref write Fhref;
      property OnlyRead: boolean read FReadOnly write FReadOnly;
      property Rel: string read Frel write Frel;
  end;

type
  TgdWhere = class
    private
     Flabel: string;
     Frel: string;
     FvalueString: string;
     FEntryLink: TgdEntryLink;
    public
      Constructor Create(const ByNode:TXMLNode=nil);
      procedure Clear;
      function IsEmpty: boolean;
      procedure ParseXML(Node: TXMLNode);
      function AddToXML(Root:TXMLNode):TXMLNode;
      property Labl:string read Flabel write Flabel;
      property Rel:string read FRel write FRel;
      property valueString: string read FvalueString write FvalueString;
      property EntryLink: TgdEntryLink read FEntryLink write FEntryLink;
  end;

type
  TWhoRel = (twAttendee,twOrganizer,twPerformer,twSpeaker,twBcc,twCc,twFrom,twReply,twTo);
  TgdWho = class
  private
    FEmail: string;
    Frel: string;
    FRelValue: TWhoRel;
    FvalueString: string;
    FAttendeeStatus: TgdAttendeeStatus;
    FAttendeeType: TgdAttendeeType;
    FEntryLink: TgdEntryLink;
    const
      RelValues: array [0..8] of string = (
    'event.attendee','event.organizer','event.performer','event.speaker',
    'message.bcc','message.cc','message.from','message.reply-to','message.to');
  public
    Constructor Create(const ByNode:TXMLNode=nil);
    procedure Clear;
    function IsEmpty:boolean;
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root:TXMLNode):TXMLNode;
    property Email: string read FEmail write FEmail;
    property RelValue: TWhoRel read FRelValue write FRelValue;
    property valueString: string read FvalueString write FvalueString;
    property AttendeeStatus: TgdAttendeeStatus read FAttendeeStatus write FAttendeeStatus;
    property AttendeeType: TgdAttendeeType read FAttendeeType write FAttendeeType;
    property EntryLink: TgdEntryLink read FEntryLink write FEntryLink;
end;

function GetGDNodeType(cName: UTF8string): TgdEnum;
function GetGDNodeName(NodeType:TgdEnum):UTF8String;inline;

function gdAttendeeStatus(aXMLNode: TXMLNode): TgdAttendeeStatus;
function gdAttendeeType(aXMLNode: TXMLNode): TgdAttendeeType;
function gdTransparency(aXMLNode: TXMLNode): TgdTransparency;
function gdVisibility(aXMLNode: TXMLNode): TgdVisibility;
function gdEventStatus(aXMLNode: TXMLNode): TgdEventStatus;
function gdWhere(aXMLNode: TXMLNode):TgdWhere;
function gdWhen(aXMLNode: TXMLNode):TgdWhen;
function gdWho(aXMLNode: TXMLNode):TgdWho;
function gdRecurrence(aXMLNode: TXMLNode):TgdRecurrence;
function gdReminder(aXMLNode: TXMLNode):TgdReminder;

implementation

function GetGDNodeName(NodeType:TgdEnum):UTF8string;inline;
begin
  Result:=UTF8String(StringReplace(GetEnumName(TypeInfo(TgdEnum),ord(NodeType)),
                        '_',':',[rfReplaceAll]));
end;

function gdReminder(aXMLNode: TXMLNode):TgdReminder;
begin
  Result:=TgdReminder.Create(aXMLNode);
end;

function gdRecurrence(aXMLNode: TXMLNode):TgdRecurrence;
begin
  Result:=TgdRecurrence.Create(aXMLNode);
end;

function gdWho(aXMLNode: TXMLNode):TgdWho;
begin
  Result:=TgdWho.Create(aXMLNode);
end;

function gdWhen(aXMLNode: TXMLNode):TgdWhen;
begin
  Result:=TgdWhen.Create(aXMLNode);
end;

function gdWhere(aXMLNode: TXMLNode):TgdWhere;
begin
  Result:=TgdWhere.Create(aXMLNode);
end;

function gdEventStatus(aXMLNode: TXMLNode): TgdEventStatus;
begin
  Result:=TgdEventStatus.Create(aXMLNode);
end;

function gdVisibility(aXMLNode: TXMLNode): TgdVisibility;
begin
  Result:=TgdVisibility.Create(aXMLNode);
end;

function gdTransparency(aXMLNode: TXMLNode): TgdTransparency;
begin
  Result:=TgdTransparency.Create(aXMLNode);
end;

function GetGDNodeType(cName: UTF8string): TgdEnum;
begin
  Result :=TgdEnum(GetEnumValue(TypeInfo(TgdEnum),ReplaceStr(string(cName),':','_')));
end;

function gdAttendeeType(aXMLNode: TXMLNode): TgdAttendeeType;
begin
  Result:=TgdAttendeeType.Create(aXMLNode);
end;

function gdAttendeeStatus(aXMLNode: TXMLNode): TgdAttendeeStatus;
begin
  Result:=TgdAttendeeStatus.Create(aXMLNode);
end;

{ TgdWhere }

function TgdWhere.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result:=nil;
  //добавляем узел
  if Root=nil then Exit;
  Result:=Root.NodeNew(GetGDNodeName(gd_where));
  if Length(Flabel)>0 then
    Result.WriteAttributeString(UTF8String(sNodeLabelAttr),UTF8String(Flabel));
  if Length(Frel)>0 then
    Result.WriteAttributeString(UTF8String(sNodeRelAttr),UTF8String(Frel));
  if Length(FvalueString)>0 then
    Result.WriteAttributeString('valueString',UTF8String(FvalueString));
  if FEntryLink<>nil then
    if (FEntryLink.FAtomEntry<>nil)or(Length(FEntryLink.Fhref)>0) then
      FEntryLink.AddToXML(Result);
end;

procedure TgdWhere.Clear;
begin
  Flabel:='';
  Frel:='';
  FvalueString:='';
end;

constructor TgdWhere.Create(const ByNode: TXMLNode);
begin
inherited Create;
Clear;
if ByNode=nil then Exit;
FEntryLink:=TgdEntryLink.Create(nil);
ParseXML(ByNode);
end;

function TgdWhere.IsEmpty: boolean;
begin
  Result:=(Length(Trim(Flabel))=0)and(Length(Trim(Frel))=0)and(Length(Trim(FvalueString))=0)
end;

procedure TgdWhere.ParseXML(Node: TXMLNode);
begin
if GetGDNodeType(Node.Name) <> gd_Where then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_Where)]));
  try
    Flabel:=string(Node.ReadAttributeString(sNodeLabelAttr));
    if Length(FLabel)=0 then
      Flabel:=string(Node.ReadAttributeString(sNodeRelAttr));
    FvalueString:=string(Node.ReadAttributeString('valueString'));
    if Node.NodeCount>0 then //есть дочерний узел с EntryLink
      begin
        FEntryLink.ParseXML(Node.FindNode(gdNodeAlias+sEntryNodeName));
      end;
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdEntryLinkStruct }

function TgdEntryLink.AddToXML(Root: TXMLNode): TXMLNode;
begin
Result:=nil;
if (Root=nil)or IsEmpty then Exit;
 Result:=Root.NodeNew(GetGDNodeName(gd_EntryLink));
 if Length(Trim(Fhref))>0 then
   Result.WriteAttributeString(sNodeHrefAttr,UTF8String(Fhref));
 if Length(Trim(Frel))>0 then
   Result.WriteAttributeString(sNodeRelAttr,UTF8String(Frel));
 Result.WriteAttributeBool('readOnly',FReadOnly);
 if FAtomEntry<>nil then
   Result.NodeAdd(FAtomEntry);
end;

procedure TgdEntryLink.Clear;
begin
  Fhref:='';
  Frel:='';
end;

constructor TgdEntryLink.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

function TgdEntryLink.IsEmpty: boolean;
begin
  Result:=(Length(Trim(Fhref))=0)and(Length(Trim(Frel))=0)
end;

procedure TgdEntryLink.ParseXML(Node: TXMLNode);
begin
if GetGDNodeType(Node.Name) <> gd_EntryLink then
    raise Exception.Create
         (Format(sc_ErrCompNodes,
                [GetGDNodeName(gd_EntryLink)]));
  try
//    if Node.Attributes['href']<>null then
      Fhref:=string(Node.ReadAttributeString(sNodeHrefAttr));
//    if Node.Attributes['rel']<>null then
      Frel:=string(Node.ReadAttributeString(sNodeRelAttr));
//    if Node.Attributes['readOnly']<>null then
      FReadOnly:=Node.ReadAttributeBool('readOnly');
    if Node.NodeCount>0 then //есть дочерний узел с EntryLink
       FAtomEntry:=Node.FindNode(sEntryNodeName);
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdEventStatus }

function TgdEventStatus.AddToXML(Root: TXMLNode): TXMLNode;
var tmp: string;
begin
Result:=nil;
if (Root=nil)or IsEmpty then Exit;

  Result:=Root.NodeNew(GetGDNodeName(gd_EventStatus));
  tmp:=GetEnumName(TypeInfo(TEventStatus),ord(FRel));
  Delete(tmp,1,3);
  tmp:=ReplaceStr(tmp,'_','.');
  Result.WriteAttributeString(sNodeValueAttr,sSchemaHref+UTF8String(tmp));
end;

procedure TgdEventStatus.Clear;
begin
FRel:=es_None;
end;

constructor TgdEventStatus.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

function TgdEventStatus.IsEmpty: boolean;
begin
  Result:=FRel=es_None;
end;

procedure TgdEventStatus.ParseXML(Node: TXMLNode);
var tmp: string;
begin
  FRel:=es_None;
  if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_EventStatus then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_EventStatus)]));
  try
    tmp:=ReplaceStr(string(Node.ReadAttributeString(sNodeValueAttr)),
                    sSchemaHref,'');
    tmp:='es_'+ReplaceStr(tmp,'.','_');
    Frel:=TEventStatus(GetEnumValue(TypeInfo(TEventStatus),tmp));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TgdEventStatus.RelToString: string;
begin
  case Frel of
    es_None: Result:='';//значение не определено
    es_event_canceled:  Result:=LoadStr(c_EventCancel);
    es_event_confirmed: Result:=LoadStr(c_EventConfirm);
    es_event_tentative: Result:=LoadStr(c_EventTentative);
  end;
end;

{ TgdWhen }

function TgdWhen.AddToXML(Root: TXMLNode;DateFormat:TDateFormat): TXMLNode;
begin
Result:=nil;
  if (Root=nil)or isEmpty then Exit;
  Result:=Root.NodeNew(GetGDNodeName(gd_When));
  case DateFormat of
    tdDate:Result.WriteAttributeString('startTime',UTF8String(FormatDateTime('yyyy-mm-dd',FstartTime)));
    tdServerDate:Result.WriteAttributeString('startTime',UTF8String(DateTimeToServerDate(FstartTime)));
  end;

  if FendTime>0 then
    Result.WriteAttributeString('endTime',UTF8String(DateTimeToServerDate(FendTime)));
  if length(Trim(FvalueString))>0 then
    Result.WriteAttributeString('valueString',UTF8String(FvalueString));
end;

procedure TgdWhen.Clear;
begin
  FendTime:=0;
  FstartTime:=0;
  FvalueString:='';
end;

constructor TgdWhen.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

function TgdWhen.isEmpty: boolean;
begin
  Result:=FstartTime<=0;//отсутствует обязательное поле
end;

procedure TgdWhen.ParseXML(Node: TXMLNode);
begin
if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_When then
    raise Exception.Create(
               Format(sc_ErrCompNodes,
                      [GetGDNodeName(gd_When)]));
  try
    FendTime:=0;
    FstartTime:=0;
    FvalueString:='';
    if Node.HasAttribute('endTime') then
      FendTime:=ServerDateToDateTime(string(Node.ReadAttributeString('endTime')));
    FstartTime:=ServerDateToDateTime(string(Node.ReadAttributeString('startTime')));
    if Node.HasAttribute('valueString') then
      FvalueString:=string(Node.ReadAttributeString('valueString'));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdAttendeeStatus }

function TgdAttendeeStatus.AddToXML(Root: TXMLNode): TXMLNode;
var tmp: string;
begin
  Result:=nil;
  if (Root=nil) or isEmpty then Exit;

  tmp:=GetEnumName(TypeInfo(TAttendeeStatus),ord(FRel));
  Delete(tmp,1,3);
  tmp:=ReplaceStr(tmp,'_','.');

  Result:=Root.NodeNew(GetGDNodeName(gd_AttendeeStatus));
  Result.WriteAttributeString(sNodeValueAttr,sSchemaHref+UTF8String(tmp));
end;

procedure TgdAttendeeStatus.Clear;
begin
  FRel:=as_None;
end;

constructor TgdAttendeeStatus.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

function TgdAttendeeStatus.isEmpty: boolean;
begin
  Result:=FRel=as_None
end;

procedure TgdAttendeeStatus.ParseXML(Node: TXMLNode);
var tmp: string;
begin
FRel:=as_None;
if (Node=nil)or isEmpty then Exit;
  if GetGDNodeType(Node.Name) <> gd_AttendeeStatus then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_AttendeeStatus)]));
  try
    tmp:=ReplaceStr(string(Node.ReadAttributeString(sNodeValueAttr)),sSchemaHref,'');
    tmp:='as_'+ReplaceStr(tmp,'.','_');
    FRel:=TAttendeeStatus(GetEnumValue(TypeInfo(TAttendeeStatus),tmp));
 except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TgdAttendeeStatus.RelToString: string;
begin
  case FRel of
    as_None: Result:='';
    as_event_accepted: Result:=LoadStr(c_EventAccepted);
    as_event_declined: Result:=LoadStr(c_EventDeclined);
    as_event_invited: Result:=LoadStr(c_EventInvited);
    as_event_tentative: Result:=LoadStr(c_EventTentativ);
  end;
end;

{ TgdAttendeeType }

function TgdAttendeeType.AddToXML(Root: TXMLNode): TXMLNode;
var tmp: string;
begin
Result:=nil;
 if (Root=nil)or IsEmpty then Exit;
  tmp:=GetEnumName(TypeInfo(TAttendeeType),ord(FRel));
  Delete(tmp,1,3);
  tmp:=ReplaceStr(tmp,'_','.');
  Result:=Root.NodeNew(GetGDNodeName(gd_AttendeeType));
  Result.WriteAttributeString(sNodeValueAttr,sSchemaHref+UTF8String(tmp));
end;

procedure TgdAttendeeType.Clear;
begin
  FRel:=at_None;
end;

constructor TgdAttendeeType.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

function TgdAttendeeType.IsEmpty: boolean;
begin
Result:=FRel=at_None
end;

procedure TgdAttendeeType.ParseXML(Node: TXMLNode);
var tmp: string;
begin
  FRel:=at_None;
  if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_AttendeeType then
    raise Exception.Create(
                    Format(sc_ErrCompNodes,
                          [GetGDNodeName(gd_AttendeeType)]));
  try
    tmp:=ReplaceStr(string(Node.ReadAttributeString(sNodeValueAttr)),sSchemaHref,'');
    tmp:='at_'+ReplaceStr(tmp,'.','_');
    FRel:=TAttendeeType(GetEnumValue(TypeInfo(TAttendeeType),tmp));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TgdAttendeeType.RelToString: string;
begin
  case FREl of
    at_None: Result:='';//значение не определено
    at_event_optional: Result:=LoadStr(c_EventOptional);
    at_event_required: Result:=LoadStr(c_EventRequired);
  end;
end;

{ TgdWho }

function TgdWho.AddToXML(Root: TXMLNode): TXMLNode;
begin
Result:=nil;
  if (Root=nil)or IsEmpty then Exit;
  Result:=Root.NodeNew(GetGDNodeName(gd_Who));
  if Length(Trim(FEmail))>0 then
    Result.WriteAttributeString('email',UTF8String(FEmail));
  if Length(Trim(Frel))>0 then
    Result.WriteAttributeString(sNodeRelAttr,sSchemaHref+UTF8String(RelValues[ord(FRelValue)]));
  if Length(Trim(FvalueString))>0 then
    Result.WriteAttributeString('valueString',UTF8String(FvalueString));
    FAttendeeStatus.AddToXML(Result);
    FAttendeeType.AddToXML(Result);
    FEntryLink.AddToXML(Result);
end;

procedure TgdWho.Clear;
begin
FEmail:='';
Frel:='';
FvalueString:='';
FAttendeeStatus.Clear;
FAttendeeType.Clear;
FEntryLink.Clear;
end;

constructor TgdWho.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  FAttendeeStatus:= TgdAttendeeStatus.Create;
  FAttendeeType:= TgdAttendeeType.Create;
  FEntryLink:= TgdEntryLink.Create;
  Clear;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

function TgdWho.IsEmpty: boolean;
begin
  Result:=(Length(Trim(FEmail))=0)and(Length(Trim(Frel))=0)and
           (Length(Trim(FvalueString))=0) and
           (FAttendeeStatus.isEmpty) and
           (FAttendeeType.IsEmpty) and
           (FEntryLink.IsEmpty)
end;

procedure TgdWho.ParseXML(Node: TXMLNode);
var i:integer;
    s:string;
begin
  if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_Who then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_Who)]));
  try
      FEmail:=string(Node.ReadAttributeString('email'));
    if Length(Node.ReadAttributeString(sNodeRelAttr))>0 then
      begin
        S:=string(Node.ReadAttributeString(sNodeRelAttr));
        S:=StringReplace(S,sSchemaHref,'',[rfIgnoreCase]);
        FRelValue:=TWhoRel(AnsiIndexStr(S, RelValues));
      end;
    FvalueString:=string(Node.ReadAttributeString('valueString'));
    if Node.NodeCount>0 then
      begin
        for I := 0 to Node.NodeCount-1 do
          case GetGDNodeType(Node.Nodes[i].Name) of
            gd_AttendeeStatus:
              FAttendeeStatus:=TgdAttendeeStatus.Create(Node.Nodes[i]);
            gd_AttendeeType:
              FAttendeeType:=TgdAttendeeType.Create(Node.Nodes[i]);
            gd_EntryLink:
              FEntryLink:=TgdEntryLink.Create(Node.Nodes[i]);
          end;
      end;
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdRecurrence }

function TgdRecurrence.AddToXML(Root: TXMLNode): TXMLNode;
begin
Result:=nil;
if (Root=nil)or IsEmpty then Exit;
  Result:=Root.NodeNew(GetGDNodeName(gd_Recurrence));
  Result.ValueAsString:=UTF8String(FText.Text);
end;

procedure TgdRecurrence.Clear;
begin
  FText.Clear;
end;

constructor TgdRecurrence.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  FText:=TStringList.Create;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

function TgdRecurrence.IsEmpty: boolean;
begin
  Result:=FText.Count=0
end;

procedure TgdRecurrence.ParseXML(Node: TXMLNode);
begin
if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_Recurrence then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_Recurrence)]));
  try
    FText.Text:=string(Node.ValueAsString);
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdReminder }

function TgdReminder.AddToXML(Root:TXMLNode): TXMLNode;
begin
Result:=nil;
  if Root=nil then Exit;
  Result:=Root.NodeNew(GetGDNodeName(gd_Reminder));
  Result.WriteAttributeString('method',UTF8String(cMethods[ord(Fmethod)]));
  case FPeriod of
    tpDays: Result.WriteAttributeInteger('days',FPeriodValue);
    tpHours: Result.WriteAttributeInteger('hours',FPeriodValue);
    tpMinutes: Result.WriteAttributeInteger('minutes',FPeriodValue);
  end;
  if FabsoluteTime>0 then
    Result.WriteAttributeString('absoluteTime',UTF8String(DateTimeToServerDate(FabsoluteTime)))
end;

constructor TgdReminder.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  FabsoluteTime:=0;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdReminder.ParseXML(Node: TXMLNode);
begin
if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_Reminder then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_Reminder)]));
  try
    if Length(Node.ReadAttributeString('absoluteTime'))>0 then
      FabsoluteTime:=ServerDateToDateTime(string(Node.ReadAttributeString('absoluteTime')));
    if length(Node.ReadAttributeString('method'))>0 then
       Fmethod:=TMethod(AnsiIndexStr(string(Node.ReadAttributeString('method')), cMethods));
    if Node.AttributeIndexByname('days')>=0 then
       FPeriod:=tpDays;
    if Node.AttributeIndexByname('hours')>=0 then
       FPeriod:=tpHours;
    if Node.AttributeIndexByname('minutes')>=0 then
       FPeriod:=tpMinutes;
    case FPeriod of
      tpDays: FPeriodValue:=Node.ReadAttributeInteger('days');
      tpHours: FPeriodValue:=Node.ReadAttributeInteger('hours');
      tpMinutes: FPeriodValue:=Node.ReadAttributeInteger('minutes');
    end;

  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdTransparency }

function TgdTransparency.AddToXML(Root: TXMLNode): TXMLNode;
var tmp: string;
begin
Result:=nil;
if (Root=nil)or IsEmpty then Exit;

tmp:=ReplaceStr(GetEnumName(TypeInfo(TTransparency),ord(FRel)),'_','.');
Delete(tmp,1,3);
Result:=Root.NodeNew(GetGDNodeName(gd_Transparency));
Result.WriteAttributeString(sNodeValueAttr,sSchemaHref+UTF8String(tmp));
end;

procedure TgdTransparency.Clear;
begin
  FRel:=tt_None;
end;

constructor TgdTransparency.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

function TgdTransparency.IsEmpty: boolean;
begin
  Result:=FRel=tt_None
end;

procedure TgdTransparency.ParseXML(Node: TXMLNode);
var tmp: string;
begin
 FRel:=tt_None;
 if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_Transparency then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_Transparency)]));
  try
    tmp:= ReplaceStr(string(Node.ReadAttributeString(sNodeValueAttr)),sSchemaHref,'');
    tmp:='tt_'+ReplaceStr(tmp,'.','_');
    FRel:=TTransparency(GetEnumValue(TypeInfo(TTransparency),tmp));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TgdTransparency.RelToString: string;
begin
  case FRel of
    tt_None: Result:='';
    tt_event_opaque: Result:=LoadStr(c_EventOpaque);
    tt_event_transparent: Result:=LoadStr(c_EventTransp);
  end;
end;

{ TgdVisibility }

function TgdVisibility.AddToXML(Root: TXMLNode): TXMLNode;
var tmp: string;
begin
Result:=nil;
if (Root=nil)or IsEmpty then Exit;
tmp:=ReplaceStr(GetEnumName(TypeInfo(TVisibility),ord(FRel)),'_','.');
Delete(tmp,1,3);
Result:=Root.NodeNew(GetGDNodeName(gd_Visibility));
Result.WriteAttributeString(sNodeValueAttr,sSchemaHref+UTF8String(tmp));
end;

procedure TgdVisibility.Clear;
begin
  FRel:=vs_None;
end;

constructor TgdVisibility.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

function TgdVisibility.IsEmpty: boolean;
begin
  Result:=FRel=vs_None
end;

procedure TgdVisibility.ParseXML(Node: TXMLNode);
var tmp:string;
begin
 FRel:=vs_None;
{TVisibility = (vs_None, vs_event_confidential, vs_event_default,
                 vs_event_private, vs_event_public);}
 if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_Visibility then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_Visibility)]));
  try
    tmp:=ReplaceStr(string(Node.ReadAttributeString(sNodeValueAttr)),sSchemaHref,'');
    tmp:='vs_'+ReplaceStr(tmp,'.','_');
    FRel:=TVisibility(GetEnumValue(TypeInfo(TVisibility),tmp));
//    FValue := ;
//    FValue:=StringReplace(FValue,sSchemaHref,'',[rfIgnoreCase]);
//    FVisible := TVisibility(AnsiIndexStr(FValue, RelValues));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TgdVisibility.RelToString: string;
begin
  case FRel of
    vs_None: Result:='';//значение не определено
    vs_event_confidential: Result:=LoadStr(c_EventConfident);
    vs_event_default:Result:=LoadStr(c_EventDefault);
    vs_event_private:Result:=LoadStr(c_EventPrivate);
    vs_event_public:Result:=LoadStr(c_EventPublic);
  end;
end;

{ TgdOrganization }

function TgdOrganization.AddToXML(Root: TXMLNode): TXmlNode;
begin
Result:=nil;
if (Root=nil)or IsEmpty then Exit;


Result:=Root.NodeNew(GetGDNodeName(gd_Organization));
if Trim(FRel)<>'' then
  Result.WriteAttributeString(sNodeRelAttr,UTF8String(FRel));
if Trim(FLabel)<>'' then
  Result.WriteAttributeString(sNodeLabelAttr,UTF8String(FLabel));
if FPrimary then
  Result.WriteAttributeBool('primary',Fprimary);
if Trim(ForgName.Value)<>'' then
  ForgName.AddToXML(Result);
if Trim(ForgTitle.Value)<>'' then
  ForgTitle.AddToXML(Result);
end;

procedure TgdOrganization.Clear;
begin
  FLabel:='';
  Frel:='';
end;

constructor TgdOrganization.Create(ByNode: TXMLNode);
begin
  inherited Create;
   ForgName:=TgdOrgName.Create;
   ForgTitle:=TgdOrgTitle.Create;
   Clear;
  if ByNode<>nil then
    ParseXML(ByNode);

end;

function TgdOrganization.IsEmpty: boolean;
begin
   Result:=(Length(Trim(FLabel))=0)and(Length(Trim(Frel))=0)and(ForgName.IsEmpty)and(ForgTitle.IsEmpty)
end;

procedure TgdOrganization.ParseXML(const Node: TXmlNode);
var i:integer;
begin
if (Node=nil)or IsEmpty then Exit;
  if GetGDNodeType(Node.Name) <> gd_Organization then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_Organization)]));
  try
    Frel:=string(Node.ReadAttributeString(sNodeRelAttr));
    if Node.HasAttribute('primary') then
      Fprimary:=Node.ReadAttributeBool('primary');
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel:=string(Node.ReadAttributeString(sNodeLabelAttr));
    for i:=0 to Node.NodeCount-1 do
      begin
        if LowerCase(string(Node.Nodes[i].Name))=LowerCase(string(GetGDNodeName(gd_OrgName))) then
          ForgName:=TgdOrgName.Create(Node.Nodes[i])
        else
          if LowerCase(string(Node.Nodes[i].Name))=LowerCase(string(GetGDNodeName(gd_OrgTitle))) then
            ForgTitle:=TgdOrgTitle.Create(Node.Nodes[i]);
      end;
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdEmailStruct }

function TgdEmail.AddToXML(Root: TXMLNode): TXmlNode;
var tmp: string;
begin
Result:=nil;
  if (Root=nil)or IsEmpty then Exit;
  Result:=Root.NodeNew(GetGDNodeName(gd_Email));
  if FRel<>em_None then
    begin
      tmp:=GetEnumName(TypeInfo(TTypeElement),ord(FRel));
      Delete(tmp,1,3);
      Result.WriteAttributeString(sNodeRelAttr,sSchemaHref+UTF8String(tmp));
    end;
  if Trim(FLabel)<>'' then
    Result.WriteAttributeString(sNodeLabelAttr,UTF8String(FLabel));
  if Trim(FLabel)<>'' then
    Result.WriteAttributeString('displayName',UTF8String(FDisplayName));
  if FPrimary then
    Result.WriteAttributeBool('primary',FPrimary);
  Result.WriteAttributeString('address',UTF8String(FAddress));
end;

procedure TgdEmail.Clear;
begin
  FAddress:='';
  FLabel:='';
  FRel:=em_None;
  FDisplayName:='';
end;

constructor TgdEmail.Create(ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TgdEmail.IsEmpty: boolean;
begin
  Result:=Length(Trim(FAddress))=0;//отсутствует обязательное поле
end;

procedure TgdEmail.ParseXML(const Node: TXmlNode);
var tmp: string;
begin
  {TTypeElement = (em_None, em_home,em_other, em_work);}
  FRel:=em_None;
  if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_Email then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_Email)]));
  try
    tmp:='em_'+ReplaceStr(string(Node.ReadAttributeString(sNodeRelAttr)),sSchemaHref,'');
    Frel:=TTypeElement(GetEnumValue(TypeInfo(TTypeElement),tmp));
    if Node.HasAttribute('primary') then
      Fprimary:=Node.ReadAttributeBool('primary');
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel:=string(Node.ReadAttributeString(sNodeLabelAttr));
    if Node.HasAttribute('displayName') then
      FDisplayName:=string(Node.ReadAttributeString('displayName'));
    FAddress:=string(Node.ReadAttributeString('address'));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TgdEmail.RelToString: string;
begin
  case FRel of
    em_None: Result:='';//значение не определено
    em_home: Result:=LoadStr(c_EmailHome);
    em_other: Result:=LoadStr(c_EmailOther);
    em_work: Result:=LoadStr(c_EmailWork);
  end;
end;

//procedure TgdEmail.SetEmailType(aType: TTypeElement);
//begin
//FEmailType:=aType;
//SetRel(RelValues[ord(aType)]);
//end;
//
//procedure TgdEmail.SetRel(const aRel: string);
//begin
//  if AnsiIndexStr(aRel,RelValues)<0 then
//   raise Exception.Create
//      (Format(sc_ErrWriteNode, [GetGDNodeName(gd_Email)])+' '+Format(sc_WrongAttr,['rel']));
//  FRel:=sSchemaHref+aRel;
//end;

{ TgdNameStruct }

function TgdName.AddToXML(Root: TXMLNode): TXmlNode;
begin
Result:=nil;
  if (Root=nil)or IsEmpty then Exit;

  Result:=Root.NodeNew(GetGDNodeName(gd_Name));
  if (AdditionalName<>nil)and(not AdditionalName.IsEmpty) then
    AdditionalName.AddToXML(Result);

  if (GivenName<>nil)and(not GivenName.IsEmpty) then
    GivenName.AddToXML(Result);
  if (FamilyName<>nil)and(not FamilyName.IsEmpty) then
    FamilyName.AddToXML(Result);
  if (not NamePrefix.IsEmpty) then
    NamePrefix.AddToXML(Result);
  if not NameSuffix.IsEmpty then
    NameSuffix.AddToXML(Result);
  if not FullName.IsEmpty then
    FullName.AddToXML(Result);
end;

procedure TgdName.Clear;
begin
  FGivenName.Clear;
  FAdditionalName.Clear;
  FFamilyName.Clear;
  FNamePrefix.Clear;
  FNameSuffix.Clear;
  FFullName.Clear;
end;

constructor TgdName.Create(ByNode: TXMLNode);
begin
  inherited Create;
  FGivenName:=TgdGivenName.Create(string(GetGDNodeName(gd_givenName)));
  FAdditionalName:=TgdAdditionalName.Create(string(GetGDNodeName(gd_additionalName)));
  FFamilyName:=TgdFamilyName.Create(string(GetGDNodeName(gd_familyName)));
  FNamePrefix:=TgdNamePrefix.Create(string(GetGDNodeName(gd_namePrefix)));
  FNameSuffix:=TgdNameSuffix.Create(string(GetGDNodeName(gd_nameSuffix)));
  FFullName:=TgdFullName.Create(string(GetGDNodeName(gd_fullName)));
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TgdName.GetFullName: string;
begin
  if FFullName<>nil then
    Result:=FFullName.Value;
end;

function TgdName.IsEmpty: boolean;
begin
Result:= FGivenName.IsEmpty and FAdditionalName.IsEmpty and
         FFamilyName.IsEmpty and FNamePrefix.IsEmpty and
         FNameSuffix.IsEmpty and FFullName.IsEmpty;
end;

procedure TgdName.ParseXML(const Node: TXmlNode);
var i:integer;
begin
  if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_Name then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_Name)]));
  try
    for i:=0 to Node.NodeCount-1 do
      begin
        case GetGDNodeType(Node.Nodes[i].Name) of
          gd_GivenName:FGivenName.ParseXML(Node.Nodes[i]);
          gd_AdditionalName:FAdditionalName.ParseXML(Node.Nodes[i]);
          gd_FamilyName:FFamilyName.ParseXML(Node.Nodes[i]);
          gd_NamePrefix:FNamePrefix.ParseXML(Node.Nodes[i]);
          gd_NameSuffix:FNameSuffix.ParseXML(Node.Nodes[i]);
          gd_FullName:FFullName.ParseXML(Node.Nodes[i]);
        end;
      end;
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

procedure TgdName.SetAdditionalName(aAdditionalName: TTextTag);
begin
if aAdditionalName=nil then Exit;
if length(FAdditionalName.Name)=0 then
  FAdditionalName.Name:=string(GetGDNodeName(gd_additionalName));
FAdditionalName.Value:=aAdditionalName.Value;
end;

procedure TgdName.SetFamilyName(aFamilyName: TTextTag);
begin
if aFamilyName=nil then Exit;
if length(FFamilyName.Name)=0 then
  FFamilyName.Name:=string(GetGDNodeName(gd_familyName));
FFamilyName.Value:=aFamilyName.Value;
end;

procedure TgdName.SetFullName(aFullName: TTextTag);
begin
if aFullName=nil then Exit;
if length(FFullName.Name)=0 then
  FFullName.Name:=string(GetGDNodeName(gd_fullName));
FFullName.Value:=aFullName.Value;
end;

procedure TgdName.SetGivenName(aGivenName: TTextTag);
begin
if aGivenName=nil then Exit;
if length(FGivenName.Name)=0 then
  FGivenName.Name:=string(GetGDNodeName(gd_givenName));
FFullName.Value:=aGivenName.Value;
end;

procedure TgdName.SetNamePrefix(aNamePrefix: TTextTag);
begin
if aNamePrefix=nil then Exit;
if length(FNamePrefix.Name)=0 then
  FNamePrefix.Name:=string(GetGDNodeName(gd_namePrefix));
FNamePrefix.Value:=aNamePrefix.Value;
end;

procedure TgdName.SetNameSuffix(aNameSuffix: TTextTag);
begin
 if aNameSuffix=nil then Exit;
if length(FNameSuffix.Name)=0 then
  FNameSuffix.Name:=string(GetGDNodeName(gd_nameSuffix));
FNameSuffix.Value:=aNameSuffix.Value;
end;

{ TgdPhoneNumber }

function TgdPhoneNumber.AddToXML(Root: TXMLNode): TXmlNode;
var tmp:string;
begin
Result:=nil;
  if (Root=nil)or IsEmpty then Exit;
  Result:=Root.NodeNew(GetGDNodeName(gd_PhoneNumber));

  if Frel<>tp_None then
    begin
      tmp:=GetEnumName(TypeInfo(TPhonesRel),Ord(FRel));
      Delete(tmp,1,3);
      Result.WriteAttributeString(sNodeRelAttr,sSchemaHref+UTF8String(tmp));
    end;


  Result.ValueAsString:=UTF8String(FValue);
  if Trim(FLabel)<>'' then
    Result.WriteAttributeString(sNodeLabelAttr,UTF8String(FLabel));
  if Trim(FUri)<>'' then
    Result.WriteAttributeString('uri',UTF8String(FUri));
  if FPrimary then
    Result.WriteAttributeBool('primary',FPrimary);
end;

procedure TgdPhoneNumber.Clear;
begin
  FLabel:='';
  FUri:='';
  FValue:='';
end;

constructor TgdPhoneNumber.Create(ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TgdPhoneNumber.IsEmpty: boolean;
begin
  Result:=(Length(Trim(FLabel))=0)and(Length(Trim(FUri))=0)and(Length(Trim(FValue))=0)
end;

procedure TgdPhoneNumber.ParseXML(const Node: TXmlNode);
var tmp:string;
begin
{ TPhonesRel=(tp_None, tp_Assistant,tp_Callback,tp_Car,Tp_Company_main,
      tp_Fax, tp_Home,tp_Home_fax,tp_Isdn,tp_Main,tp_Mobile,tp_Other,
      tp_Other_fax, tp_Pager,tp_Radio,tp_Telex,tp_Tty_tdd,Tp_Work,
      tp_Work_fax,  tp_Work_mobile,tp_Work_pager);}
  FRel:=tp_None;
  if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_PhoneNumber then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_PhoneNumber)]));
  try
    tmp:='tp_'+ReplaceStr(string(Node.ReadAttributeString(sNodeRelAttr)),sSchemaHref,'');
    if Length(tmp)>3 then
      FRel:=TPhonesRel(GetEnumValue(TypeInfo(TPhonesRel),tmp));

//    s:=StringReplace(s,sSchemaHref,'',[rfIgnoreCase]);
//    if AnsiIndexStr(s,RelValues)>-1 then
//      FPhoneType:=TPhonesRel(AnsiIndexStr(s,RelValues))
//    else
//      FPhoneType:=tpOther;
    if Node.HasAttribute('primary') then
      Fprimary:=Node.ReadAttributeBool('primary');
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel:=string(Node.ReadAttributeString(sNodeLabelAttr));
    if Node.HasAttribute('uri') then
      FUri:=string(Node.ReadAttributeString('uri'));
    FValue:=string(Node.ValueAsString);
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TgdPhoneNumber.RelToString: string;
begin
  case FRel of
    tp_None: Result:='';
    tp_Assistant: Result:=LoadStr(c_PhoneAssistant);
    tp_Callback: Result:=LoadStr(c_PhoneCallback);
    tp_Car: Result:=LoadStr(c_PhoneCar);
    Tp_Company_main: Result:=LoadStr(c_PhoneCompanymain);
    tp_Fax: Result:=LoadStr(c_PhoneFax);
    tp_Home: Result:=LoadStr(c_PhoneHome);
    tp_Home_fax: Result:=LoadStr(c_PhoneHomefax);
    tp_Isdn: Result:=LoadStr(c_PhoneIsdn);
    tp_Main: Result:=LoadStr(c_PhoneMain);
    tp_Mobile: Result:=LoadStr(c_PhoneMobile);
    tp_Other: Result:=LoadStr(c_PhoneOther);
    tp_Other_fax: Result:=LoadStr(c_PhoneOtherfax);
    tp_Pager: Result:=LoadStr(c_PhonePager);
    tp_Radio: Result:=LoadStr(c_PhoneRadio);
    tp_Telex: Result:=LoadStr(c_PhoneTelex);
    tp_Tty_tdd: Result:=LoadStr(c_PhoneTtytdd);
    Tp_Work: Result:=LoadStr(c_PhoneWork);
    tp_Work_fax: Result:=LoadStr(c_PhoneWorkfax);
    tp_Work_mobile: Result:=LoadStr(c_PhoneWorkmobile);
    tp_Work_pager: Result:=LoadStr(c_PhoneWorkpager);
  end;
end;

{ TgdCountry }

function TgdCountry.AddToXML(Root: TXMLNode): TXMLNode;
begin
Result:=nil;
 if (Root=nil)or IsEmpty then Exit;
 Result:=Root.NodeNew(GetGDNodeName(gd_Country));
 if Trim(FCode)<>'' then
   Result.WriteAttributeString('code',UTF8String(FCode));
 Result.ValueAsString:=UTF8String(FValue);
end;

procedure TgdCountry.Clear;
begin
  FCode:='';
  FValue:='';
end;

constructor TgdCountry.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TgdCountry.IsEmpty: boolean;
begin
Result:=(Length(Trim(FCode))=0)and (Length(Trim(FValue))=0);
end;

procedure TgdCountry.ParseXML(Node: TXMLNode);
begin
  if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_Country then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_Country)]));
  try
    FCode:=string(Node.ReadAttributeString(sNodeRelAttr));
    FValue:=string(Node.ValueAsString);
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdStructuredPostalAddressStruct }

function TgdStructuredPostalAddress.AddToXML(Root: TXMLNode): TXMLNode;
begin
Result:=nil;
  if (Root=nil) or IsEmpty then Exit;
  Result:=Root.NodeNew(GetGDNodeName(gd_StructuredPostalAddress));
  if Trim(FRel)<>'' then
     Result.WriteAttributeString(sNodeRelAttr,UTF8String(FRel));
  if Trim(FMailClass)<>'' then
     Result.WriteAttributeString('mailClass',UTF8String(FMailClass));
  if Trim(Flabel)<>'' then
     Result.WriteAttributeString(sNodeLabelAttr,UTF8String(Flabel));
  if Trim(FUsage)<>'' then
     Result.WriteAttributeString('Usage',UTF8String(FUsage));
  if Fprimary then
     Result.WriteAttributeBool('primary',Fprimary);
  if FAgent<>nil then
     FAgent.AddToXML(Result);
  if FHousename<>nil then
     FHousename.AddToXML(Result);
  if FStreet<>nil then
     FStreet.AddToXML(Result);
  if FPobox<>nil then
     FPobox.AddToXML(Result);
  if FNeighborhood<>nil then
     FNeighborhood.AddToXML(Result);
  if FCity<>nil then
     FCity.AddToXML(Result);
  if FSubregion<>nil then
     FSubregion.AddToXML(Result);
  if FRegion<>nil then
     FRegion.AddToXML(Result);
  if FPostcode<>nil then
     FPostcode.AddToXML(Result);
  if FCountry<>nil then
     FCountry.AddToXML(Result);
  if FFormattedAddress<>nil then
     FFormattedAddress.AddToXML(Result);
end;

procedure TgdStructuredPostalAddress.Clear;
begin
 FRel:='';
 FMailClass:='';
 FUsage:='';
 Flabel:='';
 FAgent.Clear;
 FHouseName.Clear;
 FStreet.Clear;
 FPobox.Clear;
 FNeighborhood.Clear;
 FCity.Clear;
 FSubregion.Clear;
 FRegion.Clear;
 FPostcode.Clear;
 FCountry.Clear;
 FFormattedAddress.Clear;
end;

constructor TgdStructuredPostalAddress.Create(const ByNode: TXMLNode);
begin
 inherited Create;
 FAgent:= TgdAgent.Create;
 FHouseName:= TgdHousename.Create;
 FStreet:= TgdStreet.Create;
 FPobox:= TgdPobox.Create;
 FNeighborhood:= TgdNeighborhood.Create;
 FCity:= TgdCity.Create;
 FSubregion:= TgdSubregion.Create;
 FRegion:= TgdRegion.Create;
 FPostcode:= TgdPostcode.Create;
 FCountry:= TgdCountry.Create;
 FFormattedAddress:= TgdFormattedAddress.Create;

 Clear;
 if ByNode<>nil then
   ParseXML(ByNode);
end;

function TgdStructuredPostalAddress.IsEmpty: boolean;
begin
Result:=(Length(Trim(FRel))=0)and (Length(Trim(FMailClass))=0)and
(Length(Trim(FUsage))=0)and(Length(Trim(Flabel))=0)and
FAgent.IsEmpty and
FHouseName.IsEmpty and
FStreet.IsEmpty and
FPobox.IsEmpty and
FNeighborhood.IsEmpty and
FCity.IsEmpty and
FSubregion.IsEmpty and
FRegion.IsEmpty and
FPostcode.IsEmpty and
FCountry.IsEmpty and
FFormattedAddress.IsEmpty;
end;

procedure TgdStructuredPostalAddress.ParseXML(Node: TXMLNode);
var i:integer;
begin
if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_StructuredPostalAddress then
    raise Exception.Create(Format(sc_ErrCompNodes,
        [GetGDNodeName(gd_StructuredPostalAddress)]));
  try
    FRel:=string(Node.ReadAttributeString(sNodeRelAttr));
    FMailClass:=string(Node.ReadAttributeString('mailClass'));
    Flabel:=string(Node.ReadAttributeString(sNodeLabelAttr));
    if Node.HasAttribute('primaty') then
      Fprimary:=Node.ReadAttributeBool('primary');
    FUsage:=String(Node.ReadAttributeString('Usage'));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
  for I := 0 to Node.NodeCount - 1 do
    begin
      case GetGDNodeType(Node.Nodes[i].Name) of
        gd_Agent:FAgent.ParseXML(Node.Nodes[i]);
        gd_Housename:FHousename.ParseXML(Node.Nodes[i]);
        gd_Street:FStreet.ParseXML(Node.Nodes[i]);
        gd_Pobox:FPobox.ParseXML(Node.Nodes[i]);
        gd_Neighborhood:FNeighborhood.ParseXML(Node.Nodes[i]);
        gd_City:FCity.ParseXML(Node.Nodes[i]);
        gd_Subregion:FSubregion.ParseXML(Node.Nodes[i]);
        gd_Region:FRegion.ParseXML(Node.Nodes[i]);
        gd_Postcode:FPostcode.ParseXML(Node.Nodes[i]);
        gd_Country:FCountry.ParseXML(Node.Nodes[i]);
        gd_FormattedAddress:FFormattedAddress.ParseXML(Node.Nodes[i]);
      end;
    end;
end;

{ TgdIm }

function TgdIm.AddToXML(Root: TXMLNode): TXmlNode;
var tmp:string;
begin
Result:=nil;
  if (Root=nil)or IsEmpty then Exit;
  Result:=Root.NodeNew(GetGDNodeName(gd_Im));

{TIMProtocol = (ti_None, ti_AIM,ti_MSN,ti_YAHOO,ti_SKYPE,ti_QQ,ti_GOOGLE_TALK,
                 ti_ICQ, ti_JABBER);
  TIMtype = (im_None, im_home,im_netmeeting,im_other,im_work);}

  tmp:=GetEnumName(TypeInfo(TIMtype),ord(FIMType));
  Delete(tmp,1,3);
  Result.WriteAttributeString(sNodeRelAttr,sSchemaHref+UTF8String(tmp));
  Result.WriteAttributeString('address',UTF8String(FAddress));
  Result.WriteAttributeString(sNodeLabelAttr,UTF8String(FLabel));

  tmp:=GetEnumName(TypeInfo(TIMProtocol),ord(FIMProtocol));
  Delete(tmp,1,3);
  Result.WriteAttributeString('protocol',sSchemaHref+UTF8String(tmp));

  if FPrimary then
    Result.WriteAttributeBool('primary',FPrimary);
end;

procedure TgdIm.Clear;
begin
  FAddress:='';
  FLabel:='';
end;

constructor TgdIm.Create(ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TgdIm.ImProtocolToString: string;
begin
  Result:=GetEnumName(TypeInfo(TImProtocol),ord(FIMProtocol));
  Delete(Result,1,3);
end;

function TgdIm.ImTypeToString: string;
begin
  case FIMType of
    im_None: Result:='';//значение не определено
    im_home: Result:=LoadStr(c_ImHome);
    im_netmeeting: Result:=LoadStr(c_ImNetMeeting);
    im_other: Result:=LoadStr(c_ImOther);
    im_work: Result:=LoadStr(c_ImWork);
  end;
end;

function TgdIm.IsEmpty: boolean;
begin
  Result:=(Length(Trim(FAddress))=0);//отсутствует обязательное поле
end;

procedure TgdIm.ParseXML(const Node: TXmlNode);
var tmp:string;
begin
FIMProtocol:=ti_None;
FIMType:=im_None;
if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> gd_Im then
    raise Exception.Create(Format(sc_ErrCompNodes,
          [GetGDNodeName(gd_Im)]));
  try
    tmp:='im_'+ReplaceStr(string(Node.ReadAttributeString(sNodeRelAttr)),sSchemaHref,'');
    FIMType:=TImtype(GetEnumValue(TypeInfo(TImtype),tmp));

    FLabel:=string(Node.ReadAttributeString(sNodeLabelAttr));
    FAddress:=string(Node.ReadAttributeString('address'));

    tmp:='ti_'+ReplaceStr(string(Node.ReadAttributeString('protocol')),sSchemaHref,'');
    FIMProtocol:=TIMProtocol(GetEnumValue(TypeInfo(TIMProtocol),tmp));

    if Node.HasAttribute('primary') then
      FPrimary:=Node.ReadAttributeBool('primary');
  except
     raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

end.
