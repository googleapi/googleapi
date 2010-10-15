unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, BloggerApi, uGoogleLogin, ComCtrls;

type
  TForm1 = class(TForm)
    Blogger1: TBlogger;
    Button1: TButton;
    Memo1: TMemo;
    GoogleLogin1: TGoogleLogin;
    ComboBox1: TComboBox;
    Button2: TButton;
    Memo2: TMemo;
    Memo3: TMemo;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Edit1: TEdit;
    Button6: TButton;
    ProgressBar1: TProgressBar;
    Button7: TButton;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure GoogleLogin1Autorization(const LoginResult: TLoginResult; Result: TResultRec);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Blogger1Error(E: string);
    procedure ComboBox1Change(Sender: TObject);
    procedure Blogger1Progress(aCurrentProgress, aMaxProgress: Integer);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Blogger1Error(E: string);
begin
  ShowMessage(e);
end;

procedure TForm1.Blogger1Progress(aCurrentProgress, aMaxProgress: Integer);
begin
  ProgressBar1.Max:=aMaxProgress;
  ProgressBar1.Position:=aCurrentProgress;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  GoogleLogin1.Password:=Edit2.Text;
  GoogleLogin1.Login;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  a:TStringList;
begin
  a:=TStringList.Create;
  a.Add('dd');
  Memo1.Lines.Text:= Blogger1.PostCreat(Memo2.Text,Memo3.Text ,a,False);
  a.Free;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  aa:TPostCollection;
begin
  aa:=TPostCollection.Create(nil);
  aa:=Blogger1.RetrievAllPosts;
  if aa.Count<1 then
    Exit;
  Memo1.Lines.Add( IntToStr( aa.Count));
  Memo1.Lines.Add(aa.Items[0].PostId);
  Memo1.Lines.Add(DateToStr(aa.Items[0].PostPublished));
  Memo1.Lines.Add(DateToStr(aa.Items[0].PostUpdate));
  Memo1.Lines.Add(aa.Items[0].PostTitle);
  Memo1.Lines.Add(aa.Items[0].PostSourse.Text);
  Memo1.Lines.Add(aa.Items[0].СategoryPost.Text);
  aa.Free;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  aa:TPostCollection;
begin
  aa:=TPostCollection.Create(nil);
  aa:=Blogger1.RetrievPostForParams('Wininet','','','','','',1,2);
  if aa.Count<1 then
  begin
    aa.Free;
    Exit;
  end;
  Memo1.Lines.Add( IntToStr( aa.Count));
  Memo1.Lines.Add(aa.Items[0].PostId);
  Memo1.Lines.Add(DateToStr(aa.Items[0].PostPublished));
  Memo1.Lines.Add(DateToStr(aa.Items[0].PostUpdate));
  Memo1.Lines.Add(aa.Items[0].PostTitle);
  Memo1.Lines.Add(aa.Items[0].PostSourse.Text);
  Memo1.Lines.Add(aa.Items[0].СategoryPost.Text);
  aa.Free;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  a:TStringList;
begin
  a:=TStringList.Create;
  a.Add('Привет');
  Blogger1.PostModify(Edit1.Text,Memo2.Text,Memo3.Text ,a,False);
  a.Free;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Blogger1.PostDelete(Edit1.Text);
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  a:TCommentCollection;
  i:Integer;
begin
  a:=TCommentCollection.Create(nil);
  a:=Blogger1.RetrievAllComments;
  if a.Count<=0 then
  begin
    a.Free;
    Exit;
  end;
  for I := 0 to a.Count - 1 do
  begin
    Memo3.Lines.Add('Имя автора: '+a.Items[i].CommentAutorName);
    Memo3.Lines.Add('URL: '+a.Items[i].CommentAutorURL);
    Memo3.Lines.Add('Email: '+a.Items[i].CommentAutorEmail);
    Memo3.Lines.Add('ID Комментария: '+a.Items[i].CommentId);
    Memo3.Lines.Add('Заголовок комментария: '+a.Items[i].CommentTitle);
    Memo3.Lines.Add('Текст комментария: '+a.Items[i].CommentSourse.Text);
    Memo3.Lines.Add('Дата публикации: '+DateToStr( a.Items[i].CommentPublished ));
    Memo3.Lines.Add('Дата обновления: '+DateToStr( a.Items[i].CommentPublished ));

  end;
  a.Free;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  Blogger1.CurrentBlog:=ComboBox1.ItemIndex;
end;

procedure TForm1.GoogleLogin1Autorization(const LoginResult: TLoginResult; Result: TResultRec);
var
  i:Integer;
begin
  Blogger1.Auth:=Result.Auth;
  Blogger1.RetrievAllBlogs;
  Memo1.Lines:=Blogger1.Blogs.Items[1].СategoryBlog;

  for I := 0 to Blogger1.Blogs.Count - 1 do
    ComboBox1.Items.Add(Blogger1.Blogs.Items[i].Title);
end;

end.
