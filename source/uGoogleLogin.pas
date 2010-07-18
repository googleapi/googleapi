{*******************************************************}
{                                                       }
{             Delphi & Google API                       }
{                                                       }
{              File: uGoogleLogin                       }
{          Copyright (c) WebDelphi.ru                   }
{             All Rights Reserved.                      }
{                                                       }
{                                                       }
{                                                       }
{*******************************************************}

{*******************************************************}
{             GoogleLogin Component                     }
{*******************************************************}

unit uGoogleLogin;

interface

uses WinInet, StrUtils, SysUtils, Classes,Windows;

resourcestring
  rcNone = 'Аутентификация не производилась или сброшена';
  rcOk = 'Аутентификация прошла успешно';
  rcBadAuthentication ='Не удалось распознать имя пользователя или пароль, использованные в запросе на вход';
  rcNotVerified ='Адрес электронной почты, связанный с аккаунтом, не был подтвержден';
  rcTermsNotAgreed ='Пользователь не принял условия использования службы';
  rcCaptchaRequired ='Требуется ответ на тест CAPTCHA';
  rcUnknown ='Неизвестная ошибка';
  rcAccountDeleted ='Аккаунт этого пользователя удален';
  rcAccountDisabled ='Аккаунт этого пользователя отключен';
  rcServiceDisabled ='Доступ пользователя к указанной службе запрещен';
  rcServiceUnavailable ='Служба недоступна, повторите попытку позже';
  rcDisconnect ='Соединение с сервером разорвано';
  //ошибки соединения
  rcErrServer='На сервере произошла ошибка #';
  rcErrDont= 'Не могу получить описание ошибки';

const
  DefaultAppName = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.2.6) Gecko/20100625 Firefox/3.6.6';

  Flags_Connection = INTERNET_DEFAULT_HTTPS_PORT;

  Flags_Request = INTERNET_FLAG_RELOAD or
                  INTERNET_FLAG_IGNORE_CERT_CN_INVALID or
                  INTERNET_FLAG_NO_CACHE_WRITE or
                  INTERNET_FLAG_SECURE or
                  INTERNET_FLAG_PRAGMA_NOCACHE or
                  INTERNET_FLAG_KEEP_CONNECTION;

  Errors : array [0..8] of string = ('BadAuthentication','NotVerified',
                                      'TermsNotAgreed','CaptchaRequired','Unknown','AccountDeleted',
                                      'AccountDisabled', 'ServiceDisabled','ServiceUnavailable');

type
  TAccountType = (atNone ,atGOOGLE, atHOSTED, atHOSTED_OR_GOOGLE);

type
  TLoginResult = (lrNone,lrOk, lrBadAuthentication, lrNotVerified,
                  lrTermsNotAgreed, lrCaptchaRequired, lrUnknown,
                  lrAccountDeleted, lrAccountDisabled, lrServiceDisabled,
                  lrServiceUnavailable);

type
  TServices = (tsNone,tsAnalytics,tsApps,tsGBase,tsSites,tsBlogger,tsBookSearch,
               tsCelendar,tcCodeSearch,tsContacts,tsDocLists,tsFinance,
               tsGMailFeed,tsHealth,tsMaps,tsPicasa,tsSidewiki,tsSpreadsheets,
               tsWebmaster,tsYouTube);

const
  ServiceIDs: array[0..19]of string=('xapi','analytics','apps','gbase',
                                    'jotspot','blogger','print','cl','codesearch','cp','writely','finance',
                                    'mail','health','local','lh2','annotateweb','wise','sitemaps','youtube');

type
  TResultRec = packed record
    LoginStr:string;//текстовый результат авторизации
    SID : string;//в настоящее время не используется
    LSID : string;//в настоящее время не используется
    Auth : string;
  end;

type
  TAutorization = procedure (const LoginResult: TLoginResult; Result:TResultRec)of object;//авторизировались
  TErrorAutorization = procedure (const ErrorStr:string)of object;//а это не авторизировались))
  TDisconnect = procedure (const ResultStr:string)of object;

type
  //поток используется только для получения HTML страницы
  TGoogleLoginThread = class(TThread)
  private
    { private declarations }
    FParamStr     : string;//параметры запроса
    FLogintoken   : string;
    //данные ответа/запроса
    FResultRec:TResultRec;//структура для передачи результатов
    FCaptchaURL : string;

    FLastResult : TLoginResult;//результаты авторизации

    //События
    FAutorization : TAutorization;//авторизация
    FErrorAutorization : TErrorAutorization;

    function ExpertLoginResult(const LoginResult:string):TLoginResult;//анализ результата авторизации
    function GetLoginError(const str: string):TLoginResult;//получаем тип ошибки

    function GetCaptchaURL(const cList:TStringList):string;//ссылка на капчу
    function GetCaptchaToken(const cList:TStringList):String;

    function GetResultText:string;

    function GetErrorText(const FromServer: BOOLEAN): string;//получаем текст ошибки

    procedure SynAutoriz;//передача значения авторизации в главную форму как положено в потоке
    procedure SynErrAutoriz;//передача значения ошибки в главную форму как положено в потоке
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(CreateSuspennded: Boolean;aParamStr:string);//используем для передачи логина и пароля и подобного
    procedure Execute;override;//выполняем непосредственно авторизацию на сайте
  published
    { published declarations }
    //события
    property OnAutorization:TAutorization  read FAutorization write FAutorization;//авторизировались
    property OnError:TErrorAutorization read FErrorAutorization write FErrorAutorization;//возникла ошибка ((
  end;

  //"шкурка" компонента
  TGoogleLogin = class(TComponent)
  private
    //Поток
    FThread:TGoogleLoginThread;
    //регистрационные данные
    FAppname      : string; //строка символов, которая передается серверу и идентифицирует программное обеспечение, пославшее запрос.
    FAccountType  : TAccountType;
    FLastResult   : TLoginResult;
    FEmail        : string;
    FPassword     : string;
    //данные ответа/запроса
    //FSID          : string;//в настоящее время не используется
    //FLSID         : string;//в настоящее время не используется
    //FAuth         : string;
    FService      : TServices;//сервис к которому необходимо получить доступ
    FLogintoken   : string;
    FLogincaptcha : string;

    //параметры Captcha
    FCaptchaURL   : string;

    FAfterLogin:TAutorization;
    FErrorAutorization : TErrorAutorization;

    FDisconnect   : TDisconnect;
    function SendRequest(const ParamStr: string):AnsiString;//отправляем запрос на сервер
    procedure SetEmail(cEmail:string);
    procedure SetPassword(cPassword:string);
    procedure SetService(cService:TServices);
    procedure SetCaptcha(cCaptcha:string);
    procedure SetAppName(value:string);
    ////////////////вспомогательные функции//////////////////////////
    function DigitToHex(Digit: Integer): Char;
    //кодирование url
    function URLEncode(const S: string): string;
    //декодирование url
    function URLDecode(const S: string): string;//не используется
  public
    constructor Create(AOwner: TComponent);override;
    procedure Login(aLoginToken:string='';aLoginCaptcha:string=''); //формируем запрос
    procedure Disconnect;//удаляет все данные по авторизации
    property LastResult: TLoginResult read FLastResult;
//    property Auth: string read FAuth;
//    property SID: string read FSID;
//    property LSID: string read FLSID;
//    property CaptchaURL: string read FCaptchaURL;
//    property LoginToken: string read FLogintoken;
//    property LoginCaptcha: string read FLogincaptcha write FLogincaptcha;
  published
    property AppName:string  read FAppname write SetAppName;
    property AccountType: TAccountType read FAccountType write FAccountType;
    property Email: string read FEmail write SetEmail;
    property Password:string read FPassword write SetPassword;
    property Service: TServices read FService write SetService;
    property OnAutorization :TAutorization read FAfterLogin write FAfterLogin;
    property OnError:TErrorAutorization read FErrorAutorization write FErrorAutorization;//возникла ошибка ((
    property OnDisconnect: TDisconnect read FDisconnect write FDisconnect;
end;


procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('WebDelphi.ru',[TGoogleLogin]);
end;

{ TGoogleLogin }

function TGoogleLogin.DigitToHex(Digit: Integer): Char;
begin
  case Digit of
    0..9: Result := Chr(Digit + Ord('0'));
    10..15: Result := Chr(Digit - 10 + Ord('A'));
  else
    Result := '0';
  end;
end;

procedure TGoogleLogin.Disconnect;
begin
  FAccountType:=atNone;
  FLastResult:=lrNone;
//  FSID:='';
//  FLSID:='';
//  FAuth:='';
  FLogintoken:='';
  FLogincaptcha:='';
  FCaptchaURL:='';
  FLogintoken:='';
  if Assigned(FThread) then
    FThread.Terminate;
  if Assigned(FDisconnect) then
    OnDisconnect(rcDisconnect)
end;

constructor TGoogleLogin.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAppname:=DefaultAppName;//дефолтное значение
end;
{
function TGoogleLogin.ExpertLoginResult(const LoginResult: string): TLoginResult;
var List: TStringList;
    i:integer;
begin
  //грузим ответ сервера в список
  List:=TStringList.Create;
  List.Text:=LoginResult;
  //анализируем построчно
  if pos('error',LowerCase(LoginResult))>0 then //есть сообщение об ошибке
  begin
    for i:=0 to List.Count-1 do
    begin
      if pos('error',LowerCase(List[i]))>0 then //строка с ошибкой
      begin
        Result:=GetLoginError(List[i]);//получили тип ошибки
        break;
      end;
    end;
    if Result=lrCaptchaRequired then //требуется ввод каптчи
    begin
      FCaptchaURL:=GetCaptchaURL(List);
      FLogintoken:=GetCaptchaToken(List);
    end;
  end
  else
  begin
    Result:=lrOk;
    for i:=0 to List.Count-1 do
    begin
      if pos('SID',UpperCase(List[i]))>0 then
        FSID:=Trim(copy(List[i],pos('=',List[i])+1,Length(List[i])-pos('=',List[i])))
      else
      if pos('LSID',UpperCase(List[i]))>0 then
        FLSID:=Trim(copy(List[i],pos('=',List[i])+1,Length(List[i])-pos('=',List[i])))
      else
      if pos('AUTH',UpperCase(List[i]))>0 then
        FAuth:=Trim(copy(List[i],pos('=',List[i])+1,Length(List[i])-pos('=',List[i])));
    end;
  end;
  FreeAndNil(List);
end;
}
{
function TGoogleLogin.GetCaptchaToken(const cList: TStringList): String;
var i:integer;
begin
  for I := 0 to cList.Count - 1 do
  begin
    if pos('captchatoken',lowerCase(cList[i]))>0 then
    begin
      Result:=Trim(copy(cList[i],pos('=',cList[i])+1,Length(cList[i])-pos('=',cList[i])));
      break;
    end;
  end;
end;
}
{
function TGoogleLogin.GetCaptchaURL(const cList: TStringList): string;
var i:integer;
begin
  for I := 0 to cList.Count - 1 do
  begin
    if pos('captchaurl',lowerCase(cList[i]))>0 then
    begin
      Result:=Trim(copy(cList[i],pos('=',cList[i])+1,Length(cList[i])-pos('=',cList[i])));
      break;
    end;
  end;
end;
}
{
function TGoogleLogin.GetLoginError(const str: string): TLoginResult;
var ErrorText:string;
begin
  //получили текст ошибки
  ErrorText:=Trim(copy(str,pos('=',str)+1,Length(str)-pos('=',str)));
  Result:=TLoginResult(AnsiIndexStr(ErrorText,Errors)+2);
end;
}
{
function TGoogleLogin.GetResultText: string;
begin
  case FLastResult of
    lrNone: Result:=rcNone;
    lrOk: Result:=rcOk;
    lrBadAuthentication: Result:=rcBadAuthentication;
    lrNotVerified: Result:=rcNotVerified;
    lrTermsNotAgreed: Result:=rcTermsNotAgreed;
    lrCaptchaRequired: Result:=rcCaptchaRequired;
    lrUnknown: Result:=rcUnknown;
    lrAccountDeleted: Result:=rcAccountDeleted;
    lrAccountDisabled: Result:=rcAccountDisabled;
    lrServiceDisabled: Result:=rcServiceDisabled;
    lrServiceUnavailable: Result:=rcServiceUnavailable;
  end;
end;
}
procedure TGoogleLogin.Login(aLoginToken, aLoginCaptcha: string);
var cBody: TStringStream;
    ResponseText: string;
begin
  cBody:=TStringStream.Create('');
  case FAccountType of
    atNone,atHOSTED_OR_GOOGLE:cBody.WriteString('accountType=HOSTED_OR_GOOGLE&');
    atGOOGLE:cBody.WriteString('accountType=GOOGLE&');
    atHOSTED:cBody.WriteString('accountType=HOSTED&');
  end;
  cBody.WriteString('Email='+FEmail+'&');
  cBody.WriteString('Passwd='+URLEncode(FPassword)+'&');
  cBody.WriteString('service='+ServiceIDs[ord(FService)]+'&');

  if Length(Trim(FAppname))>0 then
    cBody.WriteString('source='+FAppname)
  else
    cBody.WriteString('source='+DefaultAppName);
  if Length(Trim(aLoginToken))>0 then
  begin
    cBody.WriteString('&logintoken='+aLoginToken);
    cBody.WriteString('&logincaptcha='+aLoginCaptcha);
  end;
  //отправляем запрос на сервер
  ResponseText:=SendRequest(cBody.DataString);
{
  //проанализировали результат и заполнили необходимые поля
  Result:=ExpertLoginResult(ResponseText);
  FLastResult:=Result;
  if Assigned(FAfterLogin) then
    OnAfterLogin(FLastResult,GetResultText)
}
end;

function TGoogleLogin.SendRequest(const ParamStr: string): AnsiString;
begin
  //отправляем запрос на сервер в отдельном потоке
  FThread:=TGoogleLoginThread.Create(true,ParamStr);
  FThread.OnAutorization:=Self.OnAutorization;
  FThread.OnError:=Self.OnError;
  FThread.FreeOnTerminate:=True;//чтобы сам себя грухнул после окончания операции
  FThread.Resume;//запуск
  //тут делать смысла что то нет так как данные еще не получены(они ведь будут получены в другом потоке)
end;

//устанавливаем значение строки символов, которая передается серверу
// идентифицирует программное обеспечение, пославшее запрос.
procedure TGoogleLogin.SetAppName(value: string);
begin
  if not (value ='') then
    FAppname:=value
  else
    FAppname:=DefaultAppName;
end;

procedure TGoogleLogin.SetCaptcha(cCaptcha: string);
begin
  FLogincaptcha:=cCaptcha;
  Login(FLogintoken,FLogincaptcha);//перелогиниваемся с каптчей
end;

procedure TGoogleLogin.SetEmail(cEmail: string);
begin
  FEmail:=cEmail;
  if FLastResult=lrOk then
    Disconnect;//обнуляем результаты
end;

procedure TGoogleLogin.SetPassword(cPassword: string);
begin
  FPassword:=cPassword;
  if FLastResult=lrOk then
    Disconnect;//обнуляем результаты
end;

procedure TGoogleLogin.SetService(cService: TServices);
begin
  FService:=cService;
  if FLastResult=lrOk then
    begin
      Disconnect;//обнуляем результаты
      Login;    //перелогиниваемся
    end;
end;
{
procedure TGoogleLogin.SetSource(cSource: string);
begin
  FSource:=cSource;
  if FLastResult=lrOk then
    Disconnect;//обнуляем результаты
end;
}
function TGoogleLogin.URLDecode(const S: string): string;
var
  i, idx, len, n_coded: Integer;
  function WebHexToInt(HexChar: Char): Integer;
  begin
    if HexChar < '0' then
      Result := Ord(HexChar) + 256 - Ord('0')
    else if HexChar <= Chr(Ord('A') - 1) then
      Result := Ord(HexChar) - Ord('0')
    else if HexChar <= Chr(Ord('a') - 1) then
      Result := Ord(HexChar) - Ord('A') + 10
    else
      Result := Ord(HexChar) - Ord('a') + 10;
  end;
begin
  len := 0;
  n_coded := 0;
  for i := 1 to Length(S) do
    if n_coded >= 1 then
    begin
      n_coded := n_coded + 1;
      if n_coded >= 3 then
      n_coded := 0;
    end
    else
    begin
      len := len + 1;
      if S[i] = '%' then
      n_coded := 1;
    end;
  SetLength(Result, len);
  idx := 0;
  n_coded := 0;
  for i := 1 to Length(S) do
    if n_coded >= 1 then
    begin
      n_coded := n_coded + 1;
      if n_coded >= 3 then
      begin
        Result[idx] := Chr((WebHexToInt(S[i - 1]) * 16 +
        WebHexToInt(S[i])) mod 256);
        n_coded := 0;
      end;
    end
    else
    begin
      idx := idx + 1;
      if S[i] = '%' then
       n_coded := 1;
      if S[i] = '+' then
       Result[idx] := ' '
      else
       Result[idx] := S[i];
    end;

end;

{
RUS
кодирование URL исправило проблему с тем, что если в пароле пользователя есть
спец символ то теперь, он проходит авторизацию корректно
просто при отправке запроса серверу спец символ просто отбрасывался
на счет логина не проверял!
US google translator
URL encoding correct a problem with the fact that if a user password is
special character but now he goes through the authorization correctly
just when you query the server special character is simply discarded
the account login is not checked!
}

function TGoogleLogin.URLEncode(const S: string): string;
var
  i, idx, len: Integer;
begin
  len := 0;
  for i := 1 to Length(S) do
    if ((S[i] >= '0') and (S[i] <= '9')) or
        ((S[i] >= 'A') and (S[i] <= 'Z')) or
        ((S[i] >= 'a') and (S[i] <= 'z')) or (S[i] = ' ') or
        (S[i] = '_') or (S[i] = '*') or (S[i] = '-') or (S[i] = '.') then
            len := len + 1
    else
      len := len + 3;
  SetLength(Result, len);
  idx := 1;
  for i := 1 to Length(S) do
    if S[i] = ' ' then
    begin
      Result[idx] := '+';
      idx := idx + 1;
    end
    else if ((S[i] >= '0') and (S[i] <= '9')) or
            ((S[i] >= 'A') and (S[i] <= 'Z')) or
            ((S[i] >= 'a') and (S[i] <= 'z')) or
            (S[i] = '_') or (S[i] = '*') or (S[i] = '-') or (S[i] = '.') then
    begin
      Result[idx] := S[i];
      idx := idx + 1;
    end
    else
    begin
      Result[idx] := '%';
      Result[idx + 1] := DigitToHex(Ord(S[i]) div 16);
      Result[idx + 2] := DigitToHex(Ord(S[i]) mod 16);
      idx := idx + 3;
    end;
end;

{ TGoogleLoginThread }

constructor TGoogleLoginThread.Create(CreateSuspennded: Boolean;aParamStr:string);
begin
  inherited Create(CreateSuspennded);
  FParamStr:=aParamStr;
  FResultRec.LoginStr:='';
  FResultRec.SID:='';
  FResultRec.LSID:='';
  FResultRec.Auth:='';
end;

procedure TGoogleLoginThread.Execute;
  function DataAvailable(hRequest: pointer; out Size : cardinal): boolean;
  begin
    result := wininet.InternetQueryDataAvailable(hRequest, Size, 0, 0);
  end;
var
  hInternet,hConnect,hRequest : Pointer;
  dwBytesRead,I,L : Cardinal;
  sTemp:AnsiString;//текст страницы
begin
  try
    hInternet := InternetOpen(PChar('GoogleLogin'),INTERNET_OPEN_TYPE_PRECONFIG,Nil,Nil,0);
    if Assigned(hInternet) then
    begin
      //Открываем сессию
      hConnect := InternetConnect(hInternet,PChar('www.google.com'),Flags_connection,nil,nil,INTERNET_SERVICE_HTTP,0,1);
      if Assigned(hConnect) then
        begin
          //Формируем запрос
          hRequest := HttpOpenRequest(hConnect,PChar(uppercase('post')),PChar('accounts/ClientLogin?'+FParamStr),HTTP_VERSION,nil,Nil,Flags_Request,1);
          if Assigned(hRequest) then
            begin
              //Отправляем запрос
              I := 1;
              if HttpSendRequest(hRequest,nil,0,nil,0) then
                begin
                  repeat
                    DataAvailable(hRequest, L);//Получаем кол-во принимаемых данных
                    if L = 0 then break;
                    SetLength(sTemp,L + I);
                    if not InternetReadFile(hRequest,@sTemp[I],sizeof(L),dwBytesRead) then break;//Получаем данные с сервера
                    inc(I,dwBytesRead);
                    if Terminated then //проверка для экстренного закрытия потока
                    begin
                        InternetCloseHandle(hRequest);
                        InternetCloseHandle(hConnect);
                        InternetCloseHandle(hInternet);
                        Exit;
                    end;
                  until dwBytesRead = 0;
                  sTemp[I] := #0;
                end;
            end;
        end;
    end;
  except
    Synchronize(SynErrAutoriz);
    Exit;//сваливаем отсюда
  end;
  InternetCloseHandle(hRequest);
  InternetCloseHandle(hConnect);
  InternetCloseHandle(hInternet);
  //получаем результаты авторизации
  FLastResult:=ExpertLoginResult(sTemp);
  FResultRec.LoginStr:=GetResultText;
  Synchronize(SynAutoriz);
end;

function TGoogleLoginThread.ExpertLoginResult(const LoginResult: string): TLoginResult;
var List: TStringList;
    i:integer;
begin
  //грузим ответ сервера в список
  List:=TStringList.Create;
  List.Text:=LoginResult;
  //анализируем построчно
  if pos('error',LowerCase(LoginResult))>0 then //есть сообщение об ошибке
  begin
    for i:=0 to List.Count-1 do
    begin
      if pos('error',LowerCase(List[i]))>0 then //строка с ошибкой
      begin
        Result:=GetLoginError(List[i]);//получили тип ошибки
        break;
      end;
    end;
    if Result=lrCaptchaRequired then //требуется ввод каптчи
    begin
      FCaptchaURL:=GetCaptchaURL(List);
      FLogintoken:=GetCaptchaToken(List);
    end;
  end
  else
  begin
    Result:=lrOk;
    for i:=0 to List.Count-1 do
    begin
      if pos('SID',UpperCase(List[i]))>0 then
        FResultRec.SID:=Trim(copy(List[i],pos('=',List[i])+1,Length(List[i])-pos('=',List[i])))
      else
      if pos('LSID',UpperCase(List[i]))>0 then
        FResultRec.LSID:=Trim(copy(List[i],pos('=',List[i])+1,Length(List[i])-pos('=',List[i])))
      else
      if pos('AUTH',UpperCase(List[i]))>0 then
        FResultRec.Auth:=Trim(copy(List[i],pos('=',List[i])+1,Length(List[i])-pos('=',List[i])));
    end;
  end;
  FreeAndNil(List);
end;

function TGoogleLoginThread.GetCaptchaToken(const cList: TStringList): String;
var i:integer;
begin
  for I := 0 to cList.Count - 1 do
  begin
    if pos('captchatoken',lowerCase(cList[i]))>0 then
    begin
      Result:=Trim(copy(cList[i],pos('=',cList[i])+1,Length(cList[i])-pos('=',cList[i])));
      break;
    end;
  end;
end;

function TGoogleLoginThread.GetCaptchaURL(const cList: TStringList): string;
var i:integer;
begin
  for I := 0 to cList.Count - 1 do
  begin
    if pos('captchaurl',lowerCase(cList[i]))>0 then
    begin
      Result:=Trim(copy(cList[i],pos('=',cList[i])+1,Length(cList[i])-pos('=',cList[i])));
      break;
    end;
  end;
end;

//Если параметр FromServer TRUE, то код ошибки и её текст берется с сервера, в противном случае берется текст локальной ошибки.
function TGoogleLoginThread.GetErrorText(const FromServer: BOOLEAN): string;
var
  Msg: array[0..1023] of Char;
  ErCode, Len: Cardinal;
begin
  Len := SizeOf(Msg);
  ZeroMemory(@Msg, SizeOf(Msg));
  if FromServer then
    if InternetGetLastResponseInfo(ErCode, @Msg, Len) then
      Result := rcErrServer + IntToStr(ErCode) + #13 + StrPas( Msg )
    else
      Result := rcErrDont
  else if FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,nil, GetLastError,GetKeyboardLayout(0),@Msg, SizeOf(Msg), nil) <> 0 then
    Result := StrPas(Msg)
  else
    Result := rcErrDont;
end;


function TGoogleLoginThread.GetLoginError(const str: string): TLoginResult;
var ErrorText:string;
begin
  //получили текст ошибки
  ErrorText:=Trim(copy(str,pos('=',str)+1,Length(str)-pos('=',str)));
  Result:=TLoginResult(AnsiIndexStr(ErrorText,Errors)+2);
end;

function TGoogleLoginThread.GetResultText: string;
begin
  case FLastResult of
    lrNone: Result:=rcNone;
    lrOk: Result:=rcOk;
    lrBadAuthentication: Result:=rcBadAuthentication;
    lrNotVerified: Result:=rcNotVerified;
    lrTermsNotAgreed: Result:=rcTermsNotAgreed;
    lrCaptchaRequired: Result:=rcCaptchaRequired;
    lrUnknown: Result:=rcUnknown;
    lrAccountDeleted: Result:=rcAccountDeleted;
    lrAccountDisabled: Result:=rcAccountDisabled;
    lrServiceDisabled: Result:=rcServiceDisabled;
    lrServiceUnavailable: Result:=rcServiceUnavailable;
  end;
end;

procedure TGoogleLoginThread.SynAutoriz;
begin
  if Assigned(FAutorization) then
    OnAutorization(FLastResult,FResultRec);
end;

procedure TGoogleLoginThread.SynErrAutoriz;
begin
  if Assigned(FErrorAutorization) then
    OnError(GetErrorText(True));//получаем текст ошибки
end;

end.
