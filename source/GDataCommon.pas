{ Модуль содержит наиболее общие классы для работы с Google API, а также
  классы и методы для работы с основой всех API - GData API }
unit GDataCommon;

interface

uses
  NativeXML, Classes, StrUtils, SysUtils, typinfo,
  uLanguage, GConsts, Generics.Collections, DateUtils, httpsend;

type
 TXMLNode_ = class helper for TXMLNode
 public
   procedure NodesByName(const AName: string; AList: TList);overload;

end;


type
  { Перечислитель, определяющий узлы которые могут содержаться в XML-документе,
    присланном Google и которые могут быть преобразованы классами модуля.
    Например,
    gd_email - определяет узел gd:email, который может быть преобразован с помощью
    класса TgdEmail }
  TgdEnum = (gd_country, gd_additionalName, gd_name, gd_email,
    gd_extendedProperty, gd_geoPt, gd_im, gd_orgName, gd_orgTitle,
    gd_organization, gd_originalEvent, gd_phoneNumber, gd_postalAddress,
    gd_rating, gd_recurrence, gd_reminder, gd_resourceId, gd_when, gd_agent,
    gd_housename, gd_street, gd_pobox, gd_neighborhood, gd_city, gd_subregion,
    gd_region, gd_postcode, gd_formattedAddress, gd_structuredPostalAddress,
    gd_entryLink, gd_where, gd_familyName, gd_givenName, gd_namePrefix,
    gd_nameSuffix, gd_fullName, gd_orgDepartment, gd_orgJobDescription,
    gd_orgSymbol, gd_famileName, gd_eventStatus, gd_visibility,
    gd_transparency, gd_attendeeType, gd_attendeeStatus, gd_comments,
    gd_deleted, gd_feedLink, gd_who, gd_recurrenceException);

type
  {Перечислитель, определяющие все возможные варианты значений для атрибутов Rel
  XML-узла, определяющего событие}
  TEventRel = (ev_None, ev_attendee, ev_organizer, ev_performer, ev_speaker,
    ev_canceled, ev_confirmed, ev_tentative, ev_confidential, ev_default,
    ev_private, ev_public, ev_opaque, ev_transparent, ev_optional, ev_required,
    ev_accepted, ev_declined, ev_invited);

  { Классы и структуры общего назначения для парсинга XML-документов.
    Применяются в большинстве API Google и, как правило, узлы в XML-дереве не иеют
    каких-либо префиксов }

type
  { Класс для отправки сообщений по HTTP-протоколу. Содержит необходимые поля и методы для работы с
    интерфейсом Google ClientLogin }
  THTTPSender = class(THTTPSend)
  private
    FMethod: string;
    FURL: string;
    FAuthKey: string;
    FApiVersion: string;
    FExtendedHeaders: TStringList;
    procedure SetApiVersion(const Value: string);
    procedure SetAuthKey(const Value: string);
    procedure SetExtendedHeaders(const Value: TStringList);
    procedure SetMethod(const Value: string);
    procedure SetURL(const Value: string);
    function HeadByName(const aHead: string; aHeaders: TStringList): string;
    procedure AddGoogleHeaders;
  public
    { создает новый экземрляр класса.
      * <b>aMethod</b> - метод, используемый в запросе (GET, POST, PUT и т.д.)
      * <b>aAuthKey</b> - ключ для авторизации, который должен быть предварительно получен,
        с использованием комопнента TGoogleLogin или другим способом
      * <b>aURL</b> - адрес на которые будет отправлен запрос
      * <b>aAPIVersion</b> - текущая версия API к которому будет осуществлен запрос }
    constructor Create(const aMethod, aAuthKey, aURL, aAPIVersion: string);
    {Очищает все поля класса, в т.ч. поля Headers и Cookies родителя}
    procedure Clear;
    {Получает точное значение размера документа, который должен быть скачан из Сети
    с адреса <b>aURL</b>. Результат содержит размер документа, включая заголовки}
    function GetLength(const aURL: string): integer;
    {Отправляет запрос на сервер. </b>True</b> - в случае успешной отправки}
    function SendRequest: boolean;
    property Method: string read FMethod write SetMethod;//метод запроса (GET, POST, PUT и т.д.)
    property URL: string read FURL write SetURL;//URL на который отправляется запрос
    property AuthKey: string read FAuthKey write SetAuthKey;//ключ для авторизации на сервере Google
    property ApiVersion: string read FApiVersion write SetApiVersion;//текущая версия API к которому планируется послать запрос
    property ExtendedHeaders: TStringList read FExtendedHeaders write
      SetExtendedHeaders;//дополнительные заголовки запроса. В этот список НЕ включаются заголовки, относящиеся к авторизации (они заполняются автоматически)
  end;

type
  { Атрибут XML-узла }
  TAttribute = packed record
    Name: string;//имя атрибута
    Value: string;//значение арибута
  end;

type
  { Класс общего назначения, определющий любой XML-узел, который
    содержит значение (текст). }
  TTextTag = class
  private
    FName: string; // название узла
    FValue: string; // значение узла
    FAtributes: TList<TAttribute>; // список атрибутов узла
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
     <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    Constructor Create(const ByNode: TXMLNode = nil); overload;
    { Конструктор для создания эземпляра класса по известным значениям имени и текста }
    constructor Create(const NodeName: string; NodeValue: string = '');
      overload;
    { Функция возвращает True в случае, если не определено свойство Name или
      не определено значение узла или хотя бы один атрибут }
    function IsEmpty: boolean;
    { Очищает все поля класса }
    procedure Clear;
    { Разбирает узел XML и заполняет на основании полученных данных поля класса }
    procedure ParseXML(Node: TXMLNode);
    { На основании значений свойст формирует новый XML-узел и помещает его как
      дочерний для узла <b>Root</b> }
    function AddToXML(Root: TXMLNode): TXMLNode;
    { Значение узла }
    property Value: string read FValue write FValue;
    { Название узла }
    property Name: string read FName write FName;
    { Атрибуты узла }
    property Attributes: TList<TAttribute>read FAtributes write FAtributes;
  end;

type
  TEntryLink = class
  private
    Frel: string;
    Ftype: string;
    Fhref: string;
    FEtag: string;
  public
    Constructor Create(const ByNode: TXMLNode = nil);
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
    property Rel: string read Frel write Frel;
    property Ltype: string read Ftype write Ftype;
    property Href: string read Fhref write Fhref;
    property Etag: string read FEtag write FEtag;
  end;

type
  TAuthorTag = Class
  private
    FAuthor: string;
    FEmail: string;
    FUID: string;
  public
    constructor Create(ByNode: TXMLNode = nil);
    procedure ParseXML(Node: TXMLNode);
    property Author: string read FAuthor write FAuthor;
    property Email: string read FEmail write FEmail;
  end;

type
  {Родительский класс для все классов, определющих значения событие (events)}
  TgdEvent = class
  private
    Frel: TEventRel;
  const
    EvSuffix = 'ev_';//префикс для перечислителя <b>TEventRel</b>
    { на входе имеется строка вида
      'http://schemas.google.com/g/2005#event.SSSSSS'
      функция определяет тип события TEventRel }
    function StrToRel(const aRel: string): TEventRel;
    { на входе имеем тип события TEventRel
      на выходе строку вида
      'http://schemas.google.com/g/2005#event.SSSSSS' }
    function RelToStr(aRel: TEventRel): string;
  public
    {Создает пустой экземпляр класса}
    Constructor Create;
    {Очищает поля класса}
    procedure Clear;
    {Проверяет экзумпляр класса на "пустоту". Возвращает <b>false</b>, если
    поле <b>FRel = ev_None</b>}
    function IsEmpty: boolean;
    {перевод значения свойства Rel в тескт на языке разработчика}
    function RelToString: string;
    property Rel: TEventRel read Frel write Frel;//атрибут rel XML-узла
  end;

type
  {Класс, определяющий статус события в календаре. Может принимать следующие значения:
   * <b>ev_canceled</b> - событие отменено
   * <b>ev_confirmed</b> - событие подтверждено и запланировано
   * <b>ev_tentative</b> - событие предварительно запланировано}
  TgdEventStatus = class(TgdEvent)
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
     <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    Constructor Create(const ByNode: TXMLNode = nil);
    { Разбирает узел XML и заполняет на основании полученных данных поля класса }
    procedure ParseXML(Node: TXMLNode);
    { На основании значений свойст формирует новый XML-узел и помещает его как
      дочерний для узла <b>Root</b> }
    function AddToXML(Root: TXMLNode): TXMLNode;
  end;

  {Класс, определяющий видимость события в календаре для других пользователей. Может принимать следующие значения:
   * <b>ev_confidential</b> - видимо только для приглашенных пользователей.
   * <b>ev_default</b> - свойство видимости наследуется из настоек календаря
   * <b>ev_private</b> -	видимо только для создателя
   * <b>ev_public</b> - видимо для всех}
  TgdVisibility = class(TgdEvent)
  public
   {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    Constructor Create(const ByNode: TXMLNode = nil);
    { Разбирает узел XML и заполняет на основании полученных данных поля класса }
    procedure ParseXML(Node: TXMLNode);
    { На основании значений свойств формирует новый XML-узел и помещает его как
      дочерний для узла <b>Root</b> }
    function AddToXML(Root: TXMLNode): TXMLNode;
  end;

type
  TgdTransparency = class(TgdEvent)
  public
    Constructor Create(const ByNode: TXMLNode = nil);
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
  end;

type
  TgdAttendeeType = class(TgdEvent)
  public
    Constructor Create(const ByNode: TXMLNode = nil);
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
  end;

type
  TgdAttendeeStatus = class(TgdEvent)
  public
    Constructor Create(const ByNode: TXMLNode = nil);
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
  end;

type
  TgdCountry = class
  private
    FCode: string;
    FValue: string;
  public
    Constructor Create(const ByNode: TXMLNode = nil);
    procedure Clear;
    function IsEmpty: boolean;
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
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
    function GetFullName: string;
    procedure SetFullName(aFullName: TTextTag);
    procedure SetGivenName(aGivenName: TTextTag);
    procedure SetAdditionalName(aAdditionalName: TTextTag);
    procedure SetFamilyName(aFamilyName: TTextTag);
    procedure SetNamePrefix(aNamePrefix: TTextTag);
    procedure SetNameSuffix(aNameSuffix: TTextTag);
  public
    constructor Create(ByNode: TXMLNode = nil);
    procedure ParseXML(const Node: TXMLNode);
    procedure Clear;
    function IsEmpty: boolean;
    function AddToXML(Root: TXMLNode): TXMLNode;
    property GivenName: TTextTag read FGivenName write SetGivenName;
    property AdditionalName
      : TTextTag read FAdditionalName write SetAdditionalName;
    property FamilyName: TTextTag read FFamilyName write SetFamilyName;
    property NamePrefix: TTextTag read FNamePrefix write SetNamePrefix;
    property NameSuffix: TTextTag read FNameSuffix write SetNameSuffix;
    property FullName: TTextTag read FFullName write SetFullName;
    property FullNameString: string read GetFullName;
  end;

type
  TTypeElement = (em_None, em_home, em_other, em_work);

  TgdEmail = class
  private
    FAddress: string;
    Frel: TTypeElement;
    FLabel: string;
    FPrimary: boolean;
    FDisplayName: string;
  public
    constructor Create(ByNode: TXMLNode = nil);
    procedure Clear;
    function IsEmpty: boolean;
    procedure ParseXML(const Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
    function RelToString: string;
    property Address: string read FAddress write FAddress;
    property Labl: string read FLabel write FLabel;
    property Rel: TTypeElement read Frel write Frel;
    property DisplayName: string read FDisplayName write FDisplayName;
    property Primary: boolean read FPrimary write FPrimary;
  end;

type
  {Класс, описывающие узел GData API <b>gd:extendedProperty</b>, который позволяет хранить ограниченный набор
  пользовательских данных в виде атрибутов узла и дочерних узлов}
  TgdExtendedPropertyStruct = class
   private
     FName: string;
     FValue: string;
     FChildNodes: TList<TTextTag>;
   public
     property Name: string read FName write FName;//атрибут name
     property Value: string read FValue write FValue;//атрибут value
     property ChildNodes: TList<TTextTag> read FChildNodes write FChildNodes;//список дочерних текстовых узлов
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
  TIMProtocol = (ti_None, ti_AIM, ti_MSN, ti_YAHOO, ti_SKYPE, ti_QQ,
    ti_GOOGLE_TALK, ti_ICQ, ti_JABBER);
  TIMtype = (im_None, im_home, im_netmeeting, im_other, im_work);

  TgdIm = class
  private
    FAddress: string;
    FLabel: string;
    FPrimary: boolean;
    FIMProtocol: TIMProtocol;
    FIMType: TIMtype;
  public
    constructor Create(ByNode: TXMLNode = nil);
    procedure ParseXML(const Node: TXMLNode);
    procedure Clear;
    function IsEmpty: boolean;
    function AddToXML(Root: TXMLNode): TXMLNode;
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
    FPrimary: boolean;
    ForgName: TgdOrgName;
    ForgTitle: TgdOrgTitle;
  public
    constructor Create(ByNode: TXMLNode = nil);
    procedure ParseXML(const Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
    function IsEmpty: boolean;
    procedure Clear;
    property Labl: string read FLabel write FLabel;
    property Rel: string Read Frel write Frel;
    property Primary: boolean read FPrimary write FPrimary;
    property OrgName: TgdOrgName read ForgName write ForgName;
    property OrgTitle: TgdOrgTitle read ForgTitle write ForgTitle;
  end;

type
  TgdOriginalEventStruct = record
    id: string;
    Href: string;
  end;

type
  TPhonesRel = (tp_None, tp_Assistant, tp_Callback, tp_Car, Tp_Company_main,
    tp_Fax, tp_Home, tp_Home_fax, tp_Isdn, tp_Main, tp_Mobile, tp_Other,
    tp_Other_fax, tp_Pager, tp_Radio, tp_Telex, tp_Tty_tdd, Tp_Work,
    tp_Work_fax, tp_Work_mobile, tp_Work_pager);

  TgdPhoneNumber = class
  private
    FPrimary: boolean;
    FLabel: string;
    Frel: TPhonesRel;
    FUri: string;
    FValue: string;
  public
    constructor Create(ByNode: TXMLNode = nil);
    function IsEmpty: boolean;
    procedure Clear;
    procedure ParseXML(const Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
    function RelToString: string;
    property Primary: boolean read FPrimary write FPrimary;
    property Labl: string read FLabel write FLabel;
    property Rel: TPhonesRel read Frel write Frel;
    property Uri: string read FUri write FUri;
    property Text: string read FValue write FValue;
  end;

type
  TgdPostalAddressStruct = record
    Labels: string;
    Rel: string;
    Primary: boolean;
    Text: string;
  end;

type
  TgdRatingStruct = record
    Average: extended;
    Max: integer;
    Min: integer;
    numRaters: integer;
    Rel: string;
    Value: integer;
  end;

type
  TgdRecurrence = class
  private
    FText: TStringList;
  public
    Constructor Create(const ByNode: TXMLNode = nil);
    procedure Clear;
    function IsEmpty: boolean;
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
    property Text: TStringList read FText write FText;
  end;

  { TODO -oVlad -cBug : Переделать: добавить "неопределенное значение" в типы. Убрать константы }
const
  cMethods: array [0 .. 2] of string = ('alert', 'email', 'sms');

type
  TMethod = (tmAlert, tmEmail, tmSMS);
  TRemindPeriod = (tpDays, tpHours, tpMinutes);

type
  TgdReminder = class(TPersistent)
  private
    FabsoluteTime: TDateTime;
    FMethod: TMethod;
    FPeriod: TRemindPeriod;
    FPeriodValue: integer;
  public
    Constructor Create(const ByNode: TXMLNode);
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
    property AbsTime: TDateTime read FabsoluteTime write FabsoluteTime;
    property Method: TMethod read FMethod write FMethod;
    property Period: TRemindPeriod read FPeriod write FPeriod;
    property PeriodValue: integer read FPeriodValue write FPeriodValue;
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
    Constructor Create(const ByNode: TXMLNode = nil);
    procedure Clear;
    function IsEmpty: boolean;
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode; DateFormat: TDateFormat): TXMLNode;
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
    Frel: string;
    FMailClass: string;
    FUsage: string;
    FLabel: string;
    FPrimary: boolean;
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
    Constructor Create(const ByNode: TXMLNode = nil);
    procedure Clear;
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
    function IsEmpty: boolean;
    property Rel: string read Frel write Frel;
    property MailClass: string read FMailClass write FMailClass;
    property Usage: string read FUsage write FUsage;
    property Labl: string read FLabel write FLabel;
    property Primary: boolean read FPrimary write FPrimary;
    property Agent: TgdAgent read FAgent write FAgent;
    property HouseName: TgdHousename read FHouseName write FHouseName;
    property Street: TgdStreet read FStreet write FStreet;
    property Pobox: TgdPobox read FPobox write FPobox;
    property Neighborhood
      : TgdNeighborhood read FNeighborhood write FNeighborhood;
    property City: TgdCity read FCity write FCity;
    property Subregion: TgdSubregion read FSubregion write FSubregion;
    property Region: TgdRegion read FRegion write FRegion;
    property Postcode: TgdPostcode read FPostcode write FPostcode;
    property Coutry: TgdCountry read FCountry write FCountry;
    property FormattedAddress: TgdFormattedAddress read FFormattedAddress write
      FFormattedAddress;
  end;

type
  TgdEntryLink = class
  private
    Fhref: string;
    FReadOnly: boolean;
    Frel: string;
    FAtomEntry: TXMLNode;
  public
    Constructor Create(const ByNode: TXMLNode = nil);
    procedure ParseXML(Node: TXMLNode);
    procedure Clear;
    function IsEmpty: boolean;
    function AddToXML(Root: TXMLNode): TXMLNode;
    property Href: string read Fhref write Fhref;
    property OnlyRead: boolean read FReadOnly write FReadOnly;
    property Rel: string read Frel write Frel;
  end;

type
  TgdWhere = class
  private
    FLabel: string;
    Frel: string;
    FvalueString: string;
    FEntryLink: TgdEntryLink;
  public
    Constructor Create(const ByNode: TXMLNode = nil);
    procedure Clear;
    function IsEmpty: boolean;
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
    property Labl: string read FLabel write FLabel;
    property Rel: string read Frel write Frel;
    property valueString: string read FvalueString write FvalueString;
    property EntryLink: TgdEntryLink read FEntryLink write FEntryLink;
  end;

type
  TWhoRel = (tw_None, tw_event_attendee, tw_event_organizer,
    tw_event_performer, tw_event_speaker, tw_message_bcc, tw_message_cc,
    tw_message_from, tw_message_reply_to, tw_message_to);

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
    RelValues: array [0 .. 8] of string = ('event.attendee', 'event.organizer',
      'event.performer', 'event.speaker', 'message.bcc', 'message.cc',
      'message.from', 'message.reply-to', 'message.to');
  public
    Constructor Create(const ByNode: TXMLNode = nil);
    procedure Clear;
    function IsEmpty: boolean;
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
    property Email: string read FEmail write FEmail;
    property RelValue: TWhoRel read FRelValue write FRelValue;
    property valueString: string read FvalueString write FvalueString;
    property AttendeeStatus
      : TgdAttendeeStatus read FAttendeeStatus write FAttendeeStatus;
    property AttendeeType
      : TgdAttendeeType read FAttendeeType write FAttendeeType;
    property EntryLink: TgdEntryLink read FEntryLink write FEntryLink;
  end;

function GetGDNodeType(cName: string): TgdEnum; inline;
function GetGDNodeName(NodeType: TgdEnum): string; inline;
function ServerDateToDateTime(cServerDate: string): TDateTime;
function DateTimeToServerDate(DateTime: TDateTime): string;

implementation

function DateTimeToServerDate(DateTime: TDateTime): string;
var
  Year, Mounth, Day, hours, Mins, Seconds, MSec: Word;
  aYear, aMounth, aDay, ahours, aMins, aSeconds, aMSec: string;
begin
  DecodeDateTime(DateTime, Year, Mounth, Day, hours, Mins, Seconds, MSec);
  aYear := IntToStr(Year);
  if Mounth < 10 then
    aMounth := '0' + IntToStr(Mounth)
  else
    aMounth := IntToStr(Mounth);
  if Day < 10 then
    aDay := '0' + IntToStr(Day)
  else
    aDay := IntToStr(Day);
  if hours < 10 then
    ahours := '0' + IntToStr(hours)
  else
    ahours := IntToStr(hours);
  if Mins < 10 then
    aMins := '0' + IntToStr(Mins)
  else
    aMins := IntToStr(Mins);
  if Seconds < 10 then
    aSeconds := '0' + IntToStr(Seconds)
  else
    aSeconds := IntToStr(Seconds);

  case MSec of
    0 .. 9:
      aMSec := '00' + IntToStr(MSec);
    10 .. 99:
      aMSec := '0' + IntToStr(MSec);
  else
    aMSec := IntToStr(MSec);
  end;
  Result := aYear + '-' + aMounth + '-' + aDay + 'T' + ahours + ':' + aMins +
    ':' + aSeconds + '.' + aMSec + 'Z';
end;

function ServerDateToDateTime(cServerDate: string): TDateTime;
var
  Year, Mounth, Day, hours, Mins, Seconds: Word;
begin
  Year := StrToInt(copy(cServerDate, 1, 4));
  Mounth := StrToInt(copy(cServerDate, 6, 2));
  Day := StrToInt(copy(cServerDate, 9, 2));
  if Length(cServerDate) > 10 then
  begin
    hours := StrToInt(copy(cServerDate, 12, 2));
    Mins := StrToInt(copy(cServerDate, 15, 2));
    Seconds := StrToInt(copy(cServerDate, 18, 2));
  end
  else
  begin
    hours := 0;
    Mins := 0;
    Seconds := 0;
  end;
  Result := EncodeDateTime(Year, Mounth, Day, hours, Mins, Seconds, 0)
end;

function GetGDNodeName(NodeType: TgdEnum): string; inline;
begin
  Result := StringReplace(GetEnumName(TypeInfo(TgdEnum), ord(NodeType)), '_', ':',
      [rfReplaceAll]);
end;

function GetGDNodeType(cName: string): TgdEnum;
begin
  Result := TgdEnum(GetEnumValue(TypeInfo(TgdEnum), ReplaceStr
        (string(cName), ':', '_')));
end;

{ TgdWhere }

function TgdWhere.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  // добавляем узел
  if Root = nil then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_where));
  if Length(FLabel) > 0 then
    Result.WriteAttributeString(UTF8string(sNodeLabelAttr), UTF8string(FLabel));
  if Length(Frel) > 0 then
    Result.WriteAttributeString(UTF8string(sNodeRelAttr), UTF8string(Frel));
  if Length(FvalueString) > 0 then
    Result.WriteAttributeString('valueString', UTF8string(FvalueString));
  if FEntryLink <> nil then
    if (FEntryLink.FAtomEntry <> nil) or (Length(FEntryLink.Fhref) > 0) then
      FEntryLink.AddToXML(Result);
end;

procedure TgdWhere.Clear;
begin
  FLabel := '';
  Frel := '';
  FvalueString := '';
end;

constructor TgdWhere.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode = nil then
    Exit;
  FEntryLink := TgdEntryLink.Create(nil);
  ParseXML(ByNode);
end;

function TgdWhere.IsEmpty: boolean;
begin
  Result := (Length(Trim(FLabel)) = 0) and (Length(Trim(Frel)) = 0) and
    (Length(Trim(FvalueString)) = 0)
end;

procedure TgdWhere.ParseXML(Node: TXMLNode);
begin
  if GetGDNodeType(Node.Name) <> gd_where then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_where)]));
  try
    FLabel := string(Node.ReadAttributeString(sNodeLabelAttr));
    if Length(FLabel) = 0 then
      FLabel := string(Node.ReadAttributeString(sNodeRelAttr));
    FvalueString := string(Node.ReadAttributeString('valueString'));
    if Node.NodeCount > 0 then // есть дочерний узел с EntryLink
    begin
      FEntryLink.ParseXML(Node.FindNode(gdNodeAlias + sEntryNodeName));
    end;
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdEntryLinkStruct }

function TgdEntryLink.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_entryLink));
  if Length(Trim(Fhref)) > 0 then
    Result.WriteAttributeString(sNodeHrefAttr, UTF8string(Fhref));
  if Length(Trim(Frel)) > 0 then
    Result.WriteAttributeString(sNodeRelAttr, UTF8string(Frel));
  Result.WriteAttributeBool('readOnly', FReadOnly);
  if FAtomEntry <> nil then
    Result.NodeAdd(FAtomEntry);
end;

procedure TgdEntryLink.Clear;
begin
  Fhref := '';
  Frel := '';
end;

constructor TgdEntryLink.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

function TgdEntryLink.IsEmpty: boolean;
begin
  Result := (Length(Trim(Fhref)) = 0) and (Length(Trim(Frel)) = 0)
end;

procedure TgdEntryLink.ParseXML(Node: TXMLNode);
begin
  if GetGDNodeType(Node.Name) <> gd_entryLink then
    raise Exception.Create
      (Format(sc_ErrCompNodes, [GetGDNodeName(gd_entryLink)]));
  try
    Fhref := string(Node.ReadAttributeString(sNodeHrefAttr));
    Frel := string(Node.ReadAttributeString(sNodeRelAttr));
    FReadOnly := Node.ReadAttributeBool('readOnly');
    if Node.NodeCount > 0 then // есть дочерний узел с EntryLink
      FAtomEntry := Node.FindNode(sEntryNodeName);
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdEventStatus }

function TgdEventStatus.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_eventStatus));
  Result.WriteAttributeString(sNodeValueAttr, sSchemaHref + UTF8string
      (RelToStr(Frel)));
end;

constructor TgdEventStatus.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgdEventStatus.ParseXML(Node: TXMLNode);
begin
  Frel := ev_None;
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_eventStatus then
    raise Exception.Create
      (Format(sc_ErrCompNodes, [GetGDNodeName(gd_eventStatus)]));
  try
    Frel := StrToRel(string(Node.ReadAttributeString(sNodeValueAttr)));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdWhen }

function TgdWhen.AddToXML(Root: TXMLNode; DateFormat: TDateFormat): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_when));
  case DateFormat of
    tdDate:
      Result.WriteAttributeString('startTime', UTF8string
          (FormatDateTime('yyyy-mm-dd', FstartTime)));
    tdServerDate:
      Result.WriteAttributeString('startTime', UTF8string
          (DateTimeToServerDate(FstartTime)));
  end;

  if FendTime > 0 then
    Result.WriteAttributeString
      ('endTime', UTF8string(DateTimeToServerDate(FendTime)));
  if Length(Trim(FvalueString)) > 0 then
    Result.WriteAttributeString('valueString', UTF8string(FvalueString));
end;

procedure TgdWhen.Clear;
begin
  FendTime := 0;
  FstartTime := 0;
  FvalueString := '';
end;

constructor TgdWhen.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

function TgdWhen.IsEmpty: boolean;
begin
  Result := FstartTime <= 0; // отсутствует обязательное поле
end;

procedure TgdWhen.ParseXML(Node: TXMLNode);
begin
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_when then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_when)]));
  try
    FendTime := 0;
    FstartTime := 0;
    FvalueString := '';
    if Node.HasAttribute('endTime') then
      FendTime := ServerDateToDateTime
        (string(Node.ReadAttributeString('endTime')));
    FstartTime := ServerDateToDateTime
      (string(Node.ReadAttributeString('startTime')));
    if Node.HasAttribute('valueString') then
      FvalueString := string(Node.ReadAttributeString('valueString'));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdAttendeeStatus }

function TgdAttendeeStatus.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_attendeeStatus));
  Result.WriteAttributeString(sNodeValueAttr, sSchemaHref + UTF8string
      (RelToStr(Frel)));
end;

constructor TgdAttendeeStatus.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgdAttendeeStatus.ParseXML(Node: TXMLNode);
begin
  Frel := ev_None;
  if (Node = nil) or IsEmpty then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_attendeeStatus then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName
          (gd_attendeeStatus)]));
  try
    Frel := StrToRel(string(Node.ReadAttributeString(sNodeValueAttr)));
    // TAttendeeStatus(GetEnumValue(TypeInfo(TAttendeeStatus),tmp));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdAttendeeType }

function TgdAttendeeType.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_attendeeType));
  Result.WriteAttributeString(sNodeValueAttr, sSchemaHref + UTF8string
      (RelToStr(Frel)));
end;

constructor TgdAttendeeType.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgdAttendeeType.ParseXML(Node: TXMLNode);
begin
  Frel := ev_None;
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_attendeeType then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName
          (gd_attendeeType)]));
  try
    Frel := StrToRel(string(Node.ReadAttributeString(sNodeValueAttr)));
    // TAttendeeType(GetEnumValue(TypeInfo(TAttendeeType),tmp));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdWho }

function TgdWho.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_who));
  if Length(Trim(FEmail)) > 0 then
    Result.WriteAttributeString('email', UTF8string(FEmail));
  if Length(Trim(Frel)) > 0 then
    Result.WriteAttributeString(sNodeRelAttr, sSchemaHref + UTF8string
        (RelValues[ord(FRelValue)]));
  if Length(Trim(FvalueString)) > 0 then
    Result.WriteAttributeString('valueString', UTF8string(FvalueString));
  FAttendeeStatus.AddToXML(Result);
  FAttendeeType.AddToXML(Result);
  FEntryLink.AddToXML(Result);
end;

procedure TgdWho.Clear;
begin
  FEmail := '';
  Frel := '';
  FvalueString := '';
  FAttendeeStatus.Clear;
  FAttendeeType.Clear;
  FEntryLink.Clear;
end;

constructor TgdWho.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  FAttendeeStatus := TgdAttendeeStatus.Create;
  FAttendeeType := TgdAttendeeType.Create;
  FEntryLink := TgdEntryLink.Create;
  Clear;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

function TgdWho.IsEmpty: boolean;
begin
  Result := (Length(Trim(FEmail)) = 0) and (Length(Trim(Frel)) = 0) and
    (Length(Trim(FvalueString)) = 0) and (FAttendeeStatus.IsEmpty) and
    (FAttendeeType.IsEmpty) and (FEntryLink.IsEmpty)
end;

procedure TgdWho.ParseXML(Node: TXMLNode);
var
  i: integer;
  s: string;
begin
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_who then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_who)]));
  try
    FEmail := string(Node.ReadAttributeString('email'));
    if Length(Node.ReadAttributeString(sNodeRelAttr)) > 0 then
    begin
      s := string(Node.ReadAttributeString(sNodeRelAttr));
      s := StringReplace(s, sSchemaHref, '', [rfIgnoreCase]);
      FRelValue := TWhoRel(AnsiIndexStr(s, RelValues));
    end;
    FvalueString := string(Node.ReadAttributeString('valueString'));
    if Node.NodeCount > 0 then
    begin
      for i := 0 to Node.NodeCount - 1 do
        case GetGDNodeType(Node.Nodes[i].Name) of
          gd_attendeeStatus:
            FAttendeeStatus := TgdAttendeeStatus.Create(Node.Nodes[i]);
          gd_attendeeType:
            FAttendeeType := TgdAttendeeType.Create(Node.Nodes[i]);
          gd_entryLink:
            FEntryLink := TgdEntryLink.Create(Node.Nodes[i]);
        end;
    end;
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdRecurrence }

function TgdRecurrence.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_recurrence));
  Result.ValueAsUnicodeString:=FText.Text;
end;

procedure TgdRecurrence.Clear;
begin
  FText.Clear;
end;

constructor TgdRecurrence.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  FText := TStringList.Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

function TgdRecurrence.IsEmpty: boolean;
begin
  Result := FText.Count = 0
end;

procedure TgdRecurrence.ParseXML(Node: TXMLNode);
begin
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_recurrence then
    raise Exception.Create
      (Format(sc_ErrCompNodes, [GetGDNodeName(gd_recurrence)]));
  try
    FText.Text := string(Node.ValueAsString);
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdReminder }

function TgdReminder.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if Root = nil then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_reminder));
  Result.WriteAttributeString('method', UTF8string(cMethods[ord(FMethod)]));
  case FPeriod of
    tpDays:
      Result.WriteAttributeInteger('days', FPeriodValue);
    tpHours:
      Result.WriteAttributeInteger('hours', FPeriodValue);
    tpMinutes:
      Result.WriteAttributeInteger('minutes', FPeriodValue);
  end;
  if FabsoluteTime > 0 then
    Result.WriteAttributeString('absoluteTime', UTF8string
        (DateTimeToServerDate(FabsoluteTime)))
end;

constructor TgdReminder.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  FabsoluteTime := 0;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgdReminder.ParseXML(Node: TXMLNode);
begin
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_reminder then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_reminder)])
      );
  try
    if Length(Node.ReadAttributeString('absoluteTime')) > 0 then
      FabsoluteTime := ServerDateToDateTime
        (string(Node.ReadAttributeString('absoluteTime')));
    if Length(Node.ReadAttributeString('method')) > 0 then
      FMethod := TMethod(AnsiIndexStr(string(Node.ReadAttributeString('method'))
            , cMethods));
    if Node.AttributeIndexByname('days') >= 0 then
      FPeriod := tpDays;
    if Node.AttributeIndexByname('hours') >= 0 then
      FPeriod := tpHours;
    if Node.AttributeIndexByname('minutes') >= 0 then
      FPeriod := tpMinutes;
    case FPeriod of
      tpDays:
        FPeriodValue := Node.ReadAttributeInteger('days');
      tpHours:
        FPeriodValue := Node.ReadAttributeInteger('hours');
      tpMinutes:
        FPeriodValue := Node.ReadAttributeInteger('minutes');
    end;

  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdTransparency }

function TgdTransparency.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result.WriteAttributeString(sNodeValueAttr, sSchemaHref + UTF8string
      (RelToStr(Frel)));
end;

constructor TgdTransparency.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgdTransparency.ParseXML(Node: TXMLNode);
begin
  Frel := ev_None;
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_transparency then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName
          (gd_transparency)]));
  try
    Frel := StrToRel(string(Node.ReadAttributeString(sNodeValueAttr)));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdVisibility }

function TgdVisibility.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result.WriteAttributeString(sNodeValueAttr, sSchemaHref + UTF8string
      (RelToStr(Frel)));
end;

constructor TgdVisibility.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TgdVisibility.ParseXML(Node: TXMLNode);
begin
  Frel := ev_None;
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_visibility then
    raise Exception.Create
      (Format(sc_ErrCompNodes, [GetGDNodeName(gd_visibility)]));
  try
    Frel := StrToRel(string(Node.ReadAttributeString(sNodeValueAttr)));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdOrganization }

function TgdOrganization.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;

  Result := Root.NodeNew(GetGDNodeName(gd_organization));
  if Trim(Frel) <> '' then
    Result.WriteAttributeString(sNodeRelAttr, UTF8string(Frel));
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString(sNodeLabelAttr, UTF8string(FLabel));
  if FPrimary then
    Result.WriteAttributeBool('primary', FPrimary);
  if Trim(ForgName.Value) <> '' then
    ForgName.AddToXML(Result);
  if Trim(ForgTitle.Value) <> '' then
    ForgTitle.AddToXML(Result);
end;

procedure TgdOrganization.Clear;
begin
  FLabel := '';
  Frel := '';
end;

constructor TgdOrganization.Create(ByNode: TXMLNode);
begin
  inherited Create;
  ForgName := TgdOrgName.Create;
  ForgTitle := TgdOrgTitle.Create;
  Clear;
  if ByNode <> nil then
    ParseXML(ByNode);

end;

function TgdOrganization.IsEmpty: boolean;
begin
  Result := (Length(Trim(FLabel)) = 0) and (Length(Trim(Frel)) = 0) and
    (ForgName.IsEmpty) and (ForgTitle.IsEmpty)
end;

procedure TgdOrganization.ParseXML(const Node: TXMLNode);
var
  i: integer;
begin
  if (Node = nil) or IsEmpty then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_organization then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName
          (gd_organization)]));
  try
    Frel := string(Node.ReadAttributeString(sNodeRelAttr));
    if Node.HasAttribute('primary') then
      FPrimary := Node.ReadAttributeBool('primary');
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel := string(Node.ReadAttributeString(sNodeLabelAttr));
    for i := 0 to Node.NodeCount - 1 do
    begin
      if LowerCase(string(Node.Nodes[i].Name)) = LowerCase
        (string(GetGDNodeName(gd_orgName))) then
        ForgName := TgdOrgName.Create(Node.Nodes[i])
      else if LowerCase(string(Node.Nodes[i].Name)) = LowerCase
        (string(GetGDNodeName(gd_orgTitle))) then
        ForgTitle := TgdOrgTitle.Create(Node.Nodes[i]);
    end;
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdEmailStruct }

function TgdEmail.AddToXML(Root: TXMLNode): TXMLNode;
var
  tmp: string;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_email));
  if Frel <> em_None then
  begin
    tmp := GetEnumName(TypeInfo(TTypeElement), ord(Frel));
    Delete(tmp, 1, 3);
    Result.WriteAttributeString(sNodeRelAttr, sSchemaHref + UTF8string(tmp));
  end;
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString(sNodeLabelAttr, UTF8string(FLabel));
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString('displayName', UTF8string(FDisplayName));
  if FPrimary then
    Result.WriteAttributeBool('primary', FPrimary);
  Result.WriteAttributeString('address', UTF8string(FAddress));
end;

procedure TgdEmail.Clear;
begin
  FAddress := '';
  FLabel := '';
  Frel := em_None;
  FDisplayName := '';
end;

constructor TgdEmail.Create(ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode <> nil then
    ParseXML(ByNode);
end;

function TgdEmail.IsEmpty: boolean;
begin
  Result := Length(Trim(FAddress)) = 0; // отсутствует обязательное поле
end;

procedure TgdEmail.ParseXML(const Node: TXMLNode);
var
  tmp: string;
begin
  Frel := em_None;
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_email then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_email)]));
  try
    tmp := 'em_' + ReplaceStr(string(Node.ReadAttributeString(sNodeRelAttr)),
      sSchemaHref, '');
    Frel := TTypeElement(GetEnumValue(TypeInfo(TTypeElement), tmp));
    if Node.HasAttribute('primary') then
      FPrimary := Node.ReadAttributeBool('primary');
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel := string(Node.ReadAttributeString(sNodeLabelAttr));
    if Node.HasAttribute('displayName') then
      FDisplayName := string(Node.ReadAttributeString('displayName'));
    FAddress := string(Node.ReadAttributeString('address'));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TgdEmail.RelToString: string;
begin
  case Frel of
    em_None:
      Result := ''; // значение не определено
    em_home:
      Result := LoadStr(c_EmailHome);
    em_other:
      Result := LoadStr(c_EmailOther);
    em_work:
      Result := LoadStr(c_EmailWork);
  end;
end;

{ TgdNameStruct }

function TgdName.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;

  Result := Root.NodeNew(GetGDNodeName(gd_name));
  if (AdditionalName <> nil) and (not AdditionalName.IsEmpty) then
    AdditionalName.AddToXML(Result);

  if (GivenName <> nil) and (not GivenName.IsEmpty) then
    GivenName.AddToXML(Result);
  if (FamilyName <> nil) and (not FamilyName.IsEmpty) then
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
  FGivenName := TgdGivenName.Create(string(GetGDNodeName(gd_givenName)));
  FAdditionalName := TgdAdditionalName.Create
    (string(GetGDNodeName(gd_additionalName)));
  FFamilyName := TgdFamilyName.Create(string(GetGDNodeName(gd_familyName)));
  FNamePrefix := TgdNamePrefix.Create(string(GetGDNodeName(gd_namePrefix)));
  FNameSuffix := TgdNameSuffix.Create(string(GetGDNodeName(gd_nameSuffix)));
  FFullName := TgdFullName.Create(string(GetGDNodeName(gd_fullName)));
  if ByNode <> nil then
    ParseXML(ByNode);
end;

function TgdName.GetFullName: string;
begin
  if FFullName <> nil then
    Result := FFullName.Value;
end;

function TgdName.IsEmpty: boolean;
begin
  Result :=
    FGivenName.IsEmpty and FAdditionalName.IsEmpty and FFamilyName.IsEmpty and
    FNamePrefix.IsEmpty and FNameSuffix.IsEmpty and FFullName.IsEmpty;
end;

procedure TgdName.ParseXML(const Node: TXMLNode);
var
  i: integer;
begin
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_name then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_name)]));
  try
    for i := 0 to Node.NodeCount - 1 do
    begin
      case GetGDNodeType(Node.Nodes[i].Name) of
        gd_givenName:
          FGivenName.ParseXML(Node.Nodes[i]);
        gd_additionalName:
          FAdditionalName.ParseXML(Node.Nodes[i]);
        gd_familyName:
          FFamilyName.ParseXML(Node.Nodes[i]);
        gd_namePrefix:
          FNamePrefix.ParseXML(Node.Nodes[i]);
        gd_nameSuffix:
          FNameSuffix.ParseXML(Node.Nodes[i]);
        gd_fullName:
          FFullName.ParseXML(Node.Nodes[i]);
      end;
    end;
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

procedure TgdName.SetAdditionalName(aAdditionalName: TTextTag);
begin
  if aAdditionalName = nil then
    Exit;
  if Length(FAdditionalName.Name) = 0 then
    FAdditionalName.Name := string(GetGDNodeName(gd_additionalName));
  FAdditionalName.Value := aAdditionalName.Value;
end;

procedure TgdName.SetFamilyName(aFamilyName: TTextTag);
begin
  if aFamilyName = nil then
    Exit;
  if Length(FFamilyName.Name) = 0 then
    FFamilyName.Name := string(GetGDNodeName(gd_familyName));
  FFamilyName.Value := aFamilyName.Value;
end;

procedure TgdName.SetFullName(aFullName: TTextTag);
begin
  if aFullName = nil then
    Exit;
  if Length(FFullName.Name) = 0 then
    FFullName.Name := string(GetGDNodeName(gd_fullName));
  FFullName.Value := aFullName.Value;
end;

procedure TgdName.SetGivenName(aGivenName: TTextTag);
begin
  if aGivenName = nil then
    Exit;
  if Length(FGivenName.Name) = 0 then
    FGivenName.Name := string(GetGDNodeName(gd_givenName));
  FFullName.Value := aGivenName.Value;
end;

procedure TgdName.SetNamePrefix(aNamePrefix: TTextTag);
begin
  if aNamePrefix = nil then
    Exit;
  if Length(FNamePrefix.Name) = 0 then
    FNamePrefix.Name := string(GetGDNodeName(gd_namePrefix));
  FNamePrefix.Value := aNamePrefix.Value;
end;

procedure TgdName.SetNameSuffix(aNameSuffix: TTextTag);
begin
  if aNameSuffix = nil then
    Exit;
  if Length(FNameSuffix.Name) = 0 then
    FNameSuffix.Name := string(GetGDNodeName(gd_nameSuffix));
  FNameSuffix.Value := aNameSuffix.Value;
end;

{ TgdPhoneNumber }

function TgdPhoneNumber.AddToXML(Root: TXMLNode): TXMLNode;
var
  tmp: string;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_phoneNumber));

  if Frel <> tp_None then
  begin
    tmp := GetEnumName(TypeInfo(TPhonesRel), ord(Frel));
    Delete(tmp, 1, 3);
    Result.WriteAttributeString(sNodeRelAttr, sSchemaHref + UTF8string(tmp));
  end;

  Result.ValueAsString := FValue;
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString(sNodeLabelAttr, UTF8string(FLabel));
  if Trim(FUri) <> '' then
    Result.WriteAttributeString('uri', UTF8string(FUri));
  if FPrimary then
    Result.WriteAttributeBool('primary', FPrimary);
end;

procedure TgdPhoneNumber.Clear;
begin
  FLabel := '';
  FUri := '';
  FValue := '';
end;

constructor TgdPhoneNumber.Create(ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode <> nil then
    ParseXML(ByNode);
end;

function TgdPhoneNumber.IsEmpty: boolean;
begin
  Result := (Length(Trim(FLabel)) = 0) and (Length(Trim(FUri)) = 0) and
    (Length(Trim(FValue)) = 0)
end;

procedure TgdPhoneNumber.ParseXML(const Node: TXMLNode);
var
  tmp: string;
begin
  Frel := tp_None;
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_phoneNumber then
    raise Exception.Create
      (Format(sc_ErrCompNodes, [GetGDNodeName(gd_phoneNumber)]));
  try
    tmp := 'tp_' + ReplaceStr(string(Node.ReadAttributeString(sNodeRelAttr)),
      sSchemaHref, '');
    if Length(tmp) > 3 then
      Frel := TPhonesRel(GetEnumValue(TypeInfo(TPhonesRel), tmp));
    if Node.HasAttribute('primary') then
      FPrimary := Node.ReadAttributeBool('primary');
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel := string(Node.ReadAttributeString(sNodeLabelAttr));
    if Node.HasAttribute('uri') then
      FUri := string(Node.ReadAttributeString('uri'));
    FValue := string(Node.ValueAsString);
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

function TgdPhoneNumber.RelToString: string;
begin
  case Frel of
    tp_None:
      Result := '';
    tp_Assistant:
      Result := LoadStr(c_PhoneAssistant);
    tp_Callback:
      Result := LoadStr(c_PhoneCallback);
    tp_Car:
      Result := LoadStr(c_PhoneCar);
    Tp_Company_main:
      Result := LoadStr(c_PhoneCompanymain);
    tp_Fax:
      Result := LoadStr(c_PhoneFax);
    tp_Home:
      Result := LoadStr(c_PhoneHome);
    tp_Home_fax:
      Result := LoadStr(c_PhoneHomefax);
    tp_Isdn:
      Result := LoadStr(c_PhoneIsdn);
    tp_Main:
      Result := LoadStr(c_PhoneMain);
    tp_Mobile:
      Result := LoadStr(c_PhoneMobile);
    tp_Other:
      Result := LoadStr(c_PhoneOther);
    tp_Other_fax:
      Result := LoadStr(c_PhoneOtherfax);
    tp_Pager:
      Result := LoadStr(c_PhonePager);
    tp_Radio:
      Result := LoadStr(c_PhoneRadio);
    tp_Telex:
      Result := LoadStr(c_PhoneTelex);
    tp_Tty_tdd:
      Result := LoadStr(c_PhoneTtytdd);
    Tp_Work:
      Result := LoadStr(c_PhoneWork);
    tp_Work_fax:
      Result := LoadStr(c_PhoneWorkfax);
    tp_Work_mobile:
      Result := LoadStr(c_PhoneWorkmobile);
    tp_Work_pager:
      Result := LoadStr(c_PhoneWorkpager);
  end;
end;

{ TgdCountry }

function TgdCountry.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_country));
  if Trim(FCode) <> '' then
    Result.WriteAttributeString('code', UTF8string(FCode));
  Result.ValueAsString := FValue;
end;

procedure TgdCountry.Clear;
begin
  FCode := '';
  FValue := '';
end;

constructor TgdCountry.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode <> nil then
    ParseXML(ByNode);
end;

function TgdCountry.IsEmpty: boolean;
begin
  Result := (Length(Trim(FCode)) = 0) and (Length(Trim(FValue)) = 0);
end;

procedure TgdCountry.ParseXML(Node: TXMLNode);
begin
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_country then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_country)])
      );
  try
    FCode := string(Node.ReadAttributeString(sNodeRelAttr));
    FValue := string(Node.ValueAsString);
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdStructuredPostalAddressStruct }

function TgdStructuredPostalAddress.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_structuredPostalAddress));
  if Trim(Frel) <> '' then
    Result.WriteAttributeString(sNodeRelAttr, UTF8string(Frel));
  if Trim(FMailClass) <> '' then
    Result.WriteAttributeString('mailClass', UTF8string(FMailClass));
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString(sNodeLabelAttr, UTF8string(FLabel));
  if Trim(FUsage) <> '' then
    Result.WriteAttributeString('Usage', UTF8string(FUsage));
  if FPrimary then
    Result.WriteAttributeBool('primary', FPrimary);
  if FAgent <> nil then
    FAgent.AddToXML(Result);
  if FHouseName <> nil then
    FHouseName.AddToXML(Result);
  if FStreet <> nil then
    FStreet.AddToXML(Result);
  if FPobox <> nil then
    FPobox.AddToXML(Result);
  if FNeighborhood <> nil then
    FNeighborhood.AddToXML(Result);
  if FCity <> nil then
    FCity.AddToXML(Result);
  if FSubregion <> nil then
    FSubregion.AddToXML(Result);
  if FRegion <> nil then
    FRegion.AddToXML(Result);
  if FPostcode <> nil then
    FPostcode.AddToXML(Result);
  if FCountry <> nil then
    FCountry.AddToXML(Result);
  if FFormattedAddress <> nil then
    FFormattedAddress.AddToXML(Result);
end;

procedure TgdStructuredPostalAddress.Clear;
begin
  Frel := '';
  FMailClass := '';
  FUsage := '';
  FLabel := '';
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
  FAgent := TgdAgent.Create;
  FHouseName := TgdHousename.Create;
  FStreet := TgdStreet.Create;
  FPobox := TgdPobox.Create;
  FNeighborhood := TgdNeighborhood.Create;
  FCity := TgdCity.Create;
  FSubregion := TgdSubregion.Create;
  FRegion := TgdRegion.Create;
  FPostcode := TgdPostcode.Create;
  FCountry := TgdCountry.Create;
  FFormattedAddress := TgdFormattedAddress.Create;

  Clear;
  if ByNode <> nil then
    ParseXML(ByNode);
end;

function TgdStructuredPostalAddress.IsEmpty: boolean;
begin
  Result := (Length(Trim(Frel)) = 0) and (Length(Trim(FMailClass)) = 0) and
    (Length(Trim(FUsage)) = 0) and (Length(Trim(FLabel)) = 0)
    and FAgent.IsEmpty and FHouseName.IsEmpty and FStreet.IsEmpty and FPobox.
    IsEmpty and FNeighborhood.IsEmpty and FCity.IsEmpty and FSubregion.IsEmpty
    and FRegion.IsEmpty and FPostcode.IsEmpty and FCountry.IsEmpty and
    FFormattedAddress.IsEmpty;
end;

procedure TgdStructuredPostalAddress.ParseXML(Node: TXMLNode);
var
  i: integer;
begin
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_structuredPostalAddress then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName
          (gd_structuredPostalAddress)]));
  try
    Frel := string(Node.ReadAttributeString(sNodeRelAttr));
    FMailClass := string(Node.ReadAttributeString('mailClass'));
    FLabel := string(Node.ReadAttributeString(sNodeLabelAttr));
    if Node.HasAttribute('primaty') then
      FPrimary := Node.ReadAttributeBool('primary');
    FUsage := String(Node.ReadAttributeString('Usage'));
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
  for i := 0 to Node.NodeCount - 1 do
  begin
    case GetGDNodeType(Node.Nodes[i].Name) of
      gd_agent:
        FAgent.ParseXML(Node.Nodes[i]);
      gd_housename:
        FHouseName.ParseXML(Node.Nodes[i]);
      gd_street:
        FStreet.ParseXML(Node.Nodes[i]);
      gd_pobox:
        FPobox.ParseXML(Node.Nodes[i]);
      gd_neighborhood:
        FNeighborhood.ParseXML(Node.Nodes[i]);
      gd_city:
        FCity.ParseXML(Node.Nodes[i]);
      gd_subregion:
        FSubregion.ParseXML(Node.Nodes[i]);
      gd_region:
        FRegion.ParseXML(Node.Nodes[i]);
      gd_postcode:
        FPostcode.ParseXML(Node.Nodes[i]);
      gd_country:
        FCountry.ParseXML(Node.Nodes[i]);
      gd_formattedAddress:
        FFormattedAddress.ParseXML(Node.Nodes[i]);
    end;
  end;
end;

{ TgdIm }

function TgdIm.AddToXML(Root: TXMLNode): TXMLNode;
var
  tmp: string;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_im));
  tmp := GetEnumName(TypeInfo(TIMtype), ord(FIMType));
  Delete(tmp, 1, 3);
  Result.WriteAttributeString(sNodeRelAttr, sSchemaHref + UTF8string(tmp));
  Result.WriteAttributeString('address', UTF8string(FAddress));
  Result.WriteAttributeString(sNodeLabelAttr, UTF8string(FLabel));

  tmp := GetEnumName(TypeInfo(TIMProtocol), ord(FIMProtocol));
  Delete(tmp, 1, 3);
  Result.WriteAttributeString('protocol', sSchemaHref + UTF8string(tmp));

  if FPrimary then
    Result.WriteAttributeBool('primary', FPrimary);
end;

procedure TgdIm.Clear;
begin
  FAddress := '';
  FLabel := '';
end;

constructor TgdIm.Create(ByNode: TXMLNode);
begin
  inherited Create;
  Clear;
  if ByNode <> nil then
    ParseXML(ByNode);
end;

function TgdIm.ImProtocolToString: string;
begin
  Result := GetEnumName(TypeInfo(TIMProtocol), ord(FIMProtocol));
  Delete(Result, 1, 3);
end;

function TgdIm.ImTypeToString: string;
begin
  case FIMType of
    im_None:
      Result := ''; // значение не определено
    im_home:
      Result := LoadStr(c_ImHome);
    im_netmeeting:
      Result := LoadStr(c_ImNetMeeting);
    im_other:
      Result := LoadStr(c_ImOther);
    im_work:
      Result := LoadStr(c_ImWork);
  end;
end;

function TgdIm.IsEmpty: boolean;
begin
  Result := (Length(Trim(FAddress)) = 0); // отсутствует обязательное поле
end;

procedure TgdIm.ParseXML(const Node: TXMLNode);
var
  tmp: string;
begin
  FIMProtocol := ti_None;
  FIMType := im_None;
  if Node = nil then
    Exit;
  if GetGDNodeType(Node.Name) <> gd_im then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_im)]));
  try
    tmp := 'im_' + ReplaceStr(string(Node.ReadAttributeString(sNodeRelAttr)),
      sSchemaHref, '');
    FIMType := TIMtype(GetEnumValue(TypeInfo(TIMtype), tmp));

    FLabel := string(Node.ReadAttributeString(sNodeLabelAttr));
    FAddress := string(Node.ReadAttributeString('address'));

    tmp := 'ti_' + ReplaceStr(string(Node.ReadAttributeString('protocol')),
      sSchemaHref, '');
    FIMProtocol := TIMProtocol(GetEnumValue(TypeInfo(TIMProtocol), tmp));

    if Node.HasAttribute('primary') then
      FPrimary := Node.ReadAttributeBool('primary');
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdEvent }

procedure TgdEvent.Clear;
begin
  Frel := ev_None;
end;

constructor TgdEvent.Create;
begin
  inherited Create;
end;

function TgdEvent.IsEmpty: boolean;
begin
  Result := Frel = ev_None;
end;

function TgdEvent.RelToStr(aRel: TEventRel): string;
begin
  Result := sSchemaHref + sEventRelSuffix +
  ReplaceStr(GetEnumName(TypeInfo(TEventRel), ord(aRel)),
  EvSuffix, '');;
end;

function TgdEvent.RelToString: string;
begin
  case Frel of
    ev_attendee:
      ;
    ev_organizer:
      ;
    ev_performer:
      ;
    ev_speaker:
      ;
    ev_canceled:
      Result := LoadStr(c_EventCancel);
    ev_confirmed:
      Result := LoadStr(c_EventConfirm);
    ev_tentative:
      Result := LoadStr(c_EventTentative);
    ev_confidential:
      Result := LoadStr(c_EventConfident);
    ev_default:
      Result := LoadStr(c_EventDefault);
    ev_private:
      Result := LoadStr(c_EventPrivate);
    ev_public:
      Result := LoadStr(c_EventPublic);
    ev_opaque:
      Result := LoadStr(c_EventOpaque);
    ev_transparent:
      Result := LoadStr(c_EventTransp);
    ev_optional:
      Result := LoadStr(c_EventOptional);
    ev_required:
      Result := LoadStr(c_EventRequired);
    ev_accepted:
      Result := LoadStr(c_EventAccepted);
    ev_declined:
      Result := LoadStr(c_EventDeclined);
    ev_invited:
      Result := LoadStr(c_EventInvited);
  else
    Result := '';
  end;
end;

function TgdEvent.StrToRel(const aRel: string): TEventRel;
var
  tmp: string;
begin
  tmp := EvSuffix + ReplaceStr(aRel, sSchemaHref + sEventRelSuffix, '');
  Result := TEventRel(GetEnumValue(TypeInfo(TEventRel), tmp));
end;

{ TTextTag }

function TTextTag.AddToXML(Root: TXMLNode): TXMLNode;
var
  i: integer;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(UTF8string(FName));
  Result.ValueAsString := FValue;
  for i := 0 to FAtributes.Count - 1 do
    Result.AttributeAdd(UTF8string(FAtributes[i].Name), UTF8string
        (FAtributes[i].Value));
end;

constructor TTextTag.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  FAtributes := TList<TAttribute>.Create;
  Clear;
  if ByNode <> nil then
    ParseXML(ByNode);
end;

procedure TTextTag.Clear;
begin
  FName := '';
  FValue := '';
  FAtributes.Clear;
end;

constructor TTextTag.Create(const NodeName: string; NodeValue: string);
begin
  inherited Create;
  FName := NodeName;
  FValue := NodeValue;
  FAtributes := TList<TAttribute>.Create;
end;

function TTextTag.IsEmpty: boolean;
begin
  Result := (Length(Trim(FName)) = 0) or ((Length(Trim(FValue)) = 0) and
      (FAtributes.Count = 0));
end;

procedure TTextTag.ParseXML(Node: TXMLNode);
var
  i: integer;
  Attr: TAttribute;
begin
  try
    FValue := string(Node.ValueAsString);
    FName := string(Node.Name);
    for i := 0 to Node.AttributeCount - 1 do
    begin
      Attr.Name := string(Node.AttributeName[i]);
      Attr.Value := string(Node.AttributeValue[i]);
      FAtributes.Add(Attr)
    end;
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TAuthorTag }
constructor TAuthorTag.Create(ByNode: TXMLNode);
begin
  inherited Create;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TAuthorTag.ParseXML(Node: TXMLNode);
var
  i: integer;
begin
  try
    for i := 0 to Node.NodeCount - 1 do
    begin
      if Node.Nodes[i].Name = 'name' then
        FAuthor := string(Node.Nodes[i].ValueAsString)
      else if Node.Nodes[i].Name = 'email' then
        FEmail := string(Node.Nodes[i].ValueAsString)
      else if Node.Nodes[i].Name = 'uid' then
        FUID := string(Node.Nodes[i].ValueAsString);
    end;
  except
    Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
end;

{ TEntryLink }

function TEntryLink.AddToXML(Root: TXMLNode): TXMLNode;
begin
  Result := nil;
end;

constructor TEntryLink.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  if ByNode <> nil then
    ParseXML(ByNode);
end;

procedure TEntryLink.ParseXML(Node: TXMLNode);
begin
  if Node = nil then
    Exit;
  try
    Frel := string(Node.ReadAttributeString(sNodeRelAttr));
    Ftype := string(Node.ReadAttributeString('type'));
    Fhref := string(Node.ReadAttributeString(sNodeHrefAttr));
    FEtag := string(Node.ReadAttributeString(gdNodeAlias + 'etag'))
      except Exception.Create(Format(sc_ErrPrepareNode, ['link']));
  end;
end;

{ THTTPSender }

procedure THTTPSender.AddGoogleHeaders;
begin
  Headers.Add('GData-Version: ' + FApiVersion);
  Headers.Add('Authorization: GoogleLogin auth=' + FAuthKey);
end;

procedure THTTPSender.Clear;
begin
  inherited Clear;
  FMethod := '';
  FURL := '';
  FAuthKey := '';
  FApiVersion := '';
  FExtendedHeaders.Clear;
  Headers.Clear;
  Cookies.Clear;
end;

constructor THTTPSender.Create(const aMethod, aAuthKey, aURL,
  aAPIVersion: string);
begin
  inherited Create;
  FAuthKey := aAuthKey;
  FURL := aURL;
  FApiVersion := aAPIVersion;
  FMethod := aMethod;
  FExtendedHeaders := TStringList.Create;
end;

function THTTPSender.GetLength(const aURL: string): integer;
var
  size, content: Ansistring;
  ch: AnsiChar;
  h: TStringList;
begin
  with THTTPSend.Create do
  begin
    Headers.Add('GData-Version: ' + FApiVersion);
    Headers.Add('Authorization: GoogleLogin auth=' + FAuthKey);
    if HTTPMethod('HEAD', aURL) and (ResultCode = 200) then
    begin
      h := TStringList.Create;
      h.Assign(Headers);
      content := Ansistring(HeadByName('content-length', h));
      h.Delete(h.IndexOf(HeadByName('Connection', h)));
      h.Delete(h.IndexOf(string(content)));
      for ch in content do
        if ch in ['0' .. '9'] then
          size := size + ch;
      Result := StrToIntDef(string(size), 0) + Length(BytesOf(h.Text));
    end
    else
      Result := -1;
  end
end;

function THTTPSender.HeadByName(const aHead: string; aHeaders: TStringList)
  : string;
var
  str: string;
begin
  Result := '';
  for str in aHeaders do
  begin
    if pos(LowerCase(aHead), LowerCase(str)) > 0 then
    begin
      Result := str;
      break;
    end;
  end;
end;

function THTTPSender.SendRequest: boolean;
var
  str: string;
begin
  Result := false;
  if (Length(Trim(FMethod)) = 0) or (Length(Trim(FURL)) = 0) or
    (Length(Trim(FAuthKey)) = 0) or (Length(Trim(FApiVersion)) = 0) then
    Exit;
  // добавляем необходимые заголовки
  AddGoogleHeaders;
  if FExtendedHeaders.Count > 0 then
    for str in FExtendedHeaders do
      Headers.Add(str);
  Result := HTTPMethod(FMethod, FURL);
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

{ TXMLNode_ }

procedure TXMLNode_.NodesByName(const AName: string; AList: TList);
begin
  if AList = nil then
    AList:=TXmlNodeList.Create;
  AList.Clear;
  NodesByName(UTF8String(AName),AList);
end;


end.
