<<<<<<< HEAD
﻿{ Модуль содержит наиболее общие классы для работы с Google API, а также
  классы и методы для работы с основой всех API - GData API.
  Этот содуль должен подключаться в раздел uses всех прочих модулей, реализующих работу
  с различными Google API}
unit GDataCommon;

interface

uses
  NativeXML, Classes, StrUtils, SysUtils, typinfo,
  uLanguage, GConsts, Generics.Collections, DateUtils, httpsend;

type
{Class helper для объекта TXMLNode (узел XML-документа)
 применяется для преобразования строк в кодировке UTF-8 (UTF8String) в UnicodeString (string) и наоборот}
 TXMLNode_ = class helper for TXMLNode
 private
   function GetNameUnicode: string;
   procedure SetNodeUnicode(const aName: string);
   function GetAttributeUnicodeValue(index:integer): string;
   procedure SetAttributeUnicodeValue(index:integer; const aValue:string);
   function GetAttributeUnicodeName(index:integer):string;
   procedure SetAttributeUnicodeName(index:integer; aValue:string);
   function GetAttributeByUnicodeName(const aName: string):string;
   procedure SetAttributeByUnicodeName(const aName,aValue: string);
 public
   function  NodeNew(const AName: String): TXmlNode;overload;
   function  FindNode(const NodeName: String): TXmlNode;overload;
   function  ReadAttributeString(const AName: String; const ADefault: String = ''): String; overload;
   procedure AttributeAdd(const AName, AValue: String); overload;
   procedure WriteAttributeString(const AName: String; const AValue: String; const ADefault: String = ''); overload;
   procedure NodesByName(const AName: string; AList: TList);overload;
   property  NameUnicode: string read GetNameUnicode write SetNodeUnicode;
   property  AttributeUnicodeValue[Index: integer]: String read GetAttributeUnicodeValue write SetAttributeUnicodeValue;
   property  AttributeUnicodeName[Index: integer]: String read GetAttributeUnicodeName write SetAttributeUnicodeName;
   property AttributeByUnicodeName[const AName: String]: String read GetAttributeByUnicodeName
            write SetAttributeByUnicodeName;
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
    { Разбирает узел Node:TXMLNode и заполняет на основании полученных данных поля класса }
    procedure ParseXML(Node: TXMLNode);
    { На основании значений свойств формирует новый XML-узел и помещает его как
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
    {Проверяет экземпляр класса на "пустоту". Возвращает <b>false</b>, если
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
    {Разбирает узел Node:TXMLNode и заполняет на основании полученных данных поля класса}
    procedure ParseXML(Node: TXMLNode);
    { На основании значений свойств формирует новый XML-узел и помещает его как
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
  пользовательских данных в виде атрибутов узла и дочерних узлов XML-документа}
  TgdExtendedProperty = class
   private
     FName: string;
     FValue: string;
     FChildNodes: TList<TTextTag>;
   public
     {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
     Constructor Create(const ByNode: TXMLNode = nil);
     {Разбирает узел Node:TXMLNode и заполняет на основании полученных данных поля класса}
     procedure ParseXML(const Node: TXMLNode);
     { На основании значений свойств формирует новый XML-узел и помещает его как
      дочерний для узла <b>Root</b> }
     function AddToXML(Root: TXMLNode): TXMLNode;
     {Проверяет экземпляр класса на "пустоту". Возвращает <b>false</b>, если
      в классе не определены поля <b>FName</b> и <b>FValue</b>, а также отсутствуют дочерние узлы}
     function IsEmpty: boolean;
     {Очищает поля класса}
     procedure Clear;
     property Name: string read FName write FName;   //атрибут name узла
     property Value: string read FValue write FValue;//атрибут value узла
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
        (cName, ':', '_')));
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
    Result.WriteAttributeString(sNodeLabelAttr, FLabel);
  if Length(Frel) > 0 then
    Result.WriteAttributeString(sNodeRelAttr, Frel);
  if Length(FvalueString) > 0 then
    Result.WriteAttributeString('valueString', FvalueString);
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
  if GetGDNodeType(Node.NameUnicode) <> gd_where then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_where)]));
  try
    FLabel := Node.ReadAttributeString(sNodeLabelAttr);
    if Length(FLabel) = 0 then
      FLabel := Node.ReadAttributeString(sNodeRelAttr);
    FvalueString := Node.ReadAttributeString('valueString');
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
    Result.WriteAttributeString(sNodeHrefAttr, Fhref);
  if Length(Trim(Frel)) > 0 then
    Result.WriteAttributeString(sNodeRelAttr, Frel);
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
  if GetGDNodeType(Node.NameUnicode) <> gd_entryLink then
    raise Exception.Create
      (Format(sc_ErrCompNodes, [GetGDNodeName(gd_entryLink)]));
  try
    Fhref := Node.ReadAttributeString(sNodeHrefAttr);
    Frel := Node.ReadAttributeString(sNodeRelAttr);
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
  Result.WriteAttributeString(sNodeValueAttr, sSchemaHref + RelToStr(Frel));
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
  if GetGDNodeType(Node.NameUnicode) <> gd_eventStatus then
    raise Exception.Create
      (Format(sc_ErrCompNodes, [GetGDNodeName(gd_eventStatus)]));
  try
    Frel := StrToRel(Node.ReadAttributeString(sNodeValueAttr));
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
      Result.WriteAttributeString('startTime', FormatDateTime('yyyy-mm-dd', FstartTime));
    tdServerDate:
      Result.WriteAttributeString('startTime', DateTimeToServerDate(FstartTime));
  end;

  if FendTime > 0 then
    Result.WriteAttributeString
      ('endTime', DateTimeToServerDate(FendTime));
  if Length(Trim(FvalueString)) > 0 then
    Result.WriteAttributeString('valueString', FvalueString);
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
  if GetGDNodeType(Node.NameUnicode) <> gd_when then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_when)]));
  try
    FendTime := 0;
    FstartTime := 0;
    FvalueString := '';
    if Node.HasAttribute('endTime') then
      FendTime := ServerDateToDateTime
        (Node.ReadAttributeString('endTime'));
    FstartTime := ServerDateToDateTime
      (Node.ReadAttributeString('startTime'));
    if Node.HasAttribute('valueString') then
      FvalueString := Node.ReadAttributeString('valueString');
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
  Result.WriteAttributeString(sNodeValueAttr, sSchemaHref + RelToStr(Frel));
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
  if GetGDNodeType(Node.NameUnicode) <> gd_attendeeStatus then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName
          (gd_attendeeStatus)]));
  try
    Frel := StrToRel(Node.ReadAttributeString(sNodeValueAttr));
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
  Result.WriteAttributeString(sNodeValueAttr, sSchemaHref + RelToStr(Frel));
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
  if GetGDNodeType(Node.NameUnicode) <> gd_attendeeType then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName
          (gd_attendeeType)]));
  try
    Frel := StrToRel(Node.ReadAttributeString(sNodeValueAttr));
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
    Result.WriteAttributeString('email', FEmail);
  if Length(Trim(Frel)) > 0 then
    Result.WriteAttributeString(sNodeRelAttr, sSchemaHref + RelValues[ord(FRelValue)]);
  if Length(Trim(FvalueString)) > 0 then
    Result.WriteAttributeString('valueString', FvalueString);
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
  if GetGDNodeType(Node.NameUnicode) <> gd_who then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_who)]));
  try
    FEmail := Node.ReadAttributeString('email');
    if Length(Node.ReadAttributeString(sNodeRelAttr)) > 0 then
    begin
      s := Node.ReadAttributeString(sNodeRelAttr);
      s := StringReplace(s, sSchemaHref, '', [rfIgnoreCase]);
      FRelValue := TWhoRel(AnsiIndexStr(s, RelValues));
    end;
    FvalueString := Node.ReadAttributeString('valueString');
    if Node.NodeCount > 0 then
    begin
      for i := 0 to Node.NodeCount - 1 do
        case GetGDNodeType(Node.Nodes[i].NameUnicode) of
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
  if GetGDNodeType(Node.NameUnicode) <> gd_recurrence then
    raise Exception.Create
      (Format(sc_ErrCompNodes, [GetGDNodeName(gd_recurrence)]));
  try
    FText.Text := Node.ValueAsUnicodeString;
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
  Result.WriteAttributeString('method', cMethods[ord(FMethod)]);
  case FPeriod of
    tpDays:
      Result.WriteAttributeInteger('days', FPeriodValue);
    tpHours:
      Result.WriteAttributeInteger('hours', FPeriodValue);
    tpMinutes:
      Result.WriteAttributeInteger('minutes', FPeriodValue);
  end;
  if FabsoluteTime > 0 then
    Result.WriteAttributeString('absoluteTime', DateTimeToServerDate(FabsoluteTime))
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
  if GetGDNodeType(Node.NameUnicode) <> gd_reminder then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_reminder)])
      );
  try
    if Length(Node.ReadAttributeString('absoluteTime')) > 0 then
      FabsoluteTime := ServerDateToDateTime
        (Node.ReadAttributeString('absoluteTime'));
    if Length(Node.ReadAttributeString('method')) > 0 then
      FMethod := TMethod(AnsiIndexStr(Node.ReadAttributeString('method')
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
  Result.WriteAttributeString(sNodeValueAttr, sSchemaHref + RelToStr(Frel));
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
  if GetGDNodeType(Node.NameUnicode) <> gd_transparency then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName
          (gd_transparency)]));
  try
    Frel := StrToRel(Node.ReadAttributeString(sNodeValueAttr));
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
  Result.WriteAttributeString(sNodeValueAttr, sSchemaHref + RelToStr(Frel));
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
  if GetGDNodeType(Node.NameUnicode) <> gd_visibility then
    raise Exception.Create
      (Format(sc_ErrCompNodes, [GetGDNodeName(gd_visibility)]));
  try
    Frel := StrToRel(Node.ReadAttributeString(sNodeValueAttr));
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
    Result.WriteAttributeString(sNodeRelAttr, Frel);
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString(sNodeLabelAttr, FLabel);
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
  if GetGDNodeType(Node.NameUnicode) <> gd_organization then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName
          (gd_organization)]));
  try
    Frel := Node.ReadAttributeString(sNodeRelAttr);
    if Node.HasAttribute('primary') then
      FPrimary := Node.ReadAttributeBool('primary');
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel := Node.ReadAttributeString(sNodeLabelAttr);
    for i := 0 to Node.NodeCount - 1 do
    begin
      if LowerCase(Node.Nodes[i].NameUnicode) = LowerCase
        (GetGDNodeName(gd_orgName)) then
        ForgName := TgdOrgName.Create(Node.Nodes[i])
      else if LowerCase(Node.Nodes[i].NameUnicode) = LowerCase
        (GetGDNodeName(gd_orgTitle)) then
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
    Result.WriteAttributeString(sNodeRelAttr, sSchemaHref + tmp);
  end;
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString(sNodeLabelAttr, FLabel);
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString('displayName', FDisplayName);
  if FPrimary then
    Result.WriteAttributeBool('primary', FPrimary);
  Result.WriteAttributeString('address', FAddress);
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
  if GetGDNodeType(Node.NameUnicode) <> gd_email then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_email)]));
  try
    tmp := 'em_' + ReplaceStr(Node.ReadAttributeString(sNodeRelAttr),
      sSchemaHref, '');
    Frel := TTypeElement(GetEnumValue(TypeInfo(TTypeElement), tmp));
    if Node.HasAttribute('primary') then
      FPrimary := Node.ReadAttributeBool('primary');
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel := Node.ReadAttributeString(sNodeLabelAttr);
    if Node.HasAttribute('displayName') then
      FDisplayName := Node.ReadAttributeString('displayName');
    FAddress := Node.ReadAttributeString('address');
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
  FGivenName := TgdGivenName.Create(GetGDNodeName(gd_givenName));
  FAdditionalName := TgdAdditionalName.Create
    (string(GetGDNodeName(gd_additionalName)));
  FFamilyName := TgdFamilyName.Create(GetGDNodeName(gd_familyName));
  FNamePrefix := TgdNamePrefix.Create(GetGDNodeName(gd_namePrefix));
  FNameSuffix := TgdNameSuffix.Create(GetGDNodeName(gd_nameSuffix));
  FFullName := TgdFullName.Create(GetGDNodeName(gd_fullName));
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
  if GetGDNodeType(Node.NameUnicode) <> gd_name then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_name)]));
  try
    for i := 0 to Node.NodeCount - 1 do
    begin
      case GetGDNodeType(Node.Nodes[i].NameUnicode) of
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
    FAdditionalName.Name := GetGDNodeName(gd_additionalName);
  FAdditionalName.Value := aAdditionalName.Value;
end;

procedure TgdName.SetFamilyName(aFamilyName: TTextTag);
begin
  if aFamilyName = nil then
    Exit;
  if Length(FFamilyName.Name) = 0 then
    FFamilyName.Name := GetGDNodeName(gd_familyName);
  FFamilyName.Value := aFamilyName.Value;
end;

procedure TgdName.SetFullName(aFullName: TTextTag);
begin
  if aFullName = nil then
    Exit;
  if Length(FFullName.Name) = 0 then
    FFullName.Name := GetGDNodeName(gd_fullName);
  FFullName.Value := aFullName.Value;
end;

procedure TgdName.SetGivenName(aGivenName: TTextTag);
begin
  if aGivenName = nil then
    Exit;
  if Length(FGivenName.Name) = 0 then
    FGivenName.Name := GetGDNodeName(gd_givenName);
  FFullName.Value := aGivenName.Value;
end;

procedure TgdName.SetNamePrefix(aNamePrefix: TTextTag);
begin
  if aNamePrefix = nil then
    Exit;
  if Length(FNamePrefix.Name) = 0 then
    FNamePrefix.Name := GetGDNodeName(gd_namePrefix);
  FNamePrefix.Value := aNamePrefix.Value;
end;

procedure TgdName.SetNameSuffix(aNameSuffix: TTextTag);
begin
  if aNameSuffix = nil then
    Exit;
  if Length(FNameSuffix.Name) = 0 then
    FNameSuffix.Name := GetGDNodeName(gd_nameSuffix);
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
    Result.WriteAttributeString(sNodeRelAttr, sSchemaHref + tmp);
  end;

  Result.ValueAsUnicodeString := FValue;
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString(sNodeLabelAttr, FLabel);
  if Trim(FUri) <> '' then
    Result.WriteAttributeString('uri', FUri);
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
  if GetGDNodeType(Node.NameUnicode) <> gd_phoneNumber then
    raise Exception.Create
      (Format(sc_ErrCompNodes, [GetGDNodeName(gd_phoneNumber)]));
  try
    tmp := 'tp_' + ReplaceStr(Node.ReadAttributeString(sNodeRelAttr),
      sSchemaHref, '');
    if Length(tmp) > 3 then
      Frel := TPhonesRel(GetEnumValue(TypeInfo(TPhonesRel), tmp));
    if Node.HasAttribute('primary') then
      FPrimary := Node.ReadAttributeBool('primary');
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel := Node.ReadAttributeString(sNodeLabelAttr);
    if Node.HasAttribute('uri') then
      FUri := Node.ReadAttributeString('uri');
    FValue := Node.ValueAsUnicodeString;
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
    Result.WriteAttributeString('code', FCode);
  Result.ValueAsUnicodeString := FValue;
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
  if GetGDNodeType(Node.NameUnicode) <> gd_country then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_country)])
      );
  try
    FCode := Node.ReadAttributeString(sNodeRelAttr);
    FValue := Node.ValueAsUnicodeString;
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
    Result.WriteAttributeString(sNodeRelAttr, Frel);
  if Trim(FMailClass) <> '' then
    Result.WriteAttributeString('mailClass', FMailClass);
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString(sNodeLabelAttr, FLabel);
  if Trim(FUsage) <> '' then
    Result.WriteAttributeString('Usage', FUsage);
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
  if GetGDNodeType(Node.NameUnicode) <> gd_structuredPostalAddress then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName
          (gd_structuredPostalAddress)]));
  try
    Frel := Node.ReadAttributeString(sNodeRelAttr);
    FMailClass := Node.ReadAttributeString('mailClass');
    FLabel := Node.ReadAttributeString(sNodeLabelAttr);
    if Node.HasAttribute('primaty') then
      FPrimary := Node.ReadAttributeBool('primary');
    FUsage := Node.ReadAttributeString('Usage');
  except
    raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
  end;
  for i := 0 to Node.NodeCount - 1 do
  begin
    case GetGDNodeType(Node.Nodes[i].NameUnicode) of
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
  Result.WriteAttributeString(sNodeRelAttr, sSchemaHref + tmp);
  Result.WriteAttributeString('address', FAddress);
  Result.WriteAttributeString(sNodeLabelAttr, FLabel);

  tmp := GetEnumName(TypeInfo(TIMProtocol), ord(FIMProtocol));
  Delete(tmp, 1, 3);
  Result.WriteAttributeString('protocol', sSchemaHref + tmp);

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
  if GetGDNodeType(Node.NameUnicode) <> gd_im then
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_im)]));
  try
    tmp := 'im_' + ReplaceStr(Node.ReadAttributeString(sNodeRelAttr),
      sSchemaHref, '');
    FIMType := TIMtype(GetEnumValue(TypeInfo(TIMtype), tmp));

    FLabel := Node.ReadAttributeString(sNodeLabelAttr);
    FAddress := Node.ReadAttributeString('address');

    tmp := 'ti_' + ReplaceStr(Node.ReadAttributeString('protocol'),
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
  Result.ValueAsUnicodeString := FValue;
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
    FValue := Node.ValueAsUnicodeString;
    FName := Node.NameUnicode;
    for i := 0 to Node.AttributeCount - 1 do
    begin
      Attr.Name := Node.AttributeUnicodeName[i];
      Attr.Value := Node.AttributeUnicodeValue[i];
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
        FAuthor := Node.Nodes[i].ValueAsUnicodeString
      else if Node.Nodes[i].Name = 'email' then
        FEmail := Node.Nodes[i].ValueAsUnicodeString
      else if Node.Nodes[i].Name = 'uid' then
        FUID := Node.Nodes[i].ValueAsUnicodeString;
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
    Frel := Node.ReadAttributeString(sNodeRelAttr);
    Ftype := Node.ReadAttributeString('type');
    Fhref := Node.ReadAttributeString(sNodeHrefAttr);
    FEtag := Node.ReadAttributeString(gdNodeAlias + 'etag')
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
  MimeType:='application/atom+xml';
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

procedure TXMLNode_.AttributeAdd(const AName, AValue: String);
begin
  AttributeAdd(UTF8String(AName),UTF8String(AValue));
end;

function TXMLNode_.FindNode(const NodeName: String): TXmlNode;
begin
  Result:=FindNode(UTF8String(NodeName))
end;

function TXMLNode_.GetAttributeByUnicodeName(const aName: string): string;
begin
  Result:=string(AttributeByName[UTF8String(aName)]);
end;

function TXMLNode_.GetAttributeUnicodeName(index: integer): string;
begin
  Result:=string(AttributeName[index])
end;

function TXMLNode_.GetAttributeUnicodeValue(index:integer): string;
begin
  Result:=string(AttributeValue[index])
end;

function TXMLNode_.GetNameUnicode: string;
begin
  Result:=string(Name);
end;

function TXMLNode_.NodeNew(const AName: String): TXmlNode;
begin
  Result:=NodeNew(UTF8String(AName));
end;

procedure TXMLNode_.NodesByName(const AName: string; AList: TList);
begin
  if AList = nil then
    AList:=TXmlNodeList.Create;
  AList.Clear;
  NodesByName(UTF8String(AName),AList);
end;


function TXMLNode_.ReadAttributeString(const AName,
  ADefault: String): String;
begin
  Result:=string(ReadAttributeString(UTF8String(AName),UTF8String(ADefault)))
end;

procedure TXMLNode_.SetAttributeByUnicodeName(const aName, aValue: string);
begin
  AttributeByName[UTF8String(aName)]:=UTF8String(aValue);
end;

procedure TXMLNode_.SetAttributeUnicodeName(index: integer; aValue: string);
begin
  AttributeName[index]:=UTF8String(aValue);
end;

procedure TXMLNode_.SetAttributeUnicodeValue(index:integer;const aValue: string);
begin
  AttributeValue[index]:=UTF8String(aValue);
end;

procedure TXMLNode_.SetNodeUnicode(const aName: string);
begin
  Name:=UTF8String(aName);
end;

procedure TXMLNode_.WriteAttributeString(const AName, AValue, ADefault: String);
begin
  WriteAttributeString(UTF8String(AName),UTF8String(AValue),UTF8String(ADefault));
end;

{ TgdExtendedPropertyStruct }

function TgdExtendedProperty.AddToXML(Root: TXMLNode): TXMLNode;
var i: integer;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then Exit;
  Result := Root.NodeNew(GetGDNodeName(gd_extendedProperty));
  if Length(Trim(FName))>0 then
    Result.WriteAttributeString('name',FName);
  if Length(Trim(FValue))>0 then
    Result.WriteAttributeString('value',FValue);
  //добавляем все дочерние узлы
  for i := 0 to FChildNodes.Count - 1 do
    FChildNodes[i].AddToXML(Result)
end;

procedure TgdExtendedProperty.Clear;
begin
  FName:='';
  FValue:='';
  FChildNodes.Clear;
end;

constructor TgdExtendedProperty.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  FChildNodes:=TList<TTextTag>.Create;
  if ByNode<>nil then ParseXML(ByNode);
end;

function TgdExtendedProperty.IsEmpty: boolean;
begin
  Result:=(Length(Trim(FName))=0)
          and(Length(Trim(FValue))=0)
          and(FChildNodes.Count=0)
end;

procedure TgdExtendedProperty.ParseXML(const Node: TXMLNode);
var i:integer;
begin
if Node = nil then Exit; //если узел не определен, то выходим
  if GetGDNodeType(Node.NameUnicode) <> gd_extendedProperty then //указан не тот узел
    raise Exception.Create(Format(sc_ErrCompNodes, [GetGDNodeName(gd_extendedProperty)]));
try
//заполняем поля класса данными из атрибутов
FValue:=Node.AttributeByUnicodeName['value'];
FName:=Node.AttributeByUnicodeName['name'];
{заполняем список дочерних узлов}
if Node.NodeCount>0 then
  begin
    for I := 0 to Node.NodeCount - 1 do
      FChildNodes.Add(TTextTag.Create(Node.Nodes[i]));
  end;
except
  raise Exception.Create(Format(sc_ErrPrepareNode, [Node.Name]));
end;
end;

end.
=======
unit GDataCommon;
{ TODO : ��������� ��� ������ �� �������, ����� ��������� ��������� ���������� ������ }
interface

uses NativeXML, Classes, XMLIntf, StrUtils, SysUtils, GHelper, Variants;

const
  cGDTagNames: array [0 .. 49] of string = ('gd:country', 'gd:additionalName',
    'gd:name', 'gd:email', 'gd:extendedProperty', 'gd:geoPt', 'gd:im',
    'gd:orgName', 'gd:orgTitle', 'gd:organization', 'gd:originalEvent',
    'gd:phoneNumber', 'gd:postalAddress', 'gd:rating', 'gd:recurrence',
    'gd:reminder', 'gd:resourceId', 'gd:when', 'gd:agent', 'gd:housename',
    'gd:street', 'gd:pobox', 'gd:neighborhood', 'gd:city', 'gd:subregion',
    'gd:region', 'gd:postcode', 'gd:formattedAddress',
    'gd:structuredPostalAddress', 'gd:entryLink', 'gd:where', 'gd:familyName',
    'gd:givenName', 'gd:namePrefix', 'gd:nameSuffix', 'gd:fullName',
    'gd:orgDepartment', 'gd:orgJobDescription', 'gd:orgSymbol',
    'gd:famileName', 'gd:eventStatus', 'gd:visibility', 'gd:transparency',
    'gd:attendeeType', 'gd:attendeeStatus', 'gd:comments', 'gd:deleted',
    'gd:feedLink', 'gd:who', 'gd:recurrenceException');

type
  TgdEnum = (egdCountry, egdAdditionalName, egdName, egdEmail,
    egdExtendedProperty, egdGeoPt, egdIm, egdOrgName, egdOrgTitle,
    egdOrganization, egdOriginalEvent, egdPhoneNumber, egdPostalAddress,
    egdRating, egdRecurrence, egdReminder, egdResourceId, egdWhen, egdAgent,
    egdHousename, egdStreet, egdPobox, egdNeighborhood, egdCity, egdSubregion,
    egdRegion, egdPostcode, egdFormattedAddress, egdStructuredPostalAddress,
    egdEntryLink, egdWhere, egdFamilyName, egdGivenName, egdNamePrefix,
    egdNameSuffix, egdFullName, egdOregdepartment, egdOrgJobDescription,
    egdOrgSymbol, egdFamileName, egdEventStatus, egdVisibility,
    egdTransparency, egdAttendeeType, egdAttendeeStatus, egdComments,
    egdDeleted, egdFeedLink, egdWho, egdRecurrenceException);

type
  TGDataTags = set of TgdEnum;

type
  TEventStatus = (esCanceled, esConfirmed, esTentative);

{ DONE -o� -c������� : ��������� � ����� }
type
  TgdEventStatus = class(TPersistent)
    private
      FValue: string;
      FStatus: TEventStatus;
      const
        RelValues: array [0..2]of string=(
       'event.canceled','event.confirmed','event.tentative');
      procedure SetStatus(aStatus:TEventStatus);
    public
      Constructor Create(const ByNode:IXMLNode=nil);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
      property Status:TEventStatus read FStatus write SetStatus;
  end;

type
  TVisibility = (vConfidential, vDefault, vPrivate, vPublic);

{ DONE -o� -c������� : ��������� � ����� }
type
  TgdVisibility = class
    private
      FValue: string;
      FVisible: TVisibility;
      const
        RelValues: array [0..3]of string = (
    'event.confidential','event.default','event.private','event.public');
      procedure SetVisible(aVisible:TVisibility);
    public
      Constructor Create(const ByNode:IXMLNode=nil);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
      property Visibility: TVisibility read FVisible write SetVisible;
  end;

type
  TTransparency = (tOpaque, tTransparent);

{ DONE -o� -c������� : ��������� � ����� }
type
  TgdTransparency = class(TPersistent)
    private
      FValue: string;
      FTransparency: TTransparency;
      const
        RelValues: array [0 .. 1] of string = ('event.opaque','event.transparent');
//      procedure SetValue(aValue:string);
      procedure SetTransp(aTransp:TTransparency);
    public
      Constructor Create(const ByNode:IXMLNode=nil);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
//      property Value: string read FValue write SetValue;
      property Transparency: TTransparency read FTransparency write SetTransp;
  end;

type
  TAttendeeType = (aOptional, aRequired);

{ DONE -o� -c������� : ��������� � ����� }
type
  TgdAttendeeType = class
    private
      FValue: string;
      FAttType: TAttendeeType;
      const RelValues: array [0 .. 1] of string =
      ('event.optional','event.required');
//      procedure SetValue(aValue:string);
      procedure SetType(aStatus:TAttendeeType);
    public
      Constructor Create(const ByNode:IXMLNode);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
//      property Value: string read FValue write SetValue;
      property AttendeeType: TAttendeeType read FAttType write SetType;
  end;

type
  TAttendeeStatus = (asAccepted, asDeclined, asInvited, asTentative);

{ DONE -o� -c������� : ��������� � ����� }
type
  TgdAttendeeStatus = class(TPersistent)
    private
      FValue: string;
      FAttendeeStatus: TAttendeeStatus;
      const
        RelValues: array [0 .. 3] of string = (
    'event.accepted','event.declined','event.invited','event.tentative');
 //     procedure SetValue(aValue:string);
      procedure SetStatus(aStatus:TAttendeeStatus);
    public
      Constructor Create(const ByNode:IXMLNode);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
//      property Value: string read FValue write SetValue;
      property Status: TAttendeeStatus read FAttendeeStatus write SetStatus;
  end;

type
  TEntryTerms = (ttAny, ttContact, ttEvent, ttMessage, ttType);

type
  TgdCountry = class(TPersistent)
    private
     FCode: string;
     FValue: string;
    public
     Constructor Create(const ByNode:TXMLNode);
     procedure   ParseXML(Node: TXMLNode);
     function    AddToXML(Root:TXMLNode):TXMLNode;
     property Code: string read FCode write FCode;
     property Value: string read FValue write FValue;
  end;

type
  TgdAdditionalNameStruct = TTextTag;

type
  TgdFamilyName = TTextTag;
  TgdGivenName = TTextTag;
//  TgdFamileNameStruct = string;
  TgdNamePrefix = TTextTag;
  TgdNameSuffix = TTextTag;
  TgdFullName = TTextTag;
  TgdOrgDepartment = TTextTag;
  TgdOrgJobDescription = TTextTag;
  TgdOrgSymbol = TTextTag;

type
  TgdName = class(TPersistent)
  private
    FGivenName: TTextTag;
    FAdditionalName: TTextTag;
    FFamilyName: TTextTag;
    FNamePrefix: TTextTag;
    FNameSuffix: TTextTag;
    FFullName: TTextTag;
    function GetFullName:string;
  public
    constructor Create(ByNode: TXMLNode=nil);
    procedure   ParseXML(const Node: TXmlNode);
    function IsEmpty:boolean;
    function AddToXML(Root:TXMLNode):TXmlNode;
    property GivenName: TTextTag read FGivenName write FGivenName;
    property AdditionalName: TTextTag read FAdditionalName write FAdditionalName;
    property FamilyName: TTextTag read FFamilyName write FFamilyName;
    property NamePrefix: TTextTag read FNamePrefix write FNamePrefix;
    property NameSuffix: TTextTag read FNameSuffix write FNameSuffix;
    property FullName: TTextTag read FFullName write FFullName;
    property FullNameString: string read GetFullName;
end;

type
  TTypeElement = (ttHome,ttOther, ttWork);

type
  TgdEmail = class(TPersistent)
    private
      FAddress: string;
      FEmailType: TTypeElement;
      FLabel: string;
      FRel: string;
      FPrimary: boolean;
      FDisplayName:string;
      const RelValues: array[0..2]of string=('home','other','work');
      procedure SetRel(const aRel:string);
      procedure SetEmailType(aType:TTypeElement);
    public
      constructor Create(ByNode: TXMLNode=nil);
      procedure   ParseXML(const Node: TXmlNode);
      function AddToXML(Root:TXMLNode):TXmlNode;
      property Address : string read FAddress write FAddress;
      property Labl:string read FLabel write FLabel;
      property Rel: string read FRel write SetRel;
      property DisplayName: string read FDisplayName write FDisplayName;
      property Primary: boolean read FPrimary write FPrimary;
      property EmailType:TTypeElement read FEmailType write SetEmailType;
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
  TIMProtocol = (tiAIM,tiMSN,tiYAHOO,tiSKYPE,tiQQ,tiGOOGLE_TALK,tiICQ,tiJABBER);
  TIMtype = (timHome,timNetmeeting,timOther,timWork);

type
  TgdIm = class(TPersistent)
  private  { DONE -o� -c������� : �������� ���� ������ �� �������� � ������� Rel, ���������� �� ������� string }
    FAddress: string;
    FLabel: string;
    FPrimary: boolean;
    FIMProtocol:TIMProtocol;
    FIMType:TIMtype;
    const
      RelValues: array[0..3]of string=('home','netmeeting','other','work');
      ProtocolValues:array[0..7]of string=('AIM','MSN','YAHOO','SKYPE','QQ','GOOGLE_TALK','ICQ','JABBER');
  public
    constructor Create(ByNode: TXMLNode=nil);
    procedure   ParseXML(const Node: TXmlNode);
    function AddToXML(Root:TXMLNode):TXmlNode;
    property Address: string read FAddress write FAddress;
    property iLabel: string read FLabel write FLabel;
    property ImType: TIMtype read FIMType write FIMType;
    property Protocol: TIMProtocol read FIMProtocol write FIMProtocol;
    property Primary: boolean read FPrimary write FPrimary;
end;

  TgdOrgName = TTextTag;
  TgdOrgTitle = TTextTag;

type
  TgdOrganization = class(TPersistent)
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
  TPhonesRel=(tpAssistant,tpCallback,tpCar,TpCompany_main,tpFax,
      tpHome,tpHome_fax,tpIsdn,tpMain,tpMobile,tpOther,tpOther_fax,
      tpPager,tpRadio,tpTelex,tpTty_tdd,TpWork,tpWork_fax,
      tpWork_mobile,tpWork_pager);
type
  TgdPhoneNumber = class(TPersistent)
    private     { DONE -o� -c������� : ������ ��������� ���� FRel - ��������� �������� � ����������� �� ���� }
      FPrimary: boolean;
      FPhoneType: TPhonesRel;
      FLabel: string;
    //  Frel: string;
      FUri: string;
      FValue: string;
      const RelValues: array[0..19]of string=('assistant','callback','car','company_main','fax',
      'home','home_fax','isdn','main','mobile','other','other_fax','pager',
      'radio','telex','tty_tdd','work','work_fax','work_mobile','work_pager');
  //    procedure SetRel(aPhoneRel:TPhonesRel);
    public
      constructor Create(ByNode: TXMLNode=nil);
      procedure   ParseXML(const Node: TXmlNode);
      function AddToXML(Root:TXMLNode):TXmlNode;
      property PhoneType: TPhonesRel read FPhoneType write FPhoneType;
      property Primary: boolean read FPrimary write FPrimary;
      property Labl: string read FLabel write FLabel;
//      property Rel: string read Frel write Frel;
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
  TgdRecurrence = class(TPersistent)
  private
    FText: TStringList;
  public
    Constructor Create(const ByNode:IXMLNode=nil);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root:IXMLNode):IXMLNode;
    property Text: TStringList read FText write FText;
end;

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
      Constructor Create(const ByNode:IXMLNode);
      procedure ParseXML(Node: IXMLNode);
      function  AddToXML(Root:IXMLNode):IXMLNode;
      property  AbsTime: TDateTime read FabsoluteTime write FabsoluteTime;
      property  Method: TMethod read Fmethod write Fmethod;
      property  Period: TRemindPeriod read FPeriod write FPeriod;
      property  PeriodValue:integer read FPeriodValue write FPeriodValue;
  end;

type
  TgdResourceIdStruct = string;

type
  TDateFormat = (tdDate, tdServerDate);

type
  TgdWhen = class
    private
      FendTime: TDateTime;
      FstartTime: TDateTime;
      FvalueString: string;
    public
      Constructor Create(const ByNode:TXMLNode=nil);
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
  TgdStructuredPostalAddress = class(TPersistent)
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
     FCoutry: TgdCountry;
     FFormattedAddress: TgdFormattedAddress;
    public
      Constructor Create(const ByNode:TXMLNode=nil);
      procedure ParseXML(Node: TXMLNode);
      function AddToXML(Root:TXMLNode):TXMLNode;
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
      property Coutry: TgdCountry read FCoutry write FCoutry;
      property FormattedAddress: TgdFormattedAddress read FFormattedAddress write FFormattedAddress;
  end;

type
  TgdEntryLink = class(TPersistent)
    private
      Fhref: string;
      FReadOnly: boolean;
      Frel: string;
      FAtomEntry: IXMLNode;
    public
      Constructor Create(const ByNode:IXMLNode);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
      property Href: string read Fhref write Fhref;
      property OnlyRead: boolean read FReadOnly write FReadOnly;
      property Rel: string read Frel write Frel;
  end;

type
  TgdWhere = class(TPersistent)
    private
     Flabel: string;
     Frel: string;
     FvalueString: string;
     FEntryLink: TgdEntryLink;
    public
      Constructor Create(const ByNode:IXMLNode=nil);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
      property Labl:string read Flabel write Flabel;
      property Rel:string read FRel write FRel;
      property valueString: string read FvalueString write FvalueString;
      property EntryLink: TgdEntryLink read FEntryLink write FEntryLink;
  end;

type
  TWhoRel = (twAttendee,twOrganizer,twPerformer,twSpeaker,twBcc,twCc,twFrom,twReply,twTo);
{ DONE -o� -c������� : ��������� ��������� � ����� }
type
  TgdWho = class(TPersistent)
  private  { DONE -o� -c������� : ���������� �� ��������� ������� }
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
//    procedure SetRel(aRel:string);
//    procedure SetRelValue(aRelValue:TWhoRel);
  public
    Constructor Create(const ByNode:IXMLNode=nil);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root:IXMLNode):IXMLNode;
    property Email: string read FEmail write FEmail;
//    property Rel: string read Frel write SetRel;
    property RelValue: TWhoRel read FRelValue write FRelValue;
    property valueString: string read FvalueString write FvalueString;
    property AttendeeStatus: TgdAttendeeStatus read FAttendeeStatus write FAttendeeStatus;
    property AttendeeType: TgdAttendeeType read FAttendeeType write FAttendeeType;
    property EntryLink: TgdEntryLink read FEntryLink write FEntryLink;
end;

function GetGDNodeType(cName: string): integer;

function gdAttendeeStatus(aXMLNode: IXMLNode): TgdAttendeeStatus;
function gdAttendeeType(aXMLNode: IXMLNode): TgdAttendeeType;
function gdTransparency(aXMLNode: IXMLNode): TgdTransparency;
function gdVisibility(aXMLNode: IXMLNode): TgdVisibility;
function gdEventStatus(aXMLNode: IXMLNode): TgdEventStatus;
function gdWhere(aXMLNode: IXMLNode):TgdWhere;
function gdWhen(aXMLNode: TXMLNode):TgdWhen;
function gdWho(aXMLNode: IXMLNode):TgdWho;
function gdRecurrence(aXMLNode: IXMLNode):TgdRecurrence;
function gdReminder(aXMLNode: IXMLNode):TgdReminder;

implementation

function gdReminder(aXMLNode: IXMLNode):TgdReminder;
begin
  Result:=TgdReminder.Create(aXMLNode);
end;

function gdRecurrence(aXMLNode: IXMLNode):TgdRecurrence;
begin
  Result:=TgdRecurrence.Create(aXMLNode);
end;

function gdWho(aXMLNode: IXMLNode):TgdWho;
begin
  Result:=TgdWho.Create(aXMLNode);
end;

function gdWhen(aXMLNode: TXMLNode):TgdWhen;
begin
  Result:=TgdWhen.Create(aXMLNode);
end;

function gdWhere(aXMLNode: IXMLNode):TgdWhere;
begin
  Result:=TgdWhere.Create(aXMLNode);
end;

function gdEventStatus(aXMLNode: IXMLNode): TgdEventStatus;
begin
  Result:=TgdEventStatus.Create(aXMLNode);
end;

function gdVisibility(aXMLNode: IXMLNode): TgdVisibility;
begin
  Result:=TgdVisibility.Create(aXMLNode);
end;

function gdTransparency(aXMLNode: IXMLNode): TgdTransparency;
begin
  Result:=TgdTransparency.Create(aXMLNode);
end;

function GetGDNodeType(cName: string): integer;
begin
  Result := AnsiIndexStr(cName, cGDTagNames);
end;

function gdAttendeeType(aXMLNode: IXMLNode): TgdAttendeeType;
begin
  Result:=TgdAttendeeType.Create(aXMLNode);
end;

function gdAttendeeStatus(aXMLNode: IXMLNode): TgdAttendeeStatus;
begin
  Result:=TgdAttendeeStatus.Create(aXMLNode);
end;

{ TgdWhere }

function TgdWhere.AddToXML(Root: IXMLNode): IXMLNode;
begin
  //��������� ����
  if Root=nil then Exit;
  Result:=Root.AddChild(cgdTagNames[ord(egdWhere)]);
  if Length(Flabel)>0 then
    Result.Attributes['label']:=Flabel;
  if Length(Frel)>0 then
    Result.Attributes['rel']:=Frel;
  if Length(FvalueString)>0 then
    Result.Attributes['valueString']:=FvalueString;
  if FEntryLink<>nil then
    if (FEntryLink.FAtomEntry<>nil)or(Length(FEntryLink.Fhref)>0) then
      FEntryLink.AddToXML(Result);
end;

constructor TgdWhere.Create(const ByNode: IXMLNode);
begin
inherited Create;
if ByNode=nil then Exit;
FEntryLink:=TgdEntryLink.Create(nil);
ParseXML(ByNode);
end;

procedure TgdWhere.ParseXML(Node: IXMLNode);
begin
if GetGDNodeType(Node.NodeName) <> ord(egdWhere) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdWhere)]]));
  try
    if Node.Attributes['label']<>null then
      Flabel:=Node.Attributes['label'];
    if Node.Attributes['rel']<>null then
      Flabel:=Node.Attributes['rel'];
    if Node.Attributes['valueString']<>null then
      FvalueString:=Node.Attributes['valueString'];
    if Node.ChildNodes.Count>0 then //���� �������� ���� � EntryLink
      begin
        FEntryLink.ParseXML(Node.ChildNodes.FindNode('gd:entry'));
      end;
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgdEntryLinkStruct }

function TgdEntryLink.AddToXML(Root: IXMLNode): IXMLNode;
begin
if Root=nil then Exit;
 Result:=Root.AddChild(cgdTagNames[ord(egdEntryLink)]);
 if Length(Trim(Fhref))>0 then
   Result.Attributes['href']:=Fhref;
 if Length(Trim(Frel))>0 then
   Result.Attributes['rel']:=Frel;
 Result.Attributes['readOnly']:=FReadOnly;
 if FAtomEntry<>nil then
   Result.ChildNodes.Add(FAtomEntry);
end;

constructor TgdEntryLink.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdEntryLink.ParseXML(Node: IXMLNode);
begin
if GetGDNodeType(Node.NodeName) <> ord(egdEntryLink) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdEntryLink)]]));
  try
    if Node.Attributes['href']<>null then
      Fhref:=Node.Attributes['href'];
    if Node.Attributes['rel']<>null then
      Frel:=Node.Attributes['rel'];
    if Node.Attributes['readOnly']<>null then
      FReadOnly:=Node.Attributes['readOnly'];
    if Node.ChildNodes.Count>0 then //���� �������� ���� � EntryLink
       FAtomEntry:=Node.ChildNodes.FindNode('entry');
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgdEventStatus }

function TgdEventStatus.AddToXML(Root: IXMLNode): IXMLNode;
begin
if Root=nil then Exit;
  Result:=Root.AddChild(cgdTagNames[ord(egdEventStatus)]);
  Result.Attributes['value']:=SchemaHref+FValue;
end;

constructor TgdEventStatus.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdEventStatus.ParseXML(Node: IXMLNode);
begin
  if Node=nil then Exit;
  if GetGDNodeType(Node.NodeName) <> ord(egdEventStatus) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdEventStatus)]]));
  try
  //  ShowMessage(Node.Attributes['value']);
    FValue:=VarToStr(Node.Attributes['value']);
    FValue:=StringReplace(FValue,SchemaHref,'',[rfIgnoreCase]);
    FStatus:=TEventStatus(AnsiIndexStr(FValue, RelValues));
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

procedure TgdEventStatus.SetStatus(aStatus: TEventStatus);
begin
  FStatus:=aStatus;
  FValue:=RelValues[ord(aStatus)]
end;

//procedure TgdEventStatus.SetValue(aValue: string);
//begin
//  if AnsiIndexStr(aValue, RelValues)<=0 then
//    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdEventStatus)]]));
//  FStatus:=TEventStatus(AnsiIndexStr(aValue, RelValues));
//  FValue:=aValue;
//end;

{ TgdWhen }

function TgdWhen.AddToXML(Root: TXMLNode;DateFormat:TDateFormat): TXMLNode;
begin
  if (Root=nil)or isEmpty then Exit;
  Result:=Root.NodeNew(cgdTagNames[ord(egdWhen)]);
  case DateFormat of
    tdDate:Result.WriteAttributeString('startTime',FormatDateTime('yyyy-mm-dd',FstartTime));
    tdServerDate:Result.WriteAttributeString('startTime',DateTimeToServerDate(FstartTime));
  end;

  if FendTime>0 then
    Result.WriteAttributeString('endTime',DateTimeToServerDate(FendTime));
  if length(Trim(FvalueString))>0 then
    Result.WriteAttributeString('valueString',FvalueString);
end;

constructor TgdWhen.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  FendTime:=0;
  FstartTime:=0;
  FvalueString:='';
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

function TgdWhen.isEmpty: boolean;
begin
  Result:=(FendTime<=0)and(FstartTime<=0)and(length(Trim(FvalueString))=0);
end;

procedure TgdWhen.ParseXML(Node: TXMLNode);
begin
if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> ord(egdWhen) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdWhen)]]));
  try
    FendTime:=0;
    FstartTime:=0;
    FvalueString:='';
    if Node.HasAttribute('endTime') then
      FendTime:=ServerDateToDateTime(Node.ReadAttributeString('endTime'));
    FstartTime:=ServerDateToDateTime(Node.ReadAttributeString('startTime'));
    if Node.HasAttribute('valueString') then
      FvalueString:=Node.ReadAttributeString('valueString');
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdAttendeeStatus }

function TgdAttendeeStatus.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root=nil then Exit;
  Result:=Root.AddChild(cgdTagNames[ord(egdAttendeeStatus)]);
  Result.Attributes['value']:=SchemaHref+FValue;
end;

constructor TgdAttendeeStatus.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdAttendeeStatus.ParseXML(Node: IXMLNode);
begin
if Node=nil then Exit;
  if GetGDNodeType(Node.NodeName) <> ord(egdAttendeeStatus) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdAttendeeStatus)]]));
  try
    FValue := Node.Attributes['value'];
    FValue:=StringReplace(FValue,SchemaHref,'',[rfIgnoreCase]);
    FAttendeeStatus := TAttendeeStatus(AnsiIndexStr(FValue, RelValues));
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

procedure TgdAttendeeStatus.SetStatus(aStatus: TAttendeeStatus);
begin
  FAttendeeStatus:=aStatus;
  FValue:=RelValues[ord(aStatus)]
end;

//procedure TgdAttendeeStatus.SetValue(aValue: string);
//begin
//  if AnsiIndexStr(aValue, cAttendeeStatus)<=0 then
//    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdAttendeeStatus)]]));
//  FAttendeeStatus:=TAttendeeStatus(AnsiIndexStr(aValue, cAttendeeStatus));
//  FValue:=aValue;
//end;

{ TgdAttendeeType }

function TgdAttendeeType.AddToXML(Root: IXMLNode): IXMLNode;
begin
 if Root=nil then Exit;
  Result:=Root.AddChild(cgdTagNames[ord(egdAttendeeType)]);
  Result.Attributes['value']:=SchemaHref+FValue;
end;

constructor TgdAttendeeType.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdAttendeeType.ParseXML(Node: IXMLNode);
begin
  if Node=nil then Exit;
  if GetGDNodeType(Node.NodeName) <> ord(egdAttendeeType) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdAttendeeType)]]));
  try
    FValue:=Node.Attributes['value'];
    FValue:=StringReplace(FValue,SchemaHref,'',[rfIgnoreCase]);
    FAttType := TAttendeeType(AnsiIndexStr(FValue, RelValues));
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

procedure TgdAttendeeType.SetType(aStatus: TAttendeeType);
begin
  FAttType:=aStatus;
  FValue:=RelValues[ord(aStatus)]
end;

//procedure TgdAttendeeType.SetValue(aValue: string);
//begin
//  if AnsiIndexStr(aValue, cAttendeeType)<=0 then
//    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdAttendeeType)]]));
//  FAttType:=TAttendeeType(AnsiIndexStr(aValue, cAttendeeType));
//  FValue:=aValue;
//end;

{ TgdWho }

function TgdWho.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root=nil then Exit;
  Result:=Root.AddChild(cgdTagNames[ord(egdWho)]);
  if Length(Trim(FEmail))>0 then
    Result.Attributes['email']:=FEmail;
  if Length(Trim(Frel))>0 then
    Result.Attributes['rel']:=SchemaHref+RelValues[ord(FRelValue)];
  if Length(Trim(FvalueString))>0 then
    Result.Attributes['valueString']:=FvalueString;
  if FAttendeeStatus<>nil then
    FAttendeeStatus.AddToXML(Result);
  if FAttendeeType<>nil then
    FAttendeeType.AddToXML(Result);
  if FEntryLink<>nil then
    FEntryLink.AddToXML(Result);
end;

constructor TgdWho.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  FEmail:='';
//  Frel:='';
  FvalueString:='';
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdWho.ParseXML(Node: IXMLNode);
var i:integer;
    s:string;
begin
  if Node=nil then Exit;
  if GetGDNodeType(Node.NodeName) <> ord(egdWho) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdWho)]]));
  try
    if Node.Attributes['email']<>null then
      FEmail:=Node.Attributes['email'];
    if Node.Attributes['rel']<>null then
      begin
        S:=Node.Attributes['rel'];
        S:=StringReplace(S,SchemaHref,'',[rfIgnoreCase]);
        FRelValue:=TWhoRel(AnsiIndexStr(S, RelValues));
      end;
    if Node.Attributes['valueString']<>null then
      FvalueString:=Node.Attributes['valueString'];
    if Node.ChildNodes.Count>0 then
      begin
        for I := 0 to Node.ChildNodes.Count-1 do
          case GetGDNodeType(Node.ChildNodes[i].NodeName) of
            ord(egdAttendeeStatus):
              FAttendeeStatus:=TgdAttendeeStatus.Create(Node.ChildNodes[i]);
            ord(egdAttendeeType):
              FAttendeeType:=TgdAttendeeType.Create(Node.ChildNodes[i]);
            ord(egdEntryLink):
              FEntryLink:=TgdEntryLink.Create(Node.ChildNodes[i]);
          end;
      end;
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

//procedure TgdWho.SetRel(aRel: string);
//begin
//if AnsiIndexStr(aRel, cWhoRel)<=0 then
//    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdWho)]]));
//  FRelValue:=TWhoRel(AnsiIndexStr(aRel, cWhoRel));
//  Frel:=aRel;
//end;

//procedure TgdWho.SetRelValue(aRelValue: TWhoRel);
//begin
//  FRelValue:=aRelValue;
// // Frel:=cWhoRel[ord(aRelValue)]
//end;

{ TgdRecurrence }

function TgdRecurrence.AddToXML(Root: IXMLNode): IXMLNode;
begin
if Root=nil then Exit;
  Result:=Root.AddChild(cgdTagNames[ord(egdRecurrence)]);
  Result.Text:=FText.Text;
end;

constructor TgdRecurrence.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  FText:=TStringList.Create;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdRecurrence.ParseXML(Node: IXMLNode);
begin
if Node=nil then Exit;
  if GetGDNodeType(Node.NodeName) <> ord(egdRecurrence) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdRecurrence)]]));
  try
    FText.Text:=Node.Text;
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgdReminder }

function TgdReminder.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root=nil then Exit;
  Result:=Root.AddChild(cgdTagNames[ord(egdReminder)]);
  Result.Attributes['method']:=cMethods[ord(Fmethod)];
  case FPeriod of
    tpDays: Result.Attributes['days']:=FPeriodValue;
    tpHours: Result.Attributes['hours']:=FPeriodValue;
    tpMinutes: Result.Attributes['minutes']:=FPeriodValue;
  end;
  if FabsoluteTime>0 then
    Result.Attributes['absoluteTime']:=DateTimeToServerDate(FabsoluteTime)
end;

constructor TgdReminder.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  FabsoluteTime:=0;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdReminder.ParseXML(Node: IXMLNode);
begin
if Node=nil then Exit;
  if GetGDNodeType(Node.NodeName) <> ord(egdReminder) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdReminder)]]));
  try
    if (Node.Attributes['absoluteTime']<>null)and(Length(Trim(Node.Attributes['absoluteTime']))>0) then
      FabsoluteTime:=ServerDateToDateTime(Node.Attributes['absoluteTime']);
    if Node.Attributes['method']<>null then
       Fmethod:=TMethod(AnsiIndexStr(Node.Attributes['method'], cMethods));
    if Node.Attributes['days']<>null then
       FPeriod:=tpDays;
    if Node.Attributes['hours']<>null then
       FPeriod:=tpHours;
    if Node.Attributes['minutes']<>null then
       FPeriod:=tpMinutes;
    case FPeriod of
      tpDays: FPeriodValue:=Node.Attributes['days'];
      tpHours: FPeriodValue:=Node.Attributes['hours'];
      tpMinutes: FPeriodValue:=Node.Attributes['minutes'];
    end;

  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgdTransparency }

function TgdTransparency.AddToXML(Root: IXMLNode): IXMLNode;
begin
if Root=nil then Exit;
Result:=Root.AddChild(cgdTagNames[ord(egdTransparency)]);
Result.Attributes['value']:=SchemaHref+FValue;
end;

constructor TgdTransparency.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdTransparency.ParseXML(Node: IXMLNode);
begin
 if Node=nil then Exit;
  if GetGDNodeType(Node.NodeName) <> ord(egdTransparency) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdTransparency)]]));
  try
    FValue := Node.Attributes['value'];
    FValue:=StringReplace(FValue,SchemaHref,'',[rfIgnoreCase]);
    FTransparency := TTransparency(AnsiIndexStr(FValue, RelValues));
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

procedure TgdTransparency.SetTransp(aTransp: TTransparency);
begin
  FTransparency:=aTransp;
  FValue:=RelValues[ord(aTransp)]
end;

//procedure TgdTransparency.SetValue(aValue: string);
//begin
//if AnsiIndexStr(aValue, cTransparency)<=0 then
//    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdTransparency)]]));
//  FTransparency:=TTransparency(AnsiIndexStr(aValue, cTransparency));
//  FValue:=aValue;
//end;

{ TgdVisibility }

function TgdVisibility.AddToXML(Root: IXMLNode): IXMLNode;
begin
if Root=nil then Exit;
Result:=Root.AddChild(cgdTagNames[ord(egdVisibility)]);
Result.Attributes['value']:=SchemaHref+FValue;
end;

constructor TgdVisibility.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdVisibility.ParseXML(Node: IXMLNode);
begin
 if Node=nil then Exit;
  if GetGDNodeType(Node.NodeName) <> ord(egdVisibility) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdVisibility)]]));
  try
    FValue := Node.Attributes['value'];
    FValue:=StringReplace(FValue,SchemaHref,'',[rfIgnoreCase]);
    FVisible := TVisibility(AnsiIndexStr(FValue, RelValues));
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

//procedure TgdVisibility.SetValue(aValue: string);
//begin
//if AnsiIndexStr(aValue, RelValues)<=0 then
//    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdVisibility)]]));
//  FVisible:=TVisibility(AnsiIndexStr(aValue, RelValues));
//  FValue:=aValue;
//end;

procedure TgdVisibility.SetVisible(aVisible: TVisibility);
begin
  FVisible:=aVisible;
  FValue:=RelValues[ord(aVisible)]
end;

{ TgdOrganization }

function TgdOrganization.AddToXML(Root: TXMLNode): TXmlNode;
begin
if (Root=nil)or
((Trim(FRel)='')and
 (Trim(FLabel)='')and
 (Trim(ForgName.Value)='')and
 (Trim(ForgTitle.Value)='')) then Exit;


Result:=Root.NodeNew(cGDTagNames[ord(egdOrganization)]);
if Trim(FRel)<>'' then
  Result.WriteAttributeString('rel',FRel);
if Trim(FLabel)<>'' then
  Result.WriteAttributeString('label',FLabel);
if FPrimary then
  Result.WriteAttributeBool('primary',Fprimary);
if Trim(ForgName.Value)<>'' then
  ForgName.AddToXML(Result);
if Trim(ForgTitle.Value)<>'' then
  ForgTitle.AddToXML(Result);
end;

constructor TgdOrganization.Create(ByNode: TXMLNode);
begin
  inherited Create;
   ForgName:=TgdOrgName.Create;
   ForgTitle:=TgdOrgTitle.Create;
   FLabel:='';
   Frel:='';
  if ByNode<>nil then
    ParseXML(ByNode);

end;

function TgdOrganization.IsEmpty: boolean;
begin
Result:=(Length(Trim(FLabel))=0)and(Length(Trim(Frel))=0)
end;

procedure TgdOrganization.ParseXML(const Node: TXmlNode);
var i:integer;
begin
if (Node=nil)or IsEmpty then Exit;
  if GetGDNodeType(Node.Name) <> ord(egdOrganization) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdOrganization)]]));
  try
    Frel:=Node.ReadAttributeString('rel');
    if Node.HasAttribute('primary') then
      Fprimary:=Node.ReadAttributeBool('primary');
    if Node.HasAttribute('label') then
      FLabel:=Node.ReadAttributeString('label');
    for i:=0 to Node.NodeCount-1 do
      begin
        if LowerCase(Node.Nodes[i].Name)=LowerCase(cGDTagNames[ord(egdOrgName)]) then
          ForgName:=TgdOrgName.Create(Node.Nodes[i])
        else
          if LowerCase(Node.Nodes[i].Name)=LowerCase(cGDTagNames[ord(egdOrgTitle)]) then
            ForgTitle:=TgdOrgTitle.Create(Node.Nodes[i]);
      end;
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdEmailStruct }

function TgdEmail.AddToXML(Root: TXMLNode): TXmlNode;
begin
  if Root=nil then Exit;
  Result:=Root.NodeNew(cGDTagNames[ord(egdEmail)]);
  if Trim(FRel)<>'' then
    Result.WriteAttributeString('rel',FRel);
  if Trim(FLabel)<>'' then
    Result.WriteAttributeString('label',FLabel);
  if Trim(FLabel)<>'' then
    Result.WriteAttributeString('displayName',FDisplayName);
  if FPrimary then
    Result.WriteAttributeBool('primary',FPrimary);
  Result.WriteAttributeString('address',FAddress);
end;

constructor TgdEmail.Create(ByNode: TXMLNode);
begin
  inherited Create;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

procedure TgdEmail.ParseXML(const Node: TXmlNode);
begin
  if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> ord(egdEmail) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdEmail)]]));
  try
    Frel:=Node.ReadAttributeString('rel');
    if Node.HasAttribute('primary') then
      Fprimary:=Node.ReadAttributeBool('primary');
    if Node.HasAttribute('label') then
      FLabel:=Node.ReadAttributeString('label');
    if Node.HasAttribute('displayName') then
      FDisplayName:=Node.ReadAttributeString('displayName');
    FAddress:=Node.ReadAttributeString('address');
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.Name]));
  end;
end;

procedure TgdEmail.SetEmailType(aType: TTypeElement);
begin
FEmailType:=aType;
SetRel(RelValues[ord(aType)]);
end;

procedure TgdEmail.SetRel(const aRel: string);
begin
  if AnsiIndexStr(aRel,RelValues)<0 then
   raise Exception.Create
      (Format(rcErrWriteNode, [cGDTagNames[ord(egdEmail)]])+' '+Format(rcWrongAttr,['rel']));
  FRel:=SchemaHref+aRel;
end;

{ TgdNameStruct }

function TgdName.AddToXML(Root: TXMLNode): TXmlNode;
begin
  if (Root=nil)or IsEmpty then Exit;

  Result:=Root.NodeNew(cGDTagNames[ord(egdName)]);
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

constructor TgdName.Create(ByNode: TXMLNode);
begin
  inherited Create;
  FGivenName:=TgdGivenName.Create();
  FAdditionalName:=TgdAdditionalNameStruct.Create();
  FFamilyName:=TgdFamilyName.Create();
  FNamePrefix:=TgdNamePrefix.Create();
  FNameSuffix:=TgdNameSuffix.Create();
  FFullName:=TgdFullName.Create();
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
  if GetGDNodeType(Node.Name) <> ord(egdName) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdName)]]));
  try
    for i:=0 to Node.NodeCount-1 do
      begin
        case GetGDNodeType(Node.Nodes[i].Name) of
          ord(egdGivenName):FGivenName.ParseXML(Node.Nodes[i]);
          ord(egdAdditionalName):FAdditionalName.ParseXML(Node.Nodes[i]);
          ord(egdFamilyName):FFamilyName.ParseXML(Node.Nodes[i]);
          ord(egdNamePrefix):FNamePrefix.ParseXML(Node.Nodes[i]);
          ord(egdNameSuffix):FNameSuffix.ParseXML(Node.Nodes[i]);
          ord(egdFullName):FFullName.ParseXML(Node.Nodes[i]);
        end;
      end;
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdPhoneNumber }

function TgdPhoneNumber.AddToXML(Root: TXMLNode): TXmlNode;
begin
  if Root=nil then Exit;
  Result:=Root.NodeNew(cGDTagNames[ord(egdPhoneNumber)]);
  Result.WriteAttributeString('rel',SchemaHref+RelValues[ord(FPhoneType)]);
  Result.ValueAsString:=FValue;
  if Trim(FLabel)<>'' then
    Result.WriteAttributeString('label',FLabel);
  if Trim(FUri)<>'' then
    Result.WriteAttributeString('uri',FUri);
  if FPrimary then
    Result.WriteAttributeBool('primary',FPrimary);
end;

constructor TgdPhoneNumber.Create(ByNode: TXMLNode);
begin
  inherited Create;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

procedure TgdPhoneNumber.ParseXML(const Node: TXmlNode);
var s:string;
begin
  if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> ord(egdPhoneNumber) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdPhoneNumber)]]));
  try
    s:=Node.ReadAttributeString('rel');
    s:=StringReplace(s,SchemaHref,'',[rfIgnoreCase]);
    if AnsiIndexStr(s,RelValues)>-1 then
      FPhoneType:=TPhonesRel(AnsiIndexStr(s,RelValues))
    else
      FPhoneType:=tpOther;
    if Node.HasAttribute('primary') then
      Fprimary:=Node.ReadAttributeBool('primary');
    if Node.HasAttribute('label') then
      FLabel:=Node.ReadAttributeString('label');
    if Node.HasAttribute('uri') then
      FUri:=Node.ReadAttributeString('uri');
    FValue:=Node.ValueAsString;
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.Name]));
  end;
end;

//procedure TgdPhoneNumber.SetRel(aPhoneRel: TPhonesRel);
//begin
//  FPhoneType:=aPhoneRel;
//end;

{ TgdCountry }

function TgdCountry.AddToXML(Root: TXMLNode): TXMLNode;
begin
 if Root=nil then Exit;
 Result:=Root.NodeNew(cGDTagNames[ord(egdCountry)]);
 if Trim(FCode)<>'' then
   Result.WriteAttributeString('code',FCode);
 Result.ValueAsString:=FValue;
end;

constructor TgdCountry.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

procedure TgdCountry.ParseXML(Node: TXMLNode);
begin
  if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> ord(egdCountry) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdCountry)]]));
  try
    FCode:=Node.ReadAttributeString('rel');
    FValue:=Node.ValueAsString;
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.Name]));
  end;
end;

{ TgdStructuredPostalAddressStruct }

function TgdStructuredPostalAddress.AddToXML(Root: TXMLNode): TXMLNode;
begin
  if Root=nil then Exit;
  Result:=Root.NodeNew(cGDTagNames[ord(egdStructuredPostalAddress)]);
  if Trim(FRel)<>'' then
     Result.WriteAttributeString('rel',FRel);
  if Trim(FMailClass)<>'' then
     Result.WriteAttributeString('mailClass',FMailClass);
  if Trim(Flabel)<>'' then
     Result.WriteAttributeString('label',Flabel);
  if Trim(FUsage)<>'' then
     Result.WriteAttributeString('Usage',FUsage);
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
  if FCoutry<>nil then
     FCoutry.AddToXML(Result);
  if FFormattedAddress<>nil then
     FFormattedAddress.AddToXML(Result);
end;

constructor TgdStructuredPostalAddress.Create(const ByNode: TXMLNode);
begin
 inherited Create;
 if ByNode<>nil then
   ParseXML(ByNode);
end;

procedure TgdStructuredPostalAddress.ParseXML(Node: TXMLNode);
var i:integer;
begin
if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> ord(egdStructuredPostalAddress) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdStructuredPostalAddress)]]));
  try
    FRel:=Node.ReadAttributeString('rel');
    FMailClass:=Node.ReadAttributeString('mailClass');
    Flabel:=Node.ReadAttributeString('label');
    if Node.HasAttribute('primaty') then
      Fprimary:=Node.ReadAttributeBool('primary');
    FUsage:=Node.ReadAttributeString('Usage');
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.Name]));
  end;
  for I := 0 to Node.NodeCount - 1 do
    begin
      case GetGDNodeType(Node.Nodes[i].Name) of
        ord(egdAgent):FAgent:=TgdAgent.Create(Node.Nodes[i]);
        ord(egdHousename):FHousename:=TgdHousename.Create(Node.Nodes[i]);
        ord(egdStreet):FStreet:=TgdStreet.Create(Node.Nodes[i]);
        ord(egdPobox):FPobox:=TgdPobox.Create(Node.Nodes[i]);
        ord(egdNeighborhood):FNeighborhood:=TgdNeighborhood.Create(Node.Nodes[i]);
        ord(egdCity):FCity:=TgdCity.Create(Node.Nodes[i]);
        ord(egdSubregion):FSubregion:=TgdSubregion.Create(Node.Nodes[i]);
        ord(egdRegion):FRegion:=TgdRegion.Create(Node.Nodes[i]);
        ord(egdPostcode):FPostcode:=TgdPostcode.Create(Node.Nodes[i]);
        ord(egdCountry):FCoutry:=TgdCountry.Create(Node.Nodes[i]);
        ord(egdFormattedAddress):FFormattedAddress:=TgdFormattedAddress.Create(Node.Nodes[i]);
      end;
    end;
end;

{ TgdIm }

function TgdIm.AddToXML(Root: TXMLNode): TXmlNode;
begin
  if Root=nil then Exit;
  Result:=Root.NodeNew(cGDTagNames[ord(egdIm)]);

  Result.WriteAttributeString('rel',SchemaHref+RelValues[ord(FIMType)]);
  Result.WriteAttributeString('address',FAddress);
  Result.WriteAttributeString('label',FLabel);
  Result.WriteAttributeString('protocol',SchemaHref+ProtocolValues[ord(FIMProtocol)]);
  if FPrimary then
    Result.WriteAttributeBool('primary',FPrimary);
end;

constructor TgdIm.Create(ByNode: TXMLNode);
begin
  inherited Create;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

procedure TgdIm.ParseXML(const Node: TXmlNode);
var s:string;
begin
if Node=nil then Exit;
  if GetGDNodeType(Node.Name) <> ord(egdIm) then
    raise Exception.Create(Format(rcErrCompNodes,[cGDTagNames[ord(egdIm)]]));
  try
    s:=Node.ReadAttributeString('rel');
    s:=StringReplace(s,SchemaHref,'',[rfIgnoreCase]);
    FIMType:=TImtype(AnsiIndexStr(s,RelValues));
    FLabel:=Node.ReadAttributeString('label');
    FAddress:=Node.ReadAttributeString('address');
    s:=Node.ReadAttributeString('protocol');
    s:=StringReplace(s,SchemaHref,'',[rfIgnoreCase]);
    if AnsiIndexStr(s,ProtocolValues)>-1 then
      FIMProtocol:=TIMProtocol(AnsiIndexStr(s,ProtocolValues))
    else
      FIMProtocol:=tiGOOGLE_TALK;
    if Node.HasAttribute('primary') then
      FPrimary:=Node.ReadAttributeBool('primary');
  except
     raise Exception.Create(Format(rcErrPrepareNode, [Node.Name]));
  end;
end;

end.
>>>>>>> remotes/origin/NMD
