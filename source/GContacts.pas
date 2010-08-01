{ unit GContacts

  Модуль содержит классы и методы для работы с Google Contacts API.

  Вы можете использовать этот модуль для получения чтения и редактирования своих
  контактов в GMail.

  Основной компонент для работы с контаками - TGoogleContact.

  Автор: Vlad. (vlad383@gmail.com)
  Дата: 16 Июля 2010
  Версия: см. ниже
  Copyright (c) 2009-2010 WebDelphi.ru

  ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ», БЕЗ ЛЮБОГО ВИДА
  ГАРАНТИЙ, ЯВНО ВЫРАЖЕННЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ, НО НЕ ОГРАНИЧИВАЯСЬ
  ГАРАНТИЯМИ ТОВАРНОЙ ПРИГОДНОСТИ, СООТВЕТСТВИЯ ПО ЕГО КОНКРЕТНОМУ НАЗНАЧЕНИЮ И
  НЕНАРУШЕНИЯ ПРАВ. НИ В КАКОМ СЛУЧАЕ АВТОРЫ ИЛИ ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ
  ОТВЕТСТВЕННОСТИ ПО ИСКАМ О ВОЗМЕЩЕНИИ УЩЕРБА, УБЫТКОВ ИЛИ ДРУГИХ ТРЕБОВАНИЙ ПО
  ДЕЙСТВУЮЩИМ КОНТРАКТАМ, ДЕЛИКТАМ ИЛИ ИНОМУ, ВОЗНИКШИМ ИЗ, ИМЕЮЩИМ ПРИЧИНОЙ ИЛИ
  СВЯЗАННЫМ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ ИЛИ ИСПОЛЬЗОВАНИЕМ ПРОГРАММНОГО
  ОБЕСПЕЧЕНИЯ ИЛИ ИНЫМИ ДЕЙСТВИЯМИ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ.

  This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
  ANY KIND, either express or implied.

  Последние обновления модуля можно найти в репозитории по адресу:
  http://github.com/googleapi
}

unit GContacts;

interface

uses
  NativeXML, strUtils, httpsend, Classes, SysUtils,
  GDataCommon, Generics.Collections, Dialogs, jpeg, Graphics, typinfo,
  IOUtils, uLanguage, blcksock, Windows, GConsts;

const
  cpGContactsVersion = '0.1';


type
  ECPException = class(Exception)
  public
    constructor CreateFromStream(const Document: TStream);
end;

type
  {Элемент парсинга}
  TParseElement = (T_Group {группа контактов},
                   T_Contact {группа контактов});
  {Событие <b>TOnRetriveXML</b> возникает каждый раз, когда компонент или класс
  обращается на сервер для получения XML-документа.
  <b>FromURL</b> содержит URL на который отправляется GET-запрос}
  TOnRetriveXML = procedure(const FromURL: string {URL на который отправляется HTTP-запрос для получения документа}) of object;
  {Событие <b>TOnBeginParse</b> возникает каждый раз, когда компонент или класс
  готов начать парсинг элемента в XML-документе.
  Общее количество однотипных элементов определяется по значению узла
  <b>openSearch:totalResults</b> в первом возвращенном с сервера документе.}
  TOnBeginParse = procedure(const What: TParseElement{элемент парсинга (группа или контакт) см. TParseElement};
                                  Total:integer{общее количество элементов доступных для парсинга};
                                  Number: integer{текущий номер элементапарсинга})
    of object;
  {Событие <b>TOnEndParse</b> возникает каждый раз, когда компонент или класс
  заканчивает парсинг элемента в XML-документе.}
  TOnEndParse = procedure(const What: TParseElement;{элемент парсинга (группа или контакт) см. TParseElement}
                                      Element: TObject{элемент, полученный в результате парсинга.
  Если был проведен парсинг группы, то Element имеет тип TContactGroup,
  если контакта, то - TContact})
    of object;
  {Событие <b>TOnReadData</b> возникает каждый раз, когда компонент или класс
  считывает данные из Сети.
  <b>TotalBytes</b> содержит информацию по размеру получаемого документа, включая размер
  всех заголовков, возвращаемых сервером}
  TOnReadData = procedure(const TotalBytes:int64 {содержит значение объема данных, который должен быть получен, байт};
                                ReadBytes: int64 {содержит количество байт информации полученных из Сети на текущий момент}) of object;


{Перечислитель, содержащий все типы узлов, относящихся к Google Contacts API
 и обрабатываемых с помощью классов модуля}
type
  TcpTagEnum = (cp_billingInformation {тип узла gContact:billingInformation},
                cp_birthday {тип узла gContact:birthday},
                cp_calendarLink {тип узла gContact:calendarLink},
                cp_directoryServer {тип узла gContact:directoryServer},
                cp_event {тип узла gContact:event},
                cp_externalId {тип узла gContact:externalId},
                cp_gender {тип узла gContact:gender},
                cp_groupMembershipInfo {тип узла gContact:groupMembershipInfo},
                cp_hobby {тип узла gContact:hobby},
                cp_initials {тип узла gContact:initials},
                cp_jot {тип узла gContact:jot},
                cp_language {тип узла gContact:language},
                cp_maidenName {тип узла gContact:maidenName},
                cp_mileage {тип узла gContact:mileage},
                cp_nickname {тип узла gContact:nickname},
                cp_occupation {тип узла gContact:occupation},
                cp_priority {тип узла gContact:priority},
                cp_relation {тип узла gContact:relation},
                cp_sensitivity {тип узла gContact:sensitivity},
                cp_shortName {тип узла gContact:shortName},
                cp_subject {тип узла gContact:subject},
                cp_userDefinedField {тип узла gContact:userDefinedField},
                cp_website {тип узла gContact:website},
                cp_systemGroup {тип узла gContact:systemGroup},
                cp_None {используется в случае, если тип узла не определен});

type
  {Класс, описывающий узел <b>gContact:billingInformation</b>.
   Этот узел используется для описания платежной информации контакта.
   Элемент <b>gContact:billingInformation</b> не может быть повторен в рамках
   описания одного контакта.
   Вся информация содержится в текстовой части узла.
   Узел <b>gContact:billingInformation</b> может отсутствовать в XML-документе}
  TcpBillingInformation = class(TTextTag);

  {Класс, описывающий узел <b>gContact:directoryServer</b>.
   Этот узел используется для указания сервера катологов, связанного с контактом.
   Элемент <b>gContact:directoryServer</b> может быть повторен в рамках описания
   одного контакта.
   Вся информация содержится в текстовой части узла.
   Узел <b>gContact:directoryServer</b> может отсутствовать в XML-документе}
  TcpDirectoryServer = class(TTextTag);

  {Класс, описывающий узел <b>gContact:hobby</b>.
   Этот узел используется для указания хобби контакта.
   Элемент <b>gContact:hobby</b> может быть повторен в рамках описания
   одного контакта.
   Вся информация о хобби содержится в текстовой части узла.
   Узел <b>gContact:hobby</b> может отсутствовать в XML-документе}
  TcpHobby = class(TTextTag);

  {Класс, описывающий узел <b>gContact:initials</b>.
   Этот узел используется для указания инициалов контакта.
   Элемент <b>gContact:initials</b> не может быть повторен в рамках описания
   одного контакта.
   Вся информация об инициалах содержится в текстовой части узла.
   Узел <b>gContact:initials</b> может отсутствовать в XML-документе}
  TcpInitials = class(TTextTag);

  {Класс, описывающий узел <b>gContact:shortName</b>.
   Этот узел используется для указания сокращенного имени контакта (например,
   для имени Владислав коротким является - Влад).
   Элемент <b>gContact:shortName</b> не может быть повторен в рамках описания
   одного контакта.
   Вся информация о коротком имени содержится в текстовой части узла.
   Узел <b>gContact:shortName</b> может отсутствовать в XML-документе}
  TcpShortName = class(TTextTag);

  {Класс, описывающий узел <b>gContact:subject</b>.
   Этот узел используется для указания дополнительной информации о контакте,
   например, области деятельности в которой пользователь пересекается с контактом.
   Элемент <b>gContact:subject</b> не может быть повторен в рамках описания
   одного контакта.
   Вся дополнительная информация о контакте содержится в текстовой части узла.
   Узел <b>gContact:subject</b> может отсутствовать в XML-документе}
  TcpSubject = class(TTextTag);

  {Класс, описывающий узел <b>gContact:maidenName</b>.
   Этот узел используется для указания девичьей фамилии контакта (для контактов женского пола).
   Элемент <b>gContact:maidenName</b> не может быть повторен в рамках описания
   одного контакта.
   Вся информация о девичьей фамилии содержится в текстовой части узла.
   Узел <b>gContact:maidenName</b> может отсутствовать в XML-документе}
  TcpMaidenName = class(TTextTag);

  {Класс, описывающий узел <b>gContact:mileage</b>.
   Этот узел используется для указания расстояния, отделяющего пользователя от контакта.
   Элемент <b>gContact:mileage</b> не может быть повторен в рамках описания
   одного контакта.
   Вся информация о расстоянии содержится в текстовой части узла. Текст,
   содержащий информацию о расстоянии может содержать подстроки размерности,
   например "км.". Размерности никак не интерпретируются сервером Google.
   Узел <b>gContact:mileage</b> может отсутствовать в XML-документе}
  TcpMileage = class(TTextTag);

  {Класс, описывающий узел <b>gContact:nickname</b>.
   Этот узел используется для ника (клички) контакта.
   Элемент <b>gContact:nickname</b> не может быть повторен в рамках описания
   одного контакта.
   Вся информация о нике содержится в текстовой части узла.
   Узел <b>gContact:nickname</b> может отсутствовать в XML-документе}
  TcpNickname = class(TTextTag);

  {Класс, описывающий узел <b>gContact:occupation</b>.
   Этот узел используется для описания рода занятий/профессии контакта.
   Элемент <b>gContact:occupation</b> не может быть повторен в рамках описания
   одного контакта.
   Вся информация о профессии содержится в текстовой части узла.
   Узел <b>gContact:occupation</b> может отсутствовать в XML-документе}
  TcpOccupation = class(TTextTag);


{Класс, описывающий узел <b>gContact:birthday</b>.
   Этот узел используется для указания даты рождения контакта.
   Элемент <b>gContact:birthday</b> не может быть повторен в рамках описания
   одного контакта.
   Вся информация о дате рождения содержится в аттрибуте "when"  узла. Дата может
   быть представлена как в полном формате "YYYY-MM-DD", так и в укороченном "--MM-DD"
   Узел <b>gContact:birthday</b> может отсутствовать в XML-документе}
type
  TcpBirthday = class
  private
    FDate: TDate; //дата рождения контакта
    FShortFormat: boolean; //если True, то в указании даты рождения используется укороченный формат даты
    procedure SetDate(aDate: TDate);
    function GetServerDate: string;
  public
   {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode{XML-узел на основании которого будет создан экземпляр класса} = nil);
    {Очищает поля класса от всех данных. Поле FShortFormat получает значение <b>false</b>}
    procedure Clear;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    поле FDate<=0}
    function IsEmpty: boolean;
    { Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode{узел на основании которого будет проходить заполнение полей объекта});
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;
    {Указывает используется ли в описании даты рождения контакта укороченный формат датты (без года рождения)}
    property ShotrFormat: boolean read FShortFormat write FShortFormat;
    {Дата рождения контакта. Если используется укороченный формат даты, то в Date указывается текущий год}
    property Date: TDate read FDate write SetDate;
    {Строка используемая для указания даты рождения контакта в XML-документе.
    Фактически - это значение атрибута <b>when</b> узла <b>gContact:birthday</b>}
    property ServerDate: string read GetServerDate;
  end;

{Перечислитель, используемый для определения параметра Rel узла
<b>gContact:calendarLink</b>}
type
  TCalendarRel = (tc_none {значение парамета не определено},
                  tc_work {определяет ссылку на рабочий календарь контакта},
                  tc_home {определяет ссылку на календарь контакта, используемого для домашних записей},
                  tc_free_busy {определяет ссылку на календарь контака в котором указана информация о занятости});


{Класс, описывающий узел <b>gContact:calendarLink</b>.
   Этот узел используется для указания ссылок на календари контакта.
   Тип календаря, указанного в ссылке, определяется атрибутом Rel XML-узла
   Элемент <b>gContact:calendarLink</b> может быть повторен в рамках описания
   одного контакта, но только один календарь пользователя может помечаться как основной
   (иметь аттрибут <b>primary=true</b>).
   Узел <b>gContact:calendarLink</b> может отсутствовать в XML-документе}
  TcpCalendarLink = class
  private
    FRel: TCalendarRel;
    FLabel: string;
    FPrimary: boolean;
    FHref: string;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    { Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {Возвращает строку на языке пользователя, определяющую тип календаря в ссылке

    * Пример использования *
    <code>
       ...
       property Rel: TCalendarRel read FRel write FRel;
       ...
       S:string;

       Rel:=tc_work;
       S:=RelToString;
       ----------
       S='Рабочий календарь'
    </code>}
    function RelToString: string;
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode {родительский узел для вновь создаваемого узла}): TXmlNode;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    property Rel: TCalendarRel read FRel write FRel;//атрибут Rel узла. Определяет тип ссылки на календарь
    property Primary: boolean read FPrimary write FPrimary;//определяет является ли календарь основным для контакта
    property Href: string read FHref write FHref;//ссылка на календарь контакта
  end;


{Перечислитель, используемый для определения параметра Rel узла
<b>gContact:event</b>}
  TEventRel = (teNone {значение парамета не определено - при отправке информации на сервер,
                       содержащей такой XML-узел закончится неудачей, если не будет определен атрибут <b>label</b>},
               teAnniversary {значение определяет какой-либо юбилей контакта},
               teOther {значение определяет другие важные события контакта});


{Класс, описывающий узел <b>gContact:event</b>.
   Этот узел используется для указания каких-либо значимых дат для контакта.
   Тип события, указанного в XML-элементе, определяется атрибутом Rel.
   Элемент <b>gContact:event</b> может быть повторен в рамках описания
   одного контакта.
   Узел <b>gContact:event</b> может отсутствовать в XML-документе}
  TcpEvent = class
  private
    FEventType: TEventRel;
    FLabel: string;
    FWhen: TgdWhen;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    { Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {Возвращает строку на языке пользователя, определяющую тип календаря в ссылке

    * Пример использования *
    <code>
       ...
       property EventType: TEventRel read FEventType write FEventType;
       ...
       S:string;

       Rel:=teAnniversary;
       S:=RelToString;
       ----------
       S='Юбилей'
    </code>}
    function RelToString: string;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;

    property EventType: TEventRel read FEventType write FEventType;//тип события, указанного в элементе
    property Labl: string read FLabel write FLabel;//тектсовая метка, определяющая событие, если параметр Rel XML-узла имеет значение <b>Other</b>
    property When: TgdWhen read FWhen write FWhen; //определет дату наступления события
  end;


{Перечислитель, используемый для определения параметра Rel узла
<b>gContact:externalId</b>}
type
  TExternalIdType = (tiNone {значение не определено},
                     tiAccount {указан ID аккаунта},
                     tiCustomer {указан ID клиента какой-либо внешней сети},
                     tiNetwork {указан сетевой идентификатор в какой-либо сети},
                     tiOrganization {указан ID организации в которой работает контакт});

{Класс, описывающий узел <b>gContact:externalId</b>.
   Этот узел используется для указания каких-либо идентификаторов внешних систем в которых участвует контакт.
   Тип ID, указанного в XML-элементе, определяется атрибутом Rel.
   Элемент <b>gContact:externalId</b> может быть повторен в рамках описания
   одного контакта.
   Узел <b>gContact:externalId</b> может отсутствовать в XML-документе}
  TcpExternalId = class
  private
    FRel: TExternalIdType;
    FLabel: string;
    FValue: string;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    { Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {Возвращает строку на языке пользователя, определяющую тип календаря в ссылке

    * Пример использования *
    <code>
       ...
       property Rel: TExternalIdType read FRel write FRel;
       ...
       S:string;

       Rel:=tiAccount;
       S:=RelToString;
       ----------
       S='ID аккаунта'
    </code>}
    function RelToString: string;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;

    property Rel: TExternalIdType read FRel write FRel;//определяет тип ID
    property Labl: string read FLabel write FLabel;//текстовая метка, определяющая указанный ID
    property Value: string read FValue write FValue;//значение ID
  end;


{Перечислитель, используемый для определения значения узла
<b>gContact:gender</b>}
type
  TGenderType = (none {пол контакта не указан},
                 male {мужской},
                 female{женский});

{Класс, описывающий узел <b>gContact:gender</b>.
   Этот узел используется для указания пола контакта.
   Пол указывается в значении в XML-элемента.
   Элемент <b>gContact:gender</b> не может быть повторен в рамках описания
   одного контакта.
   Узел <b>gContact:gender</b> может отсутствовать в XML-документе}
  TcpGender = class
  private
    FValue: TGenderType;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {Возвращает строку на языке пользователя, определяющую тип календаря в ссылке

    * Пример использования *
    <code>
       ...
       property Value: TGenderType read FValue write FValue;
       ...
       S:string;

       Rel:=male;
       S:=ValueToString;
       ----------
       S='мужской'
    </code>}
    function ValueToString: string;
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;

    property Value: TGenderType read FValue write FValue;//пол контакта
  end;


{Класс, описывающий узел <b>gContact:groupMembershipInfo</b>.
   Этот узел используется для указания того в каких группах содержится контакт.
   Группа указывается в виде строки, содержащей URL группы в адресной книге.
   Элемент <b>gContact:groupMembershipInfo</b> может быть повторен в рамках описания
   одного контакта.
   Узел <b>gContact:groupMembershipInfo</b> обязательно присутствует в XML-документе}
type
  TcpGroupMembershipInfo = class
  private
    FDeleted: boolean;
    FHref: string;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;

    property Href: string read FHref write FHref;//URL группы контактов
    property Deleted: boolean read FDeleted write FDeleted;//значение <b>true</b> указывает на то, что контакт был удален не позднее, чем 30 дней назад
  end;

{Перечислитель, используемый для определения значения атрибута rel узла
<b>gContact:jot</b>}
type
  TJotRel = (TjNone,
             Tjhome,
             Tjwork,
             Tjother,
             Tjkeywords,
             Tjuser );

{Класс, описывающий узел <b>gContact:jot</b>.
   Этот узел используется для хранения произвольной информации о контакте.
   Каждый фрагмент информации обязательно должен иметь свой тип, описываемый в атрибуте rel
   (см. также значения перечислителя TJotRel)
   Фрагменты информации храняться в значении XML-узла.
   Элемент <b>gContact:jot</b> может быть повторен в рамках описания одного контакта.
   Узел <b>gContact:jot</b> может отсутствовать в XML-документе}
  TcpJot = class
  private
    FRel: TJotRel;
    FText: string;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {Возвращает строку на языке пользователя, определяющую тип календаря в ссылке

    * Пример использования *
    <code>
       ...
       property Rel: TJotRel read FRel write FRel;
       ...
       S:string;

       Rel:=Tjkeywords;
       S:=RelToString;
       ----------
       S='Ключевые слова'
    </code>}
    function RelToString: string;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
     {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;
    property Rel: TJotRel read FRel write FRel;//значение атрибута Rel
    property Text: string read FText write FText;//фрагмент информации о контакте, записанный в XML-узле
  end;


{Класс, описывающий узел <b>gContact:language</b>.
   Этот узел используется для хранения информации о предпочитаемом языке контакта.
   В атрибуте <b>code</b> указывается код языка согласно спецификации IETF BCP 47. Если код определен не верно, то
   сервер вернет ошибку.
   Произвольное описание языка задается в атрибуте <b>label</b> узла. Если определено значение code, то label обязателен к заполнению.
   Элемент <b>gContact:language</b> может быть повторен в рамках описания одного контакта.
   Узел <b>gContact:language</b> может отсутствовать в XML-документе}
type
  TcpLanguage = class
  private
    Fcode: string;
    FLabel: string;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;
    property Code: string read Fcode write Fcode;//код языка согласно спецификации IETF BCP 47
    property Labl: string read FLabel write FLabel;//произвольная строка определяющая язык пользователя
  end;


{Перечислитель, используемый для определения значения атрибута rel узла
<b>gContact:priority</b>}
type
  TPriotityRel = (TpNone   {приоритет не определен},
                  Tplow    {низкий приоритет контакта},
                  Tpnormal {нормальный приоритет контакта},
                  Tphigh   {высокий приоритет контакта});

  {Класс, описывающий узел <b>gContact:priority</b>.
   С помощью этого узла контакты можно разделить по трём категориям важности (см. описание перечислителя TPriotityRel).
   Важность контакта определяется в атрибуте <b>rel</b> XML-узла.
   Элемент <b>gContact:priority</b> не может повторяться в рамках описания одного контакта.
   Узел <b>gContact:priority</b> может отсутствовать в XML-документе}
  TcpPriority = class
  private
    FRel: TPriotityRel;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {Возвращает строку на языке пользователя, определяющую тип календаря в ссылке

    * Пример использования *
    <code>
       ...
       property Rel: TPriotityRel read FRel write FRel;
       ...
       S:string;

       Rel:=Tplow;
       S:=RelToString;
       ----------
       S='Низкий приоритет'
    </code>}
    function RelToString: string;
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;
    property Rel: TPriotityRel read FRel write FRel;//приоритет пользователя (см. описание перечислителя TPriotityRel)
  end;


{Перечислитель, используемый для определения значения атрибута rel узла
<b>gContact:relation</b>}
type
    TRelationType = (tr_None {отношение к контаку не указано},
                     tr_assistant {указанное лицо является помощником},
                     tr_brother {указанное лицо является братом},
                     tr_child {указанное лицо является ребенком},
                     tr_domestic_partner {указанное лицо является соседом},
                     tr_father {указанное лицо является отцом},
                     tr_friend {указанное лицо является другом},
                     tr_manager {указанное лицо является управляющим (начальником)},
                     tr_mother {указанное лицо является матерью},
                     tr_parent {указанное лицо является родителем},
                     tr_partner {указанное лицо является партнером},
                     tr_referred_by {указанное лицо является знакомым},
                     tr_relative {контакт находится с этим лицом в каких-либо других отношениях},
                     tr_sister {указанное лицо является сестрой},
                     tr_spouse {указанное лицо является супругой});

  {Класс, описывающий узел <b>gContact:relation</b>.
   Используется для указания других лиц, состоящих в каки-либо отношениях с контактом  (см. описание перечислителя TRelationType).
   Отношение к контакту указывается в атрибуте <b>rel</b> XML-узла.
   Элемент <b>gContact:relation</b> может повторяться в рамках описания одного контакта.
   Узел <b>gContact:relation</b> может отсутствовать в XML-документе}
  TcpRelation = class
  private
    FValue: string;
    FLabel: string;
    FRealition: TRelationType;
    function GetRelStr(aRel: TRelationType): string;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {Возвращает строку на языке пользователя, определяющую тип календаря в ссылке

    * Пример использования *
    <code>
       ...
       property Realition: TRelationType read FRealition write FRealition;
       ...
       S:string;

       Realition:=tr_brother;
       S:=RelToString;
       ----------
       S='Брат'
    </code>}
    function RelToString: string;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;
    property Realition: TRelationType read FRealition write FRealition;//отношение к контакту (см. описание значений перечислителя TRelationType)
    property Value: string read FValue write FValue;//дения об указанном человеке (e-mail, имя, и т.д.)
  end;


{Перечислитель, используемый для определения значения атрибута rel узла
<b>gContact:sensitivity</b>}
type
  TSensitivityRel = (TsNone {характер контакта не определен},
                     Tsconfidential {конфеденциальный контакт},
                     Tsnormal {обычный контакт},
                     Tspersonal {персональный контакт},
                     Tsprivate {приватный (скрытый) контакт});




  {Класс, описывающий узел <b>gContact:sensitivity</b>.
   Используется для классификации контактов по их степени открытости (см. описание значений перечислителя TSensitivityRel).
   Степень открытости контакта указывается в атрибуте <b>rel</b> XML-узла.
   Элемент <b>gContact:sensitivity</b> не может повторяться в рамках описания одного контакта.
   Узел <b>gContact:sensitivity</b> может отсутствовать в XML-документе}
  TcpSensitivity = class
  private
    FRel: TSensitivityRel;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {Возвращает строку на языке пользователя, определяющую тип календаря в ссылке

    * Пример использования *
    <code>
       ...
       property Rel: TSensitivityRel read FRel write FRel;
       ...
       S:string;

       Rel:=Tsconfidential;
       S:=RelToString;
       ----------
       S='Конфеденциальный'
    </code>}
    function RelToString: string;
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;
    property Rel: TSensitivityRel read FRel write FRel;//характеристика "открытости" контакта (см. описание значений перечислителя TSensitivityRel)
  end;


{Перечислитель, используемый для определения значения атрибута id узла
<b>gContact:systemGroup</b>}
type
  TcpSysGroupId = (tg_None {идентификатор группы не определен},
                   tg_Contacts {идентификатор системной группы "Мои контакты"},
                   tg_Friends {идентификатор системной группы "Друзья"},
                   tg_Family {идентификатор системной группы "Семья"},
                   tg_Coworkers {идентификатор системной группы "Коллеги"});

{Класс, описывающий узел <b>gContact:systemGroup</b>.
   Используется для определения идентификатора групы, если группа является системной.
   Идентификатор сисемной группы указывается в атрибуте <b>id</b> XML-узла.
   Элемент <b>gContact:systemGroup</b> не может повторяться в рамках описания одной группы.
   Узел <b>gContact:systemGroup</b> может отсутствовать в XML-документе}
  TcpSystemGroup = class
  private
    FIdRel: TcpSysGroupId;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {Возвращает строку на языке пользователя, определяющую тип календаря в ссылке

    * Пример использования *
    <code>
       ...
        property ID: TcpSysGroupId read FIdRel write FIdRel;
       ...
       S:string;

       Rel:=tg_Contacts;
       S:=RelToString;
       ----------
       S='Мои контакты'
    </code>}
    function RelToString: string;
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
     {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;
    property ID: TcpSysGroupId read FIdRel write FIdRel;//идентификатор системной группы (см. описание перечислителя TcpSysGroupId)
  end;


{Класс, описывающий узел <b>gContact:userDefinedField</b>.
   Используется для указания произвольной информации о контакте.
   В XML-узле обязательно должен присутствовать атрибут <b>key</b> - имя поля и <b>value</b> - значение
   Элемент <b>gContact:userDefinedField</b> может повторяться в рамках описания одной группы.
   Узел <b>gContact:userDefinedField</b> может отсутствовать в XML-документе}
type
  TcpUserDefinedField = class
  private
    FKey: string;
    FValue: string;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;

    property Key: string read FKey write FKey;//Ключ (имя) поля определенного пользователем
    property Value: string read FValue write FValue;//значения поля, определенного пользователем
  end;


{Перечислитель, используемый для определения значения атрибута rel узла
<b>gContact:website</b>}
type
  TWebSiteType = (tw_None {назначение ресурса не определено},
                  tw_Home_Page {ресурс является домашней страничкой контакта},
                  tw_Blog {ресурс яляется блогом контакта},
                  tw_Profile {ресурс является профилем в Google контакта},
                  tw_Home {ресурс является домашним сайтом контакта},
                  tw_Work {ресурс является рабочим сайтом контакта},
                  tw_Other {назначение ресурса не подходит ни под одно доступное описание},
                  tw_Ftp {ресурс является FTP-сайтом контакта});

  {Класс, описывающий узел <b>gContact:website</b>.
   Используется для указания ресурсов в Сети с которыми связан контакт.
   Назначение ресурса описывается в атрибуте rel XML-узла (см. описание перечислителя TWebSiteType)
   Элемент <b>gContact:website</b> может повторяться в рамках описания одной группы.
   Узел <b>gContact:website</b> может отсутствовать в XML-документе}
  TcpWebsite = class
  private
    FHref: string;
    FPrimary: boolean;
    FLabel: string;
    FRel: TWebSiteType;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {Возвращает строку на языке пользователя, определяющую тип календаря в ссылке

    * Пример использования *
    <code>
       ...
        property Rel: TWebSiteType read FRel write FRel;
       ...
       S:string;

       Rel:=tw_Blog;
       S:=RelToString;
       ----------
       S='Блог'
    </code>}
    function RelToString: string;
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(const Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {На основании значений полей класса формирует новый XML-узел и помещает его как
     дочерний для узла <b>Root</b>. Если экземпляр класса не содержит данных (функция
     IsEmpty возвращает true) выполнение функции прерывается и результатом функции
     будет <b>nil</b>}
    function AddToXML(Root: TXmlNode{родительский узел для вновь создаваемого узла}): TXmlNode;

    property Href: string read FHref write FHref;//URL ресурса
    property Primary: boolean read FPrimary write FPrimary;//true, если указанный ресурс является основным для контакта
    property Labl: string read FLabel write FLabel;//произвольное описание ресурса
    property Rel: TWebSiteType read FRel write FRel;//назначение ресурса (см. описание перечислителя TWebSiteType)
  end;

type
  TGoogleContact = class;
  TContactGroup = class;

  {Перечислитель, пределяющий формат файла, который будет сформирован для
   передачи на сервер или для сохранения на жесткий диск}
  TFileType = (tfAtom {файл будет формироваться как документ Atom},
               tfXML  {файл будет формироваться как обычный XML-документ});
  {Перечислитель, определяющий способ сортировки контактов пользователя}
  TSortOrder = (Ts_None {способ сортировки контактов не определен (определяется сервером)},
                Ts_ascending {сортировка контактов по возрастанию},
                Ts_descending {сортировка контактов по убыванию});


{Класс предоставляющий доступ к информации об одном контакте пользователя. Поля класса могут заполняться на основании
XML-узла <b>entry</b> XML-документа, содержащего сведения о контактах пользователя}
  TContact = class
  private
    FEtag: string;
    FId: string;
    FUpdated: TDateTime;
    FTitle: TTextTag;
    FContent: TTextTag;
    FLinks: TList<TEntryLink>;
    FName: TgdName;
    FNickName: TcpNickname;
    FBirthDay: TcpBirthday;
    FOrganization: TgdOrganization;
    FEmails: TList<TgdEmail>;
    FPhones: TList<TgdPhoneNumber>;
    FPostalAddreses: TList<TgdStructuredPostalAddress>;
    FEvents: TList<TcpEvent>;
    FRelations: TList<TcpRelation>;
    FUserFields: TList<TcpUserDefinedField>;
    FWebSites: TList<TcpWebsite>;
    FGroupMemberships: TList<TcpGroupMembershipInfo>;
    FIMs: TList<TgdIm>;
    function GetPrimaryEmail: string;
    procedure SetPrimaryEmail(aEmail: string);
    function GetOrganization: TgdOrganization;
    function GetContactName: string;
    function GenerateText(TypeFile: TFileType): string;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Деструктор. Корректно удаляет объект из памяти}
    destructor Destroy; override;
    {Проверка экземпляра класса на "пустоту". Возвращает <b>true</b> в случае, если
    ни одно поле объекта не заполнено, либо отсутствует обязательные какие-либо значения}
    function IsEmpty: boolean;
    {Очищает поля класса от всех данных.}
    procedure Clear;
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта}); overload;
    {Разбирает узел XML, находящийся в потоке <b>Stream</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(Stream: TStream{поток, содержащий информацию об XML-узле}); overload;
    {находит в списке всех email'ов контакта заданный адрес и возвращает полную информацию по нему в виде объекта TgdEmail}
    function FindEmail(const aEmail: string {адрес email информацию по которому необходимо найти};
                             out Index: integer {индекс объекта в списке email'ов контакта}): TgdEmail;
    {сохраняет всю информацию о контакте в файл}
    procedure SaveToFile(const FileName: string {имя файла (включая путь к нему)};
                               FileType: TFileType = tfAtom{тип файла (см. описание TFileType)});
    {загружает информацию о контакте из файла}
    procedure LoadFromFile(const FileName: string{имя файла (включая путь к нему});
    {Заголовок контакта. Представляет собой объект TTextTag}
    property TagTitle: TTextTag read FTitle write FTitle;
    {Краткое описание контакта. Представляет собой объект TTextTag}
    property TagContent: TTextTag read FContent write FContent;
    {Имя контакта. Представляет собой объект TgdName}
    property TagName: TgdName read FName write FName;
    {Псевдоним контакта. Представляет собой объект TcpNickname}
    property TagNickName: TcpNickname read FNickName write FNickName;
    {День рождения контакта. Представляет собой объект TcpBirthday}
    property TagBirthDay: TcpBirthday read FBirthDay write FBirthDay;
    {Организация в которой рабоает контакт. Представляет собой объект TgdOrganization}
    property TagOrganization
      : TgdOrganization read GetOrganization write FOrganization;
    {Уникальный идентификатор контакта}
    property Etag: string read FEtag;
    {Идентификатор контакта, представляющий собой URL по которому находится полная информация о контакте}
    property ID: string read FId write FId;
    {Дата последнего обновления контакта}
    property Updated: TDateTime read FUpdated write FUpdated;
    {Список ссылок, связанных с контактом. Каждая ссылка представлена в виде объекта TEntryLink
    Эти ссылки используются для редактирования информации о контакте на сервере, загрузки фотографий, удаления контакта и т.д.}
    property Links: TList<TEntryLink>read FLinks write FLinks;
    {Список всех email-адресов контакта. Каждый элемент списка представляет собой объект TgdEmail}
    property Emails: TList<TgdEmail>read FEmails write FEmails;
    {Список всех номеров телефонов контакта. Каждый элемент списка представляет собой объект TgdPhoneNumber}
    property Phones: TList<TgdPhoneNumber>read FPhones write FPhones;
    {Список всех почтовых адресов контакта. Каждый элемент списка представляет собой объект TgdStructuredPostalAddress}
    property PostalAddreses
      : TList<TgdStructuredPostalAddress>read FPostalAddreses write
      FPostalAddreses;
    {Список всех значимых событий для контакта. Каждый элемент списка представляет собой объект TcpEvent}
    property Events: TList<TcpEvent>read FEvents write FEvents;
    {Список лиц, связанных каким-либо образом с контактом. Каждый элемент списка представляет собой объект TcpRelation}
    property Relations: TList<TcpRelation>read FRelations write FRelations;
    {Список полей, содержащих дополнительную информацию о контакте. Каждый элемент списка представляет собой объект TcpUserDefinedField}
    property UserFields
      : TList<TcpUserDefinedField>read FUserFields write FUserFields;
    {Список ресурсов в Сети, с которыми связан контакт. Каждый элемент списка представляет собой объект TcpWebsite}
    property WebSites: TList<TcpWebsite>read FWebSites write FWebSites;
    {Список групп в которых находится контакт. Каждый элемент списка представляет собой объект TcpGroupMembershipInfo}
    property GroupMemberships
      : TList<TcpGroupMembershipInfo>read FGroupMemberships write
      FGroupMemberships;
    {Список дополнительных средств связи с контактом. Каждый элемент списка представляет собой объект TgdIm}
    property IMs: TList<TgdIm>read FIMs write FIMs;
    {Содержит адрес электронной почты, который является основным для контата.
    Может содержать пустую строку, если ни один из адресов в списке Emails не помечен как Primary}
    property PrimaryEmail: string read GetPrimaryEmail write SetPrimaryEmail;
    {Содержит строку которая представляет собой полное имя контакта.
    Полоное имя контакта формируется на основании данных, содержащихся в свойстве TagName}
    property ContactName: string Read GetContactName;
    {Содержит строку, представляющую собой XML-узел entry, в котором содержится вся информация о конакте}
    property ToXMLText[XMLType: TFileType{тип формируемого узла (см. описание TFileType)}]: string read GenerateText;
  end;


{Класс предоставляющий доступ к информации о группе контактов пользователя.
Поля класса могут заполняться на основании XML-узла <b>entry</b> XML-документа,
содержащего сведения о группах контактов пользователя}
  TContactGroup = class
  private
    FEtag: string;
    FId: string;
    FLinks: TList<TEntryLink>;
    FUpdate: TDateTime;
    FTitle: TTextTag;
    FContent: TTextTag;
    FExtendedProps: TgdExtendedProperty;
    FSystemGroup: TcpSystemGroup;
    function GetTitle: string;
    function GetContent: string;
    function GetSysGroupId: TcpSysGroupId;
    procedure SetTitle(const aTitle: string);
    procedure SetContent(const aContent: string);
    procedure SetSysGroupId(aSysGroupId: TcpSysGroupId);
    function GenerateXML(const WintExtended: boolean): TNativeXml;
  public
    {Конструктор создает экземпляр класса. Если определен входной параметр
    <b>ByNode: TXMLNode</b>, то на основании этого узла заполняются поля класса}
    constructor Create(const byNode: TXmlNode = nil{XML-узел на основании которого будет создан экземпляр класса});
    {Разбирает узел XML <b>Node</b> и заполняет на основании полученных данных
    поля класса }
    procedure ParseXML(Node: TXmlNode {узел на основании которого будет проходить заполнение полей объекта});
    {Уникальный идентификатор группы контактов}
    property Etag: string read FEtag write FEtag;
    {Идентификатор группы, представляющий собой URL документа, содержащего всю информацию по группе.
    Также этот идентификатор используется для использования в качестве аттрибута узла <b>gContact:groupMembershipInfo</b>
    (см. иформацию по классу TcpgroupMembershipInfo)}
    property ID: string read FId write FId;
    {Список служебных ссылок для группы контактов. Ссылки используются для редактирования и удаления группы.
    Каждый элемент списка представляет собой класс TEntryLink}
    property Links: TList<TEntryLink>read FLinks write FLinks;
    {Дата последнего обновления информации о группе}
    property Update: TDateTime read FUpdate write FUpdate;
    {Заголовок группы контактов}
    property Title: string read GetTitle write SetTitle;
    {Краткое описание группы контактов}
    property Content: string read GetContent write SetContent;
    {Если группа является системной, то это свойство содержит всю служебную информацию по группе}
    property SystemGroup: TcpSysGroupId read GetSysGroupId write SetSysGroupId;
  end;

  {Основной компонент для работы с Google Contacts. Содержит необходимые свойства
   и методы для работы с группами контактов и контактами}
  TGoogleContact = class(TComponent)
  private
    FAuth: string; // AUTH для доступа к API
    FEmail: string; // обязательно GMAIL!
    FTotalBytes: int64;
    FBytesCount: int64;
    FGroups: TList<TContactGroup>; // группы контактов
    FContacts: TList<TContact>; // все контакты
    FOnRetriveXML: TOnRetriveXML;
    FOnBeginParse: TOnBeginParse;
    FOnEndParse: TOnEndParse;
    FOnReadData: TOnReadData;
    FMaximumResults: integer;
    FStartIndex: integer;
    FUpdatesMin: TDateTime;
    FSortOrder: TSortOrder;
    FShowDeleted: boolean;
    function GetNextLink(Stream: TStream): string; overload;
    function GetNextLink(aXMLDoc: TNativeXml): string; overload;
    function GetContactsByGroup(GroupName: string): TList<TContact>;
    function GroupLink(const aGroupName: string): string;
    procedure ParseXMLContacts(const Data: TStream);
    function GetEditLink(aContact: TContact): string;
    function InsertPhotoEtag(aContact: TContact; const Response: TStream)
      : boolean;
    function GetTotalCount(aXMLDoc: TNativeXml): integer;
    procedure ReadData(Sender: TObject; Reason: THookSocketReason;
      const Value: String);
    function RetriveContactPhoto(index: integer): TJPEGImage; overload;
    function RetriveContactPhoto(aContact: TContact): TJPEGImage; overload;
    procedure SetMaximumResults(const Value: integer);
    procedure SetShowDeleted(const Value: boolean);
    procedure SetSortOrder(const Value: TSortOrder);
    procedure SetStartIndex(const Value: integer);
    procedure SetUpdatesMin(const Value: TDateTime);
    function ParamsToStr: TStringList;
    function GetContact(GroupName: string; Index: integer): TContact;
    procedure SetAuth(const aAuth: string);
    procedure SetGmail(const aGMail: string);
    function GetContactNames: TStrings;
    function GetGropsNames: TStrings;
  public
    {Конструктор. Создает объект с настройками по умолчанию}
    constructor Create(AOwner: TComponent); override;
    {Деструктор. Корректно удаляет объект из памяти}
    destructor Destroy; override;
    {Получение всех групп контактов пользователя. Результатом выполнения функции
    является число групп, полученных в результате выполнения запроса на сервер}
    function RetriveGroups: integer;
    {Получение всех контактов пользователя. Результатом выполнения функции
    является число контактов, полученных в результате выполнения запроса на сервер}
    function RetriveContacts: integer;
    {Удаление контакта с сервера по его индексу в списке <b>Contacts</b>.
    Функция возвращает <b>true</b> в случае, если контакт корректно удален с сервера.
    Удаленный с сервера контакт автоматически удаляется из списка контактов <b>Contacts</b>}
    function DeleteContact(index: integer): boolean; overload;
    {Удаление контакта с сервера. Контакт <b>aContact</b> должен находиться в списке <b>Contacts</b>
    Функция возвращает <b>true</b> в случае, если контакт корректно удален с сервера.
    Удаленный с сервера контакт автоматически удаляется из списка контактов <b>Contacts</b>}
    function DeleteContact(aContact: TContact): boolean; overload;
    {Добавление контакта <b>aContact</b> на сервер.  успешного выполнения операции
    новый контакт автоматически добавляется в список <b>Contacts</b>}
    function AddContact(aContact: TContact): boolean;
    {Добавление новой группы контактов с названием <b>aName</b> и описанием <b>aDescription</b> на сервер.
    В случае, если операция выполнена успешно новая группа автоматически добавляется в список <b>Groups</b>}
    function AddContactGroup(const aName, aDescription: string): boolean;
    {Редактирование информации группы контактов <b>aGroup</b>. Редактируемая группа
    должна находится на сервере (содержать список ссылок </b>Links<b>)}
    function UpdateContactGroup(const aGroup:TContactGroup):boolean;overload;
    {Редактирование информации группы контактов с индексом <b>Index</b> в списке <b>Groups</b>.
    Редактируемая группа должна находится на сервере (содержать список ссылок </b>Links<b>)}
    function UpdateContactGroup(const Index:integer):boolean;overload;
    {Удаление групп контактов <b>aGroup</b> с сервера. В случае успешно выполненной
    операции группа также удляется из списка <b>Groups</b>}
    function DeleteContactGroup(const aGroup:TContactGroup):boolean;overload;
    {Удаление групп контактов с индексом <b>Index</b> в списке <b>Groups</b> с сервера.
    В случае успешно выполненной операции группа также удляется из списка <b>Groups</b>}
    function DeleteContactGroup(const Index:integer):boolean;overload;
    {Обновление информации о контакте <b>aContact</b>. Контакт должен находится в списке <b>Contacts</b>
    В случае успешно выполненной операции информация о контакте обновляется как в списке <b>Contacts</b>
    так и на сервере}
    function UpdateContact(aContact: TContact): boolean; overload;
    {Обновление информации о контакте с индексом <b>Index</b> в списке <b>Contacts</b>
    В случае успешно выполненной операции информация о контакте обновляется как в списке <b>Contacts</b>
    так и на сервере}
    function UpdateContact(index: integer): boolean; overload;
    {Получение с сервера фотографии контакта <b>aContact</b>. В случае, если контакт не содержит фотографии
    результатом выполнения функции будет изображение, загруженное из файла <b>DefaultImage</b>}
    function RetriveContactPhoto(aContact: TContact; DefaultImage: TFileName)
      : TJPEGImage; overload;
    {Получение с сервера фотографии контакта с индексом <b>Index</b> в списке <b>Contacts</b>.
    В случае, если контакт не содержит фотографии результатом выполнения функции
    будет изображение, загруженное из файла <b>DefaultImage</b>}
    function RetriveContactPhoto(index: integer; DefaultImage: TFileName)
      : TJPEGImage; overload;

    {Загружает на сервер файл <b>PhotoFile</b> в качестве изображения контакта,
    имеющего индекс <b>Index</b> в списке <b>Contacts</b>. Функция возращает
    <b>True</b> в случае успешной загрузки}
    function UpdatePhoto(index: integer; const PhotoFile: TFileName): boolean;
      overload;
    {Загружает на сервер файл <b>PhotoFile</b> в качестве изображения контакта
    <b>aContact</b>. Функция возращает <b>True</b> в случае успешной загрузки}
    function UpdatePhoto(aContact: TContact; const PhotoFile: TFileName)
      : boolean; overload;
    {Удаление изображения контакта <b>aContact</b> с сервера. Функция возвращает
    <b>true</b> в случае, если удаление прошло успешно}
    function DeletePhoto(aContact: TContact): boolean; overload;
    {Удаление изображения контакта с индексом <b>Index</b> в списке <b>Contacts</b>
    с сервера. Функция возвращает <b>true</b> в случае, если удаление прошло успешно}
    function DeletePhoto(index: integer): boolean; overload;
    {Сохранение всего списка контактов <b>Contacts</b> в файл <b>FileName</b>.
    Формат файла - <b>XML</b>}
    procedure SaveContactsToFile(const FileName: string);
    {Загружает локальную копию списка контактов из XML-файла <b>FileName</b>}
    procedure LoadContactsFromFile(const FileName: string);


    property Groups: TList<TContactGroup>read FGroups write FGroups;//список все групп контактов пользователя
    property Contacts: TList<TContact>read FContacts write FContacts;//список всех контактов пользователя
    property ContactByGroupIndex[Group: string; I: integer]
      : TContact read GetContact;//контакт, находящийся в группе с именем
      //<b>Group</b> и имеющий в этой группе индекс <b>i</b>
    property ContactsByGroup[GroupName: string]
      : TList<TContact>read GetContactsByGroup;//список всех контактов, находящихся в группе с именем <b>GroupName</b>
    property ContactsNames: TStrings read GetContactNames;// список имен контактов
    property GroupsNames: TStrings read GetGropsNames;// список имен групп контактов

  published
    property Auth: string read FAuth write SetAuth;//Ключ Auth для авторизации в сервисе. Может быть получен с использованием компонента TClientLogin
    property Gmail: string read FEmail write SetGmail;//адрес почтового ящика на GMail. Используется для работы с группами и контактами

    property MaximumResults: integer read FMaximumResults write SetMaximumResults;// максимальное количество записей контактов возвращаемое в одном фиде
    property StartIndex: integer read FStartIndex write SetStartIndex;// начальный номер контакта с которого начинать принятие данных
    property UpdatesMin: TDateTime read FUpdatesMin write SetUpdatesMin;// нижняя граница обновления контактов
    property ShowDeleted: boolean read FShowDeleted write SetShowDeleted;// определяет будут ли показываться в списке удаленные контакты
    property SortOrder: TSortOrder read FSortOrder write SetSortOrder;// сортировка контактов


    property OnRetriveXML: TOnRetriveXML read FOnRetriveXML write FOnRetriveXML;// начало загрузки XML-документа с сервера
    property OnBeginParse: TOnBeginParse read FOnBeginParse write FOnBeginParse;// старт парсинга XML
    property OnEndParse: TOnEndParse read FOnEndParse write FOnEndParse;// окончание парсинга XML
    property OnReadData: TOnReadData read FOnReadData write FOnReadData;// чтение данных из Сети
  end;

// получение типа узла
function GetContactNodeType(const NodeName: string): TcpTagEnum; inline;
// получение имени узла по его типу
function GetContactNodeName(const NodeType: TcpTagEnum): string; inline;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('webdelphi.ru',[TGoogleContact]);
end;

function GetContactNodeName(const NodeType: TcpTagEnum): string; inline;
begin
  Result := GetEnumName(TypeInfo(TcpTagEnum), ord(NodeType));
  Delete(Result, 1, 3);
  Result := CpNodeAlias + Result;
end;

function GetContactNodeType(const NodeName: string): TcpTagEnum; inline;
var
  I: integer;
begin
  if pos(CpNodeAlias, NodeName) > 0 then
  begin
    I := GetEnumValue(TypeInfo(TcpTagEnum), Trim
        (ReplaceStr(NodeName, CpNodeAlias, 'cp_')));
    if I > -1 then
      Result := TcpTagEnum(I)
    else
      Result := cp_None;
  end
  else
    Result := cp_None;
end;

{ TcpBirthday }

function TcpBirthday.AddToXML(Root: TXmlNode): TXmlNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetContactNodeName(cp_birthday));
  Result.AttributeAdd('when', ServerDate);
end;

procedure TcpBirthday.Clear;
begin
  FDate := 0;
  FShortFormat:=false;
end;

constructor TcpBirthday.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpBirthday.GetServerDate: string;
begin
  Result := '';
  if not IsEmpty then
  begin
    if FShortFormat then // укороченный формат даты
      Result := FormatDateTime('--mm-dd', FDate)
    else
      Result := FormatDateTime('yyyy-mm-dd', FDate);
  end;
end;

function TcpBirthday.IsEmpty: boolean;
begin
  Result := FDate <= 0;
end;

procedure TcpBirthday.ParseXML(const Node: TXmlNode);
var
  DateStr: string;
  FormatSet: TFormatSettings;
begin
  if GetContactNodeType(Node.NameUnicode) <> cp_birthday then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName(cp_birthday)]);
  try
    { читаем локальные настройки форматов }
    GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, FormatSet);
    { чиаем дату }
    DateStr := Node.ReadAttributeString('when');
    if (Length(Trim(DateStr)) > 0) then // что-то есть - можно парсить дату
    begin
      // сокращенный формат - только месяц и число рождения
      if (pos('--', DateStr) > 0) then
      begin
        FormatSet.DateSeparator := '-'; // устанавливаем новый разделиель
        Delete(DateStr, 1, 2); // срезаем первые два символа
        FormatSet.ShortDateFormat := 'mm-dd';
        FDate := StrToDate(DateStr, FormatSet);
        FShortFormat := true;
      end
      // полный формат даты
      else
      begin
        FormatSet.DateSeparator := '-';
        FormatSet.ShortDateFormat := 'yyyy-mm-dd';
        FDate := StrToDate(DateStr, FormatSet);
        FShortFormat := false;
      end;
    end;
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

procedure TcpBirthday.SetDate(aDate: TDate);
begin
  FDate := aDate;
end;

{ TcpCalendarLink }

function TcpCalendarLink.AddToXML(Root: TXmlNode): TXmlNode;
var
  tmp: string;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetContactNodeName(cp_calendarLink));
  if FRel <> tc_none then
  begin
    tmp := ReplaceStr(GetEnumName(TypeInfo(TCalendarRel), ord(FRel)), '_', '-');
    Delete(tmp, 1, 3);
    Result.AttributeAdd(sNodeRelAttr, tmp)
  end
  else
    Result.AttributeAdd(sNodeLabelAttr, FLabel);
  Result.AttributeAdd(sNodeHrefAttr, FHref);
  if FPrimary then
    Result.WriteAttributeBool(sNodePrimaryAttr, FPrimary);
end;

procedure TcpCalendarLink.Clear;
begin
  FLabel := '';
  FRel := tc_none;
  FHref := '';
end;

constructor TcpCalendarLink.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpCalendarLink.IsEmpty: boolean;
begin
  Result := ((Length(Trim(FLabel)) = 0) or (FRel = tc_none)) and
    (Length(Trim(FHref)) = 0);
end;

procedure TcpCalendarLink.ParseXML(const Node: TXmlNode);
begin
  if GetContactNodeType(Node.NameUnicode) <> cp_calendarLink then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName(cp_calendarLink)]);
  try
    FPrimary := false;
    FRel := tc_none;
    if Length(Trim(Node.AttributeByUnicodeName[sNodeRelAttr])) > 0 then
    begin // считываем данные о rel
      FRel := TCalendarRel(GetEnumValue(TypeInfo(TCalendarRel),
          'tc_' + ReplaceStr((Trim(Node.AttributeByUnicodeName[sNodeRelAttr])),
            '-', '_')))
    end
    else // rel отсутствует, следовательно читаем label
      FLabel := Trim(Node.AttributeByUnicodeName[sNodeLabelAttr]);
    if Node.HasAttribute(sNodePrimaryAttr) then
      FPrimary := Node.ReadAttributeBool(sNodePrimaryAttr);
    FHref := Node.ReadAttributeString(sNodeHrefAttr);
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

function TcpCalendarLink.RelToString: string;
begin
  case FRel of
    tc_none: Result := FLabel; // описание содержится в label - свободный текст
    tc_work: Result := LoadStr(c_Work);
    tc_home: Result := LoadStr(c_Home);
    tc_free_busy: Result := LoadStr(c_FreeBusy);
  end;
end;

{ TcpEvent }

function TcpEvent.AddToXML(Root: TXmlNode): TXmlNode;
var
  sRel: string;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetContactNodeName(cp_event));
  if ord(FEventType) > -1 then
  begin
    sRel := GetEnumName(TypeInfo(TEventRel), ord(FEventType));
    Delete(sRel, 1, 2);
    Result.WriteAttributeString(sNodeRelAttr, sRel);
  end
  else
  begin
    sRel := GetEnumName(TypeInfo(TEventRel), ord(teOther));
    Delete(sRel, 1, 2);
    Result.WriteAttributeString(sNodeRelAttr, sRel);
  end;
  if Length(FLabel) > 0 then
    Result.WriteAttributeString(sNodeLabelAttr, FLabel);
  FWhen.AddToXML(Result, tdDate);
end;

procedure TcpEvent.Clear;
begin
  FEventType := teNone;
  FLabel := '';
end;

constructor TcpEvent.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  FWhen := TgdWhen.Create;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpEvent.IsEmpty: boolean;
begin
  Result := (FEventType = teNone) and (Length(Trim(FLabel)) = 0) and
    (FWhen.IsEmpty)
end;

procedure TcpEvent.ParseXML(const Node: TXmlNode);
var
  WhenNode: TXmlNode;
  S: String;
begin
  if GetContactNodeType(Node.NameUnicode) <> cp_event then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName(cp_event)]);
  try
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel := Trim(Node.ReadAttributeString(sNodeLabelAttr));
    if Node.HasAttribute(sNodeRelAttr) then
    begin
      S := Trim(Node.ReadAttributeString(sNodeRelAttr));
      S := StringReplace(S, sSchemaHref, '', [rfIgnoreCase]);
      FEventType := TEventRel(GetEnumValue(TypeInfo(TEventRel), S));
    end;

    WhenNode := Node.FindNode(GetGDNodeName(gd_When));
    if WhenNode <> nil then
      FWhen := TgdWhen.Create(WhenNode)
    else
      ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

function TcpEvent.RelToString: string;
begin
  case FEventType of
    teNone: Result := FLabel;
    teAnniversary: Result := LoadStr(c_EvntAnniv);
    teOther: Result := LoadStr(c_EvntOther);
  end;
end;

{ TcpExternalId }

function TcpExternalId.AddToXML(Root: TXmlNode): TXmlNode;
var
  sRel: string;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  if ord(FRel) < 0 then
    raise ECPException.CreateFmt(sc_ErrWriteNode, [GetContactNodeName(cp_externalId)+ ' ' + Format(sc_WrongAttr, ['rel'])]);
  Result := Root.NodeNew(GetContactNodeName(cp_externalId));
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString(sNodeLabelAttr, FLabel);
  sRel := GetEnumName(TypeInfo(TExternalIdType), ord(FRel));
  Delete(sRel, 1, 2);
  Result.WriteAttributeString(sNodeRelAttr, sRel);
  Result.WriteAttributeString(sNodeValueAttr, FValue);
end;

procedure TcpExternalId.Clear;
begin
  FRel := tiNone;
  FLabel := '';
  FValue := '';
end;

constructor TcpExternalId.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpExternalId.IsEmpty: boolean;
begin
  Result := (FRel = tiNone) and (Length(Trim(FLabel)) = 0) and
    (Length(Trim(FValue)) = 0);
end;

procedure TcpExternalId.ParseXML(const Node: TXmlNode);
begin
  if Node = nil then Exit;
  if GetContactNodeType(Node.NameUnicode) <> cp_externalId then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName
          (cp_externalId)]);
  try
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel := Node.ReadAttributeString(sNodeLabelAttr);
    FRel := TExternalIdType(GetEnumValue(TypeInfo(TExternalIdType),
        'ti' + Node.ReadAttributeString(sNodeRelAttr)));
    FValue := Node.ReadAttributeString(sNodeValueAttr);
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

function TcpExternalId.RelToString: string;
begin
  // TExternalIdType = (tiNone,tiAccount,tiCustomer,tiNetwork,tiOrganization);
  case FRel of
    tiNone: Result := FLabel; // rel не определен - берем описание из label
    tiAccount: Result := LoadStr(c_AccId);
    tiCustomer: Result := LoadStr(c_AccCostumer);
    tiNetwork: Result := LoadStr(c_AccNetwork);
    tiOrganization: Result := LoadStr(c_AccOrg);
  end;
end;

{ TcpGender }

function TcpGender.AddToXML(Root: TXmlNode): TXmlNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then Exit;
  if ord(FValue) < 0 then
    raise ECPException.CreateFmt(sc_ErrWriteNode, [GetContactNodeName(cp_gender)+' '+
    Format(sc_WrongAttr, [sNodeValueAttr])]);
  Result := Root.NodeNew(GetContactNodeName(cp_gender));
  Result.WriteAttributeString(sNodeValueAttr, GetEnumName
      (TypeInfo(TGenderType), ord(FValue)));
end;

procedure TcpGender.Clear;
begin
  FValue := none;
end;

constructor TcpGender.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpGender.IsEmpty: boolean;
begin
  Result := FValue = none;
end;

procedure TcpGender.ParseXML(const Node: TXmlNode);
begin
  if Node = nil then
    Exit;
  if GetContactNodeType(Node.NameUnicode) <> cp_gender then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName(cp_gender)]);
  try
    FValue := TGenderType(GetEnumValue(TypeInfo(TGenderType),
        Node.ReadAttributeString(sNodeValueAttr)));
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

function TcpGender.ValueToString: string;
begin
  case FValue of
    none:
      Result := '';
    male:
      Result := LoadStr(c_Male);
    female:
      Result := LoadStr(c_Female);
  end;
end;

{ TcpGroupMembershipInfo }

function TcpGroupMembershipInfo.AddToXML(Root: TXmlNode): TXmlNode;
begin
  Result := nil;
  if (Root = nil) or (IsEmpty) then
    Exit;
  Result := Root.NodeNew(GetContactNodeName(cp_groupMembershipInfo));
  Result.WriteAttributeString(sNodeHrefAttr, FHref);
  Result.WriteAttributeBool(sNodeDeletedAttr, FDeleted);
end;

procedure TcpGroupMembershipInfo.Clear;
begin
  FHref := '';
end;

constructor TcpGroupMembershipInfo.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpGroupMembershipInfo.IsEmpty: boolean;
begin
  Result := Length(Trim(FHref)) = 0
end;

procedure TcpGroupMembershipInfo.ParseXML(const Node: TXmlNode);
begin
  if Node = nil then
    Exit;
  if GetContactNodeType(Node.NameUnicode) <> cp_groupMembershipInfo then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName
          (cp_groupMembershipInfo)]);
  try
    FHref := Node.ReadAttributeString(sNodeHrefAttr);
    FDeleted := Node.ReadAttributeBool(sNodeDeletedAttr)
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

{ TcpJot }

function TcpJot.AddToXML(Root: TXmlNode): TXmlNode;
var
  sRel: string;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetContactNodeName(cp_jot));
  if FRel <> TjNone then
  begin
    sRel := GetEnumName(TypeInfo(TJotRel), ord(FRel));
    Delete(sRel, 1, 2);
    Result.WriteAttributeString(sNodeRelAttr, sRel);
  end;
  Result.ValueAsUnicodeString := FText;
end;

procedure TcpJot.Clear;
begin
  FRel := TjNone;
  FText := '';
end;

constructor TcpJot.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpJot.IsEmpty: boolean;
begin
  Result := (FRel = TjNone) and (Length(Trim(FText)) = 0);
end;

procedure TcpJot.ParseXML(const Node: TXmlNode);
begin
  if Node = nil then
    Exit;
  if GetContactNodeType(Node.NameUnicode) <> cp_jot then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName(cp_jot)]);
  try
    FRel := TJotRel(GetEnumValue(TypeInfo(TJotRel),
        'Tj' + Node.ReadAttributeString(sNodeRelAttr)));
    FText := Node.ValueAsUnicodeString;
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

function TcpJot.RelToString: string;
begin
  case FRel of
    TjNone:
      Result := ''; // не определенное значение
    Tjhome:
      Result := LoadStr(c_JotHome);
    Tjwork:
      Result := LoadStr(c_JotWork);
    Tjother:
      Result := LoadStr(c_JotOther);
    Tjkeywords:
      Result := LoadStr(c_JotKeywords);
    Tjuser:
      Result := LoadStr(c_JotUser);
  end;
end;

{ TcpLanguage }

function TcpLanguage.AddToXML(Root: TXmlNode): TXmlNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetContactNodeName(cp_language));
  Result.WriteAttributeString(sNodeCodeAttr, Fcode);
  Result.WriteAttributeString(sNodeLabelAttr, FLabel);
end;

procedure TcpLanguage.Clear;
begin
  Fcode := '';
  FLabel := '';
end;

constructor TcpLanguage.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpLanguage.IsEmpty: boolean;
begin
  Result := (Length(Trim(Fcode)) = 0) and (Length(Trim(FLabel)) = 0);
end;

procedure TcpLanguage.ParseXML(const Node: TXmlNode);
begin
  if Node = nil then
    Exit;
  if GetContactNodeType(Node.NameUnicode) <> cp_language then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName(cp_language)]);
  try
    Fcode := Node.ReadAttributeString(sNodeCodeAttr);
    FLabel := Node.ReadAttributeString(sNodeLabelAttr);
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

{ TcpPriority }

function TcpPriority.AddToXML(Root: TXmlNode): TXmlNode;
var
  sRel: string;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetContactNodeName(cp_priority));
  sRel := GetEnumName(TypeInfo(TPriotityRel), ord(FRel));
  Delete(sRel, 1, 2);
  Result.WriteAttributeString(sNodeRelAttr, sRel);
end;

procedure TcpPriority.Clear;
begin
  FRel := TpNone;
end;

constructor TcpPriority.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpPriority.IsEmpty: boolean;
begin
  Result := FRel = TpNone;
end;

procedure TcpPriority.ParseXML(const Node: TXmlNode);
begin
  if Node = nil then
    Exit;
  if GetContactNodeType(Node.NameUnicode) <> cp_priority then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName(cp_priority)]);
  try
    FRel := TPriotityRel(GetEnumValue(TypeInfo(TPriotityRel),
        'Tp' + Node.ReadAttributeString(sNodeRelAttr)));
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

function TcpPriority.RelToString: string;
begin
  case FRel of
    TpNone:
      Result := ''; // значение не определено
    Tplow:
      Result := LoadStr(c_PriorityLow);
    Tpnormal:
      Result := LoadStr(c_PriorityNormal);
    Tphigh:
      Result := LoadStr(c_PriorityHigh);
  end;
end;

{ TcpRelation }

function TcpRelation.AddToXML(Root: TXmlNode): TXmlNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetContactNodeName(cp_relation));
  if FRealition = tr_None then
    Result.WriteAttributeString(sNodeLabelAttr, FLabel)
  else
    Result.WriteAttributeString(sNodeRelAttr, GetRelStr(FRealition));
  Result.ValueAsUnicodeString := FValue;
end;

procedure TcpRelation.Clear;
begin
  FValue := '';
  FLabel := '';
  FRealition := tr_None;
end;

constructor TcpRelation.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpRelation.GetRelStr(aRel: TRelationType): string;
begin
  Result := GetEnumName(TypeInfo(TRelationType), ord(aRel));
  Delete(Result, 1, 3);
  Result := StringReplace(Result, '_', '-', [rfReplaceAll])
end;

function TcpRelation.IsEmpty: boolean;
begin
  Result := (Length(Trim(FLabel)) = 0) and (Length(Trim(FValue)) = 0) and
    (FRealition = tr_None);
end;

procedure TcpRelation.ParseXML(const Node: TXmlNode);
var
  tmp: string;
begin
  if Node = nil then
    Exit;
  if GetContactNodeType(Node.NameUnicode) <> cp_relation then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName(cp_relation)]);
  try
    if Node.HasAttribute(sNodeRelAttr) then
    begin
      tmp := 'tr_' + ReplaceStr(Node.ReadAttributeString(sNodeRelAttr), '-',
        '_');
      FRealition := TRelationType(GetEnumValue(TypeInfo(TRelationType), tmp))
    end
    else
    begin
      FLabel := Node.ReadAttributeString(sNodeLabelAttr);
      FRealition := tr_None;
    end;
    FValue := Node.ValueAsUnicodeString;
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

function TcpRelation.RelToString: string;
begin
  case FRealition of
    tr_None:
      Result := ''; // не определено
    tr_assistant:
      Result := LoadStr(c_RelationAssistant);
    tr_brother:
      Result := LoadStr(c_RelationBrother);
    tr_child:
      Result := LoadStr(c_RelationChild);
    tr_domestic_partner:
      Result := LoadStr(c_RelationDomestPart);
    tr_father:
      Result := LoadStr(c_RelationFather);
    tr_friend:
      Result := LoadStr(c_RelationFriend);
    tr_manager:
      Result := LoadStr(c_RelationManager);
    tr_mother:
      Result := LoadStr(c_RelationMother);
    tr_parent:
      Result := LoadStr(c_RelationPartner);
    tr_partner:
      Result := LoadStr(c_RelationPartner);
    tr_referred_by:
      Result := LoadStr(c_RelationReffered);
    tr_relative:
      Result := LoadStr(c_RelationRelative);
    tr_sister:
      Result := LoadStr(c_RelationSister);
    tr_spouse:
      Result := LoadStr(c_RelationSpouse);
  end;
end;

{ TcpSensitivity }

function TcpSensitivity.AddToXML(Root: TXmlNode): TXmlNode;
var
  sRel: string;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  if ord(FRel) < 0 then
    raise ECPException.CreateFmt(sc_ErrWriteNode, [GetContactNodeName(cp_sensitivity) + ' ' + Format(sc_WrongAttr, ['rel'])]);
  Result := Root.NodeNew(GetContactNodeName(cp_sensitivity));
  sRel := GetEnumName(TypeInfo(TSensitivityRel), ord(FRel));
  Delete(sRel, 1, 2);
  Result.WriteAttributeString(sNodeRelAttr, sRel);
end;

procedure TcpSensitivity.Clear;
begin
  FRel := TsNone;
end;

constructor TcpSensitivity.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpSensitivity.IsEmpty: boolean;
begin
  Result := FRel = TsNone;
end;

procedure TcpSensitivity.ParseXML(const Node: TXmlNode);
begin
  if Node = nil then
    Exit;
  if GetContactNodeType(Node.NameUnicode) <> cp_sensitivity then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName
          (cp_sensitivity)]);
  try
    FRel := TSensitivityRel(GetEnumValue(TypeInfo(TSensitivityRel),
        'Ts' + Node.ReadAttributeString(sNodeRelAttr)));
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

function TcpSensitivity.RelToString: string;
begin
  case FRel of
    TsNone:
      Result := '';
    Tsconfidential:
      Result := LoadStr(c_SensitivConf);
    Tsnormal:
      Result := LoadStr(c_SensitivNormal);
    Tspersonal:
      Result := LoadStr(c_SensitivPersonal);
    Tsprivate:
      Result := LoadStr(c_SensitivPrivate);
  end;
end;

{ TsystemGroup }

function TcpSystemGroup.AddToXML(Root: TXmlNode): TXmlNode;
var
  tmp: string;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then Exit;
  if FIdRel = tg_None then
    raise ECPException.CreateFmt(sc_ErrWriteNode, [GetContactNodeName(cp_systemGroup)+ ' ' + Format(sc_WrongAttr, ['id'])]);
  Result := Root.NodeNew(GetContactNodeName(cp_systemGroup));
  tmp := GetEnumName(TypeInfo(TcpSysGroupId), ord(FIdRel));
  Delete(tmp, 1, 3);
  Result.WriteAttributeString('id', tmp);
end;

procedure TcpSystemGroup.Clear;
begin
  FIdRel := tg_None;
end;

constructor TcpSystemGroup.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpSystemGroup.IsEmpty: boolean;
begin
  Result := FIdRel = tg_None;
end;

procedure TcpSystemGroup.ParseXML(const Node: TXmlNode);
begin
  if (Node = nil) then
    Exit;
  if GetContactNodeType(Node.NameUnicode) <> cp_systemGroup then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName
          (cp_systemGroup)]);
  try
    FIdRel := TcpSysGroupId(GetEnumValue(TypeInfo(TcpSysGroupId),
        'tg_' + Node.ReadAttributeString('id')));
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

function TcpSystemGroup.RelToString: string;
begin
  case FIdRel of
    tg_None:
      Result := ''; // значение не определено
    tg_Contacts:
      Result := LoadStr(c_SysGroupContacts);
    tg_Friends:
      Result := LoadStr(c_SysGroupFriends);
    tg_Family:
      Result := LoadStr(c_SysGroupFamily);
    tg_Coworkers:
      Result := LoadStr(c_SysGroupCoworkers);
  end;
end;

{ TcpUserDefinedField }

function TcpUserDefinedField.AddToXML(Root: TXmlNode): TXmlNode;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  Result := Root.NodeNew(GetContactNodeName(cp_userDefinedField));
  Result.WriteAttributeString(sNodeKeyAttr, FKey);
  Result.WriteAttributeString(sNodeValueAttr, FValue);
end;

procedure TcpUserDefinedField.Clear;
begin
  FKey := '';
  FValue := '';
end;

constructor TcpUserDefinedField.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpUserDefinedField.IsEmpty: boolean;
begin
  Result := (Length(Trim(FKey)) = 0) and (Length(Trim(FValue)) = 0)
end;

procedure TcpUserDefinedField.ParseXML(const Node: TXmlNode);
begin
  if Node = nil then
    Exit;
  if GetContactNodeType(Node.NameUnicode) <> cp_userDefinedField then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName
          (cp_userDefinedField)]);
  try
    FKey := Node.ReadAttributeString(sNodeKeyAttr);
    FValue := Node.ReadAttributeString(sNodeValueAttr);
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

{ TcpWebsite }

function TcpWebsite.AddToXML(Root: TXmlNode): TXmlNode;
var
  tmp: string;
begin
  Result := nil;
  if (Root = nil) or IsEmpty then
    Exit;
  if FRel = tw_None then
    raise ECPException.CreateFmt(sc_ErrWriteNode, [GetContactNodeName(cp_website)+' '+Format(sc_WrongAttr, ['rel'])]);
  Result := Root.NodeNew(GetContactNodeName(cp_website));
  Result.WriteAttributeString(sNodeHrefAttr, FHref);

  tmp := GetEnumName(TypeInfo(TWebSiteType), ord(FRel));
  Delete(tmp, 1, 3);
  tmp := ReplaceStr(tmp, '_', '-');
  Result.WriteAttributeString(sNodeRelAttr, tmp);

  if FPrimary then
    Result.WriteAttributeBool(sNodePrimaryAttr, FPrimary);
  if Trim(FLabel) <> '' then
    Result.WriteAttributeString(sNodeLabelAttr, FLabel);
end;

procedure TcpWebsite.Clear;
begin
  FHref := '';
  FLabel := '';
  FRel := tw_None;
end;

constructor TcpWebsite.Create(const byNode: TXmlNode);
begin
  inherited Create;
  Clear;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TcpWebsite.IsEmpty: boolean;
begin
  Result := (Length(Trim(FHref)) = 0) and (Length(Trim(FLabel)) = 0) and
    (FRel = tw_None)
end;

procedure TcpWebsite.ParseXML(const Node: TXmlNode);
var
  tmp: string;
begin
  if (Node = nil) then
    Exit;
  if GetContactNodeType(Node.NameUnicode) <> cp_website then
    raise ECPException.CreateFmt(sc_ErrCompNodes, [GetContactNodeName(cp_website)]);
  try
    FRel := tw_None;
    FHref := Node.ReadAttributeString(sNodeHrefAttr);
    tmp := ReplaceStr(Node.ReadAttributeString(sNodeRelAttr), sSchemaHref, '');
    tmp := 'tw_' + ReplaceStr(tmp, '-', '_');
    FRel := TWebSiteType(GetEnumValue(TypeInfo(TWebSiteType), tmp));
    if Node.HasAttribute(sNodeLabelAttr) then
      FLabel := Node.ReadAttributeString(sNodeLabelAttr);
    if Node.HasAttribute(sNodePrimaryAttr) then
      FPrimary := Node.ReadAttributeBool(sNodePrimaryAttr);
  except
    ECPException.CreateFmt(sc_ErrPrepareNode, [Node.Name]);
  end;
end;

function TcpWebsite.RelToString: string;
begin
  case FRel of
    tw_None:
      Result := ''; // значение не определено
    tw_Home_Page:
      Result := LoadStr(c_WebsiteHomePage);
    tw_Blog:
      Result := LoadStr(c_WebsiteBlog);
    tw_Profile:
      Result := LoadStr(c_WebsiteProfile);
    tw_Home:
      Result := LoadStr(c_WebsiteHome);
    tw_Work:
      Result := LoadStr(c_WebsiteWork);
    tw_Other:
      Result := LoadStr(c_WebsiteOther);
    tw_Ftp:
      Result := LoadStr(c_WebsiteFtp);
  end;
end;

{ TContact }

procedure TContact.Clear;
begin
  FEtag := '';
  FId := '';
  FUpdated := 0;
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

constructor TContact.Create(byNode: TXmlNode);
begin
  inherited Create();
  FLinks := TList<TEntryLink>.Create;
  FEmails := TList<TgdEmail>.Create;
  FPhones := TList<TgdPhoneNumber>.Create;
  FPostalAddreses := TList<TgdStructuredPostalAddress>.Create;
  FEvents := TList<TcpEvent>.Create;
  FRelations := TList<TcpRelation>.Create;
  FUserFields := TList<TcpUserDefinedField>.Create;
  FWebSites := TList<TcpWebsite>.Create;
  FIMs := TList<TgdIm>.Create;
  FGroupMemberships := TList<TcpGroupMembershipInfo>.Create;
  FOrganization := TgdOrganization.Create();
  FTitle := TTextTag.Create();
  FContent := TTextTag.Create();
  FName := TgdName.Create();
  FNickName := TcpNickname.Create();
  FBirthDay := TcpBirthday.Create(nil);
  if byNode <> nil then
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

function TContact.FindEmail(const aEmail: string; out Index: integer): TgdEmail;
var
  I: integer;
begin
  Result := nil;
  for I := 0 to FEmails.Count - 1 do
  begin
    if UpperCase(aEmail) = UpperCase(FEmails[I].Address) then
    begin
      Result := FEmails[I];
      Index := I;
      break;
    end;
  end;
end;

function TContact.GenerateText(TypeFile: TFileType): string;
var
  Doc: TNativeXml;
  I: integer;
  Node: TXmlNode;
begin
  try
    Node := nil;
    if IsEmpty then
      Exit;
    Doc := TNativeXml.Create;
    Doc.EncodingString := sDefoultEncoding;
    case TypeFile of
      tfAtom:
        begin
          Doc.CreateName(sAtomAlias + sEntryNodeName);
          Doc.Root.WriteAttributeString('xmlns:atom',
            'http://www.w3.org/2005/Atom');
          Node := Doc.Root.NodeNew(sAtomAlias + 'category');
        end;
      tfXML:
        begin
          Doc.CreateName(sEntryNodeName);
          Doc.Root.WriteAttributeString('xmlns', 'http://www.w3.org/2005/Atom');
          Node := Doc.Root.NodeNew('category');
        end;
    end;
    Doc.Root.WriteAttributeString('xmlns:gd',
      'http://schemas.google.com/g/2005');
    Doc.Root.WriteAttributeString('xmlns:gContact',
      'http://schemas.google.com/contact/2008');
    Node.WriteAttributeString('scheme',
      'http://schemas.google.com/g/2005#kind');
    Node.WriteAttributeString('term',
      'http://schemas.google.com/contact/2008#contact');

    FTitle.AddToXML(Doc.Root);

    for I := 0 to FLinks.Count - 1 do
      FLinks[I].AddToXML(Doc.Root);
    for I := 0 to FEmails.Count - 1 do
      FEmails[I].AddToXML(Doc.Root);
    for I := 0 to FPhones.Count - 1 do
      FPhones[I].AddToXML(Doc.Root);
    for I := 0 to FPostalAddreses.Count - 1 do
      FPostalAddreses[I].AddToXML(Doc.Root);
    for I := 0 to FIMs.Count - 1 do
      FIMs[I].AddToXML(Doc.Root);
    // GContact
    for I := 0 to FEvents.Count - 1 do
      FEvents[I].AddToXML(Doc.Root);
    for I := 0 to FRelations.Count - 1 do
      FRelations[I].AddToXML(Doc.Root);
    for I := 0 to FUserFields.Count - 1 do
      FUserFields[I].AddToXML(Doc.Root);
    for I := 0 to FWebSites.Count - 1 do
      FWebSites[I].AddToXML(Doc.Root);
    for I := 0 to FGroupMemberships.Count - 1 do
      FGroupMemberships[I].AddToXML(Doc.Root);

    FContent.AddToXML(Doc.Root);
    FName.AddToXML(Doc.Root);
    FNickName.AddToXML(Doc.Root);
    FOrganization.AddToXML(Doc.Root);
    FBirthDay.AddToXML(Doc.Root);
    Result := string(Doc.Root.WriteToString);
  finally
    FreeAndNil(Doc)
  end;
end;

function TContact.GetContactName: string;
begin
  Result := CpDefaultCName;
  if FTitle.IsEmpty then
    if PrimaryEmail <> '' then
      Result := PrimaryEmail
    else if not FNickName.IsEmpty then
      Result := FNickName.Value
    else
      Result := CpDefaultCName
    else
      Result := FTitle.Value
end;

function TContact.GetOrganization: TgdOrganization;
begin
  Result := TgdOrganization.Create();
  if FOrganization <> nil then
    Result := FOrganization
  else
  begin
    Result.OrgName := TTextTag.Create();
    Result.OrgTitle := TTextTag.Create();
  end;
end;

function TContact.GetPrimaryEmail: string;
var
  I: integer;
begin
  Result := '';
  if FEmails = nil then
    Exit;
  if FEmails.Count = 0 then
    Exit;
  Result := FEmails[0].Address;
  for I := 0 to FEmails.Count - 1 do
  begin
    if FEmails[I].Primary then
    begin
      Result := FEmails[I].Address;
      break;
    end;
  end;
end;

function TContact.IsEmpty: boolean;
begin
  Result := FTitle.IsEmpty and FContent.IsEmpty and FName.IsEmpty and FNickName.
    IsEmpty and FBirthDay.IsEmpty and FOrganization.IsEmpty and
    (FEmails.Count = 0) and (FPhones.Count = 0) and (FPostalAddreses.Count = 0)
    and (FEvents.Count = 0) and (FRelations.Count = 0) and
    (FUserFields.Count = 0) and (FWebSites.Count = 0) and
    (FGroupMemberships.Count = 0) and (FIMs.Count = 0);
end;

procedure TContact.LoadFromFile(const FileName: string);
var
  XML: TNativeXml;
begin
  try
    XML := TNativeXml.Create;
    XML.LoadFromFile(FileName);
    if (not XML.IsEmpty) and ((LowerCase(XML.Root.NameUnicode) = LowerCase
          (sAtomAlias + sEntryNodeName)) or (LowerCase(XML.Root.NameUnicode)
          = LowerCase(sEntryNodeName))) then
      ParseXML(XML.Root);
  finally
    FreeAndNil(XML)
  end;
end;

procedure TContact.ParseXML(Stream: TStream);
var
  XMLDoc: TNativeXml;
begin
  if Stream = nil then
    Exit;
  if Stream.Size = 0 then
    Exit;
  XMLDoc := TNativeXml.Create;
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

procedure TContact.ParseXML(Node: TXmlNode);
var
  I: integer;
  List: TXmlNodeList;
begin
  try
    if Node = nil then Exit;
    FEtag := Node.ReadAttributeString(gdNodeAlias + 'etag');
    List := TXmlNodeList.Create;
//    Node.NodesByName('id', List);
//    for I := 0 to List.Count - 1 do {!!!!!!!!!!}
//      FId :=List.Items[I].ValueAsUnicodeString;

    FId := Node.NodeByName('id').ValueAsUnicodeString;

    Node.NodesByName(GetGDNodeName(gd_Email), List);
    for I := 0 to List.Count - 1 do
      FEmails.Add(TgdEmail.Create(List.Items[I]));

    Node.NodesByName(GetGDNodeName(gd_PhoneNumber), List);
    for I := 0 to List.Count - 1 do
      FPhones.Add(TgdPhoneNumber.Create(List.Items[I]));

    Node.NodesByName(GetGDNodeName(gd_Im), List);
    for I := 0 to List.Count - 1 do
      FIMs.Add(TgdIm.Create(List.Items[I]));

    Node.NodesByName(GetGDNodeName(gd_StructuredPostalAddress), List);
    for I := 0 to List.Count - 1 do
      FPostalAddreses.Add(TgdStructuredPostalAddress.Create(List.Items[I]));

    Node.NodesByName(GetContactNodeName(cp_event), List);
    for I := 0 to List.Count - 1 do
      FEvents.Add(TcpEvent.Create(List.Items[I]));

    Node.NodesByName(GetContactNodeName(cp_relation), List);
    for I := 0 to List.Count - 1 do
      FRelations.Add(TcpRelation.Create(List.Items[I]));

    Node.NodesByName(GetContactNodeName(cp_userDefinedField), List);
    for I := 0 to List.Count - 1 do
      FUserFields.Add(TcpUserDefinedField.Create(List.Items[I]));

    Node.NodesByName(GetContactNodeName(cp_website), List);
    for I := 0 to List.Count - 1 do
      FWebSites.Add(TcpWebsite.Create(List.Items[I]));

    Node.NodesByName(GetContactNodeName(cp_groupMembershipInfo), List);
    for I := 0 to List.Count - 1 do
      FGroupMemberships.Add(TcpGroupMembershipInfo.Create(List.Items[I]));

    Node.NodesByName('link', List);
    for I := 0 to List.Count - 1 do
      FLinks.Add(TEntryLink.Create(List.Items[I]));

    for I := 0 to Node.NodeCount - 1 do
    begin
      // CpAtomAlias
      if (LowerCase(Node.Nodes[I].NameUnicode) = 'updated') or
        (LowerCase(Node.Nodes[I].NameUnicode) = LowerCase
          (sAtomAlias + 'updated')) then
        FUpdated := ServerDateToDateTime(Node.Nodes[I].ValueAsUnicodeString)
      else if (LowerCase(Node.Nodes[I].NameUnicode) = 'title') or
        (LowerCase(Node.Nodes[I].NameUnicode) = LowerCase(sAtomAlias + 'title')
        ) then
        FTitle := TTextTag.Create(Node.Nodes[I])
      else if (LowerCase(Node.Nodes[I].NameUnicode) = 'content') or
        (LowerCase(Node.Nodes[I].NameUnicode) = LowerCase
          (sAtomAlias + 'content')) then
        FContent := TTextTag.Create(Node.Nodes[I])
      else if LowerCase(Node.Nodes[I].NameUnicode) = LowerCase
        (GetGDNodeName(gd_Name)) then
        FName := TgdName.Create(Node.Nodes[I])
      else if LowerCase(Node.Nodes[I].NameUnicode) = LowerCase
        (GetGDNodeName(gd_Organization)) then
        FOrganization := TgdOrganization.Create(Node.Nodes[I])
      else if LowerCase(Node.Nodes[I].NameUnicode) = LowerCase
        (GetContactNodeName(cp_birthday)) then
        FBirthDay := TcpBirthday.Create(Node.Nodes[I])
      else if LowerCase(Node.Nodes[I].NameUnicode) = LowerCase
        (GetContactNodeName(cp_nickname)) then
        FNickName := TagNickName.Create(Node.Nodes[I]);
    end;
  finally
    FreeAndNil(List)
  end;
end;

procedure TContact.SaveToFile(const FileName: string; FileType: TFileType);
begin
  TFile.WriteAllText(FileName, GenerateText(FileType));
end;

procedure TContact.SetPrimaryEmail(aEmail: string);
var
  index, I: integer;
  NewEmail: TgdEmail;
begin
  if FindEmail(aEmail, index) = nil then
  begin
    NewEmail := TgdEmail.Create();
    NewEmail.Address := aEmail;
    NewEmail.Primary := true;
    NewEmail.Rel := em_other;
    FEmails.Add(NewEmail);
  end;
  for I := 0 to FEmails.Count - 1 do
    FEmails[I].Primary := (I = index);
end;

{ TContactGroup }


constructor TContactGroup.Create(const byNode: TXmlNode);
begin
  inherited Create;
  FLinks := TList<TEntryLink>.Create;
  FExtendedProps:=TgdExtendedProperty.Create();
  FSystemGroup:=TcpSystemGroup.Create();
  FSystemGroup.ID:=tg_None;
  if byNode <> nil then
    ParseXML(byNode);
end;

function TContactGroup.GenerateXML(const WintExtended: boolean): TNativeXml;
var Node,IdNode:TXmlNode;
begin
  Result:=TNativeXml.Create;
  Result.CreateName(sEntryNodeName);
  Result.Root.WriteAttributeString('xmlns:gd','http://schemas.google.com/g/2005');
  Result.Root.WriteAttributeString('xmlns','http://www.w3.org/2005/Atom');
  Result.Root.WriteAttributeString(gdNodeAlias+'etag',FEtag);
  Node:=Result.Root.NodeNew('category');
  Node.WriteAttributeString('scheme','http://schemas.google.com/g/2005#kind');
  Node.WriteAttributeString('term','http://schemas.google.com/g/2005#group');
  IdNode:=Result.Root.NodeNew('id');
  idNode.ValueAsUnicodeString:=Fid;
  FTitle.AddToXML(Result.Root);
  FContent.AddToXML(Result.Root);
  if WintExtended then
    FExtendedProps.AddToXML(Result.Root);
end;

function TContactGroup.GetContent: string;
begin
  Result := FContent.Value;
end;

function TContactGroup.GetSysGroupId: TcpSysGroupId;
begin
  Result := FSystemGroup.ID;
end;

function TContactGroup.GetTitle: string;
begin
  Result := FTitle.Value;
end;

procedure TContactGroup.ParseXML(Node: TXmlNode);
var
  I: integer;
begin
  if Node = nil then
    Exit;
  FEtag := Node.ReadAttributeString(gdNodeAlias + 'etag');
  for I := 0 to Node.NodeCount - 1 do
  begin
    if Node.Nodes[I].NameUnicode = 'id' then
      FId := Node.Nodes[I].ValueAsUnicodeString
    else if Node.Nodes[I].NameUnicode = 'updated' then
      FUpdate := ServerDateToDateTime(Node.Nodes[I].ValueAsUnicodeString)
    else if Node.Nodes[I].NameUnicode = 'title' then
      FTitle := TTextTag.Create(Node.Nodes[I])
    else if Node.Nodes[I].NameUnicode = 'content' then
      FContent := TTextTag.Create(Node.Nodes[I])
    else if Node.Nodes[I].NameUnicode = GetContactNodeName(cp_systemGroup) then
      FSystemGroup := TcpSystemGroup.Create(Node.Nodes[I])
    else if Node.Nodes[I].NameUnicode = 'link' then
      FLinks.Add(TEntryLink.Create(Node.Nodes[I]))
    else if Node.Nodes[i].NameUnicode=GetGDNodeName(gd_extendedProperty)then
      FExtendedProps:=TgdExtendedProperty.Create(Node.Nodes[i]);
  end;
end;

procedure TContactGroup.SetContent(const aContent: string);
begin
  FContent.Value := aContent
end;

procedure TContactGroup.SetSysGroupId(aSysGroupId: TcpSysGroupId);
begin
  FSystemGroup.ID := aSysGroupId;
end;

procedure TContactGroup.SetTitle(const aTitle: string);
begin
  FTitle.Value := aTitle;
end;

{ TGoogleContact }

function TGoogleContact.AddContact(aContact: TContact): boolean;
var
  XML: TNativeXml;
begin
  Result := false;
  if (aContact = nil) Or aContact.IsEmpty then
    Exit;
  try
    XML := TNativeXml.Create;
    XML.ReadFromString(UTF8String(aContact.ToXMLText[tfAtom]));
    with THTTPSender.Create('POST', FAuth, CpContactsLink, CpProtocolVer) do
    begin
      XML.SaveToStream(Document);
      if SendRequest then
      begin
        Result := (ResultCode = 201);
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
        ShowMessage(IntToStr(ResultCode) + ' ' + ResultString)
      end;
    end;
  finally
    FreeAndNil(XML)
  end;
end;

function TGoogleContact.DeleteContact(index: integer): boolean;
begin
  try
    Result := false;
    if (Index < 0) or (Index >= FContacts.Count) then
      Exit;
    Result := DeleteContact(FContacts[index]);
  except
    Result := false;
  end;
end;

function TGoogleContact.AddContactGroup(const aName, aDescription: string)
  : boolean;
var
  XMLDoc: TNativeXml;
  Node: TXmlNode;
  Ext: TgdExtendedProperty;
  List: TStringList;
begin
Result:=false;
List:=TStringList.Create;
try
  Ext:=TgdExtendedProperty.Create();
  Ext.Name:=aDescription;
  Ext.ChildNodes.Add(TTextTag.Create('info',aDescription));
  XMLDoc := TNativeXml.Create;
  XMLDoc.CreateName(sAtomAlias + sEntryNodeName);
  XMLDoc.Root.WriteAttributeString('xmlns:gd','http://schemas.google.com/g/2005');
  XMLDoc.Root.WriteAttributeString('xmlns:atom','http://www.w3.org/2005/Atom');
  Node := XMLDoc.Root.NodeNew(sAtomAlias + 'category');
  Node.WriteAttributeString('scheme', 'http://schemas.google.com/g/2005#kind');
  Node.WriteAttributeString('term', 'http://schemas.google.com/contact/2008#group');
  Node:=XMLDoc.Root.NodeNew(sAtomAlias + 'title');
  Node.ValueAsUnicodeString:=aName;
  Ext.AddToXML(XMLDoc.Root);

  with THTTPSender.Create('POST',FAuth,Format(CpGroupLink,[FEmail]),CpProtocolVer)do
    begin
      XMLDoc.SaveToStream(Document);
      if SendRequest then
        begin
          Result:=ResultCode=201;
          if Result then
            begin
              XMLDoc.Clear;
              XMLDoc.LoadFromStream(Document);
              // если событие определено - отправляем данные
              if Assigned(FOnBeginParse) then
                OnBeginParse(T_Group, FGroups.Count+1,FGroups.Count + 1);
            // парсим группу
              FGroups.Add(TContactGroup.Create(XMLDoc.Root));
            // если событие определено - отправляем данные
              if Assigned(FOnEndParse) then
                OnEndParse(T_Group, FGroups.Last);
            end
          else
            begin
              List.LoadFromStream(Document);
              ShowMessage(List.Text);
            end;
        end
      else
        ShowMessage(IntToStr(ResultCode)+' '+ResultString);
    end;
finally
  FreeAndNil(Ext);
  FReeAndNil(XMLDoc);
  FreeAndNil(List);
end;
end;

constructor TGoogleContact.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMaximumResults := -1;
  FStartIndex := 1;
  FUpdatesMin := 0;
  FShowDeleted := false;
  FSortOrder := Ts_None;
  FGroups := TList<TContactGroup>.Create;
  FContacts := TList<TContact>.Create;
end;

function TGoogleContact.DeleteContact(aContact: TContact): boolean;
var
  I, j: integer;
begin
  try
    Result := false;
    if aContact = nil then
      Exit;

    if Length(aContact.Etag) > 0 then
    begin
      for I := 0 to aContact.FLinks.Count - 1 do
      begin
        if LowerCase(aContact.FLinks[I].Rel) = 'edit' then
        begin
          with THTTPSender.Create('DELETE', FAuth, aContact.FLinks[I].Href,
            CpProtocolVer) do
          begin
            MimeType := 'application/atom+xml';
            ExtendedHeaders.Add('If-Match: ' + aContact.Etag);
            if SendRequest then
            begin
              if ResultCode = 200 then
              begin
                for j := 0 to FContacts.Count - 1 do
                  if FContacts[I] = aContact then
                  begin
                    FContacts.DeleteRange(I, 1);
                    // удаляем свободный элемент из списка
                    break;
                  end;
                aContact.Destroy; // удалили из памяти
                Result := true;
              end;
            end
            else
            begin
              { TODO -oVlad -cbugs : Корректно обработать исключение }
              ShowMessage(IntToStr(ResultCode) + ' ' + ResultString)
            end;
          end;
          break;
        end;
      end;
    end;
  except
    Result := false;
  end;
end;

function TGoogleContact.DeleteContactGroup(const Index: integer): boolean;
begin
  Result:=false;
  if (Index>=0)and(Index<FGroups.Count) then
    Result:=DeleteContactGroup(FGroups[index]);
end;

function TGoogleContact.DeleteContactGroup(
  const aGroup: TContactGroup): boolean;
var i,j:integer;
    List: TStringList;
begin
  Result:=false;
  List:=TStringList.Create;
try
  if aGroup=nil then Exit;
  if aGroup.Links.Count=0 then
    raise ECPException.Create(sc_ErrGroupLink);
  for I := 0 to aGroup.FLinks.Count - 1 do
    begin
      if aGroup.FLinks[i].Rel='edit' then
        begin
          with THTTPSender.Create('DELETE',FAuth,aGroup.FLinks[i].Href,CpProtocolVer)do
            begin
              ExtendedHeaders.Add('If-Match: ' + aGroup.Etag);
              if SendRequest then
                begin
                  Result:=ResultCode=200;
                  //удвляем из списка
                  if Result then
                    begin
                     for j := 0 to FGroups.Count - 1 do
                       begin
                         if FGroups[i]=aGroup then
                            begin
                              FGroups.DeleteRange(i,1);
                              break;
                            end;
                       end;
                    end
                  else
                    begin
                      List.LoadFromStream(Document);
                      ShowMessage(List.Text);
                    end;
                end
              else
                ShowMessage(IntToStr(ResultCode)+' '+ResultString);
            end;
          break;
        end;
    end;
finally
  FreeAndNil(List)
end;
end;

function TGoogleContact.DeletePhoto(index: integer): boolean;
begin
  Result := false;
  if (index >= FContacts.Count) or (index < 0) then
    Exit;
  Result := DeletePhoto(FContacts[index])
end;

function TGoogleContact.DeletePhoto(aContact: TContact): boolean;
var
  I: integer;
begin
  Result := false;
  if aContact = nil then
    Exit;
  for I := 0 to aContact.FLinks.Count - 1 do
  begin
    if (LowerCase(aContact.FLinks[I].Ltype) = sImgRel) and
      (Length(aContact.FLinks[I].Etag) > 0) then
    begin
      with THTTPSender.Create('DELETE', FAuth, aContact.FLinks[I].Href,
        CpProtocolVer) do
      begin
        MimeType := sImgRel;
        ExtendedHeaders.Add('If-Match: *');
        if SendRequest then
        begin
          Result := ResultCode = 200;
          if Result then
            aContact.FLinks[I].Etag := '';
        end
        else
          ShowMessage(IntToStr(ResultCode) + ' ' + ResultString)
      end;
      break;
    end;
  end;
end;

destructor TGoogleContact.Destroy;
var
  c: TContact;
  g: TContactGroup;
begin
  for g in FGroups do
    g.Destroy;
  for c in FContacts do
    c.Destroy;
  FContacts.Free;
  FGroups.Free;
  inherited Destroy;
end;

function TGoogleContact.GetContact(GroupName: string; Index: integer): TContact;
var
  List: TList<TContact>;
begin
  Result := nil;
  try
    List := TList<TContact>.Create;
    List := GetContactsByGroup(GroupName);
    if (Index > List.Count) or (Index < 0) then
      Exit;
    Result := TContact.Create();
    Result := List[index];
  finally
    FreeAndNil(List);
  end;
end;

function TGoogleContact.GetContactNames: TStrings;
var
  I: integer;
begin
  Result := TStringList.Create;
  for I := 0 to FContacts.Count - 1 do
    Result.Add(FContacts[I].GetContactName);
end;

function TGoogleContact.GetContactsByGroup(GroupName: string): TList<TContact>;
var
  I, j: integer;
  GrupLink: string;
begin
  Result := TList<TContact>.Create;
  GrupLink := GroupLink(GroupName);
  if GrupLink <> '' then
  begin
    for I := 0 to FContacts.Count - 1 do
      for j := 0 to FContacts[I].FGroupMemberships.Count - 1 do
      begin
        if FContacts[I].FGroupMemberships[j].FHref = GrupLink then
          Result.Add(FContacts[I])
      end;
  end;
end;

function TGoogleContact.GetEditLink(aContact: TContact): string;
var
  I: integer;
begin
  Result := '';
  for I := 0 to aContact.FLinks.Count - 1 do
    if aContact.FLinks[I].Rel = 'edit' then
    begin
      Result := aContact.FLinks[I].Href;
      break;
    end;
end;

function TGoogleContact.GetGropsNames: TStrings;
var
  I: integer;
begin
  Result := TStringList.Create;
  for I := 0 to FGroups.Count - 1 do
    Result.Add(FGroups[I].GetTitle);
end;

function TGoogleContact.GetNextLink(aXMLDoc: TNativeXml): string;
var
  I: integer;
  List: TXmlNodeList;
begin
  try
    if aXMLDoc = nil then
      Exit;
    Result := '';
    List := TXmlNodeList.Create;
    aXMLDoc.Root.NodesByName('link', List);
    for I := 0 to List.Count - 1 do
    begin
      if List.Items[I].ReadAttributeString(sNodeRelAttr) = 'next' then
      begin
        Result := String(List.Items[I].ReadAttributeString(sNodeHrefAttr));
        break;
      end;
    end;
  finally
    FreeAndNil(List);
  end;
end;

function TGoogleContact.GetTotalCount(aXMLDoc: TNativeXml): integer;
var Node: TXmlNode;
begin
Result := -1;
  try
    if aXMLDoc = nil then Exit;
  // ищем вот такой узел <openSearch:totalResults>ЧИСЛО</openSearch:totalResults>
    Node:=aXMLDoc.Root.NodeByName('openSearch:totalResults');
    if Node<>nil then
      Result := Node.ValueAsInteger
  except
    {обработать исключение}
  end;
end;

function TGoogleContact.GetNextLink(Stream: TStream): string;
var
  I: integer;
  List: TXmlNodeList;
  XML: TNativeXml;
begin
  try
    if Stream = nil then
      Exit;
    XML := TNativeXml.Create;
    XML.LoadFromStream(Stream);
    Result := '';
    List := TXmlNodeList.Create;
    XML.Root.NodesByName('link', List);
    for I := 0 to List.Count - 1 do
    begin
      if List.Items[I].ReadAttributeString(sNodeRelAttr) = 'next' then
      begin
        Result := string(List.Items[I].ReadAttributeString(sNodeHrefAttr));
        break;
      end;
    end;
  finally
    FreeAndNil(List);
    FreeAndNil(XML);
  end;
end;

function TGoogleContact.GroupLink(const aGroupName: string): string;
var
  I: integer;
begin
  Result := '';
  for I := 0 to FGroups.Count - 1 do
  begin
    if UpperCase(aGroupName) = UpperCase(FGroups[I].Title) then
    begin
      Result := FGroups[I].FId;
      break
    end;
  end;
end;

function TGoogleContact.InsertPhotoEtag(aContact: TContact;
  const Response: TStream): boolean;
var
  XML: TNativeXml;
  I: integer;
  Etag: string;
begin
  Result := false;
  try
    if Response = nil then
      Exit;
    XML := TNativeXml.Create;
    try
      XML.LoadFromStream(Response);
    except
      Exit;
    end;
    Etag := XML.Root.ReadAttributeString(gdNodeAlias + 'etag');
    for I := 0 to aContact.FLinks.Count - 1 do
    begin
      if aContact.FLinks[I].Ltype = sImgRel then
      begin
        aContact.FLinks[I].Etag := Etag;
        Result := true;
        break;
      end;
    end;
  finally
    FreeAndNil(XML)
  end;
end;

procedure TGoogleContact.LoadContactsFromFile(const FileName: string);
var
  XML: TStringStream;
begin
  try
    XML := TStringStream.Create('', TEncoding.UTF8);
    XML.LoadFromFile(FileName);
    ParseXMLContacts(XML);
  finally
    FreeAndNil(XML)
  end;
end;

function TGoogleContact.ParamsToStr: TStringList;
var
  S: string;
begin
  Result := TStringList.Create;
  Result.Delimiter := '&';
  if FMaximumResults > 0 then
    Result.Add('max-results=' + IntToStr(FMaximumResults));
  if FStartIndex > 1 then
    Result.Add('start-index=' + IntToStr(FStartIndex));
  if ShowDeleted then
    Result.Add('showdeleted=true');
  if FUpdatesMin > 0 then
    Result.Add('updated-min=' + DateTimeToServerDate(FUpdatesMin));
  if FSortOrder <> Ts_None then
  begin
    S := GetEnumName(TypeInfo(TSortOrder), ord(FSortOrder));
    Delete(S, 1, 3);
    Result.Add('sortorder=' + S);
  end;

end;

procedure TGoogleContact.ParseXMLContacts(const Data: TStream);
var
  XMLDoc: TNativeXml;
  List: TXmlNodeList;
  I: integer;
begin
  try
    if (Data = nil) then
      Exit;
    XMLDoc := TNativeXml.Create;
    XMLDoc.LoadFromStream(Data);
    List := TXmlNodeList.Create;
    XMLDoc.Root.NodesByName(sEntryNodeName, List);
    for I := 0 to List.Count - 1 do
    begin
      // Если событие определено - отправляем данные
      if Assigned(FOnBeginParse) then
        OnBeginParse(T_Contact, GetTotalCount(XMLDoc), FContacts.Count + 1);
      // парсим элемент контакта
      FContacts.Add(TContact.Create(List.Items[I]));
      // Если событие определено - отправляем данные. В Element кладем TContact
      if Assigned(FOnEndParse) then
        OnEndParse(T_Contact, FContacts.Last)
    end;
  finally
    FreeAndNil(List);
    FreeAndNil(XMLDoc);
  end;
end;

function TGoogleContact.RetriveContactPhoto(index: integer): TJPEGImage;
begin
  Result := nil;
  if (index >= FContacts.Count) or (index < 0) then
    Exit;
  Result := RetriveContactPhoto(FContacts[index])
end;

procedure TGoogleContact.ReadData(Sender: TObject; Reason: THookSocketReason;
  const Value: String);
begin
  if Reason = HR_ReadCount then
  begin
    FBytesCount := FBytesCount + StrToInt(Value);
    if Assigned(FOnReadData) then
      FOnReadData(FTotalBytes, FBytesCount)
  end;
end;

function TGoogleContact.RetriveContactPhoto(aContact: TContact): TJPEGImage;
var
  I: integer;
begin
  Result := nil;
  if aContact = nil then
    Exit;
  for I := 0 to aContact.FLinks.Count - 1 do
  begin
    if (aContact.FLinks[I].Rel = CpPhotoLink) and
      (Length(aContact.FLinks[I].Etag) > 0) then
    begin
      FTotalBytes := 0;
      FBytesCount := 0;
      with THTTPSender.Create('GET', FAuth, aContact.FLinks[I].Href,
        CpProtocolVer) do
      begin
        Sock.OnStatus := ReadData; // ставим хук на соккет
        FTotalBytes := GetLength(aContact.FLinks[I].Href);
        // получаем размер документа
        if Assigned(FOnRetriveXML) then
          FOnRetriveXML(aContact.FLinks[I].Href);
        MimeType := sDefoultMimeType;
        if SendRequest and (FTotalBytes > 0) then
        begin
          Result := TJPEGImage.Create;
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
var
  Img: TJPEGImage;
begin
  try
    Result := nil;
    if aContact = nil then
      Exit;
    if Length(Trim(DefaultImage)) = 0 then
      raise ECPException.Create(sc_ErrFileNull);
    if not FileExists(DefaultImage) then
      raise ECPException.CreateFmt(sc_ErrFileName, [DefaultImage]);
    Img := TJPEGImage.Create;
    Result := TJPEGImage.Create;
    Img := RetriveContactPhoto(aContact);
    if Img = nil then
      Result.LoadFromFile(DefaultImage)
    else
      Result.Assign(Img);
  finally
    FreeAndNil(Img)
  end;
end;

function TGoogleContact.RetriveContacts: integer;
var
  XMLDoc: TStringStream;
  NextLink: string;
  Params: TStringList;
begin
  try
    NextLink := CpContactsLink;
    Params := TStringList.Create;
    Params.Assign(ParamsToStr);
    if Params.Count > 0 then
      NextLink := NextLink + '?' + Params.DelimitedText;

    XMLDoc := TStringStream.Create('', TEncoding.UTF8);
    repeat
      FTotalBytes := 0;
      FBytesCount := 0;

      with THTTPSender.Create('GET', FAuth, NextLink, CpProtocolVer) do
      begin
        Sock.OnStatus := ReadData; // ставим хук на соккет
        FTotalBytes := GetLength(NextLink); // получаем размер документа
        // сигналим о начале загрузки
        if Assigned(FOnRetriveXML) then
          OnRetriveXML(NextLink);
        if SendRequest then
        begin
          XMLDoc.LoadFromStream(Document);
          ParseXMLContacts(XMLDoc);
          NextLink := GetNextLink(XMLDoc);
        end
        else
        begin
          { TODO -oVlad -cbugs : Корректно обработать исключение }
          break;
        end;
      end;
    until NextLink = '';
    Result := FContacts.Count;
  finally
    FreeAndNil(XMLDoc);
  end;

end;

function TGoogleContact.RetriveGroups: integer;
var
  XMLDoc: TNativeXml;
  List: TXmlNodeList;
  I, Count: integer;
  NextLink: string;
begin
  try
    FGroups.Clear;
    NextLink := Format(CpGroupLink, [FEmail]);
    XMLDoc := TNativeXml.Create;
    repeat
      FTotalBytes := 0;
      FBytesCount := 0;
      with THTTPSender.Create('GET', FAuth, NextLink, CpProtocolVer) do
      begin
        Sock.OnStatus := ReadData; // ставим хук на соккет
        FTotalBytes := GetLength(NextLink); // получаем размер документа
        // отправляем сообщение о начале загрузки
        if Assigned(FOnRetriveXML) then
          FOnRetriveXML(NextLink);
        if SendRequest then
        begin
          XMLDoc.LoadFromStream(Document);
          List := TXmlNodeList.Create;
          XMLDoc.Root.NodesByName(sEntryNodeName, List);
          Count := GetTotalCount(XMLDoc);
          if Count=-1 then
            raise ECPException.CreateFromStream(Document);
          for I := 0 to List.Count - 1 do
          begin
            // если событие определено - отправляем данные
            if Assigned(FOnBeginParse) then
              FOnBeginParse(T_Group, Count, FGroups.Count + 1);
            // парсим группу
            FGroups.Add(TContactGroup.Create(List.Items[I]));
            // если событие определено - отправляем данные
            if Assigned(FOnEndParse) then
              FOnEndParse(T_Group, FGroups.Last);
          end;
          NextLink := GetNextLink(XMLDoc);
        end
        else
          break; { TODO -oVlad -cbugs : Корректно обработать исключение }
      end;
    until NextLink = '';
    Result := FGroups.Count;
  finally
    FreeAndNil(XMLDoc);
  end;

end;

procedure TGoogleContact.SaveContactsToFile(const FileName: string);
var
  I: integer;
  Stream: TStringStream;
begin
  try
    Stream := TStringStream.Create('', TEncoding.UTF8);
    Stream.WriteString('<?xml version="1.0" encoding="UTF-8" ?>');
    Stream.WriteString('<feed ');
    Stream.WriteString('xmlns="http://www.w3.org/2005/Atom" ');
    Stream.WriteString('xmlns:gd="http://schemas.google.com/g/2005" ');
    Stream.WriteString
      ('xmlns:gContact="http://schemas.google.com/contact/2008"');
    Stream.WriteString('>');
    for I := 0 to Contacts.Count - 1 do
      Stream.WriteString(Contacts[I].ToXMLText[tfXML]);
    Stream.WriteString('</feed>');
    Stream.SaveToFile(FileName);
  finally
    FreeAndNil(Stream)
  end;
end;

procedure TGoogleContact.SetAuth(const aAuth: string);
begin
  FAuth := aAuth;
end;

procedure TGoogleContact.SetGmail(const aGMail: string);
begin
  FEmail := aGMail;
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
  Result := false;
  if (Index > FContacts.Count) Or (FContacts[index].IsEmpty) or (Index < 0) then
    Exit;
  UpdateContact(FContacts[index]);
  Result := true;
end;

function TGoogleContact.UpdateContactGroup(const Index: integer): boolean;
begin
Result:=false;
  if (Index>=0)and(Index<FGroups.Count) then
    Result:=UpdateContactGroup(FGroups[index]);
end;

function TGoogleContact.UpdateContactGroup(
  const aGroup: TContactGroup): boolean;
var List: TStringList;
    XMLDoc:TNativeXml;
    i:integer;
begin
Result:=false;
List:=TStringList.Create;
XMLDoc:=TNativeXml.Create;
try
if aGroup.SystemGroup = tg_None then
  begin
  with THTTPSender.Create('PUT',FAuth,aGroup.ID,CpProtocolVer)do
    begin
      aGroup.GenerateXML(false).SaveToStream(Document);
       if SendRequest then
        begin
          Result:=ResultCode=200;
          if not Result then
            begin
              List.LoadFromStream(Document);
              ShowMessage(List.Text);
            end
          else
            begin
              //удаляем старую группу
              for I := 0 to FGroups.Count - 1 do
                begin
                  if FGroups[i]=aGroup then
                    begin
                      FGroups.DeleteRange(i,1);
                      break;
                    end;
                end;
              XMLDoc.LoadFromStream(Document);
              // если событие определено - отправляем данные
              if Assigned(FOnBeginParse) then
                OnBeginParse(T_Group, FGroups.Count+1,FGroups.Count + 1);
              // парсим группу
              FGroups.Add(TContactGroup.Create(XMLDoc.Root));
              // если событие определено - отправляем данные
              if Assigned(FOnEndParse) then
                OnEndParse(T_Group, FGroups.Last);
            end;
        end
      else
        ShowMessage(IntToStr(ResultCode)+' '+ResultString);
    end;
  end
else
  ShowMessage(sc_ErrSysGroup)
finally
  FreeAndNil(List);
  FreeAndNil(XMLDoc);
end;
end;

function TGoogleContact.UpdatePhoto(aContact: TContact;
  const PhotoFile: TFileName): boolean;
var
  I: integer;
begin
  Result := false;
  for I := 0 to aContact.FLinks.Count - 1 do
  begin
    if aContact.FLinks[I].Ltype = sImgRel then
    begin
      With THTTPSender.Create('PUT', FAuth, aContact.FLinks[I].Href,
        CpProtocolVer) do
      begin
        ExtendedHeaders.Add('If-Match: *');
        MimeType := sImgRel;
        Document.LoadFromFile(PhotoFile);
        if SendRequest then
          Result := InsertPhotoEtag(aContact, Document)
        else
          { TODO -oVlad -cbugs : Корректно обработать исключение }
          ShowMessage(IntToStr(ResultCode) + ' ' + ResultString);
      end;
      break;
    end;
  end;
end;

function TGoogleContact.UpdatePhoto(index: integer; const PhotoFile: TFileName)
  : boolean;
begin
  Result := false;
  if (index >= FContacts.Count) or (index < 0) then
    Exit;
  Result := UpdatePhoto(FContacts[index], PhotoFile);
end;

function TGoogleContact.UpdateContact(aContact: TContact): boolean;
var
  Doc: TNativeXml;
begin
  Result := false;
  if (aContact = nil) Or aContact.IsEmpty then
    Exit;
  if (Length(aContact.Etag) = 0) then
    Exit;
  try
    Doc := TNativeXml.Create;
    Doc.ReadFromString(UTF8String(aContact.ToXMLText[tfXML]));
    with THTTPSender.Create('PUT', FAuth, GetEditLink(aContact), CpProtocolVer)
      do
    begin
      ExtendedHeaders.Add('If-Match: *');
      Doc.SaveToStream(Document);
      if SendRequest then
      begin
        Result := ResultCode = 200;
        if Result then
        begin
          aContact.Clear;
          aContact.ParseXML(Document);
        end;
      end
      else
        ShowMessage(IntToStr(ResultCode) + ' ' + ResultString)
    end;
  finally
    FreeAndNil(Doc)
  end;
end;

function TGoogleContact.RetriveContactPhoto(index: integer;
  DefaultImage: TFileName): TJPEGImage;
begin
  Result := nil;
  if (index >= FContacts.Count) or (index < 0) then
    Exit;
  Result := TJPEGImage.Create;
  Result.Assign(RetriveContactPhoto(index, DefaultImage));
end;

{ ECPECPException }

constructor ECPException.CreateFromStream(const Document: TStream);
var Lst: TStringList;
    Err: string;
begin
  Document.Position:=0;
  Lst:=TStringList.Create;
  Lst.LoadFromStream(Document);
  if Pos('html',LowerCase(Lst.Text))>0 then
     begin
       Err:=Lst[2];
       Err:=StringReplace(Err,'<TITLE>','',[rfIgnoreCase]);
       Err:=StringReplace(Err,'</TITLE>','',[rfIgnoreCase]);
     end
  else
    Err:=Lst.Text;
    inherited Create(Err);
end;

end.
