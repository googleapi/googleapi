unit GoogleOAuth;

interface

uses SysUtils, Classes, httpsend, ssl_Openssl,character,synacode;

resourcestring
  rsRequestError = 'Ошибка выполнения запроса: %d - %s';

const
  redirect_uri='urn:ietf:wg:oauth:2.0:oob';
  oauth_url = 'https://accounts.google.com/o/oauth2/auth?client_id=%s&redirect_uri=%s&scope=%s&response_type=code';
  tokenurl='https://accounts.google.com/o/oauth2/token';
  tokenparams = 'client_id=%s&client_secret=%s&code=%s&redirect_uri=%s&grant_type=authorization_code';
  crefreshtoken = 'client_id=%s&client_secret=%s&refresh_token=%s&grant_type=refresh_token';
  AuthHeader = 'Authorization: OAuth %s';

  DefaultMime = 'application/json; charset=UTF-8';

  StripChars : set of char = ['"',':',','];

type
  TOAuth = class(TComponent)
  private
    FClientID: string;//id клиента
    FClientSecret: string;//секретный ключ клиента
    FScope   : string;//точка доступа
    FResponseCode: string;
    //Токен
    FAccess_token: string;
    FExpires_in: string;
    FRefresh_token:string;
    procedure SetClientID(const Value: string);
    procedure SetResponseCode(const Value: string);
    procedure SetScope(const Value: string);//код, который возвращает Google для доступа
    function  ParamValue(ParamName,JSONString: string):string;
    procedure SetClientSecret(Value: string);
    function PrepareParams(Params: TStrings): string;
  public
    constructor Create(AOwner: TComponent);override;
    destructor destroy; override;
    function AccessURL: string; //собирает URL для получения ResponseCode
    function GetAccessToken: string;
    function RefreshToken: string;

    function GETCommand(URL: string; Params: TStrings): RawBytestring;
    function POSTCommand(URL:string; Params:TStrings; Body:TStream; Mime:string = DefaultMime):RawByteString;
    function PUTCommand(URL:string; Body:TStream; Mime:string = DefaultMime):RawByteString;
    function DELETECommand(URL:string):RawByteString;

    //Параметры токена (сам токен, время действия, ключ для обновления
    property Access_token: string read FAccess_token;
    property Expires_in: string read FExpires_in;
    property Refresh_token:string read FRefresh_token;
    property ResponseCode: string read FResponseCode write SetResponseCode;
  published
    property ClientID: string read FClientID write SetClientID;
    property Scope   : string read FScope write SetScope;
    property ClientSecret: string read FClientSecret write SetClientSecret;
end;

implementation

{ TOAuth }

function TOAuth.AccessURL: string;
begin
  Result:=Format(oauth_url,[ClientID,redirect_uri,Scope]);
end;

constructor TOAuth.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

function TOAuth.DELETECommand(URL: string): RawByteString;
begin
with THTTPSend.Create do
  begin
    Headers.Add(Format(AuthHeader, [Access_token]));
    if HTTPMethod('DELETE', URL) then
    begin
      SetLength(Result, Document.Size);
      Move(Document.Memory^, Pointer(Result)^, Document.Size);
    end
    else
      raise Exception.CreateFmt(rsRequestError,[ResultCode,ResultString]);
  end;
end;

destructor TOAuth.destroy;
begin

  inherited;
end;

function TOAuth.GetAccessToken: string;
var Params: TStringStream;
    Response:string;
begin
  Params:=TStringStream.Create(Format(tokenparams,[ClientID,ClientSecret,ResponseCode,redirect_uri]));
  try
    Response:=POSTCommand(tokenurl,nil,Params,'application/x-www-form-urlencoded');
    FAccess_token:=ParamValue('access_token',Response);
    FExpires_in:=ParamValue('expires_in',Response);
    FRefresh_token:=ParamValue('refresh_token',Response);
    Result:=Access_token;
  finally
    Params.Free;
  end;
end;

function TOAuth.GETCommand(URL: string; Params: TStrings): RawBytestring;
var
  ParamString: string;
begin
  ParamString := PrepareParams(Params);
  with THTTPSend.Create do
  begin
    Headers.Add(Format(AuthHeader, [Access_token]));
    if HTTPMethod('GET', URL + ParamString) then
    begin
      SetLength(Result, Document.Size);
      Move(Document.Memory^, Pointer(Result)^, Document.Size);
    end
    else
    begin
      raise Exception.CreateFmt(rsRequestError,[ResultCode,ResultString]);
    end;
  end;
end;

function TOAuth.ParamValue(ParamName, JSONString: string): string;
var i,j:integer;
begin
  i:=pos(ParamName,JSONString);
  if i>0 then
    begin
      for j:= i+Length(ParamName) to Length(JSONString)-1 do
        if not (JSONString[j] in StripChars) then
          Result:=Result+JSONString[j]
        else
          if JSONString[j]=',' then
            break;
    end
  else
    Result:='';
end;

function TOAuth.POSTCommand(URL: string; Params: TStrings;
  Body: TStream; Mime:string): RawByteString;
var ParamString: string;
begin
ParamString := PrepareParams(Params);
  with THTTPSend.Create do
  begin
    MimeType:=Mime;
    Headers.Add(Format(AuthHeader, [Access_token]));
    if Body<>nil then
      begin
      Body.Position:=0;
      Document.LoadFromStream(Body);
      end;
    if HTTPMethod('POST', URL + ParamString) then
    begin
      SetLength(Result, Document.Size);
      Move(Document.Memory^, Pointer(Result)^, Document.Size);
    end
    else
    begin
      raise Exception.CreateFmt(rsRequestError,[ResultCode,ResultString]);
    end;
  end;
end;

function TOAuth.PrepareParams(Params: TStrings): string;
var
  S: string;
begin
  if Assigned(Params) then
    if Params.Count > 0 then
    begin
      for S in Params do
        Result := Result + EncodeURL(S) + '&';
      Delete(Result, Length(Result), 1);
      Result:='?'+Result;
      Exit;
    end;
  Result := '';
end;

function TOAuth.PUTCommand(URL: string; Body: TStream; Mime:string): RawByteString;
begin
with THTTPSend.Create do
  begin
    MimeType:=Mime;
    Headers.Add(Format(AuthHeader, [Access_token]));
    if Body<>nil then
      begin
        Body.Position:=0;
        Document.LoadFromStream(Body);
      end;
    if HTTPMethod('PUT', URL) then
    begin
      SetLength(Result, Document.Size);
      Move(Document.Memory^, Pointer(Result)^, Document.Size);
    end
    else
    begin
      raise Exception.CreateFmt(rsRequestError,[ResultCode,ResultString]);
    end;
  end;
end;

function TOAuth.RefreshToken: string;
var Params: TStringStream;
    Response: string;
begin
  Params:=TStringStream.Create(Format(crefreshtoken,[ClientID,ClientSecret,Refresh_token]));
  try
    Response:=POSTCommand(tokenurl,nil,Params,'application/x-www-form-urlencoded');
    FAccess_token:=ParamValue('access_token',Response);
    FExpires_in:=ParamValue('expires_in',Response);
    Result:=Access_token;
  finally
    Params.Free;
  end;
end;

procedure TOAuth.SetClientID(const Value: string);
begin
  FClientID := Value;
end;

procedure TOAuth.SetClientSecret(Value: string);
begin
  FClientSecret:=EncodeURL(Value)
end;

procedure TOAuth.SetResponseCode(const Value: string);
begin
  FResponseCode := Value;
end;

procedure TOAuth.SetScope(const Value: string);
begin
  FScope := Value;
end;

end.
