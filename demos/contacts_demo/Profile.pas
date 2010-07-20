unit Profile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,GoogleLogin,GContacts;

type
  TProfileForm = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
   procedure Authorize (const LoginResult: TLoginResult; Result: TResultRec);
  end;

var
  ProfileForm: TProfileForm;

implementation

uses main;

{$R *.dfm}

procedure TProfileForm.Authorize(const LoginResult: TLoginResult;
  Result: TResultRec);
begin
  if LoginResult=lrOk then
    begin
      Contact:=TGoogleContact.Create(self);
      Contact.Gmail:=GmailContact;
      Contact.Auth:=Result.Auth;
    end;
  Form3.ToolButton2.Enabled:=LoginResult=lrOk;
end;

procedure TProfileForm.Button1Click(Sender: TObject);
begin
  Loginer:=TGoogleLogin.Create(self);
  Loginer.Email:=Edit1.Text;
  Loginer.Password:=Edit2.Text;
  Loginer.Service:=cp;
  Loginer.OnAutorization:=Authorize;
  GmailContact:=Edit3.Text;

  Loginer.Login();





  Hide;
end;

end.
