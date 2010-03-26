unit InetFunctions;

interface

uses WinInet,strutils,Windows, Messages, SysUtils, Variants, Classes, Dialogs, StdCtrls;

type
  THTTPSender = class
  private
    FHeaders: TStringList;
    FAgent: string;
    FMethod: string;
    FProtocol: string;
    FPort: integer; //порт
    FDomain: string;   //домен без http
    FParamStr: string; //всё, что стоит в адресе после / кроме параметров
    FParameters: string;
    FResponseCode: integer;//код ответа сервера
    FResponseText: string;//строка ответа сервера
    FErrorCode: integer;
    FLocation : string;
    FBody: TStringStream;
    FCookies : TStringList;
    procedure ParseURL(var cURL:string);
    function  GetQueryInfo(hRequest:Pointer; Flag:integer):string;
    procedure ParseHeaders(HeasersStr: string);
    function GetServerCookies(const aURL:string):TStringList;
  public
    constructor Create;

    function SendRequest(fURL:string):WideString;
    property Headers: TStringList read FHeaders write FHeaders;
    property Agent: string read FAgent write FAgent;
    property Method: string read FMethod write FMethod;
    property Protocol:string read FProtocol write FProtocol;
    property ResponseCode: integer read FResponseCode;
    property ResponseText: string read FResponseText;
    property ErrorCode:integer read FErrorCode;
    property Location: string read FLocation;
    property Body:TStringStream read FBody write FBody;
    property Cookies: TStringList read FCookies write FCookies;
end;


implementation

{ THTTPSender }

constructor THTTPSender.Create;
begin
  inherited Create;
  FAgent:='NoName Agent';
  FMethod:='GET';
  FProtocol:='HTTP';
  FPort:=80;
  FHeaders:=TStringList.Create;
  FCookies:=TStringList.Create;
  FBody:=TStringStream.Create('');
end;

function THTTPSender.GetQueryInfo(hRequest: Pointer; Flag: integer): string;
var code: String;
    size,index:Cardinal;
begin
SetLength(code,8);//достаточная длина для чтения статус-кода
size:=Length(code);
index:=0;
if HttpQueryInfo(hRequest, Flag ,PChar(code),size,index)then
   Result:=Code
else
  if GetLastError=ERROR_INSUFFICIENT_BUFFER then //увеличиваем буффер
    begin
      SetLength(code,size);
      HttpQueryInfo(hRequest,Flag,PChar(code),size,index);
      Result:=code;
    end
  else
   begin
     FErrorCode:=GetLastError;
     Result:='';
   end;
end;

function THTTPSender.GetServerCookies(const aURL:string): TStringList;
var Size: cardinal;
    Data: string;
begin
Result:=TStringList.Create;
  if InternetGetCookie(PChar(aURL),nil,PChar(Data),Size) then
     Result.Text:=Data
  else
    if GetLastError=ERROR_INSUFFICIENT_BUFFER then
      begin
        SetLength(Data,Size);
        if InternetGetCookie(PChar(aURL),nil,PChar(Data),Size) then
           Result.Text:=Data
        else
          exit;
      end
    else
      Exit;
FCookies.Assign(Result);
end;

procedure THTTPSender.ParseHeaders(HeasersStr: string);
var i:integer;
    s: string;
begin
  if not Assigned(FHeaders)then FHeaders:=TStringList.Create;
  FHeaders.Clear;
  FHeaders.Text:=HeasersStr;
  FHeaders.Delete(FHeaders.Count-1); //последний элемент содержит всегда CRLF

  if FHeaders.Count>0 then
    begin
      S:=FHeaders[0];
      FProtocol:=copy(s,1,pos(' ',s)-1);
      Delete(s,1,Length(FProtocol)+1);
      FProtocol:=copy(FProtocol,1,pos('/',FProtocol)-1);
      FResponseCode:=StrToInt(copy(s,1,pos(' ',s)-1));
      Delete(s,1,Length(IntToStr(FResponseCode))+1);
      FResponseText:=Trim(s);
//      if (ResponseCode=HTTP_STATUS_MOVED)or(ResponseCode=HTTP_STATUS_REDIRECT) then
        for I := 0 to FHeaders.Count - 1 do
          begin
            if pos('location:',lowercase(FHeaders[i]))>0 then
               FLocation:=LowerCase(FProtocol)+'//'+FDomain+'/'+Trim(copy(FHeaders[i],10,length(FHeaders[i])-9))
            else
              if pos('set-cookie:',lowercase(FHeaders[i]))>0 then
                FCookies.Add(Trim(copy(FHeaders[i],12,length(FHeaders[i])-11)));
          end;
    end;
end;

procedure THTTPSender.ParseURL(var cURL: string);
var lencurl: cardinal;
    aURL: string;
    aURLc: TURLComponents;
begin
  lencurl:=INTERNET_MAX_URL_LENGTH;
  if pos('http',cURL)<=0 then
    cURL:='http://'+cURL;
  SetLength(aURL, lencurl);
//каноникализируем URL
  InternetCanonicalizeUrl(PChar(cURL),PChar(aURL),lencurl,ICU_BROWSER_MODE);
//разбиваем УРЛ на составные части
with aURLc do
  begin
    lpszscheme := nil;
    dwschemelength := internet_max_scheme_length;
    lpszhostname := nil;
    dwhostnamelength := internet_max_host_name_length;
    lpszusername := nil;
    dwusernamelength := internet_max_user_name_length;
    lpszpassword := nil;
    dwpasswordlength := internet_max_password_length;
    lpszurlpath := nil;
    dwurlpathlength := internet_max_path_length;
    lpszextrainfo := nil;
    dwextrainfolength := internet_max_path_length;
    dwstructsize := sizeof(aurl);
  end;

if InternetCrackUrl(PChar(aURL), Length(aURL), 0, aURLC) then
  begin
    if aURLc.lpszUrlPath='/' then
      FDomain:=ReplaceStr(aURLC.lpszHostName,'/','')
    else
      begin
        FDomain:=copy(aURLC.lpszHostName,1,length(aURLC.lpszHostName)-length(aURLC.lpszUrlPath));
      end;
    FPort:=aURLc.nPort;
    FParamStr:=aURLc.lpszUrlPath;
 //   FParameters:=aURLc.lpszExtraInfo;
    case aURLc.nScheme of
      INTERNET_SCHEME_DEFAULT:FProtocol:='HTTP';
      INTERNET_SCHEME_FTP:FProtocol:='FTP';
      INTERNET_SCHEME_HTTP:FProtocol:='HTTP';
      INTERNET_SCHEME_HTTPS:FProtocol:='HTTPS';
      INTERNET_SCHEME_FILE:FProtocol:='FILE';
      INTERNET_SCHEME_MAILTO:FProtocol:='MAILTO';
    end;
  end
else
  MessageBox(0, PChar('Ошибка WinInet #'+IntToStr(GetLastError)),'Ошибка', MB_OK);
end;

function THTTPSender.SendRequest(fURL: string): WideString;
  function DataAvailable(hRequest: pointer; out Size : cardinal): boolean;
  begin
    result := wininet.InternetQueryDataAvailable(hRequest, Size, 0, 0);
  end;
var hInet: pointer;
    hConnect: pointer;
    hRequest: HINTERNET;
    i:integer;
    heads: string;
    B          : boolean;
    Buff       : ANSIString;
    ReadedSize : cardinal;
    L          : cardinal;
begin
try
GetServerCookies(fURL);
  hInet:=InternetOpenW(PChar(FAgent),INTERNET_OPEN_TYPE_PRECONFIG, nil, nil,0);
  if hInet<>nil then
    begin
      ParseURL(fURL);
      if FProtocol='HTTP' then
         hConnect:=InternetConnect(hInet, PChar(FDomain), INTERNET_DEFAULT_HTTP_PORT,'anonymous', nil, INTERNET_SERVICE_HTTP, 0, 0)
      else
        if FProtocol='HTTPS' then
          hConnect:=InternetConnect(hInet, PChar(FDomain), INTERNET_DEFAULT_HTTPS_PORT,'anonymous', nil, INTERNET_SERVICE_HTTP, 0, 0);
        if hConnect<>nil then
           hRequest:=HttpOpenRequest(hConnect,PChar(FMethod),PChar(FParamStr),nil,nil,nil,INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_NO_AUTO_REDIRECT,0);
        if hRequest<>nil then
          begin //пробуем добавить заголовки и куки
            for i:=0 to FCookies.Count-1 do
              begin
                if heads <> '' then
                  heads:=heads+ '; ';
                  heads:=heads+FCookies[i];
              end;
            if heads<>'' then
               FHeaders.Insert(0, 'Cookie: ' + heads);
            if FHeaders.Count>0 then
                begin
                  heads:='';
                  for i:= 0 to FHeaders.Count - 1 do
                    heads:=heads+FHeaders[i]+#10#13;
                  HttpAddRequestHeaders(hRequest,PChar(heads),length(PChar(heads)),HTTP_ADDREQ_FLAG_ADD);
                end;
            if HttpSendRequest(hRequest,PChar(heads),length(PChar(heads)),PChar(FBody.DataString),FBody.Size)then
                begin
                  ParseHeaders(GetQueryInfo(hRequest, HTTP_QUERY_RAW_HEADERS_CRLF));
                  SetLength(Buff, 1);
                  B:=false;
                  I:=1;
                  FBody.Clear;
                  while true do
                    begin
                      DataAvailable(hRequest, L);
                      if L = 0 then break;
                      SetLength(Buff, I + L);
                      B:=InternetReadFile(hRequest, @Buff[I], L, ReadedSize);
                      if NOT B then break;
                      inc(I, ReadedSize);
                   end;
                  Buff[I] := #0;
                  if B then
                    begin
                      result:=WideString(Buff);
                      FBody.WriteString(Result);
                   end
                 else result := '';
                end;
        end
      else
        Exit;
    end;
finally
  InternetCloseHandle(hInet);
  InternetCloseHandle(hConnect);
  InternetCloseHandle(hRequest);
end;
end;

end.
