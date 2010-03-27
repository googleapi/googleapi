unit GDataCommon;

interface

uses Classes, XMLDoc,Dialogs, XMLIntf, StrUtils, SysUtils, GHelper, Variants;



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

const
  cEventStatuses: array [0 .. 2] of string = (
    'http://schemas.google.com/g/2005#event.canceled',
    'http://schemas.google.com/g/2005#event.confirmed',
    'http://schemas.google.com/g/2005#event.tentative');

type
  TgdEventStatus = class(TPersistent)
    private
      FValue: string;
      FStatus: TEventStatus;
      procedure SetStatus(aStatus:TEventStatus);
      procedure SetValue(aValue:string);
    public
      Constructor Create(const ByNode:IXMLNode);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
      property Value:string read FValue write SetValue;
      property Ststus:TEventStatus read FStatus write SetStatus;
  end;

type
  TVisibility = (vConfidential, vDefault, vPrivate, vPublic);

const
  cVisibility: array [0 .. 3] of string = (
    'http://schemas.google.com/g/2005#event.confidential',
    'http://schemas.google.com/g/2005#event.default',
    'http://schemas.google.com/g/2005#event.private',
    'http://schemas.google.com/g/2005#event.public');

type
  TgdVisibility = class
    private
      FValue: string;
      FVisible: TVisibility;
    procedure SetValue(aValue:string);
      procedure SetVisible(aVisible:TVisibility);
    public
      Constructor Create(const ByNode:IXMLNode);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
      property Value: string read FValue write SetValue;
      property Visibility: TVisibility read FVisible write SetVisible;
  end;

type
  TTransparency = (tOpaque, tTransparent);

const
  cTransparency: array [0 .. 1] of string = (
    'http://schemas.google.com/g/2005#event.opaque',
    'http://schemas.google.com/g/2005#event.transparent');

type
  TgdTransparency = class(TPersistent)
    private
      FValue: string;
      FTransparency: TTransparency;
      procedure SetValue(aValue:string);
      procedure SetTransp(aTransp:TTransparency);
    public
      Constructor Create(const ByNode:IXMLNode);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
      property Value: string read FValue write SetValue;
      property Transparency: TTransparency read FTransparency write SetTransp;
  end;

type
  TAttendeeType = (aOptional, aRequired);

const
  cAttendeeType: array [0 .. 1] of string = (
    'http://schemas.google.com/g/2005#event.optional',
    'http://schemas.google.com/g/2005#event.required');

type
  TgdAttendeeType = class
    private
      FValue: string;
      FAttType: TAttendeeType;
      procedure SetValue(aValue:string);
      procedure SetType(aStatus:TAttendeeType);
    public
      Constructor Create(const ByNode:IXMLNode);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
      property Value: string read FValue write SetValue;
      property AttendeeType: TAttendeeType read FAttType write SetType;
  end;

type
  TAttendeeStatus = (asAccepted, asDeclined, asInvited, asTentative);

const
  cAttendeeStatus: array [0 .. 3] of string = (
    'http://schemas.google.com/g/2005#event.accepted',
    'http://schemas.google.com/g/2005#event.declined',
    'http://schemas.google.com/g/2005#event.invited',
    'http://schemas.google.com/g/2005#event.tentative');

type
  TgdAttendeeStatus = class(TPersistent)
    private
      FValue: string;
      FAttendeeStatus: TAttendeeStatus;
      procedure SetValue(aValue:string);
      procedure SetStatus(aStatus:TAttendeeStatus);
    public
      Constructor Create(const ByNode:IXMLNode);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
      property Value: string read FValue write SetValue;
      property Status: TAttendeeStatus read FAttendeeStatus write SetStatus;
  end;

type
  TEntryTerms = (ttAny, ttContact, ttEvent, ttMessage, ttType);

type
  TgdCountryStruct = record
    Code: string;
    Text: string;
  end;

type
  TgdAdditionalNameStruct = record
    yomi: string; //атрибут узла, означающий псевдоним пользователя
    Text: string; //текстовая часть узла - имя
  end;

type
  TgdFamilyNameStruct = TgdAdditionalNameStruct;
  TgdGivenNameStruct = TgdAdditionalNameStruct;
//  TgdFamileNameStruct = string;
  TgdNamePrefixStruct = string;
  TgdNameSuffixStruct = string;
  TgdFullNameStruct = string;
  TgdOrgDepartmentStruct = string;
  TgdOrgJobDescriptionStruct = string;
  TgdOrgSymbolStruct = string;

type
  TgdNameStruct = record
    GivenName: TgdGivenNameStruct;
    AdditionalName: TgdAdditionalNameStruct;
    FamilyName: TgdFamilyNameStruct;
    NamePrefix: TgdNamePrefixStruct;
    NameSuffix: TgdNameSuffixStruct;
    FullName: TgdFullNameStruct;
  end;

type
  TgdEmailStruct = record
    address: string;
    elabel: string;
    rel: string;
    primary: boolean;
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
  TgdImStruct = record
    address: string;
    ilabel: string;
    rel: string;
    protocol: string;
    primary: boolean;
  end;

  TgdOrgNameStruct = string;
  TgdOrgTitleStruct = string;

type
  TgdOrganizationStruct = record
    Labels: string;
    rel: string;
    primary: boolean;
    orgName: TgdOrgNameStruct;
    orgTitle: TgdOrgTitleStruct;
  end;

type
  TgdOriginalEventStruct = record
    id: string;
    href: string;
  end;

type
  TgdPhoneNumberStruct = record
    Labels: string;
    rel: string;
    Uri: string;
    primary: boolean;
    Text: string;
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
    Constructor Create(const ByNode:IXMLNode);
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
  TgdReminder = class
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
  TgdWhen = class(TPersistent)
    private
      FendTime: TDateTime;
      FstartTime: TDateTime;
      FvalueString: string;
    public
      Constructor Create(const ByNode:IXMLNode);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
      property endTime: TDateTime read FendTime write FendTime;
      property startTime: TDateTime read FstartTime write FstartTime;
      property valueString: string read FvalueString write FvalueString;
  end;

type
  TgdAgentStruct = string;
  TgdHousenameStruct = string;
  TgdStreetStruct = string;
  TgdPoboxStruct = string;
  TgdNeighborhoodStruct = string;
  TgdCityStruct = string;
  TgdSubregionStruct = string;
  TgdRegionStruct = string;
  TgdPostcodeStruct = string;
  TgdFormattedAddressStruct = string;

type
  TgdStructuredPostalAddressStruct = record
    rel: string;
    MailClass: string;
    Usage: string;
    slabel: string;
    primary: boolean;
    Agent: TgdAgentStruct;
    HouseName: TgdHousenameStruct;
    Street: TgdStreetStruct;
    Pobox: TgdPoboxStruct;
    Neighborhood: TgdNeighborhoodStruct;
    City: TgdCityStruct;
    Subregion: TgdSubregionStruct;
    Region: TgdRegionStruct;
    Postcode: TgdPostcodeStruct;
    Coutry: TgdCountryStruct;
    FormattedAddress: TgdFormattedAddressStruct;
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
      Constructor Create(const ByNode:IXMLNode);
      procedure ParseXML(Node: IXMLNode);
      function AddToXML(Root:IXMLNode):IXMLNode;
      property Labl:string read Flabel write Flabel;
      property Rel:string read FRel write FRel;
      property valueString: string read FvalueString write FvalueString;
      property EntryLink: TgdEntryLink read FEntryLink write FEntryLink;
  end;

const
  cWhoRel: array [1 .. 9] of string = (
    'http://schemas.google.com/g/2005#event.attendee',
    'http://schemas.google.com/g/2005#event.organizer',
    'http://schemas.google.com/g/2005#event.performer',
    'http://schemas.google.com/g/2005#event.speaker',
    'http://schemas.google.com/g/2005#message.bcc',
    'http://schemas.google.com/g/2005#message.cc',
    'http://schemas.google.com/g/2005#message.from',
    'http://schemas.google.com/g/2005#message.reply-to',
    'http://schemas.google.com/g/2005#message.to');

type
  TWhoRel = (twAttendee,twOrganizer,twPerformer,twSpeaker,twBcc,twCc,twFrom,twReply,twTo);

type
  TgdWho = class(TPersistent)
  private
    FEmail: string;
    Frel: string;
    FRelValue: TWhoRel;
    FvalueString: string;
    FAttendeeStatus: TgdAttendeeStatus;
    FAttendeeType: TgdAttendeeType;
    FEntryLink: TgdEntryLink;
    procedure SetRel(aRel:string);
    procedure SetRelValue(aRelValue:TWhoRel);
  public
    Constructor Create(const ByNode:IXMLNode);
    procedure ParseXML(Node: IXMLNode);
    function AddToXML(Root:IXMLNode):IXMLNode;
    property Email: string read FEmail write FEmail;
    property Rel: string read Frel write SetRel;
    property RelValue: TWhoRel read FRelValue write SetRelValue;
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
function gdCountryStruct(aXMLNode: IXMLNode): TgdCountryStruct;
function gdAdditionalName(aXMLNode: IXMLNode): TgdAdditionalNameStruct;
function gdFamilyName(aXMLNode: IXMLNode): TgdFamilyNameStruct;
function gdGivenName(aXMLNode: IXMLNode): TgdGivenNameStruct;
function gdNamePrefix(aXMLNode: IXMLNode): TgdNamePrefixStruct;
function gdNameSuffix(aXMLNode: IXMLNode): TgdNameSuffixStruct;
function gdFullName(aXMLNode: IXMLNode): TgdFullNameStruct;
function gdOrgDepartment(aXMLNode: IXMLNode): TgdOrgDepartmentStruct;
function gdOrgJobDescription(aXMLNode: IXMLNode)
  : TgdOrgJobDescriptionStruct;
function gdOrgSymbol(aXMLNode: IXMLNode): TgdOrgSymbolStruct;
function gdName(aXMLNode: IXMLNode): TgdNameStruct;
function gdEmail(aXMLNode: IXMLNode):TgdEmailStruct;
function gdWhere(aXMLNode: IXMLNode):TgdWhere;
function gdWhen(aXMLNode: IXMLNode):TgdWhen;
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

function gdWhen(aXMLNode: IXMLNode):TgdWhen;
begin
  Result:=TgdWhen.Create(aXMLNode);
end;

function gdWhere(aXMLNode: IXMLNode):TgdWhere;
begin
  Result:=TgdWhere.Create(aXMLNode);
end;

function gdEmail(aXMLNode: IXMLNode):TgdEmailStruct;
begin
  //111
end;

function gdName(aXMLNode: IXMLNode): TgdNameStruct;
var i: integer;
begin
  if GetGDNodeType(aXMLNode.NodeName) <> ord(egdName) then
    raise Exception.Create
      (Format(rcErrCompNodes, [cGDTagNames[ord(egdOrgSymbol)]]));
  for I := 0 to aXMLNode.ChildNodes.Count - 1 do
    begin
      case GetGDNodeType(aXMLNode.ChildNodes[i].NodeName) of
        ord(egdGivenName):Result.GivenName:=gdGivenName(aXMLNode.ChildNodes[i]);
        ord(egdAdditionalName):Result.AdditionalName:=gdAdditionalName(aXMLNode.ChildNodes[i]);
        ord(egdFamilyName):Result.FamilyName:=gdFamilyName(aXMLNode.ChildNodes[i]);
        ord(egdNamePrefix):Result.NamePrefix:=gdNamePrefix(aXMLNode.ChildNodes[i]);
        ord(egdNameSuffix):Result.NameSuffix:=gdNameSuffix(aXMLNode.ChildNodes[i]);
        ord(egdFullName):Result.FullName:=gdFullName(aXMLNode.ChildNodes[i]);
      end;
    end;
end;

function gdOrgSymbol(aXMLNode: IXMLNode): TgdOrgSymbolStruct;
begin
  if GetGDNodeType(aXMLNode.NodeName) <> ord(egdOrgSymbol) then
    raise Exception.Create
      (Format(rcErrCompNodes, [cGDTagNames[ord(egdOrgSymbol)]]));
  Result := aXMLNode.Text;
end;

function gdOrgJobDescription(aXMLNode: IXMLNode)
  : TgdOrgJobDescriptionStruct;
begin
  if GetGDNodeType(aXMLNode.NodeName) <> ord(egdOrgJobDescription) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdOrgJobDescription)]]));
  Result := aXMLNode.Text;
end;

function gdOrgDepartment(aXMLNode: IXMLNode): TgdOrgDepartmentStruct;
begin
  if GetGDNodeType(aXMLNode.NodeName) <> ord(egdOregdepartment) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdOregdepartment)]]));
  Result := aXMLNode.Text;
end;

function gdFullName(aXMLNode: IXMLNode): TgdFullNameStruct;
begin
  if GetGDNodeType(aXMLNode.NodeName) <> ord(egdFullName) then
    raise Exception.Create
      (Format(rcErrCompNodes, [cGDTagNames[ord(egdFullName)]]));
  Result := aXMLNode.Text;
end;

function gdNameSuffix(aXMLNode: IXMLNode): TgdNameSuffixStruct;
begin
  if GetGDNodeType(aXMLNode.NodeName) <> ord(egdNameSuffix) then
    raise Exception.Create
      (Format(rcErrCompNodes, [cGDTagNames[ord(egdNameSuffix)]]));
  Result := aXMLNode.Text;
end;

function gdNamePrefix(aXMLNode: IXMLNode): TgdNamePrefixStruct;
begin
  if GetGDNodeType(aXMLNode.NodeName) <> ord(egdNamePrefix) then
    raise Exception.Create
      (Format(rcErrCompNodes, [cGDTagNames[ord(egdNamePrefix)]]));
  Result := aXMLNode.Text;
end;

function gdGivenName(aXMLNode: IXMLNode): TgdGivenNameStruct;
begin
  if GetGDNodeType(aXMLNode.NodeName) <> ord(egdGivenName) then
    raise Exception.Create
      (Format(rcErrCompNodes, [cGDTagNames[ord(egdGivenName)]]));
  Result := gdAdditionalName(aXMLNode);
end;

function gdFamilyName(aXMLNode: IXMLNode): TgdFamilyNameStruct;
begin
  if GetGDNodeType(aXMLNode.NodeName) <> ord(egdFamilyName) then
    raise Exception.Create
      (Format(rcErrCompNodes, [cGDTagNames[ord(egdFamilyName)]]));
  Result := gdAdditionalName(aXMLNode);
end;

function gdAdditionalName(aXMLNode: IXMLNode): TgdAdditionalNameStruct;
begin
  if GetGDNodeType(aXMLNode.NodeName) <> ord(egdAdditionalName) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdAdditionalName)]]));
  try
    if aXMLNode.Attributes['yomi'] <> null then
      Result.yomi := aXMLNode.Attributes['yomi'];
    Result.Text := aXMLNode.Text;
  except
    raise Exception.Create(Format(rcErrPrepareNode, [aXMLNode.NodeName]));
  end;
end;

function gdCountryStruct(aXMLNode: IXMLNode): TgdCountryStruct;
begin
  if GetGDNodeType(aXMLNode.NodeName) <> ord(egdCountry) then
    raise Exception.Create
      (Format(rcErrCompNodes, [cGDTagNames[ord(egdCountry)]]));
  try
    if aXMLNode.Attributes['code'] <> null then
      Result.Code := aXMLNode.Attributes['code'];
    Result.Text := aXMLNode.Text;
  except
    raise Exception.Create(Format(rcErrPrepareNode, [aXMLNode.NodeName]));
  end;
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
  //добавляем узел
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
    if Node.ChildNodes.Count>0 then //есть дочерний узел с EntryLink
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
    if Node.ChildNodes.Count>0 then //есть дочерний узел с EntryLink
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
  Result.Attributes['value']:=FValue;
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
    FStatus:=TEventStatus(AnsiIndexStr(FValue, cEventStatuses));
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

procedure TgdEventStatus.SetStatus(aStatus: TEventStatus);
begin
  FStatus:=aStatus;
  FValue:=cEventStatuses[ord(aStatus)]
end;

procedure TgdEventStatus.SetValue(aValue: string);
begin
  if AnsiIndexStr(aValue, cEventStatuses)<=0 then
    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdEventStatus)]]));
  FStatus:=TEventStatus(AnsiIndexStr(aValue, cEventStatuses));
  FValue:=aValue;
end;

{ TgdWhen }

function TgdWhen.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root=nil then Exit;
  Result:=Root.AddChild(cgdTagNames[ord(egdWhen)]);
  Result.Attributes['startTime']:=DateTimeToServerDate(FstartTime);
  if FendTime>0 then
    Result.Attributes['endTime']:=DateTimeToServerDate(FendTime);
  if length(Trim(FvalueString))>0 then
    Result.Attributes['valueString']:=FvalueString;
end;

constructor TgdWhen.Create(const ByNode: IXMLNode);
begin
  inherited Create;
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdWhen.ParseXML(Node: IXMLNode);
begin
if Node=nil then Exit;
  if GetGDNodeType(Node.NodeName) <> ord(egdWhen) then
    raise Exception.Create(Format(rcErrCompNodes,
        [cGDTagNames[ord(egdWhen)]]));
  try
    FendTime:=0;
    FstartTime:=0;
    FvalueString:='';
    if Node.Attributes['endTime']<>null then
      FendTime:=ServerDateToDateTime(Node.Attributes['endTime']);
    FstartTime:=ServerDateToDateTime(Node.Attributes['startTime']);
    if Node.Attributes['valueString']<>null then
      FvalueString:=Node.Attributes['valueString'];
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

{ TgdAttendeeStatus }

function TgdAttendeeStatus.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root=nil then Exit;
  Result:=Root.AddChild(cgdTagNames[ord(egdAttendeeStatus)]);
  Result.Attributes['value']:=FValue;
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
    FAttendeeStatus := TAttendeeStatus(AnsiIndexStr(FValue, cAttendeeStatus));
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

procedure TgdAttendeeStatus.SetStatus(aStatus: TAttendeeStatus);
begin
  FAttendeeStatus:=aStatus;
  FValue:=cAttendeeStatus[ord(aStatus)]
end;

procedure TgdAttendeeStatus.SetValue(aValue: string);
begin
  if AnsiIndexStr(aValue, cAttendeeStatus)<=0 then
    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdAttendeeStatus)]]));
  FAttendeeStatus:=TAttendeeStatus(AnsiIndexStr(aValue, cAttendeeStatus));
  FValue:=aValue;
end;

{ TgdAttendeeType }

function TgdAttendeeType.AddToXML(Root: IXMLNode): IXMLNode;
begin
 if Root=nil then Exit;
  Result:=Root.AddChild(cgdTagNames[ord(egdAttendeeType)]);
  Result.Attributes['value']:=FValue;
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
    FValue := Node.Attributes['value'];
    FAttType := TAttendeeType(AnsiIndexStr(FValue, cAttendeeType));
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

procedure TgdAttendeeType.SetType(aStatus: TAttendeeType);
begin
  FAttType:=aStatus;
  FValue:=cAttendeeType[ord(aStatus)]
end;

procedure TgdAttendeeType.SetValue(aValue: string);
begin
  if AnsiIndexStr(aValue, cAttendeeType)<=0 then
    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdAttendeeType)]]));
  FAttType:=TAttendeeType(AnsiIndexStr(aValue, cAttendeeType));
  FValue:=aValue;
end;

{ TgdWho }

function TgdWho.AddToXML(Root: IXMLNode): IXMLNode;
begin
  if Root=nil then Exit;
  Result:=Root.AddChild(cgdTagNames[ord(egdWho)]);
  if Length(Trim(FEmail))>0 then
    Result.Attributes['email']:=FEmail;
  if Length(Trim(Frel))>0 then
    Result.Attributes['rel']:=Frel;
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
  Frel:='';
  FvalueString:='';
  if ByNode=nil then Exit;
  ParseXML(ByNode);
end;

procedure TgdWho.ParseXML(Node: IXMLNode);
var i:integer;
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
        Frel:=Node.Attributes['rel'];
        FRelValue:=TWhoRel(AnsiIndexStr(Frel, cWhoRel));
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

procedure TgdWho.SetRel(aRel: string);
begin
if AnsiIndexStr(aRel, cWhoRel)<=0 then
    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdWho)]]));
  FRelValue:=TWhoRel(AnsiIndexStr(aRel, cWhoRel));
  Frel:=aRel;
end;

procedure TgdWho.SetRelValue(aRelValue: TWhoRel);
begin
  FRelValue:=aRelValue;
  Frel:=cWhoRel[ord(aRelValue)]
end;

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
Result.Attributes['value']:=FValue;
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
    FTransparency := TTransparency(AnsiIndexStr(FValue, cTransparency));
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

procedure TgdTransparency.SetTransp(aTransp: TTransparency);
begin
  FTransparency:=aTransp;
  FValue:=cTransparency[ord(aTransp)]
end;

procedure TgdTransparency.SetValue(aValue: string);
begin
if AnsiIndexStr(aValue, cTransparency)<=0 then
    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdTransparency)]]));
  FTransparency:=TTransparency(AnsiIndexStr(aValue, cTransparency));
  FValue:=aValue;
end;

{ TgdVisibility }

function TgdVisibility.AddToXML(Root: IXMLNode): IXMLNode;
begin
if Root=nil then Exit;
Result:=Root.AddChild(cgdTagNames[ord(egdVisibility)]);
Result.Attributes['value']:=FValue;
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
    FVisible := TVisibility(AnsiIndexStr(FValue, cVisibility));
  except
    raise Exception.Create(Format(rcErrPrepareNode, [Node.NodeName]));
  end;
end;

procedure TgdVisibility.SetValue(aValue: string);
begin
if AnsiIndexStr(aValue, cVisibility)<=0 then
    raise Exception.Create(Format(rcErrMissValue, [cGDTagNames[ord(egdVisibility)]]));
  FVisible:=TVisibility(AnsiIndexStr(aValue, cVisibility));
  FValue:=aValue;
end;

procedure TgdVisibility.SetVisible(aVisible: TVisibility);
begin
  FVisible:=aVisible;
  FValue:=cVisibility[ord(aVisible)]
end;

end.
