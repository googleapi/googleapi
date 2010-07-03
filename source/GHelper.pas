unit GHelper;

interface

uses Graphics,strutils,Windows,DateUtils,SysUtils, Variants,
Classes,StdCtrls,httpsend,Generics.Collections,xmlintf,xmldom,NativeXML,
uLanguage;

//{$I languages\lang_russian.inc}

const
  GoogleColors: array [1..21]of string = ('A32929','B1365F','7A367A','5229A3',
                                          '29527A','2952A3','1B887A','28754E',
                                          '0D7813','528800','88880E','AB8B00',
                                          'BE6D00','B1440E','865A5A','705770',
                                          '4E5D6C','5A6986','4A716C','6E6E41',
                                          '8D6F47');

  NodeValueAttr = 'value';
  EntryNodeName = 'entry';
  SchemaHref ='http://schemas.google.com/g/2005#';

  gdRelValues: array [1..25,1..2] of string = (
  ('http://schemas.google.com/g/2005#event',''),
  ('http://schemas.google.com/g/2005#event.alternate',''),
  ('http://schemas.google.com/g/2005#event.parking',''),
  ('http://schemas.google.com/g/2005#message.bcc',''),
  ('http://schemas.google.com/g/2005#message.cc',''),
  ('http://schemas.google.com/g/2005#message.from',''),
  ('http://schemas.google.com/g/2005#message.reply-to',''),
  ('http://schemas.google.com/g/2005#message.to',''),
  ('http://schemas.google.com/g/2005#regular',''),
  ('http://schemas.google.com/g/2005#reviews',''),
  ('http://schemas.google.com/g/2005#home',''),
  ('http://schemas.google.com/g/2005#other',''),
  ('http://schemas.google.com/g/2005#work',''),
  ('http://schemas.google.com/g/2005#fax',''),
  ('http://schemas.google.com/g/2005#home_fax',''),
  ('http://schemas.google.com/g/2005#mobile',''),
  ('http://schemas.google.com/g/2005#pager',''),
  ('http://schemas.google.com/g/2005#work_fax',''),
  ('http://schemas.google.com/g/2005#overall',''),
  ('http://schemas.google.com/g/2005#price',''),
  ('http://schemas.google.com/g/2005#quality',''),
  ('http://schemas.google.com/g/2005#event.attendee',''),
  ('http://schemas.google.com/g/2005#event.organizer',''),
  ('http://schemas.google.com/g/2005#event.performer',''),
  ('http://schemas.google.com/g/2005#event.speaker',''));

//просранства имен для календарей
clNameSpaces: array [0 .. 2, 0 .. 1] of string =
    (('', 'http://www.w3.org/2005/Atom'), ('gd',
      'http://schemas.google.com/g/2005'), ('gCal',
      'http://schemas.google.com/gCal/2005'));
//значения rel для узлов category календарея
clCategories: array [0 .. 1, 0 .. 1] of string = (('scheme',
      'http://schemas.google.com/g/2005#kind'), ('term',
      'http://schemas.google.com/g/2005#event'));

type
 TTimeZone = packed record
   gConst: string;
   Desc : string;
   GMT: extended;
   rus: boolean;
end;

type
  PTimeZone = ^TTimeZone;

type
  TTimeZoneList = class(TList)
  private
    procedure SetRecord(index: Integer; Ptr: PTimeZone);
    function GetRecord(index: Integer): PTimeZone;
  public
    constructor Create;
    procedure Clear;
    destructor Destroy; override;
    property TimeZone[i: Integer]: PTimeZone read GetRecord write SetRecord;
  end;


type
  TAttribute = packed record
    Name: string;
    Value: string;
  end;

type
  TTextTag = class
  private
    FName: string;
    FValue: string;
    FAtributes: TList<TAttribute>;
  public
    Constructor Create(const ByNode: TXMLNode=nil);overload;
    constructor Create(const NodeName: string; NodeValue:string='');overload;

    function IsEmpty: boolean;
    procedure Clear;
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
    property Value: string read FValue write FValue;
    property Name: string read FName write FName;
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
    Constructor Create(const ByNode: TXMLNode=nil);
    procedure ParseXML(Node: TXMLNode);
    function AddToXML(Root: TXMLNode): TXMLNode;
    property Rel:   string read Frel write Frel;
    property Ltype: string read Ftype write Ftype;
    property Href:  string read Fhref write Fhref;
    property Etag:  string read FEtag write FEtag;
  end;

type
  TAuthorTag = Class
  private
    FAuthor: string;
    FEmail : string;
    FUID   : string;
  public
    constructor Create(ByNode: IXMLNode=nil);
    procedure ParseXML(Node: IXMLNode);
    property Author: string read FAuthor write FAuthor;
    property Email: string read FEmail write FEmail;
  end;


function HexToColor(Color: string): TColor;
function ColorToHex(Color: TColor): string;
//преобразование строки 2007-07-11T21:50:15.000Z в TDateTime
function ServerDateToDateTime(cServerDate:string):TDateTime;
//преобразование TDateTime в строку 2007-07-11T21:50:15.000Z
function DateTimeToServerDate(DateTime:TDateTime):string;
//преобразование строк
function ArrayToStr(Values:array of string; Delimiter:char):string;
//работа с HTTP
function GetNewLocationURL(Headers: TStringList):string;
function SendRequest(const aMethod, aURL, aAuth, ApiVersion: string; aDocument:TStream=nil; aExtendedHeaders:TStringList=nil):TStream;


implementation

function ArrayToStr(Values:array of string; Delimiter:char):string;
var i:integer;
begin
  if length(Values)=0 then Exit;
  Result:=Values[0];
  for i:= 1 to Length(Values)-1 do
    Result:=Result+Delimiter+Values[i]
end;

function SendRequest(const aMethod, aURL, aAuth, ApiVersion: string; aDocument:TStream; aExtendedHeaders:TStringList):TStream;
var tmpURL:string;
    i:integer;
begin
  with THTTPSend.Create do
    begin
      Headers.Add('GData-Version: '+ApiVersion);
      Headers.Add('Authorization: GoogleLogin auth='+aAuth);
      MimeType := 'application/atom+xml';
      if aExtendedHeaders<>nil then
        begin
          for I:=0 to aExtendedHeaders.Count - 1 do
            Headers.Add(aExtendedHeaders[i])
        end;
      if aDocument<>nil then
         Document.LoadFromStream(aDocument);

      HTTPMethod(aMethod,aURL);
      if (ResultCode>200)and(ResultCode<400) then
        begin
          tmpURL:=GetNewLocationURL(Headers);
          Document.Clear;
          Headers.Clear;
          Headers.Add('GData-Version: 2');
          Headers.Add('Authorization: GoogleLogin auth='+aAuth);
          MimeType := 'application/atom+xml';
          if aExtendedHeaders<>nil then
            begin
              for I:=0 to aExtendedHeaders.Count - 1 do
                Headers.Add(aExtendedHeaders[i])
            end;
          if aDocument<>nil then
            Document.LoadFromStream(aDocument);
          HTTPMethod(aMethod,tmpURL);
        end;
        Result:=TStringStream.Create('');
        Headers.SaveToFile('headers.txt');
        Document.SaveToStream(Result);
        Result.Seek(0,soFromBeginning);
     end;
end;

function GetNewLocationURL(Headers: TStringList):string;
var i:integer;
begin
  if not Assigned(Headers) then Exit;
  for i:=0 to Headers.Count - 1 do
    begin
      if pos('location:',lowercase(Headers[i]))>0 then
        begin
          Result:=Trim(copy(Headers[i],10,length(Headers[i])-9));
          Exit;
        end;
    end;
end;

function DateTimeToServerDate(DateTime:TDateTime):string;
var Year, Mounth, Day, hours, Mins, Seconds,MSec: Word;
    aYear, aMounth, aDay, ahours, aMins, aSeconds,aMSec: string;
begin
  DecodeDateTime(DateTime,Year, Mounth, Day, hours, Mins, Seconds,MSec);
  aYear:=IntToStr(Year);
  if Mounth<10 then aMounth:='0'+IntToStr(Mounth)
  else aMounth:=IntToStr(Mounth);
  if Day<10 then aDay:='0'+IntToStr(Day)
  else aDay:=IntToStr(Day);
  if hours<10 then ahours:='0'+IntToStr(hours)
  else ahours:=IntToStr(hours);
  if Mins<10 then aMins:='0'+IntToStr(Mins)
  else aMins:=IntToStr(Mins);
  if Seconds<10 then aSeconds:='0'+IntToStr(Seconds)
  else aSeconds:=IntToStr(Seconds);

  case MSec of
    0..9:aMSec:='00'+IntToStr(MSec);
    10..99:aMSec:='0'+IntToStr(MSec);
    else
      aMSec:=IntToStr(MSec);
  end;
  Result:=aYear+'-'+aMounth+'-'+aDay+'T'+ahours+':'+aMins+':'+aSeconds+'.'+aMSec+'Z';
end;

function ServerDateToDateTime(cServerDate:string):TDateTime;
var Year, Mounth, Day, hours, Mins, Seconds,MSec: Word;
begin
  Year:=StrToInt(copy(cServerDate,1,4));
  Mounth:=StrToInt(copy(cServerDate,6,2));
  Day:=StrToInt(copy(cServerDate,9,2));
  if Length(cServerDate)>10 then
     begin
       hours:=StrToInt(copy(cServerDate,12,2));
       Mins:=StrToInt(copy(cServerDate,15,2));
       Seconds:=StrToInt(copy(cServerDate,18,2));
     end
  else
    begin
      hours:=0;
      Mins:=0;
      Seconds:=0;
    end;
  Result:=EncodeDateTime(Year, Mounth, Day, hours, Mins, Seconds,0)
end;

function ColorToHex(Color: TColor): string;
begin
  Result :=
  IntToHex(GetRValue(Color), 2 ) +
  IntToHex(GetGValue(Color), 2 ) +
  IntToHex(GetBValue(Color), 2 );
end;

function HexToColor(Color: string): TColor;
begin
if pos('#',Color)>0 then
  Delete(Color,1,1);
  Result :=
    RGB(
    StrToInt('$' + Copy(Color, 1, 2)),
    StrToInt('$' + Copy(Color, 3, 2)),
    StrToInt('$' + Copy(Color, 5, 2))
    );
end;

{ TTimeZoneList }

procedure TTimeZoneList.Clear;
var
  i: Integer;
  p: PTimeZone;
begin
  for i := 0 to Pred(Count) do
  begin
    p := TimeZone[i];
    if p <> nil then
      Dispose(p);
  end;
  inherited Clear;
end;


constructor TTimeZoneList.Create;
var i:integer;
    Zone:PTimeZone;
begin
  inherited Create;
  for i:=0 to High(GoogleTimeZones) do
    begin
      New(Zone);
      with Zone^ do
       begin
         gConst:=GoogleTimeZones[i,0];
         Desc:=GoogleTimeZones[i,1];
         GMT:=StrToFloat(GoogleTimeZones[i,2]);
         rus:=GoogleTimeZones[i,2]='rus';
       end;
       Add(Zone);
    end;
end;

destructor TTimeZoneList.Destroy;
begin
 Clear;
 inherited Destroy;
end;

function TTimeZoneList.GetRecord(index: Integer): PTimeZone;
begin
  Result:= PTimeZone(Items[index]);
end;

procedure TTimeZoneList.SetRecord(index: Integer; Ptr: PTimeZone);
var
  p: PTimeZone;
begin
  p := TimeZone[index];
  if p <> Ptr then
  begin
    if p <> nil then
      Dispose(p);
    Items[index] := Ptr;
  end;
end;


{ TTextTag }

function TTextTag.AddToXML(Root: TXMLNode): TXMLNode;
var
  i: integer;
begin
  if (Root=nil)or IsEmpty then Exit;
  Result:= Root.NodeNew(FName);
  Result.ValueAsString:=AnsiToUtf8(FValue);
  for i := 0 to FAtributes.Count - 1 do
    Result.AttributeAdd(FAtributes[i].Name,FAtributes[i].Value);
  //Root.ChildNodes.Add(Result);
end;

constructor TTextTag.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  FAtributes:=TList<TAttribute>.Create;
  Clear;
  if ByNode = nil then
    Exit;
  ParseXML(ByNode);
end;

procedure TTextTag.Clear;
begin
  FName:='';
  FValue:='';
  FAtributes.Clear;
end;

constructor TTextTag.Create(const NodeName: string; NodeValue: string);
begin
  inherited Create;
  FName:=NodeName;
  FValue:=NodeValue;
  FAtributes:=TList<TAttribute>.Create;
end;

function TTextTag.IsEmpty: boolean;
begin
  Result:=(Length(Trim(FName))=0)or
   ((Length(Trim(FValue))=0)and(FAtributes.Count=0));
end;

procedure TTextTag.ParseXML(Node: TXMLNode);
var
  i: integer;
  Attr: TAttribute;
begin
  try
    FValue := Node.ValueAsString;
    FName := Node.Name;
    for i := 0 to Node.AttributeCount - 1 do
    begin
      Attr.Name := Node.AttributeName[i];
      Attr.Value := Node.AttributeValue[i];
      FAtributes.Add(Attr)
    end;
  except
    Exception.Create(Format(rcErrPrepareNode, [Node.Name]));
  end;
end;

{ TAuthorTag }

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


{ TEntryLink }

function TEntryLink.AddToXML(Root: TXMLNode): TXMLNode;
begin

end;

constructor TEntryLink.Create(const ByNode: TXMLNode);
begin
  inherited Create;
  if ByNode<>nil then
    ParseXML(ByNode);
end;

procedure TEntryLink.ParseXML(Node: TXMLNode);
begin
  if Node=nil then Exit;
  try
    Frel:=Node.ReadAttributeString('rel');
    Ftype:=Node.ReadAttributeString('type');
    Fhref:=Node.ReadAttributeString('href');
    FEtag:=Node.ReadAttributeString('gd:etag')
  except
    Exception.Create(Format(rcErrPrepareNode, ['link']));
  end;
end;

end.
