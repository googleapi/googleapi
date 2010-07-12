unit GHelper;

interface

uses Graphics,strutils,Windows,DateUtils,SysUtils, Variants,
Classes,StdCtrls,httpsend,Generics.Collections,xmlintf,xmldom,NativeXML,
GConsts;

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
    procedure Clear;override;
    destructor Destroy; override;
    property TimeZone[i: Integer]: PTimeZone read GetRecord write SetRecord;
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
var Year, Mounth, Day, hours, Mins, Seconds: Word;
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
  for i:=0 to High(sGoogleTimeZones) do
    begin
      New(Zone);
      with Zone^ do
       begin
         gConst:=sGoogleTimeZones[i,0];
         Desc:=sGoogleTimeZones[i,1];
         GMT:=StrToFloat(sGoogleTimeZones[i,2]);
         rus:=sGoogleTimeZones[i,2]='rus';
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

end.
