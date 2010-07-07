unit GContacts;

interface

uses NativeXML, strUtils, httpsend, GHelper,Classes,SysUtils,
GDataCommon,Generics.Collections,Dialogs,jpeg, Graphics, typinfo,
IOUtils,uLanguage,blcksock,Windows,GConsts;

type
  TParseElement = (T_Group, T_Contact);
//события компонента
  TOnRetriveXML = procedure (const FromURL:string) of object;
  TOnBeginParse = procedure (const What: TParseElement; Total, Number: integer) of object;
  TOnEndParse = procedure (const What: TParseElement; Element: TObject) of object;
  TOnReadData = procedure (const TotalBytes, ReadBytes: int64) of object;

type
  THTTPSender = class(THTTPSend)
  private
    FMethod: string;
    FURL: string;
    FAuthKey:string;
    FApiVersion:string;
    FExtendedHeaders:TStringList;
    procedure SetApiVersion(const Value: string);
    procedure SetAuthKey(const Value: string);
    procedure SetExtendedHeaders(const Value: TStringList);
    procedure SetMethod(const Value: string);
    procedure SetURL(const Value: string);
    function HeadByName(const aHead:string;aHeaders:TStringList):string;
    procedure AddGoogleHeaders;
  public
    constructor Create(const aMethod,aAuthKey, aURL, aAPIVersion:string);
    procedure Clear;
    function GetLength(const aURL:string):integer;
    function  SendRequest: boolean;
    property  Method: string  read FMethod write SetMethod;
    property  URL: string read FURL write SetURL;
    property  AuthKey:string read FAuthKey write SetAuthKey;
    property  ApiVersion:string read FApiVersion write SetApiVersion;
    property  ExtendedHeaders:TStringList read FExtendedHeaders write SetExtendedHeaders;
end;

type
  TcpTagEnum = (cp_billingInformation,cp_birthday,cp_calendarLink,
  cp_directoryServer,cp_event,cp_externalId,cp_gender,
  cp_groupMembershipInfo,cp_hobby, cp_initials,
  cp_jot,cp_language,cp_maidenName,cp_mileage,cp_nickname,
  cp_occupation,cp_priority,cp_relation,cp_sensitivity,cp_shortName,
  cp_subject,cp_userDefinedField,cp_website,cp_systemGroup,cp_None);

type
  TcpBillingInformation = TTextTag;
  TcpDirectoryServer = TTextTag;
  TcpHobby = TTextTag;
  TcpInitials = TTextTag;
  TcpShortName = TTextTag;
  TcpSubject = TTextTag;
  TcpMaidenName = TTextTag;
  TcpMileage = TTextTag;
  TcpNickname = TTextTag;
  TcpOccupation = TTextTag;

type
  TcpBirthday =class
  private
    FDate  : TDate;
    FShortFormat: boolean;//укороченый формат дня рождения --MM-DD
    procedure SetDate(aDate:TDate);
    function GetServerDate: string;
  public
    constructor Create(const byNode: TXmlNode=nil);
    procedure Clear;
    function IsEmpty: boolean;
    procedure ParseXML(const Node: TXmlNode);
    function AddToXML(Root: TXMLNode):TXMLNode;
    property ShotrFormat: boolean read FShortFormat write FShortFormat;
    property Date: TDate read FDate write SetDate;
    property ServerDate : string read GetServerDate;
end;

type
  TCalendarRel = (tc_none,tc_work,tc_home,tc_free_busy);
  TcpCalendarLink = class
  private
    FRel: TCalendarRel;
    FLabel: string;
    FPrimary: boolean;
    FHref: string;
  public
    constructor Create(const byNode: TXMLNode=nil);
    procedure ParseXML(const Node: TXmlNode);
    function  RelToString:string;
    procedure Clear;
    function  AddToXML(Root:TXmlNode):TXmlNode;
    function isEmpty:boolean;
    property Rel: TCalendarRel read FRel write Frel;
    property Primary: boolean read FPrimary write FPrimary;
    property Href: string read FHref write FHref;
end;

type
  TEventRel = (teNone,teAnniversary,teOther);
  TcpEvent = class
  private
    FEventType: TEventRel;
    Flabel: string;
    FWhen: TgdWhen;
  public
    constructor Create(const byNode: TXmlNode=nil);
    procedure Clear;
    procedure ParseXML(const Node: TXMLNode);
    function  RelToString:string;
    function IsEmpty: boolean;
    function AddToXML(Root: TXmlNode):TXmlNode;
    property EventType: TEventRel read FEventType write FEventType;
    property Labl:string read Flabel write Flabel;
 end;

type
  TExternalIdType = (tiNone,tiAccount,tiCustomer,tiNetwork,tiOrganization);
  TcpExternalId = class
  private
    Frel: TExternalIdType;
    FLabel: string;
    FValue: string;
  public
    constructor Create(const ByNode: TXMLNode=nil);
    procedure Clear;
    procedure ParseXML(const Node: TXmlNode);
    function  RelToString:string;
    function IsEmpty:boolean;
    function AddToXML(Root: TXmlNode):TXmlNode;
    property Rel: TExternalIdType read Frel write FRel;
    property Labl: string read FLabel write FLabel;
    property Value: string read FValue write FValue;
end;

type
  TGenderType = (none,male,female);
  TcpGender = class
  private
    FValue: TGenderType;
  public
    constructor Create(const ByNode: TXMLNode=nil);
    procedure Clear;
    function IsEmpty:boolean;
    function ValueToString: string;
    procedure ParseXML(const Node: TXmlNode);
    function AddToXML(Root: TXmlNode):TXmlNode;
    property Value: TGenderType read FValue write FValue;
end;

type
  TcpGroupMembershipInfo = class
  private
    FDeleted: boolean;
    FHref: string;
  public
    constructor Create(const ByNode: TXMLNode=nil);
    procedure Clear;
    procedure ParseXML(const Node: TXmlNode);
    function IsEmpty: boolean;
    function AddToXML(Root: TXmlNode):TXmlNode;
    property Href: string read FHref write FHref;
    property Deleted:boolean read FDeleted write FDeleted;
end;

type
  TJotRel = (TjNone,Tjhome, Tjwork, Tjother, Tjkeywords, Tjuser);
  TcpJot = class
  private
    FRel: TJotRel;
    FText: string;
  public
    constructor Create(const ByNode: TXMLNode=nil);
    procedure Clear;
    procedure ParseXML(const Node: TXmlNode);
    function RelToString:string;
    function IsEmpty: boolean;
    function AddToXML(Root: TXmlNode):TXmlNode;
    property Rel: TJotRel read FRel write FRel;
    property Text:string read FText write FText;
end;

type
  TcpLanguage = class
  private
    Fcode: string;
    Flabel: string;
  public
    constructor Create(const ByNode: TXMLNode=nil);
    procedure Clear;
    function IsEmpty: boolean;
    procedure ParseXML(const Node: TXmlNode);
    function AddToXML(Root: TXmlNode):TXmlNode;
    property Code: string read Fcode write Fcode;
    property Labl:string read Flabel write Flabel;
end;

type
  TPriotityRel = (TpNone,Tplow,Tpnormal,Tphigh);
  TcpPriority = class
  private
    FRel: TPriotityRel;
  public
    constructor Create(const ByNode: TXMLNode=nil);
    procedure Clear;
    function IsEmpty:boolean;
    function RelToString: string;
    procedure ParseXML(const Node: TXmlNode);
    function AddToXML(Root: TXmlNode):TXmlNode;
    property Rel: TPriotityRel read FRel write FRel;
end;

type
  TRelationType = (tr_None,tr_assistant,tr_brother,tr_child,
                   tr_domestic_partner,tr_father,tr_friend,
                   tr_manager,tr_mother,tr_parent,tr_partner,
                   tr_referred_by,tr_relative,tr_sister,tr_spouse);

  TcpRelation = class
  private
    FValue: string;
    FLabel: string;
    FRealition:TRelationType;
    function GetRelStr(aRel:TRelationType):string;
  public
    constructor Create(const ByNode: TXMLNode=nil);
    procedure Clear;
    function RelToString: string;
    function IsEmpty:boolean;
    procedure ParseXML(const Node: TXmlNode);
    function AddToXML(Root: TXmlNode):TXmlNode;
    property Realition:TRelationType read FRealition write FRealition;
    property Value: string read FValue write FValue;
end;

type
  TSensitivityRel = (TsNone,Tsconfidential,Tsnormal,Tspersonal,Tsprivate);
  TcpSensitivity = class
  private
    FRel: TSensitivityRel;
  public
    constructor Create(const ByNode: TXMLNode=nil);
    procedure Clear;
    function IsEmpty:boolean;
    function RelToString: string;
    procedure ParseXML(const Node: TXmlNode);
    function AddToXML(Root: TXmlNode):TXmlNode;
    property Rel: TSensitivityRel read FRel write FRel;
end;

type
  TcpSysGroupId = (tg_None, tg_Contacts,tg_Friends,tg_Family,tg_Coworkers);
  TcpSystemGroup = class
  private
    FIdRel: TcpSysGroupId;
  public
    constructor Create(const ByNode: TXMLNode=nil);
    procedure Clear;
    function  IsEmpty:boolean;
    function RelToString:string;
    procedure ParseXML(const Node: TXmlNode);
    function  AddToXML(Root: TXmlNode):TXmlNode;
    property  ID: TcpSysGroupId read FIdRel write FIdRel;
end;

type
  TcpUserDefinedField = class
  private
    FKey: string;
    FValue: string;
  public
    constructor Create(const ByNode: TXMLNode=nil);
    procedure Clear;
    function IsEmpty: boolean;
    procedure ParseXML(const Node: TXmlNode);
    function  AddToXML(Root: TXmlNode):TXmlNode;
    property  Key: string read FKey write FKey;
    property  Value: string read FValue write FValue;
end;

type
  TWebSiteType = (tw_None,tw_Home_Page,tw_Blog,tw_Profile,tw_Home,tw_Work,tw_Other,tw_Ftp);
  TcpWebsite = class
  private
    FHref: string;
    FPrimary:boolean;
    Flabel: string;
    FRel: TWebSiteType;
  public
    constructor Create(const ByNode: TXMLNode=nil);
    procedure Clear;
    function IsEmpty:boolean;
    function RelToString: string;
    procedure ParseXML(const Node: TXmlNode);
    function  AddToXML(Root: TXmlNode):TXmlNode;
    property  Href: string read FHref write FHref;
    property  Primary: boolean read FPrimary write FPrimary;
    property  Labl: string read Flabel write Flabel;
    property  Rel: TWebSiteType read FRel write FRel;
end;

type
  TGoogleContact = class;
  TContactGroup = class;
  //тип формируемого файла
  TFileType = (tfAtom, tfXML);
  //тип сортировки конактов
  TSortOrder = (Ts_None, Ts_ascending,Ts_descending);

  TContact = class
  private
    FEtag: string;
    FId: string;
    FUpdated: TDateTime;
    FTitle: TTextTag;
    FContent:TTextTag;
    FLinks:TList<TEntryLink>;
    FName: TgdName;
    FNickName: TcpNickname;
    FBirthDay: TcpBirthday;
    FOrganization: TgdOrganization;
    FEmails: TList<TgdEmail>;
    FPhones: TList<TgdPhoneNumber>;
    FPostalAddreses: TList<TgdStructuredPostalAddress>;
    FEvents : TList<TcpEvent>;
    FRelations: TList<TcpRelation>;
    FUserFields: TList<TcpUserDefinedField>;
    FWebSites: TList<TcpWebsite>;
    FGroupMemberships: TList<TcpGroupMembershipInfo>;
    FIMs:TList<TgdIm>;
    function GetPrimaryEmail: string;
    procedure SetPrimaryEmail(aEmail:string);
    function GetOrganization:TgdOrganization;
    function GetContactName:string;
    function GenerateText(TypeFile:TFileType): string;
  public
    constructor Create(byNode: TXMLNode=nil);
    destructor Destroy; override;
    function IsEmpty: boolean;
    procedure Clear;
    procedure ParseXML(Node: TXMLNode);overload;
    procedure ParseXML(Stream:TStream);overload;
    function FindEmail(const aEmail:string; out Index:integer):TgdEmail;

    procedure SaveToFile(const FileName:string; FileType:TFileType=tfAtom);
    procedure LoadFromFile(const FileName:string);

    property TagTitle: TTextTag read FTitle write FTitle;
    property TagContent:TTextTag read FContent write FContent;
    property TagName: TgdName read FName write FName;
    property TagNickName: TcpNickname read FNickName write FNickName;
    property TagBirthDay: TcpBirthday read FBirthDay write FBirthDay;
    property TagOrganization: TgdOrganization read GetOrganization write FOrganization;

    property Etag: string read FEtag write FEtag;
    property Id: string read FId write FId;
    property Updated: TDateTime read FUpdated write FUpdated;

    property Links:TList<TEntryLink> read FLinks write FLinks;
    property Emails: TList<TgdEmail> read FEmails write FEmails;
    property Phones: TList<TgdPhoneNumber> read FPhones write FPhones;
    property PostalAddreses: TList<TgdStructuredPostalAddress> read FPostalAddreses write FPostalAddreses;
    property Events : TList<TcpEvent> read FEvents write FEvents;
    property Relations: TList<TcpRelation> read FRelations write FRelations;
    property UserFields: TList<TcpUserDefinedField> read FUserFields write FUserFields;
    property WebSites: TList<TcpWebsite> read FWebSites write FWebSites;
    property GroupMemberships: TList<TcpGroupMembershipInfo> read FGroupMemberships write FGroupMemberships;
    property IMs:TList<TgdIm> read FIMs write FIMs;

    property PrimaryEmail:string read GetPrimaryEmail write SetPrimaryEmail;
    property ContactName: string Read GetContactName;
    property ToXMLText[XMLType:TFileType]: string read GenerateText;
end;

//type
  TContactGroup = class
  private
    FEtag: string;
    Fid: string;
    FLinks: TList<TEntryLink>;
    FUpdate: TDateTime;
    FTitle: TTextTag;
    FContent: TTextTag;
    FSystemGroup: TcpSystemGroup;
  public
    constructor Create(const ByNode: TXMLNode);
    procedure ParseXML(Node: TXmlNode);
    function CreateContact(const aContact: TContact):boolean;
    property Etag: string read FEtag write FEtag;
    property id: string read Fid write Fid;
    property Links: TList<TEntryLink> read FLinks write FLinks;
    property Update: TDateTime read FUpdate write FUpdate;
    property Title: TTextTag read FTitle write FTitle;
    property Content: TTextTag read FContent write FContent;
    property SystemGroup: TcpSystemGroup read FSystemGroup write FSystemGroup;
end;

//TGoogleContact
  TGoogleContact = class(TComponent)
  private
    FAuth: string; //AUTH для доступа к API
    FEmail:string; //обязательно GMAIL!
    FTotalBytes: int64;
    FBytesCount: int64;
    FGroups: TList<TContactGroup>;//группы контактов
    FContacts: TList<TContact>;//все контакты
    FOnRetriveXML: TOnRetriveXML;
    FOnBeginParse : TOnBeginParse;
    FOnEndParse : TOnEndParse;
    FOnReadData: TOnReadData;
    FMaximumResults: integer;
    FStartIndex: integer;
    FUpdatesMin: TDateTime;
    FSortOrder: TSortOrder;
    FShowDeleted: boolean;
    function GetNextLink(Stream:TStream):string;overload;
    function GetNextLink(aXMLDoc:TNativeXml):string;overload;
    function GetContactsByGroup(GroupName:string):TList<TContact>;
    function GroupLink(const aGroupName:string):string;
    procedure ParseXMLContacts(const Data: TStream);
    function GetEditLink(aContact:TContact):string;
    function InsertPhotoEtag(aContact: TContact; const Response:TStream):boolean;
    function GetTotalCount(aXMLDoc:TNativeXml):integer;
    procedure ReadData(Sender: TObject; Reason: THookSocketReason; const Value: String);
    function RetriveContactPhoto(index:integer):TJPEGImage;overload;
    function RetriveContactPhoto(aContact:TContact):TJPEGImage;overload;
    procedure SetMaximumResults(const Value: integer);
    procedure SetShowDeleted(const Value: boolean);
    procedure SetSortOrder(const Value: TSortOrder);
    procedure SetStartIndex(const Value: integer);
    procedure SetUpdatesMin(const Value: TDateTime);
    function  ParamsToStr:TStringList;
    function GetContact(GroupName:string;Index:integer):TContact;
    procedure SetAuth(const aAuth:string);
    procedure SetGmail(const aGMail:string);
  public
    constructor Create(AOwner:TComponent);override;
//    constructor Create(AOwner:TComponent; const aAuth,aEmail: string);overload;
    destructor Destroy;override;
    //получение всех групп пользователя
    function RetriveGroups:integer;
    //получение всех контактов пользователя
    function RetriveContacts: integer;overload;

    //удаление контакта
    function DeleteContact(index:integer):boolean;overload;//по индексу в списке FContacts
    function DeleteContact(aContact:TContact):boolean;overload;
    //добавление контакта на сервер
    function AddContact(aContact:TContact):boolean;
    //обновление информации о контакте
    function UpdateContact(aContact:TContact):boolean;overload;
    function UpdateContact(index:integer):boolean;overload;
    //получение фотографии контакта
    function RetriveContactPhoto(aContact:TContact; DefaultImage: TFileName):TJPEGImage; overload;
    function RetriveContactPhoto(index:integer; DefaultImage: TFileName):TJPEGImage; overload;
    //обновление фото контакта
    function UpdatePhoto(index:integer; const PhotoFile: TFileName):boolean;overload;
    function UpdatePhoto(aContact:TContact; const PhotoFile: TFileName):boolean;overload;
    //удаление фотографии контакта
    function DeletePhoto(aContact:TContact):boolean;overload;
    function DeletePhoto(index:integer):boolean;overload;
    //сохранение/загрузка контактов в/из файл/-а
    procedure SaveContactsToFile(const FileName:string);
    procedure LoadContactsFromFile(const FileName:string);

    { ----------------Свойства компонента-------------------------}
    property Auth: string read FAuth write SetAuth;
    property Gmail: string read FEmail write SetGmail;
    //группы контактов
    property Groups: TList<TContactGroup> read FGroups write FGroups;
    //все контакты пользователя
    property Contacts:TList<TContact> read FContacts write FContacts;
    property ContactByGroupIndex[Group:string; I:integer]:TContact read GetContact;
    //контакты, находящиеся в группе GroupName
    property ContactsByGroup[GroupName:string]:TList<TContact> read GetContactsByGroup;
    //максимальное количество записей контактов возвращаемое в одном фиде
    property MaximumResults: integer read FMaximumResults write SetMaximumResults;
    //начальный номер контакта с которого начинать принятие данных
    property StartIndex: integer read FStartIndex write SetStartIndex;
    //нижняя граница обновления контактов
    property UpdatesMin: TDateTime read FUpdatesMin write SetUpdatesMin;
    //определяет будут ли показываться в списке удаленные контакты
    property ShowDeleted: boolean read FShowDeleted write SetShowDeleted;
    //сортировка контактов
    property SortOrder:TSortOrder read FSortOrder write SetSortOrder;
    { ----------------События компонента-------------------------}
    //начало загрузки XML-документа с сервера
    property OnRetriveXML: TOnRetriveXML read FOnRetriveXML write FOnRetriveXML;
    //старт парсинга XML
    property OnBeginParse: TOnBeginParse read FOnBeginParse write FOnBeginParse;
    //окончание парсинга XML
    property OnEndParse: TOnEndParse read FOnEndParse write FOnEndParse;
    property OnReadData: TOnReadData read FOnReadData write FOnReadData;
 end;

//получение типа узла
function GetContactNodeType(const NodeName: UTF8string):TcpTagEnum;inline;
//получение имени узла по его типу
function GetContactNodeName(const NodeType:TcpTagEnum):UTF8string;inline;

implementation

function GetContactNodeName(const NodeType:TcpTagEnum):UTF8string;inline;
begin
    Result:=UTF8String(GetEnumName(TypeInfo(TcpTagEnum),ord(NodeType)));
    Delete(Result,1,3);
    Result:=CpNodeAlias+Result;
end;

function GetContactNodeType(const NodeName: UTF8string):TcpTagEnum;inline;
var i: integer;
begin
  if pos(CpNodeAlias,string(NodeName))>0 then
    begin
      i:=GetEnumValue(TypeInfo(TcpTagEnum),
                      Trim(ReplaceStr(string(NodeName),CpNodeAlias,'cp_')));
      if i>-1 then
        Result := TcpTagEnum(i)
      else
        Result:=cp_None;
    end
  else
    Result:=cp_None;
end;

{ TcpBirthday }

function TcpBirthday.AddToXML(Root: TXMLNode):TXmlNode;
begin
Result:=nil;
if (Root=nil)or IsEmpty then Exit;
Result:=Root.NodeNew(GetContactNodeName(cp_Birthday));
Result.AttributeAdd('when',UTF8String(ServerDate));
end;

procedure TcpBirthday.Clear;
begin
  FDate:=0;
end;

constructor TcpBirthday.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode<>nil then
    ParseXML(byNode);
end;

function TcpBirthday.GetServerDate: string;
begin
Result:='';
if not IsEmpty then
  begin
    if FShortFormat then //укороченный формат даты
      Result:=FormatDateTime('--mm-dd',FDate)
    else
      Result:=FormatDateTime('yyyy-mm-dd',FDate);
  end;
end;

function TcpBirthday.IsEmpty: boolean;
begin
  Result:=FDate<=0;
end;

procedure TcpBirthday.ParseXML(const Node: TXmlNode);
var DateStr: string;
    FormatSet: TFormatSettings;
begin
  if GetContactNodeType(Node.Name) <> cp_Birthday then
      raise Exception.Create
        (Format(sc_ErrCompNodes, [GetContactNodeName(cp_Birthday)]));
  try
    {читаем локальные настройки форматов}
    GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT,FormatSet);
    {чиаем дату}
    DateStr:= string(Node.ReadAttributeString('when'));
    if (Length(Trim(DateStr))>0)then //что-то есть - можно парсить дату
      begin
        //сокращенный формат - только месяц и число рождения
        if (pos('--',DateStr)>0) then
          begin
            FormatSet.DateSeparator:='-';//устанавливаем новый разделиель
            Delete(DateStr,1,2);//срезаем первые два символа
            FormatSet.ShortDateFormat:='mm-dd';
            FDate:=StrToDate(DateStr,FormatSet);
            FShortFormat:=true;
          end
        //полный формат даты
        else
          begin
            FormatSet.DateSeparator:='-';
            FormatSet.ShortDateFormat:='yyyy-mm-dd';
            FDate:=StrToDate(DateStr,FormatSet);
            FShortFormat:=false;
          end;
      end;
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

procedure TcpBirthday.SetDate(aDate: TDate);
begin
   FDate:=aDate;
end;

{ TcpCalendarLink }

function TcpCalendarLink.AddToXML(Root: TXmlNode): TXmlNode;
var tmp:string;
begin
Result:=nil;
  if (Root=nil)or isEmpty then Exit;
  Result:=Root.NodeNew(GetContactNodeName(cp_CalendarLink));
  if FRel<>tc_none then
    begin
      tmp:=ReplaceStr(GetEnumName(TypeInfo(TCalendarRel),ord(FRel)),'_','-');
      Delete(tmp,1,3);
      Result.AttributeAdd(sNodeRelAttr,UTF8String(tmp))
    end
  else
    Result.AttributeAdd(sNodeLabelAttr,UTF8String(FLabel));
  Result.AttributeAdd(sNodeHrefAttr,UTF8String(FHref));
  if FPrimary then
    Result.WriteAttributeBool('primary',FPrimary);
end;

procedure TcpCalendarLink.Clear;
begin
  FLabel:='';
  FRel:=tc_none;
  FHref:='';
end;

constructor TcpCalendarLink.Create(const byNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if byNode<>nil then
    ParseXML(byNode);
 end;

function TcpCalendarLink.isEmpty: boolean;
begin
  Result:=((Length(Trim(FLabel))=0)or (FRel=tc_none))and(Length(Trim(FHref))=0);
end;

procedure TcpCalendarLink.ParseXML(const Node: TXmlNode);
begin
  if GetContactNodeType(Node.Name) <> cp_CalendarLink then
     raise Exception.Create
        (Format(sc_ErrCompNodes, [GetContactNodeName(cp_CalendarLink)]));
  try
    FPrimary:=false;
    FRel:=tc_none;
    if Length(Trim(string(Node.AttributeByName[sNodeRelAttr])))>0 then
       begin //считываем данные о rel
         FRel:=TCalendarRel(GetEnumValue(TypeInfo(TCalendarRel),
         'tc_'+ReplaceStr((Trim(string(Node.AttributeByName[sNodeRelAttr]))),'-','_')))
       end
    else //rel отсутствует, следовательно читаем label
      FLabel:=Trim(string(Node.AttributeByName[sNodeLabelAttr]));
    if Node.HasAttribute('primary') then
      FPrimary:=Node.ReadAttributeBool('primary');
    FHref:=string(Node.ReadAttributeString(sNodeHrefAttr));
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TcpCalendarLink.RelToString: string;
begin
  case FRel of
    tc_none: Result:=FLabel;//описание содержится в label - свободный текст
    tc_work: Result:=LoadStr(c_Work);
    tc_home: Result:=LoadStr(c_Home);
    tc_free_busy: Result:=LoadStr(c_FreeBusy);
  end;
end;

{ TcpEvent }

function TcpEvent.AddToXML(Root: TXmlNode): TXmlNode;
var sRel: string;
begin
Result:=nil;
  if (Root=nil)or IsEmpty then Exit;
  Result:=Root.NodeNew(GetContactNodeName(cp_Event));
  if Ord(FEventType)>-1 then
    begin
      sRel:=GetEnumName(TypeInfo(TEventRel),ord(FEventType));
      Delete(sRel,1,2);
      Result.WriteAttributeString(sNodeRelAttr,UTF8String(sRel));
    end
  else
    begin
      sRel:=GetEnumName(TypeInfo(TEventRel),ord(teOther));
      Delete(sRel,1,2);
      Result.WriteAttributeString(sNodeRelAttr,UTF8String(sRel));
    end;
  if length(Flabel)>0 then
    Result.WriteAttributeString(sNodeLabelAttr,UTF8String(Flabel));
  FWhen.AddToXML(Result,tdDate);
end;

procedure TcpEvent.Clear;
begin
  FEventType:=teNone;
  Flabel:='';
end;

constructor TcpEvent.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  FWhen:=TgdWhen.Create;
  if byNode<>nil then
    ParseXML(byNode);
end;

function TcpEvent.IsEmpty: boolean;
begin
  Result:=(FEventType=teNone)and(Length(Trim(Flabel))=0)and(FWhen.isEmpty)
end;

procedure TcpEvent.ParseXML(const Node: TXMLNode);
var WhenNode: TXmlNode;
    S:String;
begin
  if GetContactNodeType(Node.Name) <> cp_Event then
     raise Exception.Create
           (Format(sc_ErrCompNodes, [GetContactNodeName(cp_Event)]));
  try
    if Node.HasAttribute(sNodeLabelAttr) then
      Flabel:=Trim(string(Node.ReadAttributeString(sNodeLabelAttr)));
    if Node.HasAttribute(sNodeRelAttr) then
      begin
        S:=Trim(string(Node.ReadAttributeString(sNodeRelAttr)));
        S:=StringReplace(S,sSchemaHref,'',[rfIgnoreCase]);
        FEventType:=TEventRel(GetEnumValue(TypeInfo(TEventRel),s));
      end;

    WhenNode:=Node.FindNode(GetGDNodeName(gd_When));
    if WhenNode<>nil then
       FWhen:=TgdWhen.Create(WhenNode)
    else
      Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TcpEvent.RelToString: string;
begin
  case FEventType of
    teNone: Result:=Flabel;
    teAnniversary:Result:=LoadStr(c_EvntAnniv);
    teOther:Result:=LoadStr(c_EvntOther);
  end;
end;

{ TcpExternalId }

function TcpExternalId.AddToXML(Root: TXmlNode): TXmlNode;
var sRel:string;
begin
Result:=nil;
  if (Root=nil)or IsEmpty then Exit;
  if ord(Frel)<0 then
    raise Exception.Create
        (Format(sc_ErrWriteNode, [GetContactNodeName(cp_ExternalId)])+' '+Format(sc_WrongAttr,['rel']));
  Result:=Root.NodeNew(GetContactNodeName(cp_ExternalId));
  if Trim(Flabel)<>'' then
    Result.WriteAttributeString(sNodeLabelAttr,UTF8String(FLabel));
  sRel:=GetEnumName(TypeInfo(TExternalIdType),Ord(FRel));
  Delete(sRel,1,2);
  Result.WriteAttributeString(sNodeRelAttr,UTF8String(sRel));
  Result.WriteAttributeString(sNodeValueAttr,UTF8String(FValue));
end;

procedure TcpExternalId.Clear;
begin
  Frel:=tiNone;
  FLabel:='';
  FValue:='';
end;

constructor TcpExternalId.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TcpExternalId.IsEmpty: boolean;
begin
  Result:=(Frel=tiNone)and(Length(Trim(FLabel))=0)and(Length(Trim(FValue))=0);
end;

procedure TcpExternalId.ParseXML(const Node: TXmlNode);
begin
  if Node=nil then Exit;
  if GetContactNodeType(Node.Name) <> cp_ExternalId then
     raise Exception.Create
          (Format(sc_ErrCompNodes, [GetContactNodeName(cp_ExternalId)]));
  try
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel:=string(Node.ReadAttributeString(sNodeLabelAttr));
    Frel:=TExternalIdType(GetEnumValue(TypeInfo(TExternalIdType),'ti'
          +string(Node.ReadAttributeString(sNodeRelAttr))));
    FValue:=string(Node.ReadAttributeString(sNodeValueAttr));
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TcpExternalId.RelToString: string;
begin
//TExternalIdType = (tiNone,tiAccount,tiCustomer,tiNetwork,tiOrganization);
  case Frel of
    tiNone: Result:=FLabel;//rel не определен - берем описание из label
    tiAccount: Result:=LoadStr(c_AccId);
    tiCustomer: Result:=LoadStr(c_AccCostumer);
    tiNetwork: Result:=LoadStr(c_AccNetwork);
    tiOrganization: Result:=LoadStr(c_AccOrg);
  end;
end;

{ TcpGender }

function TcpGender.AddToXML(Root: TXmlNode): TXmlNode;
begin
Result:=nil;
if (Root=nil)or IsEmpty then Exit;
  if Ord(FValue)<0 then
    raise Exception.Create
        (Format(sc_ErrWriteNode, [GetContactNodeName(cp_Gender)])+' '+Format(sc_WrongAttr,[sNodeValueAttr]));
  Result:=Root.NodeNew(GetContactNodeName(cp_Gender));
  Result.WriteAttributeString(sNodeValueAttr,UTF8String(GetEnumName(TypeInfo(TGenderType),Ord(FValue))));
end;

procedure TcpGender.Clear;
begin
 FValue:=none;
end;

constructor TcpGender.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TcpGender.IsEmpty: boolean;
begin
  Result:=FValue=none;
end;

procedure TcpGender.ParseXML(const Node: TXmlNode);
begin
  if Node=nil then Exit;
  if GetContactNodeType(Node.Name) <> cp_Gender then
     raise Exception.Create
     (Format(sc_ErrCompNodes, [GetContactNodeName(cp_Gender)]));
  try
    FValue:=TGenderType(GetEnumValue(TypeInfo(TGenderType),string(Node.ReadAttributeString('value'))));
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TcpGender.ValueToString: string;
begin
 case FValue of
   none: Result:='';
   male: Result:=LoadStr(c_Male);
   female: Result:=LoadStr(c_Female);
 end;
end;

{ TcpGroupMembershipInfo }

function TcpGroupMembershipInfo.AddToXML(Root: TXmlNode): TXmlNode;
begin
Result:=nil;
 if (Root=nil)or(IsEmpty) then Exit;
 Result:=Root.NodeNew(GetContactNodeName(cp_GroupMembershipInfo));
 Result.WriteAttributeString(sNodeHrefAttr,UTF8String(FHref));
 Result.WriteAttributeBool('deleted',FDeleted);
end;

procedure TcpGroupMembershipInfo.Clear;
begin
  FHref:='';
end;

constructor TcpGroupMembershipInfo.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TcpGroupMembershipInfo.IsEmpty: boolean;
begin
Result:=Length(Trim(FHref))=0
end;

procedure TcpGroupMembershipInfo.ParseXML(const Node: TXmlNode);
begin
 if Node=nil then Exit;
  if GetContactNodeType(Node.Name) <> cp_GroupMembershipInfo then
     raise Exception.Create
          (Format(sc_ErrCompNodes, [GetContactNodeName(cp_GroupMembershipInfo)]));
  try
    FHref:=string(Node.ReadAttributeString(sNodeHrefAttr));
    FDeleted:=Node.ReadAttributeBool('deleted')
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TcpJot }

function TcpJot.AddToXML(Root: TXmlNode): TXmlNode;
var sRel: string;
begin
 Result:=nil;
 if (Root=nil)or IsEmpty then Exit;
 Result:=Root.NodeNew(GetContactNodeName(cp_Jot));
 if FRel<>TjNone then
   begin
     sRel:=GetEnumName(TypeInfo(TJotRel),ord(FRel));
     Delete(sRel,1,2);
     Result.WriteAttributeString(sNodeRelAttr,UTF8String(sRel));
   end;
 Result.ValueAsString:=UTF8String(FText);
end;

procedure TcpJot.Clear;
begin
  FRel:=TjNone;
  FText:='';
end;

constructor TcpJot.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TcpJot.IsEmpty: boolean;
begin
  Result:=(FRel=TjNone)and(Length(Trim(FText))=0);
end;

procedure TcpJot.ParseXML(const Node: TXmlNode);
begin
  if Node=nil then Exit;
  if GetContactNodeType(Node.Name) <> cp_Jot then
     raise Exception.Create
          (Format(sc_ErrCompNodes, [GetContactNodeName(cp_Jot)]));
  try
    FRel:=TJotRel(GetEnumValue(TypeInfo(TJotRel),'Tj'+string(Node.ReadAttributeString('rel'))));
    FText:=string(Node.ValueAsString);
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TcpJot.RelToString: string;
begin
  case FRel of
    TjNone: Result:='';//не определенное значение
    Tjhome: Result:=LoadStr(c_JotHome);
    Tjwork: Result:=LoadStr(c_JotWork);
    Tjother: Result:=LoadStr(c_JotOther);
    Tjkeywords: Result:=LoadStr(c_JotKeywords);
    Tjuser: Result:=LoadStr(c_JotUser);
  end;
end;

{ TcpLanguage }

function TcpLanguage.AddToXML(Root: TXmlNode): TXmlNode;
begin
  Result:=nil;
  if (Root=nil)or IsEmpty then Exit;
    Result:=Root.NodeNew(GetContactNodeName(cp_Language));
  Result.WriteAttributeString('code',UTF8String(Fcode));
  Result.WriteAttributeString(sNodeLabelAttr,UTF8String(Flabel));
end;

procedure TcpLanguage.Clear;
begin
  Fcode:='';
  Flabel:='';
end;

constructor TcpLanguage.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TcpLanguage.IsEmpty: boolean;
begin
  Result:=(Length(Trim(Fcode))=0)and(length(Trim(Flabel))=0);
end;

procedure TcpLanguage.ParseXML(const Node: TXmlNode);
begin
 if Node=nil then Exit;
  if GetContactNodeType(Node.Name) <> cp_Language then
     raise Exception.Create
          (Format(sc_ErrCompNodes, [GetContactNodeName(cp_Language)]));
  try
    Fcode:=string(Node.ReadAttributeString('code'));
    Flabel:=string(Node.ReadAttributeString(sNodeLabelAttr));
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TcpPriority }

function TcpPriority.AddToXML(Root: TXmlNode): TXmlNode;
var sRel: string;
begin
  Result:=nil;
  if (Root=nil)or IsEmpty then Exit;
  Result:=Root.NodeNew(GetContactNodeName(cp_Priority));
  sRel:=GetEnumName(TypeInfo(TPriotityRel),ord(FRel));
  Delete(sRel,1,2);
  Result.WriteAttributeString(sNodeRelAttr,UTF8String(sRel));
end;

procedure TcpPriority.Clear;
begin
 FRel:=tpNone;
end;

constructor TcpPriority.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TcpPriority.IsEmpty: boolean;
begin
  Result:=FRel=TpNone;
end;

procedure TcpPriority.ParseXML(const Node: TXmlNode);
begin
  if Node=nil then Exit;
  if GetContactNodeType(Node.Name) <> cp_Priority then
     raise Exception.Create
     (Format(sc_ErrCompNodes, [GetContactNodeName(cp_Priority)]));
  try
    FRel:=TPriotityRel(GetEnumValue(TypeInfo(TPriotityRel),'Tp'+string(Node.ReadAttributeString('rel'))));
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TcpPriority.RelToString: string;
begin
  case FRel of
    TpNone: Result:='';//значение не определено
    Tplow:  Result:= LoadStr(c_PriorityLow);
    Tpnormal: Result:=LoadStr(c_PriorityNormal);
    Tphigh: Result:=LoadStr(c_PriorityHigh);
  end;
end;

{ TcpRelation }

function TcpRelation.AddToXML(Root: TXmlNode): TXmlNode;
begin
Result:=nil;
if (Root=nil)or IsEmpty then Exit;
Result:=Root.NodeNew(GetContactNodeName(cp_Relation));
if FRealition=tr_None then
  Result.WriteAttributeString(sNodeLabelAttr,UTF8String(FLabel))
else
  Result.WriteAttributeString(sNodeRelAttr,UTF8String(GetRelStr(FRealition)));
Result.ValueAsString:=UTF8String(FValue);
end;

procedure TcpRelation.Clear;
begin
  FValue:='';
  FLabel:='';
  FRealition:=tr_None;
end;

constructor TcpRelation.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TcpRelation.GetRelStr(aRel: TRelationType): string;
begin
  Result:=GetEnumName(TypeInfo(TRelationType),ord(aRel));
  Delete(Result,1,3);
  Result:=StringReplace(Result,'_','-',[rfReplaceAll])
end;

function TcpRelation.IsEmpty: boolean;
begin
  Result:=(Length(Trim(FLabel))=0)and(Length(Trim(FValue))=0)and(FRealition=tr_None);
end;

procedure TcpRelation.ParseXML(const Node: TXmlNode);
var tmp:string;
begin
 if Node=nil then Exit;
  if GetContactNodeType(Node.Name) <> cp_Relation then
     raise Exception.Create
     (Format(sc_ErrCompNodes, [GetContactNodeName(cp_Relation)]));
  try
    if Node.HasAttribute(sNodeRelAttr) then
      begin
        tmp:='tr_'+ReplaceStr(string(Node.ReadAttributeString(sNodeRelAttr)),'-','_');
        FRealition:= TRelationType(GetEnumValue(TypeInfo(TRelationType),
                                   tmp))
      end
    else
      begin
        FLabel:=string(Node.ReadAttributeString(sNodeLabelAttr));
        FRealition:=tr_None;
      end;
    FValue:=string(Node.ValueAsString);
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TcpRelation.RelToString: string;
begin
  case FRealition of
    tr_None: Result:='';//не определено
    tr_assistant: Result:=LoadStr(c_RelationAssistant);
    tr_brother: Result:=LoadStr(c_RelationBrother);
    tr_child: Result:=LoadStr(c_RelationChild);
    tr_domestic_partner: Result:=LoadStr(c_RelationDomestPart);
    tr_father: Result:=LoadStr(c_RelationFather);
    tr_friend: Result:=LoadStr(c_RelationFriend);
    tr_manager: Result:=LoadStr(c_RelationManager);
    tr_mother: Result:=LoadStr(c_RelationMother);
    tr_parent: Result:=LoadStr(c_RelationPartner);
    tr_partner: Result:=LoadStr(c_RelationPartner);
    tr_referred_by: Result:=LoadStr(c_RelationReffered);
    tr_relative: Result:=LoadStr(c_RelationRelative);
    tr_sister: Result:=LoadStr(c_RelationSister);
    tr_spouse: Result:=LoadStr(c_RelationSpouse);
  end;
end;

{ TcpSensitivity }

function TcpSensitivity.AddToXML(Root: TXmlNode): TXmlNode;
var sRel: string;
begin
Result:=nil;
 if (Root=nil)or IsEmpty then Exit;
  if Ord(Frel)<0 then
    raise Exception.Create
    (Format(sc_ErrWriteNode, [GetContactNodeName(cp_Sensitivity)])+' '+Format(sc_WrongAttr,['rel']));
  Result:=Root.NodeNew(GetContactNodeName(cp_Sensitivity));
  sRel:=GetEnumName(TypeInfo(TSensitivityRel),ord(FRel));
  Delete(sRel,1,2);
  Result.WriteAttributeString(sNodeRelAttr,UTF8String(sRel));
end;

procedure TcpSensitivity.Clear;
begin
  FRel:=TsNone;
end;

constructor TcpSensitivity.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TcpSensitivity.IsEmpty: boolean;
begin
  Result:=FRel=TsNone;
end;

procedure TcpSensitivity.ParseXML(const Node: TXmlNode);
begin
if Node=nil then Exit;
  if GetContactNodeType(Node.Name) <> cp_Sensitivity then
     raise Exception.Create
             (Format(sc_ErrCompNodes, [GetContactNodeName(cp_Sensitivity)]));
  try
    FRel:=TSensitivityRel(GetEnumValue(TypeInfo(TSensitivityRel),'Ts'+string(Node.ReadAttributeString('rel'))));
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TcpSensitivity.RelToString: string;
begin
 case FRel of
   TsNone: Result:='';
   Tsconfidential:Result:=LoadStr(c_SensitivConf);
   Tsnormal: Result:=LoadStr(c_SensitivNormal);
   Tspersonal: Result:=LoadStr(c_SensitivPersonal);
   Tsprivate: Result:=LoadStr(c_SensitivPrivate);
 end;
end;

{ TsystemGroup }

function TcpsystemGroup.AddToXML(Root: TXmlNode): TXmlNode;
var tmp:string;
begin
Result:=nil;
 if Root=nil then Exit;
  if FIdRel=tg_None then
    raise Exception.Create
    (Format(sc_ErrWriteNode, [GetContactNodeName(cp_systemGroup)])+' '+Format(sc_WrongAttr,['id']));
Result:=Root.NodeNew(GetContactNodeName(cp_systemGroup));
tmp:=GetEnumName(TypeInfo(TcpSysGroupId),Ord(FidRel));
Delete(tmp,1,3);
Result.WriteAttributeString('id',UTF8String(tmp));
end;

procedure TcpSystemGroup.Clear;
begin
  FIdRel:=tg_None;
end;

constructor TcpsystemGroup.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TcpSystemGroup.IsEmpty: boolean;
begin
  Result:=FIdRel=tg_None;
end;

procedure TcpsystemGroup.ParseXML(const Node: TXmlNode);
begin
  if (Node=nil)or IsEmpty then Exit;
  if GetContactNodeType(Node.Name) <> cp_SystemGroup then
     raise Exception.Create
     (Format(sc_ErrCompNodes, [GetContactNodeName(cp_systemGroup)]));
  try
      FIdRel:=TcpSysGroupId(GetEnumValue(TypeInfo(TcpSysGroupId),'tg_'+string(Node.ReadAttributeString('id'))));
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TcpSystemGroup.RelToString: string;
begin
  case FIdRel of
    tg_None: Result:='';//значение не определено
    tg_Contacts: Result:=LoadStr(c_SysGroupContacts);
    tg_Friends:Result:=LoadStr(c_SysGroupFriends);
    tg_Family:Result:=LoadStr(c_SysGroupFamily);
    tg_Coworkers:Result:=LoadStr(c_SysGroupCoworkers);
  end;
end;

{ TcpUserDefinedField }

function TcpUserDefinedField.AddToXML(Root: TXmlNode): TXmlNode;
begin
Result:=nil;
  if (Root=nil)or IsEmpty then Exit;
  Result:=Root.NodeNew(GetContactNodeName(cp_UserDefinedField));
  Result.WriteAttributeString('key',UTF8String(FKey));
  Result.WriteAttributeString(UTF8String(sNodeValueAttr),UTF8String(FValue));
end;

procedure TcpUserDefinedField.Clear;
begin
  FKey:='';
  FValue:='';
end;

constructor TcpUserDefinedField.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TcpUserDefinedField.IsEmpty: boolean;
begin
 Result:=(Length(Trim(FKey))=0)and(Length(Trim(FValue))=0)
end;

procedure TcpUserDefinedField.ParseXML(const Node: TXmlNode);
begin
  if Node=nil then Exit;
  if GetContactNodeType(Node.Name) <> cp_UserDefinedField then
     raise Exception.Create
     (Format(sc_ErrCompNodes, [GetContactNodeName(cp_UserDefinedField)]));
  try
    FKey:=string(Node.ReadAttributeString('key'));
    FValue:=string(Node.ReadAttributeString(sNodeValueAttr));
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TcpWebsite }

function TcpWebsite.AddToXML(Root: TXmlNode): TXmlNode;
var tmp:string;
begin
Result:=nil;
  if (Root=nil)or IsEmpty then Exit;
  if FRel=tw_None then
    raise Exception.Create
    (Format(sc_ErrWriteNode, [GetContactNodeName(cp_Website)])+' '+Format(sc_WrongAttr,['rel']));
  Result:=Root.NodeNew(GetContactNodeName(cp_Website));
  Result.WriteAttributeString(UTF8String(sNodeHrefAttr),UTF8String(FHref));

  tmp:=GetEnumName(TypeInfo(TWebSiteType),ord(FRel));
  Delete(tmp,1,3);
  tmp:=ReplaceStr(tmp,'_','-');
  Result.WriteAttributeString(UTF8String(sNodeRelAttr),UTF8String(tmp));

  if FPrimary then
    Result.WriteAttributeBool('primary',FPrimary);
  if Trim(Flabel)<>'' then
    Result.WriteAttributeString(UTF8String(sNodeLabelAttr),UTF8String(Flabel));
end;

procedure TcpWebsite.Clear;
begin
  FHref:='';
  Flabel:='';
  FRel:=tw_None;
end;

constructor TcpWebsite.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TcpWebsite.IsEmpty: boolean;
begin
  Result:=(Length(Trim(FHref))=0)and(Length(Trim(Flabel))=0)and(FRel=tw_None)
end;

procedure TcpWebsite.ParseXML(const Node: TXmlNode);
var tmp: string;
begin
  if (Node=nil) then Exit;
  if GetContactNodeType(Node.Name) <> cp_Website then
     raise Exception.Create
     (Format(sc_ErrCompNodes, [GetContactNodeName(cp_Website)]));
  try
    FRel:=tw_None;
    FHref:=string(Node.ReadAttributeString(sNodeHrefAttr));
    tmp:=ReplaceStr(string(Node.ReadAttributeString(sNodeRelAttr)),sSchemaHref,'');
    tmp:='tw_'+ReplaceStr(tmp,'-','_');
    FRel:=TWebSiteType(GetEnumValue(TypeInfo(TWebSiteType),tmp));
    if Node.HasAttribute(sNodeLabelAttr) then
      Flabel:=string(Node.ReadAttributeString(sNodeLabelAttr));
    if Node.HasAttribute('primary') then
      FPrimary:=Node.ReadAttributeBool('primary');
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TcpWebsite.RelToString: string;
begin
  case Frel of
    tw_None:       Result:='';//значение не определено
    tw_Home_Page:  Result:=LoadStr(c_WebsiteHomePage);
    tw_Blog:       Result:=LoadStr(c_WebsiteBlog);
    tw_Profile:    Result:=LoadStr(c_WebsiteProfile);
    tw_Home:       Result:=LoadStr(c_WebsiteHome);
    tw_Work:       Result:=LoadStr(c_WebsiteWork);
    tw_Other:      Result:=LoadStr(c_WebsiteOther);
    tw_Ftp:        Result:=LoadStr(c_WebsiteFtp);
  end;
end;

{ TContact }

procedure TContact.Clear;
begin
 FEtag:='';
 FId:='';
 FUpdated:=0;
 FTitle.Clear;
 FContent.Clear;
 FLinks.Clear;
 FName.Clear;
 FNickName.Clear;
 FBirthDay.Clear;
 FOrganization.Clear;
 FEmails.Clear;
 FPhones.Clear;
 FPostalAddreses.Clear;
 FEvents.Clear;
 FRelations.Clear;
 FUserFields.Clear;
 FWebSites.Clear;
 FGroupMemberships.Clear;
 FIMs.Clear;
end;

constructor TContact.Create(byNode: TXMLNode);
begin
  inherited Create();
  FLinks:=TList<TEntryLink>.Create;
  FEmails:= TList<TgdEmail>.Create;
  FPhones:= TList<TgdPhoneNumber>.Create;
  FPostalAddreses:= TList<TgdStructuredPostalAddress>.Create;
  FEvents := TList<TcpEvent>.Create;
  FRelations:= TList<TcpRelation>.Create;
  FUserFields:= TList<TcpUserDefinedField>.Create;
  FWebSites:= TList<TcpWebsite>.Create;
  FIms:=TList<TgdIm>.Create;
  FGroupMemberships:= TList<TcpGroupMembershipInfo>.Create;
  FOrganization:=TgdOrganization.Create();
  FTitle:=TTextTag.Create();
  FContent:=TTextTag.Create();
  FName:=TgdName.Create();
  FNickName:=TTextTag.Create();
  FBirthDay:=TcpBirthday.Create(nil);
  if byNode<>nil then
    ParseXML(byNode);
end;

destructor TContact.Destroy;
begin
  FreeAndNil(FTitle);
  FreeAndNil(FContent);
  FreeAndNil(FLinks);
  FreeAndNil(FName);
  FreeAndNil(FNickName);
  FreeAndNil(FBirthDay);
  FreeAndNil(FOrganization);
  FreeAndNil(FEmails);
  FreeAndNil(FPhones);
  FreeAndNil(FPostalAddreses);
  FreeAndNil(FEvents);
  FreeAndNil(FRelations);
  FreeAndNil(FUserFields);
  FreeAndNil(FWebSites);
  FreeAndNil(FGroupMemberships);
  FreeAndNil(FIMs);
  inherited Destroy;
end;

function TContact.FindEmail(const aEmail:string; out Index:integer):TgdEmail;
var i:integer;
begin
  Result:=nil;
  for i:=0 to FEmails.Count - 1 do
    begin
      if UpperCase(aEmail)=UpperCase(FEmails[i].Address) then
        begin
          Result:=FEmails[i];
          Index:=i;
          break;
        end;
    end;
end;

function TContact.GenerateText(TypeFile:TFileType): string;
var Doc: TNativeXml;
    I: Integer;
    Node:TXMLNode;
begin
try
 Node:=nil;
 if IsEmpty then Exit;
 Doc:=TNativeXml.Create;
 Doc.EncodingString:=sDefoultEncoding;
 case TypeFile of
   tfAtom:begin
            Doc.CreateName(sAtomAlias+sEntryNodeName);
            Doc.Root.WriteAttributeString('xmlns:atom','http://www.w3.org/2005/Atom');
            Node:=Doc.Root.NodeNew(sAtomAlias+'category');
          end;
   tfXML:begin
           Doc.CreateName(sEntryNodeName);
           Doc.Root.WriteAttributeString('xmlns','http://www.w3.org/2005/Atom');
           Node:=Doc.Root.NodeNew('category');
         end;
 end;
 Doc.Root.WriteAttributeString('xmlns:gd','http://schemas.google.com/g/2005');
 Doc.Root.WriteAttributeString('xmlns:gContact','http://schemas.google.com/contact/2008');
 Node.WriteAttributeString('scheme','http://schemas.google.com/g/2005#kind');
 Node.WriteAttributeString('term','http://schemas.google.com/contact/2008#contact');

 FTitle.AddToXML(Doc.Root);

 for I := 0 to FLinks.Count - 1 do
   FLinks[i].AddToXML(Doc.Root);
 for I := 0 to FEmails.Count - 1 do
   FEmails[i].AddToXML(Doc.Root);
 for I := 0 to FPhones.Count - 1 do
   FPhones[i].AddToXML(Doc.Root);
 for I := 0 to FPostalAddreses.Count - 1 do
   FPostalAddreses[i].AddToXML(Doc.Root);
 for I := 0 to FIMs.Count - 1 do
   FIMs[i].AddToXML(Doc.Root);
 //GContact
 for I := 0 to FEvents.Count - 1 do
   FEvents[i].AddToXML(Doc.Root);
 for I := 0 to FRelations.Count - 1 do
   FRelations[i].AddToXML(Doc.Root);
 for I := 0 to FUserFields.Count - 1 do
   FUserFields[i].AddToXML(Doc.Root);
 for I := 0 to FWebSites.Count - 1 do
   FWebSites[i].AddToXML(Doc.Root);
 for I := 0 to FGroupMemberships.Count - 1 do
   FGroupMemberships[i].AddToXML(Doc.Root);

 FContent.AddToXML(Doc.Root);
 FName.AddToXML(Doc.Root);
 FNickName.AddToXML(Doc.Root);
 FOrganization.AddToXML(Doc.Root);
 FBirthDay.AddToXML(Doc.Root);
 Result:=string(Doc.Root.WriteToString);
finally
  FreeAndNil(Doc)
end;
end;

function TContact.GetContactName: string;
begin
Result:=CpDefaultCName;
if FTitle.IsEmpty then
  if PrimaryEmail<>'' then
    Result:=PrimaryEmail
  else
    Result:=CpDefaultCName
else
  Result:=FTitle.Value
end;

function TContact.GetOrganization: TgdOrganization;
begin
  Result:=TgdOrganization.Create();
  if FOrganization<>nil then
    Result:=FOrganization
  else
    begin
      Result.OrgName:=TTextTag.Create();
      Result.OrgTitle:=TTextTag.Create();
    end;
end;

function TContact.GetPrimaryEmail: string;
var i:integer;
begin
Result:='';
if FEmails=nil then Exit;
if FEmails.Count=0 then Exit;
Result:=FEmails[0].Address;
    for i:=0 to FEmails.Count - 1 do
      begin
        if FEmails[i].Primary then
          begin
            Result:=FEmails[i].Address;
            break;
          end;
      end;
end;

function TContact.IsEmpty: boolean;
begin
Result:=FTitle.IsEmpty and
        FContent.IsEmpty and
        FName.IsEmpty and
        FNickName.IsEmpty and
        FBirthDay.IsEmpty and
        FOrganization.IsEmpty and
        (FEmails.Count=0) and
        (FPhones.Count=0) and
        (FPostalAddreses.Count=0) and
        (FEvents.Count=0) and
        (FRelations.Count=0) and
        (FUserFields.Count=0) and
        (FWebSites.Count=0) and
        (FGroupMemberships.Count=0)and
        (FIMs.Count=0);
end;

procedure TContact.LoadFromFile(const FileName: string);
var XML: TNativeXML;
begin
try
  XML:=TNativeXml.Create;
  XML.LoadFromFile(FileName);
  if (not XML.IsEmpty)and
     ((LowerCase(string(XML.Root.Name))=LowerCase(sAtomAlias+sEntryNodeName))
     or(LowerCase(string(XML.Root.Name))=LowerCase(sEntryNodeName))) then
       ParseXML(XML.Root);
finally
  FreeAndNil(XML)
end;
end;

procedure TContact.ParseXML(Stream: TStream);
var XMLDoc: TNativeXML;
begin
  if Stream=nil then Exit;
  if Stream.Size=0 then Exit;
  XMLDoc:=TNativeXml.Create;
  try
  try
    XMLDoc.LoadFromStream(Stream);
    ParseXML(XMLDoc.Root);
  except
    Exit;
  end;
  finally
    FreeAndNil(XMLDoc)
  end;
end;

procedure TContact.ParseXML(Node: TXMLNode);
var i:integer;
    List: TXmlNodeList;
begin
try
 if Node=nil then Exit;
 FEtag:=string(Node.ReadAttributeString(gdNodeAlias+'etag'));
 List:=TXmlNodeList.Create;
 Node.NodesByName('id',List);
 for I := 0 to List.Count - 1 do
   FId:=string(List.Items[i].ValueAsString);
 //вначале заполняем все списки
 Node.NodesByName(GetGDNodeName(gd_Email),List);
 for i:=0 to List.Count-1 do
   FEmails.Add(TgdEmail.Create(List.Items[i]));
 Node.NodesByName(GetGDNodeName(gd_PhoneNumber),List);
 for i:=0 to List.Count-1 do
    FPhones.Add(TgdPhoneNumber.Create(List.Items[i]));
 Node.NodesByName(GetGDNodeName(gd_Im),List);
 for i:=0 to List.Count-1 do
    FIMs.Add(TgdIM.Create(List.Items[i]));
 Node.NodesByName(GetGDNodeName(gd_StructuredPostalAddress),List);
 for i:=0 to List.Count-1 do
   FPostalAddreses.Add(TgdStructuredPostalAddress.Create(List.Items[i]));
 Node.NodesByName(GetContactNodeName(cp_Event),List);
 for i:=0 to List.Count-1 do
   FEvents.Add(TcpEvent.Create(List.Items[i]));
 Node.NodesByName(GetContactNodeName(cp_Relation),List);
 for i:=0 to List.Count-1 do
   FRelations.Add(TcpRelation.Create(List.Items[i]));
 Node.NodesByName(GetContactNodeName(cp_UserDefinedField),List);
 for i:=0 to List.Count-1 do
   FUserFields.Add(TcpUserDefinedField.Create(List.Items[i]));
 Node.NodesByName(GetContactNodeName(cp_Website),List);
 for i:=0 to List.Count-1 do
   FWebSites.Add(TcpWebsite.Create(List.Items[i]));
 Node.NodesByName(GetContactNodeName(cp_GroupMembershipInfo),List);
 for i:=0 to List.Count-1 do
   FGroupMemberships.Add(TcpGroupMembershipInfo.Create(List.Items[i]));
 Node.NodesByName('link',List);
 for i:=0 to List.Count-1 do
   FLinks.Add(TEntryLink.Create(List.Items[i]));
 for i:=0 to Node.NodeCount - 1 do
   begin
   //CpAtomAlias
     if (LowerCase(string(Node.Nodes[i].Name))='updated')or
        (LowerCase(string(Node.Nodes[i].Name))=LowerCase(sAtomAlias+'updated')) then
         FUpdated:=ServerDateToDateTime(string(Node.Nodes[i].ValueAsString))
     else
       if (LowerCase(string(Node.Nodes[i].Name))='title')or
          (LowerCase(string(Node.Nodes[i].Name))=LowerCase(sAtomAlias+'title')) then
         FTitle:=TTextTag.Create(Node.Nodes[i])
       else
         if (LowerCase(string(Node.Nodes[i].Name))='content')or
            (LowerCase(string(Node.Nodes[i].Name))=LowerCase(sAtomAlias+'content')) then
           FContent:=TTextTag.Create(Node.Nodes[i])
         else
           if LowerCase(string(Node.Nodes[i].Name))=LowerCase(string(GetGDNodeName(gd_Name))) then
             FName:=TgdName.Create(Node.Nodes[i])
           else
             if LowerCase(string(Node.Nodes[i].Name))=LowerCase(string(GetGDNodeName(gd_Organization))) then
               FOrganization:=TgdOrganization.Create(Node.Nodes[i])
             else
                if WideLowerCase(string(Node.Nodes[i].Name))=LowerCase(string(GetContactNodeName(cp_Birthday))) then
                 FBirthDay:=TcpBirthday.Create(Node.Nodes[i])
               else
                   if LowerCase(string(Node.Nodes[i].Name))=LowerCase(string(GetContactNodeName(cp_Nickname))) then
                   FNickName:=TTextTag.Create(Node.Nodes[i]);
   end;
finally
  FreeAndNil(List)
end;
end;

procedure TContact.SaveToFile(const FileName: string; FileType: TFileType);
begin
  TFile.WriteAllText(FileName,GenerateText(FileType));
end;

procedure TContact.SetPrimaryEmail(aEmail: string);
var index,i:integer;
    NewEmail: TgdEmail;
begin
  if FindEmail(aEmail,index)=nil then
    begin
      NewEmail:=TgdEmail.Create();
      NewEmail.Address:=aEmail;
      NewEmail.Primary:=true;
      NewEmail.EmailType:=ttOther;
      FEmails.Add(NewEmail);
    end;
 for i:=0 to FEmails.Count - 1 do
   FEmails[i].Primary:=(i=index);
end;

{ TContactGroup }

constructor TContactGroup.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  FLinks:=TList<TEntryLink>.Create;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

function TContactGroup.CreateContact(const aContact: TContact): boolean;
begin
  Result:=false
end;

procedure TContactGroup.ParseXML(Node: TXmlNode);
var i:integer;
begin
  if Node=nil then Exit;
  FEtag:=string(Node.ReadAttributeString(gdNodeAlias+'etag'));
  for i:=0 to Node.NodeCount-1 do
    begin
      if Node.Nodes[i].Name='id' then
        Fid:=string(Node.Nodes[i].ValueAsString)
      else
        if Node.Nodes[i].Name='updated' then
          FUpdate:=ServerDateToDateTime(string(Node.Nodes[i].ValueAsString))
        else
          if Node.Nodes[i].Name='title' then
            FTitle:=TTextTag.Create(Node.Nodes[i])
          else
            if Node.Nodes[i].Name='content' then
              FContent:=TTextTag.Create(Node.Nodes[i])
            else
              if Node.Nodes[i].Name=GetContactNodeName(cp_SystemGroup) then
                FSystemGroup:=TcpSystemGroup.Create(Node.Nodes[i])
              else
                if Node.Nodes[i].Name='link' then
                  FLinks.Add(TEntryLink.Create(Node.Nodes[i]));
    end;
end;

{ TGoogleContact }

function TGoogleContact.AddContact(aContact: TContact): boolean;
var XML: TNativeXML;
begin
Result:=false;
if (aContact=nil) Or aContact.IsEmpty  then Exit;
try
  XML:=TNativeXml.Create;
  XML.ReadFromString(UTF8String(aContact.ToXMLText[tfAtom]));
  with THTTPSender.Create('POST',FAuth,CpContactsLink,CpProtocolVer)do
    begin
      MimeType := 'application/atom+xml';
      XML.SaveToStream(Document);
      if SendRequest then
        begin
          Result:=(ResultCode=201);
          if Result then
            begin
              XML.Clear;
              XML.LoadFromStream(Document);
              FContacts.Add(TContact.Create(XML.Root))
            end;
        end
      else
        begin
           { TODO -oVlad -cbugs : Корректно обработать исключение }
           ShowMessage(IntToStr(ResultCode)+' '+ResultString)
        end;
    end;
finally
  FreeAndNil(XML)
end;
end;

//constructor TGoogleContact.Create(AOwner:TComponent;const aAuth,aEmail: string);
//begin
////  if Trim(aAuth)='' then
////    raise Exception.Create(rcErrNullAuth);
//  inherited Create(AOwner);
//  FEmail:=aEmail;
//  FAuth:=aAuth;
//
//  FMaximumResults:=-1;
//  FStartIndex:=1;
//  FUpdatesMin:=0;
//  FShowDeleted:=false;
//  FSortOrder:=Ts_None;
//
//  FGroups:=TList<TContactGroup>.Create;
//  FContacts:=TList<TContact>.Create;
//end;

function TGoogleContact.DeleteContact(index: integer): boolean;
begin
try
  Result:=false;
  if (Index<0)or(Index>=FContacts.Count) then Exit;
  Result:=DeleteContact(FContacts[index]);
except
  Result:=false;
end;
end;

constructor TGoogleContact.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMaximumResults:=-1;
  FStartIndex:=1;
  FUpdatesMin:=0;
  FShowDeleted:=false;
  FSortOrder:=Ts_None;

  FGroups:=TList<TContactGroup>.Create;
  FContacts:=TList<TContact>.Create;
end;

function TGoogleContact.DeleteContact(aContact: TContact): boolean;
var i:integer;
begin
try
Result:=false;
if aContact=nil then Exit;

if Length(aContact.Etag)>0 then
 begin
 for I := 0 to aContact.FLinks.Count - 1 do
   begin
     if LowerCase(aContact.FLinks[i].Rel)='edit' then
       begin
          with THTTPSender.Create('DELETE',FAuth,aContact.FLinks[i].Href,CpProtocolVer)do
            begin
              MimeType := 'application/atom+xml';
              ExtendedHeaders.Add('If-Match: '+aContact.Etag);
              if SendRequest then
                begin
                  {TODO -oVlad -cНедочёт : Необходимо обработать возможные исключения}
                end
              else
                begin
                  { TODO -oVlad -cbugs : Корректно обработать исключение }
                  ShowMessage(IntToStr(ResultCode)+' '+ResultString)
                end;
            end;
         break;
       end;
   end;
 end;
  aContact.Destroy;//удалили из памяти

  for I := 0 to FContacts.Count - 1 do
    if FContacts[i]=nil then
      begin
        FContacts.DeleteRange(i,1);//удаляем свободный элемент из списка
        break;
      end;
  Result:=true;
except
  Result:=false;
end;
end;

function TGoogleContact.DeletePhoto(index: integer):boolean;
begin
Result:=false;
  if (index>=FContacts.Count)or(index<0) then Exit;
  Result:=DeletePhoto(FContacts[index])
end;

function TGoogleContact.DeletePhoto(aContact: TContact):boolean;
var i:integer;
begin
Result:=false;
if aContact=nil then Exit;
  for I := 0 to aContact.FLinks.Count - 1 do
    begin
     if (LowerCase(aContact.FLinks[i].Ltype)=sImgRel)and
        (Length(aContact.FLinks[i].Etag)>0)  then
        begin
          with THTTPSender.Create('DELETE',FAuth,aContact.FLinks[i].Href,CpProtocolVer) do
            begin
              MimeType := sImgRel;
              ExtendedHeaders.Add('If-Match: *');
              if SendRequest then
                begin
                  Result:=ResultCode=200;
                  if Result then
                    aContact.FLinks[i].Etag:='';
                 end
              else
                ShowMessage(IntToStr(ResultCode)+' '+ResultString)
            end;
         break;
       end;
   end;
end;

destructor TGoogleContact.Destroy;
var c: TContact;
    g: TContactGroup;
begin
  for g in FGroups do g.Destroy;
  for c in FContacts do c.Destroy;
  FContacts.Free;
  FGroups.Free;
  inherited Destroy;
end;

function TGoogleContact.GetContact(GroupName: string;
  Index: integer): TContact;
var List:TList<TContact>;
begin
  Result:=nil;
try
  List:=TList<TContact>.Create;
  List:=GetContactsByGroup(GroupName);
  if (Index>List.Count)or(Index<0) then Exit;
  Result:=TContact.Create();
  Result:=List[index];
finally
  FreeAndNil(List);
end;
end;

function TGoogleContact.GetContactsByGroup(GroupName: string): TList<TContact>;
var i,j:integer;
    GrupLink:string;
begin
  Result:=TList<TContact>.Create;
  GrupLink:=GroupLink(GroupName);
  if GrupLink<>'' then
    begin
      for i:=0 to FContacts.Count - 1 do
        for j:=0 to FContacts[i].FGroupMemberships.Count-1 do
          begin
            if FContacts[i].FGroupMemberships[j].FHref=GrupLink then
              Result.Add(FContacts[i])
          end;
    end;
end;

function TGoogleContact.GetEditLink(aContact: TContact): string;
var i:integer;
begin
Result:='';
  for i:= 0 to aContact.FLinks.Count - 1 do
    if aContact.FLinks[i].Rel='edit' then
      begin
        Result:=aContact.FLinks[i].Href;
        break;
      end;
end;

function TGoogleContact.GetNextLink(aXMLDoc: TNativeXml): string;
var i:integer;
    List: TXmlNodeList;
begin
try
 if aXMLDoc=nil then Exit;
 Result:='';
 List:=TXmlNodeList.Create;
 aXMLDoc.Root.NodesByName('link',List);
 for i:=0 to List.Count-1 do
   begin
     if List.Items[i].ReadAttributeString(sNodeRelAttr)='next' then
       begin
         Result:=String(List.Items[i].ReadAttributeString(sNodeHrefAttr));
         break;
       end;
   end;
finally
  FreeAndNil(List);
end;
end;

function TGoogleContact.GetTotalCount(aXMLDoc: TNativeXml): integer;
begin
  Result:=-1;
  if aXMLDoc=nil then Exit;
  //ищем вот такой узел <openSearch:totalResults>ЧИСЛО</openSearch:totalResults>
  Result:=aXMLDoc.Root.NodeByName('openSearch:totalResults').ValueAsIntegerDef(-1)
end;

function TGoogleContact.GetNextLink(Stream: TStream): string;
var i:integer;
    List: TXmlNodeList;
    XML: TNativeXml;
begin
try
 if Stream=nil then Exit;
 XML:=TNativeXml.Create;
 XML.LoadFromStream(Stream);
 Result:='';
 List:=TXmlNodeList.Create;
 XML.Root.NodesByName('link',List);
 for i:=0 to List.Count-1 do
   begin
     if List.Items[i].ReadAttributeString(sNodeRelAttr)='next' then
       begin
         Result:=string(List.Items[i].ReadAttributeString(sNodeHrefAttr));
         break;
       end;
   end;
finally
  FreeAndNil(List);
  FreeAndNil(XML);
end;
end;

function TGoogleContact.GroupLink(const aGroupName: string): string;
var i:integer;
begin
  Result:='';
  for i:=0 to FGroups.Count - 1 do
    begin
      if UpperCase(aGroupName)=UpperCase(FGroups[i].FTitle.Value) then
        begin
          Result:=FGroups[i].Fid;
          break
        end;
    end;
end;

function TGoogleContact.InsertPhotoEtag(aContact: TContact;
  const Response: TStream):boolean;
var XML: TNativeXML;
    i:integer;
    etag: string;
begin
Result:=false;
try
  if Response=nil then Exit;
  XML:=TNativeXml.Create;
  try
    XML.LoadFromStream(Response);
  except
    Exit;
  end;
  etag:=string(XML.Root.ReadAttributeString(gdNodeAlias+'etag'));
  for I := 0 to aContact.FLinks.Count - 1 do
    begin
      if aContact.FLinks[i].Ltype=sImgRel then
        begin
          aContact.FLinks[i].Etag:=Etag;
          Result:=true;
          break;
        end;
    end;
finally
  FreeAndNil(XML)
end;
end;

procedure TGoogleContact.LoadContactsFromFile(const FileName: string);
var XML: TStringStream;
begin
  try
    XML:=TStringStream.Create('',TEncoding.UTF8);
    XML.LoadFromFile(FileName);
    ParseXMLContacts(XML);
  finally
    FreeAndNil(XML)
  end;
end;

function TGoogleContact.ParamsToStr: TStringList;
var S:string;
begin
Result:=TStringList.Create;
Result.Delimiter:='&';
  if FMaximumResults>0 then
    Result.Add('max-results='+IntToStr(FMaximumResults));
  if FStartIndex>1 then
    Result.Add('start-index='+IntToStr(FStartIndex));
  if ShowDeleted then
    Result.Add('showdeleted=true');
  if FUpdatesMin>0 then
     Result.Add('updated-min='+DateTimeToServerDate(FUpdatesMin));
  if FSortOrder<>Ts_None then
    begin
      S:=GetEnumName(TypeInfo(TSortOrder),ord(FSortOrder));
      Delete(S,1,3);
      Result.Add('sortorder='+S);
    end;

end;

procedure TGoogleContact.ParseXMLContacts(const Data: TStream);
var XMLDoc: TNativeXML;
    List: TXMLNodeList;
    i:integer;
begin
try
  if (Data=nil) then Exit;
  XMLDoc:=TNativeXml.Create;
  XMLDoc.LoadFromStream(Data);
  List:=TXmlNodeList.Create;
  XMLDoc.Root.NodesByName(sEntryNodeName,List);
  for i:=0 to List.Count - 1 do
    begin
      //Если событие определено - отправляем данные
      if Assigned(FOnBeginParse) then
        OnBeginParse(T_Contact,GetTotalCount(XMLDoc),FContacts.Count+1);
      //парсим элемент контакта
      FContacts.Add(TContact.Create(List.Items[i]));
      //Если событие определено - отправляем данные. В Element кладем TContact
      if Assigned(FOnEndParse) then
        OnEndParse(T_Contact,FContacts.Last)
    end;
finally
  FreeAndNil(List);
  FreeAndNil(XMLDoc);
end;
end;

function TGoogleContact.RetriveContactPhoto(index: integer): TJPEGImage;
begin
  Result:=nil;
  if (index>=FContacts.Count)or(index<0) then Exit;
    Result:=RetriveContactPhoto(FContacts[index])
end;

procedure TGoogleContact.ReadData(Sender: TObject; Reason: THookSocketReason;
  const Value: String);
begin
if Reason=HR_ReadCount then
  begin
    FBytesCount:=FBytesCount+StrToInt(Value);
    if Assigned(FOnReadData) then
     OnReadData(FTotalBytes,FBytesCount)
  end;
end;

function TGoogleContact.RetriveContactPhoto(aContact: TContact): TJPEGImage;
var i:integer;
begin
Result:=nil;
if aContact=nil then Exit;
  for i:=0 to aContact.FLinks.Count - 1 do
    begin
      if (aContact.FLinks[i].Rel=CpPhotoLink)and(Length(aContact.FLinks[i].Etag)>0) then
        begin
           FTotalBytes:=0;
           FBytesCount:=0;
           with THTTPSender.Create('GET',FAuth,aContact.FLinks[i].Href,CpProtocolVer)do
              begin
                Sock.OnStatus:=ReadData;//ставим хук на соккет
                FTotalBytes:=GetLength(aContact.FLinks[i].Href);//получаем размер документа
                if Assigned(FOnRetriveXML) then
                   OnRetriveXML(aContact.FLinks[i].Href);
                MimeType := 'application/atom+xml';
                if SendRequest and (FTotalBytes>0) then
                  begin
                    Result:=TJPEGImage.Create;
                    Result.LoadFromStream(Document);
                  end
                 else
                   begin
                     { TODO -oVlad -cbugs : Корректно обработать исключение }
                   end;
                 break;
               end;
            end;
        end;
end;

function TGoogleContact.RetriveContactPhoto(aContact: TContact;
  DefaultImage: TFileName): TJPEGImage;
var Img: TJPEGImage;
begin
try
  Result:=nil;
  if aContact=nil then Exit;
  if Length(Trim(DefaultImage))=0 then
    raise Exception.Create(sc_ErrFileNull);
  if not FileExists(DefaultImage) then
    raise Exception.Create(Format(sc_ErrFileName,[DefaultImage]));
  Img:=TJPEGImage.Create;
  Result:=TJPEGImage.Create;
  img:=RetriveContactPhoto(aContact);
  if Img=nil then
    Result.LoadFromFile(DefaultImage)
  else
    Result.Assign(img);
finally
  FreeAndNil(Img)
end;
end;

function TGoogleContact.RetriveContacts: integer;
var XMLDoc: TStringStream;
    NextLink: string;
    Params:TStringList;
begin
try
 NextLink:=CPContactsLink;
 Params:=TStringList.Create;
 Params.Assign(ParamsToStr);
 if Params.Count>0 then
    NextLink:=NextLink+'?'+Params.DelimitedText;

 XMLDoc:=TStringStream.Create('',TEncoding.UTF8);
 repeat
   FTotalBytes:=0;
   FBytesCount:=0;

   with THTTPSender.Create('GET',FAuth,NextLink,CpProtocolVer)do
     begin
       Sock.OnStatus:=ReadData;//ставим хук на соккет
       FTotalBytes:=GetLength(NextLink);//получаем размер документа
       //сигналим о начале загрузки
       if Assigned(FOnRetriveXML) then
         OnRetriveXML(NextLink);
       if SendRequest then
         begin
           XMLDoc.LoadFromStream(Document);
           ParseXMLContacts(XMLDoc);
           NextLink:=GetNextLink(XMLDoc);
         end
       else
         begin
           { TODO -oVlad -cbugs : Корректно обработать исключение }
           break;
         end;
     end;
  until NextLink='';
Result:=FContacts.Count;
finally
  FreeAndNil(XMLDoc);
end;

end;

function TGoogleContact.RetriveGroups: integer;
var XMLDoc: TNativeXML;
    List: TXMLNodeLIst;
    i,count:integer;
    NextLink: string;
begin
try
 NextLink:=Format(CpGroupLink,[FEmail]);
 XMLDoc:=TNativeXml.Create;
 repeat
   FTotalBytes:=0;
   FBytesCount:=0;
   with THTTPSender.Create('GET',FAuth,NextLink,CpProtocolVer)do
     begin
       Sock.OnStatus:=ReadData;//ставим хук на соккет
       FTotalBytes:=GetLength(NextLink);//получаем размер документа
       //отправляем сообщение о начале загрузки
       if Assigned(FOnRetriveXML) then
         OnRetriveXML(NextLink);
       if SendRequest then
         begin
           XMLDoc.LoadFromStream(Document);
           List:=TXmlNodeList.Create;
           XMLDoc.Root.NodesByName(sEntryNodeName,List);
           count:=GetTotalCount(XMLDoc);
           for i:=0 to List.Count - 1 do
             begin
               //если событие определено - отправляем данные
               if Assigned(FOnBeginParse) then
                 OnBeginParse(T_Group,count,FGroups.Count+1);
               //парсим группу
               FGroups.Add(TContactGroup.Create(List.Items[i]));
               //если событие определено - отправляем данные
               if Assigned(FOnEndParse) then
                 OnEndParse(T_Group,FGroups.Last);
             end;
           NextLink:=GetNextLink(XMLDoc);
         end
       else
         break; { TODO -oVlad -cbugs : Корректно обработать исключение }
     end;
  until NextLink='';
Result:=FGroups.Count;
finally
  FreeAndNil(XMLDoc);
end;

end;

procedure TGoogleContact.SaveContactsToFile(const FileName: string);
var i:integer;
    Stream:TStringStream;
begin
  try
    Stream:=TStringStream.Create('',TEncoding.UTF8);
    Stream.WriteString('<?xml version="1.0" encoding="UTF-8" ?>');
    Stream.WriteString('<feed ');
    Stream.WriteString('xmlns="http://www.w3.org/2005/Atom" ');
    Stream.WriteString('xmlns:gd="http://schemas.google.com/g/2005" ');
    Stream.WriteString('xmlns:gContact="http://schemas.google.com/contact/2008"');
    Stream.WriteString('>');
    for I := 0 to Contacts.Count - 1 do
       Stream.WriteString(Contacts[i].ToXMLText[tfXML]);
    Stream.WriteString('</feed>');
    Stream.SaveToFile(FileName);
  finally
    FreeAndNil(Stream)
  end;
end;

procedure TGoogleContact.SetAuth(const aAuth: string);
begin
  FAuth:=aAuth;
end;

procedure TGoogleContact.SetGmail(const aGMail: string);
begin
  FEmail:=aGMail;
end;

procedure TGoogleContact.SetMaximumResults(const Value: integer);
begin
  FMaximumResults := Value;
end;

procedure TGoogleContact.SetShowDeleted(const Value: boolean);
begin
  FShowDeleted := Value;
end;

procedure TGoogleContact.SetSortOrder(const Value: TSortOrder);
begin
  FSortOrder := Value;
end;

procedure TGoogleContact.SetStartIndex(const Value: integer);
begin
  FStartIndex := Value;
end;

procedure TGoogleContact.SetUpdatesMin(const Value: TDateTime);
begin
  FUpdatesMin := Value;
end;

function TGoogleContact.UpdateContact(index: integer): boolean;
begin
  Result:=false;
  if (Index>FContacts.Count)Or (FContacts[index].IsEmpty)or(Index<0) then Exit;
  UpdateContact(FContacts[index]);
  Result:=true;
end;

function TGoogleContact.UpdatePhoto(aContact: TContact;
  const PhotoFile: TFileName):boolean;
var
  i: Integer;
begin
Result:=false;
  for i:= 0 to aContact.FLinks.Count - 1 do
    begin
      if aContact.FLinks[i].Ltype=sImgRel then
        begin
           With THTTPSender.Create('PUT',FAuth,aContact.FLinks[i].Href,CpProtocolVer)do
              begin
                ExtendedHeaders.Add('If-Match: *');
                MimeType:=sImgRel;
                Document.LoadFromFile(PhotoFile);
                if SendRequest then
                  Result:=InsertPhotoEtag(aContact, Document)
                else
                  { TODO -oVlad -cbugs : Корректно обработать исключение }
                  ShowMessage(IntToStr(ResultCode)+' '+ResultString);
              end;
          break;
        end;
    end;
end;

function TGoogleContact.UpdatePhoto(index: integer;
  const PhotoFile: TFileName):boolean;
begin
Result:=false;
if (index>=FContacts.Count)or(index<0) then Exit;
  Result:=UpdatePhoto(FContacts[index],PhotoFile);
end;

function TGoogleContact.UpdateContact(aContact: TContact): boolean;
var Doc:TNativeXml;
begin
  Result:=false;
  if (aContact=nil)Or aContact.IsEmpty then Exit;
  if (Length(aContact.Etag)=0)  then Exit;
try
 Doc:=TNativeXml.Create;
 Doc.ReadFromString(UTF8String(aContact.ToXMLText[tfXML]));
 with THTTPSender.Create('PUT',FAuth,GetEditLink(aContact),CpProtocolVer)do
    begin
      ExtendedHeaders.Add('If-Match: *');
      MimeType:='application/atom+xml';
      Doc.SaveToStream(Document);
      if SendRequest then
        begin
          Result:=ResultCode=200;
          if Result then
            begin
              aContact.Clear;
              aContact.ParseXML(Document);
            end;
        end
      else
        ShowMessage(IntToStr(ResultCode)+' '+ResultString)
    end;
finally
  FreeAndNil(Doc)
end;
end;

function TGoogleContact.RetriveContactPhoto(index: integer;
  DefaultImage: TFileName): TJPEGImage;
begin
Result:=nil;
  if (index>=FContacts.Count)or(index<0) then Exit;
  Result:=TJPEGImage.Create;
  Result.Assign(RetriveContactPhoto(FContacts[index],DefaultImage));
end;

{ THTTPSender }

procedure THTTPSender.AddGoogleHeaders;
begin
  Headers.Add('GData-Version: '+FApiVersion);
  Headers.Add('Authorization: GoogleLogin auth=' + FAuthKey);
end;

procedure THTTPSender.Clear;
begin
  inherited Clear;
  FMethod:='';
  FURL:='';
  FAuthKey:='';
  FApiVersion:='';
  FExtendedHeaders.Clear;
end;

constructor THTTPSender.Create(const aMethod, aAuthKey, aURL, aAPIVersion: string);
begin
  inherited Create;
  FAuthKey:=aAuthKey;
  FURL:=aURL;
  FApiVersion:=aAPIVersion;
  FMethod:=aMethod;
  FExtendedHeaders:=TStringList.Create;
end;

function THTTPSender.GetLength(const aURL: string): integer;
var size,content:Ansistring;
    ch:AnsiChar;
    h:TStringList;
begin
  with THTTPSend.Create do
    begin
      Headers.Add('GData-Version: '+FApiVersion);
      Headers.Add('Authorization: GoogleLogin auth=' + FAuthKey);
      if HTTPMethod('HEAD',aURL)and (ResultCode=200) then
        begin
          h:=TStringList.Create;
          h.Assign(Headers);
          content:=AnsiString(HeadByName('content-length',H));
          H.Delete(H.IndexOf(HeadByName('Connection',H)));
          H.Delete(H.IndexOf(string(content)));
          for ch in content do
            if ch in ['0'..'9'] then
               size:=size+ch;
          Result:=StrToIntDef(string(size),0)+Length(BytesOf(H.Text));
        end
      else
       Result:=-1;
    end
end;

function THTTPSender.HeadByName(const aHead: string;aHeaders:TStringList): string;
var str: string;
begin
Result:='';
for str in aHeaders do
   begin
     if pos(LowerCase(aHead),lowercase(str))>0 then
       begin
         Result:=str;
         break;
       end;
   end;
end;

function THTTPSender.SendRequest: boolean;
var str: string;
begin
Result:=false;
  if (Length(Trim(FMethod))=0)or
     (Length(Trim(FURL))=0)or
     (Length(Trim(FAuthKey))=0)or
     (Length(Trim(FApiVersion))=0) then Exit;
  //добавляем необходимые заголовки
  AddGoogleHeaders;
  if FExtendedHeaders.Count>0 then
    for str in FExtendedHeaders do
      Headers.Add(str);
  Result:=HTTPMethod(FMethod,FURL);
end;

procedure THTTPSender.SetApiVersion(const Value: string);
begin
  FApiVersion := Value;
end;

procedure THTTPSender.SetAuthKey(const Value: string);
begin
  FAuthKey := Value;
end;

procedure THTTPSender.SetExtendedHeaders(const Value: TStringList);
begin
  FExtendedHeaders := Value;
end;

procedure THTTPSender.SetMethod(const Value: string);
begin
  FMethod := Value;
end;

procedure THTTPSender.SetURL(const Value: string);
begin
  FURL := Value;
end;



end.
