{*******************************************************}
{                                                       }
{       BloggerApi                                      }
{                                                       }
{       Copyright (C) 2010 NMD                          }
{       http://nmdsoft.blogspot.com/                    }
{*******************************************************}


unit BloggerApi;

interface

uses
  SysUtils, Classes,NativeXml,WinInet;

//ошибки
resourcestring
rsErrorXmlTag='Нет закрывающего тега. HTHL должен быть валидным';
rsErrorNotTolken='Нет толкена google для работы с сервисом';
rsErrorNotSelectBlog='Блог не выбран! Смотри property CurrentBlog';
rsErrorIdPost='Не указан Id сообщения в блоге';

rsErrorGet='Произошла сетевая ошибка при получении данных c сервера';
rsErrorDelete='Произошла сетевая ошибка при выполнении запроса Delete';
rsErrorPost='Произошла сетевая ошибка при отправке данных на сервер';
rsErrorPut='Произошла сетевая ошибка при обновлении данных на сервер';
const
  cnsBlogDefault='http://www.blogger.com/feeds/default/blogs';
  cnsEntry='entry';
  cnsName='name';
  cnsId='id';
  cnsPublished='published';
  cnsUpdated='updated';
  cnsTitle='title';
  cnsCategory='category';
    cntTerm='term';
  cnsXhtml='xhtml';
  cnsXmlns='xmlns';
  cnsType='type';
  cnsText='text';
  cnsContent='content';
  cnsScheme='scheme';
  cnsTerm='term';
  cnsDiv='div';
  cnsAtomUrl='http://www.w3.org/2005/Atom';
  cnsXhtmlUrl='http://www.w3.org/1999/xhtml';
  cnsAtnsUrl='http://www.blogger.com/atom/ns#';
  //http://www.blogger.com/feeds/blogID/posts/default
  cnsPostBlogStart='http://www.blogger.com/feeds/';
  cnsPostBlogEnd='/posts/default';
  cnsAppControll='app:control';
  cnsXmlnsApp='xmlns:app';
  cnsXmlnsAppUrl='http://www.w3.org/2007/app';
  cnsAppDraft='app:draft';
  cnsYes='yes';
  cnsVop='/?';
//  cnsPostIdUrl='http://www.blogger.com/feeds/blogID/posts/default/postID';

type
  //событие для ошибки
  TErrorEvent = procedure(aE: string) of object;
  //Прогресс выполнения задания
  TProgressEvent = procedure(aCurrentProgress,aMaxProgress: Integer) of object;

  //для комментариев
  TCommentItem = class (TCollectionItem)
  private
    FCommentTitle: string;
    FCommentId: string;
    FCommentSourse: TStringList;
    FCommentPublished: TDateTime;
    FCommentUpdate: TDateTime;
    FAutorName:string;
    FAutorURL:string;
    FAutorEmail:string;
    procedure SetCommentId(const Value: string);
    procedure SetCommentPublished(const Value: TDateTime);
    procedure SetCommentSourse(const Value: TStringList);
    procedure SetCommentTitle(const Value: string);
    procedure SetCommentUpdate(const Value: TDateTime);
    procedure SetCommentAutorEmail(const Value: string);
    procedure SetCommentAutorName(const Value: string);
    procedure SetCommentAutorURL(const Value: string);
  public
    constructor Create(Collection: TCollection);override;
    destructor Destroy; override;
  published
    property CommentId:string  read FCommentId write SetCommentId;
    property CommentTitle:string  read FCommentTitle write SetCommentTitle;
    property CommentSourse:TStringList  read FCommentSourse write SetCommentSourse;
    property CommentPublished:TDateTime  read FCommentPublished write SetCommentPublished;
    property CommentUpdate:TDateTime  read FCommentUpdate write SetCommentUpdate;
    property CommentAutorName:string  read FAutorName write SetCommentAutorName;
    property CommentAutorURL:string  read FAutorURL write SetCommentAutorURL;
    property CommentAutorEmail:string  read FAutorEmail write SetCommentAutorEmail;
  end;

  //комментарии
  TCommentCollection = class (TCollection)
  private
    function GetItemComment(Index: Integer): TCommentItem;
    procedure SetItemComment(Index: Integer; Value: TCommentItem);
  public
    constructor Create(AOwner:TComponent);
    function Add: TCommentItem;
    property Items[Index: Integer]: TCommentItem read GetItemComment write SetItemComment;
    function AddEx(aPostTitle,aPostId:string; aPostSourse:TStringList;aPostPublished,aPostUpdate:TDateTime): TCommentItem;
  end;

  //для сообщений
  TPostItem = class (TCollectionItem)
  private
    FPostTitle: string;
    FPostId: string;
    FPostSourse: TStringList;
    FСategoryPost:TStringList;
    FPostPublished: TDateTime;
    FPostUpdate: TDateTime;
    procedure SetPostId(const Value: string);
    procedure SetPostPublished(const Value: TDateTime);
    procedure SetPostSourse(const Value: TStringList);
    procedure SetPostTitle(const Value: string);
    procedure SetPostUpdate(const Value: TDateTime);
    procedure SetСategoryPost(const Value: TStringList);
  public
    constructor Create(Collection: TCollection);override;
    destructor Destroy; override;
  published
    property PostId:string  read FPostId write SetPostId;
    property PostTitle:string  read FPostTitle write SetPostTitle;
    property PostSourse:TStringList  read FPostSourse write SetPostSourse;
    property СategoryPost:TStringList  read FСategoryPost write SetСategoryPost;
    property PostPublished:TDateTime  read FPostPublished write SetPostPublished;
    property PostUpdate:TDateTime  read FPostUpdate write SetPostUpdate;
  end;

 TPostCollection = class (TCollection)
 private
   function GetItemBlog(Index: Integer): TPostItem;
   procedure SetItemBlog(Index: Integer; Value: TPostItem);
 public
  constructor Create(AOwner:TComponent);
  function Add: TPostItem;
  property Items[Index: Integer]: TPostItem read GetItemBlog write SetItemBlog;
  function AddEx(aPostTitle,aPostId:string; aPostSourse:TStringList;aPostPublished,aPostUpdate:TDateTime): TPostItem;
 end;


  TBlogItem = class (TCollectionItem)
  private
    FTitle:string;//заголовок
    FBlogId:string;//id блога
    FСategoryBlog:TStringList;//ярлыки блога
    FPublished:TDateTime;//дата последеней публикации
    FUpdate:TDateTime;//дата последнего обновления
    procedure SetCategory(const Value: TStringList);
    procedure SetPublished(const Value: TDateTime);
    procedure SetUpdate(const Value: TDateTime);
    procedure SetBlogId(const Value: string);
    procedure SetTitle(const Value: string);

  public
    constructor Create(Collection: TCollection);override;
    destructor Destroy; override;
  published
    property Title:string  read FTitle write SetTitle;
    property BlogId:string  read FBlogId write SetBlogId;
    property СategoryBlog:TStringList  read FСategoryBlog write SetCategory;
    property Publish:TDateTime  read FPublished write SetPublished;
    property Update:TDateTime  read FUpdate write SetUpdate;
  end;

 TBlogCollection = class (TCollection)
 private
   function GetItemBlog(Index: Integer): TBlogItem;
   procedure SetItemBlog(Index: Integer; Value: TBlogItem);
 public
  constructor Create(AOwner:TComponent);
  function Add: TBlogItem;
  property Items[Index: Integer]: TBlogItem read GetItemBlog write SetItemBlog;
  function AddEx(aName,aTitle,aBlogId: string;aUrl:string;aСategoryBlog:TStringList;aPublished,aUpdate:TDateTime): TBlogItem;
 end;

//класс для работы с блогами на Blogger'e
type
  TBlogger = class(TComponent)
  private
    //для работы с xml
    FXMLDoc:TNativeXml;
    FAuth:string;
    FUrl:string;//ссылка на профиль владельца блога
    FAppName:string;//название приложения
    FBlogs:TBlogCollection;
    FCurrentBlog: Integer;//блог с которым будем непосредственно работать
    //для событий
    FProgress:TProgressEvent;
    FErrorEvent: TErrorEvent;//ошибка

    //вспомогательные для работы с инетом
    function GetUrl(url, param, method: string; AUTH:AnsiString;postData: UTF8String): UTF8String;
    function DataAvailable(hRequest: pointer; out Size: cardinal): boolean;
    function GetScriptName(url, hostname: string): string;
    procedure SetFlags(url: string; out Flags_connection, Flags_Request: Cardinal);
    function GetHostName(url: string): string;

    function GetIdBlog(aSourse:string):string;//получение id блога
    function GetPostId(aSourse:string):string;//получение id поста

    procedure ToError(aError:string);//обработка ошибок
    //для пропертей
    procedure SetAppName(const Value: string);
    procedure SetAuth(const Value: string);
    procedure SetBlog(const Value: TBlogCollection);
    procedure SetCurrentBlog(const Value: Integer);

  protected
  public
    procedure RetrievAllBlogs;//получение списка блогов пользователя
    function PostCreat(aTitle,aContent:string; aCategory:TStringList;aComment:Boolean):UTF8String;//создание сообщения и отправка в блог
    function PostModify(id,aTitle,aContent:string; aCategory:TStringList;aComment:Boolean):UTF8String;//Изменение сообщения и отправка его в блог
    function PostDelete(id:string):Boolean;//удаление поста из блога

    function RetrievAllPosts:TPostCollection;//получаем последние 25 постов из блога
    //получение статей по заданным параметрам
    function RetrievPostForParams(aCategory:string =''; aOrderby:string =''; aPublishedMin:string ='';
                                  aPublishedMax:string =''; aUpdatedMin:string ='';aUpdatedMax:string ='';
                                  aStartIndex:Integer=0; aMaxResults:Integer=0; aAlt : string =''):TPostCollection;
    //Возвращает посты из блога по заданным параметрам созданым в ручную
    function RetrievPostForTextParams(Parametrs:string):TPostCollection;
    constructor Create(AOwner: TComponent);override;//инициализация класса
    destructor Destroy; override;//уничтожение
  published
    property Auth:string read FAuth write SetAuth;
    property AppName:string read FAppName write SetAppName;
    property CurrentBlog:Integer  read FCurrentBlog write SetCurrentBlog default -1;
    property Url: string read FUrl;
    property Blogs:TBlogCollection  read FBlogs write SetBlog;

    //события
    property OnProgress:TProgressEvent read FProgress write FProgress;//прогресс выполнения задачи
    property OnError:TErrorEvent read FErrorEvent write FErrorEvent;//возникает при ошибке )

  end;

procedure Register;

implementation

constructor TBlogger.Create(AOwner: TComponent);
begin
  inherited;
  FBlogs:=TBlogCollection.Create(Self);
  FXMLDoc:=TNativeXml.Create;
  FAuth:='';
  FAppName:='MyCompany';
  FCurrentBlog:=-1;
end;

destructor TBlogger.Destroy;
begin
  FreeAndNil(FXMLDoc);
  FBlogs.Free;
  inherited;
end;

function TBlogger.GetHostName(url : string) : string;
begin
  result := '';
  if pos('https://',url) > 0 then
    begin
      delete(url,1,length('https://'));
      SetLength(url,pos('/',url) - 1);
      result := url;
    end
  else
    if pos('http://',url) > 0 then
      begin
        delete(url,1,length('http://'));
        SetLength(url,pos('/',url) - 1);
        result := url;
      end;
end;

{-------------------------------------------------------------------------------
  Функция: TBlogger.GetIdBlog
  Автор:    NMD
  Дата:  2010.08.08
  Входные параметры: aSourse: string строка содержащая id блога
  Результат: id блога   string
-------------------------------------------------------------------------------}
function TBlogger.GetIdBlog(aSourse: string): string;
var
  i:Integer;
begin
  Result:='';
  i:=AnsiPos('.blog-',aSourse);
  Delete(aSourse,1,i+5);
  Result:=aSourse;
end;

function TBlogger.GetPostId(aSourse: string): string;
var
  i:Integer;
begin
  Result:='';
  i:=AnsiPos('.post-',aSourse);
  Delete(aSourse,1,i+5);
  Result:=aSourse;
end;

function TBlogger.GetScriptName( url,hostname : string) : string;
begin
  result := '';
  delete(url,1,pos(hostname,url) + length(hostname));
  result := url;
end;

procedure TBlogger.SetFlags(url : string; out Flags_connection,Flags_Request : Cardinal);
begin
  //Оприделяем на https или http
  if pos('https',url) > 0 then
    begin
      Flags_connection := INTERNET_DEFAULT_HTTPS_PORT;
      Flags_Request := INTERNET_FLAG_RELOAD or INTERNET_FLAG_IGNORE_CERT_CN_INVALID or INTERNET_FLAG_NO_CACHE_WRITE or INTERNET_FLAG_SECURE or INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_KEEP_CONNECTION;
    end
  else
    begin
      Flags_connection := INTERNET_DEFAULT_HTTP_PORT;
      Flags_Request := INTERNET_FLAG_RELOAD or INTERNET_FLAG_IGNORE_CERT_CN_INVALID or INTERNET_FLAG_NO_CACHE_WRITE or INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_KEEP_CONNECTION;
    end;
end;

//обработка ошибок
procedure TBlogger.ToError(aError: string);
begin
  if Assigned(FErrorEvent) then
    OnError(aError);
end;

function TBlogger.DataAvailable(hRequest: pointer; out Size : cardinal): boolean;
begin
  result := wininet.InternetQueryDataAvailable(hRequest, Size, 0, 0);
end;

function TBlogger.GetUrl(url : string; param: string; method : string; AUTH:AnsiString; postData:UTF8String) :UTF8String;//Получение страницы по url
var
  FHost,FScript : string;
  hInternet,hConnect,hRequest : Pointer;
  dwBytesRead,I,L : Cardinal;
  Flags_connection,Flags_Request : Cardinal;
  Flag_HttpSendRequest:LongBool;
  header:TStringStream;
begin
  result := '';
  fHost := GetHostName(url);
  fScript := GetScriptName(url,fHost);
  if Param <> '' then
    if fScript[Length(fScript)] = '?' then
      fScript := fScript + param
    else
      fScript := fScript + '?' + param;
  //Устанавливаем флаги
  SetFlags(url,Flags_connection,Flags_Request);
  //Инициализируем WinInet
  hInternet := InternetOpen(PChar(FAppName),INTERNET_OPEN_TYPE_PRECONFIG,Nil,Nil,0);
  if Assigned(hInternet) then
  begin
    //Открываем сессию
    hConnect := InternetConnect(hInternet,PChar(FHost),Flags_connection,nil,nil,INTERNET_SERVICE_HTTP,0,1);
    if Assigned(hConnect) then
    begin
      //Формируем запрос
      hRequest := HttpOpenRequest(hConnect,PChar(uppercase(method)),PChar(fScript),HTTP_VERSION,nil,Nil,Flags_Request,1);
      if Assigned(hRequest) then
      begin
        header:=TStringStream.Create;
        with Header do
        begin
          WriteString('Content-Type:application/atom+xml'+SLineBreak);
          WriteString('GData-Version:2 '+SLineBreak);
          WriteString('Authorization: GoogleLogin auth='+AUTH+SLineBreak+SLineBreak);
        end;
        //Отправляем запрос
        I := 1;
        if uppercase(method)='GET' then
        begin
          Flag_HttpSendRequest:=HttpSendRequest(hRequest,PChar(header.DataString),Length(header.DataString),nil,0);
          if not Flag_HttpSendRequest then
            ToError(rsErrorGet);
        end;
        if uppercase(method)='POST' then
        begin
          Flag_HttpSendRequest:=HttpSendRequest(hRequest,PChar(header.DataString),Length(header.DataString),Pointer(postData),Length(postData));
          if not Flag_HttpSendRequest then
            ToError(rsErrorPost);
        end;
        if uppercase(method)='PUT' then
        begin
          Flag_HttpSendRequest:=HttpSendRequest(hRequest,PChar(header.DataString),Length(header.DataString),Pointer(postData),Length(postData));
          if not Flag_HttpSendRequest then
            ToError(rsErrorPut);
        end;
        if uppercase(method)='DELETE' then
        begin
          Flag_HttpSendRequest:=HttpSendRequest(hRequest,PChar(header.DataString),Length(header.DataString),nil,0);
          if not Flag_HttpSendRequest then
          begin
            OnError(rsErrorDelete);
            Result:='0'
          end
          else
          begin
            Result:='1';
          end;
        end;
        if Flag_HttpSendRequest and (uppercase(method)<>'DELETE') then
        begin
          repeat
            DataAvailable(hRequest, L);//Получаем кол-во принимаемых данных
            if L = 0 then break;
              SetLength(result,L + I);
            if not (InternetReadFile(hRequest,@result[I],sizeof(L),dwBytesRead)) then //Получаем данные с сервера
            begin
              OnError(rsErrorGet);
            end;
            if Assigned(FProgress) then //прогресс
              OnProgress(i,L+1);
            inc(I,dwBytesRead);
          until dwBytesRead = 0;
          result[I] := #0;
        end;
      end;
      InternetCloseHandle(hRequest);
    end;
    InternetCloseHandle(hConnect);
  end;
  InternetCloseHandle(hInternet);
  header.Free;
end;

{-------------------------------------------------------------------------------
  Процедура: TBlogger.RetrievAllBlogs
  Автор:    NMD
  Дата:  2010.08.03 21:13:59
  Входные параметры: Нет
  Результат:    получение списка блогов пользователя
-------------------------------------------------------------------------------}
procedure TBlogger.RetrievAllBlogs;
var
  i,i2:Integer;
  Nodes,NodesChild: TXmlNodeList;
begin
  FBlogs.Clear;//очистка блогов перед получением нового списка
  FXMLDoc.Clear;
  FXMLDoc.ReadFromString(GetUrl(cnsBlogDefault,'','get',FAuth,''));
  //проверка на существование коллекции
  if not Assigned(FBlogs) then Exit;
  try
    Nodes:=TXmlNodeList.Create;
    FXMLDoc.Root.FindNodes('entry',Nodes);
    for i := 0 to Nodes.Count-1 do
    begin
      FBlogs.Add;
      FBlogs.Items[i].BlogId:=GetIdBlog(Nodes.Items[i].NodeByName(cnsId).ValueAsString);
      FBlogs.Items[i].Publish:=Nodes.Items[i].NodeByName(cnsPublished).ValueAsDateTime;
      FBlogs.Items[i].Update:=Nodes.Items[i].NodeByName(cnsUpdated).ValueAsDateTime;
      FBlogs.Items[i].Title:=Nodes.Items[i].NodeByName(cnsTitle).ValueAsString;
      NodesChild:=TXmlNodeList.Create;
      Nodes.Items[i].FindNodes(cnsCategory,NodesChild);
      for i2 := 0 to NodesChild.Count - 1 do
      begin
        FBlogs.Items[i].СategoryBlog.Add(NodesChild.Items[i2].AttributeByName[cntTerm]);
      end;
    end;
  finally
    FreeAndNil(Nodes);
    FreeAndNil(NodesChild);
  end;
end;

{-------------------------------------------------------------------------------
  Функция: TBlogger.RetrievAllPosts
  Автор:    NMD
  Дата:  2010.08.09
  Входные параметры: Нет
  Что делает: получает последние 25 сообщений из блога
  Результат: Коллекция TPostCollection содержащая исчерпывающую информацию о сообщении и само сообщение
-------------------------------------------------------------------------------}
function TBlogger.RetrievAllPosts: TPostCollection;
var
  Nodes,NodesChild: TXmlNodeList;
  i,i2:Integer;
begin
  Result:=TPostCollection.Create(nil);
  FXMLDoc.Clear;
  if FAuth<>'' then
  begin//'http://www.blogger.com/feeds/9144819905011498730/posts/default'
    if FCurrentBlog>-1 then
      FXMLDoc.ReadFromString(GetUrl(cnsPostBlogStart+Blogs.Items[FCurrentBlog].FBlogId+cnsPostBlogEnd,'','get',FAuth,''))
    else
      ToError(rsErrorNotSelectBlog);
  end
  else
    ToError(rsErrorNotTolken);

  Nodes:=TXmlNodeList.Create;
  FXMLDoc.Root.FindNodes(cnsEntry,Nodes);
  for i := 0 to Nodes.Count-1 do
  begin
    Result.Add;
    Result.Items[i].PostId:=GetPostId(Nodes.Items[i].NodeByName(cnsId).ValueAsString);
    Result.Items[i].PostTitle:=Nodes.Items[i].NodeByName(cnsTitle).ValueAsString;
    Result.Items[i].PostSourse.Add(Nodes.Items[i].NodeByName(cnsContent).ValueAsString);
    Result.Items[i].PostPublished:=Nodes.Items[i].NodeByName(cnsPublished).ValueAsDateTime;
    Result.Items[i].PostUpdate:=Nodes.Items[i].NodeByName(cnsUpdated).ValueAsDateTime;
    NodesChild:=TXmlNodeList.Create;
    Nodes.Items[i].FindNodes(cnsCategory,NodesChild);
    for i2 := 0 to NodesChild.Count - 1 do
    begin
      Result.Items[i].СategoryPost.Add(NodesChild.Items[i2].AttributeByName[cntTerm]);
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Функция: TBlogger.RetrievPostForTextParams
  Автор:    NMD
  Дата:  2010.08.10 21:09:02
  Входные параметры:
  Parametrs   параметры запроса постов из блога
  Что делает: Возвращает посты из блога по заданным параметрам созданым в ручную
  Результат:  Список постов в коллекции TPostCollection
  Необходимо забивать только параметры после знака вопроса
  http://www.blogger.com/feeds/9144819905011498730/posts/default?category=Application
  то есть category=Application
-------------------------------------------------------------------------------}
function TBlogger.RetrievPostForTextParams(Parametrs:string): TPostCollection;
var
  Nodes,NodesChild: TXmlNodeList;
  i,i2:Integer;
begin
  Result:=TPostCollection.Create(nil);
  FXMLDoc.Clear;
  if FAuth<>'' then
  begin
    if FCurrentBlog>-1 then
      FXMLDoc.ReadFromString(GetUrl(cnsPostBlogStart+Blogs.Items[FCurrentBlog].FBlogId+cnsPostBlogEnd+parametrs,'','get',FAuth,''))
    else
      ToError(rsErrorNotSelectBlog);
  end
  else
    ToError(rsErrorNotTolken);

  Nodes:=TXmlNodeList.Create;
  FXMLDoc.Root.FindNodes(cnsEntry,Nodes);
  for i := 0 to Nodes.Count-1 do
  begin
    Result.Add;
    Result.Items[i].PostId:=GetPostId(Nodes.Items[i].NodeByName(cnsId).ValueAsString);
    Result.Items[i].PostTitle:=Nodes.Items[i].NodeByName(cnsTitle).ValueAsString;
    Result.Items[i].PostSourse.Add(Nodes.Items[i].NodeByName(cnsContent).ValueAsString);
    Result.Items[i].PostPublished:=Nodes.Items[i].NodeByName(cnsPublished).ValueAsDateTime;
    Result.Items[i].PostUpdate:=Nodes.Items[i].NodeByName(cnsUpdated).ValueAsDateTime;
    NodesChild:=TXmlNodeList.Create;
    Nodes.Items[i].FindNodes(cnsCategory,NodesChild);
    for i2 := 0 to NodesChild.Count - 1 do
    begin
      Result.Items[i].СategoryPost.Add(NodesChild.Items[i2].AttributeByName[cntTerm]);
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Функция: TBlogger.RetrievPostForParams
  Автор:    NMD
  Дата:  2010.08.10 19:39:25
  Входные параметры:
  aAlt          atom(default),rss
  aCategory     Посты определенной категории
  aOrderby      Задаем порядок постов в котором мы их получим в список постов lastmodified (the default), starttime, or updated.
  aPublishedMin Ограничение на дату публикации. Игнорируется если orderby установлен в updated
  APublishedMax Ограничение на дату публикации. Игнорируется если orderby установлен в updated
  aUpdatedMin   Ограничение на дату публикации. Игнорируется если orderby установлен в updated
  aUpdatedMax   Ограничение на дату публикации. Игнорируется если orderby установлен в updated
  aStartIndex   Индекс поста который будет получен первым (для докачки постов)
  aMaxResults   Максимальное кол-во возвращаемых постов
  Что делает:   Возвращает посты из блога по заданным параметрам
  Результат:    Список постов в коллекции TPostCollection
  Пример
  http://www.blogger.com/feeds/9144819905011498730/posts/default?category=Application&max-results=10&start-index=1&published-min=2008-03-16T00:00:00&published-max=2011-03-24T23:59:59
-------------------------------------------------------------------------------}
function TBlogger.RetrievPostForParams(aCategory:string =''; aOrderby:string =''; aPublishedMin:string ='';
                                  aPublishedMax:string =''; aUpdatedMin:string ='';aUpdatedMax:string ='';
                                  aStartIndex:Integer=0; aMaxResults:Integer=0; aAlt : string =''): TPostCollection;
var
  i:Integer;
  temp:TStringList;
  parametrs:string;
begin
  Result:=TPostCollection.Create(nil);
  if FAuth='' then
  begin
    ToError(rsErrorNotTolken);
    Exit;
  end;
  if FCurrentBlog<0 then
    begin
    ToError(rsErrorNotSelectBlog);
    Exit;
  end;
  parametrs:='';
  temp:=TStringList.Create;
  if aAlt<>'' then
    temp.Add('alt='+aAlt);
  if aCategory<>'' then
    temp.Add('category='+aCategory);
  if aOrderby<>'' then
    temp.Add('orderby='+aOrderby);
  if aPublishedMin<>'' then
    temp.Add('published-min='+aPublishedMin);
  if APublishedMax<>'' then
    temp.Add('published-max='+aPublishedMax);
  if aUpdatedMin<>'' then
    temp.Add('updated-min='+aUpdatedMin);
  if aUpdatedMax<>'' then
    temp.Add('updated-max='+aUpdatedMax);
  if aStartIndex<>0 then
    temp.Add('start-index='+IntToStr(aStartIndex));
  if aMaxResults<>0 then
    temp.Add('max-results='+IntToStr(aMaxResults));
  for I := 0 to temp.Count - 1 do
  begin
    if i>0 then
      parametrs:=parametrs+'&'+temp.Strings[i]
    else
      parametrs:=parametrs+temp.Strings[i];
  end;
  temp.Free;
  Result:=RetrievPostForTextParams(cnsVop+parametrs);
end;

{-------------------------------------------------------------------------------
  Процедура: TBlogger.CreatPost формируем xml будущего сообщения и отправляем его в блог
  Автор:    NMD
  Дата:  2010.08.06 18:37:01
  Входные параметры:
  aTitle- заголовок,
  aContent-текст сообщения: string;
  aCategory-ярлыки сообщения: TStringList;
  aComment: Boolean комментарий или нет
  Результат:    string получаем xml отправленной статьи но уже из блогга или текст ошибки
-------------------------------------------------------------------------------}
function TBlogger.PostCreat(aTitle, aContent: string; aCategory: TStringList; aComment: Boolean):UTF8String;
var
  i:Integer;
  Node,Node2:TXmlNode;
  tempXML :TNativeXml;
begin
  Result:='';
  if FAuth='' then
  begin
    ToError(rsErrorNotTolken);
    Exit;
  end;
  if FCurrentBlog<0 then
  begin
    ToError(rsErrorNotSelectBlog);
    Exit;
  end;

  FXMLDoc.Clear;
  FXMLDoc.Root.CreateName(FXMLDoc,cnsEntry).AttributeAdd(cnsXmlns,cnsAtomUrl);
  {<app:control xmlns:app='http://www.w3.org/2007/app'>
    <app:draft>yes</app:draft>
  </app:control>}
  if aComment then
  begin
    Node:=FXMLDoc.Root.NodeNew(cnsAppControll);
    Node.AttributeAdd(cnsXmlnsApp,cnsXmlnsAppUrl);
    Node2:=TXmlNode.CreateNameValue(FXMLDoc,cnsAppDraft,cnsYes);
    Node.NodeAdd(Node2);
  end;

  //<title type='text'>Marriage!</title>
  with FXMLDoc.Root.NodeNew(cnsTitle)do
  begin
    AttributeAdd(cnsType,cnsText);
    ValueAsString:=aTitle;
  end;
  //  <content type='xhtml'>
  Node:=FXMLDoc.Root.NodeNew(cnsContent);
  Node.AttributeAdd(cnsType,cnsXhtml);
  //сам контент единственное он должен быть валидным html
  tempXML:=TNativeXml.Create;
  try
    tempXML.ReadFromString(aContent);
  except
    ToError(rsErrorXmlTag);
    tempXML:=nil;
    Exit;//выход
  end;
  for I := 0 to tempXML.RootNodeList.NodeCount - 1 do
  begin
    node2:=tempXML.RootNodeList.Nodes[i];
    node.NodeAdd(node2);
  end;
{  //<div xmlns="http://www.w3.org/1999/xhtml">
  Node2:=TXmlNode.CreateName(FXMLDoc,cnsDiv);
  Node2.AttributeAdd(cnsXmlns,cnsXhtmlUrl);
  Node.NodeAdd(Node2);
  Node:=TXmlNode.CreateName(FXMLDoc,'p');
  Node.ValueAsString:=aContent;
  Node2.NodeAdd(Node);
}
  //<category scheme="http://www.blogger.com/atom/ns#" term="marriage" />
  for i := 0 to aCategory.Count - 1 do
    with FXMLDoc.Root.NodeNew(cnsCategory) do
    begin
      AttributeAdd(cnsScheme,cnsAtnsUrl);
      AttributeAdd(cnsTerm,sdAnsiToUtf8(aCategory.Strings[i]));
    end;
  Result:=GetUrl(cnsPostBlogStart+Blogs.Items[FCurrentBlog].FBlogId+cnsPostBlogEnd,'','post',FAuth,FXMLDoc.WriteToString);
  tempXML:=nil;
end;

{-------------------------------------------------------------------------------
  Функция: TBlogger.PostModify
  Автор:    NMD
  Дата:  2010.08.10 21:28:47
  Входные параметры:
  id сообщения, остальное анологично созданию поста
  Что делает: Производит обновление поста в блоге
  Результат: xml модифицированного сообщения
-------------------------------------------------------------------------------}
function TBlogger.PostModify(id, aTitle, aContent: string; aCategory: TStringList; aComment: Boolean): UTF8String;
var
  i:Integer;
  Node,Node2:TXmlNode;
  blogId:string;
begin
  Result:='';
  if FAuth='' then
  begin
    ToError(rsErrorNotTolken);
    Exit;
  end;
  if FCurrentBlog<0 then
  begin
    ToError(rsErrorNotSelectBlog);
    Exit;
  end;
  FXMLDoc.Clear;
  FXMLDoc.Root.CreateName(FXMLDoc,cnsEntry).AttributeAdd(cnsXmlns,cnsAtomUrl);

  {<app:control xmlns:app='http://www.w3.org/2007/app'>
    <app:draft>yes</app:draft>
  </app:control>}
  if aComment then
  begin
    Node:=FXMLDoc.Root.NodeNew(cnsAppControll);
    Node.AttributeAdd(cnsXmlnsApp,cnsXmlnsAppUrl);
    Node2:=TXmlNode.CreateNameValue(FXMLDoc,cnsAppDraft,cnsYes);
    Node.NodeAdd(Node2);
  end;
  //  <id>tag:blogger.com,1999:blog-blogID.post-postID</id>
  blogId:=IntToStr(FBlogs.Items[FCurrentBlog].id);//id блога
  FXMLDoc.Root.NodeNew(cnsId).ValueAsString:='tag:blogger.com,1999:blog-'+blogId+'.post-'+id;
  //<title type='text'>Marriage!</title>
  with FXMLDoc.Root.NodeNew(cnsTitle)do
  begin
    AttributeAdd(cnsType,cnsText);
    ValueAsString:=aTitle;
  end;
  //  <content type='xhtml'>
  Node:=FXMLDoc.Root.NodeNew(cnsContent);
  Node.AttributeAdd(cnsType,cnsXhtml);
  //<div xmlns="http://www.w3.org/1999/xhtml">
  Node2:=TXmlNode.CreateName(FXMLDoc,cnsDiv);
  Node2.AttributeAdd(cnsXmlns,cnsXhtmlUrl);
  Node.NodeAdd(Node2);
  Node:=TXmlNode.CreateName(FXMLDoc,'p');
  Node.ValueAsString:=aContent;
  Node2.NodeAdd(Node);

  //<category scheme="http://www.blogger.com/atom/ns#" term="marriage" />
  for i := 0 to aCategory.Count - 1 do
    with FXMLDoc.Root.NodeNew(cnsCategory) do
    begin
      AttributeAdd(cnsScheme,cnsAtnsUrl);
      AttributeAdd(cnsTerm,sdAnsiToUtf8(aCategory.Strings[i]));
    end;
  //'http://www.blogger.com/feeds/1897581382578917834/posts/default/5129237316807356045',
  Result:=GetUrl(cnsPostBlogStart+Blogs.Items[FCurrentBlog].FBlogId+cnsPostBlogEnd+'/'+id,'','put',FAuth,FXMLDoc.WriteToString);
end;

{-------------------------------------------------------------------------------
  Функция: TBlogger.PostDelete
  Автор:    NMD
  Дата:  2010.08.11 19:24:17
  Входные параметры:
  id сообщения которое необходимо удалить
  Что делает: удаление поста из блога
  Результат:    Boolean
-------------------------------------------------------------------------------}
function TBlogger.PostDelete(id: string): Boolean;
begin
  if FAuth='' then
  begin
    ToError(rsErrorNotTolken);
    Exit;
  end;
  if FCurrentBlog<0 then
  begin
    ToError(rsErrorNotSelectBlog);
    Exit;
  end;
  if id='' then
  begin
    ToError(rsErrorIdPost);
    Exit;
  end;
  if GetUrl(cnsPostBlogStart+Blogs.Items[FCurrentBlog].FBlogId+cnsPostBlogEnd+'/'+id,'','DELETE',FAuth,'')='1' then
    Result:=True
  else
    Result:=False;
end;


procedure TBlogger.SetAppName(const Value: string);
begin
  if Value<>'' then
    FAppName := Value;
end;

procedure TBlogger.SetAuth(const Value: string);
begin
  if Value<>'' then
  begin
    FAuth := Value;
  end;
end;

procedure TBlogger.SetBlog(const Value: TBlogCollection);
begin
  FBlogs.Assign(Value);
end;

procedure TBlogger.SetCurrentBlog(const Value: Integer);
begin
  FCurrentBlog := Value;
end;

{BlogCollection}
function TBlogCollection.Add: TBlogItem;
begin
  result := TBlogItem(inherited Add);
end;

function TBlogCollection.AddEx(aName, aTitle,aBlogId: string; aUrl: string; aСategoryBlog: TStringList; aPublished,
  aUpdate: TDateTime): TBlogItem;
begin
  result := inherited Add as TBlogItem;
  Result.FTitle:=aTitle;
  Result.FBlogId:=aBlogId;
  Result.FСategoryBlog.Assign(aСategoryBlog);
  Result.FPublished:=aPublished;
  Result.FUpdate:=aUpdate;
end;

constructor TBlogCollection.Create(AOwner: TComponent);
begin
  inherited Create(TBlogItem);
end;

function TBlogCollection.GetItemBlog(Index: Integer): TBlogItem;
begin
  result := TBlogItem(inherited GetItem(Index));
end;

procedure TBlogCollection.SetItemBlog(Index: Integer; Value: TBlogItem);
begin
  inherited SetItem(Index, Value)
end;

constructor TBlogItem.Create(Collection: TCollection);
begin
  inherited;
  FTitle:='';
  FBlogId:='';
  FСategoryBlog:=TStringList.Create;//ярлыки блога
  FPublished:=Time;//дата последеней публикации
  FUpdate:=Time;//дата последнего обновления
end;

destructor TBlogItem.Destroy;
begin
  FСategoryBlog.Destroy;
  inherited;
end;

procedure TBlogItem.SetCategory(const Value: TStringList);
begin
  FСategoryBlog.Assign(Value);
end;

procedure TBlogItem.SetBlogId(const Value: string);
begin
  FBlogId := Value;
end;

procedure TBlogItem.SetPublished(const Value: TDateTime);
begin
  FPublished := Value;
end;

procedure TBlogItem.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

procedure TBlogItem.SetUpdate(const Value: TDateTime);
begin
  FUpdate := Value;
end;

{ TPostItem }

constructor TPostItem.Create(Collection: TCollection);
begin
  inherited;
  FPostSourse:=TStringList.Create;
  FСategoryPost:=TStringList.Create;
end;

destructor TPostItem.Destroy;
begin
  FPostSourse.Free;
  FСategoryPost.Free;
  inherited;
end;

procedure TPostItem.SetPostId(const Value: string);
begin
  FPostId := Value;
end;

procedure TPostItem.SetPostPublished(const Value: TDateTime);
begin
  FPostPublished := Value;
end;

procedure TPostItem.SetPostSourse(const Value: TStringList);
begin
  FPostSourse.Assign(Value);
end;

procedure TPostItem.SetPostTitle(const Value: string);
begin
  FPostTitle := Value;
end;

procedure TPostItem.SetPostUpdate(const Value: TDateTime);
begin
  FPostUpdate:=Value;
end;

procedure TPostItem.SetСategoryPost(const Value: TStringList);
begin
  FСategoryPost.Assign(Value);
end;

{ TPostCollection }

function TPostCollection.Add: TPostItem;
begin
  result := TPostItem(inherited Add);
end;

function TPostCollection.AddEx(aPostTitle, aPostId: string; aPostSourse: TStringList; aPostPublished,
  aPostUpdate: TDateTime): TPostItem;
begin
  result := inherited Add as TPostItem;
  Result.FPostTitle:=aPostTitle;
  Result.FPostId:=aPostId;
  Result.FPostSourse.Assign(aPostSourse);
  Result.FPostPublished:=aPostPublished;
  Result.FPostUpdate:=aPostUpdate;
end;

constructor TPostCollection.Create(AOwner: TComponent);
begin
  inherited Create(TPostItem);
end;

function TPostCollection.GetItemBlog(Index: Integer): TPostItem;
begin
  result := TPostItem(inherited GetItem(Index));
end;

procedure TPostCollection.SetItemBlog(Index: Integer; Value: TPostItem);
begin
   inherited SetItem(Index, Value);
end;

procedure Register;
begin
  RegisterComponents('WebDelphi.ru', [TBlogger]);
end;

{ TCommentItem }

constructor TCommentItem.Create(Collection: TCollection);
begin
  inherited;
  FCommentSourse:=TStringList.Create;
end;

destructor TCommentItem.Destroy;
begin
  FCommentSourse.Free;
  inherited;
end;

procedure TCommentItem.SetCommentAutorEmail(const Value: string);
begin
  FAutorEmail := Value;
end;

procedure TCommentItem.SetCommentAutorName(const Value: string);
begin
  FAutorName := Value;
end;

procedure TCommentItem.SetCommentAutorURL(const Value: string);
begin
  FAutorURL := Value;
end;

procedure TCommentItem.SetCommentId(const Value: string);
begin
  FCommentId:=Value;
end;

procedure TCommentItem.SetCommentPublished(const Value: TDateTime);
begin
  FCommentPublished:=Value;
end;

procedure TCommentItem.SetCommentSourse(const Value: TStringList);
begin
  FCommentSourse.Assign(Value);
end;

procedure TCommentItem.SetCommentTitle(const Value: string);
begin
  FCommentTitle:=Value;
end;

procedure TCommentItem.SetCommentUpdate(const Value: TDateTime);
begin
  FCommentUpdate:=Value;
end;

{ TCommentCollection }

function TCommentCollection.Add: TCommentItem;
begin

end;

function TCommentCollection.AddEx(aPostTitle, aPostId: string; aPostSourse: TStringList; aPostPublished,
  aPostUpdate: TDateTime): TCommentItem;
begin

end;

constructor TCommentCollection.Create(AOwner: TComponent);
begin
  inherited Create(TCommentItem);
end;

function TCommentCollection.GetItemComment(Index: Integer): TCommentItem;
begin
  result := TCommentItem(inherited GetItem(Index));
end;

procedure TCommentCollection.SetItemComment(Index: Integer; Value: TCommentItem);
begin
   inherited SetItem(Index, Value);
end;

end.

