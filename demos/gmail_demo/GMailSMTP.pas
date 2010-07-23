{unit GContacts

  Модуль содержит класс для отправки писем через электронную посту GMail.com
  с использованием класса бибилотеки Synapse - TSMTPSend.

  ВАЖНО: для нормальной работы компонента Вам необходимо скачать и сохранить
  в директории с программой две DLL:

  1. libeay32.dll
  2. ssleay32.dll

  Скачать их можна на сайте разработчиков Synapse:
  http://synapse.ararat.cz/files/crypt/

  Если Вы планируете использовать компонент для других почтовых сервисов,
  которые ни используют шифрованных подключений TLS, то следуетт закомментировать
  вот эту строку:
  <code>
  function TGMailSMTP.SendMessage(const aSubject: string; aClear:boolean): boolean;
  var
    ...
  begin
    ...
     SMTP.AutoTLS:=True;
    ...
  </code>

  Основной компонент для работы с почтой - TGMailSMTP.

  Автор: Vlad. (vlad383@gmail.com)
  Дата: 17 Июля 2010
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


unit GMailSMTP;

interface

uses mimemess, mimepart, smtpsend, classes, sysutils,
     controls,ssl_openssl,synautil;

const
  {$REGION 'Константы'}
    GMailSMTPVersion = '0.1';
    GmailHost = 'smtp.gmail.com';
    GmailPort = 587;
 {$ENDREGION}

type
  TGMailSMTP = class(TComponent)
  private
    FPort      : integer;    //порт
    FLogin     : string;  //логин для smtp-сервера
    FPassword  : string; //пароль
    FEmail     : string;     //почтовый ящик с которого отправляется письмо
    FFromName  : string; //от чьего имени отправляется письмо
    FHost      : string; //хост (smtp-сервер)
    FFiles     : TStrings; //прикрепленные файлы
    FRecipients: TStrings;//получатели
    FMsg       : TMimeMess;
    FMIMEPart  : TMimePart;
    procedure SetFiles(Value: TStrings);
    procedure SetRecepients(Value: TStrings);
  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    function AddText(const aText: string):boolean;
    function AddHTML(const aHTML: string):boolean;
    function SendMessage(const aSubject:string; aClear:boolean=true):boolean;
    procedure Clear;
    //для работы c объектами Synapse
    property GMessage:TMimeMess read FMsg write FMsg;
    property MIMEPart:TMimePart read FMIMEPart write FMIMEPart;
  published
    property Login: string read FLogin write FLogin;
    property Password: string read FPassword write FPassword;
    property Host: string read FHost write FHost;
    property FromEmail: string read FEmail write FEmail;
    property FromName: string read FFromName write FFromName;
    property Port: integer read FPort write FPort;
    property AttachFiles: TStrings read FFiles write SetFiles;
    property Recipients: TStrings read FRecipients write SetRecepients;
end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('WebDelphi.ru',[TGMailSMTP]);
end;

{ TGMailSMTP }

function TGMailSMTP.AddHTML(const aHTML: string): boolean;
var s:TStringList;
begin
Result:=false;
try
  S:=TStringList.Create;
  S.Text:=aHTML;
  FMsg.AddPartHTML(S, FMIMEPart);
  Result:=true;
finally
  S.Free;
end;
end;

function TGMailSMTP.AddText(const aText: string): boolean;
var s:TStringList;
begin
Result:=false;
try
  S:=TStringList.Create;
  S.Text:=aText;
  FMsg.AddPartText(S, FMIMEPart);
  Result:=true;
finally
  S.Free;
end;
end;

procedure TGMailSMTP.Clear;
begin
  FMsg.Clear;
  FMIMEPart.Clear;
  FFiles.Clear;
  FRecipients.Clear;
end;

constructor TGMailSMTP.Create(AOwner: TComponent);
begin
  inherited;
  FFiles:=TStringList.Create;
  FRecipients:=TStringList.Create;
  FMsg:=TMimeMess.Create;
  FMIMEPart:=FMsg.AddPartMultipart('alternate',nil);
  FHost:=GmailHost;
  FPort:=GmailPort;
end;

destructor TGMailSMTP.Destroy;
begin
  FFiles.Free;
  FRecipients.Free;
  inherited;
end;

function TGMailSMTP.SendMessage(const aSubject: string; aClear:boolean): boolean;
var i:integer;
    MailTo: string;
    MailFrom: string;
    SMTP: TSMTPSend;
    s, t: string;
begin
Result:=false;

if Length(Trim(FFromName))>0 then
  MailFrom:='"'+FFromName+'" <'+FEmail+'>'
else
  MailFrom:=FEmail;
  //добавляем заголовки
  FMsg.Header.Subject:=aSubject;
  FMsg.Header.From:=MailFrom;
  FMsg.Header.ToList.Assign(FRecipients);
  //добавляем файлы
  for i:=0 to FFiles.Count - 1 do
     FMsg.AddPartBinaryFromFile(FFiles[i],FMIMEPart);
  MailTo:='';
  FRecipients.Delimiter:=',';
  MailTo:=FRecipients.DelimitedText;
  FMsg.EncodeMessage;

  SMTP := TSMTPSend.Create;
  SMTP.AutoTLS:=True;
  SMTP.TargetHost := Trim(FHost);
  if FPort>0 then
   SMTP.TargetPort:=IntToStr(FPort);
  SMTP.Username := FLogin;
  SMTP.Password := FPassword;
try
if SMTP.Login then
    begin
      if SMTP.MailFrom(GetEmailAddr(MailFrom), Length(FMsg.Lines.Text)) then
      begin
        s:=MailTo;
        repeat
          t := GetEmailAddr(Trim(FetchEx(s, ',', '"')));
          if t <> '' then
            Result := SMTP.MailTo(t);
          if not Result then
            Break;
        until s = '';
        if Result then
          Result := SMTP.MailData(FMsg.Lines);
      end;
      SMTP.Logout;
    end;
  finally
    SMTP.Free;
    if aClear then
      Clear;
  end;
end;

procedure TGMailSMTP.SetFiles(Value: TStrings);
begin
  FFiles.Assign(Value)
end;

procedure TGMailSMTP.SetRecepients(Value: TStrings);
begin
  FRecipients.Assign(Value);
end;

end.
