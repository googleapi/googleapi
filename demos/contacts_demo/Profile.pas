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
    { Public declarations }
  end;

var
  ProfileForm: TProfileForm;

implementation

uses main;

{$R *.dfm}

procedure TProfileForm.Button1Click(Sender: TObject);
begin
  Loginer:=TGoogleLogin.Create(Edit1.Text,Edit2.Text);
  Loginer.Service:=tsContacts;
  GmailContact:=Edit3.Text;

  if Loginer.LastResult=lrOk then
    Contact:=TGoogleContact.Create(self,Loginer.Auth,GmailContact);

  Hide;
end;

end.
