unit uGoogleLogin;

interface

uses WinInet, Graphics, Classes, Windows, TypInfo,jpeg, SysUtils;

resourcestring
  rcNone = 'Аутентификация не производилась или сброшена';
  rcOk = 'Аутентификация прошла успешно';
  rcBadAuthentication = 'Не удалось распознать имя пользователя или пароль, использованные в запросе на вход';
  rcNotVerified = 'Адрес электронной почты, связанный с аккаунтом, не был подтвержден';
  rcTermsNotAgreed = 'Пользователь не принял условия использования службы';
  rcCaptchaRequired = 'Требуется ответ на тест CAPTCHA';
  rcUnknown = 'Неизвестная ошибка';
  rcAccountDeleted = 'Аккаунт этого пользователя удален';
  rcAccountDisabled = 'Аккаунт этого пользователя отключен';
  rcServiceDisabled = 'Доступ пользователя к указанной службе запрещен';
  rcServiceUnavailable = 'Служба недоступна, повторите попытку позже';
  rcDisconnect = 'Соединение с сервером разорвано';
  // ошибки соединения
  rcErrServer = 'На сервере произошла ошибка #';
  rcErrDont = 'Не могу получить описание ошибки';

const
  DefaultAppName ='My-Application';

  Flags_Connection = INTERNET_DEFAULT_HTTPS_PORT;

  Flags_Request =INTERNET_FLAG_RELOAD or
                 INTERNET_FLAG_IGNORE_CERT_CN_INVALID or
                 INTERNET_FLAG_NO_CACHE_WRITE or
                 INTERNET_FLAG_SECURE or
                 INTERNET_FLAG_PRAGMA_NOCACHE or
                 INTERNET_FLAG_KEEP_CONNECTION;

type
  TAccountType = (atNone, atGOOGLE, atHOSTED, atHOSTED_OR_GOOGLE);

type
  TLoginResult = (lrNone, lrOk, lrBadAuthentication, lrNotVerified,
                  lrTermsNotAgreed, lrCaptchaRequired, lrUnknown, lrAccountDeleted,
                  lrAccountDisabled, lrServiceDisabled, lrServiceUnavailable);

type
  TServices = (xapi, analytics, apps, gbase, jotspot, blogger, print, cl,
               codesearch, cp, writely, finance, mail, health, local, lh2, annotateweb,
               wise, sitemaps, youtube, gtrans);
type
  TResultRec = packed record
    LoginStr: string;
    SID: string;
    LSID: string;
    Auth: string;
  end;

type
  TAutorization = procedure(const LoginResult: TLoginResult; Result: TResultRec) of object;
  TAutorizCaptcha = procedure(PicCaptcha:TPicture) of object;
  TProgressAutorization = procedure(const Progress,MaxProgress:Integer)of object;
  TErrorAutorization = procedure(const ErrorStr: string) of object;
  TDisconnect = procedure(const ResultStr: string) of object;

type
  TGoogleLoginThread = class(TThread)
  private
    FParentComp:TComponent;
    { private declarations }
    FParamStr: string;
    FResultRec: TResultRec;
    FLastResult: TLoginResult;
    FCaptchaPic:TPicture;
    FCaptchaURL: string;
    FCapthaToken: string;
    FProgress,FMaxProgress:Integer;
    FAutorization: TAutorization;
    FAutorizCaptcha:TAutorizCaptcha;
    FProgressAutorization:TProgressAutorization;
    FErrorAutorization: TErrorAutorization;
    function ExpertLoginResult(const LoginResult: string): TLoginResult;
    function GetLoginError(const str: string): TLoginResult;
    function GetCaptchaURL(const cList: TStringList): string;
    function GetCaptchaToken(const cList: TStringList): String;
    function GetResultText: string;
    function GetErrorText(const FromServer: BOOLEAN): string;
    function LoadCaptcha(aCaptchaURL:string):Boolean;
    procedure SynAutoriz;
    procedure SynCaptcha;
    procedure SynCapchaToken;
    procedure SynProgressAutoriz;
    procedure SynErrAutoriz;
  protected
    { protected declarations }
    procedure Execute; override;
  public
    { public declarations }
    constructor Create(CreateSuspennded: BOOLEAN; aParamStr: string;aParentComp:TComponent);
  published
    { published declarations }
    property OnAutorization:TAutorization read FAutorization write FAutorization;    // авторизировались
    property OnAutorizCaptcha:TAutorizCaptcha  read FAutorizCaptcha write FAutorizCaptcha; //не авторизировались необходимо ввести капчу
    property OnProgressAutorization: TProgressAutorization read FProgressAutorization write FProgressAutorization;//прогресс авторизации
    property OnError: TErrorAutorization read FErrorAutorization write FErrorAutorization; // возникла ошибка ((
  end;

  TGoogleLogin = class(TComponent)
  private
    FAppname: string;
    FAccountType: TAccountType;
    FLastResult: TLoginResult;
    FEmail: string;
    FPassword: string;
    FService: TServices;
    FCaptcha: string;
    FCapchaToken: string;
    FAfterLogin: TAutorization;
    FAutorizCaptcha:TAutorizCaptcha;
    FProgressAutorization:TProgressAutorization;
    FErrorAutorization: TErrorAutorization;
    FDisconnect: TDisconnect;
    procedure SetEmail(cEmail: string);
    procedure SetPassword(cPassword: string);
    procedure SetService(cService: TServices);
    procedure SetCaptcha(cCaptcha: string);
    procedure SetAppName(value: string);
    function DigitToHex(Digit: Integer): Char;
    function URLEncode(const S: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;
    procedure Login(aLoginToken: string = ''; aLoginCaptcha: string = '');
    procedure Disconnect;
    property CapchaToken: string read FCapchaToken;
  published
    property AppName: string read FAppname write SetAppName;
    property AccountType: TAccountType read FAccountType write FAccountType;
    property Email: string read FEmail write SetEmail;
    property Password: string read FPassword write SetPassword;
    property Captcha: string read FCaptcha write SetCaptcha;
    property Service: TServices read FService write SetService default xapi;
    property OnAutorization: TAutorization read FAfterLogin write FAfterLogin;
    property OnAutorizCaptcha:TAutorizCaptcha  read FAutorizCaptcha write FAutorizCaptcha;
    property OnProgressAutorization:TProgressAutorization  read FProgressAutorization write FProgressAutorization;
    property OnError: TErrorAutorization read FErrorAutorization write FErrorAutorization;
    property OnDisconnect: TDisconnect read FDisconnect write FDisconnect;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BuBa Group', [TGoogleLogin]);
end;

{ TGoogleLogin }

function TGoogleLogin.DigitToHex(Digit: Integer): Char;
begin
  case Digit of
    0 .. 9:
      Result := Chr(Digit + Ord('0'));
    10 .. 15:
      Result := Chr(Digit - 10 + Ord('A'));
  else
    Result := '0';
  end;
end;

procedure TGoogleLogin.Disconnect;
begin
  FAccountType := atNone;
  FLastResult := lrNone;
  FCapchaToken := '';
  FCaptcha := '';
  if Assigned(FDisconnect) then
    OnDisconnect(rcDisconnect)
end;

destructor TGoogleLogin.Destroy;
begin
  inherited Destroy;
end;

constructor TGoogleLogin.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAppname := DefaultAppName;
end;

procedure TGoogleLogin.Login(aLoginToken, aLoginCaptcha: string);
var
  cBody: TStringStream;
//  ResponseText: string;
begin
try
  cBody := TStringStream.Create('');
  case FAccountType of
    atNone, atHOSTED_OR_GOOGLE:
      cBody.WriteString('accountType=HOSTED_OR_GOOGLE&');
    atGOOGLE:
      cBody.WriteString('accountType=GOOGLE&');
    atHOSTED:
      cBody.WriteString('accountType=HOSTED&');
  end;
  cBody.WriteString('Email=' + FEmail + '&');
  cBody.WriteString('Passwd=' + URLEncode(FPassword) + '&');
  cBody.WriteString('service=' + GetEnumName(TypeInfo(TServices),Integer(FService)) + '&');

  if Length(Trim(FAppname)) > 0 then
    cBody.WriteString('source=' + FAppname)
  else
    cBody.WriteString('source=' + DefaultAppName);
  if (Length(Trim(aLoginToken)) > 0) or (Length(Trim(aLoginCaptcha))>0) then
  begin
    cBody.WriteString('&logintoken=' + aLoginToken);
    cBody.WriteString('&logincaptcha=' + aLoginCaptcha);
  end;
  with TGoogleLoginThread.Create(True, cBody.DataString,Self) do
    begin
      OnAutorization := Self.OnAutorization;
      OnAutorizCaptcha:=Self.OnAutorizCaptcha;
      OnProgressAutorization:=Self.OnProgressAutorization;
      OnError := Self.OnError;
      FreeOnTerminate := True;
      Start;
  end;
finally
  FreeAndNil(cBody);
end;
end;

procedure TGoogleLogin.SetAppName(value: string);
begin
  if not(value = '') then
    FAppname := value
  else
    FAppname := DefaultAppName;
end;

procedure TGoogleLogin.SetCaptcha(cCaptcha: string);
begin
  FCaptcha := cCaptcha;
  Login(FCapchaToken, FCaptcha);
end;

procedure TGoogleLogin.SetEmail(cEmail: string);
begin
  FEmail := cEmail;
  if FLastResult = lrOk then
    Disconnect;
end;

procedure TGoogleLogin.SetPassword(cPassword: string);
begin
  FPassword := cPassword;
  if FLastResult = lrOk then
    Disconnect;
end;

procedure TGoogleLogin.SetService(cService: TServices);
begin
  FService := cService;
  if FLastResult = lrOk then
  begin
    Disconnect;
    Login;
  end;
end;

function TGoogleLogin.URLEncode(const S: string): string;
var
  i, idx, len: Integer;
begin
  len := 0;
  for i := 1 to Length(S) do
    if ((S[i] >= '0') and (S[i] <= '9')) or ((S[i] >= 'A') and (S[i] <= 'Z'))
      or ((S[i] >= 'a') and (S[i] <= 'z')) or (S[i] = ' ') or (S[i] = '_') or
      (S[i] = '*') or (S[i] = '-') or (S[i] = '.') then
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
      ((S[i] >= 'A') and (S[i] <= 'Z')) or ((S[i] >= 'a') and (S[i] <= 'z'))
      or (S[i] = '_') or (S[i] = '*') or (S[i] = '-') or (S[i] = '.') then
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

constructor TGoogleLoginThread.Create(CreateSuspennded: BOOLEAN; aParamStr: string;aParentComp:TComponent);
begin
  inherited Create(CreateSuspennded);
  FParentComp:=TComponent.Create(nil);
  FParentComp:=aParentComp;
  FParamStr := aParamStr;
  FResultRec.LoginStr := '';
  FResultRec.SID := '';
  FResultRec.LSID := '';
  FResultRec.Auth := '';
  FProgress:=0;
  FMaxProgress:=0;
  FCaptchaPic:=TPicture.Create;
end;

procedure TGoogleLoginThread.Execute;
  function DataAvailable(hRequest: pointer; out Size: cardinal): BOOLEAN;
  begin
    Result := WinInet.InternetQueryDataAvailable(hRequest, Size, 0, 0);
  end;

var
  hInternet, hConnect, hRequest: pointer;
  dwBytesRead, i, L: cardinal;
  sTemp: AnsiString;
begin
  try
    hInternet := InternetOpen(PChar('GoogleLogin'),INTERNET_OPEN_TYPE_PRECONFIG, Nil, Nil, 0);
    if Assigned(hInternet) then
    begin
      hConnect := InternetConnect(hInternet, PChar('www.google.com'),
        Flags_Connection, nil, nil, INTERNET_SERVICE_HTTP, 0, 1);
      if Assigned(hConnect) then
      begin
        hRequest := HttpOpenRequest(hConnect, PChar(uppercase('post')),
          PChar('accounts/ClientLogin?' + FParamStr), HTTP_VERSION, nil, Nil,
          Flags_Request, 1);
        if Assigned(hRequest) then
        begin
          i := 1;
          if HttpSendRequest(hRequest, nil, 0, nil, 0) then
          begin
            repeat
              DataAvailable(hRequest, L);
              if L = 0 then
                break;
              SetLength(sTemp, L + i);
              if not InternetReadFile(hRequest, @sTemp[i], sizeof(L),dwBytesRead) then
                break;
              inc(i, dwBytesRead);
              if Terminated then
              begin
                InternetCloseHandle(hRequest);
                InternetCloseHandle(hConnect);
                InternetCloseHandle(hInternet);
                Exit;
              end;
              FProgress:=i;
              if FMaxProgress=0 then
                FMaxProgress:=L+1;
              Synchronize(SynProgressAutoriz);
            until dwBytesRead = 0;
            sTemp[i] := #0;
          end;
        end;
      end;
    end;
  except
    Synchronize(SynErrAutoriz);
    Exit;
  end;
  InternetCloseHandle(hRequest);
  InternetCloseHandle(hConnect);
  InternetCloseHandle(hInternet);
  FLastResult := ExpertLoginResult(sTemp);
  FResultRec.LoginStr := GetResultText;
  if FLastResult=lrCaptchaRequired then
  begin
    LoadCaptcha(FCaptchaURL);
    Synchronize(SynCaptcha);
    Synchronize(SynCapchaToken);
  end;
  if FLastResult<>lrCaptchaRequired then
  begin
    Synchronize(SynAutoriz);
  end;
end;

function TGoogleLoginThread.ExpertLoginResult(const LoginResult: string)
  : TLoginResult;
var
  List: TStringList;
  i: Integer;
begin
try
  List := TStringList.Create;
  List.Text := LoginResult;
  if pos('error', LowerCase(LoginResult)) > 0 then
  begin
    for i := 0 to List.Count - 1 do
    begin
      if pos('error', LowerCase(List[i])) > 0 then
      begin
        Result := GetLoginError(List[i]);
        break;
      end;
    end;
    if Result = lrCaptchaRequired then
    begin
      FCaptchaURL := GetCaptchaURL(List);
      FCapthaToken := GetCaptchaToken(List);
    end;
  end
  else
  begin
    Result := lrOk;
    for i := 0 to List.Count - 1 do
    begin
      if pos('SID', uppercase(List[i])) > 0 then
        FResultRec.SID := Trim(copy(List[i], pos('=', List[i]) + 1,
            Length(List[i]) - pos('=', List[i])))
      else if pos('LSID', uppercase(List[i])) > 0 then
        FResultRec.LSID := Trim(copy(List[i], pos('=', List[i]) + 1,
            Length(List[i]) - pos('=', List[i])))
      else if pos('AUTH', uppercase(List[i])) > 0 then
        FResultRec.Auth := Trim(copy(List[i], pos('=', List[i]) + 1,
            Length(List[i]) - pos('=', List[i])));
    end;
  end;
finally
  FreeAndNil(List);
end;
end;

function TGoogleLoginThread.GetCaptchaToken(const cList: TStringList): String;
var
  i: Integer;
begin
  for i := 0 to cList.Count - 1 do
  begin
    if pos('captchatoken', LowerCase(cList[i])) > 0 then
    begin
      Result := Trim(copy(cList[i], pos('=', cList[i]) + 1,
          Length(cList[i]) - pos('=', cList[i])));
       break;
    end;
  end;
end;

function TGoogleLoginThread.GetCaptchaURL(const cList: TStringList): string;
var
  i: Integer;
begin
  for i := 0 to cList.Count - 1 do
  begin
    if pos('captchaurl', LowerCase(cList[i])) > 0 then
    begin
      Result := Trim(copy(cList[i], pos('=', cList[i]) + 1,
          Length(cList[i]) - pos('=', cList[i])));
      break;
    end;
  end;
end;

function TGoogleLoginThread.GetErrorText(const FromServer: BOOLEAN): string;
var
  Msg: array [0 .. 1023] of Char;
  ErCode, len: cardinal;
begin
  len := sizeof(Msg);
  ZeroMemory(@Msg, sizeof(Msg));
  if FromServer then
    if InternetGetLastResponseInfo(ErCode, @Msg, len) then
      Result := rcErrServer + IntToStr(ErCode) + #13 + StrPas(Msg)
    else
      Result := rcErrDont
    else if FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, GetLastError,
      GetKeyboardLayout(0), @Msg, sizeof(Msg), nil) <> 0 then
      Result := StrPas(Msg)
    else
      Result := rcErrDont;
end;

function TGoogleLoginThread.GetLoginError(const str: string): TLoginResult;
var
  ErrorText: string;
begin
  ErrorText := Trim(copy(str, pos('=', str) + 1, Length(str) - pos('=', str)));
  Result:=TLoginResult(GetEnumValue(TypeInfo(TLoginResult),'lr'+ErrorText));
end;

function TGoogleLoginThread.GetResultText: string;
begin
  case FLastResult of
    lrNone:
      Result := rcNone;
    lrOk:
      Result := rcOk;
    lrBadAuthentication:
      Result := rcBadAuthentication;
    lrNotVerified:
      Result := rcNotVerified;
    lrTermsNotAgreed:
      Result := rcTermsNotAgreed;
    lrCaptchaRequired:
      Result := rcCaptchaRequired;
    lrUnknown:
      Result := rcUnknown;
    lrAccountDeleted:
      Result := rcAccountDeleted;
    lrAccountDisabled:
      Result := rcAccountDisabled;
    lrServiceDisabled:
      Result := rcServiceDisabled;
    lrServiceUnavailable:
      Result := rcServiceUnavailable;
  end;
end;

function TGoogleLoginThread.LoadCaptcha(aCaptchaURL: string): Boolean;
  function DataAvailable(hRequest: pointer; out Size: cardinal): BOOLEAN;
  begin
    Result := WinInet.InternetQueryDataAvailable(hRequest, Size, 0, 0);
  end;
var
  hInternet, hConnect,hRequest: pointer;
  dwBytesRead, i, L: cardinal;
  sTemp: AnsiString;
  memStream: TMemoryStream;
  jpegimg: TJPEGImage;
  url:string;
begin
  Result:=False;;
  url:='http://www.google.com/accounts/'+aCaptchaURL;
  hInternet := InternetOpen('GoogleLogin', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  try
    if Assigned(hInternet) then
    begin
      hConnect := InternetOpenUrl(hInternet, PChar(url), nil, 0, 0, 0);
      if Assigned(hConnect) then
        try
          i := 1;
          repeat
            SetLength(sTemp, L + i);
            if not InternetReadFile(hConnect, @sTemp[i], sizeof(L),dwBytesRead) then
              break;
            inc(i, dwBytesRead);
            until dwBytesRead = 0;
        finally
          InternetCloseHandle(hConnect);
        end;
    end;
  finally
    InternetCloseHandle(hInternet);
  end;
  memStream := TMemoryStream.Create;
  jpegimg   := TJPEGImage.Create;
  try
    memStream.Write(sTemp[1], Length(sTemp));
    memStream.Position := 0;
    jpegimg.LoadFromStream(memStream);
    FCaptchaPic.Assign(jpegimg);
  finally
    memStream.Free;
    jpegimg.Free;
  end;
  Result:=True;
end;

procedure TGoogleLoginThread.SynAutoriz;
begin
  if Assigned(FAutorization) then
    OnAutorization(FLastResult, FResultRec);
end;

procedure TGoogleLoginThread.SynCapchaToken;
begin
  if Assigned(FParentComp) then
    TGoogleLogin(FParentComp).FCapchaToken:=Self.FCapthaToken;
end;

procedure TGoogleLoginThread.SynCaptcha;
begin
  if Assigned(FAutorizCaptcha) then
    OnAutorizCaptcha(FCaptchaPic);
end;

procedure TGoogleLoginThread.SynErrAutoriz;
begin
  if Assigned(FErrorAutorization) then
    OnError(GetErrorText(true));
end;

procedure TGoogleLoginThread.SynProgressAutoriz;
begin
  if Assigned(FProgressAutorization) then
    OnProgressAutorization(FProgress,FMaxProgress);
end;

end.
