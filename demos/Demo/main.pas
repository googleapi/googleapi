unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uGoogleLogin;

type
  TForm11 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    EmailEdit: TEdit;
    PassEdit: TEdit;
    Button1: TButton;
    Label4: TLabel;
    GoogleLogin1: TGoogleLogin;
    Label3: TLabel;
    Label5: TLabel;
    ComboBox1: TComboBox;
    Label6: TLabel;
    AuthEdit: TEdit;
    ResultEdit: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure GoogleLogin1AfterLogin(const LoginResult: TLoginResult;
      LoginStr: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form11: TForm11;

implementation

{$R *.dfm}


procedure TForm11.Button1Click(Sender: TObject);
begin
GoogleLogin1.Email:=EmailEdit.Text;
GoogleLogin1.Password:=PassEdit.Text;
GoogleLogin1.Service:=TServices(ComboBox1.ItemIndex);
GoogleLogin1.Login();
end;

procedure TForm11.GoogleLogin1AfterLogin(const LoginResult: TLoginResult;
  LoginStr: string);
begin
  ResultEdit.Text:=LoginStr;
  AuthEdit.Text:=GoogleLogin1.Auth;
end;

end.
