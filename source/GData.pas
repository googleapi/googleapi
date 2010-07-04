unit GData;

interface

uses strutils, GHelper, XMLIntf,SysUtils, Variants, Classes,
  StdCtrls, XMLDoc, xmldom, GDataCommon;

// элемены протокола
type
  TAuthorElement = record
    Email: string;
    Name: string;
  end;

type
  TLinkElement = record
    rel: string;
    typ: string;
    href: string;
  end;

type
  PLinkElement = ^TLinkElement;

type
  TLinkElementList = class(TList)
  private
    procedure SetRecord(index: Integer; Ptr: PLinkElement);
    function GetRecord(index: Integer): PLinkElement;
  public
    constructor Create;
    procedure Clear;
    destructor Destroy; override;
    property LinkElement[i: Integer]
      : PLinkElement read GetRecord write SetRecord;
  end;

type
  TGeneratorElement = record
    varsion: string;
    uri: string;
    name: string;
  end;

type
  TCategoryElement = record
    scheme: string;
    term: string;
    clabel: string;
  end;

type
  TCommonElements = array of IXMLNode;

type
  TGDElement = record
    ElementType : TgdEnum;
    XMLNode: IXMLNode;
end;

type
  PGDElement = ^TGDElement;

type
  TGDElemntList = class(TList)
  private
    procedure SetRecord(index: Integer; Ptr: PGDElement);
    function GetRecord(index: Integer): PGDElement;
  public
    constructor Create;
    procedure Clear;
    destructor Destroy; override;
    property GDElement[i: Integer]: PGDElement read GetRecord write SetRecord;

end;

type
  TEntryElement = class
  private
    FXMLNode: IXMLNode;
    FTerm: TEntryTerms;
    FEtag: string;
    FId: string;
    FTitle: string;
    FSummary: string;
    FContent: string;
    FAuthor: TAuthorElement;
    FCategory: TCategoryElement;
    FPublicationDate: TDateTime;
    FUpdateDate: TDateTime;
    FLinks: TLinkElementList;
    FCommonElements: TCommonElements;
    FGDElemntList:TGDElemntList;
    procedure GetBasicElements;
    function GetNodeName(aElementName: TgdEnum): string;
    procedure GetGDList;
    function GetEntryTerm: TEntryTerms;
  public
    constructor Create(aXMLNode: IXMLNode);
    function FindGDElement(aElementName: TgdEnum; var resNode: IXMLNode)
      : boolean;
    property ETag: string read FEtag;
    property ID: string read FId;
    property Title: string read FTitle;
    property Summary: string read FSummary;
    property Content: string read FContent;
    property Author: TAuthorElement read FAuthor;
    property Category: TCategoryElement read FCategory;
    property Publication: TDateTime read FPublicationDate;
    property Update: TDateTime read FUpdateDate;
    property Links: TLinkElementList read FLinks;
    property CommonElements: TCommonElements read FCommonElements;
    property GDElemntList:TGDElemntList read FGDElemntList;
    property Term: TEntryTerms read GetEntryTerm;
  end;




implementation



{ TLinkElementList }

procedure TLinkElementList.Clear;
var
  i: Integer;
  p: PLinkElement;
begin
  for i := 0 to Pred(Count) do
  begin
    p := LinkElement[i];
    if p <> nil then
      Dispose(p);
  end;
  inherited Clear;
end;

constructor TLinkElementList.Create;
begin
  inherited Create;
end;

destructor TLinkElementList.Destroy;
begin
  Clear;
  inherited Destroy;

end;

function TLinkElementList.GetRecord(index: Integer): PLinkElement;
begin
  Result := PLinkElement(Items[index]);
end;

procedure TLinkElementList.SetRecord(index: Integer; Ptr: PLinkElement);
var
  p: PLinkElement;
begin
  p := LinkElement[index];
  if p <> Ptr then
  begin
    if p <> nil then
      Dispose(p);
    Items[index] := Ptr;
  end;
end;

{ TEntryElemet }

constructor TEntryElement.Create(aXMLNode: IXMLNode);
var
  i: TgdEnum;
begin
  if aXMLNode = nil then
    Exit;
  FXMLNode := aXMLNode;
  FLinks := TLinkElementList.Create;
  FGDElemntList:=TGDElemntList.Create;
  GetBasicElements;
  GetGDList;
end;

function TEntryElement.FindGDElement(aElementName: TgdEnum;
  var resNode: IXMLNode): boolean;
var
  FindName: string;
  i: Integer;
  iNode: IXMLNode;

  procedure ProcessNode(Node: IXMLNode);
  var
    cNode: IXMLNode;
  begin
    if Node = nil then
      Exit;
    if LowerCase(FCommonElements[i].NodeName) = LowerCase(FindName) then
    begin
      resNode := FCommonElements[i];
      Exit;
    end
    else
    begin
      cNode := Node.ChildNodes.First;
      while cNode <> nil do
      begin
        ProcessNode(cNode);
        cNode := cNode.NextSibling;
      end;
    end;
  end;

begin
  resNode := nil;
  FindName := GetNodeName(aElementName);
  i := 0;
  iNode := FCommonElements[0]; // стартуем с первого элемента
  while (i > Length(FCommonElements)) or (resNode = nil) do
  begin
    ProcessNode(iNode); // Рекурсия
    i := i + 1;
    iNode := FCommonElements[i];
  end;
end;

procedure TEntryElement.GetBasicElements;
var
  i: Integer;
  LinkElement: PLinkElement;
begin
  if FXMLNode.Attributes['gd:etag'] <> null then
    FEtag := FXMLNode.Attributes['gd:etag'];
  for i := 0 to FXMLNode.ChildNodes.Count - 1 do
  begin
    if LowerCase(FXMLNode.ChildNodes[i].NodeName) = 'id' then
      FId := FXMLNode.ChildNodes[i].Text
    else
      if LowerCase(FXMLNode.ChildNodes[i].NodeName) = 'published' then
        FPublicationDate := ServerDateToDateTime(FXMLNode.ChildNodes[i].Text)
      else
        if LowerCase(FXMLNode.ChildNodes[i].NodeName) = 'updated' then
          FUpdateDate := ServerDateToDateTime(FXMLNode.ChildNodes[i].Text)
        else
          if LowerCase(FXMLNode.ChildNodes[i].NodeName) = 'category' then
          begin
            if FXMLNode.ChildNodes[i].Attributes['scheme'] <> null then
              FCategory.scheme := FXMLNode.ChildNodes[i].Attributes['scheme'];
            if FXMLNode.ChildNodes[i].Attributes['term'] <> null then
              FCategory.term := FXMLNode.ChildNodes[i].Attributes['term'];
          end
          else
            if LowerCase(FXMLNode.ChildNodes[i].NodeName) = 'title' then
              FTitle := FXMLNode.ChildNodes[i].Text
            else
              if LowerCase(FXMLNode.ChildNodes[i].NodeName) = 'content' then
                FContent := FXMLNode.ChildNodes[i].Text
              else
                if LowerCase(FXMLNode.ChildNodes[i].NodeName) = 'link' then
                begin
                  New(LinkElement);
                  with LinkElement^ do
                  begin
                    if FXMLNode.ChildNodes[i].Attributes['rel'] <> null then
                      rel := FXMLNode.ChildNodes[i].Attributes['rel'];
                    if FXMLNode.ChildNodes[i].Attributes['type'] <> null then
                      typ := FXMLNode.ChildNodes[i].Attributes['type'];
                    if FXMLNode.ChildNodes[i].Attributes['href'] <> null then
                      href := FXMLNode.ChildNodes[i].Attributes['href'];
                  end;
                  FLinks.Add(LinkElement);
                end
                else
                  if LowerCase(FXMLNode.ChildNodes[i].NodeName) = 'author' then
                  begin
                    if FXMLNode.ChildNodes[i].ChildNodes.FindNode('name')
                      <> nil then
                      FAuthor.Name := FXMLNode.ChildNodes[i].ChildNodes.FindNode
                        ('name').Text;
                    if FXMLNode.ChildNodes[i].ChildNodes.FindNode('email')
                      <> nil then
                      FAuthor.Name := FXMLNode.ChildNodes[i].ChildNodes.FindNode
                        ('email').Text;
                  end
                  else
                    if (LowerCase(FXMLNode.ChildNodes[i].NodeName)
                        = 'description') or
                      (LowerCase(FXMLNode.ChildNodes[i].NodeName) = 'summary')
                      then
                      FSummary := FXMLNode.ChildNodes[i].Text
                    else
                    begin
                      SetLength(FCommonElements, Length(FCommonElements) + 1);
                      FCommonElements[Length(FCommonElements) - 1] :=
                        FXMLNode.ChildNodes[i];
                    end;
  end;
end;

function TEntryElement.GetEntryTerm: TEntryTerms;
var
  TermStr: string;
begin
  FTerm := ttAny;
  if Length(FCategory.term) = 0 then
    Exit;
  TermStr := copy(FCategory.term, pos('#', FCategory.term) + 1, Length
      (FCategory.term) - pos('#', FCategory.term));
  if LowerCase(TermStr) = 'contact' then
    Result := ttContact
  else
    if LowerCase(TermStr) = 'event' then
      Result := ttEvent
    else
      if LowerCase(TermStr) = 'message' then
        Result := ttMessage
      else
        if LowerCase(TermStr) = 'type' then
          Result := ttType
end;

procedure TEntryElement.GetGDList;
var
  i: Integer;
  iNode: IXMLNode;

  procedure ProcessNode(Node: IXMLNode);
  var
    cNode: IXMLNode;
    Index: integer;
    NodeType: TgdEnum;
    GDElemet: PGDElement;
  begin
    if (Node = nil)or(pos('gd:',Node.NodeName)<=0) then Exit;
    Index:=GetGDNodeType(Node.NodeName);
    if index>-1 then
      begin
        NodeType:=TgdEnum(index);
        New(GDElemet);
        with GDElemet^ do
          begin
            ElementType:=NodeType;
            XMLNode:=Node;
          end;
        FGDElemntList.Add(GDElemet);
      //  ShowMessage(IntToStr(FGDElemntList.Count));
      end;

    cNode := Node.ChildNodes.First;
    while cNode <> nil do
      begin
        ProcessNode(cNode);
        cNode := cNode.NextSibling;
      end;
  end;

begin
//  i:=0;
//  iNode := FCommonElements[0]; // стартуем с первого элемента
  for I := 0 to Length(FCommonElements) - 1 do
    begin
       iNode:=FCommonElements[i];
       ProcessNode(iNode); // Рекурсия
    end;

end;

function TEntryElement.GetNodeName(aElementName: TgdEnum): string;
begin
Result:=cGDTagNames[ord(aElementName)];
//  case aElementName of
//    gdCountry:
//      Result := 'gd:country';
//    gdAdditionalName:
//      Result := 'gd:additionalName';
//    gdName:
//      Result := 'gd:country';
//    gdEmail:
//      Result := 'gd:email';
//    gdExtendedProperty:
//      Result := 'gd:extendedProperty';
//    gdGeoPt:
//      Result := 'gd:geoPt';
//    gdIm:
//      Result := 'gd:im';
//    gdOrgName:
//      Result := 'gd:orgName';
//    gdOrgTitle:
//      Result := 'gd:orgTitle';
//    gdOrganization:
//      Result := 'gd:organization';
//    gdOriginalEvent:
//      Result := 'gd:originalEvent';
//    gdPhoneNumber:
//      Result := 'gd:phoneNumber';
//    gdPostalAddress:
//      Result := 'gd:postalAddress';
//    gdRating:
//      Result := 'gd:rating';
//    gdRecurrence:
//      Result := 'gd:recurrence';
//    gdReminder:
//      Result := 'gd:reminder';
//    gdResourceId:
//      Result := 'gd:resourceId';
//    gdWhen:
//      Result := 'gd:when';
//    gdAgent:
//      Result := 'gd:agent';
//    gdHousename:
//      Result := 'gd:housename';
//    gdStreet:
//      Result := 'gd:street';
//    gdPobox:
//      Result := 'gd:pobox';
//    gdNeighborhood:
//      Result := 'gd:neighborhood';
//    gdCity:
//      Result := 'gd:city';
//    gdSubregion:
//      Result := 'gd:subregion';
//    gdRegion:
//      Result := 'gd:region';
//    gdPostcode:
//      Result := 'gd:postcode';
//    gdFormattedAddress:
//      Result := 'gd:formattedaddress';
//    gdStructuredPostalAddress:
//      Result := 'gd:structuredPostalAddress';
//    gdEntryLink:
//      Result := 'gd:entryLink';
//    gdWhere:
//      Result := 'gd:where';
//    gdFamilyName:
//      Result := 'gd:familyName';
//    gdGivenName:
//      Result := 'gd:givenName';
//    gdFamileName:
//      Result := 'gd:FamileName';
//    gdNamePrefix:
//      Result := 'gd:namePrefix';
//    gdNameSuffix:
//      Result := 'gd:nameSuffix';
//    gdFullName:
//      Result := 'gd:fullName';
//    gdOrgDepartment:
//      Result := 'gd:orgDepartment';
//    gdOrgJobDescription:
//      Result := 'gd:orgJobDescription';
//    gdOrgSymbol:
//      Result := 'gd:orgSymbol';
//    gdEventStatus:
//      Result := 'gd:eventStatus';
//    gdVisibility:
//      Result := 'gd:visibility';
//    gdTransparency:
//      Result := 'gd:transparency';
//    gdAttendeeType:
//      Result := 'gd:attendeeType';
//    gdAttendeeStatus:
//      Result := 'gd:attendeeStatus';
//  end;
end;

{ GDElemntList }

procedure TGDElemntList.Clear;
var
  i: Integer;
  p: PGDElement;
begin
  for i := 0 to Pred(Count) do
  begin
    p := GDElement[i];
    if p <> nil then
      Dispose(p);
  end;
  inherited Clear;
end;


constructor TGDElemntList.Create;
begin
  inherited Create;
end;

destructor TGDElemntList.Destroy;
begin
  Clear;
 inherited Destroy;
end;

function TGDElemntList.GetRecord(index: Integer): PGDElement;
begin
  Result:= PGDElement(Items[index]);
end;

procedure TGDElemntList.SetRecord(index: Integer; Ptr: PGDElement);
var
  p: PGDElement;
begin
  p := GDElement[index];
  if p <> Ptr then
  begin
    if p <> nil then
      Dispose(p);
    Items[index] := Ptr;
  end;
end;

end.
